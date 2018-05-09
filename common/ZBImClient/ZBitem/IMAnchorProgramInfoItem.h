/*
 * IMAnchorProgramInfoItem.h
 *
 *  Created on: 2018-4-24
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef IMANCHORPROGRAMINFOITEM_H_
#define IMANCHORPROGRAMINFOITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#define IMANCHORPROGRAMINFOITEM_SHOWLIVEID                 "live_show_id"
#define IMANCHORPROGRAMINFOITEM_ANCHORID                   "anchor_id"
#define IMANCHORPROGRAMINFOITEM_SHOWTITLE                  "show_title"
#define IMANCHORPROGRAMINFOITEM_SHOWINTRODUCE              "show_introduce"
#define IMANCHORPROGRAMINFOITEM_COVER                      "cover"
#define IMANCHORPROGRAMINFOITEM_APPROVETIME                "approve_time"
#define IMANCHORPROGRAMINFOITEM_STARTTIME                  "start_time"
#define IMANCHORPROGRAMINFOITEM_DURATION                   "duration"
#define IMANCHORPROGRAMINFOITEM_LEFTSECTOSTART             "left_sec_to_start"
#define IMANCHORPROGRAMINFOITEM_LEFTSECTOENTER             "left_sec_to_enter"
#define IMANCHORPROGRAMINFOITEM_PRICE                      "price"
#define IMANCHORPROGRAMINFOITEMT_STATUS                    "status"
#define IMANCHORPROGRAMINFOITEM_TICKETNUM                  "ticket_num"
#define IMANCHORPROGRAMINFOITEM_FOLLOWNUM                  "follow_num"
#define IMANCHORPROGRAMINFOITEM_TICKETISFULL               "ticket_is_full"

class IMAnchorProgramInfoItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* showLiveId */
            if (root[IMANCHORPROGRAMINFOITEM_SHOWLIVEID].isString()) {
                showLiveId = root[IMANCHORPROGRAMINFOITEM_SHOWLIVEID].asString();
            }
            /* anchorId */
            if (root[IMANCHORPROGRAMINFOITEM_ANCHORID].isString()) {
                anchorId = root[IMANCHORPROGRAMINFOITEM_ANCHORID].asString();
            }
            /* showTitle */
            if (root[IMANCHORPROGRAMINFOITEM_SHOWTITLE].isString()) {
                showTitle = root[IMANCHORPROGRAMINFOITEM_SHOWTITLE].asString();
            }
            /* showIntroduce */
            if (root[IMANCHORPROGRAMINFOITEM_SHOWINTRODUCE].isString()) {
                showIntroduce = root[IMANCHORPROGRAMINFOITEM_SHOWINTRODUCE].asString();
            }
            /* cover */
            if (root[IMANCHORPROGRAMINFOITEM_COVER].isString()) {
                cover = root[IMANCHORPROGRAMINFOITEM_COVER].asString();
            }
            /* approveTime */
            if (root[IMANCHORPROGRAMINFOITEM_APPROVETIME].isNumeric()) {
                approveTime = root[IMANCHORPROGRAMINFOITEM_APPROVETIME].asInt();
            }
            
            /* startTime */
            if (root[IMANCHORPROGRAMINFOITEM_STARTTIME].isNumeric()) {
                startTime = root[IMANCHORPROGRAMINFOITEM_STARTTIME].asInt();
            }
            /* duration */
            if (root[IMANCHORPROGRAMINFOITEM_DURATION].isNumeric()) {
                duration = root[IMANCHORPROGRAMINFOITEM_DURATION].asInt();
            }
            /* leftSecToStart */
            if (root[IMANCHORPROGRAMINFOITEM_LEFTSECTOSTART].isNumeric()) {
                leftSecToStart = root[IMANCHORPROGRAMINFOITEM_LEFTSECTOSTART].asInt();
            }
            
            /* leftSecToEnter */
            if (root[IMANCHORPROGRAMINFOITEM_LEFTSECTOENTER].isNumeric()) {
                leftSecToEnter = root[IMANCHORPROGRAMINFOITEM_LEFTSECTOENTER].asInt();
            }
            
            /* price */
            if (root[IMANCHORPROGRAMINFOITEM_PRICE].isNumeric()) {
                price = root[IMANCHORPROGRAMINFOITEM_PRICE].asDouble();
            }
            /* status */
            if (root[IMANCHORPROGRAMINFOITEMT_STATUS].isNumeric()) {
                status = GetIMAnchorProgramStatus(root[IMANCHORPROGRAMINFOITEMT_STATUS].asInt());
            }
            /* ticketNum */
            if (root[IMANCHORPROGRAMINFOITEM_TICKETNUM].isNumeric()) {
                ticketNum = root[IMANCHORPROGRAMINFOITEM_TICKETNUM].asInt();
            }
            /* followNum */
            if (root[IMANCHORPROGRAMINFOITEM_FOLLOWNUM].isNumeric()) {
                followNum = root[IMANCHORPROGRAMINFOITEM_FOLLOWNUM].asInt();
            }
            /* isTicketFull */
            if (root[IMANCHORPROGRAMINFOITEM_TICKETISFULL].isNumeric()) {
                isTicketFull = root[IMANCHORPROGRAMINFOITEM_TICKETISFULL].asInt() == 0 ? false : true;
            }
            

        }
        result = true;
        return result;
    }

    IMAnchorProgramInfoItem() {
        showLiveId = "";
        anchorId = "";
        showTitle = "";
        showIntroduce = "";
        cover = "";
        approveTime = 0;
        startTime = 0;
        duration = 0;
        leftSecToStart = 0;
        leftSecToEnter = 0;
        price = 0.0;
        status = IMANCHORPROGRAMSTATUS_UNKNOW;
        ticketNum = 0;
        followNum = 0;
        isTicketFull = false;
    }
    
    virtual ~IMAnchorProgramInfoItem() {
        
    }
    
    /**
     * 节目信息结构体
     * showLiveId           节目ID
     * anchorId             主播ID
     * showTitle            节目名称
     * showIntroduce        节目介绍
     * cover		        节目封面图url
     * approveTime          审核通过时间（1970年起的秒数）
     * startTime            节目开播时间（1970年起的秒数）
     * duration             节目时长
     * leftSecToStart       开始开播剩余时间（秒）
     * leftSecToEnter       可进入过渡页的剩余时间（秒）
     * price                节目价格
     * status               节目状态（IMANCHORPROGRAMSTATUS_UNVERIFY：未审核，IMANCHORPROGRAMSTATUS_VERIFYPASS：审核通过，IMANCHORPROGRAMSTATUS_VERIFYREJECT：审核被拒，IMANCHORPROGRAMSTATUS_PROGRAMEND：节目正常结束，IMANCHORPROGRAMSTATUS_PROGRAMCALCEL：节目已取消，IMANCHORPROGRAMSTATUS_OUTTIME：节目已超时）
     * ticketNum            已购票数
     * followNum            已关注数
     * isTicketFull         是否已满座
     */
    string   showLiveId;
    string   anchorId;
    string   showTitle;
    string   showIntroduce;
    string   cover;
    long     approveTime;
    long     startTime;
    int      duration;
    int      leftSecToStart;
    int      leftSecToEnter;
    double   price;
    IMAnchorProgramStatus      status;
    int     ticketNum;
    int     followNum;
    bool     isTicketFull;
};

typedef list<IMAnchorProgramInfoItem> IMAnchorProgramInfoList;

#endif /* IMANCHORPROGRAMINFOITEM_H_*/
