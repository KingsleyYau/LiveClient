/*
 * HttpGetLiveEndRecommendAnchorListTask.h
 *
 *  Created on: 2019-6-11
 *      Author: Alex
 *        desc: 3.15.获取页面推荐的主播列表
 */

#ifndef HttpGetLiveEndRecommendAnchorListTask_H_
#define HttpGetLiveEndRecommendAnchorListTask_H_

#include "HttpRequestTask.h"
#include "item/HttpRecommendAnchorItem.h"

class HttpGetLiveEndRecommendAnchorListTask;

class IRequestGetLiveEndRecommendAnchorListCallback {
public:
	virtual ~IRequestGetLiveEndRecommendAnchorListCallback(){};
	virtual void OnGetLiveEndRecommendAnchorList(HttpGetLiveEndRecommendAnchorListTask* task, bool success, int errnum, const string& errmsg, const RecommendAnchorList& listItem) = 0;
};
      
class HttpGetLiveEndRecommendAnchorListTask : public HttpRequestTask {
public:
	HttpGetLiveEndRecommendAnchorListTask();
	virtual ~HttpGetLiveEndRecommendAnchorListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetLiveEndRecommendAnchorListCallback* pCallback);

    /**
     *
     */
    void SetParam(

                  );
    
    int GetNumber();
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetLiveEndRecommendAnchorListCallback* mpCallback;

};

#endif /* HttpGetLiveEndRecommendAnchorListTask_H_ */
