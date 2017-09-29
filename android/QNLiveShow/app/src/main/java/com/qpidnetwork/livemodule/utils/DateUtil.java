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

    private static String FORMAT_SHOW_MONTH_DATE =  "MMM dd";
//    private static String FORMAT_SHOW_TIME_24 =  "H:mm";
    private static String FORMAT_SHOW_TIME_12 =  "h:mm aa";

    /**
     * 将时间戳转为　小时（9:00 am）
     * @param strDate
     * @return
     */
    public static String getTimeAMPM(long strDate){
        String time = "00:00";

        DateFormat dateFormat = new SimpleDateFormat(FORMAT_SHOW_TIME_12);
        try {
            Date date = new Date(strDate);
            //time
            time = dateFormat.format(date);
        } catch (Exception e) {
            e.printStackTrace();
        }

        return time;
    }

    /**
     * 将时间戳转为　日期（MM-dd）
     * @param strDate
     * @return
     */
    public static String getDate(long strDate){
        String month = "Jul";

        DateFormat dateFormat = new SimpleDateFormat(FORMAT_SHOW_MONTH_DATE);
        try {
            Date date = new Date(strDate);
            //
            month = dateFormat.format(date);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return month;
    }
}
