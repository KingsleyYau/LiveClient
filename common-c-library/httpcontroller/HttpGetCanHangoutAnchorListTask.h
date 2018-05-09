/*
 * HttpGetCanHangoutAnchorListTask.h
 *
 *  Created on: 2018-4-12
 *      Author: Alex
 *        desc: 8.1.获取可邀请多人互动的主播列表
 */

#ifndef HttpGetCanHangoutAnchorListTask_H_
#define HttpGetCanHangoutAnchorListTask_H_

#include "HttpRequestTask.h"
#include "item/HttpHangoutAnchorItem.h"

class HttpGetCanHangoutAnchorListTask;

class IRequestGetCanHangoutAnchorListCallback {
public:
	virtual ~IRequestGetCanHangoutAnchorListCallback(){};
	virtual void OnGetCanHangoutAnchorList(HttpGetCanHangoutAnchorListTask* task, bool success, int errnum, const string& errmsg, const HangoutAnchorList& list) = 0;
};
      
class HttpGetCanHangoutAnchorListTask : public HttpRequestTask {
public:
	HttpGetCanHangoutAnchorListTask();
	virtual ~HttpGetCanHangoutAnchorListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetCanHangoutAnchorListCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  HangoutAnchorListType type,
                  const string& anchorId,
                  int start,
                  int step
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetCanHangoutAnchorListCallback* mpCallback;
   
    HangoutAnchorListType mType;        // 列表类型（1：已关注，2：Watched，3：主播好友）
    string mAnchorId;                   // 主播ID（可无，仅当type=3才存在）
    int    mStart;                      // 起始，用于分页，表示从第几个元素开始获取
    int    mStep;                       // 步长，用于分页，表示本次请求获取多少个元素

};

#endif /* HttpGetCanHangoutAnchorListTask_H_ */
