/*
 * LSLiveChatRequestQuickMatchController.cpp
 *
 *  Created on: 2015-2-27
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#include "LSLiveChatRequestQuickMatchController.h"

LSLiveChatRequestQuickMatchController::LSLiveChatRequestQuickMatchController(LSLiveChatHttpRequestManager *phttprequestManager, LSLiveChatRequestQuickMatchControllerCallback callback/* CallbackManager* pCallbackManager*/) {
	// TODO Auto-generated constructor stub
	SetHttpRequestManager(phttprequestManager);
	mLSLiveChatRequestQuickMatchControllerCallback = callback;
}

LSLiveChatRequestQuickMatchController::~LSLiveChatRequestQuickMatchController() {
	// TODO Auto-generated destructor stub
}

/* IhttprequestManagerCallback */
void LSLiveChatRequestQuickMatchController::onSuccess(long requestId, string url, const char* buf, int size) {
	FileLog("httprequest", "LSLiveChatRequestQuickMatchController::onSuccess( url : %s, buf( size : %d ) )", url.c_str(), size);
	if (size < MAX_LOG_BUFFER) {
		FileLog("httprequest", "LSLiveChatRequestQuickMatchController::onSuccess(), buf: %s", buf);
	}

	/* parse base result */
	string errnum = "";
	string errmsg = "";
	Json::Value data;

	bool bFlag = HandleResult(buf, size, errnum, errmsg, &data);

	/* resopned parse ok, callback success */
	if( url.compare(QUICKMATCH_LIST_PATH) == 0 ) {
		/* 10.1.查询女士图片列表  */
		list<LSLCQuickMatchLady> itemList;
		if( data[COMMON_DATA_LIST].isArray() ) {
			for(int i = 0; i < data[COMMON_DATA_LIST].size(); i++ ) {
				LSLCQuickMatchLady item;
				item.Parse(data[COMMON_DATA_LIST].get(i, Json::Value::null));
				itemList.push_back(item);
			}
		} else {
			// parsing fail
			bFlag = false;
			errnum = LOCAL_ERROR_CODE_PARSEFAIL;
			errmsg = LOCAL_ERROR_CODE_PARSEFAIL_DESC;
		}

		if( mLSLiveChatRequestQuickMatchControllerCallback.onQueryQuickMatchLadyList != NULL ) {
			mLSLiveChatRequestQuickMatchControllerCallback.onQueryQuickMatchLadyList(requestId, bFlag,
					itemList, errnum, errmsg);
		}
	} else if( url.compare(QUICKMATCH_UPLOAD_PATH) == 0 ) {
		/* 10.2.提交已标记的女士 */
		if( mLSLiveChatRequestQuickMatchControllerCallback.onSubmitQuickMatchMarkLadyList != NULL ) {
			mLSLiveChatRequestQuickMatchControllerCallback.onSubmitQuickMatchMarkLadyList(requestId, bFlag, errnum, errmsg);
		}
	} else if( url.compare(QUICKMATCH_LIKE_LIST_PATH) == 0 ) {
		/* 10.3.查询已标记like的女士列表 */
		list<LSLCQuickMatchLady> itemList;
		int totalCount = 0;
		if( data[COMMON_DATA_COUNT].isInt() ) {
			totalCount = data[COMMON_DATA_COUNT].asInt();
		}
		if( data[COMMON_DATA_LIST].isArray() ) {
			for(int i = 0; i < data[COMMON_DATA_LIST].size(); i++ ) {
				LSLCQuickMatchLady item;
				item.Parse(data[COMMON_DATA_LIST].get(i, Json::Value::null));
				itemList.push_back(item);
			}
		} else {
			// parsing fail
			bFlag = false;
			errnum = LOCAL_ERROR_CODE_PARSEFAIL;
			errmsg = LOCAL_ERROR_CODE_PARSEFAIL_DESC;
		}

		if( mLSLiveChatRequestQuickMatchControllerCallback.onQueryQuickMatchLikeLadyList != NULL ) {
			mLSLiveChatRequestQuickMatchControllerCallback.onQueryQuickMatchLikeLadyList(requestId, bFlag, itemList,
					totalCount, errnum, errmsg);
		}
	} else if( url.compare(QUICKMATCH_REMOVE_PATH) == 0 ) {
		/* 10.4.删除已标记like的女士 */
		if( mLSLiveChatRequestQuickMatchControllerCallback.onSubmitQuickMatchMarkLadyList != NULL ) {
			mLSLiveChatRequestQuickMatchControllerCallback.onSubmitQuickMatchMarkLadyList(requestId, bFlag, errnum, errmsg);
		}
	}
	FileLog("httprequest", "LSLiveChatRequestQuickMatchController::onSuccess() end, url:%s", url.c_str());
}
void LSLiveChatRequestQuickMatchController::onFail(long requestId, string url) {
	FileLog("httprequest", "LSLiveChatRequestQuickMatchController::onFail( url : %s )", url.c_str());
	/* request fail, callback fail */
	if( url.compare(QUICKMATCH_LIST_PATH) == 0 ) {
		/* 10.1.查询女士图片列表   */
		list<LSLCQuickMatchLady> itemList;
		if( mLSLiveChatRequestQuickMatchControllerCallback.onQueryQuickMatchLadyList != NULL ) {
			mLSLiveChatRequestQuickMatchControllerCallback.onQueryQuickMatchLadyList(requestId, false, itemList, LOCAL_ERROR_CODE_TIMEOUT, LOCAL_ERROR_CODE_TIMEOUT_DESC);
		}
	} else if( url.compare(QUICKMATCH_UPLOAD_PATH) == 0 ) {
		/* 10.2.提交已标记的女士 */
		if( mLSLiveChatRequestQuickMatchControllerCallback.onSubmitQuickMatchMarkLadyList != NULL ) {
			mLSLiveChatRequestQuickMatchControllerCallback.onSubmitQuickMatchMarkLadyList(requestId, false, LOCAL_ERROR_CODE_TIMEOUT, LOCAL_ERROR_CODE_TIMEOUT_DESC);
		}
	} else if( url.compare(QUICKMATCH_LIKE_LIST_PATH) == 0 ) {
		/* 10.3.查询已标记like的女士列表 */
		list<LSLCQuickMatchLady> itemList;
		if( mLSLiveChatRequestQuickMatchControllerCallback.onQueryQuickMatchLikeLadyList != NULL ) {
			mLSLiveChatRequestQuickMatchControllerCallback.onQueryQuickMatchLikeLadyList(requestId, false, itemList,
					0, LOCAL_ERROR_CODE_TIMEOUT, LOCAL_ERROR_CODE_TIMEOUT_DESC);
		}
	} else if( url.compare(QUICKMATCH_REMOVE_PATH) == 0 ) {
		/* 10.4.删除已标记like的女士 */
		if( mLSLiveChatRequestQuickMatchControllerCallback.onSubmitQuickMatchMarkLadyList != NULL ) {
			mLSLiveChatRequestQuickMatchControllerCallback.onSubmitQuickMatchMarkLadyList(requestId, false, LOCAL_ERROR_CODE_TIMEOUT, LOCAL_ERROR_CODE_TIMEOUT_DESC);
		}
	}
	FileLog("httprequest", "LSLiveChatRequestQuickMatchController::onFail() end, url:%s", url.c_str());
}

