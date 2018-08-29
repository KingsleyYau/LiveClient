package com.qpidnetwork.anchor.liveshow.pushmanager;

import com.qpidnetwork.anchor.utils.Log;

import java.util.HashMap;

/**
 * Created by Hunter Mun on 2017/9/15.
 */

public class PushNotificationIdGenerator {

    private final String TAG = PushNotificationIdGenerator.class.getSimpleName();

    //主播邀请通知默认设置
    private static final int NOTIFICATION_ANCHOR_INVITE_BASE_ID = 90000;
    private static final int NOTIFICATION_ANCHOR_INVITE_MAX_COUNT = 10;

    //定时预约通知默认设置
    private static final int NOTIFICATION_SCHEDULE_INVITE_BASE_ID = 100000;
    private static final int NOTIFICATION_SCHEDULE_INVITE_MAX_COUNT = 10;

    //定时预约通知默认设置
    private static final int NOTIFICATION_HANGOUT_INVITE_BASE_ID = 110000;
    private static final int NOTIFICATION_HANGOUT_INVITE_MAX_COUNT = 10;
	
	//节目预约开播通知
    private static final int NOTIFICATION_PROGRAM_START_BASE_ID = 120000;
    private static final int NOTIFICATION_PROGRAM_START_MAX_COUNT = 10;

    //节目开播前10分钟通知
    private static final int NOTIFICATION_PROGRAM_TEN_NOTIFY_BASE_ID = 130000;
    private static final int NOTIFICATION_PROGRAM_TEN_NOTIFY_MAX_COUNT = 10;

    private HashMap<PushMessageType, Integer> mTypeCurrentIdMap;


    public PushNotificationIdGenerator(){
        mTypeCurrentIdMap = new HashMap<PushMessageType, Integer>();
    }

    /**
     * 生成系统NotificationId
     * @param type
     * @return
     */
    public int generateNotificationId(PushMessageType type){
        int currentNotificationId = 0;
        if(mTypeCurrentIdMap.containsKey(type)){
            currentNotificationId = mTypeCurrentIdMap.get(type);
        }
        switch (type){
            case Anchor_Invite_Notify:{
                currentNotificationId = NOTIFICATION_ANCHOR_INVITE_BASE_ID + ++currentNotificationId%NOTIFICATION_ANCHOR_INVITE_MAX_COUNT;
            }break;
            case Schedule_Invite_Expired:{
                currentNotificationId = NOTIFICATION_SCHEDULE_INVITE_BASE_ID + ++currentNotificationId%NOTIFICATION_SCHEDULE_INVITE_MAX_COUNT;
            }break;
            case Man_HangOut_Invite_Notify:{
                currentNotificationId = NOTIFICATION_HANGOUT_INVITE_BASE_ID + ++currentNotificationId%NOTIFICATION_HANGOUT_INVITE_MAX_COUNT;
            }break;
			case Program_Start_Notify:{
                currentNotificationId = NOTIFICATION_PROGRAM_START_BASE_ID + ++currentNotificationId%NOTIFICATION_PROGRAM_START_MAX_COUNT;
            }break;
            case Program_10_Minute_Notify:{
                currentNotificationId = NOTIFICATION_PROGRAM_TEN_NOTIFY_BASE_ID + ++currentNotificationId%NOTIFICATION_PROGRAM_TEN_NOTIFY_MAX_COUNT;
            }break;
        }
        Log.d(TAG,"generateNotificationId-type:"+type+" currentNotificationId:"+currentNotificationId);
        mTypeCurrentIdMap.put(type, currentNotificationId);
        return currentNotificationId;
    }


    public int getNotificationBaseId(PushMessageType type){
        int baseId = -1;
        switch (type){
            case Anchor_Invite_Notify:{
                baseId = NOTIFICATION_ANCHOR_INVITE_BASE_ID;
            }break;
            case Schedule_Invite_Expired:{
                baseId = NOTIFICATION_SCHEDULE_INVITE_BASE_ID;
            }break;
            case Man_HangOut_Invite_Notify:{
                baseId = NOTIFICATION_HANGOUT_INVITE_BASE_ID;
            }break;
			case Program_Start_Notify:{
                baseId = NOTIFICATION_PROGRAM_START_BASE_ID;
            }break;
            case Program_10_Minute_Notify:{
                baseId = NOTIFICATION_PROGRAM_TEN_NOTIFY_BASE_ID;
            }break;
        }
        return baseId;
    }

    public int getNotificationMaxCount(PushMessageType type){
        int maxCount = -1;
        switch (type){
            case Anchor_Invite_Notify:{
                maxCount = NOTIFICATION_ANCHOR_INVITE_MAX_COUNT;
            }break;
            case Schedule_Invite_Expired:{
                maxCount = NOTIFICATION_SCHEDULE_INVITE_MAX_COUNT;
            }break;
            case Man_HangOut_Invite_Notify:{
                maxCount = NOTIFICATION_HANGOUT_INVITE_MAX_COUNT;
            }break;
			case Program_Start_Notify:{
                maxCount = NOTIFICATION_PROGRAM_START_MAX_COUNT;
            }break;
            case Program_10_Minute_Notify:{
                maxCount = NOTIFICATION_PROGRAM_TEN_NOTIFY_MAX_COUNT;
            }break;
        }
        return maxCount;
    }

}
