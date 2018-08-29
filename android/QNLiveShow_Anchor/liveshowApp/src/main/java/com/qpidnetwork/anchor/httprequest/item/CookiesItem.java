package com.qpidnetwork.anchor.httprequest.item;
import java.io.Serializable;

/**
 * cookiesItem
 * @author alex
 *
 */
public class CookiesItem implements Serializable{

	private static final long serialVersionUID = -9192183913346483739L;
	
	/**
	 * 
	 * @param domain  cookies的域
	 * @param accessOtherWeb cookies是否接受其他web
	 * @param symbol cookies的\符号
	 * @param isSend cookies是否将要发送
	 * @param expiresTime cookies的过期时间
	 * @param cName cookies的名字
	 * @param value cookies的值
	 */
	public CookiesItem(){
		this.domain = "";
		this.accessOtherWeb = "";
		this.symbol = "";
		this.isSend = "";
		this.expiresTime = "";
		this.cName = "";
		this.value = "";
	}
	
	public void init(
			String domain,
			String accessOtherWeb,
			String symbol,
			String isSend,
			String expiresTime,
			String cName,
			String value){
		this.domain = domain;
		this.accessOtherWeb = accessOtherWeb;
		this.symbol = symbol;
		this.isSend = isSend;
		this.expiresTime = expiresTime;
		this.cName = cName;
		this.value = value;
	}

	public String domain;
	public String accessOtherWeb;
	public String symbol;
	public String isSend;
	public String expiresTime;
	public String cName;
	public String value;

}