/*
 * LSLCLoveCall.h
 *
 *  Created on: 2015-3-2
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LOVECALL_H_
#define LOVECALL_H_

#include <string>
using namespace std;


#include <json/json/json.h>

#include "../LSLiveChatRequestLoveCallDefine.h"

class LSLCLoveCall {
public:
	void Parse(Json::Value root) {
		if( root.isObject() ) {
			if( root[LOVECALL_QUERY_LIST_ORDERID].isString() ) {
				orderid = root[LOVECALL_QUERY_LIST_ORDERID].asString();
			}

			if( root[LOVECALL_QUERY_LIST_WOMANID].isString() ) {
				womanid = root[LOVECALL_QUERY_LIST_WOMANID].asString();
			}

			if( root[LOVECALL_QUERY_LIST_IMAGE].isString() ) {
				image = root[LOVECALL_QUERY_LIST_IMAGE].asString();
			}

			if( root[LOVECALL_QUERY_LIST_FIRSTNAME].isString() ) {
				firstname = root[LOVECALL_QUERY_LIST_FIRSTNAME].asString();
			}


			if( root[LOVECALL_QUERY_LIST_COUNTRY].isString() ) {
				country = root[LOVECALL_QUERY_LIST_COUNTRY].asString();
			}

			if( root[LOVECALL_QUERY_LIST_AGE].isInt() ) {
				age = root[LOVECALL_QUERY_LIST_AGE].asInt();
			}

			if( root[LOVECALL_QUERY_LIST_BEGINTIME].isInt() ) {
				begintime = root[LOVECALL_QUERY_LIST_BEGINTIME].asInt();
			}

			if( root[LOVECALL_QUERY_LIST_ENDTIME].isInt() ) {
				endtime = root[LOVECALL_QUERY_LIST_ENDTIME].asInt();
			}

			if( root[LOVECALL_QUERY_LIST_NEEDTR].isInt() ) {
				needtr = root[LOVECALL_QUERY_LIST_NEEDTR].asInt();
			}

			if( root[LOVECALL_QUERY_LIST_ISCONFIRM].isInt() ) {
				isconfirm = root[LOVECALL_QUERY_LIST_ISCONFIRM].asInt();
			}

			if( root[LOVECALL_QUERY_LIST_CONFIRMMSG].isString() ) {
				confirmmsg = root[LOVECALL_QUERY_LIST_CONFIRMMSG].asString();
			}

			if( root[LOVECALL_QUERY_LIST_CALLID].isString() ) {
				callid = root[LOVECALL_QUERY_LIST_CALLID].asString();
			}

			if ( root[LOVECALL_QUERY_LIST_CENTERID].isString() ) {
				centerid = root[LOVECALL_QUERY_LIST_CENTERID].asString();
			}
		}
	}

	LSLCLoveCall() {
		orderid = "";
		womanid = "";
		image = "";
		firstname = "";
		country = "";
		age = -1;
		begintime = -1;
		endtime = -1;
		needtr = false;
		isconfirm = false;
		confirmmsg = "";
		callid = "";
		centerid = "";
	}
	virtual ~LSLCLoveCall() {

	}

	/**
	 * 11.1.获取Love Call列表接口回调
	 * @param orderid			订单ID
	 * @param womanid			女士ID
	 * @param image				图片URL
	 * @param firstname			女士first name
	 * @param country			国家
	 * @param age				年龄
	 * @param begintime			打电话的起始时间（Unix Timestamp）
	 * @param endtime			打电话的结束时间（Unix Timestamp）
	 * @param needtr			是否需要翻译
	 * @param isconfirm			是否已确定
	 * @param confirmmsg		男士发给女士的确定消息
	 * @param callid			Love Call ID
	 * @param centerid			Call Center ID
	 */
	string orderid;
	string womanid;
	string image;
	string firstname;
	string country;
	int age;
	int begintime;
	int endtime;
	bool needtr;
	bool isconfirm;
	string confirmmsg;
	string callid;
	string centerid;
};

#endif /* LSLCLOVECALL_H_ */
