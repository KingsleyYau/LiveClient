/*
 * author: Samson.Fan
 *   date: 2018-06-21
 *   file: LMPrivateContactManager.h
 *   desc: 私信联系人管理类
 */

#pragma once

#include "LMUserItem.h"
#include <string>
using namespace std;

//class ILiveChatClient;
class LMUserManager;
class LMUserItem;
class LiveMessageItem;
class IAutoLock;
//class Counter;

class LMPrivateContactManager
{
//public:
//    // 邀请消息处理结果类型
//    typedef enum {
//        LOST,    // 丢弃
//        PASS,    // 通过
//        HANDLE,    // 需要处理
//    } HandleInviteMsgType;

public:
    LMPrivateContactManager();
    virtual ~LMPrivateContactManager();

public:
    // 初始化
    bool Init(LMUserManager* userMgr);

public:
    // ----------- 私信联系人公开操作 begin---------------------
    // 更新私信联系人列表（将本地的私信联系人列表删除，在增加进去，需要时间排列，）
    bool UpdatePrivateContactList(const IMPrivateMessageItem& item);
    // 刷新私信联系人列表（将本地的私信联系人列表删除，在增加进去，需要时间排列，）
    void RefreshPrivateContactList(const HttpPrivateMsgContactList& list, long dbtime);
    // 获取系统时间标志
    bool GetSynTimeMark();
    // ----------- 私信联系人公开操作 end---------------------
    
public:
//    // 增加或修改私信联系人列表的数据
//    bool UpdatePrivateContactList(const LMUserList& privateList);
    // 增加或修改关注私信联系人列表的数据
    bool UpdateFollowPrivateContactList(const LMUserList& privateList);

    // 获取私信联系人列表
    LMUserList GetContactList();
    // 获取关注私信联系人列表
    LMUserList GetFollowContactList();
    
    // 获取用户item（不存在不创建）
    LMUserItem* GetUserNotCreate(const string& userId);
    // 获取用户item（不存在则创建）
    LMUserItem* GetUser(const string& userId);
    
    // 移除所有私信联系人列表 和 关注的私信联系人列表
    void RemoveAllUserItem();
    

private:

    // 联系人用户列表加锁
    void LockContactList();
    // 联系人用户列表解锁
    void UnlockContactList();
    // 对私信联系人排序
    void SortContactList();
    // 比较函数
    static bool Sort(LMUserItem* item1, LMUserItem* item2);

private:
    bool                    m_isInit;                       // 是否已初始化
    //ILiveChatClient*      m_liveChatClient;               // LiveChat客户端
    LMUserManager*          m_userMgr;                      // 直播用户管理器
    LMUserList              m_privateContactList;           // 私信联系人列表
    IAutoLock*              m_privateContactListLock;       // 私信联系人列表锁
    
    LMUserList              m_followContactList;            // 关注的私信联系人列表
    IAutoLock*              m_followContactListLock;        // 关注的私信联系人列表锁

};


