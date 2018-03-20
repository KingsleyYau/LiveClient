/*
 * ZBHttpBookingUnreadUnhandleNumItem.h
 *
 *  Created on: 2018-2-28
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef ZBHTTPBOOKINGUNREADUNHANDLENUMITEM_H_
#define ZBHTTPBOOKINGUNREADUNHANDLENUMITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../ZBHttpLoginProtocol.h"
#include "../ZBHttpRequestEnum.h"

class ZBHttpBookingUnreadUnhandleNumItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* totalNoReadNum */
            if (root[GETSCHEDULELISTNOREADNUM_TOTALNOREADNUM ].isInt()) {
                totalNoReadNum = root[GETSCHEDULELISTNOREADNUM_TOTALNOREADNUM ].asInt();
            }
            /* pendingNoReadNum */
            if (root[GETSCHEDULELISTNOREADNUM_PENDINGNOREADNUM].isInt()) {
                pendingNoReadNum = root[GETSCHEDULELISTNOREADNUM_PENDINGNOREADNUM].asInt();
            }
            
            /* scheduledNoReadNum */
            if (root[GETSCHEDULELISTNOREADNUM_SCHEDULEDNOREADNUM].isInt()) {
                scheduledNoReadNum = root[GETSCHEDULELISTNOREADNUM_SCHEDULEDNOREADNUM].asInt();
            }
            
            /* historyNoReadNum */
            if (root[GETSCHEDULELISTNOREADNUM_HISTORYNOREADNUM].isInt()) {
                historyNoReadNum = root[GETSCHEDULELISTNOREADNUM_HISTORYNOREADNUM].asInt();
            }

        }

        //if (totalNoReadNum > 0) {
        result = true;
       // }
        return result;
    }
    
    ZBHttpBookingUnreadUnhandleNumItem() {
        totalNoReadNum = 0;
        pendingNoReadNum = 0;
        scheduledNoReadNum = 0;
        historyNoReadNum = 0;

    }
    
    virtual ~ZBHttpBookingUnreadUnhandleNumItem() {
        
    }
    /**
     * 预约列表数量结构体
     * totalNoReadNum                 以下参数数量总和
     * pendingNoReadNum             待观众处理的数量
     * scheduledNoReadNum    已接受的未读数量
     * historyNoReadNum      历史超时、拒绝的未读数量
     */
    int totalNoReadNum;
    int pendingNoReadNum;
    int scheduledNoReadNum;
    int historyNoReadNum;
};

#endif /* ZBHTTPBOOKINGUNREADUNHANDLENUMITEM_H_*/
