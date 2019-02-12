package com.qpidnetwork.qnbridgemodule.appsflyer;

import com.qpidnetwork.qnbridgemodule.util.Log;

import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * Created by Hardy on 2018/11/22.
 * <p>
 * 时间戳工具类
 */
public class AppsFlyerTimeStampUtil {

    private static final String TAG = "info";

    private static final String UTC_TIME_STRING = "yyyy-MM-dd HH:mm:ss";
    private static final String DATE_TIME_STRING = "yyyy-MM-dd";

    // test 测试每分钟都提交
//    private static final String DATE_TIME_STRING = "yyyy-MM-dd HH:mm";

    private AppsFlyerTimeStampUtil() {

    }


    private static String formatTimeString(Date date, String patten) {
        String str = "";
        try {
            SimpleDateFormat dateFormat = new SimpleDateFormat(patten);
            str = dateFormat.format(date);
        } catch (Exception e) {
            e.printStackTrace();
        }

        return str;
    }

    /**
     * 转换成 utc 时间戳
     * e.g:
     * 2018-11-16 23:59:59
     *
     * @param time 时间戳
     * @return
     */
    public static String formatTime2UTCString(long time) {
        Log.i(TAG, "-----------   formatTime2UTCString    ------------------------ : " + time);
        return formatTimeString(new Date(time), UTC_TIME_STRING);
    }

    public static String formatTime2DateString(Date time) {
        Log.i(TAG, "-----------   formatTime2DateString    ------------------------ : " + time);
        return formatTimeString(time, DATE_TIME_STRING);
    }

    /**
     * 是否超过 1 天
     * e.g:
     * 上次时间：2018-11-16 23:59:59
     * 当前时间：2018-11-17 00:00:00
     * 符合相差 >= 1 天条件
     *
     * @param lastTime 13 位
     * @param nowTime  13 位
     * @return
     */
    public static boolean isOverOneDay(long lastTime, long nowTime) {
        boolean isOver = false;

        // 1、判断当前时间是否在上个日期的后面
        if (nowTime <= lastTime) {
            return isOver;
        }

        // 上次日期
        Date lastDate = new Date(lastTime);
        // 当前日期
        Date nowDate = new Date(nowTime);

        // 2、2个时间日期不相等
        String lastDateStr = formatTime2DateString(lastDate);
        String nowDateStr = formatTime2DateString(nowDate);
        boolean isEqual = nowDateStr.equals(lastDateStr);

        Log.i(TAG, "isOverOneDay---------> lastDateStr: " + lastDateStr +
                "--- nowDateStr: " + nowDateStr + "--- isEqual: " + isEqual);

        if (!isEqual) {
            isOver = true;
        }

        return isOver;
    }
}
