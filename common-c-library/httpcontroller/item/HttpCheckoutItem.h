/*
 * HttpCheckoutItem.h
 *
 *  Created on: 2019-8-27
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPCHECKOUTITEM_H_
#define HTTPCHECKOUTITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "HttpCheckoutFlowerGiftItem.h"
#include "HttpGreetingCardItem.h"

class HttpCheckoutItem {
public:

	bool Parse(const Json::Value& root) {
        bool result = false;
		if( root.isObject() ) {
            
            /* giftList */
            if( root[LIVEROOM_CHECKOUT_GIFTLIST].isArray()) {
                for (int i = 0; i < root[LIVEROOM_CHECKOUT_GIFTLIST].size(); i++) {
                    Json::Value element = root[LIVEROOM_CHECKOUT_GIFTLIST].get(i, Json::Value::null);
                    HttpCheckoutFlowerGiftItem item;
                    if (item.Parse(element)) {
                        giftList.push_back(item);
                    }
                }
            }
            
            /* greetingCard */
            if ( root[LIVEROOM_CHECKOUT_GREETINGCARD].isObject()) {
                greetingCard.Parse(root[LIVEROOM_CHECKOUT_GREETINGCARD]);
            }
            
            /* deliveryPrice */
            if( root[LIVEROOM_CHECKOUT_DELIVERYFEE].isObject() ) {
                Json::Value priceElement = root[LIVEROOM_CHECKOUT_DELIVERYFEE];
                if (priceElement[LIVEROOM_CHECKOUT_DELIVERYFEE_PRICE].isNumeric()) {
                    deliveryPrice = priceElement[LIVEROOM_CHECKOUT_DELIVERYFEE_PRICE].asDouble();
                }
                
            }
            
            /* holidayPrice */
            if( root[LIVEROOM_CHECKOUT_HOLIDAYSPECIALOFFER].isObject() ) {
                Json::Value priceElement = root[LIVEROOM_CHECKOUT_HOLIDAYSPECIALOFFER];
                if (priceElement[LIVEROOM_CHECKOUT_HOLIDAYSPECIALOFFER_PRICE].isNumeric()) {
                    holidayPrice = priceElement[LIVEROOM_CHECKOUT_HOLIDAYSPECIALOFFER_PRICE].asDouble();
                }
                
            }
            
            /* totalPrice */
            if (root[LIVEROOM_CHECKOUT_TOTALPRICE].isNumeric()) {
                totalPrice = root[LIVEROOM_CHECKOUT_TOTALPRICE].asDouble();
            }
            
            /* greetingmessage */
            if (root[LIVEROOM_CHECKOUT_GREETINGMESSAGE].isString()) {
                greetingmessage = root[LIVEROOM_CHECKOUT_GREETINGMESSAGE].asString();
            }
            
            /* specialDeliveryRequest */
            if (root[LIVEROOM_CHECKOUT_SPECIALDELIVERYREQUEST].isString()) {
                specialDeliveryRequest = root[LIVEROOM_CHECKOUT_SPECIALDELIVERYREQUEST].asString();
            }
            
            result = true;
        }
        return result;
    }

	HttpCheckoutItem() {
        deliveryPrice = 0.0;
        holidayPrice = 0.0;
        totalPrice = 0.0;
        greetingmessage = "";
        specialDeliveryRequest = "";
	}

	virtual ~HttpCheckoutItem() {

	}
    
    /**
     * Checkout商品结构体
     * giftList                   礼品列表
     * greetingCard               免费贺卡
     * deliveryPrice              邮费价格
     * holidayPrice               优惠价格
     * totalPrice                 总额
     * greetingmessage            文本信息
     * specialDeliveryRequest     文本信息
     */
    CheckoutFlowerGiftList giftList;
    HttpGreetingCardItem greetingCard;
    double deliveryPrice;
    double holidayPrice;
    double totalPrice;
    string greetingmessage;
    string specialDeliveryRequest;
    
};

typedef list<HttpCheckoutItem> CheckoutItemList;

#endif /* HTTPCHECKOUTITEM_H_ */
