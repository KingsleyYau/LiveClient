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
            /* total */
            if (root[LIVEROOM_MANBOOKINGUNREADUNHANDKENUM_TOTAL].isInt()) {
                total = root[LIVEROOM_MANBOOKINGUNREADUNHANDKENUM_TOTAL].asInt();
            }
            /* handleNum */
            if (root[LIVEROOM_MANBOOKINGUNREADUNHANDKENUM_HANDLENUM].isInt()) {
                handleNum = root[LIVEROOM_MANBOOKINGUNREADUNHANDKENUM_HANDLENUM].asInt();
            }
            
            /* scheduledUnreadNum */
            if (root[LIVEROOM_MANBOOKINGUNREADUNHANDKENUM_SCHEDULEDUNREADNUM].isInt()) {
                scheduledUnreadNum = root[LIVEROOM_MANBOOKINGUNREADUNHANDKENUM_SCHEDULEDUNREADNUM].asInt();
            }
            
            /* historyUnreadNum */
            if (root[LIVEROOM_MANBOOKINGUNREADUNHANDKENUM_HISTORYUNREADNUM].isInt()) {
                historyUnreadNum = root[LIVEROOM_MANBOOKINGUNREADUNHANDKENUM_HISTORYUNREADNUM].asInt();
            }

        }

        if (total > 0) {
            result = true;
        }
        return result;
    }
    
    HttpBookingUnreadUnhandleNumItem() {
        total = 0;
        handleNum = 0;
        scheduledUnreadNum = 0;
        historyUnreadNum = 0;

    }
    
    virtual ~HttpBookingUnreadUnhandleNumItem() {
        
    }
    /**
     * 预约列表数量结构体
     * total                 以下参数数量总和
     * handleNum             待观众处理的数量
     * scheduledUnreadNum    已接受的未读数量
     * historyUnreadNum      历史超时、拒绝的未读数量
     */
    int total;
    int handleNum;
    int scheduledUnreadNum;
    int historyUnreadNum;
};

#endif /* HTTPBOOKINGUNREADUNHANDLENUMITEM_H_*/
