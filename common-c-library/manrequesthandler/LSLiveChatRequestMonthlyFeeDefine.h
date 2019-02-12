/*
 * LSLiveChatRequestMonthlyFeeDefine.h
 *
 *  Created on: 2016-5-10
 *      Author: Hunter
 */

#ifndef LSLIVECHATREQUESTMONTHLYFEEDEFINE_H_
#define LSLIVECHATREQUESTMONTHLYFEEDEFINE_H_

#include "LSLiveChatRequestDefine.h"

/* ########################	LoveCall 模块  ######################## */

/* 字段 */

/* 13.1.获取月费会员类型 */
#define MONTHLY_FEE_MEMBER_TYPE_PATH    "/member/member_type"

/* 返回参数定义 */
#define MONTHLY_FEE_MEMBER_TYPE          "type"
#define MONTHLY_FEE_MEMBER_MFEE_ENDDATE  "mfee_enddate"

/* 13.2.获取月费提示层数据 */
#define MONTHLY_FEE_GET_TIPS_PATH    	"/member/month_fee_tip"

/* 返回参数定义 */
#define MONTHLY_FEE_TITLE_PRICE          "title"
#define MONTHLY_FEE_TIPS_LIST         	 "item"

/* 6.2.获取买点送月费的文字说明 */
#define MONTHLY_FEE_PREMIUM_MEMBERSHIP   "/member/premium_membership"

/* 返回参数定义 */
#define MONTHLY_FEE_PREMIUM_TITLE       "title"
#define MONTHLY_FEE_PREMIUM_SUBTITLE    "subtitle"
#define MONTHLY_FEE_PREMIUM_PRODUCTS    "products"
#define MONTHLY_FEE_PREMIUM_ID          "id"
#define MONTHLY_FEE_PREMIUM_NAME        "name"
#define MONTHLY_FEE_PREMIUM_PRICE       "price"
#define MONTHLY_FEE_PREMIUM_DESC        "desc"
#define MONTHLY_FEE_PREMIUM_MORE        "more"

#endif /* LSLIVECHATREQUESTMONTHLYFEEDEFINE_H_ */
