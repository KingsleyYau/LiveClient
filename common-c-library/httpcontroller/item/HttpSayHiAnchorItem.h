/*
 * HttpSayHiAnchorItem.h
 *
 *  Created on: 2019-4-18
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPSAYHIANCHORITEM_H_
#define HTTPSAYHIANCHORITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"

class HttpSayHiAnchorItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* anchorId */
            if (root[LIVEROOM_GETSAYHIANCHORLIST_LIST_ANCHORID].isString()) {
                anchorId = root[LIVEROOM_GETSAYHIANCHORLIST_LIST_ANCHORID].asString();
            }
            
            /* nickName */
            if (root[LIVEROOM_GETSAYHIANCHORLIST_LIST_ANCHORNICKNAME].isString()) {
                nickName = root[LIVEROOM_GETSAYHIANCHORLIST_LIST_ANCHORNICKNAME].asString();
            }
            
            /* coverImg */
            if (root[LIVEROOM_GETSAYHIANCHORLIST_LIST_ANCHORCOVER].isString()) {
                coverImg = root[LIVEROOM_GETSAYHIANCHORLIST_LIST_ANCHORCOVER].asString();
            }
            /* onlineStatus */
            if (root[LIVEROOM_GETSAYHIANCHORLIST_LIST_ONLINESTATUS].isNumeric()) {
                onlineStatus = GetIntToOnLineStatus(root[LIVEROOM_GETSAYHIANCHORLIST_LIST_ONLINESTATUS].asInt());
            }
            
            /* roomType */
            if( root[LIVEROOM_GETSAYHIANCHORLIST_LIST_ROOMTYPE].isNumeric() ) {
                roomType = GetIntToHttpRoomType(root[LIVEROOM_GETSAYHIANCHORLIST_LIST_ROOMTYPE].asInt());
            }

        }
        result = true;
        return result;
    }

    HttpSayHiAnchorItem() {
        anchorId = "";
        nickName = "";
        coverImg = "";
        onlineStatus = ONLINE_STATUS_LIVE;
        roomType = HTTPROOMTYPE_NOLIVEROOM;
    }
    
    virtual ~HttpSayHiAnchorItem() {
        
    }
    
    /**
     * sayHi主播列表
     * anchorId         主播ID
     * nickName         主播昵称
     * coverImg         主播封面
     * onlineStatus     在线状态（1：在线，0：不在线）
     * roomType         直播间类型
     */
    string anchorId;
    string nickName;
    string coverImg;
    OnLineStatus onlineStatus;
    HttpRoomType roomType;
};

typedef list<HttpSayHiAnchorItem> HttpSayHiAnchorList;

#endif /* HTTPSAYHIANCHORITEM_H_*/
