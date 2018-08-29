/*
 * HttpPrivateMsgContactItem.h
 *
 *  Created on: 2018-6-12
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPPRIVATEMSGCONTACTITEM_H_
#define HTTPPRIVATEMSGCONTACTITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"


class HttpPrivateMsgContactItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* userId */
            if (root[GETPRIVATEMSGFRIENDLIST_LIST_USERID].isString()) {
                userId = root[GETPRIVATEMSGFRIENDLIST_LIST_USERID].asString();
            }
            /* nickName */
            if (root[GETPRIVATEMSGFRIENDLIST_LIST_NICKNAME].isString()) {
                nickName = root[GETPRIVATEMSGFRIENDLIST_LIST_NICKNAME].asString();
            }
            /* avatarImg */
            if (root[GETPRIVATEMSGFRIENDLIST_LIST_AVATARIMG].isString()) {
                avatarImg = root[GETPRIVATEMSGFRIENDLIST_LIST_AVATARIMG].asString();
            }
            /* onlineStatus */
            if (root[GETPRIVATEMSGFRIENDLIST_LIST_ONLINESTATUS].isNumeric()) {
                onlineStatus = GetIntToOnLineStatus(root[GETPRIVATEMSGFRIENDLIST_LIST_ONLINESTATUS].asInt());
            }
            /* lastMsg */
            if (root[GETPRIVATEMSGFRIENDLIST_LIST_LASTMSG].isString()) {
                lastMsg = root[GETPRIVATEMSGFRIENDLIST_LIST_LASTMSG].asString();
            }
            
            /* updateTime */
            if (root[GETPRIVATEMSGFRIENDLIST_LIST_UPDATETIME].isNumeric()) {
                updateTime = root[GETPRIVATEMSGFRIENDLIST_LIST_UPDATETIME].asInt();
            }
            
            /* unreadNum */
            if (root[GETPRIVATEMSGFRIENDLIST_LIST_UNREADNUM].isNumeric()) {
                unreadNum = root[GETPRIVATEMSGFRIENDLIST_LIST_UNREADNUM].asInt();
            }
            
            /* anchorType */
            if (root[GETPRIVATEMSGFRIENDLIST_LIST_ANCHORTYPE].isNumeric()) {
                anchorType = root[GETPRIVATEMSGFRIENDLIST_LIST_ANCHORTYPE].asInt() == 0 ? false : true;
            }

        }
        result = true;
        return result;
    }

    HttpPrivateMsgContactItem() {
        userId = "";
        nickName = "";
        avatarImg = "";
        onlineStatus = ONLINE_STATUS_UNKNOWN;
        lastMsg = "";
        updateTime = 0;
        unreadNum = 0;
        anchorType = false;

    }
    
    virtual ~HttpPrivateMsgContactItem() {
        
    }
    
    /**
     * 私信联系人信息
     * userId           用户ID
     * nickName         昵称
     * avatarImg        头像URL
     * onlineStatus     在线状态（0：离线，1：在线）
     * lastMsg          最近一条私信（包括自己及对方）
     * updateTime       最近一条私信服务器处理时间戳（1970年起的秒数）
     * unreadNum        未读条数
     * anchorType       是否主播（0：否，1：是）
     */
    string          userId;
    string          nickName;
    string          avatarImg;
    OnLineStatus    onlineStatus;
    string          lastMsg;
    long            updateTime;
    int             unreadNum;
    bool            anchorType;

};

typedef list<HttpPrivateMsgContactItem> HttpPrivateMsgContactList;


#endif /* HTTPPRIVATEMSGCONTACTITEM_H_*/
