/*
 * HttpBuyAttachItem.h
 *
 *  Created on: 2018-4-12
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPBUYATTACHITEM_H_
#define HTTPBUYATTACHITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../HttpLoginProtocol.h"

class HttpBuyAttachItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* emfId */
            if (root[LETTER_EMF_ID].isString()) {
                emfId = root[LETTER_EMF_ID].asString();
            }
            /* resourceId */
            if (root[LETTER_RESOURCE_ID].isString()) {
                resourceId = root[LETTER_RESOURCE_ID].asString();
            }
            /* originImg */
            if (root[LETTER_ORIGIN_IMG].isString()) {
                originImg = root[LETTER_ORIGIN_IMG].asString();
            }
            /* videoUrl */
            if (root[LETTER_VIDEO_URL].isString()) {
                videoUrl = root[LETTER_VIDEO_URL].asString();
            }

        }
        result = true;
        return result;
    }

    HttpBuyAttachItem() {
        emfId = "";
        resourceId = "";
        originImg = "";
        videoUrl = "";
    }
    
    virtual ~HttpBuyAttachItem() {
        
    }
    
    /**
     * 购买信件附件
     * emfId        信件ID
     * resourceId   附件ID
     * originImg    图片原图URL或视频封面图URL
     * videoUrl     视频URL（可无，仅视频附件时存在）
     */
    string      emfId;
    string      resourceId;
    string      originImg;
    string      videoUrl;
};


#endif /* HTTPBUYATTACHITEM_H_*/
