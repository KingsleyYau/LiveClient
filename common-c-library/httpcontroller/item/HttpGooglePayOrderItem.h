/*
 * HttpGooglePayOrderItem.h
 *
 *  Created on: 2020-04-10
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPGOOGLEPAYORDERITEM_H_
#define HTTPGOOGLEPAYORDERITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"

class HttpGooglePayOrderItem {
public:
	void Parse(const Json::Value& root) {
		if( root.isObject() ) {
            
            /* orderNo */
            if (root[LIVEROOM_APPPAY_ORDERNO].isString()) {
                orderNo = root[LIVEROOM_APPPAY_ORDERNO].asString();
            }
            
            /* productId */
            if (root[LIVEROOM_APPPAY_PRODUCTID].isString()) {
                productId = root[LIVEROOM_APPPAY_PRODUCTID].asString();
            }

            /* orderTime */
            if (root[LIVEROOM_APPPAY_ORDERTIME].isNumeric()) {
                orderTime = root[LIVEROOM_APPPAY_ORDERTIME].asLong();
            }
            
            /* serverTime */
            if (root[LIVEROOM_APPPAY_SERVERTIME].isNumeric()) {
                serverTime = root[LIVEROOM_APPPAY_SERVERTIME].asLong();
            }
            
        }
	}

	HttpGooglePayOrderItem() {
        orderNo = "";
        productId = "";
        orderTime = 0;
        serverTime = 0;
	}

	virtual ~HttpGooglePayOrderItem() {

	}
    /**
     * 订单号结构体
     * orderNo                  订单号
     * productId                产品号
     * orderTime             订单生成时间（时间戳）
     * serverTime          当前服务器时间（时间戳）
     */

    string orderNo;
    string productId;
    long long orderTime;
    long long serverTime;

};

#endif /* HTTPGOOGLEPAYORDERITEM_H_ */
