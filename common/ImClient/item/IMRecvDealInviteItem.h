/*
 * IMRecvDealInviteItem.h
 *
 *  Created on: 2018-04-13
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef IMRECVDEALINVITEITEM_H_
#define IMRECVDEALINVITEITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#define IMRECVDEALINVITEITEM_INVITEID_PARAM              "invite_id"
#define IMRECVDEALINVITEITEM_ROOMID_PARAM                "room_id"
#define IMRECVDEALINVITEITEM_ANCHORID_PARAM              "anchor_id"
#define IMRECVDEALINVITEITEM_NICKNAME_PARAM              "nickname"
#define IMRECVDEALINVITEITEM_PHOTOURL_PARAM              "photourl"
#define IMRECVDEALINVITEITEM_TYPE_PARAM                  "type"

class IMRecvDealInviteItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* inviteId */
            if (root[IMRECVDEALINVITEITEM_INVITEID_PARAM].isString()) {
                inviteId = root[IMRECVDEALINVITEITEM_INVITEID_PARAM].asString();
            }
            /* roomId */
            if (root[IMRECVDEALINVITEITEM_ROOMID_PARAM].isString()) {
                roomId = root[IMRECVDEALINVITEITEM_ROOMID_PARAM].asString();
            }
            /* anchorId */
            if (root[IMRECVDEALINVITEITEM_ANCHORID_PARAM].isString()) {
                anchorId = root[IMRECVDEALINVITEITEM_ANCHORID_PARAM].asString();
            }
            /* nickName */
            if (root[IMRECVDEALINVITEITEM_NICKNAME_PARAM].isString()) {
                nickName = root[IMRECVDEALINVITEITEM_NICKNAME_PARAM].asString();
            }
            /* photoUrl */
            if (root[IMRECVDEALINVITEITEM_PHOTOURL_PARAM].isString()) {
                photoUrl = root[IMRECVDEALINVITEITEM_PHOTOURL_PARAM].asString();
            }
            /* type */
            if (root[IMRECVDEALINVITEITEM_TYPE_PARAM].isNumeric()) {
                type = GetIMReplyInviteType(root[IMRECVDEALINVITEITEM_TYPE_PARAM].asInt());
            }
            
            result = true;
        }
        return result;
    }
    
    IMRecvDealInviteItem() {
        inviteId = "";
        roomId = "";
        anchorId = "";
        nickName = "";
        photoUrl = "";
        type = IMREPLYINVITETYPE_UNKNOWN;
    }
    
    virtual ~IMRecvDealInviteItem() {
        
    }
    /**
     * 主播回复观众多人互动邀请信息
     * @inviteId            邀请ID
     * @roomId              直播间ID
     * @anchorId            主播ID
     * @nickName            主播昵称
     * @photoUrl            主播头像
     * @type                邀请回复（2：接受，3：拒绝，4：邀请超时，5：观众取消邀请）
     * @expire              主播进入直播间的倒数秒数
     */
    string                      inviteId;
    string                      roomId;
    string                      anchorId;
    string                      nickName;
    string                      photoUrl;
    IMReplyInviteType           type;

};



#endif /* IMRECVDEALINVITEITEM_H_*/
