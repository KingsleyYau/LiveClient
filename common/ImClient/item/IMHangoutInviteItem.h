/*
 * IMHangoutInviteItem.h
 *
 *  Created on: 2019-1-21
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef IMHANGOUTINVITEITEM_H_
#define IMHANGOUTINVITEITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
// 请求参数定义
#define HANGOUTINVITE_LOG_ID_PARAM              "log_id"
#define HANGOUTINVITE_IS_AUTO_PARAM             "is_auto"
#define HANGOUTINVITE_ANCHOR_ID_PARAM           "anchor_id"
#define HANGOUTINVITE_ANCHOR_NICKNAME_PARAM     "anchor_nickname"
#define HANGOUTINVITE_ANCHOR_COVER_PARAM        "anchor_cover"
#define HANGOUTINVITE_AVATAR_IMG_PARAM          "avatar_img"
#define HANGOUTINVITE_INVITE_MESSAGE_PARAM      "invite_message"
#define HANGOUTINVITE_WEIGHTS_PARAM             "weights"

class IMHangoutInviteItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            if (root[HANGOUTINVITE_LOG_ID_PARAM].isNumeric()) {
                logId = root[HANGOUTINVITE_LOG_ID_PARAM].asInt();
            }
            if (root[HANGOUTINVITE_IS_AUTO_PARAM].isNumeric()) {
                isAuto =  GetReplyType(root[HANGOUTINVITE_IS_AUTO_PARAM].asInt() == 0 ? false : true);
            }
            if (root[HANGOUTINVITE_ANCHOR_ID_PARAM].isString()) {
                anchorId = root[HANGOUTINVITE_ANCHOR_ID_PARAM].asString();
            }
            if (root[HANGOUTINVITE_ANCHOR_NICKNAME_PARAM].isString()) {
                nickName = root[HANGOUTINVITE_ANCHOR_NICKNAME_PARAM].asString();
            }
            if (root[HANGOUTINVITE_ANCHOR_COVER_PARAM].isString()) {
                cover = root[HANGOUTINVITE_ANCHOR_COVER_PARAM].asString();
            }
            if (root[HANGOUTINVITE_INVITE_MESSAGE_PARAM].isString()) {
                InviteMessage = root[HANGOUTINVITE_INVITE_MESSAGE_PARAM].asString();
            }
            if (root[HANGOUTINVITE_WEIGHTS_PARAM].isNumeric()) {
                weights = root[HANGOUTINVITE_WEIGHTS_PARAM].asInt();
            }
            if (root[HANGOUTINVITE_AVATAR_IMG_PARAM].isString()) {
                avatarImg = root[HANGOUTINVITE_AVATAR_IMG_PARAM].asString();
            }

        }

        result = true;

        return result;
    }

    IMHangoutInviteItem() {
        logId = 0;
        isAuto = false;
        anchorId = "";
        nickName = "";
        cover = "";
        InviteMessage = "";
        weights = 0;
        avatarImg = "";
    }
    
    virtual ~IMHangoutInviteItem() {
        
    }
    
    /**
     * 邀请信息
     * logId            记录ID
     * isAuto           是否自动邀请
     * anchorId         主播ID
     * nickName         主播昵称
     * cover            封面图URL
     * InviteMessage    邀请内容
     * weights          权重值
     * avatarImg        主播头像
     */
    int          logId;
    bool          isAuto;
    string        anchorId;
    string        nickName;
    string        cover;
    string        InviteMessage;
    int           weights;
    string        avatarImg;
};


#endif /* IMHANGOUTINVITEITEM_H_*/
