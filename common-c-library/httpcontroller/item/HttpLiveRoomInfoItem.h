/*
 * HttpLiveRoomInfoItem.h
 *
 *  Created on: 2017-5-23
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LIVEROOMINFOITEM_H_
#define LIVEROOMINFOITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"

class HttpLiveRoomInfoItem {
public:
	void Parse(const Json::Value& root) {
		if( root.isObject() ) {
			/* userId */
			if( root[LIVEROOM_HOT_USERID].isString() ) {
				userId = root[LIVEROOM_HOT_USERID].asString();
			}
            
			/* nickName */
			if( root[LIVEROOM_HOT_NICKNAME].isString() ) {
				nickName = root[LIVEROOM_HOT_NICKNAME].asString();
			}

			/* photoUrl */
			if( root[LIVEROOM_HOT_PHOTOURL].isString() ) {
				photoUrl = root[LIVEROOM_HOT_PHOTOURL].asString();
			}
            /* roomId */
            if( root[LIVEROOM_HOT_ROOMID].isString() ) {
                roomId = root[LIVEROOM_HOT_ROOMID].asString();
            }
            
            /* roomName */
            if( root[LIVEROOM_HOT_ROOMNAME].isString() ) {
                roomName = root[LIVEROOM_HOT_ROOMNAME].asString();
            }
            
            /* roomPhotoUrl */
            if( root[LIVEROOM_HOT_ROOMPHOTOURL].isString() ) {
                roomPhotoUrl = root[LIVEROOM_HOT_ROOMPHOTOURL].asString();
            }
            /* status */
            if( root[LIVEROOM_HOT_STATUS].isInt() ) {
                status = (LiveRoomStatus)(root[LIVEROOM_HOT_STATUS].asInt());
            }
            
            /* fansNum */
            if( root[LIVEROOM_HOT_FANSNUM].isInt() ) {
                fansNum = root[LIVEROOM_HOT_FANSNUM].asInt();
            }
            
            /* country */
            if( root[LIVEROOM_HOT_COUNTRY].isString() ) {
                country = root[LIVEROOM_HOT_COUNTRY].asString();
            }
            
        }
    }

	/**
	 * 登录成功结构体
	 * @param userId			主播ID
	 * @param nickName          主播昵称
	 * @param photoUrl		    主播头像url
     * @param roomId			直播间ID
     * @param roomName          直播间名称
     * @param roomPhotoUrl		直播间封面图url
     * @param status			直播间状态
     * @param fansNum           观众人数
     * @param country		    国家／地区
     */
	HttpLiveRoomInfoItem() {
		userId = "";
		nickName = "";
		photoUrl = "";
        roomId = "";
        roomName = "";
        roomPhotoUrl = "";
        status  = LIVEROOM_STATUS_LIVE;
        fansNum =  0;
        country = "";
	}

	virtual ~HttpLiveRoomInfoItem() {

	}

	string userId;
	string nickName;
	string photoUrl;
    string roomId;
    string roomName;
    string roomPhotoUrl;
    LiveRoomStatus status;
    int fansNum;
    string country;
};

typedef list<HttpLiveRoomInfoItem> HotItemList;

#endif /* LIVEROOMINFOITEM_H_ */
