/*
 * HttpAnchorItem.h
 *
 *  Created on: 2018-4-3
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPANCHORITEM_H_
#define HTTPANCHORITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../ZBHttpLoginProtocol.h"

class HttpAnchorItem {
public:
	void Parse(const Json::Value& root) {
		if( root.isObject() ) {
			/* anchorId */
			if( root[GETCANRECOMMENDFRIENDLIST_ANCHORLIST_ANCHORID].isString() ) {
				anchorId = root[GETCANRECOMMENDFRIENDLIST_ANCHORLIST_ANCHORID].asString();
			}
            
			/* nickName */
			if( root[GETCANRECOMMENDFRIENDLIST_ANCHORLIST_NICKNAME].isString() ) {
				nickName = root[GETCANRECOMMENDFRIENDLIST_ANCHORLIST_NICKNAME].asString();
			}

			/* photoUrl */
			if( root[GETCANRECOMMENDFRIENDLIST_ANCHORLIST_PHOTOURL].isString() ) {
				photoUrl = root[GETCANRECOMMENDFRIENDLIST_ANCHORLIST_PHOTOURL].asString();
			}
            
            /* age */
            if( root[GETCANRECOMMENDFRIENDLIST_ANCHORLIST_AGE].isIntegral() ) {
                age = root[GETCANRECOMMENDFRIENDLIST_ANCHORLIST_AGE].asInt();
            }
            
            /* country */
            if( root[GETCANRECOMMENDFRIENDLIST_ANCHORLIST_COUNTRY].isString() ) {
                country = root[GETCANRECOMMENDFRIENDLIST_ANCHORLIST_COUNTRY].asString();
            }

            
        }
	}

	HttpAnchorItem() {
		anchorId = "";
		nickName = "";
		photoUrl = "";
        age = 0;
        country = "";
	}

	virtual ~HttpAnchorItem() {

	}
    /**
     * 主播列表结构体
     * anchorId			主播ID
     * nickName         昵称
     * photoUrl		    头像url
     * age              年龄
     * country          国家
     */
    string anchorId;
	string nickName;
	string photoUrl;
    int age;
    string country;
};

typedef list<HttpAnchorItem> HttpAnchorItemList;

#endif /* HTTPANCHORITEM_H_ */
