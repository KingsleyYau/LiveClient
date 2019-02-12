/*
 * HttpLetterVideoItem.h
 *
 *  Created on: 2018-4-12
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPLETTERVIDEOITEM_H_
#define HTTPLETTERVIDEOITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../HttpLoginProtocol.h"


class HttpLetterVideoItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* cover */
            if (root[LETTER_COVER].isString()) {
                cover = root[LETTER_COVER].asString();
            }
            /* video */
            if (root[LETTER_VIDEO].isString()) {
                video = root[LETTER_VIDEO].asString();
            }
            /* videoTotalTime */
            if (root[LETTER_VIDEO_TOTAL_TIME].isNumeric()) {
                videoTotalTime = root[LETTER_VIDEO_TOTAL_TIME].asDouble();
            }

        }
        result = true;
        return result;
    }

    HttpLetterVideoItem() {
        cover = "";
        video = "";
    }
    
    virtual ~HttpLetterVideoItem() {
        
    }
    
    /**
     * 视频信息
     * cover        视频封面图URL
     * video        视频URL
     * videoTotalTime    视频总时长（秒）
     */
    string    cover;
    string    video;
    double    videoTotalTime;
};
typedef list<HttpLetterVideoItem> HttpLetterVideoList;

#endif /* HTTPLETTERVIDEOITEM_H_*/
