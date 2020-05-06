/*
 * HttpScheduleDurationItem.h
 *
 *  Created on: 2020-03-16
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPSCHEDULEDURATIONITEM_H_
#define HTTPSCHEDULEDURATIONITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"

class HttpScheduleDurationItem {
public:

	bool Parse(const Json::Value& root) {
        bool result = false;
		if( root.isObject() ) {
            
            /* duration */
            if (root[LIVEROOM_GETSCHEDULEDURATIONLIST_DURATION].isNumeric()) {
                duration = root[LIVEROOM_GETSCHEDULEDURATIONLIST_DURATION].asInt();
            }
            
            /* isDefault */
            if (root[LIVEROOM_GETSCHEDULEDURATIONLIST_ISDEFAULT].isNumeric()) {
                isDefault = root[LIVEROOM_GETSCHEDULEDURATIONLIST_ISDEFAULT].asInt() == 0 ? false : true;
            }
            
            /* credit */
            if (root[LIVEROOM_GETSCHEDULEDURATIONLIST_CREDIT].isNumeric()) {
                credit = root[LIVEROOM_GETSCHEDULEDURATIONLIST_CREDIT].asDouble();
            }
            
            /* originalCredit */
            if (root[LIVEROOM_GETSCHEDULEDURATIONLIST_ORIGINAL_CREDIT].isNumeric()) {
                originalCredit = root[LIVEROOM_GETSCHEDULEDURATIONLIST_ORIGINAL_CREDIT].asDouble();
            }
            result = true;
        }
        return result;
    }

	HttpScheduleDurationItem() {
        duration = 0;
        isDefault = false;
        credit = 0.0;
        originalCredit = 0.0;
	}

	virtual ~HttpScheduleDurationItem() {

	}
    
    /**
     * 预约时间价格结构体
     * duration               分钟时长
     * isDefault              是否默认选中
     * credit                   优惠价格
     * originalCredit       原价
     */
    int duration;
    bool isDefault;
    double credit;
    double originalCredit;
    
};

typedef list<HttpScheduleDurationItem> ScheduleDurationList;

#endif /* HTTPSCHEDULEDURATIONITEM_H_ */
