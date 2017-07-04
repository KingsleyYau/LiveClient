/*
 * HttpLiveRoomGiftItem.h
 *
 *  Created on: 2017-5-19
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPLIVEROOMGIFTITEM_H_
#define HTTPLIVEROOMGIFTITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"


class HttpLiveRoomGiftItem {
public:
    void Parse(const Json::Value& root) {
        if( root.isObject() ) {
            /* giftId */
            if( root[LIVEROOM_PUBLIC_GIFTID].isString() ) {
                giftId = root[LIVEROOM_PUBLIC_GIFTID].asString();
            }
            
            /* name */
            if( root[LIVEROOM_GIFTNAME].isString() ) {
                name = root[LIVEROOM_GIFTNAME].asString();
            }
            
            /* smallImgUrl */
            if( root[LIVEROOM_GIFTSMALLIMGURL].isString() ) {
                smallImgUrl = root[LIVEROOM_GIFTSMALLIMGURL].asString();
            }
            
            /* imgUrl */
            if( root[LIVEROOM_GIFTIMGURL].isString() ) {
                imgUrl = root[LIVEROOM_GIFTIMGURL].asString();
            }
            
            /* srcUrl */
            if( root[LIVEROOM_GIFTSRCURL].isString() ) {
                srcUrl = root[LIVEROOM_GIFTSRCURL].asString();
            }
            
            /* coins */
            if( root[LIVEROOM_GIFTCOINS].isNumeric()) {
                coins = root[LIVEROOM_GIFTCOINS].asDouble();
            }
            
            /* isMulti_click */
            if( root[LIVEROOM_GIFTMULTI_CLICK].isInt() ) {
                isMulti_click = root[LIVEROOM_GIFTMULTI_CLICK].asInt();
            }
            
            /* type */
            if( root[LIVEROOM_GIFTTYPE].isInt() ) {
                type = (GiftType)root[LIVEROOM_GIFTTYPE].asInt();
            }
            
            /* update_time */
            if( root[LIVEROOM_GIFTUPDATE_TIME].isInt() ) {
                update_time = root[LIVEROOM_GIFTUPDATE_TIME].asInt();
            }
        }
    }
    
    /**
     * 获取礼物列表成功结构体
     * @param giftId			礼物ID
     * @param name				礼物名字
     * @param smallImgUrl       礼物小图标（用于文本聊天窗显示）
     * @param imgUrl			发送列表显示的图片url
     * @param srcUrl			礼物在直播间显示的资源url
     * @param coins		        发送礼物所需的金币
     * @param isMulti_click		是否可连击（1：是 0:否， ，默认：0 ） （仅type ＝ 1有效）
     * @param type			    礼物类型（1: 普通礼物 2：高级礼物（动画））
     * @param update_time		礼物最后更新时间戳（1970年起的秒数）
     */
    HttpLiveRoomGiftItem() {
        giftId = "";
        name = "";
        smallImgUrl = "";
        imgUrl = "";
        srcUrl = "";
        coins = 0.0;
        isMulti_click = false;
        type = GIFTTYPE_UNKNOWN;
        update_time = 0;
    }
    
    virtual ~HttpLiveRoomGiftItem() {
        
    }
    
    string   giftId;
    string   name;
    string   smallImgUrl;
    string   imgUrl;
    string   srcUrl;
    double    coins;
    bool     isMulti_click;
    GiftType type;
    int      update_time;
};

typedef list<HttpLiveRoomGiftItem> GiftItemList;

#endif /* HTTPLIVEROOMGIFTITEM_H_*/
