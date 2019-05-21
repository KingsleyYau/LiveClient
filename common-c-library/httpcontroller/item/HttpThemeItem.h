/*
 * HttpThemeItem.h
 *
 *  Created on: 2019-4-18
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPTHEMEITEM_H_
#define HTTPTHEMEITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../HttpLoginProtocol.h"

class HttpThemeItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* themeId */
            if (root[LIVEROOM_RESOURCECONFIG_THEMELIST_ID].isString()) {
                themeId = root[LIVEROOM_RESOURCECONFIG_THEMELIST_ID].asString();
            }
            /* themeName */
            if (root[LIVEROOM_RESOURCECONFIG_THEMELIST_NAME].isString()) {
                themeName = root[LIVEROOM_RESOURCECONFIG_THEMELIST_NAME].asString();
            }
            /* smallImg */
            if (root[LIVEROOM_RESOURCECONFIG_THEMELIST_SMALLIMG].isString()) {
                smallImg = root[LIVEROOM_RESOURCECONFIG_THEMELIST_SMALLIMG].asString();
            }
            /* bigImg */
            if (root[LIVEROOM_RESOURCECONFIG_THEMELIST_BIGIMG].isString()) {
                bigImg = root[LIVEROOM_RESOURCECONFIG_THEMELIST_BIGIMG].asString();
            }

        }
        result = true;
        return result;
    }

    HttpThemeItem() {
        themeId = "";
        themeName = "";
        smallImg = "";
        bigImg = "";
    }
    
    virtual ~HttpThemeItem() {
        
    }
    
    /**
     * 主题列表
     * themeId      主题ID
     * themeName    主题名称
     * smallImg     小图
     * bigImg       大图
     */
    string themeId;
    string themeName;
    string smallImg;
    string bigImg;
};

typedef list<HttpThemeItem> HttpThemeList;

#endif /* HTTPTHEMEITEM_H_*/
