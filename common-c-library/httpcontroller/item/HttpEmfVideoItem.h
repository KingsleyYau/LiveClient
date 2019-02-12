/*
 * HttpEmfVideoItem.h
 *
 *  Created on: 2018-4-12
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPEMFVIDEOITEM_H_
#define HTTPEMFVIDEOITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../HttpLoginProtocol.h"
#include "HttpLetterPayItem.h"


class HttpEmfVideoItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            payItem.Parse(root);
            /* coverSmallImg */
            if (root[LETTER_COVER_SMALL_IMG].isString()) {
                coverSmallImg = root[LETTER_COVER_SMALL_IMG].asString();
            }
            /* coverOriginImg */
            if (root[LETTER_COVER_ORIGIN_IMG].isString()) {
                coverOriginImg = root[LETTER_COVER_ORIGIN_IMG].asString();
            }
            /* video */
            if (root[LETTER_VIDEO_URL].isString()) {
                video = root[LETTER_VIDEO_URL].asString();
            }
            /* videoTotalTime */
            if (root[LETTER_VIDEO_TOTAL_TIME].isNumeric()) {
                videoTotalTime = root[LETTER_VIDEO_TOTAL_TIME].asDouble();
            }

        }
        result = true;
        return result;
    }

    HttpEmfVideoItem() {
        coverSmallImg = "";
        coverOriginImg = "";
        video = "";
        videoTotalTime = 0.0;
    }
    
    virtual ~HttpEmfVideoItem() {
        
    }
    
    /**
     * emf视频信息
     * payItem          支付item
     * coverSmallImg    视频封面小图URL
     * coverOriginImg   视频封面原图URL
     * video            视频URL
     * videoTotalTime    视频总时长（秒）
     */
    HttpLetterPayItem payItem;
    string    coverSmallImg;
    string    coverOriginImg;
    string    video;
    double    videoTotalTime;
};
typedef list<HttpEmfVideoItem> HttpEmfVideoList;

#endif /* HTTPEMFVIDEOITEM_H_*/
