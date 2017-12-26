/*
 * HttpSetShareSucTask.h
 *
 *  Created on: 2017-12-20
 *      Author: Alex
 *        desc: 6.12.分享链接成功
 */

#ifndef HttpSetShareSucTask_H_
#define HttpSetShareSucTask_H_

#include "HttpRequestTask.h"

#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpSetShareSucTask;

class IRequestSetShareSucCallback {
public:
    virtual ~IRequestSetShareSucCallback(){};
    virtual void OnSetShareSuc(HttpSetShareSucTask* task, bool success, int errnum, const string& errmsg) = 0;
};

class HttpSetShareSucTask : public HttpRequestTask {
public:
    HttpSetShareSucTask();
    virtual ~HttpSetShareSucTask();
    
    /**
     * 设置回调
     */
    void SetCallback(IRequestSetShareSucCallback* pCallback);
    
    /**
     * 获取分享链接
     * shareId          分享ID（参考《6.11.获取分享链接（http post）》的shareid参数））
     */
    void SetParam(
                  string shareId
                  );
    
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
    IRequestSetShareSucCallback* mpCallback;
    
    string mShareId;              // 分享ID（参考《6.11.获取分享链接（http post）》的shareid参数）
};

#endif /* HttpSetShareSucTask_H_ */
