/*
 * HttpUploadPhotoTask.h
 *
 *  Created on: 2017-12-21
 *      Author: Alex
 *        desc: 2.9.提交用户头像接口（仅独立）
 */

#ifndef HttpUploadPhotoTask_H_
#define HttpUploadPhotoTask_H_

#include "HttpRequestTask.h"

#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpUploadPhotoTask;

class IRequestUploadPhotoCallback {
public:
    virtual ~IRequestUploadPhotoCallback(){};
    virtual void OnUploadPhoto(HttpUploadPhotoTask* task, bool success, int errnum, const string& errmsg, const string& photoUrl) = 0;
};

class HttpUploadPhotoTask : public HttpRequestTask {
public:
    HttpUploadPhotoTask();
    virtual ~HttpUploadPhotoTask();
    
    /**
     * 设置回调
     */
    void SetCallback(IRequestUploadPhotoCallback* pCallback);
    
    /**
     * 提交用户头像接口
     * photoName          上传头像文件名
     */
    void SetParam(
                  string photoName
                  );
    
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
    IRequestUploadPhotoCallback* mpCallback;
    
    string mPhotoName;              // 上传头像文件名
};

#endif /* HttpUploadPhotoTask_H_ */
