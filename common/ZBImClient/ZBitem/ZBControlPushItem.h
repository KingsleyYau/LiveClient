/*
 * ZBControlPushItem.h
 *
 *  Created on: 2018-03-07
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef ZBCONTROLPUSHITEM_H_
#define ZBCONTROLPUSHITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#define ZBCMPN_ROOMID_PARAM          "roomid"
#define ZBCMPN_USERID_PARAM          "userid"
#define ZBCMPN_NICKNAME_PARAM        "nickname"
#define ZBCMPN_AVATARIMG_PARAM       "avatar_img"
#define ZBCMPN_CONTROL_PARAM         "control"
#define ZBCMPN_MANVIDEOURL_PARAM     "man_video_url"
#define ZBCMPN_HANGOUT_ROOMID_PARAM          "room_id"
#define ZBCMPN_HANGOUT_USERID_PARAM          "user_id"

class ZBControlPushItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* roomId */
            if (root[ZBCMPN_ROOMID_PARAM].isString()) {
                roomId = root[ZBCMPN_ROOMID_PARAM].asString();
            }
            /* userId */
            if (root[ZBCMPN_USERID_PARAM].isString()) {
                userId = root[ZBCMPN_USERID_PARAM].asString();
            }
            /* nickName */
            if (root[ZBCMPN_NICKNAME_PARAM].isString()) {
                nickName = root[ZBCMPN_NICKNAME_PARAM].asString();
            }
            /* avatarImg */
            if (root[ZBCMPN_AVATARIMG_PARAM].isString()) {
                avatarImg = root[ZBCMPN_AVATARIMG_PARAM].asString();
            }
            /* control */
            if (root[ZBCMPN_CONTROL_PARAM].isIntegral()) {
                control = ZBGetIMControlType(root[ZBCMPN_CONTROL_PARAM].asInt());
            }
            /* manVideoUrl */
            if (root[ZBCMPN_MANVIDEOURL_PARAM].isArray()) {
                
                for (int i = 0; i < root[ZBCMPN_MANVIDEOURL_PARAM].size(); i++) {
                    Json::Value element = root[ZBCMPN_MANVIDEOURL_PARAM].get(i, Json::Value::null);
                    if (element.isString()) {
                        manVideoUrl.push_back(element.asString());
                    }
                }
            }
            /* hangoutRoomId */
            if (root[ZBCMPN_HANGOUT_ROOMID_PARAM].isString()) {
                hangoutRoomId = root[ZBCMPN_HANGOUT_ROOMID_PARAM].asString();
            }
            /* hangoutUserId */
            if (root[ZBCMPN_HANGOUT_USERID_PARAM].isString()) {
                hangoutUserId = root[ZBCMPN_HANGOUT_USERID_PARAM].asString();
            }
            
        }
        result = true;
        return result;
    }
    
    ZBControlPushItem() {
        roomId = "";
        userId = "";
        nickName = "";
        avatarImg = "";
        control = ZBIMCONTROLTYPE_UNKNOW;
        hangoutRoomId = "";
        hangoutUserId = "";
    }
    
    virtual ~ZBControlPushItem() {
        
    }
    /**
     * 直播间开播通知结构体
     * roomId                 直播间ID
     * anchorId               观众ID
     * nickName               观众昵称
     * avatarImg              观众头像url
     * control                开关标志（1：启动，2：关闭）
     * manVideoUrl            观众视频流url
     */
    string                roomId;
    string                userId;
    string                nickName;
    string                avatarImg;
    ZBIMControlType       control;
    list<string>          manVideoUrl;
    string                hangoutRoomId;
    string                hangoutUserId;
    
};

#endif /* ZBCONTROLPUSHITEM_H_*/
