/*
 * HttpLetterImgItem.h
 *
 *  Created on: 2018-4-12
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPLETTERIMGITEM_H_
#define HTTPLETTERIMGITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../HttpLoginProtocol.h"


class HttpLetterImgItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* originImg */
            if (root[LETTER_ORIGIN_IMG].isString()) {
                originImg = root[LETTER_ORIGIN_IMG].asString();
            }
            /* smallImg */
            if (root[LETTER_SMALL_IMG].isString()) {
                smallImg = root[LETTER_SMALL_IMG].asString();
            }
            /* blurImg */
            if (root[LETTER_BLUR_IMG].isString()) {
                blurImg = root[LETTER_BLUR_IMG].asString();
            }
        }
        result = true;
        return result;
    }

    HttpLetterImgItem() {
        originImg = "";
        smallImg = "";
        blurImg = "";
    }
    
    virtual ~HttpLetterImgItem() {
        
    }
    
    /**
     * 图片信息
     * originImg        原图URL
     * smallImg         小图URL
     * blurImg          模糊图URL
     */
    string    originImg;
    string    smallImg;
    string    blurImg;
};
typedef list<HttpLetterImgItem> HttpLetterImgList;

#endif /* HTTPLETTERIMGITEM_H_*/
