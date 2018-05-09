/*
 * IMProgramItem.h
 *
 *  Created on: 2018-04-23
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef IMPROGRAMITEM_H_
#define IMPROGRAMITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#define IMPROGRAMITEM_SHOWLIVEID                 "live_show_id"
#define IMPROGRAMITEM_ANCHORID                   "anchor_id"
#define IMPROGRAMITEM_ANCHORNICKNAME             "anchor_nickname"
#define IMPROGRAMITEM_ANCHORAVATAR               "anchor_avatar"
#define IMPROGRAMITEM_SHOWTITLE                  "show_title"
#define IMPROGRAMITEM_SHOWINTRODUCE              "show_introduce"
#define IMPROGRAMITEM_COVER                      "cover"
#define IMPROGRAMITEM_APPROVETIME                "approve_time"
#define IMPROGRAMITEM_STARTTIME                  "start_time"
#define IMPROGRAMITEM_DURATION                   "duration"
#define IMPROGRAMITEM_LEFTSECTOSTART             "left_sec_to_start"
#define IMPROGRAMITEM_LEFTSECTOENTER             "left_sec_to_enter"
#define IMPROGRAMITEM_PRICE                      "price"
#define IMPROGRAMITEM_STATUS                     "status"
#define IMPROGRAMITEM_TICKETSTATUS               "ticket_status"
#define IMPROGRAMITEM_HASFOLLOW                  "has_follow"
#define IMPROGRAMITEM_TICKETISFULL               "ticket_is_full"


class IMProgramItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* showLiveId */
            if (root[IMPROGRAMITEM_SHOWLIVEID].isString()) {
                showLiveId = root[IMPROGRAMITEM_SHOWLIVEID].asString();
            }
            /* anchorId */
            if (root[IMPROGRAMITEM_ANCHORID].isString()) {
                anchorId = root[IMPROGRAMITEM_ANCHORID].asString();
            }
            /* anchorNickName */
            if (root[IMPROGRAMITEM_ANCHORNICKNAME].isString()) {
                anchorNickName = root[IMPROGRAMITEM_ANCHORNICKNAME].asString();
            }
            /* anchorAvatar */
            if (root[IMPROGRAMITEM_ANCHORAVATAR].isString()) {
                anchorAvatar = root[IMPROGRAMITEM_ANCHORAVATAR].asString();
            }
            /* showTitle */
            if (root[IMPROGRAMITEM_SHOWTITLE].isString()) {
                showTitle = root[IMPROGRAMITEM_SHOWTITLE].asString();
            }
            /* showIntroduce */
            if (root[IMPROGRAMITEM_SHOWINTRODUCE].isString()) {
                showIntroduce = root[IMPROGRAMITEM_SHOWINTRODUCE].asString();
            }
            /* cover */
            if (root[IMPROGRAMITEM_COVER].isString()) {
                cover = root[IMPROGRAMITEM_COVER].asString();
            }
            /* approveTime */
            if (root[IMPROGRAMITEM_APPROVETIME].isNumeric()) {
                approveTime = root[IMPROGRAMITEM_APPROVETIME].asInt();
            }
            
            /* startTime */
            if (root[IMPROGRAMITEM_STARTTIME].isNumeric()) {
                startTime = root[IMPROGRAMITEM_STARTTIME].asInt();
            }
            /* duration */
            if (root[IMPROGRAMITEM_DURATION].isNumeric()) {
                duration = root[IMPROGRAMITEM_DURATION].asInt();
            }
            /* leftSecToStart */
            if (root[IMPROGRAMITEM_LEFTSECTOSTART].isNumeric()) {
                leftSecToStart = root[IMPROGRAMITEM_LEFTSECTOSTART].asInt();
            }
            
            /* leftSecToEnter */
            if (root[IMPROGRAMITEM_LEFTSECTOENTER].isNumeric()) {
                leftSecToEnter = root[IMPROGRAMITEM_LEFTSECTOENTER].asInt();
            }
            
            /* price */
            if (root[IMPROGRAMITEM_PRICE].isNumeric()) {
                price = root[IMPROGRAMITEM_PRICE].asDouble();
            }
            /* status */
            if (root[IMPROGRAMITEM_STATUS].isNumeric()) {
                status = GetIMProgramStatus(root[IMPROGRAMITEM_STATUS].asInt());
            }
            /* ticketStatus */
            if (root[IMPROGRAMITEM_TICKETSTATUS].isNumeric()) {
                ticketStatus = GetIMProgramTicketStatus(root[IMPROGRAMITEM_TICKETSTATUS].asInt());
            }
            /* isHasFollow */
            if (root[IMPROGRAMITEM_HASFOLLOW].isNumeric()) {
                isHasFollow = root[IMPROGRAMITEM_HASFOLLOW].asInt() == 0 ? false : true;
            }
            /* isTicketFull */
            if (root[IMPROGRAMITEM_TICKETISFULL].isNumeric()) {
                isTicketFull = root[IMPROGRAMITEM_TICKETISFULL].asInt() == 0 ? false : true;
            }
            
            result = true;
        }
        return result;
    }
    
    IMProgramItem() {
        showLiveId = "";
        anchorId = "";
        anchorNickName = "";
        anchorAvatar = "";
        showTitle = "";
        showIntroduce = "";
        cover = "";
        approveTime = 0;
        startTime = 0;
        duration = 0;
        leftSecToStart = 0;
        leftSecToEnter = 0;
        price = 0.0;
        status = IMPROGRAMSTATUS_UNKNOW;
        ticketStatus = IMPROGRAMTICKETSTATUS_UNKNOW;
        isHasFollow = false;
        isTicketFull = false;
    }
    
    virtual ~IMProgramItem() {
        
    }
    /**
     * 节目信息结构体
     * showLiveId           节目ID
     * anchorId             主播ID
     * anchorNickName       主播昵称
     * anchorAvatar         主播头像url
     * showTitle            节目名称
     * showIntroduce        节目介绍
     * cover                节目封面图url
     * approveTime          审核通过时间（1970年起的秒数）
     * startTime            节目开播时间（1970年起的秒数）
     * duration             节目时长
     * leftSecToStart       开始开播剩余时间
     * leftSecToEnter       可进入过渡页的剩余时间（秒）
     * price                节目价格
     * status               节目状态（0：未审核，1：审核通过，2：审核被拒，3：节目正常结束，4：节目已超时, 5：节目已取消）
     * ticketStatus         购票状态（IMPROGRAMTICKETSTATUS_NOBUY：未购票，IMPROGRAMTICKETSTATUSS_BUYED：已购票，IMPROGRAMTICKETSTATUS_OUT：已退票）
     * isHasFollow          是否已关注
     * isTicketFull         是否已满座
     */
    string   showLiveId;
    string   anchorId;
    string   anchorNickName;
    string   anchorAvatar;
    string   showTitle;
    string   showIntroduce;
    string   cover;
    long     approveTime;
    long     startTime;
    int      duration;
    int      leftSecToStart;
    int      leftSecToEnter;
    double   price;
    IMProgramStatus      status;
    IMProgramTicketStatus     ticketStatus;
    bool     isHasFollow;
    bool     isTicketFull;

};



#endif /* IMPROGRAMITEM_H_*/
