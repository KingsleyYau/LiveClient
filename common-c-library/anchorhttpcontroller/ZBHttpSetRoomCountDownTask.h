/*
 * ZBHttpSetRoomCountDownTask.h
 *
 *  Created on: 2018-3-9
 *      Author: Alex
 *        desc: 4.9.设置直播间为开始倒数
 */

#ifndef ZBHttpSetRoomCountDownTask_H_
#define ZBHttpSetRoomCountDownTask_H_

#include "ZBHttpRequestTask.h"
#include "ZBHttpLoginProtocol.h"
#include "ZBHttpRequestEnum.h"

class ZBHttpSetRoomCountDownTask;

class IRequestZBSetRoomCountDownCallback {
public:
	virtual ~IRequestZBSetRoomCountDownCallback(){};
	virtual void OnZBSetRoomCountDown(ZBHttpSetRoomCountDownTask* task, bool success, int errnum, const string& errmsg) = 0;
};
      
class ZBHttpSetRoomCountDownTask : public ZBHttpRequestTask {
public:
	ZBHttpSetRoomCountDownTask();
	virtual ~ZBHttpSetRoomCountDownTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestZBSetRoomCountDownCallback* pCallback);

    /**
     *
     */
    void SetParam(
                    const string& roomId
                  );
    
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestZBSetRoomCountDownCallback* mpCallback;
    // 直播间ID
    string    mRoomId;

};

#endif /* ZBHttpSetRoomCountDownTask_H_ */
