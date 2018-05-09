/*
 * HttpAnchorGetOngoingHangoutListTask.h
 *
 *  Created on: 2018-4-3
 *      Author: Alex
 *        desc: 6.4.获取未结束的多人互动直播间列表
 */

#ifndef HttpAnchorGetOngoingHangoutListTask_H_
#define HttpAnchorGetOngoingHangoutListTask_H_

#include "ZBHttpRequestTask.h"
#include "ZBitem/HttpAnchorHangoutItem.h"


class HttpAnchorGetOngoingHangoutListTask;

class IRequestAnchorGetOngoingHangoutListCallback {
public:
	virtual ~IRequestAnchorGetOngoingHangoutListCallback(){};
	virtual void OnAnchorGetOngoingHangoutList(HttpAnchorGetOngoingHangoutListTask* task, bool success, int errnum, const string& errmsg, const HttpAnchorHangoutItemList& hangoutList) = 0;
};
      
class HttpAnchorGetOngoingHangoutListTask : public ZBHttpRequestTask {
public:
	HttpAnchorGetOngoingHangoutListTask();
	virtual ~HttpAnchorGetOngoingHangoutListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestAnchorGetOngoingHangoutListCallback* pCallback);

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
	IRequestAnchorGetOngoingHangoutListCallback* mpCallback;
    // 起始，用于分页，表示从第几个元素开始获取
    int mStart;
    // 步长，用于分页，表示本次请求获取多少个元素
    int mStep;

};

#endif /* HttpAnchorGetOngoingHangoutListTask_H */
