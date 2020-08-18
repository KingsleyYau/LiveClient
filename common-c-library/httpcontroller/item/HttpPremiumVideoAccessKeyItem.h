/*
 * HttpPremiumVideoAccessKeyItem.h
 *
 *  Created on: 2020-08-03
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPPREMIUMVIDEOACCESSKEYITEM_H_
#define HTTPPREMIUMVIDEOACCESSKEYITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

//#include "../HttpLoginProtocol.h"
#include "HttpPremiumVideoBaseInfoItem.h"

class HttpPremiumVideoAccessKeyItem {
public:
	void Parse(const Json::Value& root) {
		if( root.isObject() ) {
            /* requestId */
            if (root[LIVEROOM_PREMIUMVIDEO_REQUEST_ID].isString()) {
                requestId = root[LIVEROOM_PREMIUMVIDEO_REQUEST_ID].asString();
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
            
            /* emfId */
            if (root[LIVEROOM_PREMIUMVIDEO_EMF_ID].isString()) {
                emfId = root[LIVEROOM_PREMIUMVIDEO_EMF_ID].asString();
            }
            
            /* emfReadStatus */
            if( root[LIVEROOM_PREMIUMVIDEO_EMF_READ_STATUS].isNumeric() ) {
                emfReadStatus = root[LIVEROOM_PREMIUMVIDEO_EMF_READ_STATUS].asInt() == 1 ? true : false;
            }
            
            /* validTime */
            if (root[LIVEROOM_PREMIUMVIDEO_VALID_TIME].isNumeric()) {
                validTime = root[LIVEROOM_PREMIUMVIDEO_VALID_TIME].asLong();
            }
            
            /* lastSendTime */
            if (root[LIVEROOM_PREMIUMVIDEO_LAST_SEND_TIME].isNumeric()) {
                lastSendTime = root[LIVEROOM_PREMIUMVIDEO_LAST_SEND_TIME].asLong();
            }
            
            /* currentTime */
            if (root[LIVEROOM_PREMIUMVIDEO_CURRENT_TIME].isNumeric()) {
                currentTime = root[LIVEROOM_PREMIUMVIDEO_CURRENT_TIME].asLong();
            }
            
        }
	}

	HttpPremiumVideoAccessKeyItem() {
        requestId = "";
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
        emfId = "";
        emfReadStatus = false;
        validTime = 0;
        lastSendTime = 0;
        currentTime = 0;
	}

	virtual ~HttpPremiumVideoAccessKeyItem() {

	}
    /**
     * 付费视频解码锁信息结构体
     * requestId                    请求ID
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
     * emfId                        信件ID
     * emfReadStatus        信件是否已读（0：否，1：是）
     * validTime                解锁码有效时间(GMT时间戳)
     * lastSendTime         最后请求的时间(GMT时间戳)
     * currentTime          服务器当前时间(GMT时间戳)
     */

    string requestId;
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
    string emfId;
    bool emfReadStatus;
    long long validTime;
    long long lastSendTime;
    long long currentTime;

};

typedef list<HttpPremiumVideoAccessKeyItem> PremiumVideoAccessKeyList;

#endif /* HTTPPREMIUMVIDEOACCESSKEYITEM_H_ */
