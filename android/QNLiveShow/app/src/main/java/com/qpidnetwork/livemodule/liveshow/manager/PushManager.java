package com.qpidnetwork.livemodule.liveshow.manager;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.support.v4.app.NotificationCompat;
import android.text.TextUtils;
import android.text.format.Time;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.liveshow.home.MainFragmentActivity;

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
     * @param icon
     * @param tickerText
     * @param isVibrate
     * @param isSound
     */
    public void ShowNotification(
            PushMessageType type,
            int icon,
            String title,
            String tickerText,
            boolean isVibrate,
            boolean isSound,
            boolean isAutoCancel) {



        // 创建新的通知
        NotificationCompat.Builder builder = new NotificationCompat.Builder(mContext);

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
            builder.setSmallIcon(icon);
        }
        builder.setTicker(tickerText);

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

        // 点击事件
        Intent intent = new Intent();
        intent.setClass(mContext, MainFragmentActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);

        PendingIntent resultPendingIntent = PendingIntent.getActivity(mContext, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT);

        // 点击关闭
        builder.setAutoCancel(isAutoCancel);

        builder.setContentIntent(resultPendingIntent);

        //生成系统通知
        int notificationId = mPushNotificationIdGenerator.generateNotificationId(type);
        mNotification.cancel(notificationId);//先取消旧的
        mNotification.notify(notificationId, builder.build());
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
