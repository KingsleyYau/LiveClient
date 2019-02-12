/*
 * HttpValidSiteIdItem.h
 *
 *  Created on: 2018-7-13
 *      Author: Alex.Shum
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPVALIDSITEIDITEM_H_
#define HTTPVALIDSITEIDITEM_H_

#include <string>
using namespace std;


#include <json/json/json.h>

#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"
#include "../HttpRequestConvertEnum.h"

class HttpValidSiteIdItem {
public:
    void Parse(Json::Value root) {

        if( root.isObject() ) {
            if( root[VALIDSITEID_DATALIST_SITEID].isNumeric() ) {
                char temp[16] = {0};
                snprintf(temp, sizeof(temp), "%d", root[VALIDSITEID_DATALIST_SITEID].asInt());
                siteId = GetHttpSiteTypeByServerSiteId(temp);
            }

            if( root[VALIDSITEID_DATALIST_ISLIVE].isNumeric() ) {
                isLive = root[VALIDSITEID_DATALIST_ISLIVE].asInt();
            }
        }
    }

    HttpValidSiteIdItem() {
        siteId = HTTP_OTHER_SITE_CD;
        isLive = false;
    }
    virtual ~HttpValidSiteIdItem() {

    }

    HTTP_OTHER_SITE_TYPE siteId;
    bool isLive;

};

// 微视频列表定义
typedef list<HttpValidSiteIdItem> HttpValidSiteIdList;

#endif /* HTTPVALIDSITEIDITEM_H_ */

