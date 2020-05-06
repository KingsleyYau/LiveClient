/*
 * HttpScheduleInviteStatusItem.h
 *
 *  Created on: 2020-03-26
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPSCHEDULEINVITESTATUSITEM_H_
#define HTTPSCHEDULEINVITESTATUSITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"

class HttpScheduleInviteStatusItem {
public:

	bool Parse(const Json::Value& root) {
        bool result = false;
		if( root.isObject() ) {
            
            /* needStartNum */
            if (root[LIVEROOM_GETINVITESTATUS_NEEDSTARTNUM].isNumeric()) {
                needStartNum = root[LIVEROOM_GETINVITESTATUS_NEEDSTARTNUM].asInt();
            }
            
            /* beStartNum */
            if (root[LIVEROOM_GETINVITESTATUS_BESTARTNUM].isNumeric()) {
                beStartNum = root[LIVEROOM_GETINVITESTATUS_BESTARTNUM].asInt();
            }
            
            /* beStrtTime */
            if (root[LIVEROOM_GETINVITESTATUS_BESTARTTIME].isNumeric()) {
                beStrtTime = root[LIVEROOM_GETINVITESTATUS_BESTARTTIME].asLong();
            }
            
            /* startLeftSeconds */
            if (root[LIVEROOM_GETINVITESTATUS_STARTLEFTNUM].isNumeric()) {
                startLeftSeconds = root[LIVEROOM_GETINVITESTATUS_STARTLEFTNUM].asInt();
            }
            
            result = true;
        }
        return result;
    }

	HttpScheduleInviteStatusItem() {
        needStartNum = 0;
        beStartNum = 0;
        beStrtTime = 0;
        startLeftSeconds = 0;
	}

	virtual ~HttpScheduleInviteStatusItem() {

	}
    
    /**
     * 预付费邀请状态结构体
     * needStartNum                 已经开始的数量
     * beStartNum                     将要开始的数量
     * beStrtTime                       将要开始的时间(GMT时间戳)
     * startLeftSeconds             开始剩余秒数
     */
    int needStartNum;
    int beStartNum;
    long long beStrtTime;
    int startLeftSeconds;
    
};


#endif /* HTTPSCHEDULEINVITESTATUSITEM_H_ */
