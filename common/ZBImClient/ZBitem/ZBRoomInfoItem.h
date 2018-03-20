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
#define ZBRII_ANCHORID_PARAM          "anchor_id"
#define ZBRII_ROOMID_PARAM            "room_id"
#define ZBRII_ROOMTYPE_PARAM          "room_type"
#define ZBRII_PUSHURL_PARAM           "push_url"
#define ZBRII_LEFTSECONDS_PARAM       "left_seconds"
#define ZBRII_MAXFANSINUM_PARAM       "max_fansi_num"
#define ZBRII_PULLURL_PARAM           "pull_url"

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

        }

        result = true;

        return result;
    }

    ZBRoomInfoItem() {
        anchorId = "";
        roomId = "";
        roomType = ZBROOMTYPE_UNKNOW;
        leftSeconds = 0;
        maxFansiNum = 0;
    }
    
    virtual ~ZBRoomInfoItem() {
        
    }
    
    /**
     * 直播间结构体
     * anchorId                 主播ID
     * roomId					直播间ID
     * roomType                 直播间类型
     * PushUrl                  视频流url（字符串数组）
     * leftSeconds              开播前的倒数秒数（可无，无或0表示立即开播）
     * maxFansiNum		        最大人数限制
     * PullUrl                  男士视频流url
     */
    string          anchorId;
    string          roomId;
    ZBRoomType      roomType;
    list<string>    pushUrl;
    int             leftSeconds;
    int             maxFansiNum;
    list<string>    pullUrl;
};


#endif /* ZBROOMINFOITEM_H_*/
