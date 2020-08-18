/*
 * HttpPremiumVideoDetailItem.h
 *
 *  Created on: 2020-08-03
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPPREMIUMVIDEODETAILITEM_H_
#define HTTPPREMIUMVIDEODETAILITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "HttpPremiumVideoTypeItem.h"

class HttpPremiumVideoDetailItem {
public:
	void Parse(const Json::Value& root) {
		if( root.isObject() ) {
            
            /* anchorId */
            if (root[LIVEROOM_PREMIUMVIDEO_ANCHOR_ID].isString()) {
                anchorId = root[LIVEROOM_PREMIUMVIDEO_ANCHOR_ID].asString();
            }
                        
            /* videoId */
            if (root[LIVEROOM_PREMIUMVIDEO_VIDEO_ID].isString()) {
                videoId = root[LIVEROOM_PREMIUMVIDEO_VIDEO_ID].asString();
            }
            
            /* typeList */
            if( root[LIVEROOM_PREMIUMVIDEO_TYPE_LIST].isArray()) {
                for (int i = 0; i < root[LIVEROOM_PREMIUMVIDEO_TYPE_LIST].size(); i++) {
                    Json::Value element = root[LIVEROOM_PREMIUMVIDEO_TYPE_LIST].get(i, Json::Value::null);
                    HttpPremiumVideoTypeItem item;
                    if (item.Parse(element)) {
                        typeList.push_back(item);
                    }
                }
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
            
            /* videoUrlShort */
            if (root[LIVEROOM_PREMIUMVIDEO_VIDEO_URL_SHORT].isString()) {
                videoUrlShort = root[LIVEROOM_PREMIUMVIDEO_VIDEO_URL_SHORT].asString();
            }
            
            /* videoUrlFull */
            if (root[LIVEROOM_PREMIUMVIDEO_VIDEO_URL_FULL].isString()) {
                videoUrlFull = root[LIVEROOM_PREMIUMVIDEO_VIDEO_URL_FULL].asString();
            }
            
            /* isInterested */
            if( root[LIVEROOM_PREMIUMVIDEO_IS_INTERSTED].isNumeric() ) {
                isInterested = root[LIVEROOM_PREMIUMVIDEO_IS_INTERSTED].asInt() == 1 ? true : false;
            }
            
            /* lockStatus */
            if( root[LIVEROOM_PREMIUMVIDEO_LOCK_STATUS].isNumeric() ) {
                lockStatus = GetIntToLSLockStatus(root[LIVEROOM_PREMIUMVIDEO_LOCK_STATUS].asInt());
            }
            
            /* requestId */
            if (root[LIVEROOM_PREMIUMVIDEO_REQUEST_ID].isString()) {
                requestId = root[LIVEROOM_PREMIUMVIDEO_REQUEST_ID].asString();
            }
            
            /* requestLastTime */
            if (root[LIVEROOM_PREMIUMVIDEO_REQUEST_LAST_TIME].isNumeric()) {
                requestLastTime = root[LIVEROOM_PREMIUMVIDEO_REQUEST_LAST_TIME].asLong();
            }
            
            /* emfId */
            if (root[LIVEROOM_PREMIUMVIDEO_EMF_ID].isString()) {
                emfId = root[LIVEROOM_PREMIUMVIDEO_EMF_ID].asString();
            }
            
            /* unlockTime */
            if (root[LIVEROOM_PREMIUMVIDEO_UNLOCK_TIME].isNumeric()) {
                unlockTime = root[LIVEROOM_PREMIUMVIDEO_UNLOCK_TIME].asLong();
            }
            
            /* currentTime */
            if (root[LIVEROOM_PREMIUMVIDEO_CURRENT_TIME].isNumeric()) {
                currentTime = root[LIVEROOM_PREMIUMVIDEO_CURRENT_TIME].asLong();
            }
            
        }
	}

	HttpPremiumVideoDetailItem() {
		anchorId = "";
        videoId = "";
        title = "";
        description = "";
        duration = 0;
        coverUrlPng = "";
        coverUrlGif = "";
        videoUrlShort = "";
        videoUrlFull = "";
        isInterested = false;
        lockStatus = LSLOCKSTATUS_LOCK_NOREQUEST;
        requestId = "";
        requestLastTime = 0;
        emfId = "";
        unlockTime = 0;
        currentTime = 0;
	}

	virtual ~HttpPremiumVideoDetailItem() {

	}
    /**
     * 付费视频详情结构体
     * anchorId                     主播ID
     * videoId                      视频ID
     * typeList                      该视频对应的分类列表
     * title                            视频标题
     * description                视频描述
     * duration                     视频时长(单位:秒)
     * coverUrlPng              视频png封面地址
     * coverUrlGif               视频gif封面地址
     * videoUrlShort            短视频地址
     * videoUrlFull              完整视频地址
     * isInterested               是否感兴趣
     * lockStatus                解锁状态(LSLOCKSTATUS_LOCK_NOREQUEST:未解锁，未发过解锁请求, LSLOCKSTATUS_LOCK_UNREPLY:未解锁，解锁请求未回复, LSLOCKSTATUS_LOCK_REPLY:未解锁，解锁请求已回复, LSLOCKSTATUS_UNLOCK:已解锁 )
     * requestId                解锁码请求ID  (lockStatus=LSLOCKSTATUS_LOCK_UNREPLY时，有值)
     * requestLastTime             请求最后发送时间(GMT时间戳) (lockStatus=LSLOCKSTATUS_LOCK_UNREPLY时，有值)
     * emfId                        信件ID (lockStatus=LSLOCKSTATUS_LOCK_REPLY时，有值)
     * unlockTime             解锁时间(GMT时间戳) (lockStatus=LSLOCKSTATUS_UNLOCK时，有值)
     * currentTime             服务器当前时间(GMT时间戳)
     */

    string anchorId;
    string videoId;
    PremiumVideoTypeList typeList;
    string title;
    string description;
    int duration;
    string coverUrlPng;
    string coverUrlGif;
    string videoUrlShort;
    string videoUrlFull;
    bool isInterested;
    LSLockStatus lockStatus;
    string requestId;
    long long requestLastTime;
    string emfId;
    long long unlockTime;
    long long currentTime;

};


#endif /* HTTPPREMIUMVIDEODETAILITEM_H_ */
