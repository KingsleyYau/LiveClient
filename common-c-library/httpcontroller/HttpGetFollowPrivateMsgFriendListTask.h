/*
 * HttpGetFollowPrivateMsgFriendListTask.h
 *
 *  Created on: 2018-6-12
 *      Author: Alex
 *        desc: 10.2.获取私信Follow联系人列表
 */

#ifndef HttpGetFollowPrivateMsgFriendListTask_H_
#define HttpGetFollowPrivateMsgFriendListTask_H_

#include "HttpRequestTask.h"
#include "item/HttpPrivateMsgContactItem.h"

class HttpGetFollowPrivateMsgFriendListTask;

class IRequestGetFollowPrivateMsgFriendListCallback {
public:
	virtual ~IRequestGetFollowPrivateMsgFriendListCallback(){};
	virtual void OnGetFollowPrivateMsgFriendList(HttpGetFollowPrivateMsgFriendListTask* task, bool success, int errnum, const string& errmsg, const HttpPrivateMsgContactList& list) = 0;
};
      
class HttpGetFollowPrivateMsgFriendListTask : public HttpRequestTask {
public:
	HttpGetFollowPrivateMsgFriendListTask();
	virtual ~HttpGetFollowPrivateMsgFriendListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetFollowPrivateMsgFriendListCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetFollowPrivateMsgFriendListCallback* mpCallback;

};

#endif /* HttpGetFollowPrivateMsgFriendListTask_H_ */
