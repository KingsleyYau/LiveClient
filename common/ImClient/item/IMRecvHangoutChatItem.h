/*
 * IMRecvHangoutChatItem.h
 *
 *  Created on: 2018-5-12
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef IMRECVHANGOUTCHATITEM_H_
#define IMRECVHANGOUTCHATITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#define IMRECVHANGOUTCHATITEM_ROOMID                  "roomid"
#define IMRECVHANGOUTCHATITEM_LEVEL                   "level"
#define IMRECVHANGOUTCHATITEM_FROMID                  "fromid"
#define IMRECVHANGOUTCHATITEM_NICKNAME                "nickname"
#define IMRECVHANGOUTCHATITEM_MSG                     "msg"
#define IMRECVHANGOUTCHATITEM_HONORURL                "honor_url"
#define IMRECVHANGOUTCHATITEM_AT                      "at"

class IMRecvHangoutChatItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* roomId */
            if (root[IMRECVHANGOUTCHATITEM_ROOMID].isString()) {
                roomId = root[IMRECVHANGOUTCHATITEM_ROOMID].asString();
            }
            /* level */
            if (root[IMRECVHANGOUTCHATITEM_LEVEL].isNumeric()) {
                level = root[IMRECVHANGOUTCHATITEM_LEVEL].asInt();
            }
            /* fromId */
            if (root[IMRECVHANGOUTCHATITEM_FROMID].isString()) {
                fromId = root[IMRECVHANGOUTCHATITEM_FROMID].asString();
            }
            /* nickName */
            if (root[IMRECVHANGOUTCHATITEM_NICKNAME].isString()) {
                nickName = root[IMRECVHANGOUTCHATITEM_NICKNAME].asString();
            }
            /* msg */
            if (root[IMRECVHANGOUTCHATITEM_MSG].isString()) {
                msg = root[IMRECVHANGOUTCHATITEM_MSG].asString();
            }
            /* honorUrl */
            if (root[IMRECVHANGOUTCHATITEM_HONORURL].isString()) {
                honorUrl = root[IMRECVHANGOUTCHATITEM_HONORURL].asString();
            }
            /* at */
            if (root[IMRECVHANGOUTCHATITEM_AT].isArray()) {
                for (int i = 0; i <= root[IMRECVHANGOUTCHATITEM_AT].size(); i++) {
                    Json::Value element = root[IMRECVHANGOUTCHATITEM_AT].get(i, Json::Value::null);
                    if (element.isString()) {
                        string strAt = element.asString();
                        at.push_back(strAt);
                    }
                }
            }
        }
        result = true;
        return result;
    }

    IMRecvHangoutChatItem() {
        roomId = "";
        level = 0;
        fromId = "";
        nickName = "";
        msg = "";
        honorUrl = "";

    }
    
    virtual ~IMRecvHangoutChatItem() {
        
    }
    
    /**
     * 接收直播间文本消息
     * roomId           直播间ID
     * level            发送方级别
     * fromId           发送方的用户ID
     * nickName         发送方的昵称
     * msg		        文本消息内容
     * honorUrl         勋章图片url
     * at               用户ID，用于指定接收者（字符串数组）（可无，无则表示发送给直播间所有人）
     */
    string   roomId;
    int   level;
    string   fromId;
    string   nickName;
    string   msg;
    string   honorUrl;
    list<string>     at;

};

#endif /* IMRECVHANGOUTCHATITEM_H_*/
