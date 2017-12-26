/*
 * HttpOwnRegisterTask.cpp
 *
 *  Created on: 2017-12-20
 *      Author: Alex
 *        desc: 2.5.邮箱注册（仅独立）
 */

#include "HttpOwnRegisterTask.h"
#include <common/CommonFunc.h>
#include "common/md5.h"

HttpOwnRegisterTask::HttpOwnRegisterTask() {
    // TODO Auto-generated constructor stub
    mPath = OWN_REGISTER_PATH;
    mDeviceId = "";
    mModel = "";
    mManufacturer = "";
    mEmail = "";
    mPassWord = "";
    mBirthDay = "";
    mInviteCode = "";
    mUtmReferrer = "";
    mNickName = "";
    mGender = GENDERTYPE_MAN;
    
}

HttpOwnRegisterTask::~HttpOwnRegisterTask() {
    // TODO Auto-generated destructor stub
}

void HttpOwnRegisterTask::SetCallback(IRequestOwnRegisterCallback* callback) {
    mpCallback = callback;
}

void HttpOwnRegisterTask::SetParam(
                                   string email,
                                   string passWord,
                                   GenderType gender,
                                   string nickName,
                                   string birthDay,
                                   string inviteCode,
                                   string model,
                                   string deviceid,
                                   string manufacturer,
                                   string utmReferrer
                                   ) {
    
    //	char temp[16];
    mHttpEntiy.Reset();
    mHttpEntiy.SetSaveCookie(true);

    if( deviceid.length() > 0 ) {
        mHttpEntiy.AddContent(OWN_REGISTER_DEVICEID, deviceid.c_str());
        mDeviceId = deviceid;
    }
    
    if( model.length() > 0 ) {
        mHttpEntiy.AddContent(OWN_REGISTER_MODEL, model.c_str());
        mModel = model;
    }
    
    if( manufacturer.length() > 0 ) {
        mHttpEntiy.AddContent(OWN_REGISTER_MANUFACTURER, manufacturer.c_str());
        mManufacturer = manufacturer;
    }
    
    if (email.length() > 0) {
        mHttpEntiy.AddContent(OWN_REGISTER_EMAIL, email.c_str());
        mEmail = email;
    }
    
    if (passWord.length() > 0) {
        mHttpEntiy.AddContent(OWN_REGISTER_PASSWORD, passWord.c_str());
        mPassWord = passWord;
    }
    
    char temp[16];
    snprintf(temp, sizeof(temp), "%c", gender == GENDERTYPE_LADY ? 'F' : 'M');
    mHttpEntiy.AddContent(LIVEROOM_SUBMITSERVERVELOMETER_RES, temp);
    mGender = gender;
    
    if (nickName.length() > 0) {
        mHttpEntiy.AddContent(OWN_REGISTER_NICKNAME, birthDay.c_str());
        mNickName = nickName;
    }
    
    if (birthDay.length() > 0) {
        mHttpEntiy.AddContent(OWN_REGISTER_BIRTHDAY, birthDay.c_str());
        mBirthDay = birthDay;
    }
    
    if (inviteCode.length() > 0) {
        mHttpEntiy.AddContent(OWN_REGISTER_INVITECODE, inviteCode.c_str());
        mInviteCode = inviteCode;
    }

    if (utmReferrer.length() > 0) {
        mHttpEntiy.AddContent(OWN_REGISTER_UTMREFERRER, utmReferrer.c_str());
        mUtmReferrer = utmReferrer;
    }

	FileLog(LIVESHOW_HTTP_LOG,
            "HttpOwnRegisterTask::SetParam( "
            "task : %p, "
            "email : %s "
            "password : %s "
            "gender : %d %s"
            "nickName : %s "
            "deviceid : %s "
            "model : %s "
            "manufacturer : %s "
            "birthDay : %s "
            "inviteCode : %s "
            "utmReferrer : %s "
            ")",
            this,
            email.c_str(),
            passWord.c_str(),
            gender, gender == GENDERTYPE_LADY ? "女士" : "男人",
            nickName.c_str(),
            deviceid.c_str(),
            model.c_str(),
            manufacturer.c_str(),
            birthDay.c_str(),
            inviteCode.c_str(),
            utmReferrer.c_str()
            );
}


bool HttpOwnRegisterTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpOwnRegisterTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpOwnRegisterTask::ParseData( buf : %s )", buf);
    }
    
    string sessionId = "alex123";
    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            bParse = true;
            if (dataJson[OWN_REGISTER_SESSIONID].isString()) {
                sessionId = dataJson[OWN_REGISTER_SESSIONID].asString();
            }
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        // LSalextest
        if (bParse == false) {
            errnum = LOCAL_LIVE_ERROR_CODE_SUCCESS;
            errmsg = "";
            bParse = true;
        }
        
    } else {
//        // 超时
//        errnum = LOCAL_LIVE_ERROR_CODE_TIMEOUT;
//        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
        
        // LSalextest
        errnum = LOCAL_LIVE_ERROR_CODE_SUCCESS;
        errmsg = "";
        bParse = true;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnOwnRegister(this, bParse, errnum, errmsg, sessionId);
    }
    
    return bParse;
}
