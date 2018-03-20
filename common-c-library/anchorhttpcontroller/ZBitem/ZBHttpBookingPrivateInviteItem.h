/*
 * ZBHttpBookingPrivateInviteItem.h
 *
 *  Created on: 2018-2-28
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef ZBHTTPBOOKINPRIVATEINVITEITEM_H_
#define ZBHTTPBOOKINPRIVATEINVITEITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../ZBHttpLoginProtocol.h"
#include "../ZBHttpRequestEnum.h"

// 预约待处理列表
class ZBHttpBookingPrivateInviteItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* invitationId */
            if (root[MANHANDLEBOOKINGLIST_LIST_BOOKING_INVITATIONID].isString()) {
                invitationId = root[MANHANDLEBOOKINGLIST_LIST_BOOKING_INVITATIONID].asString();
            }
//            // alextest
//            if (root[MANHANDLEBOOKINGLIST_LIST_BOOKING_INVITATIONID].isNumeric()) {
//                char temp[16];
//                snprintf(temp, sizeof(temp), "%d",  root[MANHANDLEBOOKINGLIST_LIST_BOOKING_INVITATIONID].asInt());
//                invitationId =  temp;
//            }
            /* toId */
            if (root[MANHANDLEBOOKINGLIST_LIST_BOOKING_TOID].isString()) {
                toId = root[MANHANDLEBOOKINGLIST_LIST_BOOKING_TOID].asString();
            }
            /* fromId */
            if (root[MANHANDLEBOOKINGLIST_LIST_BOOKING_FROMID].isString()) {
                fromId = root[MANHANDLEBOOKINGLIST_LIST_BOOKING_FROMID].asString();
            }
            /* oppositePhotoUrl */
            if (root[MANHANDLEBOOKINGLIST_LIST_BOOKING_OPPOSITEPHOTOURL].isString()) {
                oppositePhotoUrl = root[MANHANDLEBOOKINGLIST_LIST_BOOKING_OPPOSITEPHOTOURL].asString();
            }
            /* oppositeNickName */
            if (root[MANHANDLEBOOKINGLIST_LIST_BOOKING_OPPOSITENICKNAME].isString()) {
                oppositeNickName = root[MANHANDLEBOOKINGLIST_LIST_BOOKING_OPPOSITENICKNAME].asString();
            }
            /* read */
            if (root[MANHANDLEBOOKINGLIST_LIST_BOOKING_READ].isInt()) {
                read = root[MANHANDLEBOOKINGLIST_LIST_BOOKING_READ].asInt() == 0 ? false : true;
            }
            /* intimacy */
            if (root[MANHANDLEBOOKINGLIST_LIST_BOOKING_INTIMACY].isInt()) {
                intimacy = root[MANHANDLEBOOKINGLIST_LIST_BOOKING_INTIMACY].asInt();
            }
            /* replyType */
            if (root[MANHANDLEBOOKINGLIST_LIST_BOOKING_REPLYTYPE].isInt()) {
                replyType = (ZBBookingReplyType)root[MANHANDLEBOOKINGLIST_LIST_BOOKING_REPLYTYPE].asInt();
            }
            /* bookTime */
            if (root[MANHANDLEBOOKINGLIST_LIST_BOOKING_BOOKTIME].isInt()) {
                bookTime = root[MANHANDLEBOOKINGLIST_LIST_BOOKING_BOOKTIME].asInt();
            }
            /* giftId */
            if (root[MANHANDLEBOOKINGLIST_LIST_BOOKING_GIFTID].isString()) {
                giftId = root[MANHANDLEBOOKINGLIST_LIST_BOOKING_GIFTID].asString();
            }
            /* giftName */
            if (root[MANHANDLEBOOKINGLIST_LIST_BOOKING_GIFTNAME].isString()) {
                giftName = root[MANHANDLEBOOKINGLIST_LIST_BOOKING_GIFTNAME].asString();
            }
 
            /* giftBigImgUrl */
            if (root[MANHANDLEBOOKINGLIST_LIST_BOOKING_GIFTBIGIMGURL].isString()) {
                giftBigImgUrl = root[MANHANDLEBOOKINGLIST_LIST_BOOKING_GIFTBIGIMGURL].asString();
            }
            /* giftSmallImgUrl */
            if (root[MANHANDLEBOOKINGLIST_LIST_BOOKING_GIFTSMALLIMGURL].isString()) {
                giftSmallImgUrl = root[MANHANDLEBOOKINGLIST_LIST_BOOKING_GIFTSMALLIMGURL].asString();
            }
            /* giftNum */
            if (root[MANHANDLEBOOKINGLIST_LIST_BOOKING_GIFTNUM].isInt()) {
                giftNum = root[MANHANDLEBOOKINGLIST_LIST_BOOKING_GIFTNUM].asInt();
            }
            
            /* validTime */
            if (root[MANHANDLEBOOKINGLIST_LIST_BOOKING_VALIDTIME].isInt()) {
                validTime = root[MANHANDLEBOOKINGLIST_LIST_BOOKING_VALIDTIME].asInt();
            }
            
            /* roomId */
            if (root[MANHANDLEBOOKINGLIST_LIST_BOOKING_ROOMID].isString()) {
                roomId = root[MANHANDLEBOOKINGLIST_LIST_BOOKING_ROOMID].asString();
            }
            
//            // alextest
//            if (root[MANHANDLEBOOKINGLIST_LIST_BOOKING_ROOMID].isNumeric()) {
//                char temp[16];
//                snprintf(temp, sizeof(temp), "%d",  root[MANHANDLEBOOKINGLIST_LIST_BOOKING_ROOMID].asInt());
//                roomId =  temp;
//            }
            
        }
        
        if (!invitationId.empty()) {
            result = true;
        }
        return result;
    }

    ZBHttpBookingPrivateInviteItem() {
        invitationId = "";
        toId = "";
        fromId = "";
        oppositePhotoUrl = "";
        oppositeNickName = "";
        read = false;
        intimacy = 0;
        replyType = ZBBOOKINGREPLYTYPE_UNKNOWN;
        bookTime = 0;
        giftId = "";
        giftName = "";
        giftBigImgUrl = "";
        giftSmallImgUrl = "";
        giftNum = 0;
        validTime = 0;
        roomId = "";

    }
    
    virtual ~ZBHttpBookingPrivateInviteItem() {
        
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
    ZBBookingReplyType replyType;
    long        bookTime;
    string      giftId;
    string      giftName;
    string      giftBigImgUrl;
    string      giftSmallImgUrl;
    int         giftNum;
    int         validTime;
    string      roomId;
};

typedef list<ZBHttpBookingPrivateInviteItem> ZBBookingPrivateInviteItemList;

#endif /* ZBHTTPBOOKINPRIVATEINVITEITEM_H_*/
