/*
 * HttpBookingPrivateInviteItem.h
 *
 *  Created on: 2017-8-18
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPBOOKINPRIVATEINVITEITEM_H_
#define HTTPBOOKINPRIVATEINVITEITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"

// 预约待处理列表
class HttpBookingPrivateInviteItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* invitationId */
            if (root[LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_INVITATIONID].isString()) {
                invitationId = root[LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_INVITATIONID].asString();
            }
            /* toId */
            if (root[LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_TOID].isString()) {
                toId = root[LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_TOID].asString();
            }
            /* fromId */
            if (root[LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_FROMID].isString()) {
                fromId = root[LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_FROMID].asString();
            }
            /* oppositePhotoUrl */
            if (root[LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_OPPOSITEPHOTOURL].isString()) {
                oppositePhotoUrl = root[LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_OPPOSITEPHOTOURL].asString();
            }
            /* oppositeNickName */
            if (root[LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_OPPOSITENICKNAME].isString()) {
                oppositeNickName = root[LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_OPPOSITENICKNAME].asString();
            }
            /* read */
            if (root[LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_READ].isInt()) {
                read = root[LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_READ].asInt() == 0 ? false : true;
            }
            /* intimacy */
            if (root[LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_INTIMACY].isInt()) {
                intimacy = root[LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_INTIMACY].asInt();
            }
            /* replyType */
            if (root[LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_REPLYTYPE].isInt()) {
                replyType = (BookingReplyType)root[LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_REPLYTYPE].asInt();
            }
            /* bookTime */
            if (root[LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_BOOKTIME].isInt()) {
                bookTime = root[LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_BOOKTIME].asInt();
            }
            /* giftId */
            if (root[LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_GIFTID].isString()) {
                giftId = root[LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_GIFTID].asString();
            }
            /* giftName */
            if (root[LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_GIFTNAME].isString()) {
                giftName = root[LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_GIFTNAME].asString();
            }
 
            /* giftBigImgUrl */
            if (root[LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_GIFTBIGIMGURL].isString()) {
                giftBigImgUrl = root[LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_GIFTBIGIMGURL].asString();
            }
            /* giftSmallImgUrl */
            if (root[LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_GIFTSMALLIMGURL].isString()) {
                giftSmallImgUrl = root[LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_GIFTSMALLIMGURL].asString();
            }
            /* giftNum */
            if (root[LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_GIFTNUM].isInt()) {
                giftNum = root[LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_GIFTNUM].asInt();
            }
            
            /* validTime */
            if (root[LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_VALIDTIME].isInt()) {
                validTime = root[LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_VALIDTIME].asInt();
            }
            
            /* roomId */
            if (root[LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_ROOMID].isString()) {
                roomId = root[LIVEROOM_MANHANDLEBOOKINGLIST_LIST_BOOKING_ROOMID].asString();
            }
            
        }
        if (!invitationId.empty()) {
            result = true;
        }
        return result;
    }

    HttpBookingPrivateInviteItem() {
        invitationId = "";
        toId = "";
        fromId = "";
        oppositePhotoUrl = "";
        oppositeNickName = "";
        read = false;
        intimacy = 0;
        replyType = BOOKINGREPLYTYPE_UNKNOWN;
        bookTime = 0;
        giftId = "";
        giftName = "";
        giftBigImgUrl = "";
        giftSmallImgUrl = "";
        giftNum = 0;
        validTime = 0;
        roomId = "";

    }
    
    virtual ~HttpBookingPrivateInviteItem() {
        
    }
    
    /**
     * 预约私密结构体
     * invitationId         邀请ID
     * toId                 接受者ID
     * fromId               发送者ID
     * oppositePhotoUrl	   对端头像
     * oppositeNickName	   对端昵称
     * read		           已读状态（0:未读 1:已读）
     * intimacy             亲密度
     * replyType            状态（1:待确定 2:已接受 3:已拒绝 4:超时 5:取消 6:主播缺席 7:观众缺席 8:已完成）
     * bookTime		       预约时间（1970年起的秒数）
     * giftId		       礼物ID（可无）
     * giftName		       礼物名称（可无， 仅giftId存在才存在）
     * giftBigImgUrl		   礼物高质量图标url（可无，仅仅giftId存在才存在）
     * giftSmallImgUrl	   礼物低质量图标url（可无，仅仅giftId存在才存在）
     * giftNum		       礼物数量
     * validTime		       邀请的剩余邮箱时间（秒， 可无，仅replyType＝1存在）
     * roomId		       直播间ID（可无，仅replyType＝2存在）
     */
    string      invitationId;
    string      toId;
    string      fromId;
    string      oppositePhotoUrl;
    string      oppositeNickName;
    bool        read;
    int         intimacy;
    BookingReplyType replyType;
    long        bookTime;
    string      giftId;
    string      giftName;
    string      giftBigImgUrl;
    string      giftSmallImgUrl;
    int         giftNum;
    int         validTime;
    string      roomId;
};

typedef list<HttpBookingPrivateInviteItem> BookingPrivateInviteItemList;

#endif /* HTTPBOOKINPRIVATEINVITEITEM_H_*/
