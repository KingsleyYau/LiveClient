/*
 * HttpUploadLetterPhotoTask.cpp
 *
 *  Created on: 2017-9-11
 *      Author: Alex
 *        desc: 13.6.上传附件
 */

#include "HttpUploadLetterPhotoTask.h"

HttpUploadLetterPhotoTask::HttpUploadLetterPhotoTask() {
	// TODO Auto-generated constructor stub
	mPath = LETTER_UPLOADLETTERPHOTO;
    mFileName = "";

}

HttpUploadLetterPhotoTask::~HttpUploadLetterPhotoTask() {
	// TODO Auto-generated destructor stub
}

void HttpUploadLetterPhotoTask::SetCallback(IRequestUploadLetterPhotoCallback* callback) {
	mpCallback = callback;
}

void HttpUploadLetterPhotoTask::SetParam(
                                         string file,
                                         string fileName
                                  ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    if (file.length() >  0 ) {
        mHttpEntiy.AddFile(LETTER_FILE, file.c_str());
        mHttpEntiy.SetConnectTimeout(60);
    }

    mFileName = fileName;
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpUploadLetterPhotoTask::SetParam( "
            "task : %p, "
            "file : %s,"
            ")",
            this,
            file.c_str()
            );
}


bool HttpUploadLetterPhotoTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpUploadLetterPhotoTask::ParseData( "
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
    string attachUrl = "";
    string attachMD5 = "";
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解
        Json::Value dataJson;
        Json::Value errDataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson, &errDataJson) ) {
            if(dataJson.isObject()) {
                if (dataJson[LETTER_URL].isString()) {
                    attachUrl = dataJson[LETTER_URL].asString();
                }
                if (dataJson[LETTER_MD5].isString()) {
                    attachMD5 = dataJson[LETTER_MD5].asString();
                }
            }
            
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnUploadLetterPhoto(this, bParse, errnum, errmsg, attachUrl, attachMD5, mFileName);
    }
    
    return bParse;
}

