/*
 * ZBHttpCrashFileTask.cpp
 *
 *  Created on: 2018-03-01
 *      Author: Alex
 *        desc: 5.4.提交crash dump文件（仅独立）
 */

#include "ZBHttpCrashFileTask.h"
#include <common/CommonFunc.h>
#include "common/md5.h"

ZBHttpCrashFileTask::ZBHttpCrashFileTask() {
    // TODO Auto-generated constructor stub
    mPath = UPLOADCRASHDUMP_PATH;
    mDeviceId = "";
    mCrashFile = "";
   
}

ZBHttpCrashFileTask::~ZBHttpCrashFileTask() {
    // TODO Auto-generated destructor stub
}

void ZBHttpCrashFileTask::SetCallback(IRequestZBCrashFileCallback* callback) {
    mpCallback = callback;
}

void ZBHttpCrashFileTask::SetParam(
                                 string deviceId,
                                 string crashFile
                                   ) {
    
    //	char temp[16];
    mHttpEntiy.Reset();
    mHttpEntiy.SetSaveCookie(true);
    
    if( deviceId.length() > 0 ) {
        mHttpEntiy.AddContent(UPLOADCRASHDUMP_DEVICEID, deviceId.c_str());
        mDeviceId = deviceId;
    }

    if( crashFile.length() > 0 ) {
       mHttpEntiy.AddFile(UPLOADCRASHDUMP_CRASHFILE, crashFile.c_str(), "application/x-zip-compressed");
        mCrashFile = crashFile;
        mHttpEntiy.SetConnectTimeout(60);
    }
    
	FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpCrashFileTask::SetParam( "
            "task : %p, "
            "deviceId : %s "
            "crashFile : %s "
            ")",
            this,
            deviceId.c_str(),
            crashFile.c_str()
            );
}


bool ZBHttpCrashFileTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpCrashFileTask::ParseData( "
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
        errnum = ZBHTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
        
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnZBCrashFile(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}
