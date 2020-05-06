/*
 * HttpMainNoReadNumItem.h
 *
 *  Created on: 2018-6-22
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPMAINNOREADNUMITEM_H_
#define HTTPMAINNOREADNUMITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"
#include "HttpLoginItem.h"

class HttpMainNoReadNumItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* showTicketUnreadNum */
            if (root[LIVEROOM_GETTOTALNOREADNUM_SHOWTICKETUNREADNUM].isNumeric()) {
                showTicketUnreadNum = root[LIVEROOM_GETTOTALNOREADNUM_SHOWTICKETUNREADNUM].asInt();
            }
            
            /* loiUnreadNum */
            if (root[LIVEROOM_GETTOTALNOREADNUM_LOIUNREADNUM].isNumeric()) {
                loiUnreadNum = root[LIVEROOM_GETTOTALNOREADNUM_LOIUNREADNUM].asInt();
            }
            
            /* emfUnreadNum */
            if (root[LIVEROOM_GETTOTALNOREADNUM_EMFUNREADNUM].isNumeric()) {
                emfUnreadNum = root[LIVEROOM_GETTOTALNOREADNUM_EMFUNREADNUM].asInt();
            }
            
            /* privateMessageUnreadNum */
            if (root[LIVEROOM_GETTOTALNOREADNUM_PRIVATEMESSAGEUNREADNUM].isNumeric()) {
                privateMessageUnreadNum = root[LIVEROOM_GETTOTALNOREADNUM_PRIVATEMESSAGEUNREADNUM].asInt();
            }
            /* bookingUnreadNum */
            if (root[LIVEROOM_GETTOTALNOREADNUM_BOOKINGUNREADNUM].isNumeric()) {
                bookingUnreadNum = root[LIVEROOM_GETTOTALNOREADNUM_BOOKINGUNREADNUM].asInt();
            }
            /* backpackUnreadNum */
            if (root[LIVEROOM_GETTOTALNOREADNUM_BACKPACKUNREADNUM].isNumeric()) {
                backpackUnreadNum = root[LIVEROOM_GETTOTALNOREADNUM_BACKPACKUNREADNUM].asInt();
            }
            /* sayHiResponseUnreadNum */
            if (root[LIVEROOM_GETTOTALNOREADNUM_SAYHIRESPONSEUNREADNUM].isNumeric()) {
                sayHiResponseUnreadNum = root[LIVEROOM_GETTOTALNOREADNUM_SAYHIRESPONSEUNREADNUM].asInt();
            }
            
            /* livechatVocherUnreadNum */
            if (root[LIVEROOM_GETTOTALNOREADNUM_LIVECHATVOUCHERUNREADNUM].isNumeric()) {
                livechatVocherUnreadNum = root[LIVEROOM_GETTOTALNOREADNUM_LIVECHATVOUCHERUNREADNUM].asInt();
            }
            
            /* schedulePendingUnreadNum */
            if (root[LIVEROOM_GETTOTALNOREADNUM_SCHEDULEPENDINGUNREADNUM].isNumeric()) {
                schedulePendingUnreadNum = root[LIVEROOM_GETTOTALNOREADNUM_SCHEDULEPENDINGUNREADNUM].asInt();
            }
            
            /* scheduleConfirmedUnreadNum */
            if (root[LIVEROOM_GETTOTALNOREADNUM_SCHEDULECONFIRMEDUNREADNUM].isNumeric()) {
                scheduleConfirmedUnreadNum = root[LIVEROOM_GETTOTALNOREADNUM_SCHEDULECONFIRMEDUNREADNUM].asInt();
            }
            
            /* scheduleStatus */
            if (root[LIVEROOM_GETTOTALNOREADNUM_SCHEDULESTATUS].isNumeric()) {
                scheduleStatus = GetIntToLSScheduleStatus(root[LIVEROOM_GETTOTALNOREADNUM_SCHEDULESTATUS].asInt());
            }
        }

        result = true;

        return result;
    }
    
    HttpMainNoReadNumItem() {
        showTicketUnreadNum = 0;
        loiUnreadNum = 0;
        emfUnreadNum = 0;
        privateMessageUnreadNum = 0;
        bookingUnreadNum = 0;
        backpackUnreadNum = 0;
        sayHiResponseUnreadNum = 0;
        livechatVocherUnreadNum = 0;
        schedulePendingUnreadNum = 0;
        scheduleConfirmedUnreadNum = 0;
        scheduleStatus = LSSCHEDULESTATUS_NOSCHEDULE;
    }
    
    virtual ~HttpMainNoReadNumItem() {
        
    }
    /**
     * 获取主界面未读数量
     * showTicketUnreadNum          节目未读数量
     * loiUnreadNum                 意向信未读数量
     * emfUnreadNum		            EMF未读数量
     * privateMessageUnreadNum      私信未读数量
     * bookingUnreadNum             预约未读数量
     * backpackUnreadNum            背包未读数量
     * sayHiResponseUnreadNum       sayHi回复未读数量
     * livechatVocherUnreadNum      livechat试聊劵未读数量
     * schedulePendingUnreadNum     预付费直播-男士待确定未读数
     * scheduleConfirmedUnreadNum   预付费直播-男主播接受未读数
     * scheduleStatus           预付费直播状态（LSSCHEDULESTATUS_NOSCHEDULE：无预约 LSSCHEDULESTATUS_SHOWED：可开播 LSSCHEDULESTATUS_SHOWING：在30分钟内即将开播）
     */
    int showTicketUnreadNum;
    int loiUnreadNum;
    int emfUnreadNum;
    int privateMessageUnreadNum;
    int bookingUnreadNum;
    int backpackUnreadNum;
    int sayHiResponseUnreadNum;
    int livechatVocherUnreadNum;
    int schedulePendingUnreadNum;
    int scheduleConfirmedUnreadNum;
    LSScheduleStatus scheduleStatus;
    
};

#endif /* HTTPMAINNOREADNUMITEM_H_*/
