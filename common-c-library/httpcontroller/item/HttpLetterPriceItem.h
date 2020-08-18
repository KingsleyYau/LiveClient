/*
 * HttpLetterPriceItem.h
 *
 *  Created on: 2020-04-10
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPLETTERPRICEITEM_H_
#define HTTPLETTERPRICEITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"

class HttpLetterPriceItem {
public:
	void Parse(const Json::Value& root) {
		if( root.isObject() ) {
            
            /* creditPrice */
            if( root[LIVEROOM_MAIL_TATIFF_MAIL_SEND_BASE_CREDIT_PRICE].isNumeric() ) {
                creditPrice = root[LIVEROOM_MAIL_TATIFF_MAIL_SEND_BASE_CREDIT_PRICE].asDouble();
            }
            
            /* stampPrice */
            if( root[LIVEROOM_MAIL_TATIFF_MAIL_SEND_BASE_STAMP_PRICE].isNumeric() ) {
                stampPrice = root[LIVEROOM_MAIL_TATIFF_MAIL_SEND_BASE_STAMP_PRICE].asDouble();
            }
            
        }
	}

	HttpLetterPriceItem() {
		creditPrice = 0.0;
		stampPrice = 0.0;
	}

	virtual ~HttpLetterPriceItem() {

	}
    /**
     * 信件价格结构体
     * creditPrice             所需的信用点
     * stampPrice           所需的邮票
     */

    double creditPrice;
    double stampPrice;

};

#endif /* HTTPLETTERPRICEITEM_H_ */
