/*
 * LSLCScheduleMsgItem.h
 *
 *  Created on: 2015-3-6
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LSLCSCHEDULEMSGITEM_H_
#define LSLCSCHEDULEMSGITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../ILSLiveChatClientEnumDef.h"

#define LSLCSCHEDULEMSGITEM_SESSIONID_PARAM         "sessionId"
#define LSLCSCHEDULEMSGITEM_RTYPE_PARAM             "rType"
#define LSLCSCHEDULEMSGITEM_TIMEZONE_PARAM          "timeZone"
#define LSLCSCHEDULEMSGITEM_TIMEZONEOFFSET_PARAM    "timeZoneOffSet"
#define LSLCSCHEDULEMSGITEM_SESSIONDURATION_PARAM   "sessionDuration"
#define LSLCSCHEDULEMSGITEM_DURATIONADJUSTED_PARAM  "durationAdjusted"
#define LSLCSCHEDULEMSGITEM_STARTGMTTIME_PARAM      "startGmtTime"
#define LSLCSCHEDULEMSGITEM_TIMEPERIOD_PARAM        "timePeriod"
#define LSLCSCHEDULEMSGITEM_INVITEID_PARAM          "inviteId"
#define LSLCSCHEDULEMSGITEM_ACTIONGMTTIME_PARAM     "actionGmtTime"

class LSLCScheduleMsgItem {
public:
	void Parse(Json::Value root) {
		if( root.isObject() ) {
			/* sessionId */
			if( root[LSLCSCHEDULEMSGITEM_SESSIONID_PARAM].isString() ) {
				sessionId = root[LSLCSCHEDULEMSGITEM_SESSIONID_PARAM].asString();
			}
            
            /* type */
            if( root[LSLCSCHEDULEMSGITEM_RTYPE_PARAM].isNumeric() ) {
                type = GetScheduleInviteType(root[LSLCSCHEDULEMSGITEM_RTYPE_PARAM].asInt());
            }
            
            /* timeZone */
            if( root[LSLCSCHEDULEMSGITEM_TIMEZONE_PARAM].isString() ) {
                timeZone = root[LSLCSCHEDULEMSGITEM_TIMEZONE_PARAM].asString();
            }
            
            /* timeZoneOffSet */
            if( root[LSLCSCHEDULEMSGITEM_TIMEZONEOFFSET_PARAM].isNumeric() ) {
                timeZoneOffSet = root[LSLCSCHEDULEMSGITEM_TIMEZONEOFFSET_PARAM].asInt();
            }
            
            /* sessionDuration */
            if( root[LSLCSCHEDULEMSGITEM_SESSIONDURATION_PARAM].isNumeric() ) {
                sessionDuration = root[LSLCSCHEDULEMSGITEM_SESSIONDURATION_PARAM].asInt();
            }
            
            /* durationAdjusted */
            if( root[LSLCSCHEDULEMSGITEM_DURATIONADJUSTED_PARAM].isNumeric() ) {
                durationAdjusted = root[LSLCSCHEDULEMSGITEM_DURATIONADJUSTED_PARAM].asInt();
            }
            
            /* startGmtTime */
            if( root[LSLCSCHEDULEMSGITEM_STARTGMTTIME_PARAM].isNumeric() ) {
                startGmtTime = root[LSLCSCHEDULEMSGITEM_STARTGMTTIME_PARAM].asLong();
            }

            /* timePeriod */
			if( root[LSLCSCHEDULEMSGITEM_TIMEPERIOD_PARAM].isString() ) {
				timePeriod = root[LSLCSCHEDULEMSGITEM_TIMEPERIOD_PARAM].asString();
			}
            
            /* inviteId */
            if( root[LSLCSCHEDULEMSGITEM_INVITEID_PARAM].isString() ) {
                inviteId = root[LSLCSCHEDULEMSGITEM_INVITEID_PARAM].asString();
            }
            
            /* actionGmtTime */
            if( root[LSLCSCHEDULEMSGITEM_ACTIONGMTTIME_PARAM].isNumeric() ) {
                actionGmtTime = root[LSLCSCHEDULEMSGITEM_ACTIONGMTTIME_PARAM].asLong();
            }
		}
	}
    
    Json::Value PackInfo() {
        Json::Value value;
        value[LSLCSCHEDULEMSGITEM_SESSIONID_PARAM] = sessionId;
        value[LSLCSCHEDULEMSGITEM_RTYPE_PARAM] = GetIntWithScheduleInviteType(type);
        value[LSLCSCHEDULEMSGITEM_TIMEZONE_PARAM] = timeZone;
        value[LSLCSCHEDULEMSGITEM_TIMEZONEOFFSET_PARAM] = timeZoneOffSet;
        value[LSLCSCHEDULEMSGITEM_SESSIONDURATION_PARAM] = sessionDuration;
        value[LSLCSCHEDULEMSGITEM_DURATIONADJUSTED_PARAM] = durationAdjusted;
        value[LSLCSCHEDULEMSGITEM_STARTGMTTIME_PARAM] = startGmtTime;
        value[LSLCSCHEDULEMSGITEM_TIMEPERIOD_PARAM] = timePeriod;
        value[LSLCSCHEDULEMSGITEM_INVITEID_PARAM] = inviteId;
        value[LSLCSCHEDULEMSGITEM_ACTIONGMTTIME_PARAM] = actionGmtTime;
        return value;
    }

	LSLCScheduleMsgItem() {
		sessionId = "";
		type = SCHEDULEINVITE_PENDING;
        timeZone = "";
		timeZoneOffSet = 0;
        sessionDuration = 0;
        durationAdjusted = 0;
        startGmtTime = 0;
        timePeriod = "";
        inviteId = "";
        actionGmtTime = 0;
	}
	virtual ~LSLCScheduleMsgItem() {

	}

	/**
	 * 预约消息协议
	 * @param sessionId		表单id
	 * @param type		       操作方式（SCHEDULEINVITE_PENDING:发送   SCHEDULEINVITE_CONFIRMED:接受    SCHEDULEINVITE_DECLINED:拒绝）
	 * @param timeZone             时区字符串
     *   @param timeZoneOffSet       时区值
     *   @param sessionDuration       会话时长
     *   @param durationAdjusted      修改后的时长
     *    @param startGmtTime           预约开始时间
     *    @param timePeriod               时间周期
     *    @param inviteId                     会话邀请ID
     *    @param actionGmtTime         操作时间
	 */
	string sessionId;
    SCHEDULEINVITE_TYPE type;
    string timeZone;
	int timeZoneOffSet;
    int sessionDuration;
    int durationAdjusted;
    long long startGmtTime;
    string timePeriod;
    string inviteId;
    long long actionGmtTime;

};

#endif /* LSLCSCHEDULEMSGITEM_H_ */
