/*
 * IMAnchorRecvHangoutChatItem.h
 *
 *  Created on: 2018-5-12
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef IMANCHORRECVHANGOUTCHATITEM_H_
#define IMANCHORRECVHANGOUTCHATITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#define IMANCHORRECVHANGOUTCHATITEM_ROOMID                  "roomid"
#define IMANCHORRECVHANGOUTCHATITEM_LEVEL                   "level"
#define IMANCHORRECVHANGOUTCHATITEM_FROMID                  "fromid"
#define IMANCHORRECVHANGOUTCHATITEM_NICKNAME                "nickname"
#define IMANCHORRECVHANGOUTCHATITEM_MSG                     "msg"
#define IMANCHORRECVHANGOUTCHATITEM_HONORURL                "honor_url"
#define IMANCHORRECVHANGOUTCHATITEM_AT                      "at"

class IMAnchorRecvHangoutChatItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* roomId */
            if (root[IMANCHORRECVHANGOUTCHATITEM_ROOMID].isString()) {
                roomId = root[IMANCHORRECVHANGOUTCHATITEM_ROOMID].asString();
            }
            /* level */
            if (root[IMANCHORRECVHANGOUTCHATITEM_LEVEL].isNumeric()) {
                level = root[IMANCHORRECVHANGOUTCHATITEM_LEVEL].asInt();
            }
            /* fromId */
            if (root[IMANCHORRECVHANGOUTCHATITEM_FROMID].isString()) {
                fromId = root[IMANCHORRECVHANGOUTCHATITEM_FROMID].asString();
            }
            /* nickName */
            if (root[IMANCHORRECVHANGOUTCHATITEM_NICKNAME].isString()) {
                nickName = root[IMANCHORRECVHANGOUTCHATITEM_NICKNAME].asString();
            }
            /* msg */
            if (root[IMANCHORRECVHANGOUTCHATITEM_MSG].isString()) {
                msg = root[IMANCHORRECVHANGOUTCHATITEM_MSG].asString();
            }
            /* honorUrl */
            if (root[IMANCHORRECVHANGOUTCHATITEM_HONORURL].isString()) {
                honorUrl = root[IMANCHORRECVHANGOUTCHATITEM_HONORURL].asString();
            }
            /* at */
            if (root[IMANCHORRECVHANGOUTCHATITEM_AT].isArray()) {
                for (int i = 0; i <= root[IMANCHORRECVHANGOUTCHATITEM_AT].size(); i++) {
                    Json::Value element = root[IMANCHORRECVHANGOUTCHATITEM_AT].get(i, Json::Value::null);
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

    IMAnchorRecvHangoutChatItem() {
        roomId = "";
        level = 0;
        fromId = "";
        nickName = "";
        msg = "";
        honorUrl = "";

    }
    
    virtual ~IMAnchorRecvHangoutChatItem() {
        
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

#endif /* IMANCHORRECVHANGOUTCHATITEM_H_*/
