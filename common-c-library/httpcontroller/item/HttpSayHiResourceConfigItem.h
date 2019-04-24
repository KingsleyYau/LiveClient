/*
 * HttpSayHiResourceConfigItem.h
 *
 *  Created on: 2018-4-18
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPSAYHIRESOURCECONFIGITEM_H_
#define HTTPSAYHIRESOURCECONFIGITEM_H_

#include <string>
using namespace std;

#include "HttpTextItem.h"
#include "HttpThemeItem.h"

class HttpSayHiResourceConfigItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            
            /* themeList */
            if( root[LIVEROOM_RESOURCECONFIG_THEMELIST].isArray()) {
                for (int i = 0; i < root[LIVEROOM_RESOURCECONFIG_THEMELIST].size(); i++) {
                    Json::Value element = root[LIVEROOM_RESOURCECONFIG_THEMELIST].get(i, Json::Value::null);
                    HttpThemeItem themeItem;
                    if (themeItem.Parse(element)) {
                        themeList.push_back(themeItem);
                    }
                }
            }
            
            /* textList */
            if( root[LIVEROOM_RESOURCECONFIG_TESTLIST].isArray()) {
                for (int i = 0; i < root[LIVEROOM_RESOURCECONFIG_TESTLIST].size(); i++) {
                    Json::Value element = root[LIVEROOM_RESOURCECONFIG_TESTLIST].get(i, Json::Value::null);
                    HttpTextItem textItem;
                    if (textItem.Parse(element)) {
                        textList.push_back(textItem);
                    }
                }
            }

        }
        result = true;
        return result;
    }

    HttpSayHiResourceConfigItem() {

    }
    
    virtual ~HttpSayHiResourceConfigItem() {
        
    }
    
    /**
     * SayHi用到的主题和文本
     * themeList     主题列表
     * textList      文本列表
     */
    HttpThemeList themeList;
    HttpTextList textList;
};

#endif /* HTTPSAYHIRESOURCECONFIGITEM_H_*/
