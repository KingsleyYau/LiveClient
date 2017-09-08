/*
 * HttpControlManPushTask.h
 *
 *  Created on: 2017-8-30
 *      Author: Alex
 *        desc: 3.13.观众开始／结束视频互动（废弃）
 */

#ifndef HttpControlManPushTask_H_
#define HttpControlManPushTask_H_

#include "HttpRequestTask.h"
#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpControlManPushTask;

class IRequestControlManPushCallback {
public:
	virtual ~IRequestControlManPushCallback(){};
	virtual void OnControlManPush(HttpControlManPushTask* task, bool success, int errnum, const string& errmsg, const list<string>& uploadUrls) = 0;
};
      
class HttpControlManPushTask : public HttpRequestTask {
public:
	HttpControlManPushTask();
	virtual ~HttpControlManPushTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestControlManPushCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    const string& roomId,
                    ControlType control
                  );
    
    const string& GetRoomId();
    
    ControlType GetControl();
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestControlManPushCallback* mpCallback;
    // 直播间ID
    string mRoomId;
    // 视频操作（1:开始 2:关闭）
    ControlType mControl;

};

#endif /* HttpControlManPushTask_H_ */
