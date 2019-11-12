/*
 * ZBHttpUserInfoItem.h
 *
 *  Created on: 2019-11-08
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef ZBHTTPUSERINFOITEM_H_
#define ZBHTTPUSERINFOITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../ZBHttpLoginProtocol.h"

class ZBHttpUserInfoItem {
public:
	void Parse(const Json::Value& root) {
		if( root.isObject() ) {
			/* userId */
			if( root[GETCURRENTROOMINFO_USERINFO_USERID].isString() ) {
				userId = root[GETCURRENTROOMINFO_USERINFO_USERID].asString();
			}
            
			/* nickName */
			if( root[GETCURRENTROOMINFO_USERINFO_NICKNAME].isString() ) {
				nickName = root[GETCURRENTROOMINFO_USERINFO_NICKNAME].asString();
			}
            
            /* photoUrl */
            if( root[GETCURRENTROOMINFO_USERINFO_PHOTOURL].isString() ) {
                photoUrl = root[GETCURRENTROOMINFO_USERINFO_PHOTOURL].asString();
            }

        }
	}

	ZBHttpUserInfoItem() {
		userId = "";
		nickName = "";
        photoUrl = "";
	}

	virtual ~ZBHttpUserInfoItem() {

	}
    /**
     * 用户信息
     * userId			观众ID
     * nickName         观众昵称
     * photoUrl		    观众头像url
     */
    string userId;
    string nickName;
	string photoUrl;

};


#endif /* ZBHTTPUSERINFOITEM_H_ */
