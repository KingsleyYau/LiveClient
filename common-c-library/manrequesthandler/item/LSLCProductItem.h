/*
 * LSLCProductItem.h
 *
 *  Created on: 2017-4-12
 *      Author: alex
 *        desc: 月费的文字说明
 */

#ifndef LSLCPRODUCTITEM_H_
#define LSLCPRODUCTITEM_H_

#include <string>
#include <list>
using namespace std;

#include <json/json/json.h>
#include "../LSLiveChatRequestMonthlyFeeDefine.h"

class LSLCProductItem {
public:

	void Parse(Json::Value root) {
		if( root.isObject() ) {
			/* 产品的id */
			if( root[MONTHLY_FEE_PREMIUM_ID].isString() ) {
				productId = root[MONTHLY_FEE_PREMIUM_ID].asString();
			}
			/* 产品的名称 */
			if( root[MONTHLY_FEE_PREMIUM_NAME].isString() ) {
				productName = root[MONTHLY_FEE_PREMIUM_NAME].asString();
			}
			/* 产品的价格 */
			if( root[MONTHLY_FEE_PREMIUM_PRICE].isString() ) {
				productPrice = root[MONTHLY_FEE_PREMIUM_PRICE].asString();
			}
		}
	}

	LSLCProductItem() {
		productId = "";
		productName = "";
		productPrice = "";
	}
	virtual ~LSLCProductItem() {

	}

	/**
	 * 登录成功回调
	 * @param productId				产品的id
	 * @param productName           产品的名称
	 * @param productPrice			产品的价格
	 */

	string productId;
	string productName;
	string productPrice;

};

typedef list<LSLCProductItem> ProductItemList;

#endif /* LSLCPRODUCTITEM_H_ */
