/*
 * author: Alex
 *   date: 2019-01-22
 *   file: LSLCAutoInviteFilter.cpp
 *   desc: 自动邀请过滤器(过滤男士不符合女士的邀请)
 */

#include "LSLCAutoInviteFilter.h"
#include <common/CommonFunc.h>
#include <manrequesthandler/LSLiveChatRequestLiveChatDefine.h>
#include <common/CheckMemoryLeak.h>
#include <common/IAutoLock.h>
#include <common/KLog.h>

// 定时业务类型
typedef enum {
    REQUEST_TASK_Unknow,                        // 未知请求类型
    REQUEST_TASK_GetLadyCondition,              // 获取女士条件
    REQUEST_TASK_GetLadyCustomTemplate,         // 获取女士模版
} REQUEST_TASK_TYPE;

// 定时业务结构体
class RequestItem
{
public:
    RequestItem()
    {
        requestType = REQUEST_TASK_Unknow;
        param = 0;
    }
    
    RequestItem(const RequestItem& item)
    {
        requestType = item.requestType;
        param = item.param;
    }
    
    ~RequestItem(){};
    
    REQUEST_TASK_TYPE requestType;
    unsigned long long param;
};

LSLCAutoInviteFilter::LSLCAutoInviteFilter(
                                           ILSLiveChatManManagerOperator* pOperator,
                                           ILSLiveChatClient*    pClient)
{
    FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LSLCAutoInviteFilter::LSLCAutoInviteFilter(pOperator : %p, pClient : %p) begin", pOperator, pClient);
    mClient = pClient;
    mOperator = pOperator;
    mPreHandleTime = 0;
    mFilterTimeInterval = 1 * 1000;
    
    mInviteMapLock = IAutoLock::CreateAutoLock();
    if (NULL != mInviteMapLock) {
        mInviteMapLock->Init();
    }
    
    if( mClient ) {
        mClient->AddListener(this);
    }
    FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LSLCAutoInviteFilter::LSLCAutoInviteFilter(pOperator : %p, pClient : %p) end", pOperator, pClient);
}

LSLCAutoInviteFilter::~LSLCAutoInviteFilter()
{
    FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LSLCAutoInviteFilter::~LSLCAutoInviteFilte() begin");
    IAutoLock::ReleaseAutoLock(mInviteMapLock);
    if( mClient ) {
        mClient->RemoveListener(this);
    }
    FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LSLCAutoInviteFilter::~LSLCAutoInviteFilte() end");
}

void LSLCAutoInviteFilter::FilterAutoInvite(const string& womanId, const string& manId, const string& key) {
    FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LSLCAutoInviteFilter::FilterAutoInvite(mIsInit : %d) begin", mIsInit);
    if (mIsInit) {
        // 1秒内只处理一个自动邀请，在一秒内的自动邀请不要了
        if (mPreHandleTime == 0 || mPreHandleTime + mFilterTimeInterval <= getCurrentTime()) {
            bool isContain = false;
            // 创建一个自动邀请item
            LSLCAutoInviteItem* item = new LSLCAutoInviteItem(womanId, manId, key);
            Lock();
            // 判断自动Map列表有没有这个女士Id的自动item，没有就插入并进行处理。
            AutoInviteMap::const_iterator inviteIter = mSystemInviteMap.find(womanId);
            if (inviteIter == mSystemInviteMap.end()) {
                mSystemInviteMap.insert(AutoInviteMap::value_type(womanId, item));
            } else {
                isContain = true;
                delete item;
            }
            Unlock();
            if (!isContain) {
                mPreHandleTime = getCurrentTime();
                // 当上面的条件成功，就获取女士的条件（加进线程获取）
                RequestItem* requestItem = new RequestItem();
                requestItem->requestType = REQUEST_TASK_GetLadyCondition;
                requestItem->param = (TaskParam)item;
                mOperator->InsertRequestTask(this, (TaskParam)requestItem);
            }
            
        }
    }
    FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LSLCAutoInviteFilter::FilterAutoInvite() end");

}

