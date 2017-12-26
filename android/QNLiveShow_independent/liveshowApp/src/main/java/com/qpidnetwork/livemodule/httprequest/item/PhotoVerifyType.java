package com.qpidnetwork.livemodule.httprequest.item;

/**
 * 头像审核状态
 * @author Hunter Mun
 *
 */
public enum PhotoVerifyType {
	nophotoandfinish,			// 没有头像及审核成功
	handleing,	    // 审核中
	nopass,			// 不合格

}
