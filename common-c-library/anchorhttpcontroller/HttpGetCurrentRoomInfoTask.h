/*
 * HttpGetCurrentRoomInfoTask.h
 *
 *  Created on: 2019-11-07
 *      Author: Alex
 *        desc: 3.9.获取主播当前直播间信息
 */

#ifndef HttpGetCurrentRoomInfoTask_H_
#define HttpGetCurrentRoomInfoTask_H_

#include "ZBHttpRequestTask.h"
#include "ZBitem/ZBHttpCurrentRoomItem.h"


class HttpGetCurrentRoomInfoTask;

class IRequestGetCurrentRoomInfoCallback {
public:
	virtual ~IRequestGetCurrentRoomInfoCallback(){};
	virtual void OnGetCurrentRoomInfo(HttpGetCurrentRoomInfoTask* task, bool success, int errnum, const string& errmsg, ZBHttpCurrentRoomItem roomItem) = 0;
};
      
class HttpGetCurrentRoomInfoTask : public ZBHttpRequestTask {
public:
	HttpGetCurrentRoomInfoTask();
	virtual ~HttpGetCurrentRoomInfoTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetCurrentRoomInfoCallback* pCallback);

    /**
     *
     */
    void SetParam(
                  );
    

protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetCurrentRoomInfoCallback* mpCallback;


};

#endif /* HttpGetCurrentRoomInfoTask_H */
