/*
 * HttpDelLiveRoomPhotoTast.h
 *
 *  Created on: 2017-6-09
 *      Author: Alex
 *        desc: 3.13.删除开播封面图（用于主播删除开播封面图）
 */

#ifndef HttpDelLiveRoomPhotoTast_H_
#define HttpDelLiveRoomPhotoTast_H_

#include "HttpRequestTask.h"

#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpDelLiveRoomPhotoTast;

class IRequestDelLiveRoomPhotoCallback {
public:
	virtual ~IRequestDelLiveRoomPhotoCallback(){};
	virtual void OnDelLiveRoomPhoto(HttpDelLiveRoomPhotoTast* task, bool success, int errnum, const string& errmsg) = 0;
};

class HttpDelLiveRoomPhotoTast : public HttpRequestTask {
public:
	HttpDelLiveRoomPhotoTast();
	virtual ~HttpDelLiveRoomPhotoTast();

    /**
     * 设置回调
     */
    void SetCallback(IRequestDelLiveRoomPhotoCallback* pCallback);

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
	IRequestDelLiveRoomPhotoCallback* mpCallback;
    
    // 用户身份唯一标识
    string mToken;
    // 封面图ID
    string mPhotoId;

};

#endif /* HttpDelLiveRoomPhotoTast_H_ */
