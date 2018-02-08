/*
 * HttpCrashFileTask.cpp
 *
 *  Created on: 2018-01-11
 *      Author: Alex
 *        desc: 6.16.提交crash dump文件（仅独立）
 */

#include "HttpCrashFileTask.h"
#include <common/CommonFunc.h>
#include "common/md5.h"

HttpCrashFileTask::HttpCrashFileTask() {
    // TODO Auto-generated constructor stub
    mPath = LIVEROOM_CRASHFILE;
    mDeviceId = "";
    mCrashFile = "";
   
}

HttpCrashFileTask::~HttpCrashFileTask() {
    // TODO Auto-generated destructor stub
}

void HttpCrashFileTask::SetCallback(IRequestCrashFileCallback* callback) {
    mpCallback = callback;
}

void HttpCrashFileTask::SetParam(
                                 string deviceId,
                                 string crashFile
                                   ) {
    
    //	char temp[16];
    mHttpEntiy.Reset();
    mHttpEntiy.SetSaveCookie(true);
    
    if( deviceId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_CRASHFILE_DEVICEID, deviceId.c_str());
        mDeviceId = deviceId;
    }

    if( crashFile.length() > 0 ) {
       mHttpEntiy.AddFile(LIVEROOM_CRASHFILE_CRASHFILE, crashFile.c_str(), "application/x-zip-compressed");
        mCrashFile = crashFile;
        mHttpEntiy.SetConnectTimeout(60);
    }
    
	FileLog(LIVESHOW_HTTP_LOG,
            "HttpCrashFileTask::SetParam( "
            "task : %p, "
            "deviceId : %s "
            "crashFile : %s "
            ")",
            this,
            deviceId.c_str(),
            crashFile.c_str()
            );
}


bool HttpCrashFileTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpCrashFileTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpCrashFileTask      ::ParseData( buf : %s )", buf);
    }
    
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
        mpCallback->OnCrashFile(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}
