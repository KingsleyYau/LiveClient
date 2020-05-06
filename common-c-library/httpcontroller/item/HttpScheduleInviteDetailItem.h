/*
 * HttpScheduleInviteDetailItem.h
 *
 *  Created on: 2020-03-26
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPSCHEDULEINVITEDETAILITEM_H_
#define HTTPSCHEDULEINVITEDETAILITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"

class HttpScheduleInviteDetailItem {
public:

	bool Parse(const Json::Value& root) {
        bool result = false;
		if( root.isObject() ) {
            
            /* inviteId */
            if (root[LIVEROOM_GETINVITEDETAIL_INVITE_ID].isString()) {
                inviteId = root[LIVEROOM_GETINVITEDETAIL_INVITE_ID].asString();
            }
            
            /* anchorId */
            if (root[LIVEROOM_GETINVITEDETAIL_ANCHOR_ID].isString()) {
                anchorId = root[LIVEROOM_GETINVITEDETAIL_ANCHOR_ID].asString();
            }
            
            /* sendFlag */
            if (root[LIVEROOM_GETINVITEDETAIL_SEND_FLAG].isNumeric()) {
                sendFlag = GetIntToLSScheduleSendFlagType(root[LIVEROOM_GETINVITEDETAIL_SEND_FLAG].asInt());
            }
            
            /* isSummerTime */
            if (root[LIVEROOM_GETINVITEDETAIL_IS_SUMMER_TIME].isNumeric()) {
                isSummerTime = root[LIVEROOM_GETINVITEDETAIL_IS_SUMMER_TIME].asInt() == 0 ? false : true;
            }
            
            /* startTime */
            if (root[LIVEROOM_GETINVITEDETAIL_START_TIME].isNumeric()) {
                startTime = root[LIVEROOM_GETINVITEDETAIL_START_TIME].asLong();
            }
            
            /* endTime */
            if (root[LIVEROOM_GETINVITEDETAIL_END_TIME].isNumeric()) {
                endTime = root[LIVEROOM_GETINVITEDETAIL_END_TIME].asLong();
            }
            
            /* addTime */
            if (root[LIVEROOM_GETINVITEDETAIL_ADD_TIME].isNumeric()) {
                addTime = root[LIVEROOM_GETINVITEDETAIL_ADD_TIME].asLong();
            }
            
            /* statusUpdateTime */
            if (root[LIVEROOM_GETINVITEDETAIL_STATUS_UPDATE_TIME].isNumeric()) {
                statusUpdateTime = root[LIVEROOM_GETINVITEDETAIL_STATUS_UPDATE_TIME].asLong();
            }
            
            /* timeZoneValue */
            if (root[LIVEROOM_GETINVITEDETAIL_TIME_ZONE_VALUE].isString()) {
                timeZoneValue = root[LIVEROOM_GETINVITEDETAIL_TIME_ZONE_VALUE].asString();
            }
            
            /* timeZoneCity */
            if (root[LIVEROOM_GETINVITEDETAIL_TIME_ZONE_CITY].isString()) {
                timeZoneCity = root[LIVEROOM_GETINVITEDETAIL_TIME_ZONE_CITY].asString();
            }
            
            /* duration */
            if (root[LIVEROOM_GETINVITEDETAIL_DURATION].isNumeric()) {
                duration = root[LIVEROOM_GETINVITEDETAIL_DURATION].asInt();
            }
            
            /* status */
            if (root[LIVEROOM_GETINVITEDETAIL_STATUS].isNumeric()) {
                status = GetIntToLSScheduleInviteStatus(root[LIVEROOM_GETINVITEDETAIL_STATUS].asInt());
            }
            
            /* cancelerName */
            if (root[LIVEROOM_GETINVITEDETAIL_CANCELER_NAME].isString()) {
                cancelerName = root[LIVEROOM_GETINVITEDETAIL_CANCELER_NAME].asString();
            }
            
            /* type */
            if (root[LIVEROOM_GETINVITEDETAIL_TYPE].isNumeric()) {
                type = GetIntToLSScheduleInviteType(root[LIVEROOM_GETINVITEDETAIL_TYPE].asInt());
            }
            
            /* refId */
            if (root[LIVEROOM_GETINVITEDETAIL_REF_ID].isString()) {
                refId = root[LIVEROOM_GETINVITEDETAIL_REF_ID].asString();
            }
            
            
            /* isActive */
            if (root[LIVEROOM_GETINVITEDETAIL_IS_ACTIVE].isNumeric()) {
                isActive = root[LIVEROOM_GETINVITEDETAIL_IS_ACTIVE].asInt() == 0 ? false : true;
            }
            
            result = true;
        }
        return result;
    }

	HttpScheduleInviteDetailItem() {
        inviteId = "";
        anchorId = "";
        sendFlag = LSSCHEDULESENDFLAGTYPE_MAN;
        isSummerTime = false;
        startTime = 0;
        endTime = 0;
        addTime = 0;
        statusUpdateTime = 0;
        timeZoneValue = "";
        timeZoneCity = "";
        duration = 0;
        status = LSSCHEDULEINVITESTATUS_UNKOWN;
        cancelerName = "";
        type = LSSCHEDULEINVITETYPE_UNKOWN;
        refId = "";
        isActive = false;
	}

	virtual ~HttpScheduleInviteDetailItem() {

	}
    
    /**
     * 预付费邀请详情结构体
     * inviteId                         邀请ID
     * anchorId                     主播ID
     * sendFlag                     发起方
     * isSummerTime             选中的时区是否夏令时
     * startTime                    开始时间(GMT时间戳)
     * endTime                    结束时间(GMT时间戳)
     * addTime                   添加时间(GMT时间戳)
     * timeZoneValue           时区差值
     * timeZoneCity             时区城市
     * duration                     分钟时长
     * stats                         邀请状态
     * cancelerName         取消者昵称
     * type                         邀请来源类型
     * refId                        关联的ID(信件ID、livechat邀请ID、场次ID等)
     * isActive                    是否激活
     */
    string inviteId;
    string anchorId;
    LSScheduleSendFlagType sendFlag;
    bool isSummerTime;
    long long startTime;
    long long endTime;
    long long addTime;
    long long statusUpdateTime;
    string timeZoneValue;
    string timeZoneCity;
    int duration;
    LSScheduleInviteStatus status;
    string cancelerName;
    LSScheduleInviteType type;
    string refId;
    bool isActive;
    
};


#endif /* HTTPSCHEDULEINVITEDETAILITEM_H_ */
