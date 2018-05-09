/*
 * IMRecommendHangoutItem.h
 *
 *  Created on: 2018-04-13
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef IMRECOMMENDHANGOUTITEM_H_
#define IMRECOMMENDHANGOUTITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#define IMRECOMMENDHANGOU_ROOMID_PARAM                "room_id"
#define IMRECOMMENDHANGOU_ANCHORID_PARAM              "anchor_id"
#define IMRECOMMENDHANGOU_NICKNAME_PARAM              "nickname"
#define IMRECOMMENDHANGOU_PHOTOURL_PARAM              "photourl"
#define IMRECOMMENDHANGOU_FRIENDID_PARAM              "friend_id"
#define IMRECOMMENDHANGOU_FRIENDNICKNAME_PARAM        "friend_nickname"
#define IMRECOMMENDHANGOU_FRIENDPHOTOURL_PARAM        "friend_photourl"
#define IMRECOMMENDHANGOU_FRIENDAGE_PARAM             "friend_age"
#define IMRECOMMENDHANGOU_FRIENDCOUNTRY_PARAM         "friend_country"
#define IMRECOMMENDHANGOU_RECOMMENDID_PARAM           "recommend_id"


class IMRecommendHangoutItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* roomId */
            if (root[IMRECOMMENDHANGOU_ROOMID_PARAM].isString()) {
                roomId = root[IMRECOMMENDHANGOU_ROOMID_PARAM].asString();
            }
            /* anchorId */
            if (root[IMRECOMMENDHANGOU_ANCHORID_PARAM].isString()) {
                anchorId = root[IMRECOMMENDHANGOU_ANCHORID_PARAM].asString();
            }
            /* nickName */
            if (root[IMRECOMMENDHANGOU_NICKNAME_PARAM].isString()) {
                nickName = root[IMRECOMMENDHANGOU_NICKNAME_PARAM].asString();
            }
            /* photoUrl */
            if (root[IMRECOMMENDHANGOU_PHOTOURL_PARAM].isString()) {
                photoUrl = root[IMRECOMMENDHANGOU_PHOTOURL_PARAM].asString();
            }
           
            /* friendId */
            if (root[IMRECOMMENDHANGOU_FRIENDID_PARAM].isString()) {
                friendId = root[IMRECOMMENDHANGOU_FRIENDID_PARAM].asString();
            }
            /* friendNickName */
            if (root[IMRECOMMENDHANGOU_FRIENDNICKNAME_PARAM].isString()) {
                friendNickName = root[IMRECOMMENDHANGOU_FRIENDNICKNAME_PARAM].asString();
            }
            /* friendPhotoUrl */
            if (root[IMRECOMMENDHANGOU_FRIENDPHOTOURL_PARAM].isString()) {
                friendPhotoUrl = root[IMRECOMMENDHANGOU_FRIENDPHOTOURL_PARAM].asString();
            }
            /* friendAge */
            if (root[IMRECOMMENDHANGOU_FRIENDAGE_PARAM].isNumeric()) {
                friendAge = root[IMRECOMMENDHANGOU_FRIENDAGE_PARAM].asInt();
            }
            
            /* friendCountry */
            if (root[IMRECOMMENDHANGOU_FRIENDCOUNTRY_PARAM].isString()) {
                friendCountry = root[IMRECOMMENDHANGOU_FRIENDCOUNTRY_PARAM].asString();
            }
            
            /* recommendId */
            if (root[IMRECOMMENDHANGOU_RECOMMENDID_PARAM].isString()) {
                recommendId = root[IMRECOMMENDHANGOU_RECOMMENDID_PARAM].asString();
            }
            
            result = true;
        }
        return result;
    }
    
    IMRecommendHangoutItem() {
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
    
    virtual ~IMRecommendHangoutItem() {
        
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

#endif /* IMRECOMMENDHANGOUTITEM_H_*/
