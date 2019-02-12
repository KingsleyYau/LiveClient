package com.qpidnetwork.livemodule.utils;

import java.io.FileInputStream;
import java.io.InputStream;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class ByteUtil {

	public static byte[] int2Bytes(int x) {
		byte[] buff = new byte[4];
		buff[0] = (byte) (x >> 24);
		buff[1] = (byte) (x >> 16);
		buff[2] = (byte) (x >> 8);
		buff[3] = (byte) x;
		return buff;
	}

	public static int bytes2Int(byte[] buff) {
		//return (buff[0] << 24) + (buff[1] << 16) + (buff[2] << 8) + buff[3];		//错误，如果是负数时不对
		int mask = 0xff;
		int temp = 0;
		int n = 0;
		for (int i = 0; i < 4; i++) {
			n <<= 8;
			temp = buff[i] & mask;
			n |= temp;
		}
		return n;
	}

	public static int bytes2Int(byte[] buff, int srcPos) {
		//return (buff[srcPos] << 24) + (buff[srcPos + 1] << 16) + (buff[srcPos + 2] << 8) + buff[srcPos + 3];		//错误，如果是负数时不对
		int mask = 0xff;
		int temp = 0;
		int n = 0;
		for (int i = 0; i < 4; i++) {
			n <<= 8;
			temp = buff[srcPos + i] & mask;
			n |= temp;
		}
		return n;
	}

	public static void putInt(byte[] buff, int x, int desPos) {
		buff[desPos] = (byte) (x >> 24);
		buff[desPos + 1] = (byte) (x >> 16);
		buff[desPos + 2] = (byte) (x >> 8);
		buff[desPos + 3] = (byte) (x);
	}
	
	/**
	 * MD5结果
	 * 
	 * @param src
	 * @return
	 */
	public static String getMd5Result(String src) {
		MessageDigest md = null;
		try {
			md = MessageDigest.getInstance("MD5");
		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace();
		}
		md.update(src.getBytes());
		// 因为md.digest()后的字节数组没法转成字符串显示（乱码），故用十六进制显示
		String result = byteArrayToHexString(md.digest());
		return result;
	}
	
	/**
	 * 对指定文件MD5校验文件完整性
	 * @param filename
	 * @return
	 */
	public static String getFileMd5Result(String filename) {
        InputStream fis;
        byte[] buffer = new byte[1024];
        int numRead = 0;
        MessageDigest md5;
        try{
            fis = new FileInputStream(filename);
            md5 = MessageDigest.getInstance("MD5");
            while((numRead=fis.read(buffer)) > 0) {
                md5.update(buffer,0,numRead);
            }
            fis.close();
            return byteArrayToHexString(md5.digest());   
        } catch (Exception e) {
            System.out.println("error");
            return null;
        }
    }

	/**
	 * 转成16进制字符串
	 * 
	 * @param b
	 * @return
	 */
	public static String byteArrayToHexString(byte[] b) {
		StringBuffer result = new StringBuffer(128);
		for (int i = 0; i < b.length; i++) {
			result.append(byteToHexString(b[i]));
		}
		return result.toString();
	}

	/**
	 * 转化方式二 将数据转化为16进制进行保存，因为有些byte是不能打印的字符 单字节转化
	 * 
	 * @param b
	 * @return [参数说明]
	 * 
	 * @return String [返回类型说明]
	 * @exception throws [违例类型] [违例说明]
	 * @see [类、类#方法、类#成员]
	 */
	public static String byteToHexString(byte b) {
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
	 * Html标记转化为普通文本标记
	 * @param str
	 * @return
	 */
	public static String HtmlTagToTextTag(String str){
		return str.replaceAll("<br/>", "\r");
	}
	
}
