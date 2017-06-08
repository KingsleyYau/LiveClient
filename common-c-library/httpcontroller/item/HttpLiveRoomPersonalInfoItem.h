/*
 * HttpLiveRoomPersonalInfoItem.h
 *
 *  Created on: 2017-5-24
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LIVEROOMPERSONALINFOITEM_H_
#define LIVEROOMPERSONALINFOITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"

class HttpLiveRoomPersonalInfoItem {
public:
	void Parse(const Json::Value& root) {
		if( root.isObject() ) {
			/* photoUrl */
			if( root[LIVEROOM_PUBLIC_PERSONAL_PHOTOURL].isString() ) {
				photoUrl = root[LIVEROOM_PUBLIC_PERSONAL_PHOTOURL].asString();
			}
            
            /* nickName */
            if( root[LIVEROOM_PUBLIC_PERSONAL_NICKNAME].isString() ) {
                nickName = root[LIVEROOM_PUBLIC_PERSONAL_NICKNAME].asString();
            }
            
            /* gender */
            if( root[LIVEROOM_PUBLIC_PERSONAL_GENDER].isInt() ) {
                gender = (Gender)(root[LIVEROOM_PUBLIC_PERSONAL_GENDER].asInt());
            }
            
            /* birthday */
            if( root[LIVEROOM_PUBLIC_PERSONAL_BIRTHDAY].isString() ) {
                birthday = root[LIVEROOM_PUBLIC_PERSONAL_BIRTHDAY].asString();
            }
            
        }
    }

	/**
	 * 登录成功结构体
	 * @param photoUrl		    头像url
	 * @param nickName          昵称
     * @param gender            性别（0:男性， 1:女性 ）
     * @param birthday		    出生日期（格式： 1980-01-01）
     */
	HttpLiveRoomPersonalInfoItem() {
		photoUrl = "";
		nickName = "";
        gender  = GENDER_UNKNOWN;
        birthday = "";
	}

	virtual ~HttpLiveRoomPersonalInfoItem() {

	}

	string photoUrl;
    string nickName;
    Gender gender;
    string birthday;
};


#endif /* LIVEROOMPERSONALINFOITEM_H_ */
