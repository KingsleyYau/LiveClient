/*
 * HttpRegisterCheckPhoneTask.cpp
 *
 *  Created on: 2017-5-22
 *      Author: Alex
 *        desc: 2.1.验证手机是否已注册
 */

#include "HttpRegisterCheckPhoneTask.h"

HttpRegisterCheckPhoneTask::HttpRegisterCheckPhoneTask() {
	// TODO Auto-generated constructor stub
	mPath = REGISTER_CHECK_PHONE_PATH;
	mPhoneNo = "";
    mAreaNo = "";
    mRegistered = 0;
}

HttpRegisterCheckPhoneTask::~HttpRegisterCheckPhoneTask() {
	// TODO Auto-generated destructor stub
}

void HttpRegisterCheckPhoneTask::SetCallback(IRequestRegisterCheckPhoneCallback* callback) {
	mpCallback = callback;
}

void HttpRegisterCheckPhoneTask::SetParam(
                                          string phoneNo,
                                          string areaNo
                                          ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);

	if( phoneNo.length() > 0 ) {
		mHttpEntiy.AddContent(REGISTER_PHONENO, phoneNo.c_str());
		mPhoneNo = phoneNo;
	}
    
    if( areaNo.length() > 0 ) {
        mHttpEntiy.AddContent(REGISTER_AREANO, areaNo.c_str());
        mAreaNo = areaNo;
    }
    

	FileLog("httpcontroller",
            "HttpRegisterCheckPhoneTask::SetParam( "
            "task : %p, "
			"phoneNo : %s, "
            "areaNo : %s, "
			")",
            this,
			phoneNo.c_str(),
            areaNo.c_str()
            );
}

const string& HttpRegisterCheckPhoneTask::GetPhoneNo() {
	return mPhoneNo;
}

const string& HttpRegisterCheckPhoneTask::GetAreaNo() {
    return mAreaNo;
}

bool HttpRegisterCheckPhoneTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog("httpcontroller",
            "HttpRegisterCheckPhoneTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog("httpcontroller", "HttpRegisterCheckPhoneTask::ParseData( buf : %s )", buf);
    }
    
    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
         
            if( dataJson.isObject() ) {
                if (dataJson[REGISER_REGISERED].isInt()) {
                    mRegistered = dataJson[REGISER_REGISERED].asInt();
                }
            }
        }
         bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
    } else {
        // 超时
        errnum = LOCAL_LIVE_ERROR_CODE_TIMEOUT;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnRegisterCheckPhone(this, bParse, errnum, errmsg, mRegistered);
    }
    
    return bParse;
}
