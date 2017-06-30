/*
 * HttpSetLiveRoomModifyInfoTask.cpp
 *
 *  Created on: 2017-5-24
 *      Author: Alex
 *        desc: 4.3.提交本人资料
 */

#include "HttpSetLiveRoomModifyInfoTask.h"

HttpSetLiveRoomModifyInfoTask::HttpSetLiveRoomModifyInfoTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_SET_MODIFY_INFO;
    mToken = "";
    mPhotoId = "";
    mNickName = "";
    mGender = GENDER_UNKNOWN;
    mBirthday = "";
}

HttpSetLiveRoomModifyInfoTask::~HttpSetLiveRoomModifyInfoTask() {
	// TODO Auto-generated destructor stub
}

void HttpSetLiveRoomModifyInfoTask::SetCallback(IRequestSetLiveRoomModifyInfoCallback* callback) {
	mpCallback = callback;
}

void HttpSetLiveRoomModifyInfoTask::SetParam(
                                             string token,
                                             string photoId,
                                             string nickName,
                                             Gender gender,
                                             string birthday
                                     ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);

    
    if( token.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_PUBLIC_PERSONAL_TOKEN, token.c_str());
        mToken = token;
    }
    
    if( photoId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_PUBLIC_PERSONAL_PHOTOID, photoId.c_str());
        mPhotoId = photoId;
    }
 
    if( nickName.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_PUBLIC_PERSONAL_NICKNAME, nickName.c_str());
        mNickName = nickName;
    }
 
    char temp[16];
    snprintf(temp, sizeof(temp), "%d", gender);
    mHttpEntiy.AddContent(LIVEROOM_PUBLIC_PERSONAL_GENDER, temp);
    mGender = gender;
    
    
    if( birthday.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_PUBLIC_PERSONAL_BIRTHDAY, birthday.c_str());
        mBirthday = birthday;
    }
    
    
    FileLog("httpcontroller",
            "HttpSetLiveRoomModifyInfoTask::SetParam( "
            "task : %p, "
            "token : %s, "
            "photoUrl : %s, "
            "nickName : %s, "
            "gender : %d, "
            "birthday : %s, "
            ")",
            this,
            token.c_str(),
            photoId.c_str(),
            nickName.c_str(),
            gender,
            birthday.c_str()
            );
}

const string& HttpSetLiveRoomModifyInfoTask::GetToken() {
    return mToken;
}

const string& HttpSetLiveRoomModifyInfoTask::GetPhotoId() {
    return mPhotoId;
}

const string& HttpSetLiveRoomModifyInfoTask::GetNickName() {
    return mNickName;
}

Gender HttpSetLiveRoomModifyInfoTask::GetGender() {
    return mGender;
}

const string& HttpSetLiveRoomModifyInfoTask::GetBirthday() {
    return mBirthday;
}

bool HttpSetLiveRoomModifyInfoTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog("httpcontroller",
            "HttpSetLiveRoomModifyInfoTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog("httpcontroller", "HttpSetLiveRoomModifyInfoTask::ParseData( buf : %s )", buf);
    }
    

    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = LOCAL_LIVE_ERROR_CODE_TIMEOUT;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnSetLiveRoomModifyInfo(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}
