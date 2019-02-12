/*
 * HttpGetHangoutOnlineAnchorTask.h
 *
 *  Created on: 2019-1-18
 *      Author: Alex
 *        desc: 8.7.获取Hang-out在线主播列表
 */

#ifndef HttpGetHangoutOnlineAnchorTask_H_
#define HttpGetHangoutOnlineAnchorTask_H_

#include "HttpRequestTask.h"
#include "item/HttpHangoutListItem.h"

class HttpGetHangoutOnlineAnchorTask;

class IRequestGetHangoutOnlineAnchorCallback {
public:
	virtual ~IRequestGetHangoutOnlineAnchorCallback(){};
	virtual void OnGetHangoutOnlineAnchor(HttpGetHangoutOnlineAnchorTask* task, bool success, int errnum, const string& errmsg, const HttpHangoutList& list) = 0;
};
      
class HttpGetHangoutOnlineAnchorTask : public HttpRequestTask {
public:
	HttpGetHangoutOnlineAnchorTask();
	virtual ~HttpGetHangoutOnlineAnchorTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetHangoutOnlineAnchorCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetHangoutOnlineAnchorCallback* mpCallback;

};

#endif /* HttpGetHangoutOnlineAnchorTask_H_ */
