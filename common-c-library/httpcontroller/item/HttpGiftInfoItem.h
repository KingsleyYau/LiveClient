/*
 * HttpGiftInfoItem.h
 *
 *  Created on: 2017-8-16
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPGIFTINFOITEM_H_
#define HTTPGIFTINFOITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"

typedef list<int> SendNumList;
class HttpGiftInfoItem {
public:
    void Parse(const Json::Value& root) {
        if( root.isObject() ) {
            /* giftId */
            if( root[LIVEROOM_GIFTINFO_ID].isString() ) {
                giftId = root[LIVEROOM_GIFTINFO_ID].asString();
            }
            
            /* name */
            if( root[LIVEROOM_GIFTINFO_NAME].isString() ) {
                name = root[LIVEROOM_GIFTINFO_NAME].asString();
            }
            
            /* smallImgUrl */
            if( root[LIVEROOM_GIFTINFO_SMALLIMGURL].isString() ) {
                smallImgUrl = root[LIVEROOM_GIFTINFO_SMALLIMGURL].asString();
            }
            
            /* middleImgUrl */
            if( root[LIVEROOM_GIFTINFO_MIDDLEIMGURL].isString() ) {
                middleImgUrl = root[LIVEROOM_GIFTINFO_MIDDLEIMGURL].asString();
            }
            
            /* bigImgUrl */
            if( root[LIVEROOM_GIFTINFO_BIGIMGURL].isString() ) {
                bigImgUrl = root[LIVEROOM_GIFTINFO_BIGIMGURL].asString();
            }
            
            /* srcFlashUrl */
            if( root[LIVEROOM_GIFTINFO_SRCFLASEURL].isString() ) {
                srcFlashUrl = root[LIVEROOM_GIFTINFO_SRCFLASEURL].asString();
            }
            
            /* srcwebpUrl */
            if( root[LIVEROOM_GIFTINFO_SRCWEBPURL].isString() ) {
                srcwebpUrl = root[LIVEROOM_GIFTINFO_SRCWEBPURL].asString();
            }
            
            /* credit */
            if( root[LIVEROOM_GIFTINFO_CREDIT].isNumeric()) {
                credit = root[LIVEROOM_GIFTINFO_CREDIT].asDouble();
            }
            
            /* multiClick */
            if( root[LIVEROOM_GIFTINFO_MULTI_CLICK].isInt() ) {
                multiClick = root[LIVEROOM_GIFTINFO_MULTI_CLICK].asInt() == 1 ? true : false;
            }
            
            /* type */
            if( root[LIVEROOM_GIFTINFO_TYPE].isInt() ) {
                type = (GiftType)root[LIVEROOM_GIFTINFO_TYPE].asInt();
            }
            
            /* level */
            if( root[LIVEROOM_GIFTINFO_LEVEL].isInt() ) {
                level = root[LIVEROOM_GIFTINFO_LEVEL].asInt();
            }
 
            /* loveLevel */
            if( root[LIVEROOM_GIFTINFO_LOVELEVEL].isInt() ) {
                loveLevel = root[LIVEROOM_GIFTINFO_LOVELEVEL].asInt();
            }
            
            /* sendNumList */
            if (root[LIVEROOM_GIFTINFO_SENDNUMLIST].isArray()) {
                for (int i = 0; i < root[LIVEROOM_GIFTINFO_SENDNUMLIST].size(); i++) {
                    Json::Value element = root[LIVEROOM_GIFTINFO_SENDNUMLIST].get(i, Json::Value::null);
                    if (element.isObject()) {
                        if ( element[LIVEROOM_GIFTINFO_SENDNUMLIST_NUM].isInt() ) {
                            sendNumList.push_back(element[LIVEROOM_GIFTINFO_SENDNUMLIST_NUM].asInt());
                        }
                    }
                }
            }
            
            /* update_time */
            if( root[LIVEROOM_GIFTINFO_UPDATE_TIME].isIntegral() ) {
                updateTime = root[LIVEROOM_GIFTINFO_UPDATE_TIME].asInt();
            }
            
            /* playTime */
            if( root[LIVEROOM_GIFTINFO_PLAY_TIME].isIntegral() ) {
                playTime = root[LIVEROOM_GIFTINFO_PLAY_TIME].asInt();
            }
        }
    }
    
    HttpGiftInfoItem() {
        giftId = "";
        name = "";
        smallImgUrl = "";
        middleImgUrl = "";
        bigImgUrl = "";
        srcFlashUrl = "";
        srcwebpUrl = "";
        credit = 0.0;
        multiClick = false;
        type = GIFTTYPE_UNKNOWN;
        level = 0;
        loveLevel = 0;
        updateTime = 0;
        playTime = 0;
    }
    
    virtual ~HttpGiftInfoItem() {
        
    }
    
    /**
     * 获取礼物列表成功结构体
     * giftId			礼物ID
     * name				礼物名字
     * smallImgUrl       礼物小图标（用于文本聊天窗显示）
     * middleImgUrl      礼物中图标（用于发送列表显示）
     * bigImgUrl         礼物大图标（用于播放连击显示）
     * srcFlashUrl	    礼物在直播间显示／播放的flash资源url
     * srcwebpUrl		礼物在直播间显示／播放的webp资源url
     * credit		    发送礼物所需的信用点
     * multiClick		是否可连击（1：是 0:否， ，默认：0 ） （仅type ＝ 1有效）
     * type			    礼物类型（1: 普通礼物 2：高级礼物（动画））
     * level			    发送礼物的用户限制等级，发送者等级>= 礼物等级才能发送
     * loveLevel			发送礼物的亲密度限制，发送者亲密度>= 礼物亲密度才能发送
     * sendNumList       发送可选数量列表
     * updateTime		礼物最后更新时间戳（1970年起的秒数）
     * playTime         大礼物的swf播放时长（毫秒）
     */
    string       giftId;
    string       name;
    string       smallImgUrl;
    string       middleImgUrl;
    string       bigImgUrl;
    string       srcFlashUrl;
    string       srcwebpUrl;
    double       credit;
    bool         multiClick;
    GiftType     type;
    int          level;
    int          loveLevel;
    SendNumList  sendNumList;
    long         updateTime;
    int          playTime;
};

typedef list<HttpGiftInfoItem> GiftItemList;

#endif /* HTTPGIFTINFOITEM_H__*/
