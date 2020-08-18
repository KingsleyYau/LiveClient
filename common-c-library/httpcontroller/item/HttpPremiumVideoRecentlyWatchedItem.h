/*
 * HttpPremiumVideoRecentlyWatchedItem.h
 *
 *  Created on: 2020-08-05
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPPREMIUMVIDEORECENTLYWATCHEDITEM_H_
#define HTTPPREMIUMVIDEORECENTLYWATCHEDITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

//#include "../HttpLoginProtocol.h"
#include "HttpPremiumVideoBaseInfoItem.h"

class HttpPremiumVideoRecentlyWatchedItem {
public:
	void Parse(const Json::Value& root) {
		if( root.isObject() ) {
            /* watchedId */
            if (root[LIVEROOM_PREMIUMVIDEO_WATCHED_ID].isString()) {
                watchedId = root[LIVEROOM_PREMIUMVIDEO_WATCHED_ID].asString();
            }
            
            premiumVideoInfo.Parse(root);
            
//            /* anchorId */
//            if (root[LIVEROOM_PREMIUMVIDEO_ANCHOR_ID].isString()) {
//                anchorId = root[LIVEROOM_PREMIUMVIDEO_ANCHOR_ID].asString();
//            }
//
//            /* anchorAge */
//            if( root[LIVEROOM_PREMIUMVIDEO_ANCHOR_AGE].isNumeric() ) {
//                anchorAge = root[LIVEROOM_PREMIUMVIDEO_ANCHOR_AGE].asInt();
//            }
//
//            /* anchorNickname */
//            if (root[LIVEROOM_PREMIUMVIDEO_ANCHOR_NICKNAME].isString()) {
//                anchorNickname = root[LIVEROOM_PREMIUMVIDEO_ANCHOR_NICKNAME].asString();
//            }
//
//            /* anchorAvatarImg */
//            if (root[LIVEROOM_PREMIUMVIDEO_ANCHOR_AVATAR_IMG].isString()) {
//                anchorAvatarImg = root[LIVEROOM_PREMIUMVIDEO_ANCHOR_AVATAR_IMG].asString();
//            }
//
//            /* videoId */
//            if (root[LIVEROOM_PREMIUMVIDEO_VIDEO_ID].isString()) {
//                videoId = root[LIVEROOM_PREMIUMVIDEO_VIDEO_ID].asString();
//            }
//
//            /* title */
//            if (root[LIVEROOM_PREMIUMVIDEO_TITLE].isString()) {
//                title = root[LIVEROOM_PREMIUMVIDEO_TITLE].asString();
//            }
//
//            /* description */
//            if (root[LIVEROOM_PREMIUMVIDEO_DESCRIPTION].isString()) {
//                description = root[LIVEROOM_PREMIUMVIDEO_DESCRIPTION].asString();
//            }
//
//            /* duration */
//            if( root[LIVEROOM_PREMIUMVIDEO_DURATION].isNumeric() ) {
//                duration = root[LIVEROOM_PREMIUMVIDEO_DURATION].asInt();
//            }
//
//            /* coverUrlPng */
//            if (root[LIVEROOM_PREMIUMVIDEO_COVER_URL_PNG].isString()) {
//                coverUrlPng = root[LIVEROOM_PREMIUMVIDEO_COVER_URL_PNG].asString();
//            }
//
//            /* coverUrlGif */
//            if (root[LIVEROOM_PREMIUMVIDEO_COVER_URL_GIF].isString()) {
//                coverUrlGif = root[LIVEROOM_PREMIUMVIDEO_COVER_URL_GIF].asString();
//            }
//
//            /* isInterested */
//            if( root[LIVEROOM_PREMIUMVIDEO_IS_INTERSTED].isNumeric() ) {
//                isInterested = root[LIVEROOM_PREMIUMVIDEO_IS_INTERSTED].asInt() == 1 ? true : false;
//            }
            
            
            /* addTime */
            if (root[LIVEROOM_PREMIUMVIDEO_ADD_TIME].isNumeric()) {
                addTime = root[LIVEROOM_PREMIUMVIDEO_ADD_TIME].asLong();
            }
            
        }
	}

	HttpPremiumVideoRecentlyWatchedItem() {
        watchedId = "";
//		anchorId = "";
//		anchorAge = 0;
//        anchorNickname = "";
//        anchorAvatarImg = "";
//        videoId = "";
//        title = "";
//        description = "";
//        duration = 0;
//        coverUrlPng = "";
//        coverUrlGif = "";
//        isInterested = false;
        addTime = 0;
	}

	virtual ~HttpPremiumVideoRecentlyWatchedItem() {

	}
    /**
     * 最近播放的视频信息结构体
     * watchedId                    记录ID
     * anchorId                     主播ID
     * anchorAge                 主播年龄
     * anchorNickname       主播昵称
     * anchorAvatarImg       主播头像
     * videoId                      视频ID
     * title                            视频标题
     * description                视频描述
     * duration                     视频时长(单位:秒)
     * coverUrlPng              视频png封面地址
     * coverUrlGif               视频gif封面地址
     * isInterested             是否感兴趣
     * addTime                  添加时间(GMT时间戳)
     */

    string watchedId;
//    string anchorId;
//    int anchorAge;
//    string anchorNickname;
//    string anchorAvatarImg;
//    string videoId;
//    string title;
//    string description;
//    int duration;
//    string coverUrlPng;
//    string coverUrlGif;
//    bool isInterested;
    HttpPremiumVideoBaseInfoItem premiumVideoInfo;
    long long addTime;

};

typedef list<HttpPremiumVideoRecentlyWatchedItem> PremiumVideoRecentlyWatchedList;

#endif /* HTTPPREMIUMVIDEORECENTLYWATCHEDITEM_H_ */
