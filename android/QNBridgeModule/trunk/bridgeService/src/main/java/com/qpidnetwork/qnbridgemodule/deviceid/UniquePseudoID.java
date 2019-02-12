package com.qpidnetwork.qnbridgemodule.deviceid;

import android.os.Build;

import java.util.UUID;

/**
 * Created by Hardy on 2018/10/25.
 * <p>
 * 伪唯一码
 * 无需敏感权限，系统版本 > 9，一定有值
 *
 * @link {#https://stackoverflow.com/questions/2785485/is-there-a-unique-android-device-id?page=1&tab=votes#tab-top}
 * @link {#https://blog.csdn.net/a360940265a/article/details/79907844}
 */
public class UniquePseudoID {

    /**
     * Return pseudo unique ID
     *
     * @return ID
     */
    public static String getUniquePseudoID() {
        // If all else fails, if the user does have lower than API 9 (lower
        // than Gingerbread), has reset their device or 'Secure.ANDROID_ID'
        // returns 'null', then simply the ID returned will be solely based
        // off their Android device information. This is where the collisions
        // can happen.
        // Thanks http://www.pocketmagic.net/?p=1662!
        // Try not to use DISPLAY, HOST or ID - these items could change.
        // If there are collisions, there will be overlapping data
        String m_szDevIDShort = "35" + (Build.BOARD.length() % 10) +
                (Build.BRAND.length() % 10) +
                (Build.CPU_ABI.length() % 10) +
                (Build.DEVICE.length() % 10) +
                (Build.MANUFACTURER.length() % 10) +
                (Build.MODEL.length() % 10) +
                (Build.PRODUCT.length() % 10);


        // Thanks to @Roman SL!
        // https://stackoverflow.com/a/4789483/950427
        // Only devices with API >= 9 have android.os.Build.SERIAL
        // http://developer.android.com/reference/android/os/Build.html#SERIAL
        // If a user upgrades software or roots their device, there will be a duplicate entry
        String serial = null;
        try {
//            serial = android.os.Build.class.getField("SERIAL").get(null).toString();

            // 2018/10/25 edit by Hardy
            serial = UmDeviceConfig.getSerialNo();

            // Go ahead and return the serial for api => 9
            return new UUID(m_szDevIDShort.hashCode(), serial.hashCode()).toString();

        } catch (Exception exception) {
            exception.printStackTrace();

            // String needs to be initialized
            serial = "serial"; // some value
        }

        // Thanks @Joe!
        // https://stackoverflow.com/a/2853253/950427
        // Finally, combine the values we have found by using the UUID class to create a unique identifier
        return new UUID(m_szDevIDShort.hashCode(), serial.hashCode()).toString();
    }
}
