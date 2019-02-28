/*
 * author: Alex
 *   date: 2019-01-22
 *   file: LSLCAutoInviteFilter.h
 *   desc: 自动邀请过滤器(过滤男士不符合女士条件的邀请)
 */

#pragma once

#include <string>
#include "LSLCAutoInviteItem.h"
#include "ILSLiveChatManManagerEnumDef.h"
#include "LSLCUserItem.h"
#include "ILSLiveChatManManagerOperator.h"
#include <livechat/ILSLiveChatClient.h>
using namespace std;
class IAutoLock;
class RequestItem;

class LSLCAutoInviteFilter : public ILSLiveChatClientListener
                            , public ILSLiveChatManManagerTaskCallback
{
public:
	LSLCAutoInviteFilter(
                         ILSLiveChatManManagerOperator* pOperator,
                         ILSLiveChatClient*    pClient);
	virtual ~LSLCAutoInviteFilter();

public:

    /**
    * 过滤系统邀请，并异步生成LCMessage
    * @param womanId
    * @param manId
    * @param key
    */
    void FilterAutoInvite(const string& womanId, const string& manId, const string& key);
    
    /**
     * 用户择偶条件更新（过滤前提是获取男士择偶条件）
     * @param userItem
     */
    void OnGetUserInfoUpdate(const UserInfoItem& userInfo);

private:

    
    // 定时业务处理器
    void RequestHandler(RequestItem* item);
    /**
     * 清除指定女士的自动邀请
     * @param womanId
     */
    LSLCAutoInviteItem* ClearAutoInviteById(const string& womanId);
    /**
     * 获取女士条件
     * @param womanId
     */
    bool GetLadyCondition(const string& womanId);
    /**
     * 获取女士模版
     * @param womanId
     */
    bool GetLadyCustomTemplate(const string& womanId);
    /**
     * 检测男士是否满足女士条件
     * @param condition
     * @return
     */
    bool CheckConditionMap(const LadyConditionItem& item);
    /**
     * 判断婚姻状况是否符合
     * @param condition
     * @return
     */
    bool CheckMarryCondition(const LadyConditionItem& item);
    /**
     * 判断国籍是否符合设置
     * @param condition
     * @return
     */
    bool CheckCountryCondition(const LadyConditionItem& item);
    /**
     * 过滤获取女士可用自定义模板列表
     * @param contents
     * @param flags
     * @return
     */
    list<string> GetValidCustomTemplateList(const vector<string>& contents, const vector<bool>& flags);
    /**
     * 验证通过生成系统邀请信息
     * @param inviteItem
     * @param message
     */
    void CreateSystemInviteMessage(LSLCAutoInviteItem* inviteItem, const string& message);
    // 系统邀请Map加锁
    void Lock();
    // 系统邀请Map解锁
    void Unlock();
    
private:
    /* -------------------------------------   ILSLiveChatClientListener   --------------------------------- */
    void OnGetLadyCondition(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const LadyConditionItem& item) override;
    void OnGetLadyCustomTemplate(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const vector<string>& contents, const vector<bool>& flags) override;
    
    /* -------------------------------------   ILSLiveChatManManagerTaskCallback   --------------------------------- */
    void OnLiveChatManManagerTaskRun(TaskParam param) override;
    void OnLiveChatManManagerTaskClose(TaskParam param) override;

private:
    /**
     * 是否初始化成功(在获取男士个人信息成功后，防止获取成功之前有自动邀请过去)
     */
    bool mIsInit;
    /**
     * 过滤邀请时间间隔（防止短时间内邀请过多负荷过重）
     */
    long long mFilterTimeInterval;
    /**
     * 上一次处理邀请的时间(毫秒)
     */
    long long mPreHandleTime;
//    /**
//     * Livechat 管理器
//     */
//    LiveChatManager mLiveChatManager;
    /**
     * 系统邀请(单人列表最多同时仅存一个)
     */
    AutoInviteMap mSystemInviteMap;
    /**
     * 系统邀请Map锁
     */
    IAutoLock*        mInviteMapLock;
    /**
     * 记录男士择偶条件等信息
     */
    UserInfoItem mUserItem;
    // LiveChat客户端
    ILSLiveChatClient* mClient;
    // 公共信息获取
    ILSLiveChatManManagerOperator* mOperator;
//    /**
//     * 随机数生成器
//     */
//    Random mRandom;
};
