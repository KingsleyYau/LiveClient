/*
 * HttpUserInfoItem.h
 *
 *  Created on: 2017-11-01
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPUSERINFOITEM_H_
#define HTTPUSERINFOITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "HttpAnchorInfoItem.h"
#include "HttpFansiInfoItem.h"

class HttpUserInfoItem {
public:
	void Parse(const Json::Value& root) {
		if( root.isObject() ) {
            
            /* userId */
            if( root[LIVEROOM_GETUSERINFO_LSUSERID].isString() ) {
                userId = root[LIVEROOM_GETUSERINFO_LSUSERID].asString();
            }
            
            /* nickName */
			if( root[LIVEROOM_GETNEWFANSBASEINFO_NICKNAME].isString() ) {
				nickName = root[LIVEROOM_GETUSERINFO_NICKNAME].asString();
			}

			/* photoUrl */
			if( root[LIVEROOM_GETUSERINFO_PHOTOURL].isString() ) {
				photoUrl = root[LIVEROOM_GETUSERINFO_PHOTOURL].asString();
			}
            
            /* age */
            if( root[LIVEROOM_GETUSERINFO_AGE].isNumeric() ) {
                age = root[LIVEROOM_GETUSERINFO_AGE].asInt();
            }
            
            /* country */
            if( root[LIVEROOM_GETUSERINFO_COUNTRY].isString() ) {
                country = root[LIVEROOM_GETUSERINFO_COUNTRY].asString();
            }
            
            /* userLevel */
            if( root[LIVEROOM_GETUSERINFO_USERLEVEL].isNumeric() ) {
                userLevel = root[LIVEROOM_GETUSERINFO_USERLEVEL].asInt();
            }
            
            /* isOnline */
            if( root[LIVEROOM_GETUSERINFO_ISONLINE].isNumeric() ) {
                isOnline = root[LIVEROOM_GETUSERINFO_ISONLINE].asInt() == 1 ? true : false;
            }
            
            /* isAnchor */
            if( root[LIVEROOM_GETUSERINFO_ISANCHOR].isNumeric() ) {
                isAnchor = root[LIVEROOM_GETUSERINFO_ISANCHOR].asInt() == 1 ? true : false;
            }
            
            /* leftCredit */
            if( root[LIVEROOM_GETUSERINFO_LEFTCREDIT].isNumeric() ) {
                leftCredit = root[LIVEROOM_GETUSERINFO_LEFTCREDIT].asDouble();
            }
            
            if (root[LIVEROOM_GETUSERINFO_ANCHORINFO].isObject()) {
                anchorInfo.Parse(root[LIVEROOM_GETUSERINFO_ANCHORINFO]);
            }
            
            if (root[LIVEROOM_GETUSERINFO_FANSIINFO].isObject()) {
                fansiInfo.Parse(root[LIVEROOM_GETUSERINFO_FANSIINFO]);
            }
            
        }
	}

	HttpUserInfoItem() {
		userId = "";
		nickName = "";
		photoUrl = "";
        age = 0;
        country = "";
        userLevel = 0;
        isOnline = false;
        isAnchor = false;
        leftCredit = 0.0;
	}

	virtual ~HttpUserInfoItem() {

	}
    /**
     * 指定观众/主播信息结构体
     * userId           观众ID/主播ID
     * nickName         昵称
     * photoUrl		    头像url
     * age              年龄
     * country          国籍
     * userlevel        观众/主播等级
     * isOnline         是否在线（0：否，1：是）
     * isAnchor         是否主播（0：否，1：是）
     * leftCredit       观众剩余信用点
     * anchorInfo       主播信息
     * fansiInfo       观众信息
     */
	string userId;
	string nickName;
	string photoUrl;
    int age;
    string country;
    int userLevel;
    bool isOnline;
    bool isAnchor;
    double leftCredit;
    HttpAnchorInfoItem anchorInfo;
    HttpFansiInfoItem fansiInfo;
};

#endif /* HTTPUSERINFOITEM_H_ */
