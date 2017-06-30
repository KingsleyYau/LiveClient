package com.qpidnetwork.tool;

/**
 * @author Max.Chiu
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
