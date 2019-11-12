/*
 * ZBHttpLoginTask.h
 *
 *  Created on: 2018-2-26
 *      Author: Alex
 *        desc: 2.1.登录
 */

#ifndef ZBHttpLoginTask_H_
#define ZBHttpLoginTask_H_

#include "ZBHttpRequestTask.h"

#include "ZBitem/ZBHttpLoginItem.h"

class ZBHttpLoginTask;

class IRequestZBLoginCallback {
public:
    virtual ~IRequestZBLoginCallback(){};
    virtual void OnZBLogin(ZBHttpLoginTask* task, bool success, int errnum, const string& errmsg, const ZBHttpLoginItem& item) = 0;
};

class ZBHttpLoginTask : public ZBHttpRequestTask {
public:
    ZBHttpLoginTask();
    virtual ~ZBHttpLoginTask();
    
    /**
     * 设置回调
     */
    void SetCallback(IRequestZBLoginCallback* pCallback);
    
    /**
     * 登录
     * @param anchorId          主播ID
     * @param password			密码
     * @param code              验证码
     * @param deviceid		    设备唯一标识
     * @param model				设备型号（格式：设备型号－系统版本号）
     * @param manufacturer		制造厂商
     * @param deviceName        设备名字
     */
    void SetParam(
                  string anchorId,
                  string password,
                  string code,
                  string deviceid,
                  string model,
                  string manufacturer,
                  string deviceName
                  );
    
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
    IRequestZBLoginCallback* mpCallback;
    string mSN;         // 主播ID
    string mPassword;   // 密码
    string mCode;       // 验证码
    string mDeviceId;   // 设备唯一标识
    string mModel;           // 设备型号（格式：设备型号-系统版本号）
    string mManufacturer;    // 制造厂商
    string mDeviceName;     // 设备名字
};

#endif /* ZBHttpLoginTask_H_ */
