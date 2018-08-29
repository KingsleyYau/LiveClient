package com.qpidnetwork.anchor.httprequest.item;

/**
 * 直播间类型
 * @author Hunter Mun
 *
 */
public enum AnchorKnockType {
	Unknown,				//未知
	Pending,				//待确定
	Confirmed,				//已接受
	Defined,				//已拒绝
	Missed,					//超时
}
