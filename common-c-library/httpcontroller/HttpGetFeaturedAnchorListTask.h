/*
 * HttpGetFeaturedAnchorListTask.h
 *
 *  Created on: 2019-11-12
 *      Author: Alex
 *        desc: 3.18.Featured欄目的推荐主播列表
 */

#ifndef HttpGetFeaturedAnchorListTask_H_
#define HttpGetFeaturedAnchorListTask_H_

#include "HttpRequestTask.h"

#include "item/HttpLiveRoomInfoItem.h"

class HttpGetFeaturedAnchorListTask;

class IRequestGetFeaturedAnchorListCallback {
public:
	virtual ~IRequestGetFeaturedAnchorListCallback(){};
	virtual void OnGetFeaturedAnchorList(HttpGetFeaturedAnchorListTask* task, bool success, int errnum, const string& errmsg, const HotItemList& listItem) = 0;
};

class HttpGetFeaturedAnchorListTask : public HttpRequestTask {
public:
	HttpGetFeaturedAnchorListTask();
	virtual ~HttpGetFeaturedAnchorListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetFeaturedAnchorListCallback* pCallback);

    /**
     * 
     * @param start			       起始，用于分页，表示从第几个元素开始获取
     * @param step			       步长，用于分页，表示本次请求获取多少个元素
     */
    void SetParam(
                  int start,
                  int step
                  );
    
    /**
     * 获取起始，用于分页，表示从第几个元素开始获取
     */
    int GetStart();
    /**
     * 步长，用于分页，表示本次请求获取多少个元素
     */
    int GetStep();
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetFeaturedAnchorListCallback* mpCallback;
    
    // 起始，用于分页，表示从第几个元素开始获取
    int mStart;
    // 步长，用于分页，表示本次请求获取多少个元素
    int mStep;
    
    HotItemList mItemList;
};

#endif /* HttpGetFeaturedAnchorListTask_H_ */
