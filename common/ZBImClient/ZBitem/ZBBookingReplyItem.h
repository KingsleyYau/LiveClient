/*
 * BookingReplyItem.h
 *
 *  Created on: 2017-09-12
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef BOOKINGREPLYITEM_H_
#define BOOKINGREPLYITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#define ZBBPI_INVITEID_PARAM              "invite_id"
#define ZBBPI_REPLYTYPE_PARAM             "reply_type"
#define ZBBPI_BOOKROOMID_PARAM            "room_id"
#define ZBBPI_ANCHORID_PARAM              "anchor_id"
#define ZBBPI_BOOKNICKNAME_PARAM          "nick_name"
#define ZBBPI_AVATARIMG_PARAM             "avatar_img"
#define ZBBPI_MSG_PARAM                   "msg"


class BookingReplyItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* inviteId */
            if (root[ZBBPI_INVITEID_PARAM].isString()) {
                inviteId = root[ZBBPI_INVITEID_PARAM].asString();
            }
            /* replyType */
            if (root[ZBBPI_REPLYTYPE_PARAM].isIntegral()) {
                replyType = (ZBReplyType)root[ZBBPI_REPLYTYPE_PARAM].asInt();
            }
            /* roomId */
            if (root[ZBBPI_BOOKROOMID_PARAM].isString()) {
                roomId = root[ZBBPI_BOOKROOMID_PARAM].asString();
            }
            /* anchorId */
            if (root[ZBBPI_ANCHORID_PARAM].isString()) {
                anchorId = root[ZBBPI_ANCHORID_PARAM].asString();
            }
            /* nickName */
            if (root[ZBBPI_BOOKNICKNAME_PARAM].isString()) {
                nickName = root[ZBBPI_BOOKNICKNAME_PARAM].asString();
            }
            /* avatarImg */
            if (root[ZBBPI_AVATARIMG_PARAM].isString()) {
                avatarImg = root[ZBBPI_AVATARIMG_PARAM].asString();
            }
            /* msg */
            if (root[ZBBPI_MSG_PARAM].isString()) {
                msg = root[ZBBPI_MSG_PARAM].asString();
            }
            
        }
        result = true;
        return result;
    }
    
    BookingReplyItem() {
        inviteId = "";
        replyType = ZBREPLYTYPE_REJECT;
        roomId = "";
        anchorId = "";
        nickName = "";
        avatarImg = "";
        msg = "";
    }
    
    virtual ~BookingReplyItem() {
        
    }
    /**
     * 预约私密邀请回复知结构体
     * inviteId                 邀请ID
     * replyType                主播回复（0:拒绝 1:同意）
     * roomId                   直播间ID
     * anchorId                 主播ID
     * nickName                 主播昵称
     * avatarImg                主播头像url
     * msg                      提示文字
     */
    string                inviteId;
    ZBReplyType             replyType;
    string                roomId;
    string                anchorId;
    string                nickName;
    string                avatarImg;
    string                msg;
    
};

#endif /* BOOKINGREPLYITEM_H_*/
