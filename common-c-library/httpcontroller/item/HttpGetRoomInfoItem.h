/*
 * HttpGetRoomInfoItem.h
 *
 *  Created on: 2017-8-17
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPGETROOMINFOITEM_H_
#define HTTPGETROOMINFOITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"
#include "HttpInviteInfoItem.h"

class HttpGetRoomInfoItem {
public:
    class RoomItem {
    public:
        bool Parse(const Json::Value& root) {
            bool result = false;
            /* roomId */
            if (root[LIVEROOM_CHECKROOM_ROOMLIST_ROOMID].isString()) {
                roomId = root[LIVEROOM_CHECKROOM_ROOMLIST_ROOMID].asString();
            }
            
            /* roomUrl */
            if (root[LIVEROOM_CHECKROOM_ROOMLIST_ROOMURL].isString()) {
                roomUrl = root[LIVEROOM_CHECKROOM_ROOMLIST_ROOMURL].asString();
            }
            if (!roomId.empty()) {
                result = true;
            }
            return result;
        }
        
        RoomItem() {
            roomId = "";
            roomUrl = "";
        }
        
        virtual ~RoomItem() {
        
        }
        /**
         * 有效直播间结构体
         * roomId			直播间ID
         * roomUrl           直播间流媒体服务url（如rtmp://192.168.88.17/live/samson_1）
         */
        string roomId;
        string roomUrl;
    };
    typedef list<RoomItem> RoomItemList;
    
	void Parse(const Json::Value& root) {
		if( root.isObject() ) {
            /* roomList */
            if (root[LIVEROOM_CHECKROOM_ROOMLIST].isArray()) {
                for (int i = 0; i < root[LIVEROOM_CHECKROOM_ROOMLIST].size(); i++) {
                    Json::Value element = root[LIVEROOM_CHECKROOM_ROOMLIST].get(i, Json::Value::null);
                    RoomItem item;
                    if ( item.Parse(element)) {
                        roomList.push_back(item);
                    }
                   
                }
                
            }
            
            /* inviteList */
            if (root[LIVEROOM_CHECKROOM_INVITELIST].isArray()) {
                for (int i = 0; i < root[LIVEROOM_CHECKROOM_INVITELIST].size(); i++) {
                    Json::Value element = root[LIVEROOM_CHECKROOM_INVITELIST].get(i, Json::Value::null);
                    HttpInviteInfoItem item;
                    if ( item.Parse(element)) {
                        inviteList.push_back(item);
                    }
                    
                }
            }
            
        }
    }

	HttpGetRoomInfoItem() {

	}

	virtual ~HttpGetRoomInfoItem() {

	}

    /**
     * 登录成功结构体
     * roomList		 有效直播间数组
     * inviteList     有效邀请数组
     */
    RoomItemList      roomList;
    InviteItemList   inviteList;
};


#endif /* HTTPGETROOMINFOITEM_H_ */
