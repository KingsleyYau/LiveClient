/*
 * HttpMyCartItem.h
 *
 *  Created on: 2019-8-27
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPMYCARTITEM_H_
#define HTTPMYCARTITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "HttpRecipientAnchorItem.h"
#include "HttpDeliveryFlowerGiftItem.h"

class HttpMyCartItem {
public:

	bool Parse(const Json::Value& root) {
        bool result = false;
		if( root.isObject() ) {
            /* anchorItem */
            anchorItem.Parse(root);
            
            /* giftList */
            if( root[LIVEROOM_GETDELIVERYLIST_LIST_GIFTLIST].isArray()) {
                for (int i = 0; i < root[LIVEROOM_GETDELIVERYLIST_LIST_GIFTLIST].size(); i++) {
                    Json::Value element = root[LIVEROOM_GETDELIVERYLIST_LIST_GIFTLIST].get(i, Json::Value::null);
                    HttpDeliveryFlowerGiftItem item;
                    if (item.Parse(element)) {
                        giftList.push_back(item);
                    }
                }
            }
            
            result = true;
        }
        return result;
    }

	HttpMyCartItem() {
	}

	virtual ~HttpMyCartItem() {

	}
    
    /**
     * My cart结构体
     * anchorItem                   主播item
     * giftList                     产品列表
     */
	HttpRecipientAnchorItem anchorItem;
    DeliveryFlowerGiftList giftList;
};

typedef list<HttpMyCartItem> MyCartItemList;

#endif /* HTTPMYCARTITEM_H_ */
