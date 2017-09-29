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

#define INVITEID_PARAM              "invite_id"
#define REPLYTYPE_PARAM             "reply_type"
#define BOOKROOMID_PARAM            "room_id"
#define ANCHORID_PARAM              "anchor_id"
#define BOOKNICKNAME_PARAM          "nick_name"
#define AVATARIMG_PARAM             "avatar_img"
#define MSG_PARAM                   "msg"


class BookingReplyItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* inviteId */
            if (root[INVITEID_PARAM].isString()) {
                inviteId = root[INVITEID_PARAM].asString();
            }
            /* replyType */
            if (root[REPLYTYPE_PARAM].isIntegral()) {
                replyType = (ReplyType)root[REPLYTYPE_PARAM].asInt();
            }
            /* roomId */
            if (root[BOOKROOMID_PARAM].isString()) {
                roomId = root[BOOKROOMID_PARAM].asString();
            }
            /* anchorId */
            if (root[ANCHORID_PARAM].isString()) {
                anchorId = root[ANCHORID_PARAM].asString();
            }
            /* nickName */
            if (root[BOOKNICKNAME_PARAM].isString()) {
                nickName = root[BOOKNICKNAME_PARAM].asString();
            }
            /* avatarImg */
            if (root[AVATARIMG_PARAM].isString()) {
                avatarImg = root[AVATARIMG_PARAM].asString();
            }
            /* msg */
            if (root[MSG_PARAM].isString()) {
                msg = root[MSG_PARAM].asString();
            }
            
        }
        result = true;
        return result;
    }
    
    BookingReplyItem() {
        inviteId = "";
        replyType = REPLYTYPE_REJECT;
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
    ReplyType             replyType;
    string                roomId;
    string                anchorId;
    string                nickName;
    string                avatarImg;
    string                msg;
    
};

#endif /* BOOKINGREPLYITEM_H_*/
