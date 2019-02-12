package com.qpidnetwork.livemodule.utils;

import android.text.TextUtils;

/**
 * Created by Hardy on 2018/11/1.
 */
public class UserInfoUtil {

    private UserInfoUtil() {

    }


    /**
     * 获取用户全名
     *
     * @param firstName
     * @param lastName
     * @return
     */
    public static String getUserFullName(String firstName, String lastName) {
        if (TextUtils.isEmpty(firstName)) {
            firstName = "";
        }
        if (TextUtils.isEmpty(lastName)) {
            lastName = "";
        }

        return firstName + " " + lastName;
    }
}
