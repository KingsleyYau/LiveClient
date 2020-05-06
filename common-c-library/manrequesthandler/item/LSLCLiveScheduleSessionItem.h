/*
 * LSLCLiveScheduleSessionItem.h
 *
 *  Created on: 2020-04-17
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LSLCLIVESCHEDULESESSIONITEM_H_
#define LSLCLIVESCHEDULESESSIONITEM_H_

#include <string>
#include <list>
using namespace std;

#include <json/json/json.h>

#include "../LSLiveChatRequestLiveChatDefine.h"
#include "../LSLiveChatRequestDefine.h"

#define LSLCLIVESCHEDULESESSIONITEM_LIST                          "list"
#define LSLCLIVESCHEDULESESSIONITEM_LIST_INVITE_ID                   "invite_id"
#define LSLCLIVESCHEDULESESSIONITEM_LIST_SEND_FLAG                   "send_flag"
#define LSLCLIVESCHEDULESESSIONITEM_LIST_IS_SUMMER_TIME              "is_summer_time"
#define LSLCLIVESCHEDULESESSIONITEM_LIST_START_TIME                  "start_time"
#define LSLCLIVESCHEDULESESSIONITEM_LIST_END_TIME                    "end_time"
#define LSLCLIVESCHEDULESESSIONITEM_LIST_TIME_ZONE_VALUE             "time_zone_value"
#define LSLCLIVESCHEDULESESSIONITEM_LIST_TIME_ZONE_CITY              "time_zone_city"
#define LSLCLIVESCHEDULESESSIONITEM_LIST_DURATION                    "duration"
#define LSLCLIVESCHEDULESESSIONITEM_LIST_STATUS                      "status"
#define LSLCLIVESCHEDULESESSIONITEM_LIST_ADD_TIME                    "add_time"
#define LSLCLIVESCHEDULESESSIONITEM_LIST_STATUS_UPDATE_TIME          "status_update_time"

class LSLCLiveScheduleSessionItem {
public:

	bool Parse(const Json::Value& root) {
        bool result = false;
		if( root.isObject() ) {
            
            /* inviteId */
            if (root[LSLCLIVESCHEDULESESSIONITEM_LIST_INVITE_ID].isString()) {
                inviteId = root[LSLCLIVESCHEDULESESSIONITEM_LIST_INVITE_ID].asString();
            }
            
            /* sendFlag */
            if (root[LSLCLIVESCHEDULESESSIONITEM_LIST_SEND_FLAG].isNumeric()) {
                sendFlag = root[LSLCLIVESCHEDULESESSIONITEM_LIST_SEND_FLAG].asInt();
            }
            
            /* isSummerTime */
            if (root[LSLCLIVESCHEDULESESSIONITEM_LIST_IS_SUMMER_TIME].isNumeric()) {
                isSummerTime = root[LSLCLIVESCHEDULESESSIONITEM_LIST_IS_SUMMER_TIME].asInt() == 0 ? false : true;
            }
            
            /* startTime */
            if (root[LSLCLIVESCHEDULESESSIONITEM_LIST_START_TIME].isNumeric()) {
                startTime = root[LSLCLIVESCHEDULESESSIONITEM_LIST_START_TIME].asLong();
            }
            
            /* endTime */
            if (root[LSLCLIVESCHEDULESESSIONITEM_LIST_END_TIME].isNumeric()) {
                endTime = root[LSLCLIVESCHEDULESESSIONITEM_LIST_END_TIME].asLong();
            }
            
            
            /* timeZoneValue */
            if (root[LSLCLIVESCHEDULESESSIONITEM_LIST_TIME_ZONE_VALUE].isString()) {
                timeZoneValue = root[LSLCLIVESCHEDULESESSIONITEM_LIST_TIME_ZONE_VALUE].asString();
            }
            
            /* timeZoneCity */
            if (root[LSLCLIVESCHEDULESESSIONITEM_LIST_TIME_ZONE_CITY].isString()) {
                timeZoneCity = root[LSLCLIVESCHEDULESESSIONITEM_LIST_TIME_ZONE_CITY].asString();
            }
            
            /* duration */
            if (root[LSLCLIVESCHEDULESESSIONITEM_LIST_DURATION].isNumeric()) {
                duration = root[LSLCLIVESCHEDULESESSIONITEM_LIST_DURATION].asInt();
            }
            
            /* status */
            if (root[LSLCLIVESCHEDULESESSIONITEM_LIST_STATUS].isNumeric()) {
                status = root[LSLCLIVESCHEDULESESSIONITEM_LIST_STATUS].asInt();
            }
            
            /* addTime */
            if (root[LSLCLIVESCHEDULESESSIONITEM_LIST_ADD_TIME].isNumeric()) {
                addTime = root[LSLCLIVESCHEDULESESSIONITEM_LIST_ADD_TIME].asLong();
            }
            
            /* statusUpdateTime */
            if (root[LSLCLIVESCHEDULESESSIONITEM_LIST_STATUS_UPDATE_TIME].isNumeric()) {
                statusUpdateTime = root[LSLCLIVESCHEDULESESSIONITEM_LIST_STATUS_UPDATE_TIME].asLong();
            }
            
            result = true;
        }
        return result;
    }

	LSLCLiveScheduleSessionItem() {
        inviteId = "";
        sendFlag = 0;
        isSummerTime = false;
        startTime = 0;
        endTime = 0;
        timeZoneValue = "";
        timeZoneCity = "";
        duration = 0;
        status = 0;
        addTime = 0;
        statusUpdateTime = 0;
	}

	virtual ~LSLCLiveScheduleSessionItem() {

	}
    
    /**
     * 直播预付费邀请结构体
     * inviteId                         邀请ID
     * sendFlag                     发起方
     * isSummerTime             选中的时区是否夏令时
     * startTime                    开始时间(GMT时间戳)
     * endTime                    结束时间(GMT时间戳)
     * timeZoneCity             时区城市
     * duration                     分钟时长
     * status                         邀请状态
     * addTime                   添加时间(GMT时间戳)
     * timeZoneValue           时区差值
     */
    string inviteId;
    int sendFlag;
    bool isSummerTime;
    long long startTime;
    long long endTime;
    string timeZoneValue;
    string timeZoneCity;
    int duration;
    int status;
    long long addTime;
    long long statusUpdateTime;
    
};
typedef list<LSLCLiveScheduleSessionItem> ChatScheduleSessionList;

#endif /* LSLCLIVESCHEDULESESSIONITEM_H_ */
