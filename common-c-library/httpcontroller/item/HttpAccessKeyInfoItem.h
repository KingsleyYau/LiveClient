/*
 * HttpAccessKeyInfoItem.h
 *
 *  Created on: 2020-08-03
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPACCESSKEYINFOITEM_H_
#define HTTPACCESSKEYINFOITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"

class HttpAccessKeyInfoItem {
public:
	void Parse(const Json::Value& root) {
		if( root.isObject() ) {

            /* videoId */
            if (root[LETTER_VIDEO_ID].isString()) {
                videoId = root[LETTER_VIDEO_ID].asString();
            }
            
            /* title */
            if (root[LETTER_TITLE].isString()) {
                title = root[LETTER_TITLE].asString();
            }
            
            /* description */
            if (root[LETTER_DESCRIPTION].isString()) {
                description = root[LETTER_DESCRIPTION].asString();
            }
            
            /* duration */
            if( root[LETTER_DURATION].isNumeric() ) {
                duration = root[LETTER_DURATION].asInt();
            }
            
            /* coverUrlPng */
            if (root[LETTER_COVER_URL_PNG].isString()) {
                coverUrlPng = root[LETTER_COVER_URL_PNG].asString();
            }
            
            /* coverUrlGif */
            if (root[LETTER_COVER_URL_GIF].isString()) {
                coverUrlGif = root[LETTER_COVER_URL_GIF].asString();
            }
            
            /* accessKey */
            if (root[LETTER_ACCESS_KEY].isString()) {
                accessKey = root[LETTER_ACCESS_KEY].asString();
            }
            
            /* accessKeyStatus */
            if( root[LETTER_ACCESS_KEY_STATUS].isNumeric() ) {
                accessKeyStatus = GetIntToLSAccessKeyStatus(root[LETTER_ACCESS_KEY_STATUS].asInt());
            }
            
            /* validTime */
            if( root[LETTER_VALID_TIME].isNumeric() ) {
                validTime = root[LETTER_VALID_TIME].asLong();
            }
            
        }
	}

	HttpAccessKeyInfoItem() {
        videoId = "";
        title = "";
        description = "";
        duration = 0;
        coverUrlPng = "";
        coverUrlGif = "";
        accessKey = "";
        accessKeyStatus = LSACCESSKEYSTATUS_NOUSE;
        validTime = 0;
	}

	virtual ~HttpAccessKeyInfoItem() {

	}
    /**
     * 视频解锁码信息结构体
     * videoId                      视频ID
     * title                            视频标题
     * description                视频描述
     * duration                     视频时长(单位:秒)
     * coverUrlPng              视频png封面地址
     * coverUrlGif               视频gif封面地址
     * accessKey                解锁码
     * accessKeyStatus     解锁码状态 （LSACCESSKEYSTATUS_NOUSE：未使用,  LSACCESSKEYSTATUS_USED：已使用）
     * validTime                解锁码有效期(GMT时间戳)
     */

    string videoId;
    string title;
    string description;
    int duration;
    string coverUrlPng;
    string coverUrlGif;
    string accessKey;
    LSAccessKeyStatus accessKeyStatus;
    long long validTime;

};

#endif /* HTTPACCESSKEYINFOITEM_H_ */
