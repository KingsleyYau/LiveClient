package com.qpidnetwork.qnbridgemodule.bean;

/**
 * 当前支持的所有通知消息类型
 */
public enum NotificationTypeEnum {
    NORMAL_NOTIFICATION,            //通用通知消息
    EMF_NOTIFICATION,               //QN EMF通知消息
    CAMSHARE_NOTIFICATION,          //QN Camshare通知消息
    KICKOFF_NOTIFICATION,           //QN 被踢通知消息
    ADVERT_NOTIFICATION,            //QN 广告通知消息
    LIVECHAT_NOTIFICATION,          //QN LiveChat通知消息
    PUSHNEWS_NOTIFICAITON,          //QN push广告通知消息
    //直播模块
    ANCHORINVITE_NOTIFICATION,      //直播主播邀请通知消息
    SCHEDULEINVITE_NOFICATION,      //直播预约邀请到期通知消息
    PROGRAMSTART_NOTIFICATION,       //直播节目开始通知消息
    LIVE_LIVECHAT_NOTIFICATION       //直播Livechat Push
}
