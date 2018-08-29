/*
 * HttpGetFriendRelationTask.h
 *
 *  Created on: 2018-5-12
 *      Author: Alex
 *        desc: 6.10.获取好友关系信息
 */

#ifndef HttpGetFriendRelationTask_H_
#define HttpGetFriendRelationTask_H_

#include "ZBHttpRequestTask.h"
#include "ZBitem/HttpAnchorFriendItem.h"


class HttpGetFriendRelationTask;

class IRequestGetFriendRelationCallback {
public:
	virtual ~IRequestGetFriendRelationCallback(){};
	virtual void OnGetFriendRelation(HttpGetFriendRelationTask* task, bool success, int errnum, const string& errmsg, const HttpAnchorFriendItem& item) = 0;
};
      
class HttpGetFriendRelationTask : public ZBHttpRequestTask {
public:
	HttpGetFriendRelationTask();
	virtual ~HttpGetFriendRelationTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetFriendRelationCallback* pCallback);

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
	IRequestGetFriendRelationCallback* mpCallback;
    // 主播ID
    string mAnchorId;


};

#endif /* HttpGetFriendRelationTask_H */
