/*
 * HttpSetLiveRoomModifyInfoTask.h
 *
 *  Created on: 2017-5-24
 *      Author: Alex
 *        desc: 4.3.提交本人资料
 */

#ifndef HttpSetLiveRoomModifyInfoTask_H_
#define HttpSetLiveRoomModifyInfoTask_H_

#include "HttpRequestTask.h"

#include "HttpLoginProtocol.h"
#include "HttpRequestEnum.h"

class HttpSetLiveRoomModifyInfoTask;

class IRequestSetLiveRoomModifyInfoCallback {
public:
	virtual ~IRequestSetLiveRoomModifyInfoCallback(){};
	virtual void OnSetLiveRoomModifyInfo(HttpSetLiveRoomModifyInfoTask* task, bool success, int errnum, const string& errmsg) = 0;
};
      
class HttpSetLiveRoomModifyInfoTask : public HttpRequestTask {
public:
	HttpSetLiveRoomModifyInfoTask();
	virtual ~HttpSetLiveRoomModifyInfoTask();

    /**
     * 设置回调
     */
    void SetCallback(IRequestSetLiveRoomModifyInfoCallback* pCallback);

    /**
     * 关闭直播间
     * @param token			           用户身份唯一标识
     * @param photoUrl			       头像文件数据
     * @param nickName			       昵称
     * @param gender			       性别（0:男性 1:女性）
     * @param birthday			       出生日期（格式：1980-01-01）
     */
    void SetParam(
                  string token,
                  string photoUrl,
                  string nickName,
                  Gender gender,
                  string birthday
                  );
    
    /**
     * 获取用户身份唯一标识
     */
    const string& GetToken();
    
    /**
     * 获取头像文件数据
     */
    const string& GetPhotoUrl();
 
    /**
     * 获取昵称
     */
    const string& GetNickName();
    
    /**
     * 获取性别（0:男性 1:女性）
     */
    Gender GetGender();
    
    /**
     * 获取出生日期（格式：1980-01-01）
     */
    const string& GetBirthday();
    
protected:
    // Implement HttpRequestTask
    bool ParseData(const string& url, bool bFlag, const char* buf, int size);
    
protected:
	IRequestSetLiveRoomModifyInfoCallback* mpCallback;
    
    // 用户身份唯一标识
    string mToken;
    // 头像文件数据
    string mPhotoUrl;
    // 昵称
    string mNickName;
    // 性别（0:男性 1:女性）
    Gender mGender;
    // 出生日期（格式：1980-01-01）
    string mBirthday;
};

#endif /* HttpGetLiveRoomUserPhotoTask_H_ */
