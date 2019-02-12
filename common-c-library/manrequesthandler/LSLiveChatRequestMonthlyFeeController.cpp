/*
 * LSLiveChatRequestMonthlyFeeController.cpp
 *
 *  Created on: 2016-5-10
 *      Author: Hunter
 */

#include "LSLiveChatRequestMonthlyFeeController.h"

LSLiveChatRequestMonthlyFeeController::LSLiveChatRequestMonthlyFeeController(LSLiveChatHttpRequestManager *phttprequestManager, LSLiveChatRequestMonthlyFeeControllerCallback callback/* CallbackManager* pCallbackManager*/) {
	// TODO Auto-generated constructor stub
	SetHttpRequestManager(phttprequestManager);
	mLSLiveChatRequestMonthlyFeeControllerCallback = callback;
}

LSLiveChatRequestMonthlyFeeController::~LSLiveChatRequestMonthlyFeeController() {
	// TODO Auto-generated destructor stub
}

/* IhttprequestManagerCallback */
void LSLiveChatRequestMonthlyFeeController::onSuccess(long requestId, string url, const char* buf, int size) {
	FileLog("httprequest", "LSLiveChatRequestMonthlyFeeController::onSuccess( url : %s, buf( size : %d ) )", url.c_str(), size);
	if (size < MAX_LOG_BUFFER) {
		FileLog("httprequest", "LSLiveChatRequestMonthlyFeeController::onSuccess(), buf: %s", buf);
	}

	/* parse base result */
	string errnum = "";
	string errmsg = "";
	Json::Value data;

	bool bFlag = HandleResult(buf, size, errnum, errmsg, &data);

	/* resopned parse ok, callback success */
	if( url.compare(MONTHLY_FEE_MEMBER_TYPE_PATH) == 0 ) {
		/* 13.1.获取月费会员类型   */
		int memberType = 0;
		if( data[MONTHLY_FEE_MEMBER_TYPE].isInt() ){
			memberType = data[MONTHLY_FEE_MEMBER_TYPE].asInt();
		}
        string mfeeEndDate = "";
        if (data[MONTHLY_FEE_MEMBER_MFEE_ENDDATE].isString()) {
            mfeeEndDate = data[MONTHLY_FEE_MEMBER_MFEE_ENDDATE].asString();
        }
		if( mLSLiveChatRequestMonthlyFeeControllerCallback.onQueryMemberType != NULL ) {
			mLSLiveChatRequestMonthlyFeeControllerCallback.onQueryMemberType(requestId, bFlag, errnum, errmsg, memberType, mfeeEndDate);
		}
	} else if( url.compare(MONTHLY_FEE_GET_TIPS_PATH) == 0 ) {
		/* 13.2.获取月费提示层数据   */
		list<LSLCMonthlyFeeTip> itemList;
		if( data.isArray() ) {
			for(int i = 0; i < data.size(); i++ ) {
				LSLCMonthlyFeeTip item;
				item.Parse(data.get(i, Json::Value::null));
				itemList.push_back(item);
			}
        } else {
			// parsing fail
			bFlag = false;
			errnum = LOCAL_ERROR_CODE_PARSEFAIL;
			errmsg = LOCAL_ERROR_CODE_PARSEFAIL_DESC;
		}
		if( mLSLiveChatRequestMonthlyFeeControllerCallback.onGetMonthlyFeeTips != NULL ) {
			mLSLiveChatRequestMonthlyFeeControllerCallback.onGetMonthlyFeeTips(requestId, bFlag, errnum, errmsg, itemList);
		}
    } else if(url.compare(MONTHLY_FEE_PREMIUM_MEMBERSHIP) == 0 ) {
        /* 6.2.获取买点送月费的文字说明 */
         LSLCMonthlyFeeInstructionItem item;
        if (data[MONTHLY_FEE_PREMIUM_TITLE].isString()) {
            item.Parse(data);
        }
        if (mLSLiveChatRequestMonthlyFeeControllerCallback.onGetPremiumMemberShip != NULL) {
            mLSLiveChatRequestMonthlyFeeControllerCallback.onGetPremiumMemberShip(requestId, bFlag, errnum, errmsg, item);
        }
        
    }
	FileLog("httprequest", "LSLiveChatRequestMonthlyFeeController::onSuccess() end, url:%s", url.c_str());
}
void LSLiveChatRequestMonthlyFeeController::onFail(long requestId, string url) {
	FileLog("httprequest", "LSLiveChatRequestMonthlyFeeController::onFail( url : %s )", url.c_str());
	/* request fail, callback fail */
	if( url.compare(MONTHLY_FEE_MEMBER_TYPE_PATH) == 0 ) {
		/* 13.1.获取月费会员类型  */
		if( mLSLiveChatRequestMonthlyFeeControllerCallback.onQueryMemberType != NULL ) {
			mLSLiveChatRequestMonthlyFeeControllerCallback.onQueryMemberType(requestId, false, LOCAL_ERROR_CODE_TIMEOUT, LOCAL_ERROR_CODE_TIMEOUT_DESC, 0, "");
		}
	} else if( url.compare(MONTHLY_FEE_GET_TIPS_PATH) == 0 ) {
		/* 13.2.获取月费提示层数据   */
		list<LSLCMonthlyFeeTip> itemList;
		if( mLSLiveChatRequestMonthlyFeeControllerCallback.onGetMonthlyFeeTips != NULL ) {
			mLSLiveChatRequestMonthlyFeeControllerCallback.onGetMonthlyFeeTips(requestId, false, LOCAL_ERROR_CODE_TIMEOUT, LOCAL_ERROR_CODE_TIMEOUT_DESC, itemList);
		}
	}
    else if( url.compare(MONTHLY_FEE_PREMIUM_MEMBERSHIP) == 0 ) {
        /* 6.2.获取买点送月费的文字说明 */
        LSLCMonthlyFeeInstructionItem item;
        if( mLSLiveChatRequestMonthlyFeeControllerCallback.onGetPremiumMemberShip != NULL ) {
            mLSLiveChatRequestMonthlyFeeControllerCallback.onGetPremiumMemberShip(requestId, false, LOCAL_ERROR_CODE_TIMEOUT, LOCAL_ERROR_CODE_TIMEOUT_DESC, item);
        }
    }
    FileLog("httprequest", "LSLiveChatRequestMonthlyFeeController::onFail() end, url:%s", url.c_str());
}

