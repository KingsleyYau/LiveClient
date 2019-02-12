/*
 * author: Samson.Fan
 *   date: 2015-10-21
 *   file:LiveMessageItem.h
 *   desc: 直播聊天消息item
 */

#pragma once

#include "LMPrivateMsgItem.h"
#include "ILiveMessageDef.h"
#include <httpcontroller/HttpRequestController.h>
#include <ImClient/IImClient.h>
//#include "LCEmotionItem.h"
//#include "LCVoiceItem.h"
//#include "LCPhotoItem.h"
//#include "LCVideoItem.h"
//#include "LCSystemItem.h"
//#include "LCCustomItem.h"
//#include "LCMagicIconItem.h"
//#include <livechat/ILiveChatClient.h>
#include <string>
#include <list>
using namespace std;

//class LCEmotionManager;
//class LCVoiceManager;
//class LCPhotoManager;
//class LCVideoManager;
//class LCMagicIconManager;
//class LCUserItem;
class Record;
class IAutoLock;
class LiveMessageItem
{
public:
//    // 消息类型定义
//    typedef enum  {
//        LMMT_Unknow,        // 未知类型
//        LMMT_Text,          // 私信消息
////        MT_Warning,        // 警告消息
////        MT_Emotion,        // 高级表情
////        MT_Voice,        // 语音
////        MT_MagicIcon,   // 小高级表情
////        MT_Photo,        // 私密照
////        MT_Video,        // 微视频
////        MT_System,        // 系统消息
////        MT_Custom,        //自定义消息
//    } LMMessageType;
//
//    // 消息发送方向 类型
//    typedef enum  {
//        LMSendType_Unknow,        // 未知类型
//        LMSendType_Send,            // 发出
//        LMSendType_Recv,            // 接收
//        //SendType_System,        // 系统
//    } LMSendType;
//
//    // 处理状态
//    typedef enum {
//        LMStatusType_Unprocess,        // 未处理
//        LMStatusType_Processing,      // 处理中
//        LMStatusType_Fail,            // 发送失败
//        LMStatusType_Finish,          // 发送完成/接收成功
//    } LMStatusType;
//
//    // 处理（发送/接收/购买）结果
//    class ProcResult
//    {
//    public:
//        ProcResult() {
//            SetSuccess();
//        }
//        virtual ~ProcResult() {}
//    public:
//        void SetSuccess() {
//            m_errType = LCC_ERR_SUCCESS;
//            m_errNum = "";
//            m_errMsg = "";
//        }
//        void SetResult(LCC_ERR_TYPE errType, const string& errNum, const string& errMsg) {
//            m_errType = errType;
//            m_errNum = errNum;
//            m_errMsg = errMsg;
//        }
//    public:
//        LCC_ERR_TYPE    m_errType;    // 处理结果类型
//        string    m_errNum;            // 处理结果代码
//        string    m_errMsg;            // 处理结果描述
//    };

public:
    LiveMessageItem();
    virtual ~LiveMessageItem();

public:
    // 初始化
    bool Init(
            int sendMsgId
            , int msgId
            , LMSendType sendType
            , const string& fromId
            , const string& toId
            , const string& nickName
            , const string& avatarImg
            , LMStatusType statusType);
    // http私信消息更新私信信息
    bool UpdateMessage(const HttpPrivateMsgItem& item, LMSendType sendType);
    // IM私信消息更新私信信息
    bool UpdateMessageFromIm(const IMPrivateMessageItem& item, LMSendType sendType);
    // 获取生成时间
    static long GetCreateTime();
    // 更新生成时间
    void RenewCreateTime();
    // 设置服务器当前数据库时间
    static void SetDbTime(long dbTime);
    // 把服务器时间转换为手机时间
    static long GetLocalTimeWithServerTime(long serverTime);
//    // 使用Record初始化MessageItem
//    bool InitWithRecord(
//                    int msgId
//                    , const string& selfId
//                    , const string& userId
//                    , const string& inviteId
//                    , const Record& record);
//    // 设置语音item
//    void SetVoiceItem(LCVoiceItem* theVoiceItem);
//    // 获取语音item
//    LCVoiceItem* GetVoiceItem() const;
//    // 设置图片item
//    void SetPhotoItem(LCPhotoItem* thePhotoItem);
//    // 获取图片item
//    LCPhotoItem* GetPhotoItem() const;
//    // 设置视频item
//    void SetVideoItem(lcmm::LCVideoItem* theVideoItem);
//    // 获取视频item
//    lcmm::LCVideoItem* GetVideoItem() const;
    // 设置私信item
    void SetPrivateMsgItem(LMPrivateMsgItem* thePrivateItem);
    // 获取私信item
    LMPrivateMsgItem* GetPrivateMsgItem() const;
//    // 设置warning item
//    void SetWarningItem(LCWarningItem* theWarningItem);
//    // 获取warning item
//    LCWarningItem* GetWarningItem() const;
//    // 设置高级表情item
//    void SetEmotionItem(LCEmotionItem* theEmotionItem);
//    // 获取高级表情item
//    LCEmotionItem* GetEmotionItem() const;
//    // 设置系统消息item
//    void SetSystemItem(LCSystemItem* theSystemItem);
//    // 获取系统消息item
//    LCSystemItem* GetSystemItem() const;
//    // 设置自定义消息item
//    void SetCustomItem(LCCustomItem* theCustomItem);
//    // 获取自定义消息item
//    LCCustomItem* GetCustomItem() const;
//    // 判断子消息item（如：语音、图片、视频等）是否正在处理
//    bool IsSubItemProcssign() const;
//    //  设置小高级表情item alex 2016－09-12
//    void SetMagicIconItem(LCMagicIconItem* theMagicIconItem);
//    //  设置小高级表情item alex 2016-09-12
//    LCMagicIconItem* GetMagicIconItem() const;
//    // 设置用户item
//    void SetUserItem(LCUserItem* theUserItem);
//    // 获取用户item
//    LCUserItem* GetUserItem() const;
    // 重置所有成员变量
    void Clear();

    // 排序函数
    static bool Sort(const LiveMessageItem* item1, const LiveMessageItem* item2);
    
    // 判断是否聊天消息
    bool IsChatMessage();
    
    // 状态加锁
    void Lock();
    // 状态解锁
    void Unlock();

public:
    int              m_sendMsgId;   // 本地消息ID （用于发送时才有的，当发送成功后，返回有msgId，本地消息ID设置为0）
    int              m_msgId;       // 消息ID
    LMSendType       m_sendType;    // 消息发送方向
    string           m_fromId;      // 发送者ID
    string           m_toId;        // 接收者ID
    string           m_nickName;    // 对方的昵称
    string           m_avatarImg;   // 对方头像URL
    long             m_createTime;    // 接收/发送时间
    LMStatusType     m_statusType;    // 处理状态
    LMMessageType    m_msgType;        // 消息类型
    //ProcResult        m_procResult;    // 处理(发送/接收/购买)结果
    
    IAutoLock*        m_updateLock;     // 消息修改锁(用于用户数据改变),一般用在外面，里面不加
    
private:
    LMPrivateMsgItem*   m_textItem;        // 私信item
//    LCUserItem*        m_userItem;        // 用户item

    static long        m_diffTime;        // 服务器数据库当前时间
    
};
typedef list<LiveMessageItem*>    LMMessageList;


