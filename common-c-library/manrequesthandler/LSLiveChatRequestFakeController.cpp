/*
 * LSLiveChatRequestFakeController.cpp
 *
 *  Created on: 2015-2-27
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#include "LSLiveChatRequestFakeController.h"

#include "LSLiveChatRequestEnumDefine.h"

#include <amf/AmfParser.h>

LSLiveChatRequestFakeController::LSLiveChatRequestFakeController(LSLiveChatHttpRequestManager *pHttpRequestManager, ILSLiveChatRequestFakeControllerCallback* pLSLiveChatRequestFakeControllerCallback/* CallbackManager* pCallbackManager*/) {
	// TODO Auto-generated constructor stub
	SetHttpRequestManager(pHttpRequestManager);
	mpLSLiveChatRequestFakeControllerCallback = pLSLiveChatRequestFakeControllerCallback;
}

LSLiveChatRequestFakeController::~LSLiveChatRequestFakeController() {
	// TODO Auto-generated destructor stub
}

/* ILSLiveChatHttpRequestManagerCallback */
void LSLiveChatRequestFakeController::onSuccess(long requestId, string url, const char* buf, int size) {
	FileLog("httprequest",
			"LSLiveChatRequestFakeController::onSuccess( url : %s, content-type : %s, buf( size : %d ) )",
			url.c_str(),
			GetContentTypeById(requestId).c_str(),
			size
			);

	if (size < MAX_LOG_BUFFER) {
		FileLog("httprequest", "LSLiveChatRequestFakeController::onSuccess(), buf: %s", buf);
	}

	/* parse base result */
	string errnum = "";
	string errmsg = "";
	Json::Value data;
	Json::Value errdata;

	bool bFlag = HandleResult(buf, size, errnum, errmsg, &data, &errdata);

	/* resopned parse ok, callback success */
	if( url.compare(FAKE_CHECK_SERVER_PATH) == 0 ) {
		/* 2.1.检查真假服务器 */
		LSLCCheckServerItem item;
		item.Parse(data);

		if( mpLSLiveChatRequestFakeControllerCallback != NULL ) {
			mpLSLiveChatRequestFakeControllerCallback->OnCheckServer(requestId, bFlag, item, errnum, errmsg);
		}
	}

	FileLog("httprequest", "LSLiveChatRequestFakeController::onSuccess() end, url:%s", url.c_str());
}
void LSLiveChatRequestFakeController::onFail(long requestId, string url) {
	FileLog("httprequest", "LSLiveChatRequestFakeController::onFail( url : %s )", url.c_str());
	/* request fail, callback fail */
	if( url.compare(FAKE_CHECK_SERVER_PATH) == 0 ) {
		/* 2.1.检查真假服务器 */
		LSLCCheckServerItem item;

		if( mpLSLiveChatRequestFakeControllerCallback != NULL ) {
			mpLSLiveChatRequestFakeControllerCallback->OnCheckServer(requestId, false, item,
					LOCAL_ERROR_CODE_TIMEOUT, LOCAL_ERROR_CODE_TIMEOUT_DESC);
		}
	}
	FileLog("httprequest", "LSLiveChatRequestFakeController::onFail() end, url:%s", url.c_str());
}


/**
 * 2.1.检查真假服务器
 * @param email				电子邮箱
 * @return					请求唯一标识
 */
long LSLiveChatRequestFakeController::CheckServer(
		string email
		) {

	HttpEntiy entiy;

	if( email.length() > 0 ) {
		entiy.AddContent(FAKE_EMAIL, email.c_str());
	}

	string url = FAKE_CHECK_SERVER_PATH;
	FileLog("httprequest", "LSLiveChatRequestFakeController::LoginWithFacebook( "
			"url : %s, "
			"email : %s "
			" )",
			url.c_str(),
			email.c_str()
			);

	return StartRequest(url, entiy, this, FakeSite);
}