void LSLCAutoInviteFilter::OnGetUserInfoUpdate(const UserInfoItem& userInfo) {
    // 用户择偶条件更新（过滤前提是获取男士择偶条件）, 在登录成功后获取的
    mUserItem = userInfo;
    mIsInit = true;
}

LSLCAutoInviteItem* LSLCAutoInviteFilter::ClearAutoInviteById(const string& womanId) {
    LSLCAutoInviteItem* item = NULL;
    if (womanId.length() > 0) {
        Lock();
        AutoInviteMap::const_iterator inviteIter = mSystemInviteMap.find(womanId);
        if (inviteIter != mSystemInviteMap.end()) {
            item = (*inviteIter).second;
            mSystemInviteMap.erase(inviteIter);
        }
        Unlock();
    }
    return item;
}

bool LSLCAutoInviteFilter::GetLadyCondition(const string& womanId) {
    FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LSLCAutoInviteFilter::GetLadyCondition(womanId : %s) begin", womanId.c_str());
    bool result = false;
    if (womanId.length() > 0 && NULL != mClient) {
        result = mClient->GetLadyCondition(womanId);
    }
    FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LSLCAutoInviteFilter::GetLadyCondition(womanId : %s result: %d) end", womanId.c_str(), result);
    return result;
}

bool LSLCAutoInviteFilter::GetLadyCustomTemplate(const string& womanId) {
    FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LSLCAutoInviteFilter::GetLadyCustomTemplate(womanId : %s) begin", womanId.c_str());
    bool result = false;
    if (womanId.length() > 0 && NULL != mClient) {
        result = mClient->GetLadyCustomTemplate(womanId);
    }
     FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LSLCAutoInviteFilter::GetLadyCustomTemplate(womanId : %s result: %d) end", womanId.c_str(), result);
    return result;
}

bool LSLCAutoInviteFilter::CheckConditionMap(const LadyConditionItem& item) {
     FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LSLCAutoInviteFilter::CheckConditionMap(mIsInit : %d) begin", mIsInit);
    bool isMap = false;
    if(mIsInit){
        //婚姻情况判定
        if(item.marriageCondition){
            isMap = CheckMarryCondition(item);
        }else{
            isMap = true;
        }
        if(isMap){
            //判断子女状况
            if(item.childCondition){
                if((item.noChild && mUserItem.childrenType == CT_NO) ||
                   (!item.noChild && mUserItem.childrenType == CT_YES)){
                    isMap = true;
                }else{
                    isMap = false;
                }
            }else{
                isMap = true;
            }
        }
        
        if(isMap){
            //判断国籍
            if(item.countryCondition){
                isMap = CheckCountryCondition(item);
            }else{
                isMap = true;
            }
        }
        
        if(isMap){
            //判断年龄
            if(mUserItem.age >= item.startAge && mUserItem.age <= item.endAge){
                isMap = true;
            }else{
                isMap = false;
            }
        }
    }
    FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LSLCAutoInviteFilter::CheckConditionMap(mIsInit : %d, isMap : %d) end", mIsInit, isMap);
    return isMap;
}

bool LSLCAutoInviteFilter::CheckMarryCondition(const LadyConditionItem& item) {
    FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LSLCAutoInviteFilter::CheckMarryCondition() begin");
    bool result = false;
    if(item.neverMarried && mUserItem.marryType == MT_NEVERMARRIED){
        result = true;
    }
    
    if(item.divorced && mUserItem.marryType ==MT_DIVORCED){
        result = true;
    }
    
    if(item.widowed && mUserItem.marryType == MT_WIDOWED){
        result = true;
    }
    
    if(item.separated && mUserItem.marryType == MT_SEPARATED){
        result = true;
    }
    
    if(item.married && mUserItem.marryType == MT_MARRIED){
        result = true;
    }
    FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LSLCAutoInviteFilter::CheckMarryCondition(result : %d) end", result);
    return result;
}

