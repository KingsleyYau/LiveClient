/*
 * HttpUploadUserPhotoTask.h
 *
 *  Created on: 2019-08-14
 *      Author: Alex
 *        desc: 2.23.提交用户头像接口
 */

#ifndef HttpUploadUserPhotoTask_H_
#define HttpUploadUserPhotoTask_H_

#include "HttpRequestTask.h"

#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpUploadUserPhotoTask;

class IRequestUploadUserPhotoCallback {
public:
    virtual ~IRequestUploadUserPhotoCallback(){};
    virtual void OnUploadUserPhoto(HttpUploadUserPhotoTask* task, bool success, int errnum, const string& errmsg) = 0;
};

class HttpUploadUserPhotoTask : public HttpRequestTask {
public:
    HttpUploadUserPhotoTask();
    virtual ~HttpUploadUserPhotoTask();
    
    /**
     * 设置回调
     */
    void SetCallback(IRequestUploadUserPhotoCallback* pCallback);
    
    /**
     * 提交用户头像接口
     * photoName          上传头像文件名
     */
    void SetParam(
                  string photoName
                  );
    
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
    IRequestUploadUserPhotoCallback   * mpCallback;
    
    string mPhotoName;              // 上传头像文件名
};

#endif /* HttpUploadUserPhotoTask_H_ */
