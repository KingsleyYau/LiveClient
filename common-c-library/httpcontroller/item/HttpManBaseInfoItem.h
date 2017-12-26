/*
 * HttpManBaseInfoItem.h
 *
 *  Created on: 2017-12-23
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPMANBASEINFOITEM_H_
#define HTTPMANBASEINFOITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../HttpLoginProtocol.h"

class HttpManBaseInfoItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* userId */
            if (root[LIVEROOM_GETMANBASEINFO_USERID].isString()) {
                userId = root[LIVEROOM_GETMANBASEINFO_USERID].asString();
            }
            /* nickName */
            if (root[LIVEROOM_GETMANBASEINFO_NICKNAME].isString()) {
                nickName = root[LIVEROOM_GETMANBASEINFO_NICKNAME].asString();
            }
            
            /* nickNameStatus */
            if (root[LIVEROOM_GETMANBASEINFO_NICKNAMESTATUS].isNumeric()) {
                nickNameStatus = GetNickNameVerifyStatus(root[LIVEROOM_GETMANBASEINFO_NICKNAMESTATUS].asInt());
            }
   
            /* photoUrl */
            if (root[LIVEROOM_GETMANBASEINFO_PHOTOURL].isString()) {
                photoUrl = root[LIVEROOM_GETMANBASEINFO_PHOTOURL].asString();
            }
            /* photoStatus */
            if (root[LIVEROOM_GETMANBASEINFO_PHOTOSTATUS].isNumeric()) {
                photoStatus = GetPhotoVerifyStatus(root[LIVEROOM_GETMANBASEINFO_PHOTOSTATUS].asInt());
            }
            /* birthday */
            if (root[LIVEROOM_GETMANBASEINFO_BIRTHDAY].isString()) {
                birthday = root[LIVEROOM_GETMANBASEINFO_BIRTHDAY].asString();
            }
            /* userlevel */
            if (root[LIVEROOM_GETMANBASEINFO_USERLEVEL].isNumeric()) {
                userlevel = root[LIVEROOM_GETMANBASEINFO_USERLEVEL].asInt();
            }
        }

        return result;
    }
    
    HttpManBaseInfoItem() {
        userId = "";
        nickName = "";
        nickNameStatus = NICKNAMEVERIFYSTATUS_HANDLDING;
        photoUrl = "";
        photoStatus = PHOTOVERIFYSTATUS_HANDLDING;
        birthday = "";
        userlevel = 0;
    }
    
    virtual ~HttpManBaseInfoItem() {
        
    }
    /**
     * 个人信息
     * userId               观众ID
     * nickName             昵称
     * nickNameStatus       昵称审核状态（0：审核完成，1：审核中）
     * photoUrl             头像url
     * photoStatus          头像审核状态（0：没有头像及审核成功，1：审核中，2：不合格）
     * birthday             生日
     * userlevel            观众等级（整型）
     */
    string userId;
    string nickName;
    NickNameVerifyStatus nickNameStatus;
    string  photoUrl;
    PhotoVerifyStatus  photoStatus;
    string  birthday;
    int     userlevel;
};

#endif /* HTTPMANBASEINFOITEM_H_*/
