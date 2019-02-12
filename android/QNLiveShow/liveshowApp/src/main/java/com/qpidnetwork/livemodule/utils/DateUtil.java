package com.qpidnetwork.livemodule.utils;


import android.os.Build;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.Locale;

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
    public static String FORMAT_MM_DDhmm_24 =  "MM-dd H:mm";
    public static String FORMAT_MMMDDhmm_24 =  "MMM dd, H:mm";

    public enum DateTimeType{
        Default,                //默认
        Today,                  //今天
        Yestoday,               //昨天
        InWeek,                 //一周以内（排除今天，昨天）
        WeekBefore              //一周以前
    }

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

        DateFormat dateFormat = new SimpleDateFormat(format , Locale.ENGLISH);
        try {
            Date date = new Date(dateMillis);
            //
            dateStr = dateFormat.format(date);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return dateStr;
    }

    /**
     * 获取指定时间所处于的时间段，具体参考enum DateTimeType分段描述
     * @param time
     * @return
     */
    public static DateTimeType getDateTimeType(long time){
        DateTimeType timeType = DateTimeType.Default;
        //现在时间
        long now = new Date().getTime();
        long day=(60*60*24)*1000;
        //时间点比当天零点早
        if (time <= now) {
            Date date = new Date(time);
            if (time < getTimesmorning()) {
                if (time >= getTimesmorning() - day) {
                    //比昨天零点晚
                    timeType = DateTimeType.Yestoday;
                } else {//比昨天零点早
                    if (time >= getTimesmorning() - 6 * day) {
                        //比七天前的零点晚，距离当前一周内
                        timeType = DateTimeType.InWeek;
                    } else {
                        //距离今天一周以前
                        timeType = DateTimeType.WeekBefore;
                    }
                }

            } else {
                //当天时间
                timeType = DateTimeType.Today;
            }

        }
        return timeType;
    }

    /**
     * 获取当天零点unix时间戳
     * @return
     */
    private static long getTimesmorning(){
        Calendar cal = Calendar.getInstance();
        cal.set(Calendar.HOUR_OF_DAY, 0);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.MILLISECOND, 0);
        return cal.getTimeInMillis();
    }

    /**
     * 获取分秒的时间显示
     *
     * @param t单位为妙
     * @return
     */
    public static String getTime(long t) {
        String time;
        long m = t / 60;
        long s = t % 60;
        if (m < 10) {
            time = "0" + m + ":";
        } else {
            time = m + ":";
        }
        if (s < 10) {
            time = time + "0" + s;
        } else {
            time = time + s;
        }
        return time;
    }
}
