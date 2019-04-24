/*
 * HttpHangoutAnchorItem.h
 *
 *  Created on: 2018-4-12
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPHANGOUTANCHORITEM_H_
#define HTTPHANGOUTANCHORITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"

typedef list<string> WatchAnchorList;

class HttpHangoutAnchorItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* anchorId */
            if (root[LIVEROOM_GETCANHANGOUTANCHORLIST_LIST_ANCHORID].isString()) {
                anchorId = root[LIVEROOM_GETCANHANGOUTANCHORLIST_LIST_ANCHORID].asString();
            }
            /* nickName */
            if (root[LIVEROOM_GETCANHANGOUTANCHORLIST_LIST_NICKNAME].isString()) {
                nickName = root[LIVEROOM_GETCANHANGOUTANCHORLIST_LIST_NICKNAME].asString();
            }
            /* photoUrl */
            if (root[LIVEROOM_GETCANHANGOUTANCHORLIST_LIST_PHOTOURL].isString()) {
                photoUrl = root[LIVEROOM_GETCANHANGOUTANCHORLIST_LIST_PHOTOURL].asString();
            }
            /* avatarImg */
            if (root[LIVEROOM_GETCANHANGOUTANCHORLIST_LIST_AVATAR_IMG].isString()) {
                avatarImg = root[LIVEROOM_GETCANHANGOUTANCHORLIST_LIST_AVATAR_IMG].asString();
            }
            /* age */
            if (root[LIVEROOM_GETCANHANGOUTANCHORLIST_LIST_AGE].isNumeric()) {
                age = root[LIVEROOM_GETCANHANGOUTANCHORLIST_LIST_AGE].asInt();
            }
            /* country */
            if (root[LIVEROOM_GETCANHANGOUTANCHORLIST_LIST_COUNTRY].isString()) {
                country = root[LIVEROOM_GETCANHANGOUTANCHORLIST_LIST_COUNTRY].asString();
            }
            
            /* onlineStatus */
            if (root[LIVEROOM_GETCANHANGOUTANCHORLIST_LIST_ONLINESTATUS].isNumeric()) {
                onlineStatus = GetIntToOnLineStatus(root[LIVEROOM_GETCANHANGOUTANCHORLIST_LIST_ONLINESTATUS].asInt());
            }

        }
        result = true;
        return result;
    }

    HttpHangoutAnchorItem() {
        anchorId = "";
        nickName = "";
        photoUrl = "";
        age = 0;
        country = "";
        onlineStatus = ONLINE_STATUS_UNKNOWN;
        avatarImg = "";
    }
    
    virtual ~HttpHangoutAnchorItem() {
        
    }
    
    /**
     * 多人互动的主播列表结构体
     * anchorId         主播ID
     * nickName         昵称
     * photoUrl         主播封面url
     * avatarImg        主播头像url
     * age              年龄
     * country		    国家
     * onlineStatus     在线状态（ONLINE_STATUS_OFFLINE：离线，ONLINE_STATUS_LIVE：在线）
     */
    string   anchorId;
    string   nickName;
    string   photoUrl;
    string   avatarImg;
    int      age;
    string   country;
    OnLineStatus onlineStatus;
};

typedef list<HttpHangoutAnchorItem> HangoutAnchorList;

#endif /* HTTPHANGOUTANCHORITEM_H_*/
