/*
 * HttpGetPrivateMsgFriendListTask.h
 *
 *  Created on: 2018-6-12
 *      Author: Alex
 *        desc: 10.1.获取私信联系人列表
 */

#ifndef HttpGetPrivateMsgFriendListTask_H_
#define HttpGetPrivateMsgFriendListTask_H_

#include "HttpRequestTask.h"
#include "item/HttpPrivateMsgContactItem.h"

class HttpGetPrivateMsgFriendListTask;

class IRequestGetPrivateMsgFriendListCallback {
public:
	virtual ~IRequestGetPrivateMsgFriendListCallback(){};
	virtual void OnGetPrivateMsgFriendList(HttpGetPrivateMsgFriendListTask* task, bool success, int errnum, const string& errmsg, const HttpPrivateMsgContactList& list, long dbtime) = 0;
};
      
class HttpGetPrivateMsgFriendListTask : public HttpRequestTask {
public:
	HttpGetPrivateMsgFriendListTask();
	virtual ~HttpGetPrivateMsgFriendListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetPrivateMsgFriendListCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetPrivateMsgFriendListCallback* mpCallback;

};

#endif /* HttpGetPrivateMsgFriendListTask_H_ */
