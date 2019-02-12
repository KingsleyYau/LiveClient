/*
 * LSLiveChatRequestLoveCallDefine.h
 *
 *  Created on: 2015-2-27
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LSLIVECHATREQUESTLOVECALLDEFINE_H_
#define LSLIVECHATREQUESTLOVECALLDEFINE_H_

#include "LSLiveChatRequestDefine.h"

/* ########################	LoveCall 模块  ######################## */

/* 字段 */

/* 11.1.获取Love Call列表接口 */
#define LOVECALL_QUERY_LIST_TYPE 		"type"
#define LOVECALL_QUERY_LIST_ORDERID		"orderid"
#define LOVECALL_QUERY_LIST_WOMANID		"womanid"
#define LOVECALL_QUERY_LIST_IMAGE		"image"
#define LOVECALL_QUERY_LIST_FIRSTNAME	"firstname"
#define LOVECALL_QUERY_LIST_COUNTRY		"country"
#define LOVECALL_QUERY_LIST_AGE			"age"
#define LOVECALL_QUERY_LIST_BEGINTIME	"begintime"
#define LOVECALL_QUERY_LIST_ENDTIME		"endtime"
#define LOVECALL_QUERY_LIST_NEEDTR		"needtr"
#define LOVECALL_QUERY_LIST_ISCONFIRM	"isconfirm"
#define LOVECALL_QUERY_LIST_CONFIRMMSG	"confirmmsg"
#define LOVECALL_QUERY_LIST_CALLID		"callid"
#define LOVECALL_QUERY_LIST_CENTERID	"centerid"

/* 11.2.确定Love Call接口  */
#define LOVECALL_CONFIRM_CONFIRMTYPE	"confirmtype"

/* 11.3.获取Love Call未处理数接口  */
#define LOVECALL_QUERY_REQUESTCOUNT_TYPE	"type"
#define LOVECALL_QUERY_REQUESTCOUNT_NUM		"num"

/* 字段  end*/

/* 接口路径定义 */

/**
 * 11.1.获取Love Call列表接口
 */
#define LOVECALL_QUERY_LIST_PATH "/member/lovecall_requestlist"

/**
 * 11.2.确定Love Call接口
 */
#define LOVECALL_CONFIRM_PATH "/member/lovecall_confirmrequest"

/**
 * 11.3.获取LoveCall未处理数
 */
#define LOVECALL_QUERY_REQUESTCOUNT_PATH "/member/lovecall_requestcount"

/* 接口路径定义  end */

#endif /* LSLIVECHATREQUESTLOVECALLDEFINE_H_ */
