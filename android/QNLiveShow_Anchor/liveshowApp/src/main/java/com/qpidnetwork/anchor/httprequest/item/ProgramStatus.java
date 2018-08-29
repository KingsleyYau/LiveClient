package com.qpidnetwork.anchor.httprequest.item;

/**
 * 节目状态类型
 * @author Hunter Mun
 *
 */
public enum ProgramStatus {
	UnVerify,			// 未审核
	VerifyPass,			// 审核通过
	VerifyReject,		// 审核被拒
	ProgramEnd, 		// 节目正常结束
	ProgramCancel,		// 节目已取消
	OutTime				// 节目已超时
}
