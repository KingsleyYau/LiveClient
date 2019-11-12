/*
 * HttpCheckoutFlowerGiftItem.h
 *
 *  Created on: 2019-8-27
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPCHECKOUTFLOWERGIFTITEM_H_
#define HTTPCHECKOUTFLOWERGIFTITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"

class HttpCheckoutFlowerGiftItem {
public:

	bool Parse(const Json::Value& root) {
        bool result = false;
		if( root.isObject() ) {
            
			/* giftId */
			if( root[LIVEROOM_CHECKOUT_GIFTLIST_GIFTID].isString() ) {
				giftId = root[LIVEROOM_CHECKOUT_GIFTLIST_GIFTID].asString();
			}
            
            /* giftName */
            if (root[LIVEROOM_CHECKOUT_GIFTLIST_GIFTNAME].isString()) {
                giftName = root[LIVEROOM_CHECKOUT_GIFTLIST_GIFTNAME].asString();
            }
            
            /* giftImg */
            if (root[LIVEROOM_CHECKOUT_GIFTLIST_GIFTIMG].isString()) {
                giftImg = root[LIVEROOM_CHECKOUT_GIFTLIST_GIFTIMG].asString();
            }
            
            /* giftNumber */
            if( root[LIVEROOM_CHECKOUT_GIFTLIST_GIFTNUMBER].isNumeric() ) {
                giftNumber = root[LIVEROOM_CHECKOUT_GIFTLIST_GIFTNUMBER].asInt();
            }
            
            /* giftPrice */
            if( root[LIVEROOM_CHECKOUT_GIFTLIST_GIFTPRICE].isNumeric() ) {
                giftPrice = root[LIVEROOM_CHECKOUT_GIFTLIST_GIFTPRICE].asDouble();
            }
            
            /* giftstatus */
            if( root[LIVEROOM_CHECKOUT_GIFTLIST_GIFTSTATUS].isNumeric() ) {
                giftstatus = root[LIVEROOM_CHECKOUT_GIFTLIST_GIFTSTATUS].asInt() == 0 ? false : true;
            }
            
            /* isGreetingCard */
            if( root[LIVEROOM_CHECKOUT_GIFTLIST_ISGREETINGCARD].isNumeric() ) {
                isGreetingCard = root[LIVEROOM_CHECKOUT_GIFTLIST_ISGREETINGCARD].asInt() == 0 ? false : true;
            }
            
            result = true;
        }
        return result;
    }

	HttpCheckoutFlowerGiftItem() {
		giftId = "";
        giftName = "";
        giftImg = "";
        giftNumber = 0;
        giftPrice = 0.0;
        giftstatus = false;
        isGreetingCard = false;
	}

	virtual ~HttpCheckoutFlowerGiftItem() {

	}
    
    /**
     * checkout鲜花礼品结构体
     * giftId               礼品ID
     * giftName             礼品名称
     * giftImg              礼品图片
     * giftNumber           礼品数量
     * giftPrice            礼品价格
     * giftstatus           是否可用
     * isGreetingCard       是否是贺卡
     */
	string giftId;
    string giftName;
    string giftImg;
    int giftNumber;
    double giftPrice;
    bool giftstatus;
    bool isGreetingCard;
};

typedef list<HttpCheckoutFlowerGiftItem> CheckoutFlowerGiftList;

#endif /* HTTPCHECKOUTFLOWERGIFTITEM_H_ */
