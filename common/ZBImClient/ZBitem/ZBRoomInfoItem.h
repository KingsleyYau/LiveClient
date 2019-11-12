/*
 * ZBRoomInfoItem.h
 *
 *  Created on: 2017-9-05
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef ZBROOMINFOITEM_H_
#define ZBROOMINFOITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "ZBRebateInfoItem.h"
#include "ZBAuthorityItem.h"
#include "ZBCurrentPushInfoItem.h"
#define ZBRII_ANCHORID_PARAM          "anchor_id"
#define ZBRII_ROOMID_PARAM            "room_id"
#define ZBRII_ROOMTYPE_PARAM          "room_type"
#define ZBRII_LIVESHOWTYPE_PARAM      "live_show_type"
#define ZBRII_PUSHURL_PARAM           "push_url"
#define ZBRII_LEFTSECONDS_PARAM       "left_seconds"
#define ZBRII_STATUS_PARAM            "status"
#define ZBRII_MAXFANSINUM_PARAM       "max_fansi_num"
#define ZBRII_PULLURL_PARAM           "pull_url"
#define ZBRII_PRIV_PARAM              "priv"
#define ZBRII_CURRENT_PUSH_PARAM      "current_push"

class ZBRoomInfoItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            if (root[ZBRII_ANCHORID_PARAM].isString()) {
                anchorId = root[ZBRII_ANCHORID_PARAM].asString();
            }
            if (root[ZBRII_ROOMID_PARAM].isString()) {
                roomId = root[ZBRII_ROOMID_PARAM].asString();
            }
            if (root[ZBRII_ROOMTYPE_PARAM].isInt()) {
                int type = root[ZBRII_ROOMTYPE_PARAM].asInt();
                roomType = ZBGetRoomType(type);
            }
            if (root[ZBRII_LIVESHOWTYPE_PARAM].isInt()) {
                int type = root[ZBRII_LIVESHOWTYPE_PARAM].asInt();
                liveShowType = GetIMAnchorPublicRoomType(type);
            }
            
            if (root[ZBRII_PUSHURL_PARAM].isArray()) {
                
                for (int i = 0; i < root[ZBRII_PUSHURL_PARAM].size(); i++) {
                    Json::Value element = root[ZBRII_PUSHURL_PARAM].get(i, Json::Value::null);
                    if (element.isString()) {
                        pushUrl.push_back(element.asString());
                    }
                }
                
            }
            
            if (root[ZBRII_LEFTSECONDS_PARAM].isInt()) {
                leftSeconds = root[ZBRII_LEFTSECONDS_PARAM].asInt();
            }
            
            if (root[ZBRII_STATUS_PARAM].isInt()) {
                status = ZBGetLiveStatus(root[ZBRII_STATUS_PARAM].asInt());
            }
            
            if (root[ZBRII_MAXFANSINUM_PARAM].isIntegral()) {
                maxFansiNum = root[ZBRII_MAXFANSINUM_PARAM].asInt();
            }
            
            if (root[ZBRII_PULLURL_PARAM].isArray()) {
                
                for (int i = 0; i < root[ZBRII_PULLURL_PARAM].size(); i++) {
                    Json::Value element = root[ZBRII_PULLURL_PARAM].get(i, Json::Value::null);
                    if (element.isString()) {
                        pullUrl.push_back(element.asString());
                    }
                }
                
            }
            
            if (root[ZBRII_PRIV_PARAM].isObject()) {
                priv.Parse(root[ZBRII_PRIV_PARAM]);
            }
            
            if (root[ZBRII_CURRENT_PUSH_PARAM].isObject()) {
                currentPush.Parse(root[ZBRII_CURRENT_PUSH_PARAM]);
            }

        }

        result = true;

        return result;
    }

    ZBRoomInfoItem() {
        anchorId = "";
        roomId = "";
        roomType = ZBROOMTYPE_UNKNOW;
        liveShowType = IMANCHORPUBLICROOMTYPE_UNKNOW;
        leftSeconds = 0;
        maxFansiNum = 0;
        status = ZBLIVESTATUS_UNKNOW;
    }
    
    virtual ~ZBRoomInfoItem() {
        
    }
    
    /**
     * 直播间结构体
     * anchorId                 主播ID
     * roomId					直播间ID
     * roomType                 直播间类型
     * liveShowType             公开直播间类型（IMANCHORPUBLICROOMTYPE_COMMON：普通公开，IMANCHORPUBLICROOMTYPE_PROGRAM：节目）
     * PushUrl                  视频流url（字符串数组）
     * leftSeconds              开播前的倒数秒数（可无，无或0表示立即开播）
     * status                   直播间状态（整型）（ZBLIVESTATUS_INIT：初始，ZBLIVESTATUSE_RECIPROCALSTART：开始倒数中，ZBLIVESTATUS_ONLINE：在线，ZBLIVESTATUS_ARREARAGE：欠费中，ZBLIVESTATUS_RECIPROCALEND：结束倒数中，ZBLIVESTATUS_CLOSE：关闭）
     * maxFansiNum		        最大人数限制
     * PullUrl                  男士视频流url
     * priv                     权限
     * currentPush              当前推流状态
     */
    string          anchorId;
    string          roomId;
    ZBRoomType      roomType;
    IMAnchorPublicRoomType liveShowType;
    list<string>    pushUrl;
    int             leftSeconds;
    ZBLiveStatus    status;
    int             maxFansiNum;
    list<string>    pullUrl;
    ZBAuthorityItem priv;
    ZBCurrentPushInfoItem currentPush;
};


#endif /* ZBROOMINFOITEM_H_*/
