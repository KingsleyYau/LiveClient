/*
 * AnchorHangoutRoomItem.h
 *
 *  Created on: 2018-04-08
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef ANCHORHANGOUTROOMITEM_H_
#define ANCHORHANGOUTROOMITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "AnchorRecvGiftItem.h"
#include "OtherAnchorItem.h"

#define HANGOUTROOM_ROOMID_PARAM                "room_id"
#define HANGOUTROOM_ROOMTYPE_PARAM              "room_type"
#define HANGOUTROOM_MANID_PARAM                 "man_id"
#define HANGOUTROOM_MANNICKNAME_PARAM           "man_nickname"
#define HANGOUTROOM_MANPHOTURL_PARAM            "man_photourl"
#define HANGOUTROOM_MANLEVEL_PARAM              "man_level"
#define HANGOUTROOM_MANVIEOURL_PARAM            "man_video_url"
#define HANGOUTROOM_PUSHURL_PARAM               "push_url"
#define HANGOUTROOM_OTHERANCHORLIST_PARAM       "other_anchor_list"
#define HANGOUTROOM_BUYFOR_PARAM                "buyfor"


class AnchorHangoutRoomItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* roomId */
            if (root[HANGOUTROOM_ROOMID_PARAM].isString()) {
                roomId = root[HANGOUTROOM_ROOMID_PARAM].asString();
            }
            /* roomType */
            if (root[HANGOUTROOM_ROOMTYPE_PARAM].isNumeric()) {
                roomType = ZBGetRoomType(root[HANGOUTROOM_ROOMTYPE_PARAM].asInt());
            }
            /* manId */
            if (root[HANGOUTROOM_MANID_PARAM].isString()) {
                manId = root[HANGOUTROOM_MANID_PARAM].asString();
            }
            /* manNickName */
            if (root[HANGOUTROOM_MANNICKNAME_PARAM].isString()) {
                manNickName = root[HANGOUTROOM_MANNICKNAME_PARAM].asString();
            }
            /* manPhotoUrl */
            if (root[HANGOUTROOM_MANPHOTURL_PARAM].isString()) {
                manPhotoUrl = root[HANGOUTROOM_MANPHOTURL_PARAM].asString();
            }
            /* manLevel */
            if (root[HANGOUTROOM_MANLEVEL_PARAM].isInt()) {
                manLevel = root[HANGOUTROOM_MANLEVEL_PARAM].asInt();
            }
            /* manVideoUrl */
            if (root[HANGOUTROOM_MANVIEOURL_PARAM].isArray()) {
                int i = 0;
                for (i = 0; i < root[HANGOUTROOM_MANVIEOURL_PARAM].size(); i++) {
                    Json::Value element = root[HANGOUTROOM_MANVIEOURL_PARAM].get(i, Json::Value::null);
                    if (element.isString()) {
                        manVideoUrl.push_back(element.asString());
                    }
                }
            }
            /* pushUrl */
            if (root[HANGOUTROOM_PUSHURL_PARAM].isArray()) {
                int i = 0;
                for (i = 0; i < root[HANGOUTROOM_PUSHURL_PARAM].size(); i++) {
                    Json::Value element = root[HANGOUTROOM_PUSHURL_PARAM].get(i, Json::Value::null);
                    if (element.isString()) {
                        pushUrl.push_back(element.asString());
                    }
                }
            }
            
            /* otherAnchorList */
            if (root[HANGOUTROOM_OTHERANCHORLIST_PARAM].isArray()) {
                int i = 0;
                for (i = 0; i < root[HANGOUTROOM_OTHERANCHORLIST_PARAM].size(); i++) {
                    OtherAnchorItem item;
                    item.Parse(root[HANGOUTROOM_OTHERANCHORLIST_PARAM].get(i, Json::Value::null));
                    otherAnchorList.push_back(item);
                }
            }
            
            /* buyforList */
            if (root[HANGOUTROOM_BUYFOR_PARAM].isArray()) {
                int i = 0;
                for (i = 0; i < root[HANGOUTROOM_BUYFOR_PARAM].size(); i++) {
                    AnchorRecvGiftItem item;
                    item.Parse(root[HANGOUTROOM_BUYFOR_PARAM].get(i, Json::Value::null));
                    buyforList.push_back(item);
                }
            }
            result = true;
        }
        return result;
    }
    
    AnchorHangoutRoomItem() {
        roomId = "";
        roomType = ZBROOMTYPE_UNKNOW;
        manId = "";
        manNickName = "";
        manPhotoUrl = "";
        manLevel = 0;
    }
    
    virtual ~AnchorHangoutRoomItem() {
        
    }
    /**
     * 互动直播间
     * @roomId                  直播间ID
     * @roomType                直播间类型（参考《“直播间类型”对照表》）
     * @manId                   观众ID
     * @manNickName             观众昵称ID
     * @manPhotoUrl             观众头像url
     * @manLevel                观众等级
     * @manVideoUrl             观众视频流url（字符串数组）（访问视频URL的协议参考《“视频URL”协议描述》）
     * @pushUrl                 视频流url（字符串数组）（访问视频URL的协议参考《“视频URL”协议描述》）
     * @otherAnchorList         其它主播列表
     * @buyforList              已收礼物列表
     */
    string                      roomId;
    ZBRoomType                  roomType;
    string                      manId;
    string                      manNickName;
    string                      manPhotoUrl;
    int                         manLevel;
    list<string>                manVideoUrl;
    list<string>                pushUrl;
    OtherAnchorItemList         otherAnchorList;
    AnchorRecvGiftList          buyforList;
};



#endif /* ANCHORHANGOUTROOMITEM_H_*/
