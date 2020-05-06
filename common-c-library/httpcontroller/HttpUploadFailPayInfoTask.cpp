/*
 * HttpUploadFailPayInfoTask.cpp
 *
 *  Created on: 2019-12-10
 *      Author: Alex
 *        desc: 16.4.Google购买失败信息上传（仅Android）
 */

#include "HttpUploadFailPayInfoTask.h"
#include <common/md5.h>

typedef map<string, string, less<string>> mapTmp;

HttpUploadFailPayInfoTask::HttpUploadFailPayInfoTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_ANDROIDPAIDLOGS;
}

HttpUploadFailPayInfoTask::~HttpUploadFailPayInfoTask() {
	// TODO Auto-generated destructor stub
}

void HttpUploadFailPayInfoTask::SetCallback(IRequestUploadFailPayInfoCallback* callback) {
	mpCallback = callback;
}

void HttpUploadFailPayInfoTask::SetParam(
                                         string manid,
                                         string orderNo,
                                         string number,
                                         string errNo,
                                         string errMsg

                                      ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    mapTmp tmp;
    
    if( manid.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_ANDROIDPAIDLOGS_MANID, manid.c_str());
        
    }
    tmp.insert(mapTmp::value_type(LIVEROOM_ANDROIDPAIDLOGS_MANID, manid));
    
    if( orderNo.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_ANDROIDPAIDLOGS_ORDERNO, orderNo.c_str());
        
    }
    tmp.insert(mapTmp::value_type(LIVEROOM_ANDROIDPAIDLOGS_ORDERNO, orderNo));
    
    if( number.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_ANDROIDPAIDLOGS_NUMBER, number.c_str());
        
    }
    tmp.insert(mapTmp::value_type(LIVEROOM_ANDROIDPAIDLOGS_NUMBER, number));
    
    if( errNo.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_ANDROIDPAIDLOGS_ERRNO, errNo.c_str());
        
    }
    tmp.insert(mapTmp::value_type(LIVEROOM_ANDROIDPAIDLOGS_ERRNO, errNo));
    
    if( errMsg.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_ANDROIDPAIDLOGS_ERRMSG, errMsg.c_str());
        
    }
    tmp.insert(mapTmp::value_type(LIVEROOM_ANDROIDPAIDLOGS_ERRMSG, errMsg));
    
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
            "HttpUploadFailPayInfoTask::SetParam( "
            "task : %p, "
            "manid : %s, "
            "orderNo : %s, "
            "number : %s, "
            "errNo : %s, "
            "errMsg : %s, "
            "strTemp : %s, "
            "strMD5 : %s"
            ")",
            this,
            manid.c_str(),
            orderNo.c_str(),
            number.c_str(),
            errNo.c_str(),
            errMsg.c_str(),
            strTemp.c_str(),
            strMD5
            );
}



bool HttpUploadFailPayInfoTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpUploadFailPayInfoTask::ParseData( "
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
        mpCallback->OnUploadFailPayInfo(this, bParse, code, errmsg);
    }
    
    return bParse;
}

