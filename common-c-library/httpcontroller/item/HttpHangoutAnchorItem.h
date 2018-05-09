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
            /* age */
            if (root[LIVEROOM_GETCANHANGOUTANCHORLIST_LIST_AGE].isNumeric()) {
                age = root[LIVEROOM_GETCANHANGOUTANCHORLIST_LIST_AGE].asInt();
            }
            /* country */
            if (root[LIVEROOM_GETCANHANGOUTANCHORLIST_LIST_COUNTRY].isString()) {
                country = root[LIVEROOM_GETCANHANGOUTANCHORLIST_LIST_COUNTRY].asString();
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
    }
    
    virtual ~HttpHangoutAnchorItem() {
        
    }
    
    /**
     * 多人互动的主播列表结构体
     * anchorId         主播ID
     * nickName         昵称
     * photoUrl         头像
     * age              年龄
     * country		    国家
     */
    string   anchorId;
    string   nickName;
    string   photoUrl;
    int      age;
    string   country;
};

typedef list<HttpHangoutAnchorItem> HangoutAnchorList;

#endif /* HTTPHANGOUTANCHORITEM_H_*/
