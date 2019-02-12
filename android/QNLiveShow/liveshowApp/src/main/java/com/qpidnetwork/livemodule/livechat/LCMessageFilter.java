package com.qpidnetwork.livemodule.livechat;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 文本消息过滤器
 * @author Samson Fan
 *
 */
public class LCMessageFilter {
	private static String[] characterCheckArr = {"http://|HTTP://","https://|HTTPS://","ftp://|FTP://",
		"(\\d{3,4}+[-|\\s])*\\d{5,11}","\\d+\\.\\d+\\.\\d+\\.\\d+",
        "(\\d{1,}+[-|\\s]{1,}){3,}+(\\d{1,})*","(\\d{3,}+[\\n|\\r]{1,}){1,}+(\\d{1,})*",
		"([0-9a-zA-Z])*[0-9a-zA-Z]+@([0-9a-zA-Z]+[\\s]{0,}+[.]+[\\s]{0,})+(com|net|cn|org|ru)+[\\s]{0,}",
		"([0-9a-zA-Z]+[-._+&])*([0-9a-zA-Z]+[\\s]{0,}+[.]+[\\s]{0,})+(com|net|cn|org|ru)+[\\s]{1,}",
		" fuck ", " fucking ", " fucked ", " ass ", " asshole ", " cock ", " dick ", " suck ", " sucking ", " tit ", " tits ", " nipples ", " horn ", " horny "," pussy ", " wet pussy "," shit "," make love ", " making love "," penis "," climax "," lick "," vagina "," sex ", " oral sex ", " anal sex "};
	
	public LCMessageFilter() {
		
	}
	

	/**
	 * 过滤消息中的非法字符
	 * 
	 * @param src
	 * @return
	 */
	public static String filterMessage(String src) {
		src = " " + src + " ";
		for (int i = 0; i < characterCheckArr.length; i++) {
			src = src.replaceAll("(?i)" + characterCheckArr[i], "******");
		}
		src = src.trim();
		return src;
	}
	
	/**
	 * 判断消息内容是否合法
	 * 
	 * @param src
	 * @return
	 */
	public static boolean isIllegalMessage(String src) {
		boolean result = false;
		src = " " + src + " ";
		int arrLength = characterCheckArr.length;
		for (int i = 0; i < arrLength; i++) {
			Pattern p = Pattern.compile("(?i)" + characterCheckArr[i]);
			Matcher m = p.matcher(src);
			if (m.find()) {
				result = true;
			}
		}
		return result;
	}
}
