/*
 * HttpLiveFansItem.h
 *
 *  Created on: 2017-8-16
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPLIVEFANSITEM_H_
#define HTTPLIVEFANSITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"

class HttpLiveFansItem {
public:
	void Parse(const Json::Value& root) {
		if( root.isObject() ) {
			/* userId */
			if( root[LIVEROOM_FANS_USERID].isString() ) {
				userId = root[LIVEROOM_FANS_USERID].asString();
			}
            
			/* nickName */
			if( root[LIVEROOM_FANS_NICK_NAME].isString() ) {
				nickName = root[LIVEROOM_FANS_NICK_NAME].asString();
			}

			/* photourl */
			if( root[LIVEROOM_FANS_PHOTO_URL].isString() ) {
				photoUrl = root[LIVEROOM_FANS_PHOTO_URL].asString();
			}
            
            /* mountId */
            if( root[LIVEROOM_FANS_MOUNTID].isString() ) {
                mountId = root[LIVEROOM_FANS_MOUNTID].asString();
            }
            
            /* mountUrl */
            if( root[LIVEROOM_FANS_MOUNTURL].isString() ) {
                mountUrl = root[LIVEROOM_FANS_MOUNTURL].asString();
            }
            
            /* level */
            if( root[LIVEROOM_FANS_LEVEL].isIntegral() ) {
                level = root[LIVEROOM_FANS_LEVEL].asInt();
            }
            
            /* isHasTicket */
            if( root[LIVEROOM_FANS_HASTICKET].isIntegral() ) {
                isHasTicket = root[LIVEROOM_FANS_HASTICKET].asInt() == 0 ? false : true;
            }
            
        }
	}

	HttpLiveFansItem() {
		userId = "";
		nickName = "";
		photoUrl = "";
        mountId = "";
        mountUrl = "";
        level = 0;
        isHasTicket = false;
	}

	virtual ~HttpLiveFansItem() {

	}
    /**
     * 指定观众信息结构体
     * userId			观众ID
     * nickName         观众昵称
     * photoUrl		    观众头像url
     * mountId          坐驾ID
     * mountUrl         坐驾图片url
     * level            用户等级
     * isHasTicket      是否已购票（false：否，true：是）
     */
    string userId;
	string nickName;
	string photoUrl;
    string mountId;
    string mountUrl;
    int    level;
    bool   isHasTicket;
};

typedef list<HttpLiveFansItem> HttpLiveFansList;

#endif /* HTTPLIVEFANSITEM_H_ */
