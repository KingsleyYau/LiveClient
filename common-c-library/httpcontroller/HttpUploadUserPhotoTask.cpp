/*
 * HttpUploadUserPhotoTask.cpp
 *
 *  Created on: 2019-08-14
 *      Author: Alex
 *        desc: 2.23.提交用户头像接口
 */

#include "HttpUploadUserPhotoTask.h"
#include <common/CommonFunc.h>
#include "common/md5.h"

HttpUploadUserPhotoTask::HttpUploadUserPhotoTask() {
    // TODO Auto-generated constructor stub
    mPath = LIVEROOM_UPLOADPHOTO_PATH;
    mPhotoName = "";
   
}

HttpUploadUserPhotoTask::~HttpUploadUserPhotoTask() {
    // TODO Auto-generated destructor stub
}

void HttpUploadUserPhotoTask::SetCallback(IRequestUploadUserPhotoCallback* callback) {
    mpCallback = callback;
}

void HttpUploadUserPhotoTask::SetParam(
                                    string photoName
                                   ) {
    
    //	char temp[16];
    mHttpEntiy.Reset();
    mHttpEntiy.SetSaveCookie(true);

    if( photoName.length() > 0 ) {
       mHttpEntiy.AddFile(LIVEROOM_UPLOADPHOTO_PHOTONAME, photoName.c_str());
        //mHttpEntiy.AddFile(OWN_UPLOAD_PHOTO_PHOTONAME, "/Users/alex/Documents/headPhoto.jpg");
        mPhotoName = photoName;
        mHttpEntiy.SetConnectTimeout(60);
    }
    
	FileLog(LIVESHOW_HTTP_LOG,
            "HttpUploadUserPhotoTask::SetParam( "
            "task : %p, "
            "photoName : %s "
            ")",
            this,
            photoName.c_str()
            );
}


bool HttpUploadUserPhotoTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpUploadUserPhotoTask::ParseData( "
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
    bool bParse = false;

    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            bParse = true;
            
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = HTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
        
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnUploadUserPhoto(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}
