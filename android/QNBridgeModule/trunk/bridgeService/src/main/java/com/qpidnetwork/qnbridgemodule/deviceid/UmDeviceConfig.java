package com.qpidnetwork.qnbridgemodule.deviceid;

import android.Manifest;
import android.annotation.SuppressLint;
import android.content.Context;
import android.content.pm.PackageManager;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.os.Build.VERSION;
import android.provider.Settings.Secure;
import android.telephony.TelephonyManager;
import android.text.TextUtils;

import java.io.BufferedReader;
import java.io.FileReader;
import java.lang.reflect.Method;
import java.net.NetworkInterface;
import java.util.Enumeration;
import java.util.Locale;


/**
 * 摘自：友盟应用统计 SDK <umeng-common-1.5.4.jar>
 *
 * @link {#https://developer.umeng.com/sdk/android}
 *
 * <p>
 * Created by Hardy on 2018/10/25.
 * <p>
 * getIMEI() 方法需要该权限，需要用户授权获取
 * <uses-permission android:name="android.permission.READ_PHONE_STATE" />
 * <p>
 * <p>
 * getMacBySystemInterface() 方法需要该权限，看需要，可不配置
 * <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
 */
public class UmDeviceConfig {

    private static final String LOG_TAG = UmDeviceConfig.class.getName();

    public static String getDeviceId(Context var0) {
//        return getDeviceIdForGeneral(var0);
        return getDeviceIdForGeneralNew(var0);
    }

    /**
     * test
     * 获取所有的信息，仅仅做测试用
     * {@link #getDeviceIdForGeneral(Context var0)}
     *
     * @param var0
     * @return
     */
    public static String getDeviceInfoTest(Context var0) {
        StringBuilder sb = new StringBuilder();
        String temp = "";

        if (var0 == null) {
            return temp;
        }

        sb.append("Os Version: " + VERSION.SDK_INT);
        sb.append("\n");
        sb.append("device id: " + getDeviceIdForGeneral(var0));
        sb.append("\n");
        sb.append("\n");
        sb.append("==========================");
        sb.append("\n");

        sb.append("imei: " + getIMEI(var0));
        sb.append("\n");
        sb.append("mac ByJavaAPI: " + getMacByJavaAPI());
        sb.append("\n");
        sb.append("mac ByShell: " + getMacShell());
        sb.append("\n");
        sb.append("mac BySystemInterface: " + getMacBySystemInterface(var0));
        sb.append("\n");
        sb.append("android_id: " + getAndroidID(var0));
        sb.append("\n");
        sb.append("SerialNo: " + getSerialNo());
        sb.append("\n");

        return sb.toString();
    }

    private static String getAndroidID(Context var0) {
        return var0 == null ? "" : Secure.getString(var0.getContentResolver(), Secure.ANDROID_ID);
    }

    /**
     * @Samson
     * 获取本地设备 id 算法的修改，去除系统版本的判断，按照以下顺序获取，为了避免用户升级系统导致的数据不准确。
     * 	1) 获取 imei
     * 	2) 获取 SerialNo
     * 	3) 获取 android_id
     * 	4) 本地算法生成（uuid + 设备信息，保存本地）
     * @param var0 context
     * @return
     */
    private static String getDeviceIdForGeneralNew(Context var0){
        String var1 = "";
        if (var0 == null) {
            return var1;
        } else {
            var1 = getIMEI(var0);

            if (TextUtils.isEmpty(var1)) {
                var1 = getSerialNo();

                if (TextUtils.isEmpty(var1)) {
                    var1 = getAndroidID(var0);
                }
            }
        }

        return var1;
    }


