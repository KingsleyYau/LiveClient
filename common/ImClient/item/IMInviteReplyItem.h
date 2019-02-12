/*
 * IMInviteReplyItem.h
 *
 *  Created on: 2017-9-05
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef IMINVITEREPLYITEM_H_
#define IMINVITEREPLYITEM_H_

#include <string>
using namespace std;
#include "IMAuthorityItem.h"

#include <json/json/json.h>
// 请求参数定义
#define INVITEID_PARAM          "invite_id"
#define REPLYTYPE_PARAM         "reply_type"
#define IMROOMID_PARAM          "room_id"
#define ROOMTYPE_PARAM          "room_type"
#define ANCHORID_PARAM          "anchor_id"
#define NICKNAMET_PARAM         "nick_name"
#define AVATARIMG_PARAM         "avatar_img"
#define MSG_PARAM               "msg"
#define RECV_CHAT_ONLINE_STATUS_PARAM         "chat_online_status"
#define RECV_IMINVITE_PRIV_PARAM         "priv"

class IMInviteReplyItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            if (root[INVITEID_PARAM].isString()) {
                inviteId = root[INVITEID_PARAM].asString();
            }
            if (root[REPLYTYPE_PARAM].isInt()) {
                replyType =  GetReplyType(root[REPLYTYPE_PARAM].asInt());
            }
            if (root[IMROOMID_PARAM].isString()) {
                roomId = root[IMROOMID_PARAM].asString();
            }
            if (root[ROOMTYPE_PARAM].isInt()) {
                roomType = GetRoomType(root[ROOMTYPE_PARAM].asInt());
            }
            if (root[ANCHORID_PARAM].isString()) {
                anchorId = root[ANCHORID_PARAM].asString();
            }
            if (root[NICKNAMET_PARAM].isString()) {
                nickName = root[NICKNAMET_PARAM].asString();
            }
            if (root[AVATARIMG_PARAM].isString()) {
                avatarImg = root[AVATARIMG_PARAM].asString();
            }
            if (root[MSG_PARAM].isString()) {
                msg = root[MSG_PARAM].asString();
            }
            if (root[RECV_CHAT_ONLINE_STATUS_PARAM].isNumeric()) {
                status = GetIntToIMChatOnlineStatus(root[RECV_CHAT_ONLINE_STATUS_PARAM].asInt());
            }
            if (root[RECV_IMINVITE_PRIV_PARAM].isObject()) {
                priv.Parse(root[RECV_IMINVITE_PRIV_PARAM]);
            }

        }

        result = true;

        return result;
    }

    IMInviteReplyItem() {
        inviteId = "";
        replyType = REPLYTYPE_REJECT;
        roomId = "";
        roomType = ROOMTYPE_UNKNOW;
        inviteId = "";
        anchorId = "";
        nickName = "";
        avatarImg = "";
        msg = "";
        status = IMCHATONLINESTATUS_OFF;
    }
    
    virtual ~IMInviteReplyItem() {
        
    }
    
    /**
     * 权限
     */
    string        inviteId;
    ReplyType     replyType;
    string        roomId;
    RoomType      roomType;
    string        anchorId;   // 主播ID
    string        nickName;   // 主播昵称
    string        avatarImg;  // 主播头像url
    string        msg;        // 提示文字
    IMChatOnlineStatus status;
    IMAuthorityItem  priv;
};


#endif /* IMINVITEREPLYITEM_H_*/
