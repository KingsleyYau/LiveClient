/*
 * LSLiveChatRequestPaidDefine.h
 *
 *  Created on: 2016-06-21
 *      Author: Samson
 */

#ifndef LSLIVECHATREQUESTPAIDDEFINE_H_
#define LSLIVECHATREQUESTPAIDDEFINE_H_


/* ########################	支付 模块  ######################## */

/* 字段 */

#define PAID_MANID 		"manid"
#define PAID_SID		"sid"
#define PAID_NUMBER     "number"
#define PAID_RECEIPT    "receipt"
#define PAID_ORDERNO    "orderno"
#define PAID_ASCODE     "code"
#define PAID_PRODUCTID  "product_id"

#define PAID_RESULT     "result"
#define PAID_CODE       "code"

/* 字段  end */

/* 接口路径定义 */

/**
 *  7.1 获取订单信息接口
 */
#define PAID_PAY_PATH       "/member/ios_pay"

/**
 *  7.2 验证订单信息接口
 */
#define PAID_CHECKPAY_PATH  "/member/ios_callback"

/* 接口路径定义  end */

#endif /* LSLIVECHATREQUESTPAIDDEFINE_H_ */
