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
#include "HttpProgramInfoItem.h"
#include "HttpAuthorityItem.h"

typedef list<InterestType> FollowInterestList;

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
                onlineStatus = GetIntToOnLineStatus(root[LIVEROOM_FOLLOW_ONLINESTATUS].asInt());
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
                roomType = GetIntToHttpRoomType(root[LIVEROOM_FOLLOW_ROOMTYPE].asInt());
            }
            /* addDate */
            if( root[LIVEROOM_FOLLOW_ADDDATE].isIntegral() ) {
                addDate = root[LIVEROOM_FOLLOW_ADDDATE].asInt();
            }
            /* interest */
            if (root[LIVEROOM_FOLLOW_INTEREST].isArray()) {
                for (int i = 0; i < root[LIVEROOM_FOLLOW_INTEREST].size(); i++) {
                    Json::Value element = root[LIVEROOM_FOLLOW_INTEREST].get(i, Json::Value::null);
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
            if( root[LIVEROOM_FOLLOW_ANCHORTYPE].isInt() ) {
                anchorType = GetIntToAnchorLevelType(root[LIVEROOM_FOLLOW_ANCHORTYPE].asInt());
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
                    showInfo = new HttpProgramInfoItem;
                    showInfo->Parse(root[LIVEROOM_HOT_SHOWINFO]);
                }
            }
            
            /* priv */
            if ( root[LIVEROOM_HOT_PROGRAMLIST_PRIV].isObject()) {
                priv.Parse(root[LIVEROOM_HOT_PROGRAMLIST_PRIV]);
            }
            
            if (root[LIVEROOM_HOT_PROGRAMLIST_CHAT_ONLINE_STATUS].isNumeric()) {
                chatOnlineStatus = GetIntToIMChatOnlineStatus(root[LIVEROOM_HOT_PROGRAMLIST_CHAT_ONLINE_STATUS].asInt());
            }

        }
    }

	HttpFollowItem() {
		userId = "";
		nickName = "";
		photoUrl = "";
        roomPhotoUrl = "";
        onlineStatus  = ONLINE_STATUS_UNKNOWN;
        roomType = HTTPROOMTYPE_NOLIVEROOM;
        loveLevel = 0;
        addDate = 0;
        anchorType = ANCHORLEVELTYPE_UNKNOW;
        showInfo = NULL;
        chatOnlineStatus = IMCHATONLINESTATUS_OFF;
	}

	virtual ~HttpFollowItem() {
        if(showInfo != NULL) {
            delete showInfo;
        }
	}
    
    /**
     * Follow结构体
     * userId			主播ID
     * nickName         主播昵称
     * photoUrl		    主播头像url
     * onlineStatus		主播在线状态
     * loveLevel        亲密度等级
     * roomPhotoUrl		直播间封面图url
     * roomType         直播间类型
     * addDate          添加收藏时间（1970年起的秒数）
     * interest         爱好ID列表
     * anchorType        主播类型（1:白银 2:黄金）
     * showInfo         节目信息
     * priv             权限
     */
    string userId;
	string nickName;
	string photoUrl;
    OnLineStatus onlineStatus;
    string roomPhotoUrl;
    int  loveLevel;
    HttpRoomType roomType;
    long addDate;
    FollowInterestList interest;
    AnchorLevelType anchorType;
    HttpProgramInfoItem* showInfo;
    HttpAuthorityItem    priv;
    IMChatOnlineStatus   chatOnlineStatus;
};

typedef list<HttpFollowItem*> FollowItemList;

#endif /* HTTPFOLLOWITEM_H_ */
