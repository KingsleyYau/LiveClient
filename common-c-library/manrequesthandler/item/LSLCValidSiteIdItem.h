/*
 * LSLCValidSiteIdItem.h
 *
 *  Created on: 2018-7-13
 *      Author: Alex.Shum
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LSLCVALIDSITEIDITEM_H_
#define LSLCVALIDSITEIDITEM_H_

#include <string>
using namespace std;


#include <json/json/json.h>

#include "../LSLiveChatRequestAuthorizationDefine.h"
#include "../LSLiveChatRequestOtherDefine.h"

class LSLCValidSiteIdItem {
public:
    void Parse(Json::Value root) {

        if( root.isObject() ) {
            if( root[AUTHORIZATION_SITE_ID].isNumeric() ) {
                char temp[16] = {0};
                snprintf(temp, sizeof(temp), "%d", root[AUTHORIZATION_SITE_ID].asInt());
                siteId = GetSiteTypeByServerSiteId(temp);
            }

            if( root[AUTHORIZATION_ISLIVE].isNumeric() ) {
                isLive = root[AUTHORIZATION_ISLIVE].asInt();
            }
        }
    }

    LSLCValidSiteIdItem() {
        siteId = OTHER_SITE_CD;
        isLive = false;
    }
    virtual ~LSLCValidSiteIdItem() {

    }

    OTHER_SITE_TYPE siteId;
    bool isLive;

};

// 微视频列表定义
typedef list<LSLCValidSiteIdItem> ValidSiteIdList;

#endif /* VALIDSITEIDITEM_H_ */

