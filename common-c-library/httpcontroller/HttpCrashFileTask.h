/*
 * HttpCrashFileTask.h
 *
 *  Created on: 2018-01-11
 *      Author: Alex
 *        desc: 6.16.提交crash dump文件（仅独立）
 */

#ifndef HttpCrashFileTask_H_
#define HttpCrashFileTask_H_

#include "HttpRequestTask.h"

#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpCrashFileTask;

class IRequestCrashFileCallback {
public:
    virtual ~IRequestCrashFileCallback(){};
    virtual void OnCrashFile(HttpCrashFileTask* task, bool success, int errnum, const string& errmsg) = 0;
};

class HttpCrashFileTask : public HttpRequestTask {
public:
    HttpCrashFileTask();
    virtual ~HttpCrashFileTask();
    
    /**
     * 设置回调
     */
    void SetCallback(IRequestCrashFileCallback* pCallback);
    
    /**
     * 提交crash dump文件接口
     * deviceId          设备唯一标识
     * crashFile         crash dump文件zip包二进制流（zip密钥：Qpid_Dating）
     */
    void SetParam(
                  string deviceId,
                  string crashFile
                  );
    
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
    IRequestCrashFileCallback* mpCallback;
    
    string mDeviceId;               // 设备唯一标识
    string mCrashFile;              // crash dump文件zip包二进制流（zip密钥：Qpid_Dating）
};

#endif /* HttpCrashFileTask_H_ */
