/*
 * HttpOwnRegisterTask.h
 *
 *  Created on: 2017-12-20
 *      Author: Alex
 *        desc: 2.5.邮箱注册（仅独立）
 */

#ifndef HttpOwnRegisterTask_H_
#define HttpOwnRegisterTask_H_

#include "HttpRequestTask.h"

#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpOwnRegisterTask;

class IRequestOwnRegisterCallback {
public:
    virtual ~IRequestOwnRegisterCallback(){};
    virtual void OnOwnRegister(HttpOwnRegisterTask* task, bool success, int errnum, const string& errmsg, const string& sessionId) = 0;
};

class HttpOwnRegisterTask : public HttpRequestTask {
public:
    HttpOwnRegisterTask();
    virtual ~HttpOwnRegisterTask();
    
    /**
     * 设置回调
     */
    void SetCallback(IRequestOwnRegisterCallback* pCallback);
    
    /**
     * 邮箱注册
     * email                电子邮箱
     * passWord             密码
     * gender               性别（M：男，F：女）
     * nickName             昵称
     * birthDay             出生日期（格式为：2015-02-20）
     * inviteCode           推荐码（可无）
     * model                设备型号
     * deviceId             设备唯一标识
     * manufacturer         制造厂商
     * utmReferrer          APP推广参数（google play返回的referrer，格式：UrlEncode(referrer)）
     */
    void SetParam(
                  string email,
                  string passWord,
                  GenderType gender,
                  string nickName,
                  string birthDay,
                  string inviteCode,
                  string model,
                  string deviceid,
                  string manufacturer,
                  string utmReferrer
                  );
    
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
    IRequestOwnRegisterCallback* mpCallback;
    
    string mEmail;              // 电子邮箱
    string mPassWord;           // 密码
    GenderType mGender;         // 性别（M：男，F：女）
    string mNickName;           // 昵称
    string mBirthDay;           // 出生日期（格式为：2015-02-20）
    string mInviteCode;         // 推荐码（可无）
    string mModel;              // 设备型号
    string mDeviceId;           // 设备唯一标识
    string mManufacturer;       // 制造厂商
    string mUtmReferrer;        // APP推广参数（google play返回的referrer，格式：UrlEncode(referrer)）
};

#endif /* HttpOwnFackBookLoginTask_H_ */
