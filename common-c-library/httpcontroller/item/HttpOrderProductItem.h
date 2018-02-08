/*
 * HttpOrderProductItem.h
 *
 *  Created on: 2017-12-22
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPORDERPRODUCTTITEM_H_
#define HTTPORDERPRODUCTTITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "HttpProductItem.h"

class HttpOrderProductItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {

            /* list */
            if (root[LIVEROOM_PREMIUM_MEMBERSHIP_PRODUCTS].isArray()) {
                for (int i = 0; i < root[LIVEROOM_PREMIUM_MEMBERSHIP_PRODUCTS].size(); i++) {
                    Json::Value element = root[LIVEROOM_PREMIUM_MEMBERSHIP_PRODUCTS].get(i, Json::Value::null);
                    HttpProductItem item;
                    if (item.Parse(element)) {
                        list.push_back(item);
                    }
                }
            }
            /* desc */
            if (root[LIVEROOM_PREMIUM_MEMBERSHIP_DESC].isString()) {
                desc = root[LIVEROOM_PREMIUM_MEMBERSHIP_DESC].asString();
            }
            /* more */
            if (root[LIVEROOM_PREMIUM_MEMBERSHIP_MORE].isString()) {
                more = root[LIVEROOM_PREMIUM_MEMBERSHIP_MORE].asString();
            }
        }

        return result;
    }
    
    HttpOrderProductItem() {

        desc = "";
        more = "";

    }
    
    virtual ~HttpOrderProductItem() {
        
    }
    /**
     * 买点信息
     * list             产品列表
     * desc             描述
     * more             详情描述
     */
    ProductItemList list;
    string  desc;
    string  more;
};

#endif /* HTTPORDERPRODUCTTITEM_H_*/
