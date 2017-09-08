/*
 * HttpGetTalentStatusTask.h
 *
 *  Created on: 2017-8-29
 *      Author: Alex
 *        desc: 3.11.获取才艺点播邀请状态
 */

#ifndef HttpGetTalentStatusTask_H_
#define HttpGetTalentStatusTask_H_

#include "HttpRequestTask.h"
#include "item/HttpGetTalentStatusItem.h"

class HttpGetTalentStatusTask;

class IRequestGetTalentStatusCallback {
public:
	virtual ~IRequestGetTalentStatusCallback(){};
	virtual void OnGetTalentStatus(HttpGetTalentStatusTask* task, bool success, int errnum, const string& errmsg, const HttpGetTalentStatusItem& item) = 0;
};
      
class HttpGetTalentStatusTask : public HttpRequestTask {
public:
	HttpGetTalentStatusTask();
	virtual ~HttpGetTalentStatusTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetTalentStatusCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  const string roomId,
                  const string talentInviteId
                  );
    
    /**
     *  直播间ID
     */
    const string& GetRoomId();
    
    /*
     * 才艺点播邀请ID
     */
    const string& TalentInviteId();
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetTalentStatusCallback* mpCallback;
    
    // 直播间ID
    string mRoomId;
    // 才艺点播邀请ID
    string mTalentInviteId;

};

#endif /* HttpGetTalentStatusTask_H_ */
