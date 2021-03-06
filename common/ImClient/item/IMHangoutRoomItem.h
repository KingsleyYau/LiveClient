/*
 * IMHangoutRoomItem.h
 *
 *  Created on: 2018-04-13
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef IMHANGOUTROOMITEM_H_
#define IMHANGOUTROOMITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "IMOtherAnchorItem.h"
#include "IMRecvGiftItem.h"

#define HANGOUTROOM_ROOMID_PARAM                "room_id"
#define HANGOUTROOM_ROOMTYPE_PARAM              "room_type"
#define HANGOUTROOM_MANLEVEL_PARAM              "man_level"
#define HANGOUTROOM_MANPUSHPRICE_PARAM          "man_push_price"
#define HANGOUTROOM_CREDIT_PARAM                "credit"
#define HANGOUTROOM_PUSHURL_PARAM               "push_url"
#define HANGOUTROOM_LIVINGANCHORLIST_PARAM      "living_anchor_list"
#define HANGOUTROOM_BUYFOR_PARAM                "buyfor"


class IMHangoutRoomItem {
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
                roomType = GetRoomType(root[HANGOUTROOM_ROOMTYPE_PARAM].asInt());
            }
            /* manLevel */
            if (root[HANGOUTROOM_MANLEVEL_PARAM].isNumeric()) {
                manLevel = root[HANGOUTROOM_MANLEVEL_PARAM].asInt();
            }
            /* manPushPrice */
            if (root[HANGOUTROOM_MANPUSHPRICE_PARAM].isNumeric()) {
                manPushPrice = root[HANGOUTROOM_MANPUSHPRICE_PARAM].asDouble();
            }
            /* credit */
            if (root[HANGOUTROOM_CREDIT_PARAM].isNumeric()) {
                credit = root[HANGOUTROOM_CREDIT_PARAM].asDouble();
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
            if (root[HANGOUTROOM_LIVINGANCHORLIST_PARAM].isArray()) {
                int i = 0;
                for (i = 0; i < root[HANGOUTROOM_LIVINGANCHORLIST_PARAM].size(); i++) {
                    IMOtherAnchorItem item;
                    item.Parse(root[HANGOUTROOM_LIVINGANCHORLIST_PARAM].get(i, Json::Value::null));
                    otherAnchorList.push_back(item);
                }
            }
            
            /* buyforList */
            if (root[HANGOUTROOM_BUYFOR_PARAM].isArray()) {
                int i = 0;
                for (i = 0; i < root[HANGOUTROOM_BUYFOR_PARAM].size(); i++) {
                    IMRecvGiftItem item;
                    item.Parse(root[HANGOUTROOM_BUYFOR_PARAM].get(i, Json::Value::null));
                    buyforList.push_back(item);
                }
            }
            result = true;
        }
        return result;
    }
    
    IMHangoutRoomItem() {
        roomId = "";
        roomType = ROOMTYPE_UNKNOW;
        manLevel = 0;
        manPushPrice = 0.0;
        credit = 0.0;
    }
    
    virtual ~IMHangoutRoomItem() {
        
    }
    /**
     * 互动直播间
     * @roomId                  直播间ID
     * @roomType                直播间类型（参考《“直播间类型”对照表》）
     * @manLevel                观众等级
     * @manVideoUrl             观众视频流url（字符串数组）（访问视频URL的协议参考《“视频URL”协议描述》）
     * @credit                  当前信用点余额
     * @pushUrl                 视频流url（字符串数组）（访问视频URL的协议参考《“视频URL”协议描述》）
     * @otherAnchorList         其它主播列表
     * @buyforList              已收礼物列表
     */
    string                      roomId;
    RoomType                    roomType;
    int                         manLevel;
    double                      manPushPrice;
    double                      credit;
    list<string>                pushUrl;
    IMOtherAnchorItemList       otherAnchorList;
    RecvGiftList              buyforList;
};



#endif /* IMHANGOUTROOMITEM_H_*/
