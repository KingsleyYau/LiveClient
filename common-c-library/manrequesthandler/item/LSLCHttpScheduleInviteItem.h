/*
 * LSLCHttpScheduleInviteItem.h
 *
 *  Created on: 2020-4-14
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LSLCHTTPSCHEDULEINVITEITEM_H_
#define LSLCHTTPSCHEDULEINVITEITEM_H_

#include <string>
using namespace std;


#include <json/json/json.h>

#include "../LSLiveChatRequestLiveChatDefine.h"
#include "../LSLiveChatRequestDefine.h"

#define LSLCHTTPSCHEDULEINVITEITEM_SESSIONID_PARAM         "sessionId"
#define LSLCHTTPSCHEDULEINVITEITEM_RTYPE_PARAM             "rType"
#define LSLCHTTPSCHEDULEINVITEITEM_TIMEZONE_PARAM          "timeZone"
#define LSLCHTTPSCHEDULEINVITEITEM_TIMEZONEOFFSET_PARAM    "timeZoneOffSet"
#define LSLCHTTPSCHEDULEINVITEITEM_SESSIONDURATION_PARAM   "sessionDuration"
#define LSLCHTTPSCHEDULEINVITEITEM_DURATIONADJUSTED_PARAM  "durationAdjusted"
#define LSLCHTTPSCHEDULEINVITEITEM_STARTGMTTIME_PARAM      "startGmtTime"
#define LSLCHTTPSCHEDULEINVITEITEM_TIMEPERIOD_PARAM        "timePeriod"
#define LSLCHTTPSCHEDULEINVITEITEM_INVITEID_PARAM          "inviteId"
#define LSLCHTTPSCHEDULEINVITEITEM_ACTIONGMTTIME_PARAM     "actionGmtTime"

class LSLCHttpScheduleInviteItem {
public:
	bool Parse(Json::Value root) {
		bool result = false;
		if( root.isObject() ) {
            /* sessionId */
            if( root[LSLCHTTPSCHEDULEINVITEITEM_SESSIONID_PARAM].isString() ) {
                sessionId = root[LSLCHTTPSCHEDULEINVITEITEM_SESSIONID_PARAM].asString();
            }
            
            /* type */
            if( root[LSLCHTTPSCHEDULEINVITEITEM_RTYPE_PARAM].isNumeric() ) {
                type = root[LSLCHTTPSCHEDULEINVITEITEM_RTYPE_PARAM].asInt();
            }
            
            /* timeZone */
            if( root[LSLCHTTPSCHEDULEINVITEITEM_TIMEZONE_PARAM].isString() ) {
                timeZone = root[LSLCHTTPSCHEDULEINVITEITEM_TIMEZONE_PARAM].asString();
            }
            
            /* timeZoneOffSet */
            if( root[LSLCHTTPSCHEDULEINVITEITEM_TIMEZONEOFFSET_PARAM].isNumeric() ) {
                timeZoneOffSet = root[LSLCHTTPSCHEDULEINVITEITEM_TIMEZONEOFFSET_PARAM].asInt();
            }
            
            /* sessionDuration */
            if( root[LSLCHTTPSCHEDULEINVITEITEM_SESSIONDURATION_PARAM].isNumeric() ) {
                sessionDuration = root[LSLCHTTPSCHEDULEINVITEITEM_SESSIONDURATION_PARAM].asInt();
            }
            
            /* durationAdjusted */
            if( root[LSLCHTTPSCHEDULEINVITEITEM_DURATIONADJUSTED_PARAM].isNumeric() ) {
                durationAdjusted = root[LSLCHTTPSCHEDULEINVITEITEM_DURATIONADJUSTED_PARAM].asInt();
            }
            
            /* startGmtTime */
            if( root[LSLCHTTPSCHEDULEINVITEITEM_STARTGMTTIME_PARAM].isNumeric() ) {
                startGmtTime = root[LSLCHTTPSCHEDULEINVITEITEM_STARTGMTTIME_PARAM].asLong();
            }

            /* timePeriod */
            if( root[LSLCHTTPSCHEDULEINVITEITEM_TIMEPERIOD_PARAM].isString() ) {
                timePeriod = root[LSLCHTTPSCHEDULEINVITEITEM_TIMEPERIOD_PARAM].asString();
            }
            
            /* inviteId */
            if( root[LSLCHTTPSCHEDULEINVITEITEM_INVITEID_PARAM].isString() ) {
                inviteId = root[LSLCHTTPSCHEDULEINVITEITEM_INVITEID_PARAM].asString();
            }
            
            /* actionGmtTime */
            if( root[LSLCHTTPSCHEDULEINVITEITEM_ACTIONGMTTIME_PARAM].isNumeric() ) {
                actionGmtTime = root[LSLCHTTPSCHEDULEINVITEITEM_ACTIONGMTTIME_PARAM].asLong();
            }
		}
		return result;
	}

	LSLCHttpScheduleInviteItem() {
        sessionId = "";
        type = 0;
        timeZone = "";
        timeZoneOffSet = 0;
        sessionDuration = 0;
        durationAdjusted = 0;
        startGmtTime = 0;
        timePeriod = "";
        inviteId = "";
        actionGmtTime = 0;
	}
	virtual ~LSLCHttpScheduleInviteItem() {

	}

    /**
     * 预约消息协议
     * @param sessionId        表单id
     * @param type               操作方式（SCHEDULEINVITE_PENDING:发送   SCHEDULEINVITE_CONFIRMED:接受    SCHEDULEINVITE_DECLINED:拒绝）
     * @param timeZone             时区字符串
     *   @param timeZoneOffSet       时区值
     *   @param sessionDuration       会话时长
     *   @param durationAdjusted      修改后的时长
     *   @param startGmtTime           预约开始时间
     *   @param timePeriod               时间周期
     *    @param inviteId                     会话邀请ID
     *    @param actionGmtTime         操作时间
     */
    string sessionId;
    int type;
    string timeZone;
    int timeZoneOffSet;
    int sessionDuration;
    int durationAdjusted;
    long long startGmtTime;
    string timePeriod;
    string inviteId;
    long long actionGmtTime;
};

#endif /* LSLCHTTPSCHEDULEINVITEITEM_H_ */
