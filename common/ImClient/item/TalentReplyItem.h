/*
 * TalentReplyItem.h
 *
 *  Created on: 2017-09-28
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef TALENTREPLYITEM_H_
#define TALENTREPLYITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#define ROOMID_TALENT_PARAM         "roomid"
#define TALENTINVITEID_PARAM        "talent_inviteid"
#define TALENTID_PARAM              "talentid"
#define NAME_PARAM                  "name"
#define CREDIT_PARAM                "credit"
#define STATUS_PARAM                "status"
#define REBATECREDIT                "rebate_credit"
#define GIFTID_PARAM                "gift_id"
#define GIFTNAME_PARAM              "gift_name"
#define GIFTNUM_PARAM               "gift_num"


class TalentReplyItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* roomId */
            if (root[ROOMID_TALENT_PARAM].isString()) {
                roomId = root[ROOMID_TALENT_PARAM].asString();
            }
            /* talentInviteId */
            if (root[TALENTINVITEID_PARAM].isString()) {
                talentInviteId = root[TALENTINVITEID_PARAM].asString();
            }
            /* talentId */
            if (root[TALENTID_PARAM].isString()) {
                talentId = root[TALENTID_PARAM].asString();
            }
            /* name */
            if (root[NAME_PARAM].isString()) {
                name = root[NAME_PARAM].asString();
            }
            /* credit */
            if (root[CREDIT_PARAM].isNumeric()) {
                credit = root[CREDIT_PARAM].asDouble();
            }
            /* status */
            if (root[STATUS_PARAM].isIntegral()) {
                status = GetIntToTalentStatus(root[STATUS_PARAM].asInt());
            }
            /* rebateCredit */
            if (root[REBATECREDIT].isNumeric()) {
                rebateCredit = root[REBATECREDIT].asDouble();
            }

            /* giftId */
            if (root[GIFTID_PARAM].isString()) {
                giftId = root[GIFTID_PARAM].asString();
            }
            
            /* giftName */
            if (root[GIFTNAME_PARAM].isString()) {
                giftName = root[GIFTNAME_PARAM].asString();
            }
            
            /* giftNum */
            if (root[GIFTNUM_PARAM].isNumeric()) {
                giftNum = root[GIFTNUM_PARAM].asInt();
            }
            
        }
        result = true;
        return result;
    }
    
    TalentReplyItem() {
        roomId = "";
        talentInviteId = "";
        talentId = "";
        name = "";
        credit = 0.0;
        status = TALENTSTATUS_UNKNOW;
        rebateCredit = 0.0;
        giftId = "";
        giftName = "";
        giftNum = 0;
    }
    
    virtual ~TalentReplyItem() {
        
    }
    /**
     * 才艺回复通知结构体
     * roomId                 直播间ID
     * talentInviteId         才艺邀请ID
     * talentId               才艺ID
     * name                   才艺名称
     * credit                 信用点
     * status                 状态（1:已接受 2:拒绝）
     * rebateCredit           返点
     * giftId                 礼物ID
     * giftName               礼物名称
     * giftNum                礼物数量
     */
    string                roomId;
    string                talentInviteId;
    string                talentId;
    string                name;
    double                credit;
    TalentStatus          status;
    double                rebateCredit;
    string                giftId;
    string                giftName;
    int                   giftNum;
    
};

#endif /* TALENTREPLYITEM_H_*/
