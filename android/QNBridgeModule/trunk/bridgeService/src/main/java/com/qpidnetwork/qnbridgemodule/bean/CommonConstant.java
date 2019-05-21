package com.qpidnetwork.qnbridgemodule.bean;

/**
 * 公共常量数据
 * Created by Hunter on 17/10/24.
 */

public class CommonConstant {

    /************************************ 本地缓存prference缓存  ********************************************/
    //本地preference文件名
    public static final String LOCAL_CORE_DATACACHE_PREFERENCE_FILE = "localCahcePreferenceFile";
    //本地prefernce缓存通知设置key
    public static final String LOCAL_CORE_DATACACHE_KEY_NOTIFICATION = "NotificationSetting";
    //本地preference缓存默认站点key
    public static final String LOCAL_CORE_DATACACHE_KEY_CURRENT_SITEID = "currentSiteId";
    //本地缓存用户账号信息key
    public static final String LOCAL_CORE_DATACACHE_KEY_ACCOUNT_INFO = "accountInfo";
    //GoogleReferrer
    public static final String KEY_SP_GoogleReferrer = "KEY_SP_GoogleReferrer";
    //是否第一次注册
    public static final String KEY_INSTALL_FIRST_REGISTER_FLAGS = "firstRegister";
    //是否提交过InstallLog
    public static final String SP_KEY_INSTALL_LOGS_BEFORE_AUTH_IS_SUMMIT = "sp_key_install_log_before_auth_is_summit";
    //HangOut列表头是否可视
    public static final String SP_KEY_HANG_OUT_LIST_HEADER_IS_VISIBLE = "sp_key_hang_out_list_header_is_visible";

    /***********************************  通知广播相关  ******************************************/
    //通知广播Action
    public static final String NOTIFICATION_BROADCAST_ACTION = "action.push.notification";
    //通知广播所带参数
    public static final String NOTIFICATION_BROADCAST_PARAM_KEY = "notificationParamsKey";

    //关闭activity广播
    public static final String ACTION_ACTIVITY_CLOSE = "action.activity.close";

    //session过期广播
    public static final String ACTION_SESSION_TIMEOUT = "com.qpidnetwork.livemodule.liveshow.ACTION_SESSION_TIMEOUT";

    //QN 内部使用广播
    public static final String ACTION_QN_PHONE_NUM_VERIFY_SUCCEED = "qn.ACTION_PHONE_NUM_VERIFY_SUCCEED";

    //用户上传头像成功
    public static final String ACTION_USER_UPLOAD_PHOTO_SUCCESS = "qn.ACTION_USER_UPLOAD_PHOTO_SUCCESS";

    //APP 重启广播
    public static final String ACTION_NOTIFICATION_APP_PERMISSION_RESET = "com.qpidnetwork.action.APP_PERMISSION_RESET";

    /***********************************  通知广播相关  ******************************************/
    //push通知 targetSdkVersion 26 版本channel id
    public static final String PUSH_NOTIFICATION_CHANNEL_ID = "channel_qn";
}
