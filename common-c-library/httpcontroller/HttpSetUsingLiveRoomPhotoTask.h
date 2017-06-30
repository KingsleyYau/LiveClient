/*
 * HttpSetUsingLiveRoomPhotoTask.h
 *
 *  Created on: 2017-6-09
 *      Author: Alex
 *        desc: 3.12.设置默认使用封面图（用于主播设置默认的封面图）
 */

#ifndef HttpSetUsingLiveRoomPhotoTask_H_
#define HttpSetUsingLiveRoomPhotoTask_H_

#include "HttpRequestTask.h"

#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpSetUsingLiveRoomPhotoTask;

class IRequestSetUsingLiveRoomPhotoCallback {
public:
	virtual ~IRequestSetUsingLiveRoomPhotoCallback(){};
	virtual void OnSetUsingLiveRoomPhoto(HttpSetUsingLiveRoomPhotoTask* task, bool success, int errnum, const string& errmsg) = 0;
};

class HttpSetUsingLiveRoomPhotoTask : public HttpRequestTask {
public:
	HttpSetUsingLiveRoomPhotoTask();
	virtual ~HttpSetUsingLiveRoomPhotoTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestSetUsingLiveRoomPhotoCallback* pCallback);

    /**
     * 新建直播间
     * @param token			       用户身份唯一标识
     * @param photoId			   封面图ID
     */
    void SetParam(
                  string token,
                  string photoId
                  );
    
    /**
     * 获取用户身份唯一标识
     */
    const string& GetToken();
    /**
     * 获取封面图ID
     */
    const string& GetPhotoId();

    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestSetUsingLiveRoomPhotoCallback* mpCallback;
    
    // 用户身份唯一标识
    string mToken;
    // 封面图ID
    string mPhotoId;

};

#endif /* HttpSetUsingLiveRoomPhotoTask_H_ */
