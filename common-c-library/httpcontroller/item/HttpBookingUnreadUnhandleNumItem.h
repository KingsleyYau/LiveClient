/*
 * HttpBookingUnreadUnhandleNumItem.h
 *
 *  Created on: 2017-8-18
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPBOOKINGUNREADUNHANDLENUMITEM_H_
#define HTTPBOOKINGUNREADUNHANDLENUMITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"

class HttpBookingUnreadUnhandleNumItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* totalNoReadNum */
            if (root[LIVEROOM_MANBOOKINGUNREADUNHANDKENUM_TOTALNOREADNUM ].isInt()) {
                totalNoReadNum = root[LIVEROOM_MANBOOKINGUNREADUNHANDKENUM_TOTALNOREADNUM ].asInt();
            }
            /* pendingNoReadNum */
            if (root[LIVEROOM_MANBOOKINGUNREADUNHANDKENUM_PENDINGNOREADNUM].isInt()) {
                pendingNoReadNum = root[LIVEROOM_MANBOOKINGUNREADUNHANDKENUM_PENDINGNOREADNUM].asInt();
            }
            
            /* scheduledNoReadNum */
            if (root[LIVEROOM_MANBOOKINGUNREADUNHANDKENUM_SCHEDULEDNOREADNUM].isInt()) {
                scheduledNoReadNum = root[LIVEROOM_MANBOOKINGUNREADUNHANDKENUM_SCHEDULEDNOREADNUM].asInt();
            }
            
            /* historyNoReadNum */
            if (root[LIVEROOM_MANBOOKINGUNREADUNHANDKENUM_HISTORYNOREADNUM].isInt()) {
                historyNoReadNum = root[LIVEROOM_MANBOOKINGUNREADUNHANDKENUM_HISTORYNOREADNUM].asInt();
            }

        }

        //if (totalNoReadNum > 0) {
        result = true;
       // }
        return result;
    }
    
    HttpBookingUnreadUnhandleNumItem() {
        totalNoReadNum = 0;
        pendingNoReadNum = 0;
        scheduledNoReadNum = 0;
        historyNoReadNum = 0;

    }
    
    virtual ~HttpBookingUnreadUnhandleNumItem() {
        
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

#endif /* HTTPBOOKINGUNREADUNHANDLENUMITEM_H_*/
