/*
 * HttpHangoutStatusItem.h
 *
 *  Created on: 2018-4-12
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPHANGOUTSTATUSITEM_H_
#define HTTPHANGOUTSTATUSITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "HttpFriendsInfoItem.h"

class HttpHangoutStatusItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* liveRoomId */
            if (root[LIVEROOM_GETHANGOUTATUS_LIVE_ROOM_ID].isString()) {
                liveRoomId = root[LIVEROOM_GETHANGOUTATUS_LIVE_ROOM_ID].asString();
            }
            
            /* anchorList */
            if( root[LIVEROOM_GETHANGOUTATUS_LIVEROOMANCHOR].isArray()) {
                for (int i = 0; i < root[LIVEROOM_GETHANGOUTATUS_LIVEROOMANCHOR].size(); i++) {
                    Json::Value element = root[LIVEROOM_GETHANGOUTATUS_LIVEROOMANCHOR].get(i, Json::Value::null);
                    HttpFriendsInfoItem item;
                    if (item.Parse(element)) {
                        anchorList.push_back(item);
                    }
                }
            }

        }
        result = true;
        return result;
    }

    HttpHangoutStatusItem() {
        liveRoomId = "";
    }
    
    virtual ~HttpHangoutStatusItem() {
        
    }
    
    /**
     * Hangout直播信息
     * liveRoomId      直播间
     * anchorList      主播数组
     */
    string liveRoomId;
    HttpFriendsInfoList anchorList;
};

typedef list<HttpHangoutStatusItem> HttpHangoutStatusList;

#endif /* HTTPHANGOUTSTATUSITEM_H_*/
