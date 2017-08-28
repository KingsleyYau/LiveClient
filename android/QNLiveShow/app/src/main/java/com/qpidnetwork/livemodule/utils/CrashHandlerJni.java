package com.qpidnetwork.livemodule.utils;

/**
 * 底层Crash dump
 * Created by Hunter Mun on 2017/5/26.
 */

public class CrashHandlerJni {
    static {
        try {
            System.loadLibrary("crashhandler");
            System.loadLibrary("crashhandler-interface");
        } catch(Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 设置错误日志目录
     * @param directory		错误日志目录
     */
    static public native void SetCrashLogDirectory(String directory);
}
