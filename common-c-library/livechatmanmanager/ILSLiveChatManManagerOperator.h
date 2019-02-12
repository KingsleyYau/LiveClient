//
//  ILSLiveChatManManagerOperator.h
//  Common-C-Library
//  LiveChatManager公用接口
//  Created by Max on 2017/2/20.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#ifndef ILSLiveChatManManagerOperator_h
#define ILSLiveChatManManagerOperator_h

#include <common/CommonFunc.h>

typedef unsigned long long TaskParam;

class ILSLiveChatManManagerTaskCallback {
public:
    virtual ~ILSLiveChatManManagerTaskCallback(){};
    virtual void OnLiveChatManManagerTaskRun(TaskParam param) = 0;
    virtual void OnLiveChatManManagerTaskClose(TaskParam param) = 0;
};

class ILSLiveChatManManagerOperator {
public:
    virtual ~ILSLiveChatManManagerOperator(){};
    
    // 是否自动登录
    virtual bool IsAutoLogin() = 0;
    // 是否已经登录
    virtual bool IsLogin() = 0;
    // 是否已经获取历史记录
    virtual bool IsGetHistory() = 0;
    // 获取登录用户Id
    virtual string GetUserId() = 0;
    // 获取登录用户Name
    virtual string GetUserName() = 0;
    // 获取登录用户Sid
    virtual string GetSid() = 0;
    // 站点ID
    virtual int GetSiteType() = 0;
    // 获取最小点数
    virtual double GetMinBalance() = 0;
    
    // 根据错误类型生成警告消息
    virtual void BuildAndInsertWarningWithErrType(const string& userId, LSLIVECHAT_LCC_ERR_TYPE errType) = 0;
    // 生成警告消息
    virtual void BuildAndInsertWarningMsg(const string& userId, WarningCodeType codeType) = 0;
    // 生成系统消息
    virtual void BuildAndInsertSystemMsg(const string& userId, CodeType codeType) = 0;
    
    virtual void SetUserOnlineStatusWithLccErrType(LSLCUserItem* userItem, LSLIVECHAT_LCC_ERR_TYPE errType) = 0;
    
    // 插入定时任务
    virtual void InsertRequestTask(ILSLiveChatManManagerTaskCallback* callback, TaskParam param, long long delayTime = -1) = 0;
};

#endif /* ILSLiveChatManManagerOperator_h */
