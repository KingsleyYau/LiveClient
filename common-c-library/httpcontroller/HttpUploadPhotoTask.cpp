/*
 * HttpUploadPhotoTask.cpp
 *
 *  Created on: 2017-12-21
 *      Author: Alex
 *        desc: 2.9.提交用户头像接口（仅独立）
 */

#include "HttpUploadPhotoTask.h"
#include <common/CommonFunc.h>
#include "common/md5.h"

HttpUploadPhotoTask::HttpUploadPhotoTask() {
    // TODO Auto-generated constructor stub
    mPath = OWN_UPLOAD_PHOTO_PATH;
    mPhotoName = "";
   
}

HttpUploadPhotoTask::~HttpUploadPhotoTask() {
    // TODO Auto-generated destructor stub
}

void HttpUploadPhotoTask::SetCallback(IRequestUploadPhotoCallback* callback) {
    mpCallback = callback;
}

void HttpUploadPhotoTask::SetParam(
                                    string photoName
                                   ) {
    
    //	char temp[16];
    mHttpEntiy.Reset();
    mHttpEntiy.SetSaveCookie(true);

    if( photoName.length() > 0 ) {
       mHttpEntiy.AddFile(OWN_UPLOAD_PHOTO_PHOTONAME, photoName.c_str());
        //mHttpEntiy.AddFile(OWN_UPLOAD_PHOTO_PHOTONAME, "/Users/alex/Documents/headPhoto.jpg");
        mPhotoName = photoName;
        mHttpEntiy.SetConnectTimeout(60);
    }
    
	FileLog(LIVESHOW_HTTP_LOG,
            "HttpUploadPhotoTask::SetParam( "
            "task : %p, "
            "photoName : %s "
            ")",
            this,
            photoName.c_str()
            );
}


bool HttpUploadPhotoTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpUploadPhotoTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpUploadPhotoTask      ::ParseData( buf : %s )", buf);
    }
    
    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    string photoUrl = "";
    bool bParse = false;

    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            bParse = true;
            if (dataJson[OWN_UPLOAD_PHOTO_PHOTOURL].isString()) {
                photoUrl = dataJson[OWN_UPLOAD_PHOTO_PHOTOURL].asString();
            }
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
        
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnUploadPhoto(this, bParse, errnum, errmsg, photoUrl);
    }
    
    return bParse;
}
