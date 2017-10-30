/*
 * StartOverRoomItem.h
 *
 *  Created on: 2017-09-12
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef STARTOVERROOMITEM_H_
#define STARTOVERROOMITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#define SRARTROOMID_PARAM          "room_id"
#define ANCHORID_PARAM             "anchor_id"
#define SRARTNICKNAME_PARAM        "nick_name"
#define AVATARIMG_PARAM            "avatar_img"
#define LEFTSECONDS_PARAM          "left_seconds"
#define PLAYURL_PARAM              "play_url"


class StartOverRoomItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* roomId */
            if (root[SRARTROOMID_PARAM].isString()) {
                roomId = root[SRARTROOMID_PARAM].asString();
            }
            /* anchorId */
            if (root[ANCHORID_PARAM].isString()) {
                anchorId = root[ANCHORID_PARAM].asString();
            }
            /* nickName */
            if (root[SRARTNICKNAME_PARAM].isString()) {
                nickName = root[SRARTNICKNAME_PARAM].asString();
            }
            /* avatarImg */
            if (root[AVATARIMG_PARAM].isString()) {
                avatarImg = root[AVATARIMG_PARAM].asString();
            }
            /* leftSeconds */
            if (root[LEFTSECONDS_PARAM].isIntegral()) {
                leftSeconds = root[LEFTSECONDS_PARAM].asInt();
            }
            /* playUrl */
            if (root[PLAYURL_PARAM].isArray()) {
                
                for (int i = 0; i < root[PLAYURL_PARAM].size(); i++) {
                    Json::Value element = root[PLAYURL_PARAM].get(i, Json::Value::null);
                    if (element.isString()) {
                        playUrl.push_back(element.asString());
                    }
                }
            }
            
        }
        result = true;
        return result;
    }
    
    StartOverRoomItem() {
        roomId = "";
        anchorId = "";
        nickName = "";
        avatarImg = "";
        leftSeconds = 0;
    }
    
    virtual ~StartOverRoomItem() {
        
    }
    /**
     * 直播间开播通知结构体
     * roomId                 直播间ID
     * anchorId               主播ID
     * nickName               主播昵称
     * avatarImg              主播头像url
     * leftSeconds            开播前的倒数秒数（可无，无或0表示立即开播）
     * playUrl                视频播放url
     */
    string                roomId;
    string                anchorId;
    string                nickName;
    string                avatarImg;
    int                   leftSeconds;
    list<string>          playUrl;
    
};

#endif /* STARTOVERROOMITEM_H_*/
