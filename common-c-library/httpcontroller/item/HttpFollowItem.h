/*
 * HttpFollowItem.h
 *
 *  Created on: 2017-8-16
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPFOLLOWITEM_H_
#define HTTPFOLLOWITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"

typedef list<string> FollowInterestList;

class HttpFollowItem {
public:
	void Parse(const Json::Value& root) {
		if( root.isObject() ) {
			/* userId */
			if( root[LIVEROOM_FOLLOW_USERID].isString() ) {
				userId = root[LIVEROOM_FOLLOW_USERID].asString();
			}
            
			/* nickName */
			if( root[LIVEROOM_FOLLOW_NICKNAME].isString() ) {
				nickName = root[LIVEROOM_FOLLOW_NICKNAME].asString();
			}

			/* photoUrl */
			if( root[LIVEROOM_FOLLOW_PHOTOURL].isString() ) {
				photoUrl = root[LIVEROOM_FOLLOW_PHOTOURL].asString();
			}
            /* onlineStatus */
            if( root[LIVEROOM_FOLLOW_ONLINESTATUS].isInt() ) {
                onlineStatus = (OnLineStatus)(root[LIVEROOM_FOLLOW_ONLINESTATUS].asInt());
            }
            
            /* roomName */
            if( root[LIVEROOM_FOLLOW_ROOMNAME].isString() ) {
                roomName = root[LIVEROOM_FOLLOW_ROOMNAME].asString();
            }
            
            /* roomPhotoUrl */
            if( root[LIVEROOM_FOLLOW_ROOMPHOTOURL].isString() ) {
                roomPhotoUrl = root[LIVEROOM_FOLLOW_ROOMPHOTOURL].asString();
            }
            /* loveLevel */
            if( root[LIVEROOM_FOLLOW_LOVELEVEL].isInt() ) {
                loveLevel = root[LIVEROOM_FOLLOW_LOVELEVEL].asInt();
            }
            /* roomType */
            if( root[LIVEROOM_FOLLOW_ROOMTYPE].isInt() ) {
                roomType = (HttpRoomType)root[LIVEROOM_FOLLOW_ROOMTYPE].asInt();
            }
            /* addDate */
            if( root[LIVEROOM_FOLLOW_LOVELEVEL].isIntegral() ) {
                addDate = root[LIVEROOM_FOLLOW_LOVELEVEL].asInt();
            }
            /* interest */
            if (root[LIVEROOM_FOLLOW_INTEREST].isArray()) {
                for (int i = 0; i < root[LIVEROOM_FOLLOW_INTEREST].size(); i++) {
                    Json::Value element = root[LIVEROOM_FOLLOW_INTEREST].get(i, Json::Value::null);
                    if (element.isString()) {
                        interest.push_back(element.asString());
                    }
                }
                
            }

        }
    }

	HttpFollowItem() {
		userId = "";
		nickName = "";
		photoUrl = "";
        roomName = "";
        roomPhotoUrl = "";
        onlineStatus  = ONLINE_STATUS_UNKNOWN;
        roomType = HTTPROOMTYPE_NOLIVEROOM;
        loveLevel = 0;
        addDate = 0;
	}

	virtual ~HttpFollowItem() {

	}
    
    /**
     * Follow结构体
     * userId			主播ID
     * nickName         主播昵称
     * photoUrl		    主播头像url
     * onlineStatus		主播在线状态
     * roomName         直播间名称
     * loveLevel        亲密度等级
     * roomPhotoUrl		直播间封面图url
     * roomType         直播间类型
     * addDate          添加收藏时间（1970年起的秒数）
     * interest         爱好ID列表
     */
    string userId;
	string nickName;
	string photoUrl;
    OnLineStatus onlineStatus;
    string roomName;
    string roomPhotoUrl;
    int  loveLevel;
    HttpRoomType roomType;
    long addDate;
    FollowInterestList interest;
};

typedef list<HttpFollowItem> FollowItemList;

#endif /* HTTPFOLLOWITEM_H_ */
