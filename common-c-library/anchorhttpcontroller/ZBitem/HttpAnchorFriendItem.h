/*
 * HttpAnchorFriendItem.h
 *
 *  Created on: 2018-5-12
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPANCHORFRIENDITEM_H_
#define HTTPANCHORFRIENDITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../ZBHttpLoginProtocol.h"

class HttpAnchorFriendItem {
public:
	void Parse(const Json::Value& root) {
		if( root.isObject() ) {
			/* avatar */
			if( root[HANGOUTGETFRIENDRELATION_AVATAR].isString() ) {
				avatar = root[HANGOUTGETFRIENDRELATION_AVATAR].asString();
			}
            
			/* nickName */
			if( root[HANGOUTGETFRIENDRELATION_NICKNAME].isString() ) {
				nickName = root[HANGOUTGETFRIENDRELATION_NICKNAME].asString();
			}
            
            /* age */
            if( root[HANGOUTGETFRIENDRELATION_AGE].isIntegral() ) {
                age = root[HANGOUTGETFRIENDRELATION_AGE].asInt();
            }
            
            /* country */
            if( root[HANGOUTGETFRIENDRELATION_COUNTRY].isString() ) {
                country = root[HANGOUTGETFRIENDRELATION_COUNTRY].asString();
            }

            /* isFriend */
            if( root[HANGOUTGETFRIENDRELATION_ISFRIEND].isIntegral() ) {
                isFriend = GetIntToAnchorFriendType(root[HANGOUTGETFRIENDRELATION_ISFRIEND].asInt());
            }
        }
	}

	HttpAnchorFriendItem() {
		anchorId = "";
		avatar = "";
		nickName = "";
        age = 0;
        country = "";
        isFriend = ANCHORFRIENDTYPE_REQUESTING;
	}

	virtual ~HttpAnchorFriendItem() {

	}
    /**
     * 主播好友信息
     * anchorId			主播ID
     * nickName         昵称
     * photoUrl		    头像url
     * age              年龄
     * country          国家
     * isFriend 是否好友（ANCHORFRIENDTYPE_NO：否，ANCHORFRIENDTYPE_REQUESTING：请求中，ANCHORFRIENDTYPE_YES：是）
     */
    string anchorId;
    string avatar;
	string nickName;
    int age;
    string country;
    AnchorFriendType isFriend;
};


#endif /* HTTPANCHORFRIENDITEM_H_ */
