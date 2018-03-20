/*
 * ZBHttpGiftInfoItem.h
 *
 *  Created on: 2018-2-27
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef ZBHTTPGIFTINFOITEM_H_
#define ZBHTTPGIFTINFOITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../ZBHttpLoginProtocol.h"
#include "../ZBHttpRequestEnum.h"

typedef list<int> SendNumList;
class ZBHttpGiftInfoItem {
public:
    void Parse(const Json::Value& root) {
        if( root.isObject() ) {
            /* giftId */
            if( root[GETALLGIFTLIST_LIST_ID].isString() ) {
                giftId = root[GETALLGIFTLIST_LIST_ID].asString();
            }
            
            /* name */
            if( root[GETALLGIFTLIST_LIST_NAME].isString() ) {
                name = root[GETALLGIFTLIST_LIST_NAME].asString();
            }
            
            /* smallImgUrl */
            if( root[GETALLGIFTLIST_LIST_SMALLIMGURL].isString() ) {
                smallImgUrl = root[GETALLGIFTLIST_LIST_SMALLIMGURL].asString();
            }
            
            /* middleImgUrl */
            if( root[GETALLGIFTLIST_LIST_MIDDLEIMGURL].isString() ) {
                middleImgUrl = root[GETALLGIFTLIST_LIST_MIDDLEIMGURL].asString();
            }
            
            /* bigImgUrl */
            if( root[GETALLGIFTLIST_LIST_BIGIMGURL].isString() ) {
                bigImgUrl = root[GETALLGIFTLIST_LIST_BIGIMGURL].asString();
            }
            
            /* srcFlashUrl */
            if( root[GETALLGIFTLIST_LIST_SRCFLASEURL].isString() ) {
                srcFlashUrl = root[GETALLGIFTLIST_LIST_SRCFLASEURL].asString();
            }
            
            /* srcwebpUrl */
            if( root[GETALLGIFTLIST_LIST_SRCWEBPURL].isString() ) {
                srcwebpUrl = root[GETALLGIFTLIST_LIST_SRCWEBPURL].asString();
            }
            
            /* credit */
            if( root[GETALLGIFTLIST_LIST_CREDIT].isNumeric()) {
                credit = root[GETALLGIFTLIST_LIST_CREDIT].asDouble();
            }
            
            /* multiClick */
            if( root[GETALLGIFTLIST_LIST_MULTI_CLICK].isInt() ) {
                multiClick = root[GETALLGIFTLIST_LIST_MULTI_CLICK].asInt() == 1 ? true : false;
            }
            
            /* type */
            if( root[GETALLGIFTLIST_LIST_TYPE].isInt() ) {
                type = (ZBGiftType)root[GETALLGIFTLIST_LIST_TYPE].asInt();
            }
            
            /* level */
            if( root[GETALLGIFTLIST_LIST_LEVEL].isInt() ) {
                level = root[GETALLGIFTLIST_LIST_LEVEL].asInt();
            }
 
            /* loveLevel */
            if( root[GETALLGIFTLIST_LIST_LOVELEVEL].isInt() ) {
                loveLevel = root[GETALLGIFTLIST_LIST_LOVELEVEL].asInt();
            }
            
            /* sendNumList */
            if (root[GETALLGIFTLIST_LIST_SENDNUMLIST].isArray()) {
                for (int i = 0; i < root[GETALLGIFTLIST_LIST_SENDNUMLIST].size(); i++) {
                    Json::Value element = root[GETALLGIFTLIST_LIST_SENDNUMLIST].get(i, Json::Value::null);
                    if (element.isObject()) {
                        if ( element[GETALLGIFTLIST_LIST_SENDNUMLIST_NUM].isInt() ) {
                            sendNumList.push_back(element[GETALLGIFTLIST_LIST_SENDNUMLIST_NUM].asInt());
                        }
                    }
                }
            }
            
            /* update_time */
            if( root[GETALLGIFTLIST_LIST_UPDATE_TIME].isIntegral() ) {
                updateTime = root[GETALLGIFTLIST_LIST_UPDATE_TIME].asInt();
            }
            
            /* playTime */
            if( root[GETALLGIFTLIST_LISTPLAY_TIME].isIntegral() ) {
                playTime = root[GETALLGIFTLIST_LISTPLAY_TIME].asInt();
            }
        }
    }
    
    ZBHttpGiftInfoItem() {
        giftId = "";
        name = "";
        smallImgUrl = "";
        middleImgUrl = "";
        bigImgUrl = "";
        srcFlashUrl = "";
        srcwebpUrl = "";
        credit = 0.0;
        multiClick = false;
        type = ZBGIFTTYPE_UNKNOWN;
        level = 0;
        loveLevel = 0;
        updateTime = 0;
        playTime = 0;
    }
    
    virtual ~ZBHttpGiftInfoItem() {
        
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
    ZBGiftType     type;
    int          level;
    int          loveLevel;
    SendNumList  sendNumList;
    long         updateTime;
    int          playTime;
};

typedef list<ZBHttpGiftInfoItem> ZBGiftItemList;

#endif /* ZBHTTPGIFTINFOITEM_H__*/
