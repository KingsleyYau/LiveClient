/*
 * HttpAnchorGetCanRecommendFriendListTask.h
 *
 *  Created on: 2018-4-3
 *      Author: Alex
 *        desc: 6.1.获取可推荐的好友列表
 */

#ifndef HttpAnchorGetCanRecommendFriendListTask_H_
#define HttpAnchorGetCanRecommendFriendListTask_H_

#include "ZBHttpRequestTask.h"
#include "ZBitem/HttpAnchorItem.h"

class HttpAnchorGetCanRecommendFriendListTask;

class IRequestAnchorGetCanRecommendFriendListCallback {
public:
	virtual ~IRequestAnchorGetCanRecommendFriendListCallback(){};
	virtual void OnAnchorGetCanRecommendFriendList(HttpAnchorGetCanRecommendFriendListTask* task, bool success, int errnum, const string& errmsg, const HttpAnchorItemList& anchorList) = 0;
};
      
class HttpAnchorGetCanRecommendFriendListTask : public ZBHttpRequestTask {
public:
	HttpAnchorGetCanRecommendFriendListTask();
	virtual ~HttpAnchorGetCanRecommendFriendListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestAnchorGetCanRecommendFriendListCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    int start,
                    int step
                  );
    

protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestAnchorGetCanRecommendFriendListCallback* mpCallback;
    // 起始，用于分页，表示从第几个元素开始获取
    int mStart;
    // 步长，用于分页，表示本次请求获取多少个元素
    int mStep;

};

#endif /* HttpAnchorGetCanRecommendFriendListTask */
