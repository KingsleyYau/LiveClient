/*
 * IMAnchorRecvGiftItem.h
 *
 *  Created on: 2018-04-10
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef IMANCHORRECVGIFTITEM_H_
#define IMANCHORRECVGIFTITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "IMAnchorUserInfoItem.h"
#include "AnchorGiftNumItem.h"

#define IMANCHORRECVGIFTITEM_ROOMID_PARAM               "roomid"
#define IMANCHORRECVGIFTITEM_FROMID_PARAM               "fromid"
#define IMANCHORRECVGIFTITEM_NICKNAME_PARAM             "nickname"
#define IMANCHORRECVGIFTITEM_TOUID_PARAM                "to_uid"
#define IMANCHORRECVGIFTITEM_ISPRIVATE_PARAM            "is_private"
#define IMANCHORRECVGIFTITEM_GIFTID_PARAM               "giftid"
#define IMANCHORRECVGIFTITEM_GIFTNAME_PARAM             "giftname"
#define IMANCHORRECVGIFTITEM_GIFTNUM_PARAM              "giftnum"
#define IMANCHORRECVGIFTITEM_MULTICLICK_PARAM           "multi_click"
#define IMANCHORRECVGIFTITEM_MULTICLICKSTART_PARAM      "multi_click_start"
#define IMANCHORRECVGIFTITEM_MULTICLICKEND_PARAM        "multi_click_end"
#define IMANCHORRECVGIFTITEM_MULTICLICKID_PARAM         "multi_click_id"

class IMAnchorRecvGiftItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* roomId */
            if (root[IMANCHORRECVGIFTITEM_ROOMID_PARAM].isString()) {
                roomId = root[IMANCHORRECVGIFTITEM_ROOMID_PARAM].asString();
            }
            /* fromId */
            if (root[IMANCHORRECVGIFTITEM_FROMID_PARAM].isString()) {
                fromId = root[IMANCHORRECVGIFTITEM_FROMID_PARAM].asString();
            }
            /* nickName */
            if (root[IMANCHORRECVGIFTITEM_NICKNAME_PARAM].isString()) {
                nickName = root[IMANCHORRECVGIFTITEM_NICKNAME_PARAM].asString();
            }
            /* toUid */
            if (root[IMANCHORRECVGIFTITEM_TOUID_PARAM].isString()) {
                toUid = root[IMANCHORRECVGIFTITEM_TOUID_PARAM].asString();
            }
            /* isPrivate */
            if (root[IMANCHORRECVGIFTITEM_ISPRIVATE_PARAM].isNumeric()) {
                isPrivate = root[IMANCHORRECVGIFTITEM_ISPRIVATE_PARAM].asInt() == 0 ? false : true;
            }
            /* giftId */
            if (root[IMANCHORRECVGIFTITEM_GIFTID_PARAM].isString()) {
                giftId = root[IMANCHORRECVGIFTITEM_GIFTID_PARAM].asString();
            }
            /* giftName */
            if (root[IMANCHORRECVGIFTITEM_GIFTNAME_PARAM].isString()) {
                giftName = root[IMANCHORRECVGIFTITEM_GIFTNAME_PARAM].asString();
            }
            /* giftNum */
            if (root[IMANCHORRECVGIFTITEM_GIFTNUM_PARAM].isNumeric()) {
                giftNum = root[IMANCHORRECVGIFTITEM_GIFTNUM_PARAM].asInt();
            }
            /* isMultiClick */
            if (root[IMANCHORRECVGIFTITEM_MULTICLICK_PARAM].isNumeric()) {
                isMultiClick = root[IMANCHORRECVGIFTITEM_MULTICLICK_PARAM].asInt() == 0 ? false : true;
            }
            /* multiClickStart */
            if (root[IMANCHORRECVGIFTITEM_MULTICLICKSTART_PARAM].isNumeric()) {
                multiClickStart = root[IMANCHORRECVGIFTITEM_MULTICLICKSTART_PARAM].asInt();
            }
            /* multiClickEnd */
            if (root[IMANCHORRECVGIFTITEM_MULTICLICKEND_PARAM].isNumeric()) {
                multiClickEnd = root[IMANCHORRECVGIFTITEM_MULTICLICKEND_PARAM].asInt();
            }
            /* multiClickId */
            if (root[IMANCHORRECVGIFTITEM_MULTICLICKID_PARAM].isNumeric()) {
                multiClickId = root[IMANCHORRECVGIFTITEM_MULTICLICKID_PARAM].asInt();
            }
            result = true;
        }
        return result;
    }
    
    IMAnchorRecvGiftItem() {
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
    
    virtual ~IMAnchorRecvGiftItem() {
        
    }
    /**
     * 观众端/主播端接收直播间礼物信息
     * @roomId              直播间ID
     * @fromId              发送方的用户ID
     * @nickName            发送方的昵称
     * @toUid               接收者ID（可无，无则表示发送给所有人）
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



#endif /* IMANCHORRECVGIFTITEM_H_*/
