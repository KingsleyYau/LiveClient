/*
 * HttpProductItem.h
 *
 *  Created on: 2017-12-22
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPPRODUCTITEM_H_
#define HTTPPRODUCTITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

class HttpProductItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* productId */
            if (root[LIVEROOM_PREMIUM_MEMBERSHIP_PRODUCTS_ID].isString()) {
                productId = root[LIVEROOM_PREMIUM_MEMBERSHIP_PRODUCTS_ID].asString();
            }

            /* name */
            if (root[LIVEROOM_PREMIUM_MEMBERSHIP_PRODUCTS_NAME].isString()) {
                name = root[LIVEROOM_PREMIUM_MEMBERSHIP_PRODUCTS_NAME].asString();
            }
            /* price */
            if (root[LIVEROOM_PREMIUM_MEMBERSHIP_PRODUCTS_PRICE].isString()) {
                price = root[LIVEROOM_PREMIUM_MEMBERSHIP_PRODUCTS_PRICE].asString();
            }
            result = true;
        }

        return result;
    }

    HttpProductItem() {
        productId = "";
        name = "";
        price = "";

    }
    
    virtual ~HttpProductItem() {
        
    }
    
    /**
     * 产品结构体
     * productId               产品ID
     * name                    名称
     * price                   价格
     */
    string      productId;
    string      name;
    string      price;

};

typedef list<HttpProductItem> ProductItemList;


#endif /* HTTPPRODUCTITEM_H_*/
