package com.qpidnetwork.livemodule.httprequest.item;

/**
 * 发送照片权限
 * @author Alex
 *
 */
public enum SendImgRiskType {
	Normal,				//正常
	OnlyFree,			//只能发免费
	OnlyPayment,		//只能发付费
	NoSend				//不能发照片

}
