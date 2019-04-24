/*
 * HttpHangoutListItem.h
 *
 *  Created on: 2018-4-12
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPHANGOUTLISTITEM_H_
#define HTTPHANGOUTLISTITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "HttpFriendsInfoItem.h"
#include "../HttpRequestEnum.h"

class HttpHangoutListItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* anchorId */
            if (root[LIVEROOM_GETRECENTCONTACEANCHOR_ANCHORID].isString()) {
                anchorId = root[LIVEROOM_GETRECENTCONTACEANCHOR_ANCHORID].asString();
            }
            
            /* nickName */
            if (root[LIVEROOM_GETRECENTCONTACEANCHOR_NICKNAME].isString()) {
                nickName = root[LIVEROOM_GETRECENTCONTACEANCHOR_NICKNAME].asString();
            }
            
            /* avatarImg */
            if (root[LIVEROOM_GETRECENTCONTACEANCHOR_AVATARIMG].isString()) {
                avatarImg = root[LIVEROOM_GETRECENTCONTACEANCHOR_AVATARIMG].asString();
            }
            
            /* coverImg */
            if (root[LIVEROOM_GETRECENTCONTACEANCHOR_COVERIMG].isString()) {
                coverImg = root[LIVEROOM_GETRECENTCONTACEANCHOR_COVERIMG].asString();
            }
            
            /* onlineStatus 注意（hangout的在线状态：1为离线 2为在线） */
            if (root[LIVEROOM_GETRECENTCONTACEANCHOR_ONLINESTATUS].isNumeric()) {
                onlineStatus = GetIntToOnLineStatus((root[LIVEROOM_GETRECENTCONTACEANCHOR_ONLINESTATUS].asInt() - 1));
            }
            
            /* friendsNum */
            if (root[LIVEROOM_GETRECENTCONTACEANCHOR_FRIENDSNUM].isNumeric()) {
                friendsNum = root[LIVEROOM_GETRECENTCONTACEANCHOR_FRIENDSNUM].asInt();
            }
            
            /* invitationMsg */
            if (root[LIVEROOM_GETRECENTCONTACEANCHOR_INVITATION_MSG].isString()) {
                invitationMsg = root[LIVEROOM_GETRECENTCONTACEANCHOR_INVITATION_MSG].asString();
            }
            
            /* friendsInfoList */
            if( root[LIVEROOM_GETRECENTCONTACEANCHOR_FRIENDSINFO].isArray()) {
                for (int i = 0; i < root[LIVEROOM_GETRECENTCONTACEANCHOR_FRIENDSINFO].size(); i++) {
                    Json::Value element = root[LIVEROOM_GETRECENTCONTACEANCHOR_FRIENDSINFO].get(i, Json::Value::null);
                    HttpFriendsInfoItem item;
                    if (item.Parse(element)) {
                        friendsInfoList.push_back(item);
                    }
                }
            }

        }
        result = true;
        return result;
    }

    HttpHangoutListItem() {
        anchorId = "";
        nickName = "";
        avatarImg = "";
        coverImg = "";
        onlineStatus = ONLINE_STATUS_UNKNOWN;
        friendsNum = 0;
        invitationMsg = "";
    }
    
    virtual ~HttpHangoutListItem() {
        
    }
    
    /**
     * Hang-out列表
     * anchorId         主播ID
     * nickName         主播昵称
     * avatarImg        主播头像url
     * coverImg         直播间封面图url
     * onlineStatus     主播在线状态（ONLINE_STATUS_OFFLINE：离线，ONLINE_STATUS_LIVE：在线）注意（hangout的在线状态：1为离线 2为在线）
     * friendsNum       好友数量
     * invitationMsg    邀请语
     * friendsInfoList  好友信息列表
     */
    string anchorId;
    string nickName;
    string avatarImg;
    string coverImg;
    OnLineStatus onlineStatus;
    int friendsNum;
    string invitationMsg;
    HttpFriendsInfoList friendsInfoList;
};

typedef list<HttpHangoutListItem> HttpHangoutList;

#endif /* HTTPHANGOUTLISTITEM_H_*/
