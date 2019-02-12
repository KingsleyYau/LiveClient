/*
 * HttpPhoneInfoTask.cpp
 *
 *  Created on: 2018-11-23
 *      Author: Alex
 *        desc: 6.22.收集手机硬件信息
 */

#include "HttpPhoneInfoTask.h"
#include "HttpRequestConvertEnum.h"
#include <common/CommonFunc.h>

HttpPhoneInfoTask::HttpPhoneInfoTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_PHONEINFO;


}

HttpPhoneInfoTask::~HttpPhoneInfoTask() {
	// TODO Auto-generated destructor stub
}

void HttpPhoneInfoTask::SetCallback(IRequestPhoneInfoCallback* callback) {
	mpCallback = callback;
}

void HttpPhoneInfoTask::SetParam(
                                 const string& manId, int verCode, const string& verName,
                                 int action, HTTP_OTHER_SITE_TYPE siteId, double density,
                                 int width, int height, const string& densityDpi,
                                 const string& model, const string& manufacturer, const string& os,
                                 const string& release, const string& sdk, const string& language,
                                 const string& region, const string& lineNumber, const string& simOptName,
                                 const string& simOpt, const string& simCountryIso, const string& simState,
                                 int phoneType, int networkType, const string& deviceId
                                      ) {
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    char temp[16] = {0};
    
    // density
    snprintf(temp, sizeof(temp), "%f", density);
    mHttpEntiy.AddContent(LIVEROOM_PHONEINFO_DENSITY, temp);
    
    // densityDpi
    if (densityDpi.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_PHONEINFO_DENSITYDPI, densityDpi.c_str());
    }
    
    // model
    if (model.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_PHONEINFO_MODEL, model.c_str());
    }
    
    // manufacturer
    if (manufacturer.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_PHONEINFO_MANUFACTURER, manufacturer.c_str());
    }
    
    // os
    if (os.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_PHONEINFO_OS, os.c_str());
    }
    
    // release
    if (release.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_PHONEINFO_RELEASE, release.c_str());
    }
    
    // sdk
    if (sdk.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_PHONEINFO_SDK, sdk.c_str());
    }
    
    // language
    if (language.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_PHONEINFO_LANGUAGE, language.c_str());
    }
    
    // region
    if (region.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_PHONEINFO_COUNTRY, region.c_str());
    }
    
    // width
    snprintf(temp, sizeof(temp), "%d", width);
    mHttpEntiy.AddContent(LIVEROOM_PHONEINFO_WIDTH, temp);
    
    // height
    snprintf(temp, sizeof(temp), "%d", height);
    mHttpEntiy.AddContent(LIVEROOM_PHONEINFO_HEIGHT, temp);
    
    // data
    string strData = "P0:";
    strData += manId;
    mHttpEntiy.AddContent(LIVEROOM_PHONEINFO_DATA, strData.c_str());
    
    // versionCode
    snprintf(temp, sizeof(temp), "%d", verCode);
    mHttpEntiy.AddContent(LIVEROOM_PHONEINFO_VERSIONCODE, temp);
    
    // versionName
    if (verName.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_PHONEINFO_VERSIONNAME, verName.c_str());
    }
    
    // PhoneType
    snprintf(temp, sizeof(temp), "%d", phoneType);
    mHttpEntiy.AddContent(LIVEROOM_PHONEINFO_PHONETYPE, temp);
    
    // NetworkType
    snprintf(temp, sizeof(temp), "%d", networkType);
    mHttpEntiy.AddContent(LIVEROOM_PHONEINFO_NETWORKTYPE, temp);
    
    // siteid
    string strSite("");
    strSite = GetHttpSiteId(siteId);
    mHttpEntiy.AddContent(LIVEROOM_PHONEINFO_SITEID, strSite);
    
    // action
    string strAction("");
    if (action < _countof(HTTPOTHER_ACTION_TYPE)) {
        strAction = HTTPOTHER_ACTION_TYPE[action];
        mHttpEntiy.AddContent(LIVEROOM_PHONEINFO_ACTION, strAction.c_str());
    }
    
    // line1Number
    if (lineNumber.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_PHONEINFO_LINENUMBER, lineNumber.c_str());
    }
    
    // deviceId
    if (deviceId.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_PHONEINFO_DEVICEID, deviceId.c_str());
    }
    
    // SimOperatorName
    if (simOptName.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_PHONEINFO_SIMOPERATORNAME, simOptName.c_str());
    }
    
    // SimOperator
    if (simOpt.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_PHONEINFO_SIMOPERATOR, simOpt.c_str());
    }
    
    // SimCountryIso
    if (simCountryIso.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_PHONEINFO_SIMCOUNTRYISO, simCountryIso.c_str());
    }
    
    // SimState
    if (simState.length() > 0) {
        mHttpEntiy.AddContent(LIVEROOM_PHONEINFO_SIMSTATE, simState.c_str());
    }

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpPhoneInfoTask::SetParam( "
            "(this:%p, model:%s, manufacturer:%s, os:%s, release:%s, sdk:%s, "
            "density:%f, densityDpi:%s, width:%d, height:%d, "
            "data:%s, versionCode:%d, versionName:%s, PhoneType:%d, NetworkType:%d, "
            "language:%s, country:%s, siteid:%s, action:%s, line1Number:%s, "
            "deviceId:%s, SimOperatorName:%s, SimOperator:%s, SimCountryIso:%s, SimState:%s)",
            this, model.c_str(), manufacturer.c_str(), os.c_str(), release.c_str(), sdk.c_str()
            , density, densityDpi.c_str(), width, height
            , strData.c_str(), verCode, verName.c_str(), phoneType, networkType
            , language.c_str(), region.c_str(), strSite.c_str(), strAction.c_str(), lineNumber.c_str()
            , deviceId.c_str(), simOptName.c_str(), simOpt.c_str(), simCountryIso.c_str(), simState.c_str()
            );
}



bool HttpPhoneInfoTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpPhoneInfoTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );

    string errnum = "";
    string errmsg = "";
    bool bParse = false;
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        bParse = ParseCommon(buf, size, errnum, errmsg, &dataJson);
        
        // bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
    } else {
        // 超时
        errnum = LOCAL_ERROR_CODE_TIMEOUT;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnPhoneInfo(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}