bool LSLCAutoInviteFilter::CheckCountryCondition(const LadyConditionItem& item) {
     FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LSLCAutoInviteFilter::CheckCountryCondition() begin");
    bool result = false;

    if(item.unitedstates && (mUserItem.country == ("United States")
                                  || mUserItem.country == ("US"))){
        result = true;
    }
    if(item.canada && (mUserItem.country == ("Canada")
                            || mUserItem.country == ("CA"))){
        result = true;
    }
    if(item.newzealand && (mUserItem.country == ("New Zealand")
                                || mUserItem.country == ("NZ"))){
        result = true;
    }
    if(item.australia && (mUserItem.country == ("Australia")
                               || mUserItem.country == ("AU"))){
        result = true;
    }
    if(item.unitedkingdom && (mUserItem.country == ("United Kingdom")
                                   || mUserItem.country == ("GB"))){
        result = true;
    }
    
    if(item.germany && (mUserItem.country == ("Germany")
                             || mUserItem.country == ("DE"))){
        result = true;
    }
    
    if(item.othercountries){
        if((!(mUserItem.country == ("United States")) && !(mUserItem.country == ("US")))
           && (!(mUserItem.country == ("Canada")) && !(mUserItem.country == ("CA")))
           && (!(mUserItem.country == ("New Zealand")) && !(mUserItem.country == ("NZ")))
           && (!(mUserItem.country == ("Australia")) && !(mUserItem.country == ("AU")))
           && (!(mUserItem.country == ("United Kingdom")) && !(mUserItem.country == ("GB")))
           && (!(mUserItem.country == ("Germany")) && !(mUserItem.country == ("DE")))){
            result = true;
        }
    }
    FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LSLCAutoInviteFilter::CheckCountryCondition(result : %d) end", result);
    return result;
}

list<string> LSLCAutoInviteFilter::GetValidCustomTemplateList(const vector<string>& contents, const vector<bool>& flags) {
    list<string> list;
    if (contents.size() == flags.size()) {
        for (int i = 0; i < contents.size(); i++) {
            if (flags[i]) {
                list.push_back(contents[i]);
            }
        }
    }
    return list;
}

void LSLCAutoInviteFilter::Lock() {
    if (NULL != mInviteMapLock) {
        mInviteMapLock->Lock();
    }
}

void LSLCAutoInviteFilter::Unlock() {
    if (NULL != mInviteMapLock) {
        mInviteMapLock->Unlock();
    }
}

void LSLCAutoInviteFilter::RequestHandler(RequestItem* item) {
    switch (item->requestType)
    {
        case REQUEST_TASK_Unknow:break;
        case REQUEST_TASK_GetLadyCondition:{
            // 获取女士条件
            LSLCAutoInviteItem* inviteItem = (LSLCAutoInviteItem*)item->param;
            if (NULL != inviteItem) {
                if (!GetLadyCondition(inviteItem->womanId)) {
                    // 请求失败就删除
                    LSLCAutoInviteItem* item = ClearAutoInviteById(inviteItem->womanId);
                    if (item != NULL) {
                        delete item;
                        item = NULL;
                    }
                }
            }
        }break;
        case REQUEST_TASK_GetLadyCustomTemplate:{
            // 获取女士模版
            string womanId = "";
            LSLCAutoInviteItem* inviteItem = (LSLCAutoInviteItem*)item->param;
            if (NULL != inviteItem) {
                if (!GetLadyCustomTemplate(inviteItem->womanId)) {
                    // 请求失败就删除
                    LSLCAutoInviteItem* item = ClearAutoInviteById(inviteItem->womanId);
                    if (item != NULL) {
                        delete item;
                        item = NULL;
                    }
                }
            }

        }break;
            
    }
}

