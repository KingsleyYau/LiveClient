/*
 * HttpAutoInvitationHangoutLiveDisplayTask.h
 *
 *  Created on: 2019-1-22
 *      Author: Alex
 *        desc: 8.9.自动邀请Hangout直播邀請展示條件
 */

#ifndef HttpAutoInvitationHangoutLiveDisplayTask_H_
#define HttpAutoInvitationHangoutLiveDisplayTask_H_

#include "HttpRequestTask.h"
#include "item/HttpHangoutAnchorItem.h"

class HttpAutoInvitationHangoutLiveDisplayTask;

class IRequestAutoInvitationHangoutLiveDisplayCallback {
public:
	virtual ~IRequestAutoInvitationHangoutLiveDisplayCallback(){};
	virtual void OnAutoInvitationHangoutLiveDisplay(HttpAutoInvitationHangoutLiveDisplayTask* task, bool success, int errnum, const string& errmsg) = 0;
};
      
class HttpAutoInvitationHangoutLiveDisplayTask : public HttpRequestTask {
public:
	HttpAutoInvitationHangoutLiveDisplayTask();
	virtual ~HttpAutoInvitationHangoutLiveDisplayTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestAutoInvitationHangoutLiveDisplayCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  const string& anchorId
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestAutoInvitationHangoutLiveDisplayCallback* mpCallback;

};

#endif /* HttpAutoInvitationHangoutLiveDisplayTask_H_ */
