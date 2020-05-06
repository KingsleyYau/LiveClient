/*
 * HttpSendEmfTask.cpp
 *
 *  Created on: 2017-9-11
 *      Author: Alex
 *        desc: 13.5.发送信件
 */

#include "HttpSendEmfTask.h"

HttpSendEmfTask::HttpSendEmfTask() {
	// TODO Auto-generated constructor stub
	mPath = LETTER_SENDEMF;

}

HttpSendEmfTask::~HttpSendEmfTask() {
	// TODO Auto-generated destructor stub
}

void HttpSendEmfTask::SetCallback(IRequestSendEmfCallback* callback) {
	mpCallback = callback;
}

void HttpSendEmfTask::SetParam(
                               string anchorId,
                               string loiId,
                               string emfId,
                               string content,
                               list<string> imgList,
                               LSLetterComsumeType comsumeType,
                               string sayHiResponseId,
                               bool isSchedule,
                               string timeZoneId,
                               string startTime,
                               int duration
                                  ) {

    char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    string imgListInfo("");
    if (anchorId.length() >  0 ) {
        mHttpEntiy.AddContent(LETTER_ANCHOR_ID, anchorId.c_str());
    }
    if (loiId.length() >  0 ) {
        mHttpEntiy.AddContent(LETTER_LOI_ID, loiId.c_str());
    }
    if (emfId.length() >  0 ) {
        mHttpEntiy.AddContent(LETTER_EMF_ID, emfId.c_str());
    }
    if (content.length() >  0 ) {
        mHttpEntiy.AddContent(LETTER_CONTENT, content.c_str());
    }
    
    int tempType = LSLETTERCOMSUMETYPE_CREDIT;
    if (LSLETTERCOMSUMETYPE_BEGIN< comsumeType && comsumeType <= LSLETTERCOMSUMETYPE_END) {
        tempType = comsumeType;
    }
    snprintf(temp, sizeof(temp), "%d", tempType);
    mHttpEntiy.AddContent(LETTER_COMSUME_TYPE, temp);
    
    Json::Value imgJson;
    list<string>::const_iterator imgIter;
    for (imgIter = imgList.begin(); imgIter != imgList.end(); imgIter++) {
        Json::Value img;
        img[LETTER_IMGURL] = *imgIter;
        imgJson.append(Json::Value(img));
    }
    Json::Value attachInfoJson;
    Json::FastWriter jsonWriter;
    imgListInfo = jsonWriter.write(imgJson);
    mHttpEntiy.AddContent(LETTER_IMG_LIST, imgListInfo.c_str());
    
    if (sayHiResponseId.length() >  0 ) {
        mHttpEntiy.AddContent(LETTER_SAYHI_RESPONSEID, sayHiResponseId.c_str());
    }
    
    snprintf(temp, sizeof(temp), "%d", isSchedule == false ? 0 : 1);
    mHttpEntiy.AddContent(LETTER_IS_SCHEDULE, temp);
    
    if (isSchedule) {
        if (timeZoneId.length() >  0 ) {
            mHttpEntiy.AddContent(LETTER_TIME_ZONE_ID, timeZoneId.c_str());
        }
        
        if (startTime.length() >  0 ) {
            mHttpEntiy.AddContent(LETTER_START_TIME, startTime.c_str());
        }
        
        snprintf(temp, sizeof(temp), "%d", duration);
        mHttpEntiy.AddContent(LETTER_DURATION, temp);
    }

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpSendEmfTask::SetParam( "
            "task : %p, "
            "anchorId : %s, "
            "loiId : %s, "
            "emfId : %s, "
            "content : %s, "
            "sayHiResponseId : %s, "
            "comsumeType : %d, "
            "isSchedule : %d, "
            "timeZoneId : %s, "
            "startTime : %s, "
            "duration : %d"
            ")",
            this,
            anchorId.c_str(),
            loiId.c_str(),
            emfId.c_str(),
            content.c_str(),
            sayHiResponseId.c_str(),
            comsumeType,
            isSchedule,
            timeZoneId.c_str(),
            startTime.c_str(),
            duration
            );
}


bool HttpSendEmfTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpSendEmfTask::ParseData( "
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
    string emfId = "";
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解
        Json::Value dataJson;
        Json::Value errDataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson, &errDataJson) ) {
            if(dataJson.isObject()) {
                if (dataJson[LETTER_EMF_ID].isString()) {
                    emfId = dataJson[LETTER_EMF_ID].asString();
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
        mpCallback->OnSendEmf(this, bParse, errnum, errmsg, emfId);
    }
    
    return bParse;
}

