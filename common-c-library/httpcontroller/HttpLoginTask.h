/*
 * HttpLoginTask.h
 *
 *  Created on: 2017-8-16
 *      Author: Alex
 *        desc: 2.1.登录
 */

#ifndef HttpLoginTask_H_
#define HttpLoginTask_H_

#include "HttpRequestTask.h"

#include "item/HttpLoginItem.h"

class HttpLoginTask;

class IRequestLoginCallback {
public:
    virtual ~IRequestLoginCallback(){};
    virtual void OnLogin(HttpLoginTask* task, bool success, int errnum, const string& errmsg, const HttpLoginItem& item) = 0;
};

class HttpLoginTask : public HttpRequestTask {
public:
    HttpLoginTask();
    virtual ~HttpLoginTask();
    
    /**
     * 设置回调
     */
    void SetCallback(IRequestLoginCallback* pCallback);
    
    /**
     * 登录
     * @param qnsid			    QN系统登录验证返回的标识
     * @param deviceid		    设备唯一标识
     * @param model				设备型号（格式：设备型号－系统版本号）
     * @param manufacturer		制造厂商
     */
    void SetParam(
                  string qnsid,
                  string deviceid,
                  string model,
                  string manufacturer
                  );

    /**
     * 获取QN系统登录验证返回的标识
     */
    const string& GetQnsid();
    
    /**
     * 获取设备唯一标识
     */
    const string& GetDeviceId();
    
    /**
     * 获取设备型号（格式：设备型号－系统版本号）
     */
    const string& GetModel();
    
    /**
     * 获取制造厂商
     */
    const string& GetManufacturer();
    
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
    IRequestLoginCallback* mpCallback;
    string mQnsid;           // QN系统登录验证返回的标识
    string mDeviceId;        // 设备唯一标识
    string mModel;           // 设备型号
    string mManufacturer;    // 制造厂商
    
};

#endif /* HttpLoginTask_H_ */
