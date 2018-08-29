package com.qpidnetwork.livemodule.httprequest.item;

/**
 * 邀请状态类型
 * @author Hunter Mun
 *
 */
public enum HangoutInviteStatus {
	Unknown,				//	未知
	Penging,				//	待确定
	Accept,					//	已接受
	Reject,					//	已拒绝
	OutTime,				//	已超时
	Cancle,					// 观众取消邀
	NoCredit,				// 余额不足
	Busy					// 主播繁忙
}
