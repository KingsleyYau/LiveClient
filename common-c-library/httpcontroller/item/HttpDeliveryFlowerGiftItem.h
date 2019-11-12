/*
 * HttpDeliveryFlowerGiftItem.h
 *
 *  Created on: 2019-8-27
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPDELIVERYFLOWERGIFTITEM_H_
#define HTTPDELIVERYFLOWERGIFTITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"

typedef list<string> CountryList;
class HttpDeliveryFlowerGiftItem {
public:

	bool Parse(const Json::Value& root) {
        bool result = false;
		if( root.isObject() ) {
            
			/* giftId */
			if( root[LIVEROOM_GETSTOREGIFTLIST_GIFTLIST_GIFTID].isString() ) {
				giftId = root[LIVEROOM_GETSTOREGIFTLIST_GIFTLIST_GIFTID].asString();
			}
            
            /* giftName */
            if (root[LIVEROOM_GETSTOREGIFTLIST_GIFTLIST_GIFTNAME].isString()) {
                giftName = root[LIVEROOM_GETSTOREGIFTLIST_GIFTLIST_GIFTNAME].asString();
            }
            
            /* giftImg */
            if (root[LIVEROOM_GETSTOREGIFTLIST_GIFTLIST_GIFTIMG].isString()) {
                giftImg = root[LIVEROOM_GETSTOREGIFTLIST_GIFTLIST_GIFTIMG].asString();
            }
            
            /* giftNumber */
            if( root[LIVEROOM_GETDELIVERYLIST_LIST_GIFTLIST_GIFTNUMBER].isNumeric() ) {
                giftNumber = root[LIVEROOM_GETDELIVERYLIST_LIST_GIFTLIST_GIFTNUMBER].asInt();
            }
            
            /* giftPrice */
            if( root[LIVEROOM_GETCARTGIFTLIST_LIST_GIFTLIST_GIFTPRICE].isNumeric() ) {
                giftPrice = root[LIVEROOM_GETCARTGIFTLIST_LIST_GIFTLIST_GIFTPRICE].asDouble();
            }
            
            result = true;
        }
        return result;
    }

	HttpDeliveryFlowerGiftItem() {
		giftId = "";
        giftName = "";
        giftImg = "";
        giftNumber = 0;
        giftPrice = 0.0;
	}

	virtual ~HttpDeliveryFlowerGiftItem() {

	}
    
    /**
     * Delivery鲜花礼品结构体
     * giftId               礼品ID
     * giftName             礼品名称
     * giftImg              礼品图片
     * giftNumber           礼品数量
     * giftPrice            礼品价格
     */
	string giftId;
    string giftName;
    string giftImg;
    int giftNumber;
    double giftPrice;
};

typedef list<HttpDeliveryFlowerGiftItem> DeliveryFlowerGiftList;

#endif /* HTTPDELIVERYFLOWERGIFTITEM_H_ */
