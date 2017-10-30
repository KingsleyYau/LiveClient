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
            
            /* emoType */
            if( root[LIVEROOM_EMOTICON_LIST_EMOLIST_EMOTYPE].isNumeric()) {
                emoType = (EmoticonActionType)root[LIVEROOM_EMOTICON_LIST_EMOLIST_EMOTYPE].asInt();
            }
            
            /* emoIconUrl */
            if( root[LIVEROOM_EMOTICON_LIST_EMOLIST_EMOICONURL].isString() ) {
                emoIconUrl = root[LIVEROOM_EMOTICON_LIST_EMOLIST_EMOICONURL].asString();
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
        emoType = EMOTICONACTIONTYPE_STATIC;
        emoIconUrl = "";
    }
    
    virtual ~HttpEmoticonInfoItem() {
        
    }
    /**
     * 表情信息结构体
     * emoId             表情ID
     * emoSign			表情文本标记
     * emoUrl		    表情图片url
     * emoType          表情类型（0：静态表情，1：动画表情）
     * emoIconUrl       表情icon图片url，用于移动端在表情列表显示
     */
    string   emoId;
    string   emoSign;
    string   emoUrl;
    EmoticonActionType emoType;
    string   emoIconUrl;
};

 typedef list<HttpEmoticonInfoItem> EmoticonInfoItemList;

#endif /* HTTPEMOTIOCONINFOITEM_H_*/
