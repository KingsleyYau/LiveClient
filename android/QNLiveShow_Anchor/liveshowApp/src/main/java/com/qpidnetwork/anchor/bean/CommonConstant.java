package com.qpidnetwork.anchor.bean;
/**
 * 公共常量数据
 * Created by Hunter on 17/10/24.
 */

public class CommonConstant {

    //push 广播实现的action
    public static final String ACTION_PUSH_NOTIFICATION = "action.push.notification";
    public static final String ACTION_ANCHOR_PUSH_NOTIFICATION = "action.anchor.push.notification";

    public static final String KEY_PUSH_NOTIFICATION_URL = "url";

    //踢下线广播
    public static final String ACTION_KICKED_OFF = "com.qpidnetwork.livemodule.liveshow.ACTION_KICKED_OFF";

    //session过期广播
    public static final String ACTION_SESSION_TIMEOUT = "com.qpidnetwork.livemodule.liveshow.ACTION_SESSION_TIMEOUT";

    //服务冲突通知界面广播
    public static final String ACTION_NOTIFICATION_SERVICE_CONFLICT_ACTION = "action.service.conflict";
    public static final String ACTION_NOTIFICATION_SERVICE_CONFLICT_JUMPURL = "ServiceConflictJumpUrl";

    //QN 内部使用广播
    public static final String ACTION_QN_PHONE_NUM_VERIFY_SUCCEED = "qn.ACTION_PHONE_NUM_VERIFY_SUCCEED";

    //APP 重启广播
    public static final String ACTION_NOTIFICATION_APP_PERMISSION_RESET = "com.qpidnetwork.action.APP_PERMISSION_RESET";
}

