/*
 * ZBHttpEmoticonInfoItem.h
 *
 *  Created on: 2018-2-28
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef ZBHTTPEMOTIOCONINFOITEM_H_
#define ZBHTTPEMOTIOCONINFOITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../ZBHttpLoginProtocol.h"
#include "../ZBHttpRequestEnum.h"


class ZBHttpEmoticonInfoItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if( root.isObject() ) {
            /* emoId */
            if( root[GETEMOTICONLIST_LIST_EMOLIST_ID].isString() ) {
                emoId = root[GETEMOTICONLIST_LIST_EMOLIST_ID].asString();
            }
            
            /* emoSign */
            if( root[GETEMOTICONLIST_LIST_EMOLIST_EMOSIGN].isString() ) {
                emoSign = root[GETEMOTICONLIST_LIST_EMOLIST_EMOSIGN].asString();
            }
            
            /* emoUrl */
            if( root[GETEMOTICONLIST_LIST_EMOLIST_EMOURL].isString() ) {
                emoUrl = root[GETEMOTICONLIST_LIST_EMOLIST_EMOURL].asString();
            }
            
            /* emoType */
            if( root[GETEMOTICONLIST_LIST_EMOLIST_EMOTYPE].isNumeric()) {
                emoType = (ZBEmoticonActionType)root[GETEMOTICONLIST_LIST_EMOLIST_EMOTYPE].asInt();
            }
            
            /* emoIconUrl */
            if( root[GETEMOTICONLIST_LIST_EMOLIST_EMOICONURL].isString() ) {
                emoIconUrl = root[GETEMOTICONLIST_LIST_EMOLIST_EMOICONURL].asString();
            }
            
        }
        if (!emoId.empty()) {
            result = true;
        }
        return result;
    }
    
    ZBHttpEmoticonInfoItem() {
        emoId = "";
        emoSign = "";
        emoUrl = "";
        emoType = ZBEMOTICONACTIONTYPE_STATIC;
        emoIconUrl = "";
    }
    
    virtual ~ZBHttpEmoticonInfoItem() {
        
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
    ZBEmoticonActionType emoType;
    string   emoIconUrl;
};

 typedef list<ZBHttpEmoticonInfoItem> ZBEmoticonInfoItemList;

#endif /* ZBHTTPEMOTIOCONINFOITEM_H_*/
