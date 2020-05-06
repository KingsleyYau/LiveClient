/*
 * HttpScheduleInviteListItem.h
 *
 *  Created on: 2020-03-26
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPSCHEDULEINVITELISTITEM_H_
#define HTTPSCHEDULEINVITELISTITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "HttpScheduleAnchorInfoItem.h"

class HttpScheduleInviteListItem {
public:

	bool Parse(const Json::Value& root) {
        bool result = false;
		if( root.isObject() ) {
            
            /* anchorInfo */
            if (root[LIVEROOM_GETINVITELIST_ANCHOR_INFO].isObject()) {
                anchorInfo.Parse(root[LIVEROOM_GETINVITELIST_ANCHOR_INFO]);
            }
            
            /* inviteId */
            if (root[LIVEROOM_GETINVITELIST_INVITE_ID].isString()) {
                inviteId = root[LIVEROOM_GETINVITELIST_INVITE_ID].asString();
            }
            
            /* sendFlag */
            if (root[LIVEROOM_GETINVITELIST_SEND_FLAG].isNumeric()) {
                sendFlag = GetIntToLSScheduleSendFlagType(root[LIVEROOM_GETINVITELIST_SEND_FLAG].asInt());
            }
            
            /* isSummerTime */
            if (root[LIVEROOM_GETINVITELIST_IS_SUMMER_TIME].isNumeric()) {
                isSummerTime = root[LIVEROOM_GETINVITELIST_IS_SUMMER_TIME].asInt() == 0 ? false : true;
            }
            
            /* startTime */
            if (root[LIVEROOM_GETINVITELIST_START_TIME].isNumeric()) {
                startTime = root[LIVEROOM_GETINVITELIST_START_TIME].asLong();
            }
            
            /* endTime */
            if (root[LIVEROOM_GETINVITELIST_END_TIME].isNumeric()) {
                endTime = root[LIVEROOM_GETINVITELIST_END_TIME].asLong();
            }
            
            /* timeZoneValue */
            if (root[LIVEROOM_GETINVITELIST_TIME_ZONE_VALUE].isString()) {
                timeZoneValue = root[LIVEROOM_GETINVITELIST_TIME_ZONE_VALUE].asString();
            }
            
            /* timeZoneCity */
            if (root[LIVEROOM_GETINVITELIST_TIME_ZONE_CITY].isString()) {
                timeZoneCity = root[LIVEROOM_GETINVITELIST_TIME_ZONE_CITY].asString();
            }
            
            /* duration */
            if (root[LIVEROOM_GETINVITELIST_DURATION].isNumeric()) {
                duration = root[LIVEROOM_GETINVITELIST_DURATION].asInt();
            }
            
            /* stats */
            if (root[LIVEROOM_GETINVITELIST_STATUS].isNumeric()) {
                status = GetIntToLSScheduleInviteStatus(root[LIVEROOM_GETINVITELIST_STATUS].asInt());
            }
            
            /* type */
            if (root[LIVEROOM_GETINVITELIST_TYPE].isNumeric()) {
                type = GetIntToLSScheduleInviteType(root[LIVEROOM_GETINVITELIST_TYPE].asInt());
            }
            
            /* refId */
            if (root[LIVEROOM_GETINVITELIST_REF_ID].isString()) {
                refId = root[LIVEROOM_GETINVITELIST_REF_ID].asString();
            }
            
            /* hasRead */
            if (root[LIVEROOM_GETINVITELIST_HAS_ID].isNumeric()) {
                hasRead = root[LIVEROOM_GETINVITELIST_HAS_ID].asInt() == 0 ? false : true;
            }
            
            /* isActive */
            if (root[LIVEROOM_GETINVITELIST_IS_ACTIVE].isNumeric()) {
                isActive = root[LIVEROOM_GETINVITELIST_IS_ACTIVE].asInt() == 0 ? false : true;
            }
            
            result = true;
        }
        return result;
    }

	HttpScheduleInviteListItem() {
        inviteId = "";
        sendFlag = LSSCHEDULESENDFLAGTYPE_MAN;
        isSummerTime = false;
        startTime = 0;
        endTime = 0;
        timeZoneValue = "";
        timeZoneCity = "";
        duration = 0;
        status = LSSCHEDULEINVITESTATUS_UNKOWN;
        type = LSSCHEDULEINVITETYPE_UNKOWN;
        refId = "";
        hasRead = false;
        isActive = false;
	}

	virtual ~HttpScheduleInviteListItem() {

	}
    
    /**
     * 预付费邀请列表结构体
     * anchorInfo                   主播信息
     * inviteId                         邀请ID
     * sendFlag                     发起方
     * isSummerTime             选中的时区是否夏令时
     * startTime                    开始时间(GMT时间戳)
     * endTime                    结束时间(GMT时间戳)
     * timeZoneValue           时区差值
     * timeZoneCity             时区城市
     * duration                     分钟时长
     * stats                         邀请状态
     * type                         邀请来源类型
     * refId                        关联的ID(信件ID、livechat邀请ID、场次ID等)
     * hasRead                  是否已读
     * isActive                    是否激活
     */
    HttpScheduleAnchorInfoItem anchorInfo;
    string inviteId;
    LSScheduleSendFlagType sendFlag;
    bool isSummerTime;
    long long startTime;
    long long endTime;
    string timeZoneValue;
    string timeZoneCity;
    int duration;
    LSScheduleInviteStatus status;
    LSScheduleInviteType type;
    string refId;
    bool hasRead;
    bool isActive;
    
};

typedef list<HttpScheduleInviteListItem> ScheduleInviteList;

#endif /* HTTPSCHEDULEINVITELISTITEM_H_ */
