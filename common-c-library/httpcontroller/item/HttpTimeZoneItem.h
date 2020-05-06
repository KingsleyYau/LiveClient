/*
 * HttpTimeZoneItem.h
 *
 *  Created on: 2020-03-16
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTTIMEZONEITEM_H_
#define HTTTIMEZONEITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"

class HttpTimeZoneItem {
public:

	bool Parse(const Json::Value& root) {
        bool result = false;
		if( root.isObject() ) {
            
            /* zoneId */
            if (root[LIVEROOM_GETCOUNTRYTIMEZONELIST_TIME_ZONE_LIST_ID].isString()) {
                zoneId = root[LIVEROOM_GETCOUNTRYTIMEZONELIST_TIME_ZONE_LIST_ID].asString();
            }
            
            /* value */
            if (root[LIVEROOM_GETCOUNTRYTIMEZONELIST_TIME_ZONE_LIST_VALUE].isString()) {
                value = root[LIVEROOM_GETCOUNTRYTIMEZONELIST_TIME_ZONE_LIST_VALUE].asString();
            }
            
            /* cityCode */
            if (root[LIVEROOM_GETCOUNTRYTIMEZONELIST_TIME_ZONE_LIST_CITY].isString()) {
                city = root[LIVEROOM_GETCOUNTRYTIMEZONELIST_TIME_ZONE_LIST_CITY].asString();
            }
            
            /* city */
            if (root[LIVEROOM_GETCOUNTRYTIMEZONELIST_TIME_ZONE_LIST_CITYCODE].isString()) {
                cityCode = root[LIVEROOM_GETCOUNTRYTIMEZONELIST_TIME_ZONE_LIST_CITYCODE].asString();
            }
            
            /* summerTimeStart */
            if (root[LIVEROOM_GETCOUNTRYTIMEZONELIST_TIME_ZONE_LIST_SUMMER_TIME_START].isNumeric()) {
                summerTimeStart = root[LIVEROOM_GETCOUNTRYTIMEZONELIST_TIME_ZONE_LIST_SUMMER_TIME_START].asLong();
            }
            
            /* summerTimeEnd */
            if (root[LIVEROOM_GETCOUNTRYTIMEZONELIST_TIME_ZONE_LIST_SUMMER_TIME_END].isNumeric()) {
                summerTimeEnd = root[LIVEROOM_GETCOUNTRYTIMEZONELIST_TIME_ZONE_LIST_SUMMER_TIME_END].asLong();
            }
            result = true;
        }
        return result;
    }

	HttpTimeZoneItem() {
        zoneId = "";
        value = "";
        city = "";
        cityCode = "";
        summerTimeStart = 0;
        summerTimeEnd = 0;
	}

	virtual ~HttpTimeZoneItem() {

	}
    
    /**
     * 时区结构体
     * zoneId              时区ID
     * value              时区差值
     * city                  城市
     * cityCode         城市码
     * summerTimeStart       夏令时开始时间
     * summerTimeEnd       夏令时结束时间
     */
    string zoneId;
    string value;
    string city;
    string cityCode;
    long long summerTimeStart;
    long long summerTimeEnd;
    
};

typedef list<HttpTimeZoneItem> TimeZoneList;

#endif /* HTTTIMEZONEITEM_H_ */
