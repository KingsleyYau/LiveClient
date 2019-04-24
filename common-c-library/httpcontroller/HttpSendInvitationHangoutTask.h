/*
 * HttpSendInvitationHangoutTask.h
 *
 *  Created on: 2018-4-12
 *      Author: Alex
 *        desc: 8.2.发起多人互动邀请
 */

#ifndef HttpSendInvitationHangoutTask_H_
#define HttpSendInvitationHangoutTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpSendInvitationHangoutTask;

class IRequestSendInvitationHangoutCallback {
public:
	virtual ~IRequestSendInvitationHangoutCallback(){};
	virtual void OnSendInvitationHangout(HttpSendInvitationHangoutTask* task, bool success, int errnum, const string& errmsg, const string& roomId, const string& inviteId, int expire) = 0;
};
      
class HttpSendInvitationHangoutTask : public HttpRequestTask {
public:
	HttpSendInvitationHangoutTask();
	virtual ~HttpSendInvitationHangoutTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestSendInvitationHangoutCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  const string& roomId,
                  const string& anchorId,
                  const string& recommendId,
                  bool isCreateOnly
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestSendInvitationHangoutCallback* mpCallback;
   
    string mRoomId;         // 当前发起的直播间ID
    string mAnchorId;       // 主播ID
    string mRecommendId;    // 推荐ID（可无，无则表示不是因推荐导致观众发起邀请）

};

#endif /* HttpSendInvitationHangoutTask_H_ */
