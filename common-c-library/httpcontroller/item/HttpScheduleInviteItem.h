/*
 * HttpScheduleInviteItem.h
 *
 *  Created on: 2020-03-16
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPSCHEDULEINVITEITEM_H_
#define HTTPSCHEDULEINVITEITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"

class HttpScheduleInviteItem {
public:

	bool Parse(const Json::Value& root) {
        bool result = false;
		if( root.isObject() ) {
            
            /* inviteId */
            if (root[LIVEROOM_SENDSCHEDULELIVEINVITE_INVITE_ID].isString()) {
                inviteId = root[LIVEROOM_SENDSCHEDULELIVEINVITE_INVITE_ID].asString();
            }
            
            /* isSummerTime */
            if (root[LIVEROOM_SENDSCHEDULELIVEINVITE_IS_SUMMER_TIME].isNumeric()) {
                isSummerTime = root[LIVEROOM_SENDSCHEDULELIVEINVITE_IS_SUMMER_TIME].asInt() == 0 ? false : true;
            }
            
            /* startTime */
            if (root[LIVEROOM_SENDSCHEDULELIVEINVITE_START_TIME].isNumeric()) {
                startTime = root[LIVEROOM_SENDSCHEDULELIVEINVITE_START_TIME].asLong();
            }
            
            /* addTime */
            if (root[LIVEROOM_SENDSCHEDULELIVEINVITE_ADD_TIME].isNumeric()) {
                addTime = root[LIVEROOM_SENDSCHEDULELIVEINVITE_ADD_TIME].asLong();
            }
            result = true;
        }
        return result;
    }

	HttpScheduleInviteItem() {
        inviteId = "";
        isSummerTime = false;
        startTime = 0;
        addTime = 0;
	}

	virtual ~HttpScheduleInviteItem() {

	}
    
    /**
     * 预付费邀请结构体
     * inviteId                         邀请ID
     * isSummerTime            选中的时区是否夏令时
     * startTime                    开始时间GMT时间戳
     * addTime                    添加时间GMT时间戳
     */
    string inviteId;
    bool isSummerTime;
    long long startTime;
    long long addTime;
    
};

#endif /* HTTPSCHEDULEINVITEITEM_H_ */
