/*
 * IMAnchorRecommendHangoutItem.h
 *
 *  Created on: 2018-04-09
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef IMANCHORRECOMMENDHANGOUTITEM_H_
#define IMANCHORRECOMMENDHANGOUTITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#define IMANCHORRECOMMENDHANGOU_ROOMID_PARAM                "room_id"
#define IMANCHORRECOMMENDHANGOU_ANCHORID_PARAM              "anchor_id"
#define IMANCHORRECOMMENDHANGOU_NICKNAME_PARAM              "nickname"
#define IMANCHORRECOMMENDHANGOU_PHOTOURL_PARAM              "photourl"
#define IMANCHORRECOMMENDHANGOU_FRIENDID_PARAM              "friend_id"
#define IMANCHORRECOMMENDHANGOU_FRIENDNICKNAME_PARAM        "friend_nickname"
#define IMANCHORRECOMMENDHANGOU_FRIENDPHOTOURL_PARAM        "friend_photourl"
#define IMANCHORRECOMMENDHANGOU_FRIENDAGE_PARAM             "friend_age"
#define IMANCHORRECOMMENDHANGOU_FRIENDCOUNTRY_PARAM         "friend_country"
#define IMANCHORRECOMMENDHANGOU_RECOMMENDID_PARAM           "recommend_id"


class IMAnchorRecommendHangoutItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* roomId */
            if (root[IMANCHORRECOMMENDHANGOU_ROOMID_PARAM].isString()) {
                roomId = root[IMANCHORRECOMMENDHANGOU_ROOMID_PARAM].asString();
            }
            /* anchorId */
            if (root[IMANCHORRECOMMENDHANGOU_ANCHORID_PARAM].isString()) {
                anchorId = root[IMANCHORRECOMMENDHANGOU_ANCHORID_PARAM].asString();
            }
            /* nickName */
            if (root[IMANCHORRECOMMENDHANGOU_NICKNAME_PARAM].isString()) {
                nickName = root[IMANCHORRECOMMENDHANGOU_NICKNAME_PARAM].asString();
            }
            /* photoUrl */
            if (root[IMANCHORRECOMMENDHANGOU_PHOTOURL_PARAM].isString()) {
                photoUrl = root[IMANCHORRECOMMENDHANGOU_PHOTOURL_PARAM].asString();
            }
           
            /* friendId */
            if (root[IMANCHORRECOMMENDHANGOU_FRIENDID_PARAM].isString()) {
                friendId = root[IMANCHORRECOMMENDHANGOU_FRIENDID_PARAM].asString();
            }
            /* friendNickName */
            if (root[IMANCHORRECOMMENDHANGOU_FRIENDNICKNAME_PARAM].isString()) {
                friendNickName = root[IMANCHORRECOMMENDHANGOU_FRIENDNICKNAME_PARAM].asString();
            }
            /* friendPhotoUrl */
            if (root[IMANCHORRECOMMENDHANGOU_FRIENDPHOTOURL_PARAM].isString()) {
                friendPhotoUrl = root[IMANCHORRECOMMENDHANGOU_FRIENDPHOTOURL_PARAM].asString();
            }
            /* friendAge */
            if (root[IMANCHORRECOMMENDHANGOU_FRIENDAGE_PARAM].isNumeric()) {
                friendAge = root[IMANCHORRECOMMENDHANGOU_FRIENDAGE_PARAM].asInt();
            }
            
            /* friendCountry */
            if (root[IMANCHORRECOMMENDHANGOU_FRIENDCOUNTRY_PARAM].isString()) {
                friendCountry = root[IMANCHORRECOMMENDHANGOU_FRIENDCOUNTRY_PARAM].asString();
            }
            
            /* recommendId */
            if (root[IMANCHORRECOMMENDHANGOU_RECOMMENDID_PARAM].isString()) {
                recommendId = root[IMANCHORRECOMMENDHANGOU_RECOMMENDID_PARAM].asString();
            }
            
            result = true;
        }
        return result;
    }
    
    IMAnchorRecommendHangoutItem() {
        roomId = "";
        anchorId = "";
        nickName = "";
        photoUrl = "";
        friendId = "";
        friendNickName = "";
        friendPhotoUrl = "";
        friendAge = 0;
        friendCountry = "";
        recommendId = "";
    }
    
    virtual ~IMAnchorRecommendHangoutItem() {
        
    }
    /**
     * 推荐好友信息
     * @roomId              直播间ID
     * @anchorId            主播ID
     * @nickName            主播昵称
     * @photoUrl            主播头像
     * @friendId            主播好友ID
     * @friendNickName      主播好友昵称
     * @friendPhotoUrl      主播好友头像
     * @friendAge           年龄
     * @friendCountry       国家
     * @recommendId         邀请ID
     */
    string                      roomId;
    string                      anchorId;
    string                      nickName;
    string                      photoUrl;
    string                      friendId;
    string                      friendNickName;
    string                      friendPhotoUrl;
    int                         friendAge;
    string                      friendCountry;
    string                      recommendId;

};

#endif /* IMANCHORRECOMMENDHANGOUTITEM_H_*/
