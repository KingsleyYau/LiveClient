/*
 * HttpLiveScheduleInviteItem.h
 *
 *  Created on: 2020-03-26
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPLIVESCHEDULEINVITEITEM_H_
#define HTTPLIVESCHEDULEINVITEITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"

class HttpLiveScheduleInviteItem {
public:

	bool Parse(const Json::Value& root) {
        bool result = false;
		if( root.isObject() ) {
            
            /* inviteId */
            if (root[LIVEROOM_GETSESSIONINVITELIST_LIST_INVITE_ID].isString()) {
                inviteId = root[LIVEROOM_GETSESSIONINVITELIST_LIST_INVITE_ID].asString();
            }
            
            /* sendFlag */
            if (root[LIVEROOM_GETSESSIONINVITELIST_LIST_SEND_FLAG].isNumeric()) {
                sendFlag = GetIntToLSScheduleSendFlagType(root[LIVEROOM_GETSESSIONINVITELIST_LIST_SEND_FLAG].asInt());
            }
            
            /* isSummerTime */
            if (root[LIVEROOM_GETSESSIONINVITELIST_LIST_IS_SUMMER_TIME].isNumeric()) {
                isSummerTime = root[LIVEROOM_GETSESSIONINVITELIST_LIST_IS_SUMMER_TIME].asInt() == 0 ? false : true;
            }
            
            /* startTime */
            if (root[LIVEROOM_GETSESSIONINVITELIST_LIST_START_TIME].isNumeric()) {
                startTime = root[LIVEROOM_GETSESSIONINVITELIST_LIST_START_TIME].asLong();
            }
            
            /* endTime */
            if (root[LIVEROOM_GETSESSIONINVITELIST_LIST_END_TIME].isNumeric()) {
                endTime = root[LIVEROOM_GETSESSIONINVITELIST_LIST_END_TIME].asLong();
            }
            
            
            /* timeZoneValue */
            if (root[LIVEROOM_GETSESSIONINVITELIST_LIST_TIME_ZONE_VALUE].isString()) {
                timeZoneValue = root[LIVEROOM_GETSESSIONINVITELIST_LIST_TIME_ZONE_VALUE].asString();
            }
            
            /* timeZoneCity */
            if (root[LIVEROOM_GETSESSIONINVITELIST_LIST_TIME_ZONE_CITY].isString()) {
                timeZoneCity = root[LIVEROOM_GETSESSIONINVITELIST_LIST_TIME_ZONE_CITY].asString();
            }
            
            /* duration */
            if (root[LIVEROOM_GETSESSIONINVITELIST_LIST_DURATION].isNumeric()) {
                duration = root[LIVEROOM_GETSESSIONINVITELIST_LIST_DURATION].asInt();
            }
            
            /* status */
            if (root[LIVEROOM_GETSESSIONINVITELIST_LIST_STATUS].isNumeric()) {
                status = GetIntToLSScheduleInviteStatus(root[LIVEROOM_GETSESSIONINVITELIST_LIST_STATUS].asInt());
            }
            
            /* addTime */
            if (root[LIVEROOM_GETSESSIONINVITELIST_LIST_ADD_TIME].isNumeric()) {
                addTime = root[LIVEROOM_GETSESSIONINVITELIST_LIST_ADD_TIME].asLong();
            }
            
            /* statusUpdateTime */
            if (root[LIVEROOM_GETSESSIONINVITELIST_LIST_STATUS_UPDATE_TIME].isNumeric()) {
                statusUpdateTime = root[LIVEROOM_GETSESSIONINVITELIST_LIST_STATUS_UPDATE_TIME].asLong();
            }
            
            result = true;
        }
        return result;
    }

	HttpLiveScheduleInviteItem() {
        inviteId = "";
        sendFlag = LSSCHEDULESENDFLAGTYPE_MAN;
        isSummerTime = false;
        startTime = 0;
        endTime = 0;
        timeZoneValue = "";
        timeZoneCity = "";
        duration = 0;
        status = LSSCHEDULEINVITESTATUS_UNKOWN;
        addTime = 0;
        statusUpdateTime = 0;
	}

	virtual ~HttpLiveScheduleInviteItem() {

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
    LSScheduleSendFlagType sendFlag;
    bool isSummerTime;
    long long startTime;
    long long endTime;
    string timeZoneValue;
    string timeZoneCity;
    int duration;
    LSScheduleInviteStatus status;
    long long addTime;
    long long statusUpdateTime;
    
};
typedef list<HttpLiveScheduleInviteItem> LiveScheduleInviteList;

#endif /* HTTPLIVESCHEDULEINVITEITEM_H_ */
