/*
 * HttpUploadLiveRoomImgTask.h
 *
 *  Created on: 2017-6-08
 *      Author: Alex
 *        desc: 5.2.上传图片（用于客户端上传图片，使用5.1.同步配置的上传图片服务器域名及端口）
 */

#ifndef HttpUploadLiveRoomImgTask_H_
#define HttpUploadLiveRoomImgTask_H_

#include "HttpRequestTask.h"

#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpUploadLiveRoomImgTask;

class IRequestUploadLiveRoomImgCallback {
public:
	virtual ~IRequestUploadLiveRoomImgCallback(){};
	virtual void OnUploadLiveRoomImg(HttpUploadLiveRoomImgTask* task, bool success, int errnum, const string& errmsg, const string& imageId, const string& imageUrl) = 0;
};

class HttpUploadLiveRoomImgTask : public HttpRequestTask {
public:
	HttpUploadLiveRoomImgTask();
	virtual ~HttpUploadLiveRoomImgTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestUploadLiveRoomImgCallback* pCallback);

    /**
     * 新建直播间
     * @param token			       用户身份唯一标识
     */
    void SetParam(
                  string token,
                  ImageType imageType,
                  string imageFileName
                  );
    
    /**
     * 获取用户身份唯一标识
     */
    const string& GetToken();
    /**
     * 获取图片类型（1:用户头像 2:直播间封面图）
     */
    const ImageType GetImageType();
    /**
     * 获取图片文件二进制数据
     */
    const string& GetImageFileName();
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestUploadLiveRoomImgCallback* mpCallback;
    
    // 用户身份唯一标识
    string mToken;
    // 图片类型（1:用户头像 2:直播间封面图）
    ImageType mImageType;
    // 图片文件二进制数据
    string mImageFileName;
    
    // 图片ID
    string mImageId;
    // 图片url
    string mImageUrl;
};

#endif /* HttpUploadLiveRoomImgTask_H_ */
