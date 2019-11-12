/*
 * HttpRecommendAnchorItem.h
 *
 *  Created on: 2019-6-11
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPRECOMMENDANCHORITEM_H_
#define HTTPRECOMMENDANCHORITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"
#include "HttpAuthorityItem.h"

class HttpRecommendAnchorItem {
public:
    void ParseContact(const Json::Value& root) {
        if( root.isObject() ) {
            /* anchorId */
            if( root[LIVEROOM_GETCONTACTLIST_LIST_ANCHOR].isString() ) {
                anchorId = root[LIVEROOM_GETCONTACTLIST_LIST_ANCHOR].asString();
            }
            
            /* anchorNickName */
            if( root[LIVEROOM_GETCONTACTLIST_LIST_ANCHORNICKNAME].isString() ) {
                anchorNickName = root[LIVEROOM_GETCONTACTLIST_LIST_ANCHORNICKNAME].asString();
            }
            
            /* anchorCover */
            if( root[LIVEROOM_GETCONTACTLIST_LIST_ANCHORCOVERIMG].isString() ) {
                anchorCover = root[LIVEROOM_GETCONTACTLIST_LIST_ANCHORCOVERIMG].asString();
            }
            
            /* anchorAvatar */
            if( root[LIVEROOM_GETCONTACTLIST_LIST_ANCHORAVATARIMG].isString() ) {
                anchorAvatar = root[LIVEROOM_GETCONTACTLIST_LIST_ANCHORAVATARIMG].asString();
            }
            
            /* isFollow */
            if (root[LIVEROOM_GETPAGERECOMMENDANCHORLIST_LIST_ISFOLLOW].isNumeric()) {
                isFollow = root[LIVEROOM_GETPAGERECOMMENDANCHORLIST_LIST_ISFOLLOW].asInt() == 0 ? false : true;
            }
            
            /* onlineStatus */
            if (root[LIVEROOM_GETCONTACTLIST_LIST_ONLINESTATUS].isNumeric()) {
                onlineStatus = GetIntToOnLineStatus(root[LIVEROOM_GETCONTACTLIST_LIST_ONLINESTATUS].asInt());
            }
            
            /* publicRoomId */
            if( root[LIVEROOM_GETCONTACTLIST_LIST_PUBLICROOMID].isString() ) {
                publicRoomId = root[LIVEROOM_GETCONTACTLIST_LIST_PUBLICROOMID].asString();
            }
            
            
            /* roomType */
            if( root[LIVEROOM_GETCONTACTLIST_LIST_ROOMTYPE].isInt() ) {
                roomType = GetIntToHttpRoomType(root[LIVEROOM_GETCONTACTLIST_LIST_ROOMTYPE].asInt());
            }
            
            /* priv */
            if ( root[LIVEROOM_GETCONTACTLIST_LIST_ANCHORPRIV].isObject()) {
                priv.Parse(root[LIVEROOM_GETCONTACTLIST_LIST_ANCHORPRIV]);
            }
            
            /* lastCountactTime */
            if( root[LIVEROOM_GETCONTACTLIST_LIST_LASTCONTACTTIME].isNumeric() ) {
                lastCountactTime = root[LIVEROOM_GETCONTACTLIST_LIST_LASTCONTACTTIME].asInt();
            }
            
        }
    }

	void Parse(const Json::Value& root) {
		if( root.isObject() ) {
			/* anchorId */
			if( root[LIVEROOM_GETPAGERECOMMENDANCHORLIST_LIST_ANCHOR].isString() ) {
				anchorId = root[LIVEROOM_GETPAGERECOMMENDANCHORLIST_LIST_ANCHOR].asString();
			}
            
			/* anchorNickName */
			if( root[LIVEROOM_GETPAGERECOMMENDANCHORLIST_LIST_ANCHORNICKNAME].isString() ) {
				anchorNickName = root[LIVEROOM_GETPAGERECOMMENDANCHORLIST_LIST_ANCHORNICKNAME].asString();
			}

			/* anchorCover */
			if( root[LIVEROOM_GETPAGERECOMMENDANCHORLIST_LIST_ANCHORCOVER].isString() ) {
				anchorCover = root[LIVEROOM_GETPAGERECOMMENDANCHORLIST_LIST_ANCHORCOVER].asString();
			}
            
            /* anchorAvatar */
            if( root[LIVEROOM_GETPAGERECOMMENDANCHORLIST_LIST_ANCHORAVATAR].isString() ) {
                anchorAvatar = root[LIVEROOM_GETPAGERECOMMENDANCHORLIST_LIST_ANCHORAVATAR].asString();
            }
            
            /* isFollow */
            if (root[LIVEROOM_GETPAGERECOMMENDANCHORLIST_LIST_ISFOLLOW].isNumeric()) {
                isFollow = root[LIVEROOM_GETPAGERECOMMENDANCHORLIST_LIST_ISFOLLOW].asInt() == 0 ? false : true;
            }
            
            /* onlineStatus */
            if (root[LIVEROOM_GETPAGERECOMMENDANCHORLIST_LIST_ONLINESTATUS].isNumeric()) {
                onlineStatus = GetIntToOnLineStatus(root[LIVEROOM_GETPAGERECOMMENDANCHORLIST_LIST_ONLINESTATUS].asInt());
            }

            /* publicRoomId */
            if( root[LIVEROOM_GETPAGERECOMMENDANCHORLIST_LIST_PUBLICROOMID].isString() ) {
                publicRoomId = root[LIVEROOM_GETPAGERECOMMENDANCHORLIST_LIST_PUBLICROOMID].asString();
            }

            lastCountactTime = 0;
        }
    }

	HttpRecommendAnchorItem() {
		anchorId = "";
		anchorNickName = "";
		anchorCover = "";
        anchorAvatar = "";
        isFollow = false;
        onlineStatus = ONLINE_STATUS_LIVE;
        publicRoomId = "";
        roomType = HTTPROOMTYPE_NOLIVEROOM;
        lastCountactTime = 0;
	}

	virtual ~HttpRecommendAnchorItem() {

	}
    
    /**
     * 推荐主播结构体
     * anchorId			主播ID
     * anchorNickName   主播昵称
     * anchorCover		主播封面
     * anchorAvatar		主播头像
     * isFollow         是否关注（0：不关注，1：关注）
     * onlineStatus		在线状态
     * publicRoomId     公开直播间ID(空值则表示不在公开中)
     * lastCountactTime 最后联系人时间
     */
    string anchorId;
	string anchorNickName;
	string anchorCover;
    string anchorAvatar;
    bool   isFollow;
    OnLineStatus onlineStatus;
    string publicRoomId;
    HttpRoomType roomType;
    HttpAuthorityItem priv;
    long long lastCountactTime;
};

typedef list<HttpRecommendAnchorItem> RecommendAnchorList;

#endif /* HTTPRECOMMENDANCHORITEM_H_ */
