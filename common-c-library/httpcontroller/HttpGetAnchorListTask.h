/*
 * HttpGetAnchorListTask.h
 *
 *  Created on: 2017-8-16
 *      Author: Alex
 *        desc: 3.1.获取Hot列表
 */

#ifndef HttpGetAnchorListTask_H_
#define HttpGetAnchorListTask_H_

#include "HttpRequestTask.h"

#include "item/HttpLiveRoomInfoItem.h"

class HttpGetAnchorListTask;

class IRequestGetAnchorListCallback {
public:
	virtual ~IRequestGetAnchorListCallback(){};
	virtual void OnGetAnchorList(HttpGetAnchorListTask* task, bool success, int errnum, const string& errmsg, const HotItemList& listItem) = 0;
};

class HttpGetAnchorListTask : public HttpRequestTask {
public:
	HttpGetAnchorListTask();
	virtual ~HttpGetAnchorListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetAnchorListCallback* pCallback);

    /**
     * 
     * @param start			       起始，用于分页，表示从第几个元素开始获取
     * @param step			       步长，用于分页，表示本次请求获取多少个元素
     * @param hasWatch			   是否只获取观众看过的主播（0: 否 1: 是  可无，无则默认为0）
     * @param isForTest            是否可看到测试主播（0：否，1：是）（整型）（可无，无则默认为0）
     */
    void SetParam(
                  int start,
                  int step,
                  bool hasWatch,
                  bool isForTest
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
	IRequestGetAnchorListCallback* mpCallback;
    
    // 起始，用于分页，表示从第几个元素开始获取
    int mStart;
    // 步长，用于分页，表示本次请求获取多少个元素
    int mStep;
    // 是否只获取观众看过的主播（0: 否 1: 是  可无，无则默认为0）
    bool mHasWatch;
    // 是否可看到测试主播（0：否，1：是）（整型）（可无，无则默认为0）
    bool mIsForTest;
    
    HotItemList mItemList;
};

#endif /* HttpGetAnchorListTask_H_ */
