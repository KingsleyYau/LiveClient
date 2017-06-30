/*
 * HttpGetLiveRoomPhotoListTask.h
 *
 *  Created on: 2017-6-08
 *      Author: Alex
 *        desc: 3.10.获取开播封面图列表（用于主播开播前，获取封面图列表）
 */

#ifndef HttpGetLiveRoomPhotoListTask_H_
#define HttpGetLiveRoomPhotoListTask_H_

#include "HttpRequestTask.h"

#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"
#include "item/HttpLiveRoomCoverPhotoItem.h"

class HttpGetLiveRoomPhotoListTask;

class IRequestGetLiveRoomPhotoListCallback {
public:
	virtual ~IRequestGetLiveRoomPhotoListCallback(){};
	virtual void OnGetLiveRoomPhotoList(HttpGetLiveRoomPhotoListTask* task, bool success, int errnum, const string& errmsg, const CoverPhotoItemList& itemList) = 0;
};

class HttpGetLiveRoomPhotoListTask : public HttpRequestTask {
public:
	HttpGetLiveRoomPhotoListTask();
	virtual ~HttpGetLiveRoomPhotoListTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestGetLiveRoomPhotoListCallback* pCallback);

    /**
     * 新建直播间
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
	IRequestGetLiveRoomPhotoListCallback* mpCallback;
    
    // 用户身份唯一标识
    string mToken;

};

#endif /* HttpUploadLiveRoomImgTask_H_ */
