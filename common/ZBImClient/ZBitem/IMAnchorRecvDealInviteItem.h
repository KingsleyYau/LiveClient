/*
 * IMAnchorRecvDealInviteItem.h
 *
 *  Created on: 2018-04-10
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef IMANCHORRECVDEALINVITEITEM_H_
#define IMANCHORRECVDEALINVITEITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#define IMANCHORRECVDEALINVITEITEM_INVITEID_PARAM              "invite_id"
#define IMANCHORRECVDEALINVITEITEM_ROOMID_PARAM                "room_id"
#define IMANCHORRECVDEALINVITEITEM_ANCHORID_PARAM              "anchor_id"
#define IMANCHORRECVDEALINVITEITEM_NICKNAME_PARAM              "nickname"
#define IMANCHORRECVDEALINVITEITEM_PHOTOURL_PARAM              "photourl"
#define IMANCHORRECVDEALINVITEITEM_TYPE_PARAM                  "type"


class IMAnchorRecvDealInviteItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* inviteId */
            if (root[IMANCHORRECVDEALINVITEITEM_INVITEID_PARAM].isString()) {
                inviteId = root[IMANCHORRECVDEALINVITEITEM_INVITEID_PARAM].asString();
            }
            /* roomId */
            if (root[IMANCHORRECVDEALINVITEITEM_ROOMID_PARAM].isString()) {
                roomId = root[IMANCHORRECVDEALINVITEITEM_ROOMID_PARAM].asString();
            }
            /* anchorId */
            if (root[IMANCHORRECVDEALINVITEITEM_ANCHORID_PARAM].isString()) {
                anchorId = root[IMANCHORRECVDEALINVITEITEM_ANCHORID_PARAM].asString();
            }
            /* nickName */
            if (root[IMANCHORRECVDEALINVITEITEM_NICKNAME_PARAM].isString()) {
                nickName = root[IMANCHORRECVDEALINVITEITEM_NICKNAME_PARAM].asString();
            }
            /* photoUrl */
            if (root[IMANCHORRECVDEALINVITEITEM_PHOTOURL_PARAM].isString()) {
                photoUrl = root[IMANCHORRECVDEALINVITEITEM_PHOTOURL_PARAM].asString();
            }
            /* type */
            if (root[IMANCHORRECVDEALINVITEITEM_TYPE_PARAM].isNumeric()) {
                type = GetIMAnchorReplyInviteType(root[IMANCHORRECVDEALINVITEITEM_TYPE_PARAM].asInt());
            }
            
            
            result = true;
        }
        return result;
    }
    
    IMAnchorRecvDealInviteItem() {
        inviteId = "";
        roomId = "";
        anchorId = "";
        nickName = "";
        photoUrl = "";
        type = IMANCHORREPLYINVITETYPE_UNKNOWN;
    }
    
    virtual ~IMAnchorRecvDealInviteItem() {
        
    }
    /**
     * 主播回复观众多人互动邀请信息
     * @inviteId            邀请ID
     * @roomId              直播间ID
     * @anchorId            主播ID
     * @nickName            主播昵称
     * @photoUrl            主播头像
     * @type                邀请回复（2：接受，3：拒绝，4：邀请超时，5：观众取消邀请）
     */
    string                      inviteId;
    string                      roomId;
    string                      anchorId;
    string                      nickName;
    string                      photoUrl;
    IMAnchorReplyInviteType     type;

};



#endif /* IMANCHORRECVDEALINVITEITEM_H_*/
