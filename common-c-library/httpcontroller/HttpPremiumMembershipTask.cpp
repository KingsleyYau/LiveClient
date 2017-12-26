/*
 * HttpPremiumMembershipTask.cpp
 *
 *  Created on: 2017-12-23
 *      Author: Alex
 *        desc: 7.1.获取买点信息（仅独立）（仅iOS）
 */

#include "HttpPremiumMembershipTask.h"
#include <common/CommonFunc.h>
#include "common/md5.h"

HttpPremiumMembershipTask::HttpPremiumMembershipTask() {
    // TODO Auto-generated constructor stub
    mPath = LIVEROOM_PREMIUM_MEMBERSHIP;
    mSiteId = "";
   
}

HttpPremiumMembershipTask::~HttpPremiumMembershipTask() {
    // TODO Auto-generated destructor stub
}

void HttpPremiumMembershipTask::SetCallback(IRequestPremiumMembershipCallback* callback) {
    mpCallback = callback;
}

void HttpPremiumMembershipTask::SetParam(
                                   string siteId
                                   ) {
    
    //	char temp[16];
    mHttpEntiy.Reset();
    mHttpEntiy.SetSaveCookie(true);

    if( siteId.length() > 0 ) {
        mHttpEntiy.AddContent(LIVEROOM_PREMIUM_MEMBERSHIP_SITEID, siteId.c_str());
        mSiteId = siteId;
    }
    
	FileLog(LIVESHOW_HTTP_LOG,
            "HttpPremiumMembershipTask::SetParam( "
            "task : %p, "
            "siteId : %s "
            ")",
            this,
            siteId.c_str()
            );
}


bool HttpPremiumMembershipTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "HttpPremiumMembershipTask::ParseData( "
            "task : %p, "
            "url : %s, "
            "bFlag : %s "
            ")",
            this,
            url.c_str(),
            bFlag?"true":"false"
            );
    
    if ( bFlag && size < MAX_LOG_BUFFER ) {
        FileLog(LIVESHOW_HTTP_LOG, "HttpPremiumMembershipTask::ParseData( buf : %s )", buf);
    }
    
    int errnum = LOCAL_LIVE_ERROR_CODE_FAIL;
    string errmsg = "";
    bool bParse = false;
    HttpOrderProductItem item;
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {
            item.Parse(dataJson);
        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
        // LSalextest
        if (bParse == false) {
            errnum = LOCAL_LIVE_ERROR_CODE_SUCCESS;
            errmsg = "";
            item.title = "alextestTitel";
            item.subtitle = "alextestSubtitle";
            HttpProductItem itemProduct;
            itemProduct.productId = "alextest123";
            itemProduct.name = "alextestname";
            itemProduct.price = "alextestPrice";
            item.list.push_back(itemProduct);
            item.desc = "alextestDesc";
            item.more = "alextestmore";
            
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
        mpCallback->OnPremiumMembership(this, bParse, errnum, errmsg, item);
    }
    
    return bParse;
}
