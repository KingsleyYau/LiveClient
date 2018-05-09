/*
 * HttpAnchorGetProgramListTask.h
 *
 *  Created on: 2018-4-24
 *      Author: Alex
 *        desc: 7.1.获取节目列表
 */

#ifndef HttpAnchorGetProgramListTask_H_
#define HttpAnchorGetProgramListTask_H_

#include "ZBHttpRequestTask.h"
#include "ZBitem/HttpAnchorProgramInfoItem.h"


class HttpAnchorGetProgramListTask;

class IRequestAnchorGetProgramListCallback {
public:
	virtual ~IRequestAnchorGetProgramListCallback(){};
	virtual void OnAnchorGetProgramList(HttpAnchorGetProgramListTask* task, bool success, int errnum, const string& errmsg, const AnchorProgramInfoList& list) = 0;
};
      
class HttpAnchorGetProgramListTask : public ZBHttpRequestTask {
public:
	HttpAnchorGetProgramListTask();
	virtual ~HttpAnchorGetProgramListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestAnchorGetProgramListCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  int start,
                  int step,
                  AnchorProgramListType status
                  );
    

protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestAnchorGetProgramListCallback* mpCallback;
    // 起始，用于分页，表示从第几个元素开始获取
    int mStart;
    // 步长，用于分页，表示本次请求获取多少个元素
    int mStep;
    // 列表类型（ANCHORPROGRAMLISTTYPE_UNVERIFY：待审核，ANCHORPROGRAMLISTTYPE_VERIFYPASS：已通过审核且未开播，ANCHORPROGRAMLISTTYPE_VERIFYREJECT：被拒绝，ANCHORPROGRAMLISTTYPE_HISTORY：历史）
    AnchorProgramListType mStatus;


};

#endif /* HttpAnchorGetPragramListTask_H */