    private static String getDeviceIdForGeneral(Context var0) {
        String var1 = "";
        if (var0 == null) {
            return var1;
        } else {
            if (VERSION.SDK_INT < 23) {
                var1 = getIMEI(var0);

                if (TextUtils.isEmpty(var1)) {
//                    if (AnalyticsConstants.UM_DEBUG) {
//                    MLog.w(LOG_TAG, new Object[]{"No IMEI."});
//                    }

//                    var1 = getMacBySystemInterface(var0);

                    if (TextUtils.isEmpty(var1)) {
//                        var1 = Secure.getString(var0.getContentResolver(), "android_id");
                        var1 = getAndroidID(var0);
//                        if (AnalyticsConstants.UM_DEBUG) {
//                        MLog.i(LOG_TAG, new Object[]{"getDeviceId, ANDROID_ID: " + var1});
//                        }

                        if (TextUtils.isEmpty(var1)) {
                            var1 = getSerialNo();
                        }
                    }
                }
            } else if (VERSION.SDK_INT == 23) {
                var1 = getIMEI(var0);

                if (TextUtils.isEmpty(var1)) {
//                    var1 = getMacByJavaAPI();
//                    if (TextUtils.isEmpty(var1)) {
////                        if (AnalyticsConstants.CHECK_DEVICE) {
////                            var1 = getMacShell();
////                        } else {
////                            var1 = getMacBySystemInterface(var0);
////                        }
//                        var1 = getMacShell();
//                    }

//                    if (AnalyticsConstants.UM_DEBUG) {
//                    MLog.i(LOG_TAG, new Object[]{"getDeviceId, MAC: " + var1});
//                    }

                    if (TextUtils.isEmpty(var1)) {
//                        var1 = Secure.getString(var0.getContentResolver(), Secure.ANDROID_ID);
                        var1 = getAndroidID(var0);
//                        if (AnalyticsConstants.UM_DEBUG) {
//                        MLog.i(LOG_TAG, new Object[]{"getDeviceId, ANDROID_ID: " + var1});
//                        }

                        if (TextUtils.isEmpty(var1)) {
                            var1 = getSerialNo();
                        }
                    }
                }
            } else {
                var1 = getIMEI(var0);
                if (TextUtils.isEmpty(var1)) {
                    var1 = getSerialNo();
                    if (TextUtils.isEmpty(var1)) {
//                        var1 = Secure.getString(var0.getContentResolver(), Secure.ANDROID_ID);
                        var1 = getAndroidID(var0);
//                        if (AnalyticsConstants.UM_DEBUG) {
//                        MLog.i(LOG_TAG, new Object[]{"getDeviceId, ANDROID_ID: " + var1});
//                        }

//                        if (TextUtils.isEmpty(var1)) {
//                            var1 = getMacByJavaAPI();
//                            if (TextUtils.isEmpty(var1)) {
//                                var1 = getMacBySystemInterface(var0);
////                                if (AnalyticsConstants.UM_DEBUG) {
////                                MLog.i(LOG_TAG, new Object[]{"getDeviceId, MAC: " + var1});
////                                }
//                            }
//                        }
                    }
                }
            }

            return var1;
        }
    }


    /**
     * <uses-permission android:name="android.permission.READ_PHONE_STATE"
     *
     * @param var0
     * @return
     */
    @SuppressLint("MissingPermission")
    private static String getIMEI(Context var0) {
        String var1 = "";
        if (var0 == null) {
            return var1;
        } else {
//            TelephonyManager var2 = (TelephonyManager) var0.getSystemService("phone");
            TelephonyManager var2 = (TelephonyManager) var0.getSystemService(Context.TELEPHONY_SERVICE);
            if (var2 != null) {
                try {
//                    if (checkPermission(var0, "android.permission.READ_PHONE_STATE")) {
                    if (checkPermission(var0, Manifest.permission.READ_PHONE_STATE)) {
                        var1 = var2.getDeviceId();
//                        if (AnalyticsConstants.UM_DEBUG) {
//                        MLog.i(LOG_TAG, new Object[]{"getDeviceId, IMEI: " + var1});
//                        }
                    }
                } catch (Throwable var4) {
//                    if (AnalyticsConstants.UM_DEBUG) {
//                    MLog.w(LOG_TAG, "No IMEI.", var4);
//                    }
                    var4.printStackTrace();
                }
            }

            return var1;
        }
    }

    public static boolean checkPermission(Context var0, String var1) {
        boolean var2 = false;
        if (var0 == null) {
            return var2;
        } else {
            if (VERSION.SDK_INT >= 23) {
                try {
                    Class var3 = Class.forName("android.content.Context");
                    Method var4 = var3.getMethod("checkSelfPermission", String.class);
                    int var5 = (Integer) var4.invoke(var0, var1);
                    if (var5 == 0) {
                        var2 = true;
                    } else {
                        var2 = false;
                    }
                } catch (Throwable var6) {
                    var6.printStackTrace();

                    var2 = false;
                }
            } else {
                PackageManager var7 = var0.getPackageManager();
                if (var7.checkPermission(var1, var0.getPackageName()) == PackageManager.PERMISSION_GRANTED) {
                    var2 = true;
                }
            }

            return var2;
        }
    }

