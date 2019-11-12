package com.qpidnetwork.anchor.liveshow.pushmanager;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.RequiresApi;
import android.support.v4.app.NotificationCompat;
import android.text.TextUtils;
import android.text.format.Time;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.bean.CommonConstant;
import com.qpidnetwork.anchor.bean.MainModuleConfig;
import com.qpidnetwork.anchor.framework.services.LiveService;
import com.qpidnetwork.anchor.liveshow.googleanalytics.AnalyticsManager;

import java.util.UUID;

/**
 * Push消息生成管理器
 * Created by Hunter Mun on 2017/9/15.
 */

public class PushManager {
    //push通知 targetSdkVersion 26 版本channel id
    public final String PUSH_NOTIFICATION_CHANNEL_ID = "channel_anchor";

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

        //读取系统设置处理push通知状态
        boolean isVibrate = true;
        boolean isSound = true;
        MainModuleConfig config = LiveService.getInstance().getmMainModuleConfig();
        if (config != null) {
            isVibrate = config.isNotificationVibrate;
            isSound = config.isNotificationSound;
        }

        //-----------------------------
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            sendNotification_26(type, title, tickerText, pushActionUrl, isAutoCancel, isVibrate, isSound);
        }else{
            sendNotification_old(type, title, tickerText, pushActionUrl, isAutoCancel, isVibrate, isSound);
        }
        //-----------------------------

        //GA统计，收到主播邀请/预约到期
        AnalyticsManager instance = AnalyticsManager.getsInstance();
        if (instance != null) {
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


    /**
     * 系统版本26及以上push通知中心逻辑
     */
    @RequiresApi(api = Build.VERSION_CODES.O)
    private void sendNotification_26(PushMessageType type,
                                     String title,
                                     String tickerText,
                                     String pushActionUrl,
                                     boolean isAutoCancel,
                                     boolean isVibrate,
                                     boolean isSound){

        // 通知优先级和重要性:
        // 可以配置五个级别中的一个，
        // 这些级别代表着通知渠道可以打断用户的程度，范围是 IMPORTANCE_NONE(0)至 IMPORTANCE_HIGH(4)。
        // 默认重要性级别为 3：在所有位置显示，发出提示音，但不会对用户产生视觉干扰。
//        if(type == NotificationTypeEnum.LIVE_LIVECHAT_NOTIFICATION || type == NotificationTypeEnum.LIVECHAT_NOTIFICATION){
//            //聊天消息
//            createNotificationChannel(mNotification, NotificationManager.IMPORTANCE_HIGH, isVibrate);
//        }else{
        //订阅消息
        createNotificationChannel(mNotification, NotificationManager.IMPORTANCE_DEFAULT, isVibrate);
//        }

        // 创建新的通知
        Notification.Builder builder = new Notification.Builder(mContext, PUSH_NOTIFICATION_CHANNEL_ID);

        /*
            2019/1/14 Hardy
            问题：https://www.qoogifts.com.cn/zentaopms2/www/index.php?m=bug&f=view&bugID=15953
            修复：https://blog.csdn.net/qq1073273116/article/details/83087120
         */
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
//            builder.setGroupSummary(false);
//            builder.setGroup(mContext.getPackageName());
//        }

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

        //设置title
        if(TextUtils.isEmpty(title)){
            builder.setContentTitle(mContext.getResources().getString(R.string.app_name));
        }else {
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
        if (type != PushMessageType.Program_10_Minute_Notify) {
            intent.putExtras(bundle);
            intent.setAction(CommonConstant.ACTION_ANCHOR_PUSH_NOTIFICATION);
            intent.setPackage(mContext.getPackageName()); //8.0+需要这个 参考:https://blog.csdn.net/u011386173/article/details/82889275
        }

        //使用UUID保证requestCode唯一性，避免多个通知的PendingIntent事件冲突
        PendingIntent resultPendingIntent = PendingIntent.getBroadcast(mContext, UUID.randomUUID().hashCode(), intent, PendingIntent.FLAG_UPDATE_CURRENT);
        builder.setContentIntent(resultPendingIntent);

        // 点击关闭
        builder.setAutoCancel(isAutoCancel);

        //生成系统通知
        int notificationId = mPushNotificationIdGenerator.generateNotificationId(type);
        mNotification.cancel(notificationId);//先取消旧的
        mNotification.notify(notificationId, builder.build());
    }

    /**
     * 系统版本26以下push通知中心逻辑
     */
    private void sendNotification_old(PushMessageType type,
                                      String title,
                                      String tickerText,
                                      String pushActionUrl,
                                      boolean isAutoCancel,
                                      boolean isVibrate,
                                      boolean isSound){
        // 创建新的通知
        NotificationCompat.Builder builder = new NotificationCompat.Builder(mContext);

        // 振动
        if (isVibrate) {
            long[] vibrate = {0, 100, 200, 300};
            builder.setVibrate(vibrate);
        }
        // 声音
        if (isSound) {
            builder.setDefaults(Notification.DEFAULT_SOUND);
        }

        // 设置图标
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP) {
            builder.setSmallIcon(R.drawable.logo_white_48dp);
        } else {
            builder.setSmallIcon(R.drawable.logo_40dp);
        }

        builder.setTicker(tickerText);

        // 状态栏
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP) {
            builder.setSmallIcon(R.drawable.logo_white_48dp);
        } else {
            //            builder.setSmallIcon(R.drawable.ic_launcher);
            builder.setSmallIcon(R.drawable.logo_40dp);
        }

        //设置title
        if (TextUtils.isEmpty(title)) {
            builder.setContentTitle(mContext.getString(R.string.app_name));
        } else {
            builder.setContentTitle(title);
        }

        //设置描述
        builder.setContentText(tickerText);

        //设置时间
        Time time = new Time();
        time.setToNow();
        builder.setWhen(time.toMillis(false));

        //封装参数, 点击事件
        Intent intent = new Intent();
        if (type != PushMessageType.Program_10_Minute_Notify) {
            //10分钟开播通知点击无响应
            Bundle bundle = new Bundle();
            bundle.putString(CommonConstant.KEY_PUSH_NOTIFICATION_URL, pushActionUrl);
            //建立Intent
            intent.putExtras(bundle);
            intent.setAction(CommonConstant.ACTION_ANCHOR_PUSH_NOTIFICATION);
        }
        //使用UUID保证requestCode唯一性，避免多个通知的PendingIntent事件冲突
        PendingIntent resultPendingIntent = PendingIntent.getBroadcast(mContext, UUID.randomUUID().hashCode(), intent, PendingIntent.FLAG_UPDATE_CURRENT);
        builder.setContentIntent(resultPendingIntent);

        // 点击关闭
        builder.setAutoCancel(isAutoCancel);

        //生成系统通知
        int notificationId = mPushNotificationIdGenerator.generateNotificationId(type);
        mNotification.cancel(notificationId);//先取消旧的
        mNotification.notify(notificationId, builder.build());
    }

    /**
     * targetSdkVersion 26 通知中心兼容性
     */
    public void createNotificationChannel(NotificationManager notification,int importance, boolean isVibrate) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            CharSequence name = mContext.getResources().getString(R.string.app_name);
            NotificationChannel channel = new NotificationChannel(PUSH_NOTIFICATION_CHANNEL_ID, name, importance);
            channel.enableVibration(isVibrate);
            channel.setVibrationPattern(new long[]{0, 100, 200, 300});
            notification.createNotificationChannel(channel);
        }
    }

}
