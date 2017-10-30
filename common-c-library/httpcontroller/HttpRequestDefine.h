/*
 * RequestDefine.h
 *
 *  Created on: 2015-2-27
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef REQUESTDEFINE_H_
#define REQUESTDEFINE_H_


/* 本地错误代码 */
#define LOCAL_ERROR_CODE_TIMEOUT			"LOCAL_ERROR_CODE_TIMEOUT"
#define LOCAL_ERROR_CODE_TIMEOUT_DESC		"Trouble connecting to the server, please try again later."
#define LOCAL_ERROR_CODE_PARSEFAIL			"LOCAL_ERROR_CODE_PARSEFAIL"
#define LOCAL_ERROR_CODE_PARSEFAIL_DESC		"Trouble connecting to the server, please try again later."
#define LOCAL_ERROR_CODE_FILEOPTFAIL		"LOCAL_ERROR_CODE_FILEOPTFAIL"
#define LOCAL_ERROR_CODE_FILEOPTFAIL_DESC	"Error encountered while writing your file storage."

/**
 * 服务器错误码
 */
/* 未登录 */
#define ERROR_CODE_MBCE0003			"0003"

/* 本地直播错误代码 */
#define LOCAL_LIVE_ERROR_CODE_SUCCESS			0
#define LOCAL_LIVE_ERROR_CODE_FAIL			    1
#define LOCAL_LIVE_ERROR_CODE_TIMEOUT			2
#define LOCAL_LIVE_ERROR_CODE_PARSEFAIL         3



/* 公共字段 */
#define COMMON_RESULT 		"result"
#define COMMON_ERRNO 		"errno"
#define COMMON_ERRMSG 		"errmsg"
#define COMMON_ERRDATA		"errdata"
#define COMMON_EXT			"ext"
#define COMMON_DATA			"data"
#define COMMON_DATA_COUNT	"dataCount"
#define COMMON_DATA_LIST	"datalist"
#define COMMON_LIST         "list"

#define COMMON_PAGE_INDEX 	"page_index"
#define COMMON_PAGE_SIZE 	"page_size"

#define	COMMON_SID			"sid"
#define	COMMON_SESSION_ID	"sessionid"
#define COMMON_VERSION_CODE	"ver"

/* for xml */
#define COMMON_ROOT			"ROOT"
#define COMMON_RESULT		"result"
#define COMMON_STATUS		"status"
#define COMMON_ERRCODE		"errcode"
#define COMMON_ERRMSG		"errmsg"
#define COMMON_INFO			"info"

#endif /* REQUESTDEFINE_H_ */
