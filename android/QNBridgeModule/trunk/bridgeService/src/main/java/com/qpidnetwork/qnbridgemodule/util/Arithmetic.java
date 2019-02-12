package com.qpidnetwork.qnbridgemodule.util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class Arithmetic {
	/**
	 * 转化方式二 将数据转化为16进制进行保存，因为有些byte是不能打印的字符 单字节转化
	 * 
	 * @param b
	 * @return String
	 */
	public static String ByteToHexString(byte b) {
		int n = b;
		if (0 > n) {
			n = 256 + n;
		}
		int d1 = n / HEX_NUM;
		int d2 = n % HEX_NUM;
		return HEX_DIGITS[d1] + HEX_DIGITS[d2];
	}

	/** 十六进制 */
	private static final int HEX_NUM = 16;

	/** 十六进制码 */
	private static final String[] HEX_DIGITS = { "0", "1", "2", "3", "4", "5",
			"6", "7", "8", "9", "a", "b", "c", "d", "e", "f" };
	
	/**
	 * 转化方式二 将数据转化为16进制进行保存
	 * @param b
	 * @return
	 */
	public static String ByteArrayToHexString(byte[] b) {
		StringBuffer result = new StringBuffer(128);
		for (int i = 0; i < b.length; i++) {
			result.append(ByteToHexString(b[i]));
		}
		return result.toString();
	}
	
	/**
	 * 获取字节流MD5
	 * @param bytes
	 * @param length
	 * @return
	 */
	public static String MD5(byte[] bytes, int length) {
		String result = "";
		MessageDigest md5;
		try {
			md5 = MessageDigest.getInstance("MD5");
			md5.update(bytes, 0, length);
			result = ByteArrayToHexString(md5.digest());
		} catch (NoSuchAlgorithmException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		return result;
	}
}
