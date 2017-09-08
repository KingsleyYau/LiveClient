/*
 * HttpGetTalentStatusItem.h
 *
 *  Created on: 2017-8-29
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPGETTALENTSTATUSITEM_H_
#define HTTPGETTALENTSTATUSITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"

class HttpGetTalentStatusItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* talentInviteId */
            if (root[LIVEROOM_GETTALENTSTATUS_RETURNTALENTINVITEID].isString()) {
                talentInviteId = root[LIVEROOM_GETTALENTSTATUS_RETURNTALENTINVITEID].asString();
            }
            /* talentId */
            if (root[LIVEROOM_GETTALENTSTATUS_TALENTID].isString()) {
                talentId = root[LIVEROOM_GETTALENTSTATUS_TALENTID].asString();
            }
            /* name */
            if (root[LIVEROOM_GETTALENTSTATUS_NAME].isString()) {
                name = root[LIVEROOM_GETTALENTSTATUS_NAME].asString();
            }
            /* credit */
            if (root[LIVEROOM_GETTALENTSTATUS_CREDIT].isDouble()) {
                credit = root[LIVEROOM_GETTALENTSTATUS_CREDIT].asDouble();
            }            /* credit */
            if (root[LIVEROOM_GETTALENTSTATUS_STATUS].isInt()) {
                status = (HTTPTalentStatus)root[LIVEROOM_GETTALENTSTATUS_STATUS].asInt();
            }
        }
        if (!talentId.empty()) {
            result = true;
        }
        return result;
    }
    

    HttpGetTalentStatusItem() {
        talentInviteId = "";
        talentId = "";
        name = "";
        credit = 0.0;
        status = HTTPTALENTSTATUS_UNREPLY;
    }
    
    virtual ~HttpGetTalentStatusItem() {
        
    }
    
    /**
     * 才艺信息结构体
     * talentInviteId     才艺邀请ID
     * talentId           才艺ID
     * name               才艺名称
     * credit             发送礼物所需的信用点
     * status             状态（0:未回复 1:已接受 2:拒绝）
     */
    string talentInviteId;
    string talentId;
    string name;
    double credit;
    HTTPTalentStatus status;
};


#endif /* HTTPGETTALENTSTATUSITEM_H_*/
