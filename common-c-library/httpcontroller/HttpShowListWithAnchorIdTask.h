/*
 * HttpShowListWithAnchorIdTask.h
 *
 *  Created on: 2018-4-27
 *      Author: Alex
 *        desc: 9.6.获取节目推荐列表
 */

#ifndef HttpShowListWithAnchorIdTask_H_
#define HttpShowListWithAnchorIdTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"
#include "item/HttpProgramInfoItem.h"


class HttpShowListWithAnchorIdTask;

class IRequestShowListWithAnchorIdTCallback {
public:
	virtual ~IRequestShowListWithAnchorIdTCallback(){};
	virtual void OnShowListWithAnchorId(HttpShowListWithAnchorIdTask* task, bool success, int errnum, const string& errmsg, const ProgramInfoList& list) = 0;
};
      
class HttpShowListWithAnchorIdTask : public HttpRequestTask {
public:
	HttpShowListWithAnchorIdTask();
	virtual ~HttpShowListWithAnchorIdTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestShowListWithAnchorIdTCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  const string& anchorId,
                  int start,
                  int step,
                  ShowRecommendListType sortType
                  );
    

protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestShowListWithAnchorIdTCallback* mpCallback;
    string mAnchorId;
    int mStart;                         // 起始，用于分页，表示从第几个元素开始获取
    int mStep;                          // 步长，用于分页，表示本次请求获取多少个元素
    ShowRecommendListType mSortType;    // 列表类型（1：直播结束推荐<包括指定主播及其它主播>，2：主播个人节目推荐<仅包括指定主播>，3：不包括指定主播）

};

#endif /* HttpShowListWithAnchorIdTask_H */
