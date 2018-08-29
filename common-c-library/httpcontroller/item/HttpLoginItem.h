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
            
        }
        
    }
    
    HttpLoginItem() {
        userId = "";
        token = "";
        nickName = "";
        level = 0;
        experience = 0;
        photoUrl = "";
        isPushAd = false;
        userType = USERTYPEA1;
        qnMainAdUrl = "";
        qnMainAdTitle = "";
        qnMainAdId = "";
    }
    
    virtual ~HttpLoginItem() {
        
    }
    /**
     * 登录成功结构体
     * userId			用户ID
     * token            直播系统不同服务器的统一验证身份标识
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
     */
    string userId;
    string token;
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
};

#endif /* LOGINITEM_H_ */
