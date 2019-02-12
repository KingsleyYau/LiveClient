/*
 * LSLiveChatRequestPaidController.cpp
 *
 *  Created on: 2016-06-21
 *      Author: Samson
 */

#include "LSLiveChatRequestPaidController.h"

LSLiveChatRequestPaidController::LSLiveChatRequestPaidController(LSLiveChatHttpRequestManager *pHttpRequestManager, LSLiveChatRequestPaidControllerCallback callback/* CallbackManager* pCallbackManager*/)
{
	// TODO Auto-generated constructor stub
	SetHttpRequestManager(pHttpRequestManager);
	mLSLiveChatRequestPaidControllerCallback = callback;
}

LSLiveChatRequestPaidController::~LSLiveChatRequestPaidController()
{
	// TODO Auto-generated destructor stub
}

/* ILSLiveChatHttpRequestManagerCallback */
void LSLiveChatRequestPaidController::onSuccess(long requestId, string url, const char* buf, int size)
{
	FileLog("httprequest", "LSLiveChatRequestPaidController::onSuccess( url : %s, buf( size : %d ) )", url.c_str(), size);
	if (size < MAX_LOG_BUFFER) {
		FileLog("httprequest", "LSLiveChatRequestPaidController::onSuccess(), buf: %s", buf);
	}

	/* parse base result */
	string code = "";
	Json::Value root;
    bool bFlag = Parsing(buf, size, code, root);
    
	/* resopned parse ok, callback success */
	if( url.compare(PAID_PAY_PATH) == 0 ) {
		/* 7.1.获取订单信息 */
        string orderNo("");
        string productId("");
        if (bFlag) {
            if (root[PAID_ORDERNO].isString()) {
                orderNo = root[PAID_ORDERNO].asString();
            }
            
            if (root[PAID_PRODUCTID].isString()) {
                productId = root[PAID_PRODUCTID].asString();
            }
        }

		if( mLSLiveChatRequestPaidControllerCallback.onPay != NULL ) {
			mLSLiveChatRequestPaidControllerCallback.onPay(requestId, bFlag, code, orderNo, productId);
		}
	}
    else if ( url.compare(PAID_CHECKPAY_PATH) == 0 ) {
        /* 7.2.验证订单信息 */
        if( mLSLiveChatRequestPaidControllerCallback.onCallback != NULL ) {
            mLSLiveChatRequestPaidControllerCallback.onCallback(requestId, bFlag, code);
        }
    }
	FileLog("httprequest", "LSLiveChatRequestPaidController::onSuccess() end, url:%s", url.c_str());
}

void LSLiveChatRequestPaidController::onFail(long requestId, string url)
{
	FileLog("httprequest", "LSLiveChatRequestPaidController::onFail( url : %s )", url.c_str());
	/* request fail, callback fail */
    if( url.compare(PAID_PAY_PATH) == 0 ) {
        /* 7.1.获取订单信息 */
        if( mLSLiveChatRequestPaidControllerCallback.onPay != NULL ) {
            mLSLiveChatRequestPaidControllerCallback.onPay(requestId, false, "", "", "");
        }
    }
    else if ( url.compare(PAID_CHECKPAY_PATH) == 0 ) {
        /* 7.2.验证订单信息 */
        if( mLSLiveChatRequestPaidControllerCallback.onCallback != NULL ) {
            mLSLiveChatRequestPaidControllerCallback.onCallback(requestId, false, "");
        }
    }
	FileLog("httprequest", "LSLiveChatRequestPaidController::onFail() end, url:%s", url.c_str());
}

bool LSLiveChatRequestPaidController::Parsing(const char* buf, int size, string &code, Json::Value &data)
{
    bool result = false;
    
    Json::Value root;
    Json::Reader reader;
    
    string strBuf("");
    strBuf.assign(buf, size);
    if( reader.parse(strBuf, root, false) ) {
        FileLog("httprequest", "LSLiveChatRequestBaseController::HandleResult( parse Json finish )");
        if( root.isObject() ) {
            if( root[PAID_RESULT].isInt() && root[PAID_RESULT].asInt() == 1 ) {
                code = "";
                data = root;
                
                result = true;
            } else {
                if( root[PAID_CODE].isString() ) {
                    code = root[PAID_CODE].asString();
                }
                
                result = false;
            }
        }
    }
    
    return result;
}

/**
 * 7.1.获取订单信息
 * @param manId         男士ID
 * @param sid           跨服务器唯一标识
 * @param number        信用点套餐ID
 * @return				请求唯一标识
 */
long LSLiveChatRequestPaidController::GetPaymentOrder(const string& manId, const string& sid, const string& number)
{
	HttpEntiy entiy;

	if( manId.length() > 0 ) {
		entiy.AddContent(PAID_MANID, manId);
	}

	if( sid.length() > 0 ) {
		entiy.AddContent(PAID_SID, sid);
	}
    
    if( number.length() > 0 ) {
        entiy.AddContent(PAID_NUMBER, number);
    }

	string url = PAID_PAY_PATH;
	FileLog("httprequest", "LSLiveChatRequestPaidController::Pay( "
			"url : %s, "
			"manId : %s, "
			"sid : %s, "
            "number : %s ",
			url.c_str(),
			manId.c_str(),
			sid.c_str(),
            number.c_str()
			);

	return StartRequest(url, entiy, this);
}

/**
 * 7.2.验证订单信息
 * @param manId         男士ID
 * @param sid           跨服务器唯一标识
 * @param receipt       AppStore支付成功返回的recetip参数（BASE64）
 * @param orderNo       订单号
 * @param code          AppStore支付完成返回的状态码
 * @return				请求唯一标识
 */
long LSLiveChatRequestPaidController::CheckPayment(const string& manId, const string& sid, const string& receipt, const string& orderNo, int code)
{
    HttpEntiy entiy;
    
    if( manId.length() > 0 ) {
        entiy.AddContent(PAID_MANID, manId);
    }
    
    if( sid.length() > 0 ) {
        entiy.AddContent(PAID_SID, sid);
    }
    
    if( receipt.length() > 0 ) {
        entiy.AddContent(PAID_RECEIPT, receipt);
    }
    
    if ( orderNo.length() > 0 ) {
        entiy.AddContent(PAID_ORDERNO, orderNo);
    }
    
    char temp[64] = {0};
    sprintf(temp, "%d", code);
    string strCode = temp;
    if ( strCode.length() > 0 ) {
        entiy.AddContent(PAID_ASCODE, strCode);
    }
    
    string url = PAID_CHECKPAY_PATH;
    FileLog("httprequest", "LSLiveChatRequestPaidController::Pay( "
            "url : %s, "
            "manId : %s, "
            "sid : %s, "
            "receipt : %s , "
            "orderNo : %s , "
            "code : %s",
            url.c_str(),
            manId.c_str(),
            sid.c_str(),
            receipt.c_str(),
            orderNo.c_str(),
            strCode.c_str()
            );
    
    return StartRequest(url, entiy, this);
}
