/*
 * ZBHttpLiveFansInfoItem.h
 *
 *  Created on: 2018-2-27
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef ZBHTTPLIVEFANSINFOITEM_H_
#define ZBHTTPLIVEFANSINFOITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../ZBHttpLoginProtocol.h"

class ZBHttpLiveFansInfoItem {
public:
	void Parse(const Json::Value& root) {
		if( root.isObject() ) {
            
			/* nickName */
			if( root[GETNEWFANSBASEINFO_NICKNAME].isString() ) {
				nickName = root[GETNEWFANSBASEINFO_NICKNAME].asString();
			}

			/* photourl */
			if( root[GETNEWFANSBASEINFO_PHOTOURL].isString() ) {
				photoUrl = root[GETNEWFANSBASEINFO_PHOTOURL].asString();
			}
            
            /* riderId */
            if( root[GETNEWFANSBASEINFO_RIDERID].isString() ) {
                riderId = root[GETNEWFANSBASEINFO_RIDERID].asString();
            }
            
            /* riderName */
            if( root[GETNEWFANSBASEINFO_RIDERNAME].isString() ) {
                riderName = root[GETNEWFANSBASEINFO_RIDERNAME].asString();
            }
            
            /* riderUrl */
            if( root[GETNEWFANSBASEINFO_RIDERURL].isString() ) {
                riderUrl = root[GETNEWFANSBASEINFO_RIDERURL].asString();
            }
            
            /* level */
            if( root[GETNEWFANSBASEINFO_LEVEL].isIntegral() ) {
                level = root[GETNEWFANSBASEINFO_LEVEL].asInt();
            }
            
            
        }
	}

	ZBHttpLiveFansInfoItem() {
		userId = "";
		nickName = "";
		photoUrl = "";
        riderId = "";
        riderName = "";
        riderUrl = "";
        level = 0;
	}

	virtual ~ZBHttpLiveFansInfoItem() {

	}
    /**
     * 指定观众信息结构体
     * userId           用户Id
     * nickName         观众昵称
     * photoUrl		    观众头像url
     * riderId          座驾ID
     * riderName        座驾名称
     * riderUrl         座驾图片url
     * level            用户等级
     */
	string userId;
	string nickName;
	string photoUrl;
    string riderId;
    string riderName;
    string riderUrl;
    int level;
};

#endif /* ZBHTTPLIVEFANSINFOITEM_H_ */
