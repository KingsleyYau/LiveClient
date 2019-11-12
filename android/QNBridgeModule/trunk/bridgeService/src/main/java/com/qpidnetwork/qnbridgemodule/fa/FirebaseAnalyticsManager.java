package com.qpidnetwork.qnbridgemodule.fa;

import android.content.Context;
import android.os.Bundle;
import android.text.TextUtils;

import com.google.firebase.analytics.FirebaseAnalytics;
import com.qpidnetwork.qnbridgemodule.websitemanager.WebSiteConfigManager;

/**
 * Created by Hardy on 2019/6/26.
 * <p>
 * FireBase Analytics 的管理类
 */
public class FirebaseAnalyticsManager {

    private static final String CONTENT_FLAG_DIVIDER = "_";
    // 开发环境
    private static final String CONTENT_FLAG_ENV_OFFICIAL = "productionEnv";
    private static final String CONTENT_FLAG_ENV_DEMO = "demoEnv";
    // 功能模块
    private static final String CONTENT_FLAG_QN = "qpidnetworkCont";
    private static final String CONTENT_FLAG_LIVE = "liveBroadcastCont";

    // bundle key
    private static final String BUNDLE_KEY_CONTENT_FLAG = "contentFlag";
    private static final String BUNDLE_KEY_SCREEN_NAME = "screen_name";
    // event key
    private static final String EVENT_KEY_SCREENVIEW = "screenview";


    /**
     * 分析模块类型
     * —— QN
     * —— 直播
     */
    public enum AnalyticsModeType {
        QN,
        LIVE
    }

    /**
     * 开发环境类型
     * —— 正式
     * —— demo
     */
    public enum AnalyticsEnvType {
        OFFICIAL,
        DEMO
    }

    private AnalyticsModeType analyticsModeType;
    private AnalyticsEnvType analyticsEnvType;

    private FirebaseAnalytics mFirebaseAnalytics;

    public FirebaseAnalyticsManager(Context context,
                                    AnalyticsModeType analyticsModeType,
                                    AnalyticsEnvType analyticsEnvType) {
        this.analyticsModeType = analyticsModeType;
        this.analyticsEnvType = analyticsEnvType;

        init(context);
    }

    private void init(Context context) {
        mFirebaseAnalytics = FirebaseAnalytics.getInstance(context);
    }


    /**
     * 获取屏幕拼接后缀
     * e.g
     * charmdate_qpidnetworkCont_demoEnv
     *
     * @return
     */
    private String getScreenNameSuffix() {
        String env = getScreenNameEnvType();
        String mode = getScreenNameModeType();

        StringBuilder sb = new StringBuilder();

        // 站点名字，换站后会改变，这里一直取局部变量，不能存全局变量来使用
        String siteKey = "";
        if (null != WebSiteConfigManager.getInstance()
                && null != WebSiteConfigManager.getInstance().getCurrentWebSite()) {
            siteKey = WebSiteConfigManager.getInstance().getCurrentWebSite().getSiteKey();
        }
        sb.append(siteKey);

        // 模块
        sb.append(CONTENT_FLAG_DIVIDER);
        sb.append(mode);

        // 开发环境
        sb.append(CONTENT_FLAG_DIVIDER);
        sb.append(env);

        return sb.toString();
    }

    /**
     * 获取屏幕名字模块类型
     *
     * @return
     */
    private String getScreenNameModeType() {
        String screenNameType = "";

        if (analyticsModeType != null) {
            switch (analyticsModeType) {
                case QN:
                    screenNameType = CONTENT_FLAG_QN;
                    break;

                case LIVE:
                    screenNameType = CONTENT_FLAG_LIVE;
                    break;

                default:
                    break;
            }
        }

        return screenNameType;
    }

    /**
     * 获取开发环境类型
     *
     * @return
     */
    private String getScreenNameEnvType() {
        String screenNameType = "";

        if (analyticsEnvType != null) {
            switch (analyticsEnvType) {
                case OFFICIAL:
                    screenNameType = CONTENT_FLAG_ENV_OFFICIAL;
                    break;

                case DEMO:
                    screenNameType = CONTENT_FLAG_ENV_DEMO;
                    break;

                default:
                    break;
            }
        }

        return screenNameType;
    }


    //==========================    FA report 事件    ============================================

    /**
     * FA 开始 activity 统计
     */
    public void FaReportStart(String screenName) {
        Bundle params = getCommonBundle();
        params.putString(BUNDLE_KEY_SCREEN_NAME, screenName);
        mFirebaseAnalytics.logEvent(EVENT_KEY_SCREENVIEW, params);
    }

    /**
     * FA 停止 activity 统计
     */
    public void FaReportStop(String screenName) {
//        if (null != mGaAnalytics && null != mGaTracker) {
//            Log.d("AnalyticsManager", "GaReportStop() screenName:%s", screenName);
//            mGaAnalytics.dispatchLocalHits();
//        }

        // 2019/6/26 保留该方法，对应 GA ，暂无具体实现
    }

    /**
     * FA 设置活动统计
     *
     * @param gaActivity 活动统计GA值
     */
    public void FaSetActivity(String gaActivity) {
//        if (null != mGaTracker
//                && !TextUtils.isEmpty(gaActivity))
//        {
//            Log.d("AnalyticsManager", "GaSetActivity() activity:%s", gaActivity);
//            mGaTracker.send(new HitBuilders.EventBuilder().setCategory("monthGroup").setAction("GA Activity").build());
//            mGaTracker.send(new HitBuilders.EventBuilder().setCategory("monthGroup").setCustomDimension(4, gaActivity).build());
//        }

        FaReportEvent("monthGroup", "GA Activity", "");
    }

    /**
     * FA 统计 screen 路径
     *
     * @param screenPath
     */
    public void FaReportScreenPath(String screenPath) {
        FaReportEvent("APPActionEvent", "APPAction", screenPath);
    }

    /**
     * FA 设置user id
     *
     * @param gaUserId 用户的跟踪ID
     */
    public void GaSetUserId(String gaUserId) {
        if (mFirebaseAnalytics != null && !TextUtils.isEmpty(gaUserId)) {
            mFirebaseAnalytics.setUserProperty("QPID_GA_UID", gaUserId);

            FaReportEvent("userid", "User Sign In", "");
        }
    }

    /**
     * FA 注册成功
     */
    public void FaRegisterSuccess(String registerType) {
        FaReportEvent("registerCategory", "registerSuccess", registerType);
    }

    /**
     * FA 统计 event
     */
    public void FaReportEvent(String category, String action, String label) {
        if (mFirebaseAnalytics != null) {
            Bundle params = getCommonBundle();
            params.putString("Category", category);
            params.putString("Action", action);
            params.putString("Label", label);
            mFirebaseAnalytics.logEvent("eventTracking", params);
        }
    }

    /**
     * 获取通用事件 bundle
     *
     * @return
     */
    private Bundle getCommonBundle() {
        Bundle params = new Bundle();

        String screenNameSuffix = getScreenNameSuffix();
        params.putString(BUNDLE_KEY_CONTENT_FLAG, screenNameSuffix);

        return params;
    }
}
