/*
 * LSLiveChatRequestQuickMatchDefine.h
 *
 *  Created on: 2015-2-27
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LSLIVECHATREQUESTQUICKMATCHDEFINE_H_
#define LSLIVECHATREQUESTQUICKMATCHDEFINE_H_

#include "LSLiveChatRequestDefine.h"

/* ########################	QuickMatch 模块  ######################## */

/* 字段 */

/* 10.1.查询女士图片列表 */
#define QUICKMATCH_QUERY_WOMANID		"womanid"
#define QUICKMATCH_QUERY_IMAGE			"image"
#define QUICKMATCH_QUERY_FIRSTNAME		"firstname"
#define QUICKMATCH_QUERY_COUNTRY		"country"
#define QUICKMATCH_QUERY_AGE			"age"
#define QUICKMATCH_QUERY_DEVICEID 		"deviceId"

/* 10.2.提交已标记的女士  */
#define QUICKMATCH_UPLOAD_CONFIRMTYPE	"likewomanid"
#define QUICKMATCH_UPLOAD_CONFIRMTYPE	"likewomanid"

#define QUICKMATCH_QUERY_PHOTOURL		"photoURL"

/* 字段  end*/

/* 接口路径定义 */

/**
 * 10.1.查询女士图片列表
 */
#define QUICKMATCH_LIST_PATH "/member/quickmatch_ladylist"

/**
 * 10.2.提交已标记的女士
 */
#define QUICKMATCH_UPLOAD_PATH "/member/quickmatch_uploadlady"

/**
 * 10.3.查询已标记like的女士列表
 */
#define QUICKMATCH_LIKE_LIST_PATH "/member/quickmatch_likedlist"

/**
 * 10.4.删除已标记like的女士
 */
#define QUICKMATCH_REMOVE_PATH "/member/quickmatch_removeliked"

/* 接口路径定义  end */

#endif /* LSLIVECHATREQUESTQUICKMATCHDEFINE_H_ */
