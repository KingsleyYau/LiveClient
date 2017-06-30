/*
 *  HttpUploadLiveRoomImgTask.cpp
 *
 *  Created on: 2017-6-08
 *      Author: Alex
 *        desc: 5.2.上传图片（用于客户端上传图片，使用5.1.同步配置的上传图片服务器域名及端口）
 */

#include "HttpUploadLiveRoomImgTask.h"

HttpUploadLiveRoomImgTask::HttpUploadLiveRoomImgTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_UPLOADIMG;
    mToken = "";
    mImageType = IMAGETYPE_UNKNOWN;
    mImageFileName = "";
    
    mImageId = "";
    mImageUrl = "";
}

HttpUploadLiveRoomImgTask::~HttpUploadLiveRoomImgTask() {
	// TODO Auto-generated destructor stub
}

void HttpUploadLiveRoomImgTask::SetCallback(IRequestUploadLiveRoomImgCallback* callback) {
	mpCallback = callback;
}

void HttpUploadLiveRoomImgTask::SetParam(
                                         string token,
                                         ImageType imageType,
                                         string imageFileName
                                     ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);

    if( token.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_UPLOAD_TOKEN, token.c_str());
        mToken = token;
    }
    
    char temp[16];
    snprintf(temp, sizeof(temp), "%d", imageType);
    mHttpEntiy.AddContent(LIVEROOM_UPLOAD_TYPE, temp);
    mImageType = imageType;
    
    if (imageFileName.length() > 0) {
        //mHttpEntiy.AddContent(LIVEROOM_UPLOAD_IMAGE, imageFileName.c_str());
        mHttpEntiy.AddFile(LIVEROOM_UPLOAD_IMAGE, imageFileName);
    }
    
    FileLog("httpcontroller",
            "HttpUploadLiveRoomImgTask::SetParam( "
            "task : %p, "
            "token : %s, "
            "imageType : %d, "
            "imageFileName : %s"
            ")",
            this,
            token.c_str(),
            imageType,
            imageFileName.c_str()
            );
}

const string& HttpUploadLiveRoomImgTask::GetToken() {
    return mToken;
}

const ImageType HttpUploadLiveRoomImgTask::GetImageType() {
    return mImageType;
}

const string& HttpUploadLiveRoomImgTask::GetImageFileName() {
    return mImageFileName;
}

bool HttpUploadLiveRoomImgTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog("httpcontroller",
            "HttpUploadLiveRoomImgTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog("httpcontroller", "HttpUploadLiveRoomImgTask::ParseData( buf : %s )", buf);
    }
    
    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            if( dataJson.isObject() ) {
                if (dataJson[LIVEROOM_UPLOAD_ID].isString()) {
                    mImageId = dataJson[LIVEROOM_UPLOAD_ID].asString();
                }
                if (dataJson[LIVEROOM_UPLOAD_URL].isString()) {
                    mImageUrl = dataJson[LIVEROOM_UPLOAD_URL].asString();
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
        mpCallback->OnUploadLiveRoomImg(this, bParse, errnum, errmsg, mImageId, mImageUrl);
    }
    
    return bParse;
}
