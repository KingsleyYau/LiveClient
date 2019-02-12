package com.qpidnetwork.qnbridgemodule.util;

import android.util.Base64;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by zy2 on 2018/11/29.
 * <p>
 * Demo 环境下，打开图片、视频链接等资源，需要添加 http 指定头
 */
public class Authorization5179Util {

    private Authorization5179Util() {

    }

    public static String getDemoAuthorizationHeaderKey() {
        return "Authorization";
    }

    public static String getDemoAuthorizationHeaderValue() {
        String basicAuth = "Basic " + new String(Base64.encode("test:5179".getBytes(), Base64.NO_WRAP));
        return basicAuth;
    }

    public static Map<String, String> getDemoAuthorizationHeaderMap() {
        Map<String, String> map = new HashMap<>();
        map.put(getDemoAuthorizationHeaderKey(), getDemoAuthorizationHeaderValue());
        return map;
    }
}
