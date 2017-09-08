/*
 * HttpGetRoomInfoTask.h
 *
 *  Created on: 2017-8-17
 *      Author: Alex
 *        desc: 3.3.获取本人有效直播间或邀请信息(已废弃)
 */

#ifndef HttpGetRoomInfoTask_H_
#define HttpGetRoomInfoTask_H_

#include "HttpRequestTask.h"
#include "item/HttpGetRoomInfoItem.h"

class HttpGetRoomInfoTask;

class IRequestGetRoomInfoCallback {
public:
	virtual ~IRequestGetRoomInfoCallback(){};
	virtual void OnGetRoomInfo(HttpGetRoomInfoTask* task, bool success, int errnum, const string& errmsg, const HttpGetRoomInfoItem& Item) = 0;
};

class HttpGetRoomInfoTask : public HttpRequestTask {
public:
	HttpGetRoomInfoTask();
	virtual ~HttpGetRoomInfoTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetRoomInfoCallback* pCallback);

    void SetParam(
                  );
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetRoomInfoCallback* mpCallback;

};

#endif /* HttpGetRoomInfoTask_H_ */
