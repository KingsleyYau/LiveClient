/*
 * HttpAnchorProgramInfoItem.h
 *
 *  Created on: 2018-4-24
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPANCHORPROGRAMINFOITEM_H_
#define HTTPANCHORPROGRAMINFOITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../ZBHttpLoginProtocol.h"
#include "../ZBHttpRequestEnum.h"

class HttpAnchorProgramInfoItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* showLiveId */
            if (root[ANCHORGETPROGRAMLIST_LIST_SHOWLIVEID].isString()) {
                showLiveId = root[ANCHORGETPROGRAMLIST_LIST_SHOWLIVEID].asString();
            }
            /* anchorId */
            if (root[ANCHORGETPROGRAMLIST_LIST_ANCHORID].isString()) {
                anchorId = root[ANCHORGETPROGRAMLIST_LIST_ANCHORID].asString();
            }
            /* showTitle */
            if (root[ANCHORGETPROGRAMLIST_LIST_SHOWTITLE].isString()) {
                showTitle = root[ANCHORGETPROGRAMLIST_LIST_SHOWTITLE].asString();
            }
            /* showIntroduce */
            if (root[ANCHORGETPROGRAMLIST_LIST_SHOWINTRODUCE].isString()) {
                showIntroduce = root[ANCHORGETPROGRAMLIST_LIST_SHOWINTRODUCE].asString();
            }
            /* cover */
            if (root[ANCHORGETPROGRAMLIST_LIST_COVER].isString()) {
                cover = root[ANCHORGETPROGRAMLIST_LIST_COVER].asString();
            }
            /* approveTime */
            if (root[ANCHORGETPROGRAMLIST_LIST_APPROVETIME].isNumeric()) {
                approveTime = root[ANCHORGETPROGRAMLIST_LIST_APPROVETIME].asInt();
            }
            
            /* startTime */
            if (root[ANCHORGETPROGRAMLIST_LIST_STARTTIME].isNumeric()) {
                startTime = root[ANCHORGETPROGRAMLIST_LIST_STARTTIME].asInt();
            }
            /* duration */
            if (root[ANCHORGETPROGRAMLIST_LIST_DURATION].isNumeric()) {
                duration = root[ANCHORGETPROGRAMLIST_LIST_DURATION].asInt();
            }
            /* leftSecToStart */
            if (root[ANCHORGETPROGRAMLIST_LIST_LEFTSECTOSTART].isNumeric()) {
                leftSecToStart = root[ANCHORGETPROGRAMLIST_LIST_LEFTSECTOSTART].asInt();
            }
            
            /* leftSecToEnter */
            if (root[ANCHORGETPROGRAMLIST_LIST_LEFTSECTOENTER].isNumeric()) {
                leftSecToEnter = root[ANCHORGETPROGRAMLIST_LIST_LEFTSECTOENTER].asInt();
            }
            
            /* price */
            if (root[ANCHORGETPROGRAMLIST_LIST_PRICE].isNumeric()) {
                price = root[ANCHORGETPROGRAMLIST_LIST_PRICE].asDouble();
            }
            /* status */
            if (root[ANCHORGETPROGRAMLIST_LIST_STATUS].isNumeric()) {
                status = (AnchorProgramStatus)root[ANCHORGETPROGRAMLIST_LIST_STATUS].asInt();
            }
            /* ticketNum */
            if (root[ANCHORGETPROGRAMLIST_LIST_TICKETNUM].isNumeric()) {
                ticketNum = root[ANCHORGETPROGRAMLIST_LIST_TICKETNUM].asInt();
            }
            /* followNum */
            if (root[ANCHORGETPROGRAMLIST_LIST_FOLLOWNUM].isNumeric()) {
                followNum = root[ANCHORGETPROGRAMLIST_LIST_FOLLOWNUM].asInt();
            }
            /* isTicketFull */
            if (root[ANCHORGETPROGRAMLIST_LIST_TICKETISFULL].isNumeric()) {
                isTicketFull = root[ANCHORGETPROGRAMLIST_LIST_TICKETISFULL].asInt() == 0 ? false : true;
            }
            

        }
        result = true;
        return result;
    }

    HttpAnchorProgramInfoItem() {
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
        status = ANCHORPROGRAMSTATUS_UNKNOW;
        ticketNum = 0;
        followNum = 0;
        isTicketFull = false;
    }
    
    virtual ~HttpAnchorProgramInfoItem() {
        
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
     * status               节目状态（0：未审核，1：审核通过，2：审核被拒，3：节目正常结束，4：节目已取消，5：节目已超时）
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
    AnchorProgramStatus      status;
    int     ticketNum;
    int     followNum;
    bool     isTicketFull;
};

typedef list<HttpAnchorProgramInfoItem> AnchorProgramInfoList;

#endif /* HTTPANCHORPROGRAMINFOITEM_H_*/
