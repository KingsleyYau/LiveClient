/*
 * ZBIMBookingUnreadUnhandleNumItem.h
 *
 *  Created on: 2019-11-08
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef ZBIMBOOKINGUNREADUNHSNDLENUMITEM_H_
#define ZBIMBOOKINGUNREADUNHSNDLENUMITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#define BUYFOR_TOTALNOREADNUM_PARAM             "total_no_read_num"
#define BUYFOR_PENDINGNOREADNUM_PARAM           "pending_no_read_num"
#define BUYFOR_SCHEDULEDNOREADNUM_PARAM         "scheduled_no_read_num"
#define BUYFOR_HISTORYNOREADNUM_PARAM           "history_no_read_num"


class ZBIMBookingUnreadUnhandleNumItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* totalNoReadNum */
            if (root[BUYFOR_TOTALNOREADNUM_PARAM ].isInt()) {
                totalNoReadNum = root[BUYFOR_TOTALNOREADNUM_PARAM ].asInt();
            }
            /* pendingNoReadNum */
            if (root[BUYFOR_PENDINGNOREADNUM_PARAM].isInt()) {
                pendingNoReadNum = root[BUYFOR_PENDINGNOREADNUM_PARAM].asInt();
            }
            
            /* scheduledNoReadNum */
            if (root[BUYFOR_SCHEDULEDNOREADNUM_PARAM].isInt()) {
                scheduledNoReadNum = root[BUYFOR_SCHEDULEDNOREADNUM_PARAM].asInt();
            }
            
            /* historyNoReadNum */
            if (root[BUYFOR_HISTORYNOREADNUM_PARAM].isInt()) {
                historyNoReadNum = root[BUYFOR_HISTORYNOREADNUM_PARAM].asInt();
            }
            
        }
        return result;
    }
    
    ZBIMBookingUnreadUnhandleNumItem() {
        totalNoReadNum = 0;
        pendingNoReadNum = 0;
        scheduledNoReadNum = 0;
        historyNoReadNum = 0;
    }
    
    virtual ~ZBIMBookingUnreadUnhandleNumItem() {
        
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

#endif /* ZBIMBOOKINGUNREADUNHSNDLENUMITEM_H_*/
