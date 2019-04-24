/*
 * HttpLoginItem.h
 *
 *  Created on: 2017-5-19
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LOGINITEM_H_
#define LOGINITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"

class HttpLoginItem {
public:
    class SvrItem {
    public:
        bool Parse(const Json::Value& root) {
            bool result = false;
            /* svrId */
            if (root[LOGIN_SVRLIST_SVRID].isString()) {
                svrId = root[LOGIN_SVRLIST_SVRID].asString();
            }
            /* tUrl */
            if (root[LOGIN_SVRLIST_TURL].isString()) {
                tUrl = root[LOGIN_SVRLIST_TURL].asString();
            }
            result = true;
            return result;
        }
        
        SvrItem() {
            svrId = "";
            tUrl = "";
        }
        
        virtual ~SvrItem() {
        
        }
        /**
         *  流媒体服务器
         *  svrId       流媒体服务器ID
         *  tUrl        流媒体服务器测速url
         */
        string      svrId;
        string      tUrl;
    };
    typedef list<SvrItem> SvrList;
    
    class HttpUserSendMailPrivItem {
    public:
        bool Parse(const Json::Value& root) {
            bool result = false;
            /* isPriv */
            if (root[LOGIN_MAILPRIV_USERSENDMAILIMGPRIV_ISPRIV].isNumeric()) {
                isPriv = GetLSSendImgRiskType(root[LOGIN_MAILPRIV_USERSENDMAILIMGPRIV_ISPRIV].asInt());
            }
            /* maxImg */
            if (root[LOGIN_MAILPRIV_REPLY_USERSENDMAILIMGPRIV_MAX_IMG].isNumeric()) {
                maxImg = root[LOGIN_MAILPRIV_REPLY_USERSENDMAILIMGPRIV_MAX_IMG].asInt();
            }
            /* postStampMsg */
            if (root[LOGIN_MAILPRIV_REPLY_USERSENDMAILIMGPRIV_POSTSTAMPMSG].isString()) {
                postStampMsg = root[LOGIN_MAILPRIV_REPLY_USERSENDMAILIMGPRIV_POSTSTAMPMSG].asString();
            }
            /* coinMsg */
            if (root[LOGIN_MAILPRIV_REPLY_USERSENDMAILIMGPRIV_COINMSG].isString()) {
                coinMsg = root[LOGIN_MAILPRIV_REPLY_USERSENDMAILIMGPRIV_COINMSG].asString();
            }
            /* quickPostStampMsg */
            if (root[LOGIN_MAILPRIV_QUICKREPLY_USERSENDMAILIMGPRIV_POSTSTAMPMSG].isString()) {
                quickPostStampMsg = root[LOGIN_MAILPRIV_QUICKREPLY_USERSENDMAILIMGPRIV_POSTSTAMPMSG].asString();
            }
            /* quickCoinMsg */
            if (root[LOGIN_MAILPRIV_QUICKREPLY_USERSENDMAILIMGPRIV_COINMSG].isString()) {
                quickCoinMsg = root[LOGIN_MAILPRIV_QUICKREPLY_USERSENDMAILIMGPRIV_COINMSG].asString();
            }
            result = true;
            return result;
        }
        
        HttpUserSendMailPrivItem() {
            maxImg = 0;
            isPriv = LSSENDIMGRISKTYPE_NORMAL;
            postStampMsg = "";
            coinMsg = "";
        }
        
        virtual ~HttpUserSendMailPrivItem() {
            
        }
        /**
         *  发送照片相关
         *  isPriv              发送照片权限（0：正常，1：只能发免费，2：只能发付费，3：不能发照片）
         *  maxImg              单封信件可发照片最大数
         *  postStampMsg        邮票回复/发送照片提示
         *  coinMsg             信用点回复/发送照片提示
         *  quickPostStampMsg        邮票快速回复照片提示
         *  quickCoinMsg             信用点快速回复照片提示
         */
        LSSendImgRiskType      isPriv;
        int       maxImg;
        string    postStampMsg;
        string    coinMsg;
        string    quickPostStampMsg;
        string    quickCoinMsg;
        
    };
    
    class HttpMailPrivItem {
    public:
        bool Parse(const Json::Value& root) {
            bool result = false;
            /* userSendMailPriv */
            if (root[LOGIN_USER_PRIV_MAILPRIV_USERSENDMAILPRIV].isNumeric()) {
                userSendMailPriv = root[LOGIN_USER_PRIV_MAILPRIV_USERSENDMAILPRIV].asInt() == 1 ? true : false;
            }
            /* userSendMailImgPriv */
            if (root[LOGIN_USER_PRIV_MAILPRIV_USERSENDMAILIMGPRIV].isObject()) {
                userSendMailImgPriv.Parse(root[LOGIN_USER_PRIV_MAILPRIV_USERSENDMAILIMGPRIV]);
            }
            result = true;
            return result;
        }
        
        HttpMailPrivItem() {
            userSendMailPriv = true;
        }
        
        virtual ~HttpMailPrivItem() {
            
        }
        /**
         *  信件及意向信权限相关
         *  userSendMailPriv       是否有权限发送信件
         *  userSendMailImgPriv    发送照片相关
         */
        bool                         userSendMailPriv;
        HttpUserSendMailPrivItem      userSendMailImgPriv;
    };
    
    class HttpLiveChatPrivItem {
    public:
        bool Parse(const Json::Value& root) {
            bool result = false;
            /* isLiveChatPriv */
            if(root[LOGIN_USER_PRIV_LIVECHAT_LIVECHAT_PRIV].isNumeric()) {
                isLiveChatPriv = root[LOGIN_USER_PRIV_LIVECHAT_LIVECHAT_PRIV].asInt() == 1 ? true : false;
            }
            
            /* liveChatInviteRiskType */
            if(root[LOGIN_USER_PRIV_LIVECHAT_LIVECHAT_INVITE].isNumeric()) {
                liveChatInviteRiskType = GetLSHttpliveChatInviteRiskType(root[LOGIN_USER_PRIV_LIVECHAT_LIVECHAT_INVITE].asInt());
            }
            
            /* isSendLiveChatPhotoPriv */
            if(root[LOGIN_USER_PRIV_LIVECHAT_PRIVMBPPSENDVIALIVECHAT].isNumeric()) {
                isSendLiveChatPhotoPriv = root[LOGIN_USER_PRIV_LIVECHAT_PRIVMBPPSENDVIALIVECHAT].asInt() == 1 ? true : false;
            }
            /* isSendLiveChatVoicePriv */
            if(root[LOGIN_USER_PRIV_LIVECHAT_PRIVMBLIVECHATINVITATIONVOICE].isNumeric()) {
                isSendLiveChatVoicePriv = root[LOGIN_USER_PRIV_LIVECHAT_PRIVMBLIVECHATINVITATIONVOICE].asInt() == 1 ? true : false;
            }
            result = true;
            return result;
        }
        
        HttpLiveChatPrivItem() {
            isLiveChatPriv = true;
            liveChatInviteRiskType = LSHTTP_LIVECHATINVITE_RISK_NOLIMIT;
            isSendLiveChatPhotoPriv = true;
            isSendLiveChatVoicePriv = true;
        }
        
        virtual ~HttpLiveChatPrivItem() {
            
        }
        /**
         *  LiveChat权限相关
         *  isLiveChatPriv              LiveChat聊天总权限（0：禁止，1：正常，默认：1）
         *  liveChatInviteRiskType      聊天邀请（LSHTTP_LIVECHATINVITE_RISK_NOLIMIT：不作任何限制 ，
                                                 LSHTTP_LIVECHATINVITE_RISK_LIMITSEND：限制发送信息，
                                                 LSHTTP_LIVECHATINVITE_RISK_LIMITREV：限制接受邀请，
                                                 LSHTTP_LIVECHATINVITE_RISK_LIMITALL：收发全部限制）
         *  isSendLiveChatPhotoPriv     观众发送私密照权限（0：禁止，1：正常，默认：1）
         *  isSendLiveChatVoicePriv     观众发送语音权限（0：禁止，1：正常，默认：1）
         */
        bool                         isLiveChatPriv;
        LSHttpLiveChatInviteRiskType liveChatInviteRiskType;
        bool                         isSendLiveChatPhotoPriv;
        bool                         isSendLiveChatVoicePriv;
    };
    
    class HttpHangoutPrivItem {
    public:
        bool Parse(const Json::Value& root) {
            bool result = false;
            /* isHangoutPriv */
            if(root[LOGIN_USER_PRIV_HANGOUT_HANGOUTPRIV].isNumeric()) {
                isHangoutPriv = root[LOGIN_USER_PRIV_HANGOUT_HANGOUTPRIV].asInt() == 1 ? true : false;
            }
            
            result = true;
            return result;
        }
        
        HttpHangoutPrivItem() {
            isHangoutPriv = true;
        }
        
        virtual ~HttpHangoutPrivItem() {
            
        }
        /**
         *  Hangout权限相关
         *  isHangoutPriv            Hangout总权限（0：禁止，1：正常，默认：0）
         */
        bool                         isHangoutPriv;
    };
    
    class HttpUserPrivItem {
    public:
        bool Parse(const Json::Value& root) {
            bool result = false;
            /* liveChatPriv */
            if(root[LOGIN_USER_PRIV_LIVECHAT].isObject()) {
                liveChatPriv.Parse(root[LOGIN_USER_PRIV_LIVECHAT]);
            }
            /* mailPriv */
            if(root[LOGIN_USER_PRIV_MAILPRIV].isObject()) {
                mailPriv.Parse(root[LOGIN_USER_PRIV_MAILPRIV]);
            }
            /* hangoutPriv */
            if(root[LOGIN_USER_PRIV_HANGOUT].isObject()) {
                hangoutPriv.Parse(root[LOGIN_USER_PRIV_HANGOUT]);
            }
            /* isSayHiPriv */
            if(root[LOGIN_USER_PRIV_SAYHI].isNumeric()) {
                isSayHiPriv = root[LOGIN_USER_PRIV_SAYHI].asInt() == 0 ? false : true;
            }
            result = true;
            return result;
        }
        
        HttpUserPrivItem() {
            isSayHiPriv = true;
        }
        
        virtual ~HttpUserPrivItem() {
            
        }
        /**
         *  信件及意向信权限相关
         *  liveChatPriv        LiveChat权限相关
         *  mailPriv            信件及意向信权限相关
         *  hangoutPriv         Hangout权限相关
         *  isSayHiPriv         SayHi权限(1:有  0:无)
         */
        HttpLiveChatPrivItem         liveChatPriv;
        HttpMailPrivItem             mailPriv;
        HttpHangoutPrivItem          hangoutPriv;
        bool                         isSayHiPriv;
    };
    
    void Parse(const Json::Value& root) {
        if( root.isObject() ) {
            /* userId */
            if( root[LOGIN_USERID].isString() ) {
                userId = root[LOGIN_USERID].asString();
            }
            
            /* token */
            if( root[LOGIN_TOKEN].isString() ) {
                token = root[LOGIN_TOKEN].asString();
            }
            
            /* sessionId */
            if( root[LOGIN_SESSIONID].isString() ) {
                sessionId = root[LOGIN_SESSIONID].asString();
            }
            
            /* nickName */
            if( root[LOGIN_NICKNAME].isString() ) {
                nickName = root[LOGIN_NICKNAME].asString();
            }
            
            /* level */
            if( root[LOGIN_LEVEL].isInt() ) {
                level = root[LOGIN_LEVEL].asInt();
            }
            
            /* experience */
            if( root[LOGIN_EXPERIENCE].isInt() ) {
                experience = root[LOGIN_EXPERIENCE].asInt();
            }
            
            /* photourl */
            if( root[LOGIN_PHOTOURL].isString() ) {
                photoUrl = root[LOGIN_PHOTOURL].asString();
            }
            
            /* isPushAd */
            if( root[LOGIN_ISPUSHAD].isNumeric()) {
                isPushAd = root[LOGIN_ISPUSHAD].asInt();
            }
            
            /* svrList */
            if( root[LOGIN_SVRLIST].isArray()) {
                for (int i = 0; i < root[LOGIN_SVRLIST].size(); i++) {
                    Json::Value element = root[LOGIN_SVRLIST].get(i, Json::Value::null);
                    SvrItem item;
                    if (item.Parse(element)) {
                        svrList.push_back(item);
                    }
                }
            }
            
            /* userType */
            if(root[LOGIN_USERTYPE].isNumeric()) {
                userType = GetIntToUserType(root[LOGIN_USERTYPE].asInt());
            }
            
            /* qnMainAdUrl */
            if( root[LOGIN_QNMAINADURL].isString() ) {
                qnMainAdUrl = root[LOGIN_QNMAINADURL].asString();
            }

            /* qnMainAdTitle */
            if( root[LOGIN_QNMAINADTITLE].isString() ) {
                qnMainAdTitle = root[LOGIN_QNMAINADTITLE].asString();
            }

            /* qnMainAdId */
            if( root[LOGIN_QNMAINADID].isString() ) {
                qnMainAdId = root[LOGIN_QNMAINADID].asString();
            }
            
            /* gaUid */
            if( root[LOGIN_GAUID].isString() ) {
                gaUid = root[LOGIN_GAUID].asString();
            }
            
            /* isLiveChatRisk */
            if(root[LOGIN_LIVECHAT].isNumeric()) {
                isLiveChatRisk = root[LOGIN_LIVECHAT].asInt() == 1 ? true : false;
            }
            
            /* isHangoutRisk */
            if(root[LOGIN_HANGOUTPRIV].isNumeric()) {
                isHangoutRisk = root[LOGIN_HANGOUTPRIV].asInt() == 1 ? true : false;
            }

            /* liveChatInviteRiskType */
            if(root[LOGIN_LIVECHAT_INVITE].isNumeric()) {
                liveChatInviteRiskType = GetLSHttpliveChatInviteRiskType(root[LOGIN_LIVECHAT_INVITE].asInt());
            }
//
//            /* mailPriv */
//            if(root[LOGIN_MAILPRIV].isObject()) {
//                mailPriv.Parse(root[LOGIN_MAILPRIV]);
//            }
            
            /* userPriv */
            if(root[LOGIN_USER_PRIV].isObject()) {
                userPriv.Parse(root[LOGIN_USER_PRIV]);
            }
            
        }
        
    }
    
    HttpLoginItem() {
        userId = "";
        token = "";
        sessionId = "";
        nickName = "";
        level = 0;
        experience = 0;
        photoUrl = "";
        isPushAd = false;
        userType = USERTYPEA1;
        qnMainAdUrl = "";
        qnMainAdTitle = "";
        qnMainAdId = "";
        gaUid = "";
        isLiveChatRisk = false;
        isHangoutRisk = false;
        liveChatInviteRiskType = LSHTTP_LIVECHATINVITE_RISK_NOLIMIT;
    }
    
    virtual ~HttpLoginItem() {
        
    }
    /**
     * 登录成功结构体
     * userId			用户ID
     * token            直播系统不同服务器的统一验证身份标识
     * sessionId        唯一身份标识用于登录LiveChat服务器
     * nickName         昵称
     * levenl			级别
     * experience		经验值
     * photoUrl		    头像url
     * isPushAd		    是否打开广告（0:否 1:是）
     * svrList          流媒体服务器ID
     * userType         观众用户类型（1:A1类型 2:A2类型）（A1类型：仅可看付费公开及豪华私密直播间，A2类型：可看所有直播间）
     * qnMainAdUrl      QN主界面广告浮层的URL（可无，无则表示不弹广告）
     * qnMainAdTitle    QN主界面广告浮层的标题（可无）
     * qnMainAdId       QN主界面广告浮层的ID（可无，无则表示不弹广告）
     * gaUid            Google Analytics UserID参数
     * isLiveChatRisk       LiveChat详细风控标识（1：有风控，0：无，默认：0）
     * isHangoutRisk        多人互动风控标识（1：有风控，0：无，默认：0）
     * liveChatInviteRiskType   聊天邀请（LSHTTP_LIVECHATINVITE_RISK_NOLIMIT：不作任何限制 ，
                                         LSHTTP_LIVECHATINVITE_RISK_LIMITSEND：限制发送信息，
                                         LSHTTP_LIVECHATINVITE_RISK_LIMITREV：限制接受邀请，
                                         LSHTTP_LIVECHATINVITE_RISK_LIMITALL：收发全部限制）
     *
     * mailPriv   信件及意向信权限相关
     * userPriv   信件及意向信权限相关
     */
    string userId;
    string token;
    string sessionId;
    string nickName;
    int level;
    int experience;
    string photoUrl;
    bool isPushAd;
    SvrList svrList;
    UserType userType;
    string qnMainAdUrl;
    string qnMainAdTitle;
    string qnMainAdId;
    string gaUid;
    bool isLiveChatRisk;
    bool isHangoutRisk;
    LSHttpLiveChatInviteRiskType liveChatInviteRiskType;
//    HttpMailPrivItem mailPriv;
    HttpUserPrivItem userPriv;
};

#endif /* LOGINITEM_H_ */
