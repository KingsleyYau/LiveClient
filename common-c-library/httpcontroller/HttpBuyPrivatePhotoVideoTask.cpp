/*
 * HttpBuyPrivatePhotoVideoTask.cpp
 *
 *  Created on: 2017-9-11
 *      Author: Alex
 *        desc: 13.7.购买信件附件
 */

#include "HttpBuyPrivatePhotoVideoTask.h"
#include "HttpRequestConvertEnum.h"

HttpBuyPrivatePhotoVideoTask::HttpBuyPrivatePhotoVideoTask() {
	// TODO Auto-generated constructor stub
	mPath = LETTER_BUYPRIVATEPHOTOVIDEO;

}

HttpBuyPrivatePhotoVideoTask::~HttpBuyPrivatePhotoVideoTask() {
	// TODO Auto-generated destructor stub
}

void HttpBuyPrivatePhotoVideoTask::SetCallback(IRequestBuyPrivatePhotoVideoCallback* callback) {
	mpCallback = callback;
}

void HttpBuyPrivatePhotoVideoTask::SetParam(
                                            string emfId,
                                            string resourceId,
                                            LSLetterComsumeType comsumeType
                                  ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    if (emfId.length() >  0 ) {
        mHttpEntiy.AddContent(LETTER_EMF_ID, emfId.c_str());
    }
    if (resourceId.length() >  0 ) {
        mHttpEntiy.AddContent(LETTER_RESOURCE_ID, resourceId.c_str());
    }
    string strType = GetLetterComsumeTypeStr(comsumeType);
    if (strType.length()) {
        mHttpEntiy.AddContent(LETTER_CLICK_TYPE, strType.c_str());
    }
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpBuyPrivatePhotoVideoTask::SetParam( "
            "task : %p, "
            "emfId : %s,"
            "resourceId : %s,"
            "comsumeType : %d"
            ")",
            this,
            emfId.c_str(),
            resourceId.c_str(),
            comsumeType
            );
}


bool HttpBuyPrivatePhotoVideoTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpBuyPrivatePhotoVideoTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );

    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    HttpBuyAttachItem item;
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解
        Json::Value dataJson;
        Json::Value errDataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson, &errDataJson) ) {
            if(dataJson.isObject()) {
                item.Parse(dataJson);
            }
            
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnBuyPrivatePhotoVideo(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}

