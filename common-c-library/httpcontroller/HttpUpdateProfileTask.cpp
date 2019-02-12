/*
 * HttpUpdateProfileTask.cpp
 *
 *  Created on: 2018-9-18
 *      Author: Alex
 *        desc: 10.4.标记私信已读
 */

#include "HttpUpdateProfileTask.h"

HttpUpdateProfileTask::HttpUpdateProfileTask() {
	// TODO Auto-generated constructor stub
	mPath = LIVEROOM_UPDATEPRO;
    

}

HttpUpdateProfileTask::~HttpUpdateProfileTask() {
	// TODO Auto-generated destructor stub
}

void HttpUpdateProfileTask::SetCallback(IRequestUpdateProfileCallback* callback) {
	mpCallback = callback;
}

void HttpUpdateProfileTask::SetParam(
                                     int weight,
                                     int height,
                                     int language,
                                     int ethnicity,
                                     int religion,
                                     int education,
                                     int profession,
                                     int income,
                                     int children,
                                     int smoke,
                                     int drink,
                                     const string resume,
                                     list<string> interests,
                                     int zodiac
                                      ) {
    char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    
    if( weight > -1 ) {
        sprintf(temp, "%d", CodeToWeight(weight));
        mHttpEntiy.AddContent(LIVEROOM_MYPROFILE_WEIGHT, temp);
    }
    
    if( height > -1 ) {
        sprintf(temp, "%d", CodeToHeight(height));
        mHttpEntiy.AddContent(LIVEROOM_MYPROFILE_HEIGHT, temp);
    }
    
    if( language > -1 ) {
        sprintf(temp, "%d", language);
        mHttpEntiy.AddContent(LIVEROOM_MYPROFILE_LANGUAGE, temp);
    }
    
    if( ethnicity > -1 ) {
        sprintf(temp, "%d", CodeToEthnicity(ethnicity));
        mHttpEntiy.AddContent(LIVEROOM_MYPROFILE_ETHNICITY, temp);
    }
    
    if( religion > -1 ) {
        sprintf(temp, "%d", religion);
        mHttpEntiy.AddContent(LIVEROOM_MYPROFILE_RELIGION, temp);
    }
    
    if( education > -1 ) {
        sprintf(temp, "%d", education);
        mHttpEntiy.AddContent(LIVEROOM_MYPROFILE_EDUCATION, temp);
    }
    
    if( profession > -1 ) {
        sprintf(temp, "%d", profession);
        mHttpEntiy.AddContent(LIVEROOM_MYPROFILE_PROFESSION, temp);
    }
    
    if( children > -1 ) {
        sprintf(temp, "%d", children);
        mHttpEntiy.AddContent(LIVEROOM_MYPROFILE_CHILDREN, temp);
    }
    
    if( smoke > -1 ) {
        sprintf(temp, "%d", smoke);
        mHttpEntiy.AddContent(LIVEROOM_MYPROFILE_SMOKE, temp);
    }
    
    if( drink > -1 ) {
        sprintf(temp, "%d", drink);
        mHttpEntiy.AddContent(LIVEROOM_MYPROFILE_DRINK, temp);
    }
    
    if (income > -1) {
        sprintf(temp, "%d", income);
        mHttpEntiy.AddContent(LIVEROOM_MYPROFILE_INCOME, temp);
    }
    
    if( resume.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_MYPROFILE_JJ, resume.c_str());
    }
    
    if(zodiac > -1 ) {
        sprintf(temp, "%d", zodiac);
        mHttpEntiy.AddContent(LIVEROOM_MYPROFILE_ZODIAC, temp);
    }
    
    string interestString = "";
    for(list<string>::iterator itr = interests.begin(); itr != interests.end(); itr++) {
        interestString += *itr;
        interestString += ",";
    }
    
    if( interestString.length() > 0 ) {
        interestString = interestString.substr(0, interestString.length() - 1);
        mHttpEntiy.AddContent(LIVEROOM_MYPROFILE_INTERESTS, interestString.c_str());
    }else
    {
        mHttpEntiy.AddContent(LIVEROOM_MYPROFILE_INTERESTS, interestString.c_str());
    }

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpModifyProfileTask::SetParam( "
            "task : %p, "
            "weight : %d, "
            "height : %d, "
            "language : %d, "
            "ethnicity : %d, "
            "religion : %d, "
            "education : %d, "
            "profession : %d, "
            "income : %d, "
            "children : %d, "
            "smoke : %d, "
            "drink : %d, "
            "resume : %s, "
            "interestString : %s, "
            "zodiac :%d"
            ")",
            this,
            weight,
            height,
            language,
            ethnicity,
            religion,
            education,
            profession,
            income,
            children,
            smoke,
            drink,
            resume.c_str(),
            interestString.c_str(),
            zodiac
            );
}



bool HttpUpdateProfileTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpModifyProfileTask::ParseData( "
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
    bool result = false;
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        bParse = ParseCommon(buf, size, errnum, errmsg, &dataJson);
        if( bParse ) {
            if (dataJson.isObject()) {
                if (dataJson[LIVEROOM_UPDATEPRO_JJRESULT].isNumeric()) {
                    result = dataJson[LIVEROOM_UPDATEPRO_JJRESULT].asInt() == -1 ? false : true;
                }
            }
        }
        
        //bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        
    } else {
        // 超时
        errnum = LOCAL_ERROR_CODE_TIMEOUT;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnUpdateProfile(this, bParse, errnum, errmsg, result);
    }
    
    return bParse;
}

