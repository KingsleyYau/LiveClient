/*
 *  ZBHttpDealTalentRequestTask.cpp
 *
 *  Created on: 2018-2-28
 *      Author: Alex
 *        desc: 3.7.主播回复才艺点播邀请（用于主播接受/拒绝观众发出的才艺点播邀请）
 */

#include "ZBHttpDealTalentRequestTask.h"

ZBHttpDealTalentRequestTask::ZBHttpDealTalentRequestTask() {
	// TODO Auto-generated constructor stub
	mPath = DEALTALENTREQUEST_PATH;

    mTalentInviteId = "";
    mStatus = ZBTALENTREPLYTYPE_UNKNOWN;
}

ZBHttpDealTalentRequestTask::~ZBHttpDealTalentRequestTask() {
	// TODO Auto-generated destructor stub
}

void ZBHttpDealTalentRequestTask::SetCallback(IRequestZBDealTalentRequestCallback* callback) {
	mpCallback = callback;
}

void ZBHttpDealTalentRequestTask::SetParam(
                                           const string talentInviteId,
                                           ZBTalentReplyType status
                                     ) {

//	char temp[16];
	mHttpEntiy.Reset();
	mHttpEntiy.SetSaveCookie(true);
    
    if( talentInviteId.length() > 0 ) {
        mHttpEntiy.AddContent(DEALTALENTREQUEST_TALENTINVITEID, talentInviteId.c_str());
        mTalentInviteId = talentInviteId;
    }
    
    if (status > ZBTALENTREPLYTYPE_UNKNOWN && status <= ZBTALENTREPLYTYPE_REJECT) {
        char temp[16];
        snprintf(temp, sizeof(temp), "%d", status == ZBTALENTREPLYTYPE_AGREE ? 1 : 2);
        mHttpEntiy.AddContent(DEALTALENTREQUEST_STATU, temp);
        mStatus = status;
    }

    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpDealTalentRequestTask::SetParam( "
            "task : %p, "
            "talentInviteId : %s, "
            "status: %d"
            ")",
            this,
            talentInviteId.c_str(),
            status
            );
}


bool ZBHttpDealTalentRequestTask::ParseData(const string& url, bool bFlag, const char* buf, int size) {
    FileLog(LIVESHOW_HTTP_LOG,
            "ZBHttpDealTalentRequestTask::ParseData( "
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
    
    bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
    
    if ( bFlag ) {
        // 公共解析
        Json::Value dataJson;
        if( ParseLiveCommon(buf, size, errnum, errmsg, &dataJson) ) {

        }
        bParse = (errnum == LOCAL_LIVE_ERROR_CODE_SUCCESS ? true : false);
        
    } else {
        // 超时
        errnum = ZBHTTP_LCC_ERR_CONNECTFAIL;
        errmsg = LOCAL_ERROR_CODE_TIMEOUT_DESC;
    }
    
    if( mpCallback != NULL ) {
        mpCallback->OnZBDealTalentRequest(this, bParse, errnum, errmsg);
    }
    
    return bParse;
}
