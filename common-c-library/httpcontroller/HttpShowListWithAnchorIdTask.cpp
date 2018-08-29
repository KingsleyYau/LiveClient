/*
 * HttpShowListWithAnchorIdTask.cpp
 *
 *  Created on: 2018-4-27
 *      Author: Alex
 *        desc: 9.6.获取节目推荐列表
 */

#include "HttpShowListWithAnchorIdTask.h"

HttpShowListWithAnchorIdTask::HttpShowListWithAnchorIdTask() {
	// TODO Auto-generated constructor stub
	mPath = SHOWLISTWITHANCHORID_PATH;
    mAnchorId = "";
    mStart = 0;
    mStep = 0;
    mSortType = SHOWRECOMMENDLISTTYPE_UNKNOW;
}

HttpShowListWithAnchorIdTask::~HttpShowListWithAnchorIdTask() {
	// TODO Auto-generated destructor stub
}

void HttpShowListWithAnchorIdTask::SetCallback(IRequestShowListWithAnchorIdTCallback* callback) {
	mpCallback = callback;
}

void HttpShowListWithAnchorIdTask::SetParam(
                                            const string& anchorId,
                                            int start,
                                            int step,
                                            ShowRecommendListType sortType
                                          ) {

	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    char temp[16];
    
    if (anchorId.length() > 0) {
        mHttpEntiy.AddContent(SHOWLISTWITHANCHORID_ANCHORID, anchorId.c_str());
        mAnchorId = anchorId;
    }
    
    if (sortType > SHOWRECOMMENDLISTTYPE_UNKNOW && sortType <= SHOWRECOMMENDLISTTYPE_NOHOSTRECOMMEND) {
        snprintf(temp, sizeof(temp), "%d", sortType);
        mHttpEntiy.AddContent(SHOWLISTWITHANCHORID_SORTTYPE, temp);
        mSortType = sortType;
    }
    
    snprintf(temp, sizeof(temp), "%d", start);
    mHttpEntiy.AddContent(SHOWLISTWITHANCHORID_START, temp);
    mStart = start;
    
    snprintf(temp, sizeof(temp), "%d", step);
    mHttpEntiy.AddContent(SHOWLISTWITHANCHORID_STEP, temp);
    mStep = step;
    

    FileLog(LIVESHOW_HTTP_LOG,
            "HttpShowListWithAnchorIdTask::SetParam( "
            "task : %p, "
            "sortType : %d ,"
            "start : %d ,"
            "step : %d ,"
            "anchorId :%s"
            ")",
            this,
            sortType,
            start,
            step,
            anchorId.c_str()
            );
}

bool HttpShowListWithAnchorIdTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpShowListWithAnchorIdTask::ParseData( "
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
    ProgramInfoList list;
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            bParse = true;
            if (dataJson[SHOWLISTWITHANCHORI_LIST].isArray()) {
                int i = 0;
                for (i = 0; i < dataJson[SHOWLISTWITHANCHORI_LIST].size(); i++) {
                    HttpProgramInfoItem item;
                    item.Parse(dataJson[SHOWLISTWITHANCHORI_LIST].get(i, Json::Value::null));
                    list.push_back(item);
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
        mpCallback->OnShowListWithAnchorId(this, bParse, errnum, errmsg, list);
    }
    
    return bParse;
}

