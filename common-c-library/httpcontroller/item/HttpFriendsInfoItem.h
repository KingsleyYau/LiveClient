/*
 * HttpFriendsInfoItem.h
 *
 *  Created on: 2018-4-12
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPFRIENDSINFOITEM_H_
#define HTTPFRIENDSINFOITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../HttpLoginProtocol.h"

class HttpFriendsInfoItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* anchorId */
            if (root[LIVEROOM_GETRECENTCONTACEANCHOR_FRIENDSINFO_ANCHORID].isString()) {
                anchorId = root[LIVEROOM_GETRECENTCONTACEANCHOR_FRIENDSINFO_ANCHORID].asString();
            }
            
            /* nickName */
            if (root[LIVEROOM_GETRECENTCONTACEANCHOR_FRIENDSINFO_NICKNAME].isString()) {
                nickName = root[LIVEROOM_GETRECENTCONTACEANCHOR_FRIENDSINFO_NICKNAME].asString();
            }
            
            /* anchorImg */
            if (root[LIVEROOM_GETRECENTCONTACEANCHOR_FRIENDSINFO_AVATARIMG].isString()) {
                anchorImg = root[LIVEROOM_GETRECENTCONTACEANCHOR_FRIENDSINFO_AVATARIMG].asString();
            }
            
            /* coverImg */
            if (root[LIVEROOM_GETRECENTCONTACEANCHOR_FRIENDSINFO_COVERIMG].isString()) {
                coverImg = root[LIVEROOM_GETRECENTCONTACEANCHOR_FRIENDSINFO_COVERIMG].asString();
            }

        }
        result = true;
        return result;
    }

    HttpFriendsInfoItem() {
        anchorId = "";
        nickName = "";
        anchorImg = "";
        coverImg = "";
    }
    
    virtual ~HttpFriendsInfoItem() {
        
    }
    
    /**
     * 好友信息
     * anchorId         主播ID
     * nickName         主播昵称
     * anchorImg        主播头像url
     * coverImg         直播间封面图ur
     */
    string anchorId;
    string nickName;
    string anchorImg;
    string coverImg;
};

typedef list<HttpFriendsInfoItem> HttpFriendsInfoList;

#endif /* HTTPFRIENDSINFOITEM_H_*/
