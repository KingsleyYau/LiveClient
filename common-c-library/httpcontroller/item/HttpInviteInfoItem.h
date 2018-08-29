/*
 * HttpInviteInfoItem.h
 *
 *  Created on: 2017-8-17
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPINVITEINFOITEM_H_
#define HTTPINVITEINFOITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"


class HttpInviteInfoItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* invitationId */
            if (root[LIVEROOM_CHECKROOM_INVITELIST_INVITATIONID].isString()) {
                invitationId = root[LIVEROOM_CHECKROOM_INVITELIST_INVITATIONID].asString();
            }
            /* oppositeId */
            if (root[LIVEROOM_CHECKROOM_INVITELIST_OPPOSITEID].isString()) {
                oppositeId = root[LIVEROOM_CHECKROOM_INVITELIST_OPPOSITEID].isString();
            }
            /* oppositeNickName */
            if (root[LIVEROOM_CHECKROOM_INVITELIST_OPPOSITENICKNAME].isString()) {
                oppositeNickName = root[LIVEROOM_CHECKROOM_INVITELIST_OPPOSITENICKNAME].asString();
            }
            /* oppositePhotoUrl */
            if (root[LIVEROOM_CHECKROOM_INVITELIST_OPPOSITEPHOTOURL].isString()) {
                oppositePhotoUrl = root[LIVEROOM_CHECKROOM_INVITELIST_OPPOSITEPHOTOURL].asString();
            }
            /* oppositeLevel */
            if (root[LIVEROOM_CHECKROOM_INVITELIST_OPPOSITELEVEL].isInt()) {
                oppositeLevel = root[LIVEROOM_CHECKROOM_INVITELIST_OPPOSITELEVEL].asInt();
            }
            /* oppositeAge */
            if (root[LIVEROOM_CHECKROOM_INVITELIST_OPPOSITEAGE].isInt()) {
                oppositeAge = root[LIVEROOM_CHECKROOM_INVITELIST_OPPOSITEAGE].asInt();
            }
            /* oppositeCountry */
            if (root[LIVEROOM_CHECKROOM_INVITELIST_OPPOSITECOUNTRY].isString()) {
                oppositeCountry = root[LIVEROOM_CHECKROOM_INVITELIST_OPPOSITECOUNTRY].asString();
            }
            /* read */
            if (root[LIVEROOM_CHECKROOM_INVITELIST_READ].isInt()) {
                read = root[LIVEROOM_CHECKROOM_INVITELIST_READ].asInt() == 0 ? false : true;
            }
            /* inviTime */
            if (root[LIVEROOM_CHECKROOM_INVITELIST_INVITIME].isInt()) {
                inviTime = root[LIVEROOM_CHECKROOM_INVITELIST_INVITIME].asInt();
            }
            /* replyType */
            if (root[LIVEROOM_CHECKROOM_INVITELIST_REPLYTYPE].isInt()) {
                replyType = GetIntToHttpReplyType(root[LIVEROOM_CHECKROOM_INVITELIST_REPLYTYPE].asInt());
            }
            /* validTime */
            if (root[LIVEROOM_CHECKROOM_INVITELIST_VALIDTIME].isInt()) {
                validTime = root[LIVEROOM_CHECKROOM_INVITELIST_VALIDTIME].asInt();
            }
            /* roomId */
            if (root[LIVEROOM_CHECKROOM_INVITELIST_ROOMID].isString()) {
                roomId = root[LIVEROOM_CHECKROOM_INVITELIST_ROOMID].asString();
            }
        }
        if (!invitationId.empty()) {
            result = true;
        }
        return result;
    }
    
    HttpInviteInfoItem() {
        invitationId = "";
        oppositeId = "";
        oppositeNickName = "";
        oppositePhotoUrl = "";
        oppositeLevel = 0;
        oppositeAge = 0;
        oppositeCountry = "";
        read = false;
        inviTime = 0;
        replyType = HTTPREPLYTYPE_UNKNOWN;
        validTime = 0;
        roomId = "";
    }
    
    virtual ~HttpInviteInfoItem() {
        
    }
    /**
     * 立即私密邀请结构体
     * invitationId			邀请ID
     * oppositeId            主播ID
     * oppositeNickName		    主播头像url
     * oppositePhotoUrl		    主播昵称
     * oppositeLevel		    主播头像url
     * oppositeAge		    主播头像url
     * oppositeCountry		    主播头像url
     * read		    主播头像url
     * inviTime		    主播头像url
     * replyType		    回复状态（0:拒绝 1:同意 2:未回复 3:已超时 4:超时 5:观众／主播取消 6:主播缺席 7:观众缺席 8:已完成）
     * validTime		    邀请的剩余有效时间（秒）（可无，仅reply_type = 2 存在）
     * roomId		    直播间ID(可无， 仅reply_type = 1 存在)
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
    HttpReplyType   replyType;
    int         validTime;
    string      roomId;
    
};

typedef list<HttpInviteInfoItem> InviteItemList;


#endif /* HTTPINVITEINFOITEM_H_*/
