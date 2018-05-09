/*
 * ZBPrivateInviteItem.h
 *
 *  Created on: 2018-03-02
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef ZBPRIVATEINVITEITEM_H_
#define ZBPRIVATEINVITEITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#define INVITATIONID_PARAM          "invitation_id"
#define OPPOSITEID_PARAM            "opposite_id"
#define OPPOSITENICKNAME_PARAM      "opposite_nickname"
#define OPPOSITEPHOTOURL_PARAM      "opposite_photourl"
#define OPPOSITELEVEL_PARAM         "opposite_level"
#define OPPOSITEAGE_PARAM           "opposite_age"
#define OPPOSITECOUNTRY_PARAM       "opposite_country"
#define READ_PARAM                  "read"
#define INVITIME_PARAM              "invi_time"
#define REPLYTYPE_PARAM             "reply_type"
#define VALIDTIME_PARAM             "valid_time"
#define ROOMID_PARAM                "roomid"


class ZBPrivateInviteItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* invitationId */
            if (root[INVITATIONID_PARAM].isString()) {
                invitationId = root[INVITATIONID_PARAM].asString();
            }
            /* oppositeId */
            if (root[OPPOSITEID_PARAM].isString()) {
                oppositeId = root[OPPOSITEID_PARAM].asString();
            }
            /* oppositeNickName */
            if (root[OPPOSITENICKNAME_PARAM].isString()) {
                oppositeNickName = root[OPPOSITENICKNAME_PARAM].asString();
            }
            /* oppositePhotoUrl */
            if (root[OPPOSITEPHOTOURL_PARAM].isString()) {
                oppositePhotoUrl = root[OPPOSITEPHOTOURL_PARAM].asString();
            }
            /* oppositeLevel */
            if (root[OPPOSITELEVEL_PARAM].isInt()) {
                oppositeLevel = root[OPPOSITELEVEL_PARAM].asInt();
            }
            /* oppositeAge */
            if (root[OPPOSITEAGE_PARAM].isInt()) {
                oppositeAge = root[OPPOSITEAGE_PARAM].asInt();
            }
            /* oppositeCountry */
            if (root[OPPOSITECOUNTRY_PARAM].isString()) {
                oppositeCountry = root[OPPOSITECOUNTRY_PARAM].asString();
            }
            /* read */
            if (root[READ_PARAM].isInt()) {
                read = root[READ_PARAM].asInt() == 0 ? false : true;
            }
            /* inviTime */
            if (root[INVITIME_PARAM].isInt()) {
                inviTime = root[INVITIME_PARAM].asInt();
            }
            /* replyType */
            if (root[REPLYTYPE_PARAM].isInt()) {
                replyType = (ZBIMReplyType)root[REPLYTYPE_PARAM].asInt();
            }
            /* validTime */
            if (root[VALIDTIME_PARAM].isInt()) {
                validTime = root[VALIDTIME_PARAM].asInt();
            }
            /* roomId */
            if (root[ROOMID_PARAM].isString()) {
                roomId = root[ROOMID_PARAM].asString();
            }
        }
        if (!invitationId.empty()) {
            result = true;
        }
        return result;
    }
    
    ZBPrivateInviteItem() {
        invitationId = "";
        oppositeId = "";
        oppositeNickName = "";
        oppositePhotoUrl = "";
        oppositeLevel = 0;
        oppositeAge = 0;
        oppositeCountry = "";
        read = false;
        inviTime = 0;
        replyType = ZBIMREPLYTYPE_UNKNOWN;
        validTime = 0;
        roomId = "";
    }
    
    virtual ~ZBPrivateInviteItem() {
        
    }
    /**
     * 立即私密邀请结构体
     * @invitationId            邀请ID
     * @oppositeId              主播ID
     * @oppositeNickName        对端昵称
     * @oppositePhotoUrl        对端头像
     * @oppositeLevel           对端等级
     * @oppositeAge             对端年龄
     * @oppositeCountry         对端国家
     * @read                    已读状态（false：未读，true：已读）
     * @inviTime                邀请时间（1970年起的秒数）
     * @replyType               回复状态（1：待确定，2：已接受，3：已拒绝，4：超时，5：观众/主播取消，6：主播缺席， 7：观众缺席，8：已完成）
     * @validTime               邀请的剩余有效时间（秒）（可无，仅reply_type = 2 存在）
     * @roomId                  直播间ID(可无， 仅reply_type = 1 存在)
     */
    string      invitationId;
    string      oppositeId;
    string      oppositeNickName;
    string      oppositePhotoUrl;
    int         oppositeLevel;
    int         oppositeAge;
    string      oppositeCountry;
    bool        read;
    long        inviTime;
    ZBIMReplyType   replyType;
    int         validTime;
    string      roomId;
    
};

typedef list<ZBPrivateInviteItem> ZBInviteList;


#endif /* PRIVATEINVITEITEM_H_*/
