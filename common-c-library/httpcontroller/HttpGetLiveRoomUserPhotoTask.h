/*
 * HttpGetLiveRoomUserPhotoTask.h
 *
 *  Created on: 2017-5-23
 *      Author: Alex
 *        desc: 4.1.获取用户头像
 */

#ifndef HttpGetLiveRoomUserPhotoTask_H_
#define HttpGetLiveRoomUserPhotoTask_H_

#include "HttpRequestTask.h"

#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpGetLiveRoomUserPhotoTask;

class IRequestGetLiveRoomUserPhotoCallback {
public:
	virtual ~IRequestGetLiveRoomUserPhotoCallback(){};
	virtual void OnGetLiveRoomUserPhoto(HttpGetLiveRoomUserPhotoTask* task, bool success, int errnum, const string& errmsg, const string& photoUrl) = 0;
};

class HttpGetLiveRoomUserPhotoTask : public HttpRequestTask {
public:
	HttpGetLiveRoomUserPhotoTask();
	virtual ~HttpGetLiveRoomUserPhotoTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetLiveRoomUserPhotoCallback* pCallback);

    /**
     * 关闭直播间
     * @param token			       用户身份唯一标识
     * @param userid			   用户ID
     * @param phototype			   头像类型（0:小图 1:大图）
     */
    void SetParam(
                  string token,
                  string userid,
                  PhotoType phototype
                  );
    
    /**
     * 获取用户身份唯一标识
     */
    const string& GetToken();
    
    /**
     * 获取用户ID
     */
    const string& GetUserId();
    
    /**
     * 获取头像类型
     */
    PhotoType GetPhotoType();
    
    /**
     * 获取头像url（返回）
     */
    const string& GetPhotoUrl();
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestGetLiveRoomUserPhotoCallback* mpCallback;
    
    // 用户身份唯一标识
    string mToken;
    // 用户ID
    string mUserId;
    // 头像类型（0:小图 1:大图）
    PhotoType mPhotoType;
    
    // 头像url（返回）
    string mPhotoUrl;
};

#endif /* HttpGetLiveRoomUserPhotoTask_H_ */
