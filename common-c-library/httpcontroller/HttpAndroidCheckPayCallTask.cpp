/*
 * HttpAndroidCheckPayCallTask.cpp
 *
 *  Created on: 2019-12-10
 *      Author: Alex
 *        desc: 16.3.购买成功上传校验送点（仅Android）
 */

#include "HttpAndroidCheckPayCallTask.h"
#include <common/md5.h>

typedef map<string, string, less<string>> mapTmp;


HttpAndroidCheckPayCallTask::HttpAndroidCheckPayCallTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_ANDROIDCALLBACK;
}

HttpAndroidCheckPayCallTask::~HttpAndroidCheckPayCallTask() {
	// TODO Auto-generated destructor stub
}

void HttpAndroidCheckPayCallTask::SetCallback(IRequestAndroidCheckPayCallCallback* callback) {
	mpCallback = callback;
}

void HttpAndroidCheckPayCallTask::SetParam(
                                           LSPaidCallType callType,
                                           string manid,
                                           string orderNo,
                                           string number,
                                           string token,
                                           string data

                                      ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    mapTmp tmp;
    
    char temp[16];
    if (callType > LSPAIDCALLTYPE_BEGIN && callType <= LSPAIDCALLTYPE_END) {
        snprintf(temp, sizeof(temp), "%d", callType);
        mHttpEntiy.AddContent(LIVEROOM_ANDROIDCALLBACK_CALLTAYPE, temp);
        
    }
    tmp.insert(mapTmp::value_type(LIVEROOM_ANDROIDCALLBACK_CALLTAYPE, temp));

    
    if( manid.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_ANDROIDCALLBACK_MANID, manid.c_str());
        
    }
    tmp.insert(mapTmp::value_type(LIVEROOM_ANDROIDCALLBACK_MANID, manid));
    
    if( orderNo.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_ANDROIDCALLBACK_ORDERNO, orderNo.c_str());
        
    }
    tmp.insert(mapTmp::value_type(LIVEROOM_ANDROIDCALLBACK_ORDERNO, orderNo));
    
    if( number.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_ANDROIDCALLBACK_NUMBER, number.c_str());
        
    }
    tmp.insert(mapTmp::value_type(LIVEROOM_ANDROIDCALLBACK_NUMBER, number));
    
    if( token.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_ANDROIDCALLBACK_TOKEN, token.c_str());
        
    }
    tmp.insert(mapTmp::value_type(LIVEROOM_ANDROIDCALLBACK_TOKEN, token));
    
    if( data.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_ANDROIDCALLBACK_DATA, data.c_str());
        
    }
    tmp.insert(mapTmp::value_type(LIVEROOM_ANDROIDCALLBACK_DATA, data));
    
    string strTemp = "4#5j@!94*s^a(e2";
    for(mapTmp::iterator iter = tmp.begin(); iter != tmp.end(); iter++) {
        char cTemp[1024];
        snprintf(cTemp, sizeof(cTemp), "%s=%s&", (iter->first).c_str(), (iter->second).c_str());
        strTemp += cTemp;
    }
    
    // 生成MD5字符串
    char strMD5[2048] = {0};
    GetMD5String(strTemp.c_str(), strMD5);
    
    mHttpEntiy.AddContent(LIVEROOM_ANDROIDCALLBACK_SIGN, strMD5);

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAndroidCheckPayCallTask::SetParam( "
            "task : %p, "
            "callType : %d, "
            "manid : %s, "
            "orderNo : %s, "
            "number : %s, "
            "token : %s, "
            "data : %s, "
            "strTemp : %s, "
            "strMD5 : %s"
            ")",
            this,
            callType,
            manid.c_str(),
            orderNo.c_str(),
            number.c_str(),
            token.c_str(),
            data.c_str(),
            strTemp.c_str(),
            strMD5
            );
}



bool HttpAndroidCheckPayCallTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpAndroidCheckPayCallTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );

    string errmsg = "";
    string code = "";
    string orderNo = "";
    string productId = "";
    bool bParse = false;
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        bParse = ParseAndroidPaid(buf, size, code, errmsg, &dataJson);
        if (bParse) {
            if (dataJson[LIVEROOM_IOSPAY_ORDERNO].isString()) {
                orderNo = dataJson[LIVEROOM_IOSPAY_ORDERNO].asString();
            }
            if (dataJson[LIVEROOM_IOSPAY_PRODUCTID].isString()) {
                productId = dataJson[LIVEROOM_IOSPAY_PRODUCTID].asString();
            }
        }
        // bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
    } else {
        // 超时
        code = LOCAL_ERROR_CODE_TIMEOUT;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnAndroidCheckPayCall(this, bParse, code, errmsg);
    }
    
    return bParse;
}

