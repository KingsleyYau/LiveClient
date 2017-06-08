/*
 * HttpGetLiveRoomModifyInfoTask.h
 *
 *  Created on: 2017-5-24
 *      Author: Alex
 *        desc: 4.2.获取可编辑的本人资料
 */

#ifndef HttpGetLiveRoomModifyInfoTask_H_
#define HttpGetLiveRoomModifyInfoTask_H_

#include "HttpRequestTask.h"

#include "item/HttpLiveRoomPersonalInfoItem.h"

class HttpGetLiveRoomModifyInfoTask;

class IRequestGetLiveRoomModifyInfoCallback {
public:
	virtual ~IRequestGetLiveRoomModifyInfoCallback(){};
	virtual void OnGetLiveRoomModifyInfo(HttpGetLiveRoomModifyInfoTask* task, bool success, int errnum, const string& errmsg, const HttpLiveRoomPersonalInfoItem& item) = 0;
};

class HttpGetLiveRoomModifyInfoTask : public HttpRequestTask {
public:
	HttpGetLiveRoomModifyInfoTask();
	virtual ~HttpGetLiveRoomModifyInfoTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetLiveRoomModifyInfoCallback* pCallback);

    /**
     * 关闭直播间
     * @param token			       用户身份唯一标识
     */
    void SetParam(
                  string token
                  );
    
    /**
     * 获取用户身份唯一标识
     */
    const string& GetToken();
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetLiveRoomModifyInfoCallback* mpCallback;
    
    // 用户身份唯一标识
    string mToken;

};

#endif /* HttpGetLiveRoomUserPhotoTask_H_ */
