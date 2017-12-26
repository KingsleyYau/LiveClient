package com.qpidnetwork.livemodule.liveshow.manager;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.NotificationCompat;
import android.text.TextUtils;
import android.text.format.Time;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.services.LiveService;
import com.qpidnetwork.livemodule.liveshow.googleanalytics.AnalyticsManager;
import com.qpidnetwork.qnbridgemodule.bean.CommonConstant;
import com.qpidnetwork.qnbridgemodule.bean.MainModuleConfig;

import java.util.UUID;

/**
 * Push消息生成管理器
 * Created by Hunter Mun on 2017/9/15.
 */

public class PushManager {

    private static PushManager gPushManager;
    private Context mContext = null;
    private NotificationManager mNotification;
    private PushNotificationIdGenerator mPushNotificationIdGenerator;       //notificationID 生成器


    public static PushManager newInstance(Context context) {
        if( gPushManager == null ) {
            gPushManager = new PushManager(context);
        }
        return gPushManager;
    }

    public static PushManager getInstance() {
        return gPushManager;
    }

    public PushManager(Context context)  {
        mContext = context;
        mNotification = (NotificationManager)mContext.getSystemService(Context.NOTIFICATION_SERVICE);
        mPushNotificationIdGenerator = new PushNotificationIdGenerator();
    }

    /**
     * 通知栏显示通知
     * @param tickerText
     */
    public void ShowNotification(
            PushMessageType type,
            String title,
            String tickerText,
            String pushActionUrl,
            boolean isAutoCancel) {

        // 创建新的通知
        NotificationCompat.Builder builder = new NotificationCompat.Builder(mContext);

        //读取系统设置处理push通知状态
        boolean isVibrate = true;
        boolean isSound = true;
        MainModuleConfig config = LiveService.getInstance().getmMainModuleConfig();
        if(config != null){
            isVibrate = config.isNotificationVibrate;
            isSound = config.isNotificationSound;
        }
        // 振动
        if( isVibrate ) {
            long[] vibrate = {0, 100, 200, 300};
            builder.setVibrate(vibrate);
        }
        // 声音
        if( isSound ) {
            builder.setDefaults(Notification.DEFAULT_SOUND);
        }

        // 设置图标
        if(android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP){
            builder.setSmallIcon(R.drawable.logo_white_48dp);
        }else{
            builder.setSmallIcon(R.drawable.logo_40dp);
        }

        builder.setTicker(tickerText);

        // 状态栏
        if(android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP){
            builder.setSmallIcon(R.drawable.logo_white_48dp);
        }else{
//            builder.setSmallIcon(R.drawable.ic_launcher);
            builder.setSmallIcon(R.drawable.logo_40dp);
        }

        //设置title
        if(TextUtils.isEmpty(title)){
            builder.setContentTitle(mContext.getString(R.string.app_name));
        }else{
            builder.setContentTitle(title);
        }

        //设置描述
        builder.setContentText(tickerText);

        //设置时间
        Time time = new Time();
        time.setToNow();
        builder.setWhen(time.toMillis(false));

        //封装参数, 点击事件
        Bundle bundle = new Bundle();
        bundle.putString(CommonConstant.KEY_PUSH_NOTIFICATION_URL, pushActionUrl);
        //建立Intent
        Intent intent = new Intent();
        intent.putExtras(bundle);
        intent.setAction(CommonConstant.ACTION_PUSH_NOTIFICATION);
        //使用UUID保证requestCode唯一性，避免多个通知的PendingIntent事件冲突
        PendingIntent resultPendingIntent = PendingIntent.getBroadcast(mContext, UUID.randomUUID().hashCode(), intent, PendingIntent.FLAG_UPDATE_CURRENT);
        builder.setContentIntent(resultPendingIntent);

        // 点击关闭
        builder.setAutoCancel(isAutoCancel);

        //生成系统通知
        int notificationId = mPushNotificationIdGenerator.generateNotificationId(type);
        mNotification.cancel(notificationId);//先取消旧的
        mNotification.notify(notificationId, builder.build());

        //GA统计，收到主播邀请/预约到期
        AnalyticsManager instance = AnalyticsManager.getsInstance();
        if(instance != null) {
            if (type == PushMessageType.Anchor_Invite_Notify) {
                instance.ReportEvent(mContext.getResources().getString(R.string.Live_Global_Category),
                        mContext.getResources().getString(R.string.Live_Global_Action_ShowInvitation),
                        mContext.getResources().getString(R.string.Live_Global_Label_ShowInvitation));
            } else if (type == PushMessageType.Schedule_Invite_Expired) {
                instance.ReportEvent(mContext.getResources().getString(R.string.Live_Global_Category),
                        mContext.getResources().getString(R.string.Live_Global_Action_ShowBookingStart),
                        mContext.getResources().getString(R.string.Live_Global_Label_ShowBookingStart));
            }
        }
    }

    /**
     * 取消置顶类型的所有Push
     * @param type
     */
    public void Cancel(PushMessageType type) {
        int baseId = mPushNotificationIdGenerator.getNotificationBaseId(type);
        int maxCount = mPushNotificationIdGenerator.getNotificationMaxCount(type);
        if(baseId > 0 && maxCount>0){
            for(int i=0; i<maxCount; i++){
                mNotification.cancel(baseId + i);
            }
        }
    }

    /**
     * 清除应用所有Push通知消息
     */
    public void CancelAll(){
        mNotification.cancelAll();
    }

}
