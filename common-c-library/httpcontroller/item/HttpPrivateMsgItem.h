/*
 * HttpPrivateMsgItem.h
 *
 *  Created on: 2018-6-12
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPPRIVATEMSGITEM_H_
#define HTTPPRIVATEMSGITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"


class HttpPrivateMsgItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* msgId */
            if (root[GETPRIVATEMESSAGEHISTORYBYID_LIST_ID].isNumeric()) {
                msgId = root[GETPRIVATEMESSAGEHISTORYBYID_LIST_ID].asInt();
            }
            /* fromId */
            if (root[GETPRIVATEMESSAGEHISTORYBYID_LIST_FROMID].isString()) {
                fromId = root[GETPRIVATEMESSAGEHISTORYBYID_LIST_FROMID].asString();
            }
            /* toId */
            if (root[GETPRIVATEMESSAGEHISTORYBYID_LIST_TOID].isString()) {
                toId = root[GETPRIVATEMESSAGEHISTORYBYID_LIST_TOID].asString();
            }
            /* nickName */
            if (root[GETPRIVATEMESSAGEHISTORYBYID_LIST_NICKNAME].isString()) {
                nickName = root[GETPRIVATEMESSAGEHISTORYBYID_LIST_NICKNAME].asString();
            }
            
            /* avatarImg */
            if (root[GETPRIVATEMESSAGEHISTORYBYID_LIST_AVATARIMG].isString()) {
                avatarImg = root[GETPRIVATEMESSAGEHISTORYBYID_LIST_AVATARIMG].asString();
            }
            
            /* content */
            if (root[GETPRIVATEMESSAGEHISTORYBYID_LIST_CONTENT].isString()) {
                content = root[GETPRIVATEMESSAGEHISTORYBYID_LIST_CONTENT].asString();
            }
            /* isRead */
            if (root[GETPRIVATEMESSAGEHISTORYBYID_LIST_ISREAD].isNumeric()) {
                isRead = root[GETPRIVATEMESSAGEHISTORYBYID_LIST_ISREAD].asInt() == 0 ? false : true;
            }
            /* addTime */
            if (root[GETPRIVATEMESSAGEHISTORYBYID_LIST_ADDTIME].isNumeric()) {
                addTime = root[GETPRIVATEMESSAGEHISTORYBYID_LIST_ADDTIME].asInt();
            }
            /* msgType */
            if (root[GETPRIVATEMESSAGEHISTORYBYID_LIST_MSGTYPE].isNumeric()) {
                msgType = GetIntToPrivateMsgType(root[GETPRIVATEMESSAGEHISTORYBYID_LIST_MSGTYPE].asInt());
            }

        }
        result = true;
        return result;
    }
    
    //// 比较函数(将http的私信消息列表按msgid从小到大排列)
   static bool HttpSort(const HttpPrivateMsgItem& item1, const HttpPrivateMsgItem& item2) {
        // true在前，false在后
        bool result = false;
        
        // 更是最后时间排序
        result = item1.msgId <= item2.msgId;
        
        return result;
    }
    
    HttpPrivateMsgItem() {
        msgId = 0;
        fromId = "";
        toId = "";
        nickName = "";
        avatarImg = "";
        content = "";
        isRead = false;
        addTime = 0;
        msgType = PRIVATEMSGTYPE_UNKNOW;
    }
    
    virtual ~HttpPrivateMsgItem() {
        
    }
    
    /**
     * 私信消息
     * msgId                消息ID
     * fromId               发送者用户ID
     * toId                 发送者用户ID
     * nickName             对方昵称
     * avatarImg		    对方头像URL
     * content              消息内容
     * isRead               是否已读（0：否，1：是）
     * addTime              发送时间（1970年起的秒数）
     * msgType              私信消息类型（PRIVATEMSGTYPE_TEXT：私信文本，PRIVATEMSGTYPE_Dynamic：动态）
     */
    int         msgId;
    string      fromId;
    string      toId;
    string      nickName;
    string      avatarImg;
    string      content;
    bool        isRead;
    long        addTime;
    PrivateMsgType msgType;
};

typedef list<HttpPrivateMsgItem> HttpPrivateMsgList;

#endif /* HTTPPRIVATEMSGITEM_H_*/
