/*
 * IMAnchorKnockRequestItem.h
 *
 *  Created on: 2018-04-10
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef IMANCHORKNOCKREQUESTITEM_H_
#define IMANCHORKNOCKREQUESTITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#define IMANCHORKNOCKREQUESTITEM_ROOMID_PARAM               "room_id"
#define IMANCHORKNOCKREQUESTITEM_USERID_PARAM               "user_id"
#define IMANCHORKNOCKREQUESTITEM_NICKNAME_PARAM             "nickname"
#define IMANCHORKNOCKREQUESTITEM_PHOTOURL_PARAM             "photourl"
#define IMANCHORKNOCKREQUESTITEM_KNOCKID_PARAM              "knock_id"
#define IMANCHORKNOCKREQUESTITEM_TYPE_PARAM                 "type"


class IMAnchorKnockRequestItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* roomId */
            if (root[IMANCHORKNOCKREQUESTITEM_ROOMID_PARAM].isString()) {
                roomId = root[IMANCHORKNOCKREQUESTITEM_ROOMID_PARAM].asString();
            }
            /* userId */
            if (root[IMANCHORKNOCKREQUESTITEM_USERID_PARAM].isString()) {
                userId = root[IMANCHORKNOCKREQUESTITEM_USERID_PARAM].asString();
            }
            /* nickName */
            if (root[IMANCHORKNOCKREQUESTITEM_NICKNAME_PARAM].isString()) {
                nickName = root[IMANCHORKNOCKREQUESTITEM_NICKNAME_PARAM].asString();
            }
            /* photoUrl */
            if (root[IMANCHORKNOCKREQUESTITEM_PHOTOURL_PARAM].isString()) {
                photoUrl = root[IMANCHORKNOCKREQUESTITEM_PHOTOURL_PARAM].asString();
            }
            /* knockId */
            if (root[IMANCHORKNOCKREQUESTITEM_KNOCKID_PARAM].isString()) {
                knockId = root[IMANCHORKNOCKREQUESTITEM_KNOCKID_PARAM].asString();
            }
            /* type */
            if (root[IMANCHORKNOCKREQUESTITEM_TYPE_PARAM].isNumeric()) {
                type = GetIMAnchorKnockType(root[IMANCHORKNOCKREQUESTITEM_TYPE_PARAM].asInt());
            }
            
            
            result = true;
        }
        return result;
    }
    
    IMAnchorKnockRequestItem() {
        roomId = "";
        userId = "";
        nickName = "";
        photoUrl = "";
        knockId = "";
        type = IMANCHORKNOCKTYPE_UNKNOWN;
    }
    
    virtual ~IMAnchorKnockRequestItem() {
        
    }
    /**
     * 敲门回复信息
     * @roomId              直播间ID
     * @userId              敲门的主播ID
     * @nickName            敲门的主播昵称
     * @photoUrl            敲门的主播头像
     * @knockId             敲门ID
     * @type                敲门回复（2：接受，3：拒绝，4：邀请超时，5：主播取消邀请）
     */
    string                      roomId;
    string                      userId;
    string                      nickName;
    string                      photoUrl;
    string                      knockId;
    IMAnchorKnockType           type;

};



#endif /* IMANCHORKNOCKREQUESTITEM_H_*/
