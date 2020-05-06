/*
 * HttpAndroidProductItem.h
 *
 *  Created on: 2017-12-22
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPANDROIDPRODUCTTITEM_H_
#define HTTPANDROIDPRODUCTTITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "HttpProductItem.h"

class HttpAndroidProductItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {

            /* creditProductslist */
            if (root[LIVEROOM_ANDROIDPREMIUM_MEMBERSHIP_PRODUCTSCREDITS].isArray()) {
                for (int i = 0; i < root[LIVEROOM_ANDROIDPREMIUM_MEMBERSHIP_PRODUCTSCREDITS].size(); i++) {
                    Json::Value element = root[LIVEROOM_ANDROIDPREMIUM_MEMBERSHIP_PRODUCTSCREDITS].get(i, Json::Value::null);
                    HttpProductItem item;
                    if (item.Parse(element)) {
                        creditProductslist.push_back(item);
                    }
                }
            }
            /* stampProductlist */
            if (root[LIVEROOM_ANDROIDPREMIUM_MEMBERSHIP_PRODUCTSSTAMPS].isArray()) {
                for (int i = 0; i < root[LIVEROOM_ANDROIDPREMIUM_MEMBERSHIP_PRODUCTSSTAMPS].size(); i++) {
                    Json::Value element = root[LIVEROOM_ANDROIDPREMIUM_MEMBERSHIP_PRODUCTSSTAMPS].get(i, Json::Value::null);
                    HttpProductItem item;
                    if (item.Parse(element)) {
                        stampProductlist.push_back(item);
                    }
                }
            }
            /* desc */
            if (root[LIVEROOM_PREMIUM_MEMBERSHIP_DESC].isString()) {
                desc = root[LIVEROOM_PREMIUM_MEMBERSHIP_DESC].asString();
            }

            /* products_stamp_tips */
            if (root[LIVEROOM_PREMIUM_MEMBERSHIP_STAMP_DESC].isString()) {
                products_stamp_tips = root[LIVEROOM_PREMIUM_MEMBERSHIP_STAMP_DESC].asString();
            }

            /* more */
            if (root[LIVEROOM_PREMIUM_MEMBERSHIP_MORE].isString()) {
                more = root[LIVEROOM_PREMIUM_MEMBERSHIP_MORE].asString();
            }
            
            /* title */
            if (root[LIVEROOM_IOSPREMIUM_MEMBERSHIP_TITLE].isString()) {
                title = root[LIVEROOM_IOSPREMIUM_MEMBERSHIP_TITLE].asString();
            }

            /* subTitle */
            if (root[LIVEROOM_IOSPREMIUM_MEMBERSHIP_SUBTITLE].isString()) {
                subTitle = root[LIVEROOM_IOSPREMIUM_MEMBERSHIP_SUBTITLE].asString();
            }
        }

        return result;
    }
    
    HttpAndroidProductItem() {

        desc = "";
        products_stamp_tips = "";
        more = "";
        title = "";
        subTitle = "";
    }
    
    virtual ~HttpAndroidProductItem() {
        
    }
    /**
     * 买点信息
     * desc             描述
     * products_stamp_tips 邮票描述
     * more             详情描述
     * creditProductslist          普通产品列表
     * stampProductlist            邮票产品列表
     * title            主标题
     * subTitle         副标题
     */

    string title;
    string subTitle;
    ProductItemList creditProductslist;
    ProductItemList stampProductlist;
    string  desc;
    string  products_stamp_tips;
    string  more;
    
};

#endif /* HTTPANDROIDPRODUCTTITEM_H_*/
