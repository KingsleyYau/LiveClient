/*
 * HttpAddLiveRoomPhotoTask.h
 *
 *  Created on: 2017-6-09
 *      Author: Alex
 *        desc: 3.11.添加开播封面图（用于主播添加开播封面图）
 */

#ifndef HttpAddLiveRoomPhotoTask_H_
#define HttpAddLiveRoomPhotoTask_H_

#include "HttpRequestTask.h"

#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpAddLiveRoomPhotoTask;

class IRequestAddLiveRoomPhotoCallback {
public:
	virtual ~IRequestAddLiveRoomPhotoCallback(){};
	virtual void OnAddLiveRoomPhoto(HttpAddLiveRoomPhotoTask* task, bool success, int errnum, const string& errmsg) = 0;
};

class HttpAddLiveRoomPhotoTask : public HttpRequestTask {
public:
	HttpAddLiveRoomPhotoTask();
	virtual ~HttpAddLiveRoomPhotoTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestAddLiveRoomPhotoCallback* pCallback);

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
	IRequestAddLiveRoomPhotoCallback* mpCallback;
    
    // 用户身份唯一标识
    string mToken;
    // 封面图ID
    string mPhotoId;

};

#endif /* HttpAddLiveRoomPhotoTask_H_ */
