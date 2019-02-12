package com.qpidnetwork.qnbridgemodule.appsflyer;

import android.content.Context;
import android.content.SharedPreferences;
import android.text.TextUtils;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Hardy on 2018/11/22.
 * AppsFlyer Sp 存储相关
 */
public class AppsFlyerSpUtil {

    // AppsFlyer 相关信息的 sp 文件名
    private static final String APPS_FLYER_INFO_FILE_NAME = "qn_apps_flyer_info_file";

    // google service 广告 id
    private static final String KEY_GAID = "gaid";

    /*  每日打开跟踪  */
    // 每日打开时间
    private static final String KEY_OPEN_TIME_STAMP = "open_timeStamp";

    // 待提交记录列表
    private static final String KEY_OPEN_TIME_STAMP_LIST_UPLOAD = "open_timeStamp_list_upload";
    /*
       待提交记录列表
       该列表是一个字符串数组
       用该特殊字符进行拼接成一个长字符串保存，或者分割成一个字符串数组读取
     */
    private static final String OPEN_TIME_STAMP_LIST_PATTEN = "QN";


    private AppsFlyerSpUtil() {

    }

    private static SharedPreferences getSp(Context context) {
        return context.getSharedPreferences(APPS_FLYER_INFO_FILE_NAME, Context.MODE_PRIVATE);
    }

    //=============     gaid    ===============================

    public static String getGaidSp(Context context) {
        return getSp(context).getString(KEY_GAID, "");
    }

    public static void saveGaidSp(Context context, String gaid) {
        getSp(context).edit().putString(KEY_GAID, gaid).commit();
    }

    //=============     gaid    ===============================


    //=============     open timeStamp   =====================================

    public static long getOpenTimeStampSp(Context context) {
        return getSp(context).getLong(KEY_OPEN_TIME_STAMP, 0);
    }

    public static void saveOpenTimeStampSp(Context context, long time) {
        getSp(context).edit().putLong(KEY_OPEN_TIME_STAMP, time).commit();
    }

    //=============     open timeStamp   =====================================


    //=============     open timeStamp list upload =====================================

    public static String getUploadTimeStampListSp(Context context) {
        return getSp(context).getString(KEY_OPEN_TIME_STAMP_LIST_UPLOAD, "");
    }

    private static void saveUploadTimeStampListSp(Context context, String uploadTimeStampList) {
        getSp(context).edit().putString(KEY_OPEN_TIME_STAMP_LIST_UPLOAD, uploadTimeStampList).commit();
    }

    /**
     * 清空待提交记录
     *
     * @param context
     */
    public static void clearUploadTimeStampList(Context context) {
        saveUploadTimeStampListSp(context, "");
    }

    /**
     * 获取待提交记录
     *
     * @param context
     * @return
     */
    public static int[] getUploadTimeStamps(Context context) {
        String val = getUploadTimeStampListSp(context);
        if (TextUtils.isEmpty(val)) {
            val = "";
        }

        String[] vals = val.split(OPEN_TIME_STAMP_LIST_PATTEN);
        int len = vals != null ? vals.length : 0;

        if (len > 0) {
            List<String> list = new ArrayList<>();

            // 过滤有效的待提交记录
            for (int i = 0; i < len; i++) {
                String timeStr = vals[i];
                if (!TextUtils.isEmpty(timeStr)) {
                    list.add(timeStr);
                }
            }

            // 保存有效的待提交记录
            int size = list.size();
            if (size > 0) {
                int[] times = new int[size];

                for (int i = 0; i < size; i++) {
                    String timeStr = list.get(i);

                    long timeL = 0;
                    try {
                        timeL = Long.parseLong(timeStr);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }

                    int timeI = (int) (timeL / 1000);
                    times[i] = timeI;
                }

                return times;
            }
        }

        return null;
    }

    /**
     * 保存待提交记录
     *
     * @param context
     * @param time
     */
    public static void saveUploadTimeStamp(Context context, long time) {
        if (time <= 0) {
            return;
        }

        String val = getUploadTimeStampListSp(context);
        if (TextUtils.isEmpty(val)) {
            val = time + OPEN_TIME_STAMP_LIST_PATTEN;
        } else {
            val = val + time + OPEN_TIME_STAMP_LIST_PATTEN;
        }

        saveUploadTimeStampListSp(context, val);
    }
    //=============     open timeStamp list upload =====================================

}
