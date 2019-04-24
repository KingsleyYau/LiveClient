/*
 * LSLiveChatRequestDefine.h
 *
 *  Created on: 2015-2-27
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LSLIVECHATREQUESTDEFINE_H_
#define LSLIVECHATREQUESTDEFINE_H_

/* 本地错误代码 */
#define LOCAL_ERROR_CODE_TIMEOUT			"LOCAL_ERROR_CODE_TIMEOUT"
#define LOCAL_ERROR_CODE_TIMEOUT_DESC		"Trouble connecting to the server. Please try again later."
#define LOCAL_ERROR_CODE_PARSEFAIL			"LOCAL_ERROR_CODE_PARSEFAIL"
#define LOCAL_ERROR_CODE_PARSEFAIL_DESC		"Trouble connecting to the server. Please try again later."
#define LOCAL_ERROR_CODE_FILEOPTFAIL		"LOCAL_ERROR_CODE_FILEOPTFAIL"
#define LOCAL_ERROR_CODE_FILEOPTFAIL_DESC	"Error encountered while writing your file storage."

/* 本地直播错误代码(整形) */
#define LOCAL_LIVE_ERROR_CODE_SUCCESS            0
#define LOCAL_LIVE_ERROR_CODE_FAIL               1
#define LOCAL_LIVE_ERROR_CODE_TIMEOUT            2

/* 公共字段 */
#define COMMON_RESULT 		"result"
#define COMMON_ERRNO 		"errno"
#define COMMON_ERRMSG 		"errmsg"
#define COMMON_ERRDATA		"errdata"
#define COMMON_EXT			"ext"
#define COMMON_DATA			"data"
#define COMMON_DATA_COUNT	"dataCount"
#define COMMON_DATA_LIST	"datalist"
#define COMMON_ERRDATA_TYPE	"type"
#define COMMON_ERRDATA_SERVERID	"serverid"

#define COMMON_PAGE_INDEX 	"pageIndex"
#define COMMON_PAGE_SIZE 	"pageSize"

#define	COMMON_SID			"sid"
#define	COMMON_SESSION_ID	"sessionid"
#define COMMON_VERSION_CODE	"versioncode"
#define COMMON_APPID        "appid"

/* for xml */
#define COMMON_ROOT			"ROOT"
#define COMMON_RESULT		"result"
#define COMMON_STATUS		"status"
#define COMMON_ERRCODE		"errcode"
#define COMMON_ERRMSG		"errmsg"

#endif /* LSLIVECHATREQUESTDEFINE_H_ */
