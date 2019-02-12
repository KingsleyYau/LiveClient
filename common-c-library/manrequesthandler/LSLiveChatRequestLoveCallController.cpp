/*
 * LSLiveChatRequestLoveCallController.cpp
 *
 *  Created on: 2015-2-27
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#include "LSLiveChatRequestLoveCallController.h"

LSLiveChatRequestLoveCallController::LSLiveChatRequestLoveCallController(LSLiveChatHttpRequestManager *phttprequestManager, LSLiveChatRequestLoveCallControllerCallback callback/* CallbackManager* pCallbackManager*/) {
	// TODO Auto-generated constructor stub
	SetHttpRequestManager(phttprequestManager);
	mLSLiveChatRequestLoveCallControllerCallback = callback;
}

LSLiveChatRequestLoveCallController::~LSLiveChatRequestLoveCallController() {
	// TODO Auto-generated destructor stub
}

/* IhttprequestManagerCallback */
void LSLiveChatRequestLoveCallController::onSuccess(long requestId, string url, const char* buf, int size) {
	FileLog("httprequest", "LSLiveChatRequestLoveCallController::onSuccess( url : %s, buf( size : %d ) )", url.c_str(), size);
	if (size < MAX_LOG_BUFFER) {
		FileLog("httprequest", "LSLiveChatRequestLoveCallController::onSuccess(), buf: %s", buf);
	}

	/* parse base result */
	string errnum = "";
	string errmsg = "";
	int memberType = 0;
	Json::Value data;
	Json::Value errDataJson;

	bool bFlag = HandleResult(buf, size, errnum, errmsg, &data, &errDataJson);

	/* resopned parse ok, callback success */
	if( url.compare(LOVECALL_QUERY_LIST_PATH) == 0 ) {
		/* 11.1.获取Love Call列表接口  */
		list<LSLCLoveCall> itemList;
		int totalCount = 0;
		if( data[COMMON_DATA_COUNT].isInt() ) {
			totalCount = data[COMMON_DATA_COUNT].asInt();
		}
		if( data[COMMON_DATA_LIST].isArray() ) {
			for(int i = 0; i < data[COMMON_DATA_LIST].size(); i++ ) {
				LSLCLoveCall item;
				item.Parse(data[COMMON_DATA_LIST].get(i, Json::Value::null));
				itemList.push_back(item);
			}
		} else {
			// parsing fail
			bFlag = false;
			errnum = LOCAL_ERROR_CODE_PARSEFAIL;
			errmsg = LOCAL_ERROR_CODE_PARSEFAIL_DESC;
		}

		if( mLSLiveChatRequestLoveCallControllerCallback.onQueryLoveCallList != NULL ) {
			mLSLiveChatRequestLoveCallControllerCallback.onQueryLoveCallList(requestId, bFlag, itemList,
					totalCount, errnum, errmsg);
		}
	} else if( url.compare(LOVECALL_CONFIRM_PATH) == 0 ) {
		/* 11.2.确定Love Call接口 */
		if(!bFlag){
			if (errDataJson.isObject()) {
				if(errDataJson[COMMON_ERRDATA_TYPE].isInt()){
					memberType = errDataJson[COMMON_ERRDATA_TYPE].asInt();
				}
			}
		}
		if( mLSLiveChatRequestLoveCallControllerCallback.onConfirmLoveCall != NULL ) {
			mLSLiveChatRequestLoveCallControllerCallback.onConfirmLoveCall(requestId, bFlag, errnum, errmsg, memberType);
		}
	} else if ( url.compare(LOVECALL_QUERY_REQUESTCOUNT_PATH) == 0 ) {
		if ( mLSLiveChatRequestLoveCallControllerCallback.onQueryLoveCallRequestCount != NULL ) {
			int count = 0;
			if ( data[LOVECALL_QUERY_REQUESTCOUNT_NUM].isIntegral() ) {
				count = data[LOVECALL_QUERY_REQUESTCOUNT_NUM].asInt();
			}
			mLSLiveChatRequestLoveCallControllerCallback.onQueryLoveCallRequestCount(requestId, bFlag, errnum, errmsg, count);
		}
	}
	FileLog("httprequest", "LSLiveChatRequestLoveCallController::onSuccess() end, url:%s", url.c_str());
}
void LSLiveChatRequestLoveCallController::onFail(long requestId, string url) {
	FileLog("httprequest", "LSLiveChatRequestLoveCallController::onFail( url : %s )", url.c_str());
	/* request fail, callback fail */
	if( url.compare(LOVECALL_QUERY_LIST_PATH) == 0 ) {
		/* 11.1.获取Love Call列表接口  */
		list<LSLCLoveCall> itemList;
		if( mLSLiveChatRequestLoveCallControllerCallback.onQueryLoveCallList != NULL ) {
			mLSLiveChatRequestLoveCallControllerCallback.onQueryLoveCallList(requestId, false, itemList, 0, LOCAL_ERROR_CODE_TIMEOUT, LOCAL_ERROR_CODE_TIMEOUT_DESC);
		}
	} else if( url.compare(LOVECALL_CONFIRM_PATH) == 0 ) {
		/* 11.2.确定Love Call接口 */
		if( mLSLiveChatRequestLoveCallControllerCallback.onConfirmLoveCall != NULL ) {
			mLSLiveChatRequestLoveCallControllerCallback.onConfirmLoveCall(requestId, false, LOCAL_ERROR_CODE_TIMEOUT, LOCAL_ERROR_CODE_TIMEOUT_DESC, 0);
		}
	} else if ( url.compare(LOVECALL_QUERY_REQUESTCOUNT_PATH) == 0 ) {
		if ( mLSLiveChatRequestLoveCallControllerCallback.onQueryLoveCallRequestCount != NULL ) {
			mLSLiveChatRequestLoveCallControllerCallback.onQueryLoveCallRequestCount(requestId, false, LOCAL_ERROR_CODE_TIMEOUT, LOCAL_ERROR_CODE_TIMEOUT_DESC, 0);
		}
	}
	FileLog("httprequest", "LSLiveChatRequestLoveCallController::onFail() end, url:%s", url.c_str());
}

