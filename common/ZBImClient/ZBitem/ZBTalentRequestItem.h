/*
 * ZBTalentRequestItem.h
 *
 *  Created on: 2018-03-07
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 *      Des: 才艺点播请求结构体
 */

#ifndef ZBTALENTREQUESTITEM_H_
#define ZBTALENTREQUESTITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#define TALENTINVITEID_PARAM        "talent_inviteid"
#define NAME_PARAM                  "name"
#define USERID_PARAM                "userid"
#define NICKNAME_PARAM              "nickname"


class ZBTalentRequestItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* talentInviteId */
            if (root[TALENTINVITEID_PARAM].isString()) {
                talentInviteId = root[TALENTINVITEID_PARAM].asString();
            }
            /* name */
            if (root[NAME_PARAM].isString()) {
                name = root[NAME_PARAM].asString();
            }
            /* userId */
            if (root[USERID_PARAM].isString()) {
                userId = root[USERID_PARAM].asString();
            }
            /* nickName */
            if (root[NICKNAME_PARAM].isString()) {
                nickName = root[NICKNAME_PARAM].asString();
            }

        }
        result = true;
        return result;
    }
    
    ZBTalentRequestItem() {
        talentInviteId = "";
        name = "";
        userId = "";
        nickName = "";
    }
    
    virtual ~ZBTalentRequestItem() {
        
    }
    /**
     * 才艺点播请求结构体
     * talentInviteId         才艺邀请ID
     * name                   才艺点播名称
     * userId                 观众ID
     * nickName               观众昵称
     */
    string                talentInviteId;
    string                name;
    string                userId;
    string                nickName;

};

#endif /* ZBTALENTREQUESTITEM_H_*/
