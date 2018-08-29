/*
 * IMPrivateMessageItem.h
 *
 *  Created on: 2018-6-14
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef IMPRIVATEMESSAGEITEM_H_
#define IMPRIVATEMESSAGEITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#define IMPRIVATEMESSAGEITEM_FROMID                     "from_id"
#define IMPRIVATEMESSAGEITEM_TOID                       "to_id"
#define IMPRIVATEMESSAGEITEM_NICKNAME                   "nick_name"
#define IMPRIVATEMESSAGEITEM_AVATARIMG                  "avatar_img"
#define IMPRIVATEMESSAGEITEM_MSG                        "msg"
#define IMPRIVATEMESSAGEITEM_MSGID                      "msg_id"
#define IMPRIVATEMESSAGEITEM_SENDTIEM                   "send_time"
#define IMPRIVATEMESSAGEITEM_MSGTYPE                    "msg_type"

class IMPrivateMessageItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* fromId */
            if (root[IMPRIVATEMESSAGEITEM_FROMID].isString()) {
                fromId = root[IMPRIVATEMESSAGEITEM_FROMID].asString();
            }
            /* toId */
            if (root[IMPRIVATEMESSAGEITEM_TOID].isString()) {
                toId = root[IMPRIVATEMESSAGEITEM_TOID].asString();
            }
            /* nickName */
            if (root[IMPRIVATEMESSAGEITEM_NICKNAME].isString()) {
                nickName = root[IMPRIVATEMESSAGEITEM_NICKNAME].asString();
            }
            /* avatarImg */
            if (root[IMPRIVATEMESSAGEITEM_AVATARIMG].isString()) {
                avatarImg = root[IMPRIVATEMESSAGEITEM_AVATARIMG].asString();
            }
            /* msg */
            if (root[IMPRIVATEMESSAGEITEM_MSG].isString()) {
                msg = root[IMPRIVATEMESSAGEITEM_MSG].asString();
            }
            /* msgId */
            if (root[IMPRIVATEMESSAGEITEM_MSGID].isNumeric()) {
                msgId = root[IMPRIVATEMESSAGEITEM_MSGID].asInt();
            }
            /* sendTime */
            if (root[IMPRIVATEMESSAGEITEM_SENDTIEM].isNumeric()) {
                sendTime = root[IMPRIVATEMESSAGEITEM_SENDTIEM].asInt();
            }
            /* msgType */
            if (root[IMPRIVATEMESSAGEITEM_MSGTYPE].isNumeric()) {
                msgType = GetIntToIMPrivateMsgType(root[IMPRIVATEMESSAGEITEM_MSGTYPE].asInt());
            }
        }
        result = true;
        return result;
    }

    IMPrivateMessageItem() {
        fromId = "";
        toId = "";
        nickName = "";
        avatarImg = "";
        msg = "";
        msgId = 0;
        sendTime = 0;
        msgType = IMPRIVATEMSGTYPE_UNKNOW;
    }
    
    virtual ~IMPrivateMessageItem() {
        
    }
    
    /**
     * 接收私信文本消息
     * fromId        发送者ID
     * toId          接收者ID
     * nickName      发送者昵称
     * avatarImg     发送者头像
     * msg		     消息内容
     * msgId         消息ID
     * sendTime      发送时间（1970年起的秒数）
     * msgType        消息类型（IMPRIVATEMSGTYPE_TEXT：文本消息<包括普通表情>，IMPRIVATEMSGTYPE_Dynamic：动态）
     */
    string   fromId;
    string   toId;
    string   nickName;
    string   avatarImg;
    string   msg;
    int      msgId;
    long     sendTime;
    IMPrivateMsgType msgType;

};

#endif /* IMPRIVATEMESSAGEITEM_H_*/
