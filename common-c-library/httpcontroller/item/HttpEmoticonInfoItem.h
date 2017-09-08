/*
 * HttpEmoticonInfoItem.h
 *
 *  Created on: 2017-8-16
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPEMOTIOCONINFOITEM_H_
#define HTTPEMOTIOCONINFOITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"


class HttpEmoticonInfoItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if( root.isObject() ) {
            /* emoId */
            if( root[LIVEROOM_EMOTICON_LIST_EMOLIST_ID].isString() ) {
                emoId = root[LIVEROOM_EMOTICON_LIST_EMOLIST_ID].asString();
            }
            
            /* emoSign */
            if( root[LIVEROOM_EMOTICON_LIST_EMOLIST_EMOSIGN].isString() ) {
                emoSign = root[LIVEROOM_EMOTICON_LIST_EMOLIST_EMOSIGN].asString();
            }
            
            /* emoUrl */
            if( root[LIVEROOM_EMOTICON_LIST_EMOLIST_EMOURL].isString() ) {
                emoUrl = root[LIVEROOM_EMOTICON_LIST_EMOLIST_EMOURL].asString();
            }
        }
        if (!emoSign.empty()) {
            result = true;
        }
        return result;
    }
    
    HttpEmoticonInfoItem() {
        emoId = "";
        emoSign = "";
        emoUrl = "";
    }
    
    virtual ~HttpEmoticonInfoItem() {
        
    }
    /**
     * 表情信息结构体
     * emoId             表情ID
     * emoSign			表情文本标记
     * emoUrl		    表情图片url
     */
    string   emoId;
    string   emoSign;
    string   emoUrl;
};

 typedef list<HttpEmoticonInfoItem> EmoticonInfoItemList;

#endif /* HTTPEMOTIOCONINFOITEM_H_*/
