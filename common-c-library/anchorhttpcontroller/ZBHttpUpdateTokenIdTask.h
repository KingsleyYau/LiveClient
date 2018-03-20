/*
 * ZBHttpUpdateTokenIdTask.h
 *
 *  Created on: 2018-2-27
 *      Author: Alex
 *        desc: 2.2.上传tokenid接口
 */

#ifndef ZBHttpUpdateTokenIdTask_H_
#define ZBHttpUpdateTokenIdTask_H_

#include "ZBHttpRequestTask.h"

#include "ZBHttpLoginProtocol.h"
#include "ZBHttpRequestEnum.h"

class ZBHttpUpdateTokenIdTask;

class IRequestZBUpdateTokenIdCallback {
public:
	virtual ~IRequestZBUpdateTokenIdCallback(){};
	virtual void OnZBUpdateTokenId(ZBHttpUpdateTokenIdTask* task, bool success, int errnum, const string& errmsg) = 0;
};
      
class ZBHttpUpdateTokenIdTask : public ZBHttpRequestTask {
public:
	ZBHttpUpdateTokenIdTask();
	virtual ~ZBHttpUpdateTokenIdTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestZBUpdateTokenIdCallback* pCallback);

    /**
     * 关闭直播间
     * @param tokenId			       用于Push Notification的ID
     */
    void SetParam(
                  string tokenId
                  );
    
    /**
     * 获取用于Push Notification的ID
     */
    const string& GetmTokenId();
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestZBUpdateTokenIdCallback* mpCallback;
    
    // 用于Push Notification的ID
    string mTokenId;

};

#endif /* ZBHttpUpdateTokenIdTask_H_ */
