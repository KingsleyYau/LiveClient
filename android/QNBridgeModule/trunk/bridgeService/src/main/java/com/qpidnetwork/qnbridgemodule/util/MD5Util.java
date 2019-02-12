package com.qpidnetwork.qnbridgemodule.util;

import java.security.MessageDigest;

/**
 * Created by Hardy on 2018/11/8.
 */
public class MD5Util {

    private MD5Util() {
    }


    public static String getMD5(String key) {
        MessageDigest md5 = null;

        try {
            md5 = MessageDigest.getInstance("MD5");
            char[] charArray = key.toCharArray();
            byte[] byteArray = new byte[charArray.length];
            for (int i = 0; i < charArray.length; i++) {
                byteArray[i] = (byte) charArray[i];
            }
            byte[] md5Bytes = md5.digest(byteArray);

            StringBuffer hexValue = new StringBuffer();
            for (int i = 0; i < md5Bytes.length; i++) {
                int val = ((int) md5Bytes[i]) & 0xff;
                if (val < 16) {
                    hexValue.append("0");
                }

                hexValue.append(Integer.toHexString(val));
            }

            return hexValue.toString().toLowerCase();

        } catch (Exception e) {
            e.printStackTrace();
        }

        return key;
    }
}
