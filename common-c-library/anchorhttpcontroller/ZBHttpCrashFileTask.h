/*
 * ZBHttpCrashFileTask.h
 *
 *  Created on: 2018-03-01
 *      Author: Alex
 *        desc: 5.4.提交crash dump文件
 */

#ifndef ZBHttpCrashFileTask_H_
#define ZBHttpCrashFileTask_H_

#include "ZBHttpRequestTask.h"

#include "ZBHttpLoginProtocol.h"
#include "ZBHttpRequestEnum.h"

class ZBHttpCrashFileTask;

class IRequestZBCrashFileCallback {
public:
    virtual ~IRequestZBCrashFileCallback(){};
    virtual void OnZBCrashFile(ZBHttpCrashFileTask* task, bool success, int errnum, const string& errmsg) = 0;
};

class ZBHttpCrashFileTask : public ZBHttpRequestTask {
public:
    ZBHttpCrashFileTask();
    virtual ~ZBHttpCrashFileTask();
    
    /**
     * 设置回调
     */
    void SetCallback(IRequestZBCrashFileCallback* pCallback);
    
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
    IRequestZBCrashFileCallback* mpCallback;
    
    string mDeviceId;               // 设备唯一标识
    string mCrashFile;              // crash dump文件zip包二进制流（zip密钥：Qpid_Dating）
};

#endif /* ZBHttpCrashFileTask_H_ */
