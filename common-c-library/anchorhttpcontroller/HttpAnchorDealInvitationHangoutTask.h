/*
 * HttpAnchorDealInvitationHangoutTask.h
 *
 *  Created on: 2018-4-3
 *      Author: Alex
 *        desc: 6.3.主播回复多人互动邀请
 */

#ifndef HttpAnchorDealInvitationHangoutTask_H_
#define HttpAnchorDealInvitationHangoutTask_H_

#include "ZBHttpRequestTask.h"
#include "ZBHttpLoginProtocol.h"
#include "ZBHttpRequestEnum.h"

class HttpAnchorDealInvitationHangoutTask;

class IRequestAnchorDealInvitationHangoutCallback {
public:
	virtual ~IRequestAnchorDealInvitationHangoutCallback(){};
	virtual void OnAnchorDealInvitationHangout(HttpAnchorDealInvitationHangoutTask* task, bool success, int errnum, const string& errmsg, const string& roomId) = 0;
};
      
class HttpAnchorDealInvitationHangoutTask : public ZBHttpRequestTask {
public:
	HttpAnchorDealInvitationHangoutTask();
	virtual ~HttpAnchorDealInvitationHangoutTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestAnchorDealInvitationHangoutCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    const string& inviteId,
                    AnchorMultiplayerReplyType type
                  );
    

protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestAnchorDealInvitationHangoutCallback* mpCallback;
    // 多人互动邀请ID
    string mInviteId;
    // 回复结果（ANCHORMULTIPLAYERREPLYTYPE_AGREE：接受，ANCHORMULTIPLAYERREPLYTYPE_REJECT：拒绝）
    AnchorMultiplayerReplyType mType;

};

#endif /* HttpAnchorDealInvitationHangoutTask_H */
