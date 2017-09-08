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
            
            /* photoId */
            if (root[LIVEROOM_PUBLIC_PERSONAL_PHOTOID].isString()) {
                photoId = root[LIVEROOM_PUBLIC_PERSONAL_PHOTOID].asString();
            }
            
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

	HttpLiveRoomPersonalInfoItem() {
        photoId = "";
		photoUrl = "";
		nickName = "";
        gender  = GENDER_UNKNOWN;
        birthday = "";
	}

	virtual ~HttpLiveRoomPersonalInfoItem() {

	}
    /**
     * 获取编辑本人资料成功结构体
     * photoId           头像图片ID
     * photoUrl		    头像url
     * nickName          昵称
     * gender            性别（0:男性， 1:女性 ）
     * birthday		    出生日期（格式： 1980-01-01）
     */
    string photoId;
	string photoUrl;
    string nickName;
    Gender gender;
    string birthday;
};


#endif /* LIVEROOMPERSONALINFOITEM_H_ */
