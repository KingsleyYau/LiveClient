/*
 * HttpGetHangoutFriendsTask.h
 *
 *  Created on: 2019-1-21
 *      Author: Alex
 *        desc: 8.8.获取指定主播的Hang-out好友列表
 */

#ifndef HttpGetHangoutFriendsTask_H_
#define HttpGetHangoutFriendsTask_H_

#include "HttpRequestTask.h"
#include "item/HttpHangoutAnchorItem.h"

class HttpGetHangoutFriendsTask;

class IRequestGetHangoutFriendsCallback {
public:
	virtual ~IRequestGetHangoutFriendsCallback(){};
	virtual void OnGetHangoutFriends(HttpGetHangoutFriendsTask* task, bool success, int errnum, const string& errmsg, const string& anchorId, const HangoutAnchorList& list) = 0;
};
      
class HttpGetHangoutFriendsTask : public HttpRequestTask {
public:
	HttpGetHangoutFriendsTask();
	virtual ~HttpGetHangoutFriendsTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetHangoutFriendsCallback* pCallback);

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
	IRequestGetHangoutFriendsCallback* mpCallback;
    // 主播ID
    string mAnchorId;

};

#endif /* HttpGetHangoutFriendsTask_H_ */