/**
 * 11.1.获取Love Call列表接口
 * @param pageIndex			当前页数
 * @param pageSize			每页行数
 * @param searchType		查询类型（0：Request，1：Scheduled）
 * @return					请求唯一标识
 */
long LSLiveChatRequestLoveCallController::QueryLoveCallList(int pageIndex, int pageSize, int searchType) {
	HttpEntiy entiy;
	char temp[16];

	sprintf(temp, "%d", pageIndex);
	entiy.AddContent(COMMON_PAGE_INDEX, temp);

	sprintf(temp, "%d", pageSize);
	entiy.AddContent(COMMON_PAGE_SIZE, temp);

	sprintf(temp, "%d", searchType);
	entiy.AddContent(LOVECALL_QUERY_LIST_TYPE, temp);

	string url = LOVECALL_QUERY_LIST_PATH;
	FileLog("httprequest", "LSLiveChatRequestLoveCallController::QueryLoveCallList( "
			"url : %s, "
			"pageIndex : %d, "
			"pageSize : %d, "
			"searchType : %d "
			")",
			url.c_str(),
			pageIndex,
			pageSize,
			searchType
			);

	return StartRequest(url, entiy, this);
}

/**
 * 11.2.确定Love Call接口
 * @param orderId			订单ID
 * @param confirmType		确定类型（1：接受，0：拒绝）
 * @return					请求唯一标识
 */
long LSLiveChatRequestLoveCallController::ConfirmLoveCall(string orderId, int confirmType) {
	HttpEntiy entiy;
	char temp[16];

	if( orderId.length() > 0 ) {
		entiy.AddContent(LOVECALL_QUERY_LIST_ORDERID, orderId);
	}

	sprintf(temp, "%d", confirmType);
	entiy.AddContent(LOVECALL_CONFIRM_CONFIRMTYPE, temp);

	string url = LOVECALL_CONFIRM_PATH;
	FileLog("httprequest", "LSLiveChatRequestLoveCallController::ConfirmLoveCall( "
			"url : %s, "
			"orderId : %s, "
			"confirmType : %d "
			")",
			url.c_str(),
			orderId.c_str(),
			confirmType
			);

	return StartRequest(url, entiy, this);
}

// 11.3 获取LoveCall未处理数
long LSLiveChatRequestLoveCallController::QueryLoveCallRequestCount(int searchType)
{
	HttpEntiy entiy;
	char temp[16];

	sprintf(temp, "%d", searchType);
	entiy.AddContent(LOVECALL_QUERY_REQUESTCOUNT_TYPE, temp);

	string url = LOVECALL_QUERY_REQUESTCOUNT_PATH;
	FileLog("httprequest", "LSLiveChatRequestLoveCallController::QueryLoveCallRequestCount( "
			"url : %s, "
			"searchType : %d "
			")",
			url.c_str(),
			searchType
			);

	return StartRequest(url, entiy, this);
}
