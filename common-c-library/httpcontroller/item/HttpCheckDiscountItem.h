/*
 * HttpCheckDiscountItem.h
 *
 *  Created on: 2019-11-29
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPCHECKDISCOUNTITEM_H_
#define HTTPCHECKDISCOUNTITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"

class HttpCheckDiscountItem {
public:

	bool Parse(const Json::Value& root) {
        bool result = false;
		if( root.isObject() ) {
            
            /* type */
            if (root[LIVEROOM_CHECKDISCOUNT_TYPE].isNumeric()) {
                type = GetLSDiscountTypeWithInt(root[LIVEROOM_CHECKDISCOUNT_TYPE].asInt());
            }
            
            /* name */
            if (root[LIVEROOM_CHECKDISCOUNT_NAME].isString()) {
                name = root[LIVEROOM_CHECKDISCOUNT_NAME].asString();
            }
            
            /* discount */
            if (root[LIVEROOM_CHECKDISCOUNT_DISCOUNT].isNumeric()) {
                discount = root[LIVEROOM_CHECKDISCOUNT_DISCOUNT].asDouble();
            }
            
            /* imgUrl */
            if (root[LIVEROOM_CHECKDISCOUNT_IMGURL].isString()) {
                imgUrl = root[LIVEROOM_CHECKDISCOUNT_IMGURL].asString();
            }
            result = true;
        }
        return result;
    }

	HttpCheckDiscountItem() {
        type = LSDISCOUNTTYPE_UNKNOW;
        name = "";
        discount = 0.0;
        imgUrl = "";
	}

	virtual ~HttpCheckDiscountItem() {

	}
    
    /**
     * 优惠折扣结构体
     * type               优惠折扣类型
     * name               优惠折扣名称
     * discount           折扣
     * imgUrl             图标图片地址
     */
    LSDiscountType type;
    string name;
    double discount;
    string imgUrl;
    
};

#endif /* HTTPCHECKDISCOUNTITEM_H_ */
