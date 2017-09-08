/*
 * HttpGetInviteInfoTask.h
 *
 *  Created on: 2017-8-17
 *      Author: Alex
 *        desc: 3.9.获取指定立即私密邀请信息
 */

#ifndef HttpGetInviteInfoTask_H_
#define HttpGetInviteInfoTask_H_

#include "HttpRequestTask.h"

#include "item/HttpInviteInfoItem.h"

class HttpGetInviteInfoTask;

class IRequestGetInviteInfoCallback {
public:
	virtual ~IRequestGetInviteInfoCallback(){};
	virtual void OnGetInviteInfo(HttpGetInviteInfoTask* task, bool success, int errnum, const string& errmsg, const HttpInviteInfoItem& inviteItem) = 0;
};
      
class HttpGetInviteInfoTask : public HttpRequestTask {
public:
	HttpGetInviteInfoTask();
	virtual ~HttpGetInviteInfoTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetInviteInfoCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  const string inviteId
                  );
    
    /**
     *  邀请ID
     */
    const string& GetInviteId();
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetInviteInfoCallback* mpCallback;
    
    string mInvitationId;
    

};

#endif /* HttpGetInviteInfoTask_H_ */
