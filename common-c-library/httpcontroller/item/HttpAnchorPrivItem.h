/*
 * HttpAnchorPrivItem.h
 *
 *  Created on: 2020-04-10
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPANCHORPRIVITEM_H_
#define HTTPANCHORPRIVITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"

class HttpAnchorPrivItem {
public:
	void Parse(const Json::Value& root) {
		if( root.isObject() ) {
            
            /* scheduleOneOnOneRecvPriv */
            if( root[LIVEROOM_GETUSRRINFO_ANCHORINFO_PRIV_SCHEDULE_ONEONONE].isNumeric() ) {
                scheduleOneOnOneRecvPriv = root[LIVEROOM_GETUSRRINFO_ANCHORINFO_PRIV_SCHEDULE_ONEONONE].asInt() == 1 ? true : false;
            }
            
            /* scheduleOneOnOneSendPriv */
            if( root[LIVEROOM_GETUSRRINFO_ANCHORINFO_PRIV_SCHEDULE_ONEONONE_SEND].isNumeric() ) {
                scheduleOneOnOneSendPriv = root[LIVEROOM_GETUSRRINFO_ANCHORINFO_PRIV_SCHEDULE_ONEONONE_SEND].asInt() == 1 ? true : false;
            }
            
        }
	}

	HttpAnchorPrivItem() {
		scheduleOneOnOneRecvPriv = false;
		scheduleOneOnOneSendPriv = false;
	}

	virtual ~HttpAnchorPrivItem() {

	}
    /**
     * 主播权限结构体
     * scheduleOneOnOneRecvPriv              是否有接收邀请权限
     * scheduleOneOnOneSendPriv           是否有发送邀请权限
     */

    bool scheduleOneOnOneRecvPriv;
    bool scheduleOneOnOneSendPriv;

};

#endif /* HTTPANCHORPRIVITEM_H_ */
