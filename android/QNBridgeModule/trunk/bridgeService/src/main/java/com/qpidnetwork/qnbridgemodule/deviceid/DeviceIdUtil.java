package com.qpidnetwork.qnbridgemodule.deviceid;

import android.content.Context;
import android.content.SharedPreferences;
import android.text.TextUtils;
import android.util.Log;

import com.qpidnetwork.qnbridgemodule.util.MD5Util;

/**
 * Created by Hardy on 2018/10/25.
 * <p>
 * 获取设备唯一 id 的工具类
 * 思路：由于接口频繁获取，故优先存在一个全局变量，不用频繁去读取 Sp (解析 XMl 文件)或者读取设备 id
 * 1、全局变量，不存在，则往下获取
 * 2、Sp 存储，不存在，则往下获取
 * 3、UmDeviceConfig.getDeviceId(Context var0)，不存在，则往下获取。存 Sp
 * 4、UniquePseudoID.getUniquePseudoID()，一定有值。存 Sp
 */
public class DeviceIdUtil {

    private static final String PREFS_FILE = "bridge_device_id_file";
    private static final String PREFS_DEVICE_ID = "device_id";

    private static String deviceId;

    private DeviceIdUtil() {

    }

    private static String getDeviceIdSp(Context context) {
        SharedPreferences prefs = context.getSharedPreferences(PREFS_FILE, Context.MODE_PRIVATE);
        String id = prefs.getString(PREFS_DEVICE_ID, "");
        return id;
    }

    private static void saveDeviceIdSp(Context context, String deviceId) {
        SharedPreferences prefs = context.getSharedPreferences(PREFS_FILE, Context.MODE_PRIVATE);
        prefs.edit().putString(PREFS_DEVICE_ID, deviceId).commit();
    }

    public static String getDeviceId(Context context) {
        if (context == null) {
            return "";
        }

        if (TextUtils.isEmpty(deviceId)) {

            synchronized (DeviceIdUtil.class) {

                boolean isChange = false;

                if (TextUtils.isEmpty(deviceId)) {
                    deviceId = getDeviceIdSp(context);

                    if (TextUtils.isEmpty(deviceId)) {
                        isChange = true;

                        deviceId = UmDeviceConfig.getDeviceId(context);

                        if (TextUtils.isEmpty(deviceId)) {
                            deviceId = UniquePseudoID.getUniquePseudoID();
                        }
                    }
                }

                if (isChange) {
                    Log.i("info", "deviceId: " + deviceId);
                    deviceId = MD5Util.getMD5(deviceId);
                    Log.i("info", "deviceId md5: " + deviceId);

                    saveDeviceIdSp(context, deviceId);
                }
            }
        }

        return deviceId;
    }
}
