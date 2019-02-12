/*
 * HttpLetterHasItem.h
 *
 *  Created on: 2018-4-12
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPLETTERHASITEM_H_
#define HTTPLETTERHASITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../HttpLoginProtocol.h"


class HttpLetterHasItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* hasImg */
            if (root[LETTER_HAS_IMG].isNumeric()) {
                hasImg = root[LETTER_HAS_IMG].asInt() == 0 ? false : true;
            }
            /* hasVideo */
            if (root[LETTER_HAS_VIDEO].isNumeric()) {
                hasVideo = root[LETTER_HAS_VIDEO].asInt() == 0 ? false : true;
            }
            /* hasRead */
            if (root[LETTER_HAS_READ].isNumeric()) {
                hasRead = root[LETTER_HAS_READ].asInt() == 0 ? false : true;
            }
            /* hasReplied */
            if (root[LETTER_HAS_REPLIED].isNumeric()) {
                hasReplied = root[LETTER_HAS_REPLIED].asInt() == 0 ? false : true;
            }

        }
        result = true;
        return result;
    }

    HttpLetterHasItem() {
        hasImg = false;
        hasVideo = false;
        hasRead = false;
        hasReplied = false;
    }
    
    virtual ~HttpLetterHasItem() {
        
    }
    
    /**
     * 信件是否有item
     * hasImg         是否有照片
     * hasVideo       是否有视频
     * hasRead        是否已读
     * hasReplied     是否已回复
     */
    bool    hasImg;
    bool    hasVideo;
    bool    hasRead;
    bool    hasReplied;
};


#endif /* HTTPLETTERHASITEM_H_*/