/**
 * 10.1.查询女士图片列表
 * @param deviceId		设备唯一标识
 * @return				请求唯一标识
 */
long LSLiveChatRequestQuickMatchController::QueryQuickMatchLadyList(string deviceId) {
	HttpEntiy entiy;

	entiy.AddContent(QUICKMATCH_QUERY_DEVICEID, deviceId.c_str());

	string url = QUICKMATCH_LIST_PATH;
	FileLog("httprequest", "LSLiveChatRequestQuickMatchController::QueryQuickMatchLadyList( "
			"url : %s, "
			"deviceId : %s "
			")",
			url.c_str(),
			deviceId.c_str()
			);

	return StartRequest(url, entiy, this);
}

/**
 * 10.2.提交已标记的女士
 * @param likeList		喜爱的女士列表
 * @param unlikeList	不喜爱女士列表
 * @return				请求唯一标识
 */
long LSLiveChatRequestQuickMatchController::SubmitQuickMatchMarkLadyList(list<string> likeListId, list<string> unlikeListId) {
	HttpEntiy entiy;

	string likeId = "";
	for(list<string>::iterator itr = likeListId.begin(); itr != likeListId.end(); itr++) {
		likeId += *itr;
		likeId += ",";
	}
	if( likeId.length() > 0 ) {
		likeId = likeId.substr(0, likeId.length() - 1);
		entiy.AddContent(QUICKMATCH_UPLOAD_CONFIRMTYPE, likeId);
	}

	string unlikeId = "";
	for(list<string>::iterator itr = unlikeListId.begin(); itr != unlikeListId.end(); itr++) {
		unlikeId += *itr;
		unlikeId += ",";
	}
	if( unlikeId.length() > 0 ) {
		unlikeId = unlikeId.substr(0, unlikeId.length() - 1);
		entiy.AddContent(QUICKMATCH_UPLOAD_CONFIRMTYPE, unlikeId);
	}

	string url = QUICKMATCH_UPLOAD_PATH;
	FileLog("httprequest", "LSLiveChatRequestQuickMatchController::SubmitQuickMatchMarkLadyList( "
			"url : %s, "
			"likeId : %s, "
			"unlikeId : %s "
			")",
			url.c_str(),
			likeId.c_str(),
			unlikeId.c_str()
			);

	return StartRequest(url, entiy, this);
}

