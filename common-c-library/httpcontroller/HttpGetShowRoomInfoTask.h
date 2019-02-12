/*
 * HttpGetShowRoomInfoTask.h
 *
 *  Created on: 2018-4-23
 *      Author: Alex
 *        desc: 9.5.获取可进入的节目信息
 */

#ifndef HttpGetShowRoomInfoTask_H_
#define HttpGetShowRoomInfoTask_H_

#include "HttpRequestTask.h"
#include "item/HttpProgramInfoItem.h"
#include "item/HttpAuthorityItem.h"

class HttpGetShowRoomInfoTask;

class IRequestGetShowRoomInfoCallback {
public:
	virtual ~IRequestGetShowRoomInfoCallback(){};
	virtual void OnGetShowRoomInfo(HttpGetShowRoomInfoTask* task, bool success, int errnum, const string& errmsg, const HttpProgramInfoItem& item, const string& roomId, const HttpAuthorityItem& priv) = 0;
};
      
class HttpGetShowRoomInfoTask : public HttpRequestTask {
public:
	HttpGetShowRoomInfoTask();
	virtual ~HttpGetShowRoomInfoTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetShowRoomInfoCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    const string& liveShowId
                  );
    

protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetShowRoomInfoCallback* mpCallback;
    // 节目ID
    string mLiveShowId;
};

#endif /* HttpGetShowRoomInfoTask_H */
