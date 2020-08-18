/*
 * HttpPremiumVideoBaseInfoItem.h
 *
 *  Created on: 2020-08-03
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPPREMIUMVIDEOBASEINFOITEM_H_
#define HTTPPREMIUMVIDEOBASEINFOITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"

class HttpPremiumVideoBaseInfoItem {
public:
	void Parse(const Json::Value& root) {
		if( root.isObject() ) {
            
            /* anchorId */
            if (root[LIVEROOM_PREMIUMVIDEO_ANCHOR_ID].isString()) {
                anchorId = root[LIVEROOM_PREMIUMVIDEO_ANCHOR_ID].asString();
            }
            
            /* anchorAge */
            if( root[LIVEROOM_PREMIUMVIDEO_ANCHOR_AGE].isNumeric() ) {
                anchorAge = root[LIVEROOM_PREMIUMVIDEO_ANCHOR_AGE].asInt();
            }
            
            /* anchorNickname */
            if (root[LIVEROOM_PREMIUMVIDEO_ANCHOR_NICKNAME].isString()) {
                anchorNickname = root[LIVEROOM_PREMIUMVIDEO_ANCHOR_NICKNAME].asString();
            }
            
            /* anchorAvatarImg */
            if (root[LIVEROOM_PREMIUMVIDEO_ANCHOR_AVATAR_IMG].isString()) {
                anchorAvatarImg = root[LIVEROOM_PREMIUMVIDEO_ANCHOR_AVATAR_IMG].asString();
            }
            
            /* onlineStatus */
            if( root[LIVEROOM_PREMIUMVIDEO_ONLINE_STATUS].isNumeric() ) {
                onlineStatus = root[LIVEROOM_PREMIUMVIDEO_ONLINE_STATUS].asInt() == 1 ? true : false;
            }
            
            /* videoId */
            if (root[LIVEROOM_PREMIUMVIDEO_VIDEO_ID].isString()) {
                videoId = root[LIVEROOM_PREMIUMVIDEO_VIDEO_ID].asString();
            }
            
            /* title */
            if (root[LIVEROOM_PREMIUMVIDEO_TITLE].isString()) {
                title = root[LIVEROOM_PREMIUMVIDEO_TITLE].asString();
            }
            
            /* description */
            if (root[LIVEROOM_PREMIUMVIDEO_DESCRIPTION].isString()) {
                description = root[LIVEROOM_PREMIUMVIDEO_DESCRIPTION].asString();
            }
            
            /* duration */
            if( root[LIVEROOM_PREMIUMVIDEO_DURATION].isNumeric() ) {
                duration = root[LIVEROOM_PREMIUMVIDEO_DURATION].asInt();
            }
            
            /* coverUrlPng */
            if (root[LIVEROOM_PREMIUMVIDEO_COVER_URL_PNG].isString()) {
                coverUrlPng = root[LIVEROOM_PREMIUMVIDEO_COVER_URL_PNG].asString();
            }
            
            /* coverUrlGif */
            if (root[LIVEROOM_PREMIUMVIDEO_COVER_URL_GIF].isString()) {
                coverUrlGif = root[LIVEROOM_PREMIUMVIDEO_COVER_URL_GIF].asString();
            }
            
            /* isInterested */
            if( root[LIVEROOM_PREMIUMVIDEO_IS_INTERSTED].isNumeric() ) {
                isInterested = root[LIVEROOM_PREMIUMVIDEO_IS_INTERSTED].asInt() == 1 ? true : false;
            }
            
        }
	}

	HttpPremiumVideoBaseInfoItem() {
		anchorId = "";
		anchorAge = 0;
        anchorNickname = "";
        anchorAvatarImg = "";
        onlineStatus = false;
        videoId = "";
        title = "";
        description = "";
        duration = 0;
        coverUrlPng = "";
        coverUrlGif = "";
        isInterested = false;
	}

	virtual ~HttpPremiumVideoBaseInfoItem() {

	}
    /**
     * 付费视频基本信息结构体
     * anchorId                     主播ID
     * anchorAge                 主播年龄
     * anchorNickname       主播昵称
     * anchorAvatarImg       主播头像
     * onlineStatus             是否在线
     * videoId                      视频ID
     * title                            视频标题
     * description                视频描述
     * duration                     视频时长(单位:秒)
     * coverUrlPng              视频png封面地址
     * coverUrlGif               视频gif封面地址
     * isInterested             是否感兴趣
     */

    string anchorId;
    int anchorAge;
    string anchorNickname;
    string anchorAvatarImg;
    bool onlineStatus;
    string videoId;
    string title;
    string description;
    int duration;
    string coverUrlPng;
    string coverUrlGif;
    bool isInterested;

};

typedef list<HttpPremiumVideoBaseInfoItem> PremiumVideoBaseInfoList;

#endif /* HTTPPREMIUMVIDEOBASEINFOITEM_H_ */
