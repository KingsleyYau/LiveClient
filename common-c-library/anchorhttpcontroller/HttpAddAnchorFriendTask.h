/*
 * HttpAddAnchorFriendTask.h
 *
 *  Created on: 2018-5-12
 *      Author: Alex
 *        desc: 6.9.请求添加好友
 */

#ifndef HttpAddAnchorFriendTask_H_
#define HttpAddAnchorFriendTask_H_

#include "ZBHttpRequestTask.h"
#include "ZBHttpLoginProtocol.h"
#include "ZBHttpRequestEnum.h"


class HttpAddAnchorFriendTask;

class IRequestAddAnchorFriendCallback {
public:
	virtual ~IRequestAddAnchorFriendCallback(){};
	virtual void OnAddAnchorFriend(HttpAddAnchorFriendTask* task, bool success, int errnum, const string& errmsg) = 0;
};
      
class HttpAddAnchorFriendTask : public ZBHttpRequestTask {
public:
	HttpAddAnchorFriendTask();
	virtual ~HttpAddAnchorFriendTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestAddAnchorFriendCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    const string& userId
                  );
    

protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestAddAnchorFriendCallback* mpCallback;
    // 主播ID
    string mUserId;


};

#endif /* HttpAddAnchorFriendTask_H */
