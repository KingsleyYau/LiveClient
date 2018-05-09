/*
 * AnchorHangoutInviteItem.h
 *
 *  Created on: 2018-04-09
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef ANCHORHANGOUTINVITEITEM_H_
#define ANCHORHANGOUTINVITEITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "AnchorItem.h"

#define HANGOUTINVITE_INVITEID_PARAM                "invite_id"
#define HANGOUTINVITE_USERID_PARAM                  "user_id"
#define HANGOUTINVITE_NICKNAME_PARAM                "nickname"
#define HANGOUTINVITE_PHOTOURL_PARAM                "photourl"
#define HANGOUTINVITE_ANCHORLIST_PARAM              "anchor_list"
#define HANGOUTINVITE_EXPIRE_PARAM                  "expire"


class AnchorHangoutInviteItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* inviteId */
            if (root[HANGOUTINVITE_INVITEID_PARAM].isString()) {
                inviteId = root[HANGOUTINVITE_INVITEID_PARAM].asString();
            }
            /* userId */
            if (root[HANGOUTINVITE_USERID_PARAM].isString()) {
                userId = root[HANGOUTINVITE_USERID_PARAM].asString();
            }
            /* nickName */
            if (root[HANGOUTINVITE_NICKNAME_PARAM].isString()) {
                nickName = root[HANGOUTINVITE_NICKNAME_PARAM].asString();
            }
            /* photoUrl */
            if (root[HANGOUTINVITE_PHOTOURL_PARAM].isString()) {
                photoUrl = root[HANGOUTINVITE_PHOTOURL_PARAM].asString();
            }
           
            
            /* anchorList */
            if (root[HANGOUTINVITE_ANCHORLIST_PARAM].isArray()) {
                int i = 0;
                for (i = 0; i < root[HANGOUTINVITE_ANCHORLIST_PARAM].size(); i++) {
                    AnchorItem item;
                    item.Parse(root[HANGOUTINVITE_ANCHORLIST_PARAM].get(i, Json::Value::null));
                    anchorList.push_back(item);
                }
            }
            
            /* expire */
            if (root[HANGOUTINVITE_EXPIRE_PARAM].isNumeric()) {
                expire = root[HANGOUTINVITE_EXPIRE_PARAM].asInt();
            }

            result = true;
        }
        return result;
    }
    
    AnchorHangoutInviteItem() {
        inviteId = "";
        userId = "";
        nickName = "";
        photoUrl = "";
        expire = 0;
    }
    
    virtual ~AnchorHangoutInviteItem() {
        
    }
    /**
     * 互动直播间邀请信息
     * @inviteId              邀请ID
     * @userId                观众ID
     * @nickName              观众昵称
     * @photoUrl              观众头像url
     * @anchorList            已在直播间的主播列表
     * @expire                邀请有效的剩余秒数
     */
    string                      inviteId;
    string                      userId;
    string                      nickName;
    string                      photoUrl;
    AnchorItemList              anchorList;
    int                         expire;

};



#endif /* ANCHORHANGOUTINVITEITEM_H_*/
