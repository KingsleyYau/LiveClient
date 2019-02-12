/*
 * HttpLetterOppAnchorItem.h
 *
 *  Created on: 2018-4-12
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPLETTEROPPANCHORITEM_H_
#define HTTPLETTEROPPANCHORITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../HttpLoginProtocol.h"


class HttpLetterOppAnchorItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* anchorId */
            if (root[LETTER_ANCHOR_ID].isString()) {
                anchorId = root[LETTER_ANCHOR_ID].asString();
            }
            /* anchorAvatar */
            if (root[LETTER_ANCHOR_AVATAR].isString()) {
                anchorAvatar = root[LETTER_ANCHOR_AVATAR].asString();
            }
            /* anchorNickName */
            if (root[LETTER_ANCHOR_NICKNAME].isString()) {
                anchorNickName = root[LETTER_ANCHOR_NICKNAME].asString();
            }
            /* isFollow */
            if (root[LETTER_IS_FOLLOW].isNumeric()) {
                isFollow = root[LETTER_IS_FOLLOW].asInt() == 0 ? false : true;
            }
        }
        result = true;
        return result;
    }

    HttpLetterOppAnchorItem() {
        anchorId = "";
        anchorAvatar = "";
        anchorNickName = "";
        isFollow = false;
    }
    
    virtual ~HttpLetterOppAnchorItem() {
        
    }
    
    /**
     * 信件主播信息
     * anchorId           主播ID
     * anchorAvatar       主播头像
     * anchorNickName     主播昵称
     * isFollow           是否关注
     */
    string    anchorId;
    string    anchorAvatar;
    string    anchorNickName;
    bool      isFollow;
};


#endif /* HTTPLETTEROPPANCHORITEM_H_*/
