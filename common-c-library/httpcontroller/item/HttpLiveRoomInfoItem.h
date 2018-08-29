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
#include "HttpProgramInfoItem.h"

// typedef list<string> InterestList;
typedef list<InterestType> InterestList;
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
            
            /* onlineStatus */
            if( root[LIVEROOM_HOT_ONLINESTATUS].isInt() ) {
                onlineStatus = GetIntToOnLineStatus(root[LIVEROOM_HOT_ONLINESTATUS].asInt());
            }

            /* roomPhotoUrl */
            if( root[LIVEROOM_HOT_ROOMPHOTOURL].isString() ) {
                roomPhotoUrl = root[LIVEROOM_HOT_ROOMPHOTOURL].asString();
            }
            
            /* roomType */
            if( root[LIVEROOM_HOT_ROOMTYPE].isInt() ) {
                roomType = GetIntToHttpRoomType(root[LIVEROOM_HOT_ROOMTYPE].asInt());
            }
            
            /* interest */
            if (root[LIVEROOM_HOT_INTEREST].isArray()) {
                for (int i = 0; i < root[LIVEROOM_HOT_INTEREST].size(); i++) {
                    Json::Value element = root[LIVEROOM_HOT_INTEREST].get(i, Json::Value::null);
                    if (element.isString()) {
                        //int intType = stoi(element.asString());
                        int intType = atoi(element.asString().c_str());
                        InterestType type = GetInterestType(intType);
                        if (type != INTERESTTYPE_NOINTEREST) {
                            interest.push_back(type);
                        }
                    }
                }
                
            }
            /* anchorType */
            if( root[LIVEROOM_HOT_ANCHORTYPE].isInt() ) {
                anchorType = GetIntToAnchorLevelType(root[LIVEROOM_HOT_ANCHORTYPE].asInt());
            }
            
            /* showInfo */
            if( root[LIVEROOM_HOT_SHOWINFO].isObject() ) {
                if (root[LIVEROOM_HOT_SHOWINFO].isNull()) {
                    if(showInfo != NULL) {
                        delete showInfo;
                    }
                    showInfo = NULL;
                }
                else {
                    showInfo = new HttpProgramInfoItem();
                    showInfo->Parse(root[LIVEROOM_HOT_SHOWINFO]);
                }
                
                
            }
        }
    }

	HttpLiveRoomInfoItem() {
		userId = "";
		nickName = "";
		photoUrl = "";
        roomPhotoUrl = "";
        onlineStatus  = ONLINE_STATUS_UNKNOWN;
        roomType = HTTPROOMTYPE_NOLIVEROOM;
        anchorType = ANCHORLEVELTYPE_UNKNOW;
        showInfo = NULL;
	}

	virtual ~HttpLiveRoomInfoItem() {
        if(showInfo != NULL) {
            delete showInfo;
        }
	}
    /**
     * Hot结构体
     * userId			主播ID
     * nickName         主播昵称
     * photoUrl		    主播头像url
     * onlineStatus		主播在线状态
     * roomPhotoUrl		直播间封面图url
     * roomType          直播间类型
     * interest          爱好ID列表
     * anchorType        主播类型（1:白银 2:黄金）
     * showInfo          节目信息
     */
    string userId;
	string nickName;
	string photoUrl;
    OnLineStatus onlineStatus;
    string roomPhotoUrl;
    HttpRoomType roomType;
    InterestList interest;
    AnchorLevelType anchorType;
    HttpProgramInfoItem* showInfo;
};

typedef list<HttpLiveRoomInfoItem* > HotItemList;
typedef list<HttpLiveRoomInfoItem>   AdItemList;

#endif /* LIVEROOMINFOITEM_H_ */
