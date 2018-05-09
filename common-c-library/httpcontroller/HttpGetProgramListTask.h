/*
 * HttpGetProgramListTask.h
 *
 *  Created on: 2018-4-18
 *      Author: Alex
 *        desc: 9.2.获取节目列表
 */

#ifndef HttpGetProgramListTask_H_
#define HttpGetProgramListTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"
#include "item/HttpProgramInfoItem.h"


class HttpGetProgramListTask;

class IRequestGetProgramListCallback {
public:
	virtual ~IRequestGetProgramListCallback(){};
	virtual void OnGetProgramList(HttpGetProgramListTask* task, bool success, int errnum, const string& errmsg, const ProgramInfoList& list) = 0;
};
      
class HttpGetProgramListTask : public HttpRequestTask {
public:
	HttpGetProgramListTask();
	virtual ~HttpGetProgramListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetProgramListCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  ProgramListType sortType,
                  int start,
                  int step
                  );
    

protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetProgramListCallback* mpCallback;
    int mStart;                         // 起始，用于分页，表示从第几个元素开始获取
    int mStep;                          // 步长，用于分页，表示本次请求获取多少个元素
    ProgramListType mSortType;           // 列表类型（1：按节目开始时间排序，2：按节目审核时间排序，3：按广告排序，4：直播间结束推荐列表，5：主播个人项目推荐，6：已购票列表）

};

#endif /* HttpGetProgramListTask_H */
