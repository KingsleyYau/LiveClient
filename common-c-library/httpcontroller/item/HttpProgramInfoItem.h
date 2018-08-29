/*
 * HttpProgramInfoItem.h
 *
 *  Created on: 2018-4-12
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPPROGRAMINFOITEM_H_
#define HTTPPROGRAMINFOITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"

class HttpProgramInfoItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* showLiveId */
            if (root[LIVEROOM_HOT_PROGRAMLIST_SHOWLIVEID].isString()) {
                showLiveId = root[LIVEROOM_HOT_PROGRAMLIST_SHOWLIVEID].asString();
            }
            /* anchorId */
            if (root[LIVEROOM_HOT_PROGRAMLIST_ANCHORID].isString()) {
                anchorId = root[LIVEROOM_HOT_PROGRAMLIST_ANCHORID].asString();
            }
            /* anchorNickName */
            if (root[LIVEROOM_HOT_PROGRAMLIST_ANCHORNICKNAME].isString()) {
                anchorNickName = root[LIVEROOM_HOT_PROGRAMLIST_ANCHORNICKNAME].asString();
            }
            /* anchorAvatar */
            if (root[LIVEROOM_HOT_PROGRAMLIST_ANCHORAVATAR].isString()) {
                anchorAvatar = root[LIVEROOM_HOT_PROGRAMLIST_ANCHORAVATAR].asString();
            }
            /* showTitle */
            if (root[LIVEROOM_HOT_PROGRAMLIST_SHOWTITLE].isString()) {
                showTitle = root[LIVEROOM_HOT_PROGRAMLIST_SHOWTITLE].asString();
            }
            /* showIntroduce */
            if (root[LIVEROOM_HOT_PROGRAMLIST_SHOWINTRODUCE].isString()) {
                showIntroduce = root[LIVEROOM_HOT_PROGRAMLIST_SHOWINTRODUCE].asString();
            }
            /* cover */
            if (root[LIVEROOM_HOT_PROGRAMLIST_COVER].isString()) {
                cover = root[LIVEROOM_HOT_PROGRAMLIST_COVER].asString();
            }
            /* approveTime */
            if (root[LIVEROOM_HOT_PROGRAMLIST_APPROVETIME].isNumeric()) {
                approveTime = root[LIVEROOM_HOT_PROGRAMLIST_APPROVETIME].asInt();
            }
            
            /* startTime */
            if (root[LIVEROOM_HOT_PROGRAMLIST_STARTTIME].isNumeric()) {
                startTime = root[LIVEROOM_HOT_PROGRAMLIST_STARTTIME].asInt();
            }
            /* duration */
            if (root[LIVEROOM_HOT_PROGRAMLIST_DURATION].isNumeric()) {
                duration = root[LIVEROOM_HOT_PROGRAMLIST_DURATION].asInt();
            }
            /* leftSecToStart */
            if (root[LIVEROOM_HOT_PROGRAMLIST_LEFTSECTOSTART].isNumeric()) {
                leftSecToStart = root[LIVEROOM_HOT_PROGRAMLIST_LEFTSECTOSTART].asInt();
            }
            
            /* leftSecToEnter */
            if (root[LIVEROOM_HOT_PROGRAMLIST_LEFTSECTOENTER].isNumeric()) {
                leftSecToEnter = root[LIVEROOM_HOT_PROGRAMLIST_LEFTSECTOENTER].asInt();
            }

            /* price */
            if (root[LIVEROOM_HOT_PROGRAMLIST_PRICE].isNumeric()) {
                price = root[LIVEROOM_HOT_PROGRAMLIST_PRICE].asDouble();
            }
            /* status */
            if (root[LIVEROOM_HOT_PROGRAMLIST_STATUS].isNumeric()) {
                status = GetIntToProgramStatus(root[LIVEROOM_HOT_PROGRAMLIST_STATUS].asInt());
            }
            
            /* ticketStatus */
            if (root[LIVEROOM_HOT_PROGRAMLIST_TICKETSTATUS].isNumeric()) {
                ticketStatus = GetIntToProgramTicketStatus(root[LIVEROOM_HOT_PROGRAMLIST_TICKETSTATUS].asInt());
            }

            /* isHasFollow */
            if (root[LIVEROOM_HOT_PROGRAMLIST_HASFOLLOW].isNumeric()) {
                isHasFollow = root[LIVEROOM_HOT_PROGRAMLIST_HASFOLLOW].asInt() == 0 ? false : true;
            }
            /* isTicketFull */
            if (root[LIVEROOM_HOT_PROGRAMLIST_TICKETISFULL].isNumeric()) {
                isTicketFull = root[LIVEROOM_HOT_PROGRAMLIST_TICKETISFULL].asInt() == 0 ? false : true;
            }
            

        }
        result = true;
        return result;
    }

    HttpProgramInfoItem() {
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
        status = PROGRAMSTATUS_UNKNOW;
        ticketStatus = PROGRAMTICKETSTATUS_UNKNOW;
        isHasFollow = false;
        isTicketFull = false;
    }
    
    virtual ~HttpProgramInfoItem() {
        
    }
    
    /**
     * 节目信息结构体
     * showLiveId           节目ID
     * anchorId             主播ID
     * anchorNickName       主播昵称
     * anchorAvatar         主播头像url
     * showTitle            节目名称
     * showIntroduce        节目介绍
     * cover		        节目封面图url
     * approveTime          审核通过时间（1970年起的秒数）
     * startTime            节目开播时间（1970年起的秒数）
     * duration             节目时长
     * leftSecToStart       开始开播剩余时间（秒）
     * leftSecToEnter       可进入过渡页的剩余时间（秒）
     * price                节目价格
     * status               节目状态（0：未审核，1：审核通过，2：审核被拒，3：节目正常结束，4：节目已取消，5：节目已超时）
     * isHasTicket          购票状态（PROGRAMTICKETSTATUS_NOBUY：未购票，PROGRAMTICKETSTATUS_BUYED：已购票，PROGRAMTICKETSTATUS_OUT：已退票）
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
    ProgramStatus      status;
    ProgramTicketStatus     ticketStatus;
    bool     isHasFollow;
    bool     isTicketFull;
};

typedef list<HttpProgramInfoItem> ProgramInfoList;

#endif /* HTTPPROGRAMINFOITEM_H_*/
