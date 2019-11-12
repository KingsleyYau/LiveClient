package com.qpidnetwork.livemodule.liveshow.datacache.preference;

/**
 * 本地Preference缓存key值等定义
 * Created by Hunter Mun on 2017/5/27.
 */

public class LocalPreferenceConstant {

    /*Local file name*/
    public static final String LIVE_SHOW_PREFERENCE_NAME = "live_show";

    //key
    public final static String KEY_FIRST_START = "AppFirstLaunch";
    public final static String KEY_LOGIN_ACCOUNT_INFO = "LoginAccountInFo";
    public final static String KEY_DEFAULT_COUNTRY_CODE = "DefaultCountryCode";

    //system key
    public final static String KEY_SYSTEM_STATUS_BAR_HEIGHT = "statusBarHeight";

    // SayHi 新手引导弹窗
    public final static String KEY_HAS_SHOW_SAY_HI_GUIDE_DIALOG = "hasShowSayHiGuideDialog";
    // SayHi Response 列表的点击确认弹窗
    public final static String KEY_HAS_SHOW_SAY_HI_LIST_RESPONSE_DIALOG = "hasShowSayHiListResponseDialog";
    // SayHi Response 列表的过滤条件记录
    public final static String KEY_SAY_HI_LIST_RESPONSE_FILTER_TYPE = "sayHiListResponseFilterType";
    // SayHi 用户发送成功的主题ID
    public final static String KEY_SAY_HI_THEME_SELECTED = "SayHiThemeSelectedId";
    // SayHi 用户发送成功的文字ID
    public final static String KEY_SAY_HI_NOTE_SELECTED = "SayHiNoteSelectedId";
}
