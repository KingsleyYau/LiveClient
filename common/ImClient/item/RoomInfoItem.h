/*
 * RoomInfoItem.h
 *
 *  Created on: 2017-9-05
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef ROOMINFOITEM_H_
#define ROOMINFOITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "RebateInfoItem.h"
#define USERID_PARAM           "userid"
#define NICKNAME_PARAM         "nickname"
#define PHOTOURL_PARAM         "photourl"
#define VIDEOURL_PARAM         "videourl"
#define ROOMID_PARAM		   "roomid"
#define ROOMTYPE_PARAM         "room_type"
#define CREDIT_PARAM           "credit"
#define USEDVOUCHER_PARAM      "used_voucher"
#define FANSNUM_PARAM          "fansnum"
#define EMOTYPELIST_PARAM      "emo_typelist"
#define LOVELEVEL_PARAM        "love_level"
#define REBATEINFO_PARAM       "rebate_info"
#define FAVORITE_PARAM         "favorite"
#define LEFTSECONDS_PARAM      "left_seconds"
#define WAITSTART_PARAM        "wait_start"
#define MANPUSHURL_PARAM       "man_push_url"
#define MANLEVEL_PARAM         "man_level"
#define ROOMPRICE_PARAM        "room_price"
#define MANPUSHPRICE_PARAM     "man_push_price"
#define MAXFANSINUM_PARAM      "max_fansi_num"

class RoomInfoItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            if (root[USERID_PARAM].isString()) {
                userId = root[USERID_PARAM].asString();
            }
            if (root[NICKNAME_PARAM].isString()) {
                nickName = root[NICKNAME_PARAM].asString();
            }
            if (root[PHOTOURL_PARAM].isString()) {
                photoUrl = root[PHOTOURL_PARAM].asString();
            }
            if (root[VIDEOURL_PARAM].isArray()) {
                
                for (int i = 0; i < root[VIDEOURL_PARAM].size(); i++) {
                    Json::Value element = root[VIDEOURL_PARAM].get(i, Json::Value::null);
                    if (element.isString()) {
                        videoUrl.push_back(element.asString());
                    }
                }
                
            }
            if (root[ROOMID_PARAM].isString()) {
                roomId = root[ROOMID_PARAM].asString();
            }
            if (root[ROOMTYPE_PARAM].isInt()) {
                int type = root[ROOMTYPE_PARAM].asInt();
                roomType = GetRoomType(type);
            }
            if (root[CREDIT_PARAM].isNumeric()) {
                credit = root[CREDIT_PARAM].asDouble();
            }
            if (root[USEDVOUCHER_PARAM].isInt()) {
                usedVoucher = root[USEDVOUCHER_PARAM].asInt() == 0 ? false : true;
            }
            if (root[FANSNUM_PARAM].isInt()) {
                fansNum = root[FANSNUM_PARAM].asInt();
            }
            
            if (root[EMOTYPELIST_PARAM].isArray()) {
                if (root[EMOTYPELIST_PARAM].isArray()) {
                    
                    for (int i = 0; i < root[EMOTYPELIST_PARAM].size(); i++) {
                        Json::Value element = root[EMOTYPELIST_PARAM].get(i, Json::Value::null);
                        if (element.isInt()) {
                            emoTypeList.push_back(element.asInt());
                        }
                    }
                    
                }
            }
            
            if (root[LOVELEVEL_PARAM].isInt()) {
                loveLevel = root[LOVELEVEL_PARAM].asInt();
            }
            
            if (root[REBATEINFO_PARAM].isObject()) {
                Json::Value permission = root[REBATEINFO_PARAM];
                rebateInfo.Parse(permission);
            }
            
            if (root[FAVORITE_PARAM].isInt()) {
                favorite = root[FAVORITE_PARAM].asInt() == 0 ? false : true;
            }
            if (root[LEFTSECONDS_PARAM].isInt()) {
                leftSeconds = root[LEFTSECONDS_PARAM].asInt();
            }
            if (root[WAITSTART_PARAM].isInt()) {
                waitStart = root[WAITSTART_PARAM].asInt() == 0 ? false : true;
            }
            if (root[MANPUSHURL_PARAM].isArray()) {
                
                for (int i = 0; i < root[MANPUSHURL_PARAM].size(); i++) {
                    Json::Value element = root[MANPUSHURL_PARAM].get(i, Json::Value::null);
                    if (element.isString()) {
                        manPushUrl.push_back(element.asString());
                    }
                }
                
            }
            if (root[MANLEVEL_PARAM].isInt()) {
                manlevel = root[MANLEVEL_PARAM].asInt();
            }
            if (root[ROOMPRICE_PARAM].isNumeric()) {
                roomPrice = root[ROOMPRICE_PARAM].asDouble();
            }
            
            if (root[MANPUSHPRICE_PARAM].isNumeric()) {
                manPushPrice = root[MANPUSHPRICE_PARAM].asDouble();
            }
            
            if (root[MAXFANSINUM_PARAM].isIntegral()) {
                maxFansiNum = root[MAXFANSINUM_PARAM].asInt();
            }
            
        }

        result = true;

        return result;
    }

    RoomInfoItem() {
        userId = "";
        nickName = "";
        photoUrl = "";
        roomId = "";
        roomType = ROOMTYPE_UNKNOW;
        credit = 0.0;
        usedVoucher = false;
        fansNum = 0;
        loveLevel = 0;
        favorite = false;
        leftSeconds = 0;
        waitStart = false;
        manlevel = 0;
        roomPrice = 0.0;
        manPushPrice = 0.0;
        maxFansiNum = 0;
    }
    
    virtual ~RoomInfoItem() {
        
    }
    
    /**
     * 礼物列表结构体
     * userId                   主播ID
     * nickName                 主播昵称
     * photoUrl                 主播头像url
     * videoUrl                 视频流url
     * roomId					房间Id
     * roomType                 直播间类型
     * credit                   信用点
     * usedVoucher              是否使用使用劵（0:否 1:是）
     * fansNum                  观众人数
     * emoTypeList		        可发送文本表情类型列表
     * loveLevel                亲密度等级
     * rebateInfo               返点信息
     * favorite                 是否已收藏（0:否 1:是  默认：1）（可无）
     * leftSeconds              开播前的倒数秒数（可无， 无或0表示立即开播）
     * waitStart		        是否要等开播通知（0:否 1:是 默认：0  直至收到《直播间开播通知》）
     * manPushUrl               男士视频流url
     * manlevel                 男士等级
     * roomPrice                直播间资费
     * manPushPrice             视频资费
     * maxFansiNum		        最大人数限制
     */
    string          userId;
    string          nickName;
    string          photoUrl;
    list<string>    videoUrl;
    string          roomId;
    RoomType        roomType;
    double          credit;
    bool            usedVoucher;
    int             fansNum;
    list<int>       emoTypeList;
    int             loveLevel;
    RebateInfoItem   rebateInfo;
    bool            favorite;
    int             leftSeconds;
    bool            waitStart;
    list<string>    manPushUrl;
    int             manlevel;
    double          roomPrice;
    double          manPushPrice;
    int             maxFansiNum;
};


#endif /* ROOMINFOITEM_H_*/
