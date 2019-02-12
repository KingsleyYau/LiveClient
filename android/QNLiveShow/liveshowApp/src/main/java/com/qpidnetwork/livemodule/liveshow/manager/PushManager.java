package com.qpidnetwork.livemodule.liveshow.manager;

import android.content.Context;

import com.qpidnetwork.livemodule.liveshow.LiveModule;
import com.qpidnetwork.qnbridgemodule.bean.NotificationTypeEnum;

/**
 * Push消息生成管理器
 * Created by Hunter Mun on 2017/9/15.
 */

public class PushManager {

    private static PushManager gPushManager;
    private Context mContext = null;

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
    }

    /**
     * 通知栏显示通知
     * @param tickerText
     */
    public void ShowNotification(
            NotificationTypeEnum type,
            String title,
            String tickerText,
            String pushActionUrl,
            boolean isAutoCancel) {
        LiveModule.getInstance().showSystemNotification(type, title, tickerText, pushActionUrl, isAutoCancel);

//        //GA统计，收到主播邀请/预约到期
//        AnalyticsManager instance = AnalyticsManager.getsInstance();
//        if(instance != null) {
//            if (type == PushMessageType.Anchor_Invite_Notify) {
//                instance.ReportEvent(mContext.getResources().getString(R.string.Live_Global_Category),
//                        mContext.getResources().getString(R.string.Live_Global_Action_ShowInvitation),
//                        mContext.getResources().getString(R.string.Live_Global_Label_ShowInvitation));
//            } else if (type == PushMessageType.Schedule_Invite_Expired) {
//                instance.ReportEvent(mContext.getResources().getString(R.string.Live_Global_Category),
//                        mContext.getResources().getString(R.string.Live_Global_Action_ShowBookingStart),
//                        mContext.getResources().getString(R.string.Live_Global_Label_ShowBookingStart));
//            } else if(type == PushMessageType.Program_Show_Start){
//                instance.ReportEvent(mContext.getResources().getString(R.string.Live_Calendar_Category),
//                        mContext.getResources().getString(R.string.Live_Calendar_Action_showStart_notify),
//                        mContext.getResources().getString(R.string.Live_Calendar_Label_showStart_notify));
//            }
//        }
    }

    /**
     * 取消置顶类型的所有Push
     * @param type
     */
    public void Cancel(NotificationTypeEnum type) {
        LiveModule.getInstance().cancelNotification(type);
    }

    /**
     * 清除应用所有Push通知消息
     */
    public void CancelAll(){
        LiveModule.getInstance().cancelAllNotification();
    }

}
