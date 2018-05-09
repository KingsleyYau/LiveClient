/*
 * IMAnchorRecvOtherInviteItem.h
 *
 *  Created on: 2018-04-10
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef IMANCHORRECVOTHERINVITEITEM_H_
#define IMANCHORRECVOTHERINVITEITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#define IMANCHORRECVOTHERINVITEITEM_INVITEID_PARAM              "invite_id"
#define IMANCHORRECVOTHERINVITEITEM_ROOMID_PARAM                "room_id"
#define IMANCHORRECVOTHERINVITEITEM_ANCHORID_PARAM              "anchor_id"
#define IMANCHORRECVOTHERINVITEITEM_NICKNAME_PARAM              "nickname"
#define IMANCHORRECVOTHERINVITEITEM_PHOTOURL_PARAM              "photourl"
#define IMANCHORRECVOTHERINVITEITEM_EXPIRE_PARAM                "expire"


class IMAnchorRecvOtherInviteItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* inviteId */
            if (root[IMANCHORRECVOTHERINVITEITEM_INVITEID_PARAM].isString()) {
                inviteId = root[IMANCHORRECVOTHERINVITEITEM_INVITEID_PARAM].asString();
            }
            /* roomId */
            if (root[IMANCHORRECVOTHERINVITEITEM_ROOMID_PARAM].isString()) {
                roomId = root[IMANCHORRECVOTHERINVITEITEM_ROOMID_PARAM].asString();
            }
            /* anchorId */
            if (root[IMANCHORRECVOTHERINVITEITEM_ANCHORID_PARAM].isString()) {
                anchorId = root[IMANCHORRECVOTHERINVITEITEM_ANCHORID_PARAM].asString();
            }
            /* nickName */
            if (root[IMANCHORRECVOTHERINVITEITEM_NICKNAME_PARAM].isString()) {
                nickName = root[IMANCHORRECVOTHERINVITEITEM_NICKNAME_PARAM].asString();
            }
            /* photoUrl */
            if (root[IMANCHORRECVOTHERINVITEITEM_PHOTOURL_PARAM].isString()) {
                photoUrl = root[IMANCHORRECVOTHERINVITEITEM_PHOTOURL_PARAM].asString();
            }
            /* expire */
            if (root[IMANCHORRECVOTHERINVITEITEM_EXPIRE_PARAM].isNumeric()) {
                expire = root[IMANCHORRECVOTHERINVITEITEM_EXPIRE_PARAM].asInt();
            }
            
            
            result = true;
        }
        return result;
    }
    
    IMAnchorRecvOtherInviteItem() {
        inviteId = "";
        roomId = "";
        anchorId = "";
        nickName = "";
        photoUrl = "";
        expire = 0;
    }
    
    virtual ~IMAnchorRecvOtherInviteItem() {
        
    }
    /**
     * 观众邀请其它主播加入信息
     * @inviteId            邀请ID
     * @roomId              多人互动直播间ID
     * @anchorId            被邀请的主播ID
     * @nickName            被邀请的主播昵称
     * @photoUrl            被邀请的主播头像
     * @expire              邀请有效的剩余秒数
     */
    string                      inviteId;
    string                      roomId;
    string                      anchorId;
    string                      nickName;
    string                      photoUrl;
    int                         expire;

};



#endif /* IMANCHORRECVOTHERINVITEITEM_H_*/
