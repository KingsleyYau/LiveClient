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
                               string sayHiResponseId
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

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpSendEmfTask::SetParam( "
            "task : %p, "
            "anchorId : %s,"
            "loiId : %s,"
            "emfId : %s,"
            "content : %s,"
            "sayHiResponseId : %s,"
            "comsumeType : %d"
            ")",
            this,
            anchorId.c_str(),
            loiId.c_str(),
            emfId.c_str(),
            content.c_str(),
            sayHiResponseId.c_str(),
            comsumeType
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
    HttpLetterItemList list;
    bool bParse = false;
    
    if ( bFlag ) {
        // 公共解
        Json::Value dataJson;
        Json::Value errDataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson, &errDataJson) ) {
            if(dataJson.isObject()) {
                if (dataJson[LETTER_LIST].isArray()) {
                    for (int i = 0; i < dataJson[LETTER_LIST].size(); i++) {
                        HttpLetterListItem item;
                        item.Parse(dataJson[LETTER_LIST].get(i, Json::Value::null), false);
                        list.push_back(item);
                    }
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
        mpCallback->OnSendEmf(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}

