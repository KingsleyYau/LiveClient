/*
 * HttpScheduleAnchorInfoItem.h
 *
 *  Created on: 2020-03-26
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPSCHEDULEANCHORINFOITEM_H_
#define HTTPSCHEDULEANCHORINFOITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"

class HttpScheduleAnchorInfoItem {
public:

	bool Parse(const Json::Value& root) {
        bool result = false;
		if( root.isObject() ) {
            
            /* anchorId */
            if (root[LIVEROOM_GETINVITELIST_ANCHOR_INFO_ANCHOR_ID].isString()) {
                anchorId = root[LIVEROOM_GETINVITELIST_ANCHOR_INFO_ANCHOR_ID].asString();
            }
            /* nickName */
            if (root[LIVEROOM_GETINVITELIST_ANCHOR_INFO_NICK_NAME].isString()) {
                nickName = root[LIVEROOM_GETINVITELIST_ANCHOR_INFO_NICK_NAME].asString();
            }
            /* avatarImg */
            if (root[LIVEROOM_GETINVITELIST_ANCHOR_INFO_AVATAR_IMG].isString()) {
                avatarImg = root[LIVEROOM_GETINVITELIST_ANCHOR_INFO_AVATAR_IMG].asString();
            }
            /* onlineStatus */
            if (root[LIVEROOM_GETINVITELIST_ANCHOR_INFO_ONLINE_STATUS].isNumeric()) {
                onlineStatus = GetIntToOnLineStatus(root[LIVEROOM_GETINVITELIST_ANCHOR_INFO_ONLINE_STATUS].asInt());
            }
            /* age */
            if (root[LIVEROOM_GETINVITELIST_ANCHOR_INFO_AGE].isNumeric()) {
                age = root[LIVEROOM_GETINVITELIST_ANCHOR_INFO_AGE].asInt();
            }
            /* country */
            if (root[LIVEROOM_GETINVITELIST_ANCHOR_INFO_COUNTRY].isString()) {
                country = root[LIVEROOM_GETINVITELIST_ANCHOR_INFO_COUNTRY].asString();
            }

            result = true;
        }
        return result;
    }

	HttpScheduleAnchorInfoItem() {
        anchorId = "";
        nickName = "";
        avatarImg = "";
        onlineStatus = ONLINE_STATUS_UNKNOWN;
        age = 0;
        country = "";
	}

	virtual ~HttpScheduleAnchorInfoItem() {

	}
    
    /**
     * 预付费主播信息结构体
     * anchorId         主播ID
     * nickName         昵称
     * avatarImg        主播头像url
     * onlineStatus     在线状态（ONLINE_STATUS_OFFLINE：离线，ONLINE_STATUS_LIVE：在线）
     * age              年龄
     * country            国家
     */
    string anchorId;
    string nickName;
    string avatarImg;
    OnLineStatus onlineStatus;
    int      age;
    string   country;
    
};


#endif /* HTTPSCHEDULEANCHORINFOITEM_H_ */