/* -------------------------------------   ILSLiveChatClientListener   --------------------------------- */
void LSLCAutoInviteFilter::OnGetLadyCondition(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const LadyConditionItem& item) {
    FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LSLCAutoInviteFilter::OnGetLadyCondition(err : %d, errmsg : %s) begin", err, errmsg.c_str());
    LSLCAutoInviteItem* inviteItem = NULL;
    if (err == LSLIVECHAT_LCC_ERR_SUCCESS) {
        if (CheckConditionMap(item)) {
            // 当上面的条件成功，就获取女士模版（加进线程获取）
            if (inUserId.length() > 0) {
                Lock();
                // 查找自动邀请
                AutoInviteMap::const_iterator inviteIter = mSystemInviteMap.find(inUserId);
                if (inviteIter != mSystemInviteMap.end()) {
                    inviteItem = (*inviteIter).second;
                }
                Unlock();
            }
            RequestItem* requestItem = new RequestItem();
            requestItem->requestType = REQUEST_TASK_GetLadyCustomTemplate;
            requestItem->param = (TaskParam)inviteItem;
            mOperator->InsertRequestTask(this, (TaskParam)requestItem);
        } else {
            inviteItem = ClearAutoInviteById(inUserId);
            if (NULL != inviteItem) {
                delete inviteItem;
            }
        }

    } else {
        inviteItem = ClearAutoInviteById(inUserId);
        if (NULL != inviteItem) {
            delete inviteItem;
        }
    }
     FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LSLCAutoInviteFilter::OnGetLadyCondition(err : %d, errmsg : %s) end", err, errmsg.c_str());
}

void LSLCAutoInviteFilter::OnGetLadyCustomTemplate(const string& inUserId, LSLIVECHAT_LCC_ERR_TYPE err, const string& errmsg, const vector<string>& contents, const vector<bool>& flags) {
    FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LSLCAutoInviteFilter::OnGetLadyCustomTemplate(err : %d, errmsg : %s) begin", err, errmsg.c_str());
    LSLCAutoInviteItem* item = ClearAutoInviteById(inUserId);
    list<string> tempList = GetValidCustomTemplateList(contents, flags);
    if(tempList.size() > 0){
        // 随机从列表抽出邀请
        int position = GetRandomValue() % tempList.size();
        string strTemplate = "";
        int i = 0;
        for (list<string>::const_iterator iter = tempList.begin(); iter != tempList.end(); iter++, i++) {
            if (i == position) {
                strTemplate = (*iter);
            }
        }
        CreateSystemInviteMessage(item, strTemplate);
    }
     FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LSLCAutoInviteFilter::OnGetLadyCustomTemplate(err : %d, errmsg : %s) end", err, errmsg.c_str());
}

void LSLCAutoInviteFilter::CreateSystemInviteMessage(LSLCAutoInviteItem* inviteItem, const string& message) {
    FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LSLCAutoInviteFilter::CreateSystemInviteMessage(inviteItem : %p, message : %s, mOperator : %p) begin", inviteItem, message.c_str(), mOperator);
    if (inviteItem != NULL && mOperator != NULL) {
        mOperator->OnAutoInviteFilterCallback(inviteItem, message);
    }
    FileLevelLog("LiveChatManager", KLog::LOG_WARNING, "LSLCAutoInviteFilter::CreateSystemInviteMessage() end");
}

/* --------------------------------   ILSLiveChatManManagerTaskCallback   ----------------------------- */
void LSLCAutoInviteFilter::OnLiveChatManManagerTaskRun(TaskParam param) {
    RequestItem* item = (RequestItem *)param;
    if( item ) {
        RequestHandler(item);
        delete item;
    }
}

void LSLCAutoInviteFilter::OnLiveChatManManagerTaskClose(TaskParam param) {
    RequestItem* item = (RequestItem *)param;
    if( item ) {
        delete item;
    }
}
