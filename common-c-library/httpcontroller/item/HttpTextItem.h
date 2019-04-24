/*
 * HttpTextItem.h
 *
 *  Created on: 2019-4-18
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPTEXTITEM_H_
#define HTTPTEXTITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../HttpLoginProtocol.h"

class HttpTextItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* textId */
            if (root[LIVEROOM_RESOURCECONFIG_TESTLIST_ID].isNumeric()) {
                textId = root[LIVEROOM_RESOURCECONFIG_TESTLIST_ID].asInt();
            }
            /* text */
            if (root[LIVEROOM_RESOURCECONFIG_TESTLIST_TEXT].isString()) {
                text = root[LIVEROOM_RESOURCECONFIG_TESTLIST_TEXT].asString();
            }

        }
        result = true;
        return result;
    }

    HttpTextItem() {
        textId = 0;
        text = "";
    }
    
    virtual ~HttpTextItem() {
        
    }
    
    /**
     * 文本列表
     * textId      文本ID
     * text        文本内容
     */
    int textId;
    string text;

};

typedef list<HttpTextItem> HttpTextList;

#endif /* HTTPTEXTITEM_H_*/
