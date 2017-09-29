/*
 * HttpLiveFansInfoItem.h
 *
 *  Created on: 2017-9-22
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPLIVEFANSINFOITEM_H_
#define HTTPLIVEFANSINFOITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"

class HttpLiveFansInfoItem {
public:
	void Parse(const Json::Value& root) {
		if( root.isObject() ) {
            
			/* nickName */
			if( root[LIVEROOM_GETNEWFANSBASEINFO_NICKNAME].isString() ) {
				nickName = root[LIVEROOM_GETNEWFANSBASEINFO_NICKNAME].asString();
			}

			/* photourl */
			if( root[LIVEROOM_GETNEWFANSBASEINFO_PHOTOURL].isString() ) {
				photoUrl = root[LIVEROOM_GETNEWFANSBASEINFO_PHOTOURL].asString();
			}
            
            /* riderId */
            if( root[LIVEROOM_GETNEWFANSBASEINFO_RIDERID].isString() ) {
                riderId = root[LIVEROOM_GETNEWFANSBASEINFO_RIDERID].asString();
            }
            
            /* riderName */
            if( root[LIVEROOM_GETNEWFANSBASEINFO_RIDERNAME].isString() ) {
                riderName = root[LIVEROOM_GETNEWFANSBASEINFO_RIDERNAME].asString();
            }
            
            /* riderUrl */
            if( root[LIVEROOM_GETNEWFANSBASEINFO_RIDERURL].isString() ) {
                riderUrl = root[LIVEROOM_GETNEWFANSBASEINFO_RIDERURL].asString();
            }
            
        }
	}

	HttpLiveFansInfoItem() {
		userId = "";
		nickName = "";
		photoUrl = "";
        riderId = "";
        riderName = "";
        riderUrl = "";
	}

	virtual ~HttpLiveFansInfoItem() {

	}
    /**
     * 指定观众信息结构体
     * userId           用户Id
     * nickName         观众昵称
     * photoUrl		    观众头像url
     * riderId          座驾ID
     * riderName        座驾名称
     * riderUrl         座驾图片url
     */
	string userId;
	string nickName;
	string photoUrl;
    string riderId;
    string riderName;
    string riderUrl;
};

#endif /* HTTPLIVEFANSINFOITEM_H_ */