/**
 * 10.3.查询已标记like的女士列表
 * @return				请求唯一标识
 */
long LSLiveChatRequestQuickMatchController::QueryQuickMatchLikeLadyList(int pageIndex, int pageSize) {
	char temp[16];

	HttpEntiy entiy;

	sprintf(temp, "%d", pageIndex);
	entiy.AddContent(COMMON_PAGE_INDEX, temp);

	sprintf(temp, "%d", pageSize);
	entiy.AddContent(COMMON_PAGE_SIZE, temp);

	string url = QUICKMATCH_LIKE_LIST_PATH;
	FileLog("httprequest", "LSLiveChatRequestQuickMatchController::QueryQuickMatchLikeLadyList( "
			"url : %s, "
			"pageIndex : %d, "
			"pageSize : %d "
			")",
			url.c_str(),
			pageIndex,
			pageSize
			);

	return StartRequest(url, entiy, this);
}

/**
 * 10.4.删除已标记like的女士
 * @param likeListId	喜爱的女士列表
 * @return				请求唯一标识
 */
long LSLiveChatRequestQuickMatchController::RemoveQuickMatchLikeLadyList(list<string> likeListId) {

	HttpEntiy entiy;

	string likeId = "";
	for(list<string>::iterator itr = likeListId.begin(); itr != likeListId.end(); itr++) {
		likeId += *itr;
		likeId += ",";
	}
	if( likeId.length() > 0 ) {
		likeId = likeId.substr(0, likeId.length() - 1);
		entiy.AddContent(QUICKMATCH_UPLOAD_CONFIRMTYPE, likeId);
	}

	string url = QUICKMATCH_REMOVE_PATH;
	FileLog("httprequest", "LSLiveChatRequestQuickMatchController::RemoveQuickMatchLikeLadyList( "
			"url : %s, "
			"likeId : %s "
			")",
			url.c_str(),
			likeId.c_str()
			);

	return StartRequest(url, entiy, this);
}
