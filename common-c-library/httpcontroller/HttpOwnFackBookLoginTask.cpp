/*
 * HttpOwnFackBookLoginTask.cpp
 *
 *  Created on: 2017-12-20
 *      Author: Alex
 *        desc: 2.4.Facebook注册及登录（仅独立）
 */

#include "HttpOwnFackBookLoginTask.h"
#include <common/CommonFunc.h>
#include "common/md5.h"

HttpOwnFackBookLoginTask::HttpOwnFackBookLoginTask() {
    // TODO Auto-generated constructor stub
    mPath = OWN_FACKBOOK_LOGIN_PATH;
    mDeviceId = "";
    mModel = "";
    mManufacturer = "";
    mFToken = "";
    mEmail = "";
    mPassWord = "";
    mBirthDay = "";
    mNickName = "";
    mInviteCode = "";
    mUtmReferrer = "";
    mGender = GENDERTYPE_MAN;
    
}

HttpOwnFackBookLoginTask::~HttpOwnFackBookLoginTask() {
    // TODO Auto-generated destructor stub
}

void HttpOwnFackBookLoginTask::SetCallback(IRequestOwnFackBookLoginCallback* callback) {
    mpCallback = callback;
}

void HttpOwnFackBookLoginTask::SetParam(
                                        string model,
                                        string deviceid,
                                        string manufacturer,
                                        string fToken                           ,
                                        string email,
                                        string passWord,
                                        string birthDay,
                                        string inviteCode,
                                        string nickName,
                                        string utmReferrer,
                                        GenderType gender
                                   ) {
    
    //	char temp[16];
    mHttpEntiy.Reset();
    mHttpEntiy.SetSaveCookie(true);

    if( deviceid.length() > 0 ) {
        mHttpEntiy.AddContent(OWN_FACKBOOK_LOGIN_DEVICEID, deviceid.c_str());
        mDeviceId = deviceid;
    }
    
    if( model.length() > 0 ) {
        mHttpEntiy.AddContent(OWN_FACKBOOK_LOGIN_MODEL, model.c_str());
        mModel = model;
    }
    
    if( manufacturer.length() > 0 ) {
        mHttpEntiy.AddContent(OWN_FACKBOOK_LOGIN_MANUFACTURER, manufacturer.c_str());
        mManufacturer = manufacturer;
    }
    
    if (fToken.length() > 0) {
        mHttpEntiy.AddContent(OWN_FACKBOOK_LOGIN_FTOKEN, fToken.c_str());
        mFToken = fToken;
    }
    
    if (email.length() > 0) {
        mHttpEntiy.AddContent(OWN_FACKBOOK_LOGIN_EMAIL, email.c_str());
        mEmail = email;
    }
    
    if (passWord.length() > 0) {
        mHttpEntiy.AddContent(OWN_FACKBOOK_LOGIN_PASSWORD, passWord.c_str());
        mPassWord = passWord;
    }
    
    if (birthDay.length() > 0) {
        mHttpEntiy.AddContent(OWN_FACKBOOK_LOGIN_BIRTHDAY, birthDay.c_str());
        mBirthDay = birthDay;
    }
    
    if (inviteCode.length() > 0) {
        mHttpEntiy.AddContent(OWN_FACKBOOK_LOGIN_INVITECODE, inviteCode.c_str());
        mInviteCode = inviteCode;
    }
    
    if (nickName.length() > 0) {
        mHttpEntiy.AddContent(OWN_FACKBOOK_LOGIN_NICKNAME, nickName.c_str());
        mNickName = nickName;
    }
    
    if (utmReferrer.length() > 0) {
        mHttpEntiy.AddContent(OWN_FACKBOOK_LOGIN_UTMREFERRER, utmReferrer.c_str());
        mUtmReferrer = utmReferrer;
    }
    
    if (gender > GENDERTYPE_UNKNOW && gender <= GENDERTYPE_LADY) {
        char temp[16];
        snprintf(temp, sizeof(temp), "%c", gender == GENDERTYPE_LADY ? 'F' : 'M');
        mHttpEntiy.AddContent(OWN_FACKBOOK_LOGIN_GENDER, temp);
        mGender = gender;
    }


	FileLog(LIVESHOW_HTTP_LOG,
            "HttpOwnFackBookLoginTask::SetParam( "
            "task : %p, "
            "fToken : %s"
            "email : %s "
            "deviceid : %s "
            "model : %s "
            "manufacturer : %s "
            "passWord : %s "
            "birthDay : %s "
            "inviteCode : %s "
            "nickName : %s "
            "utmReferrer : %s "
            "gender : %d"
            ")",
            this,
            fToken.c_str(),
            email.c_str(),
            deviceid.c_str(),
            model.c_str(),
            manufacturer.c_str(),
            passWord.c_str(),
            birthDay.c_str(),
            inviteCode.c_str(),
            nickName.c_str(),
            utmReferrer.c_str(),
            gender
            );
}


bool HttpOwnFackBookLoginTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpOwnFackBookLoginTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    string sessionId = "";
    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            bParse = true;
            if(dataJson.isObject()) {
                if (dataJson[OWN_FACKBOOK_LOGIN_SESSIONID].isString()) {
                    sessionId = dataJson[OWN_FACKBOOK_LOGIN_SESSIONID].asString();
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
        mpCallback->OnOwnFackBookLogin(this, bParse, errnum, errmsg, sessionId);
    }
    
    return bParse;
}