    /**
     * <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
     *
     * @param var0
     * @return
     */
    private static String getMacBySystemInterface(Context var0) {
        if (var0 == null) {
            return "";
        } else {
            try {
                WifiManager var1 = (WifiManager) var0.getSystemService(Context.WIFI_SERVICE);
//                if (checkPermission(var0, "android.permission.ACCESS_WIFI_STATE")) {
                if (checkPermission(var0, Manifest.permission.ACCESS_WIFI_STATE)) {
                    if (var1 != null) {
                        @SuppressLint("MissingPermission")
                        WifiInfo var2 = var1.getConnectionInfo();
                        return var2.getMacAddress();
                    } else {
                        return "";
                    }
                } else {
//                    if (AnalyticsConstants.UM_DEBUG) {
//                    MLog.w(LOG_TAG, new Object[]{"Could not get mac address.[no permission android.permission.ACCESS_WIFI_STATE"});
//                    }

                    return "";
                }
            } catch (Throwable var3) {
//                if (AnalyticsConstants.UM_DEBUG) {
//                MLog.w(LOG_TAG, new Object[]{"Could not get mac address." + var3.toString()});
//                }
                var3.printStackTrace();

                return "";
            }
        }
    }

    private static String getMacByJavaAPI() {
        try {
            Enumeration var0 = NetworkInterface.getNetworkInterfaces();

            NetworkInterface var1;
            do {
                if (!var0.hasMoreElements()) {
                    return null;
                }

                var1 = (NetworkInterface) var0.nextElement();
            } while (!"wlan0".equals(var1.getName()) && !"eth0".equals(var1.getName()));

            byte[] var2 = var1.getHardwareAddress();
            if (var2 != null && var2.length != 0) {
                StringBuilder var3 = new StringBuilder();
                byte[] var4 = var2;
                int var5 = var2.length;

                for (int var6 = 0; var6 < var5; ++var6) {
                    byte var7 = var4[var6];
                    var3.append(String.format("%02X:", var7));
                }

                if (var3.length() > 0) {
                    var3.deleteCharAt(var3.length() - 1);
                }

                return var3.toString().toLowerCase(Locale.getDefault());
            } else {
                return null;
            }
        } catch (Throwable var8) {
            var8.printStackTrace();

            return null;
        }
    }

    private static String getMacShell() {
        try {
            String[] var0 = new String[]{"/sys/class/net/wlan0/address", "/sys/class/net/eth0/address", "/sys/devices/virtual/net/wlan0/address"};

            for (int var2 = 0; var2 < var0.length; ++var2) {
                try {
                    String var1 = reaMac(var0[var2]);
                    if (var1 != null) {
                        return var1;
                    }
                } catch (Throwable var4) {
                    var4.printStackTrace();

//                    if (AnalyticsConstants.UM_DEBUG) {
//                    MLog.e(LOG_TAG, "open file  Failed", var4);
//                    }
                }
            }
        } catch (Throwable var5) {
            var5.printStackTrace();
        }

        return null;
    }

    private static String reaMac(String var0) {
        String var1 = null;

        try {
            FileReader var2 = new FileReader(var0);
            BufferedReader var3 = null;
            if (var2 != null) {
                try {
                    var3 = new BufferedReader(var2, 1024);
                    var1 = var3.readLine();
                } finally {
                    if (var2 != null) {
                        try {
                            var2.close();
                        } catch (Throwable var14) {
                            var14.printStackTrace();
                        }
                    }

                    if (var3 != null) {
                        try {
                            var3.close();
                        } catch (Throwable var13) {
                            var13.printStackTrace();
                        }
                    }

                }
            }
        } catch (Throwable var16) {
            var16.printStackTrace();
        }

        return var1;
    }

    public static String getSerialNo() {
        String var0 = "";
        if (VERSION.SDK_INT >= 9) {
            if (VERSION.SDK_INT >= 26) {
                try {
                    Class var1 = Class.forName("android.os.Build");
                    Method var2 = var1.getMethod("getSerial");
                    var0 = (String) var2.invoke(var1);
                } catch (Throwable var3) {
                    var3.printStackTrace();
                }
            } else {
                var0 = Build.SERIAL;
            }
        }

//        if (AnalyticsConstants.UM_DEBUG) {
//        MLog.i(LOG_TAG, new Object[]{"getDeviceId, serial no: " + var0});
//        }

        return var0;
    }
}