/**
 * 13.1.获取月费会员类型
 * @return					请求唯一标识
 */
long LSLiveChatRequestMonthlyFeeController::QueryMemberType() {
	HttpEntiy entiy;

	string url = MONTHLY_FEE_MEMBER_TYPE_PATH;
	FileLog("httprequest", "LSLiveChatRequestMonthlyFeeController::QueryMemberType( "
			"url : %s"
			")",
			url.c_str()
			);

	return StartRequest(url, entiy, this);
}

/**
 * 13.2.获取月费提示层数据
 * @return					请求唯一标识
 */
long LSLiveChatRequestMonthlyFeeController::GetMonthlyFeeTips() {
	HttpEntiy entiy;

	string url = MONTHLY_FEE_GET_TIPS_PATH;
	FileLog("httprequest", "LSLiveChatRequestMonthlyFeeController::GetMonthlyFeeTips( "
			"url : %s"
			")",
			url.c_str()
			);

	return StartRequest(url, entiy, this);
}

/**
 * 6.2.获取买点送月费的文字说明
 * @return					请求唯一标识
 */
long LSLiveChatRequestMonthlyFeeController::GetPremiumMemberShip() {
    HttpEntiy entiy;
    
    string url = MONTHLY_FEE_PREMIUM_MEMBERSHIP;
    FileLog("httprequest", "LSLiveChatRequestMonthlyFeeController::GetPremiumMemberShip( "
            "url : %s"
            ")",
            url.c_str()
            );
    
    return StartRequest(url, entiy, this);
}
