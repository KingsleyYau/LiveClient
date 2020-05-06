/*
 * HttpCountryTimeZoneItem.h
 *
 *  Created on: 2020-03-16
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTCOUNTRYTIMEZONEITEM_H_
#define HTTCOUNTRYTIMEZONEITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "HttpTimeZoneItem.h"

class HttpCountryTimeZoneItem {
public:

	bool Parse(const Json::Value& root) {
        bool result = false;
		if( root.isObject() ) {
            
            /* countryCode */
            if (root[LIVEROOM_GETCOUNTRYTIMEZONELIST_COUNTRY_CODE].isString()) {
                countryCode = root[LIVEROOM_GETCOUNTRYTIMEZONELIST_COUNTRY_CODE].asString();
            }
            
            /* countryName */
            if (root[LIVEROOM_GETCOUNTRYTIMEZONELIST_COUNTRY_NAME].isString()) {
                countryName = root[LIVEROOM_GETCOUNTRYTIMEZONELIST_COUNTRY_NAME].asString();
            }
            
            /* isDefault */
            if (root[LIVEROOM_GETCOUNTRYTIMEZONELIST_IS_DEFAULT].isNumeric()) {
                isDefault = root[LIVEROOM_GETCOUNTRYTIMEZONELIST_IS_DEFAULT].asInt() == 0 ? false : true;
            }
            
            /* timeZoneList */
            if( root[LIVEROOM_GETCOUNTRYTIMEZONELIST_TIME_ZONE_LIST].isArray()) {
                for (int i = 0; i < root[LIVEROOM_GETCOUNTRYTIMEZONELIST_TIME_ZONE_LIST].size(); i++) {
                    Json::Value element = root[LIVEROOM_GETCOUNTRYTIMEZONELIST_TIME_ZONE_LIST].get(i, Json::Value::null);
                    HttpTimeZoneItem item;
                    if (item.Parse(element)) {
                        timeZoneList.push_back(item);
                    }
                }
            }
            result = true;
        }
        return result;
    }

	HttpCountryTimeZoneItem() {
        countryCode = "";
        countryName = "";
        isDefault = false;
	}

	virtual ~HttpCountryTimeZoneItem() {

	}
    
    /**
     * 国家时区结构体
     * countryCode              国家码
     * countryName             国家名称
     * isDefault                    是否默认选中
     * timeZoneList             时区列表
     */
    string countryCode;
    string countryName;
    bool isDefault;
    TimeZoneList timeZoneList;
    
};

typedef list<HttpCountryTimeZoneItem> CountryTimeZoneList;

#endif /* HTTCOUNTRYTIMEZONEITEM_H_ */
