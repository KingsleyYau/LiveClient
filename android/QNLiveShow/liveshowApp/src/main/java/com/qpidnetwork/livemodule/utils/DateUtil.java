package com.qpidnetwork.livemodule.utils;


import android.os.Build;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;

/**
 * 日期时间工具类
 * Created by Jagger on 2017/9/27.
 */

public class DateUtil {

    public static String FORMAT_SHOW_MONTH_DATE =  "MMM dd";
//    private static String FORMAT_SHOW_TIME_24 =  "H:mm";
    public static String FORMAT_SHOW_TIME_12 =  "h:mm aa";
    public static String FORMAT_SHOW_DATE =  "MMM dd|h:mm aa";
    public static String FORMAT_MMDDhmmaa =  "MMM dd . h:mm aa";

    /**
     * 将时间戳转为　小时（9:00 am）
     * @param dateMillis
     * @return
     */
    public static String getTimeAMPM(long dateMillis){
        return getDateStr(dateMillis , FORMAT_SHOW_TIME_12);
    }

    /**
     * 将时间戳转为　日期（MM-dd）
     * @param dateMillis
     * @return
     */
    public static String getDate(long dateMillis){
        return getDateStr(dateMillis , FORMAT_SHOW_MONTH_DATE);
    }

    /**
     * 将时间戳转为　日期（MMM dd|h:mm aa） ,为了拆分为数组
     * @param dateMillis
     * @return
     */
    public static String getDateDetail(long dateMillis){
        return getDateStr(dateMillis , FORMAT_SHOW_DATE);
    }

    /**
     * 将时间戳转为　你喜欢的格式
     * @param dateMillis 毫秒
     * @return
     */
    public static String getDateStr(long dateMillis , String format){
        String dateStr = "";

        DateFormat dateFormat = new SimpleDateFormat(format);
        try {
            Date date = new Date(dateMillis);
            //
            dateStr = dateFormat.format(date);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return dateStr;
    }
}
