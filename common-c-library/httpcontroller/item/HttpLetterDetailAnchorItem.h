/*
 * HttpLetterDetailAnchorItem.h
 *
 *  Created on: 2018-4-12
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPLETTERDETAILANCHORITEM_H_
#define HTTPLETTERDETAILANCHORITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../HttpLoginProtocol.h"


class HttpLetterDetailAnchorItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* anchorId */
            if (root[LETTER_ANCHOR_ID].isString()) {
                anchorId = root[LETTER_ANCHOR_ID].asString();
            }
            /* anchorCover */
            if (root[LETTER_ANCHOR_COVER].isString()) {
                anchorCover = root[LETTER_ANCHOR_COVER].asString();
            }
            /* anchorAvatar */
            if (root[LETTER_ANCHOR_AVATAR].isString()) {
                anchorAvatar = root[LETTER_ANCHOR_AVATAR].asString();
            }
            /* anchorNickName */
            if (root[LETTER_ANCHOR_NICKNAME].isString()) {
                anchorNickName = root[LETTER_ANCHOR_NICKNAME].asString();
            }
            /* age */
            if (root[LETTER_AGE].isNumeric()) {
                age = root[LETTER_AGE].asInt();
            }
            /* country */
            if (root[LETTER_COUNTRY].isString()) {
                country = root[LETTER_COUNTRY].asString();
            }
            /* onlineStatus */
            if (root[LETTER_ONLINE_STATUS].isNumeric()) {
                onlineStatus = root[LETTER_ONLINE_STATUS].asInt() == 0 ? false : true;
            }
            /* isInPublic */
            if (root[LETTER_IS_IN_PUBLIC].isNumeric()) {
                isInPublic = root[LETTER_IS_IN_PUBLIC].asInt() == 0 ? false : true;
            }
            /* isFollow */
            if (root[LETTER_IS_FOLLOW].isNumeric()) {
                isFollow = root[LETTER_IS_FOLLOW].asInt() == 0 ? false : true;
            }
        }
        result = true;
        return result;
    }

    HttpLetterDetailAnchorItem() {
        anchorId = "";
        anchorCover = "";
        anchorAvatar = "";
        anchorNickName = "";
        age = 0;
        country = "";
        onlineStatus = false;
        isInPublic = false;
        isFollow = false;
    }
    
    virtual ~HttpLetterDetailAnchorItem() {
        
    }
    
    /**
     * 信件主播详细信息
     * anchorId           主播ID
     * anchorAvatar       主播头像
     * anchorNickName     主播昵称
     * isFollow           是否关注
     */
    string    anchorId;
    string    anchorCover;
    string    anchorAvatar;
    string    anchorNickName;
    int       age;
    string    country;
    bool      onlineStatus;
    bool      isInPublic;
    bool      isFollow;
};


#endif /* HTTPLETTEROPPANCHORITEM_H_*/
