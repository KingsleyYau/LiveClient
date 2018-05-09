/*
 * IMRecvHangoutGiftItem.h
 *
 *  Created on: 2018-04-13
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef IMRECVHANGOUTGIFTITEM_H_
#define IMRECVHANGOUTGIFTITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#define IMRECVHANGOUTGIFTITEM_ROOMID_PARAM               "roomid"
#define IMRECVHANGOUTGIFTITEM_FROMID_PARAM               "fromid"
#define IMRECVHANGOUTGIFTITEM_NICKNAME_PARAM             "nickname"
#define IMRECVHANGOUTGIFTITEM_TOUID_PARAM                "to_uid"
#define IMRECVHANGOUTGIFTITEM_ISPRIVATE_PARAM            "is_private"
#define IMRECVHANGOUTGIFTITEM_GIFTID_PARAM               "giftid"
#define IMRECVHANGOUTGIFTITEM_GIFTNAME_PARAM             "giftname"
#define IMRECVHANGOUTGIFTITEM_GIFTNUM_PARAM              "giftnum"
#define IMRECVHANGOUTGIFTITEM_MULTICLICK_PARAM           "multi_click"
#define IMRECVHANGOUTGIFTITEM_MULTICLICKSTART_PARAM      "multi_click_start"
#define IMRECVHANGOUTGIFTITEM_MULTICLICKEND_PARAM        "multi_click_end"
#define IMRECVHANGOUTGIFTITEM_MULTICLICKID_PARAM         "multi_click_id"

class IMRecvHangoutGiftItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* roomId */
            if (root[IMRECVHANGOUTGIFTITEM_ROOMID_PARAM].isString()) {
                roomId = root[IMRECVHANGOUTGIFTITEM_ROOMID_PARAM].asString();
            }
            /* fromId */
            if (root[IMRECVHANGOUTGIFTITEM_FROMID_PARAM].isString()) {
                fromId = root[IMRECVHANGOUTGIFTITEM_FROMID_PARAM].asString();
            }
            /* nickName */
            if (root[IMRECVHANGOUTGIFTITEM_NICKNAME_PARAM].isString()) {
                nickName = root[IMRECVHANGOUTGIFTITEM_NICKNAME_PARAM].asString();
            }
            /* toUid */
            if (root[IMRECVHANGOUTGIFTITEM_TOUID_PARAM].isString()) {
                toUid = root[IMRECVHANGOUTGIFTITEM_TOUID_PARAM].asString();
            }
            /* isPrivate */
            if (root[IMRECVHANGOUTGIFTITEM_ISPRIVATE_PARAM].isNumeric()) {
                isPrivate = root[IMRECVHANGOUTGIFTITEM_ISPRIVATE_PARAM].asInt() == 0 ? false : true;
            }
            /* giftId */
            if (root[IMRECVHANGOUTGIFTITEM_GIFTID_PARAM].isString()) {
                giftId = root[IMRECVHANGOUTGIFTITEM_GIFTID_PARAM].asString();
            }

            /* giftName */
            if (root[IMRECVHANGOUTGIFTITEM_GIFTNAME_PARAM].isString()) {
                giftName = root[IMRECVHANGOUTGIFTITEM_GIFTNAME_PARAM].asString();
            }
            /* giftNum */
            if (root[IMRECVHANGOUTGIFTITEM_GIFTNUM_PARAM].isNumeric()) {
                giftNum = root[IMRECVHANGOUTGIFTITEM_GIFTNUM_PARAM].asInt();
            }
            /* isMultiClick */
            if (root[IMRECVHANGOUTGIFTITEM_MULTICLICK_PARAM].isNumeric()) {
                isMultiClick = root[IMRECVHANGOUTGIFTITEM_MULTICLICK_PARAM].asInt() == 0 ? false : true;
            }
            /* multiClickStart */
            if (root[IMRECVHANGOUTGIFTITEM_MULTICLICKSTART_PARAM].isNumeric()) {
                multiClickStart = root[IMRECVHANGOUTGIFTITEM_MULTICLICKSTART_PARAM].asInt();
            }
            /* multiClickEnd */
            if (root[IMRECVHANGOUTGIFTITEM_MULTICLICKEND_PARAM].isNumeric()) {
                multiClickEnd = root[IMRECVHANGOUTGIFTITEM_MULTICLICKEND_PARAM].asInt();
            }
            /* multiClickId */
            if (root[IMRECVHANGOUTGIFTITEM_MULTICLICKID_PARAM].isNumeric()) {
                multiClickId = root[IMRECVHANGOUTGIFTITEM_MULTICLICKID_PARAM].asInt();
            }
            result = true;
        }
        return result;
    }
    
    IMRecvHangoutGiftItem() {
        roomId = "";
        fromId = "";
        nickName = "";
        toUid = "";
        isPrivate = false;
        giftId = "";
        giftName = "";
        giftNum = 0;
        isMultiClick = false;
        multiClickStart = 0;
        multiClickEnd = 0;
        multiClickId = 0;
    }
    
    virtual ~IMRecvHangoutGiftItem() {
        
    }
    /**
     * 观众端/主播端接收直播间礼物信息
     * @roomId              直播间ID
     * @fromId              发送方的用户ID
     * @nickName            发送方的昵称
     * @toUid               接收者ID（可无，无则表示发送给所有人）
     * isPrivate            是否私密发送（1：是，0：否）
     * @giftId              礼物ID
     * @giftName            礼物名称
     * @giftNum             本次发送礼物的数量
     * @isMultiClick        是否连击礼物（1：是，0：否）
     * @multiClickStart     连击起始数（整型）（可无，multi_click=0则无）
     * @multiClickEnd       连击结束数（整型）（可无，multi_click=0则无）
     * @multiClickId        连击ID，相同则表示是同一次连击（整型）（可无，multi_click=0则无）
     */
    string                      roomId;
    string                      fromId;
    string                      nickName;
    string                      toUid;
    bool                        isPrivate;
    string                      giftId;
    string                      giftName;
    int                         giftNum;
    bool                        isMultiClick;
    int                         multiClickStart;
    int                         multiClickEnd;
    int                         multiClickId;

};



#endif /* IMRECVHANGOUTGIFTITEM_H_*/
