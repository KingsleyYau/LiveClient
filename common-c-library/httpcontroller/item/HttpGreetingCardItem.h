/*
 * HttpGreetingCardItem.h
 *
 *  Created on: 2019-8-29
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPGREETINGCARDITEM_H_
#define HTTPGREETINGCARDITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"

class HttpGreetingCardItem {
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
            
            /* giftNumber */
            if( root[LIVEROOM_CHECKOUT_GIFTLIST_GIFTNUMBER].isNumeric() ) {
                giftNumber = root[LIVEROOM_CHECKOUT_GIFTLIST_GIFTNUMBER].asInt();
            }
            /* isBirthday */
            if( root[LIVEROOM_CHECKOUT_GIFTLIST_ISBIRTHDAY].isNumeric() ) {
                isBirthday = root[LIVEROOM_CHECKOUT_GIFTLIST_ISBIRTHDAY].asInt() == 0 ? false : true;
            }
            
            /* giftPrice */
            if( root[LIVEROOM_CHECKOUT_GIFTLIST_GIFTPRICE].isNumeric() ) {
                giftPrice = root[LIVEROOM_CHECKOUT_GIFTLIST_GIFTPRICE].asDouble();
            }
            
            /* giftImg */
            if (root[LIVEROOM_CHECKOUT_GIFTLIST_GIFTIMG].isString()) {
                giftImg = root[LIVEROOM_CHECKOUT_GIFTLIST_GIFTIMG].asString();
            }
            
            result = true;
        }
        return result;
    }

	HttpGreetingCardItem() {
		giftId = "";
        giftName = "";
        giftNumber = 0;
        isBirthday = false;
        giftPrice = 0.0;
        giftImg = "";
	}

	virtual ~HttpGreetingCardItem() {

	}
    
    /**
     * 免费贺卡结构体
     * giftId               礼品ID
     * giftName             礼品名称
     * giftNumber           礼品数量
     * isBirthday           是否生日贺卡
     * giftPrice            原价
     * giftImg              图片地址
     */
	string giftId;
    string giftName;
    int giftNumber;
    bool isBirthday;
    double giftPrice;
    string giftImg;
};


#endif /* HTTPGREETINGCARDITEM_H_ */
