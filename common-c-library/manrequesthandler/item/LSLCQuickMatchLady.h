/*
 * LSLCQuickMatchLady.h
 *
 *  Created on: 2015-3-2
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LSLCQUICKMATCHLADY_H_
#define LSLCQUICKMATCHLADY_H_

#include <string>
using namespace std;


#include <json/json/json.h>

#include "../LSLiveChatRequestQuickMatchDefine.h"

class LSLCQuickMatchLady {
public:
	void Parse(Json::Value root) {
		if( root.isObject() ) {
			if( root[QUICKMATCH_QUERY_AGE].isInt() ) {
				age = root[QUICKMATCH_QUERY_AGE].asInt();
			}

			if( root[QUICKMATCH_QUERY_WOMANID].isString() ) {
				womanid = root[QUICKMATCH_QUERY_WOMANID].asString();
			}

			if( root[QUICKMATCH_QUERY_FIRSTNAME].isString() ) {
				firstname = root[QUICKMATCH_QUERY_FIRSTNAME].asString();
			}

			if( root[QUICKMATCH_QUERY_COUNTRY].isString() ) {
				country = root[QUICKMATCH_QUERY_COUNTRY].asString();
			}

			if( root[QUICKMATCH_QUERY_IMAGE].isString() ) {
				image = root[QUICKMATCH_QUERY_IMAGE].asString();
			}

			if( root[QUICKMATCH_QUERY_PHOTOURL].isString() ) {
				photoURL = root[QUICKMATCH_QUERY_PHOTOURL].asString();
			}
		}
	}

	LSLCQuickMatchLady() {
		age = 0;
		womanid = "";
		firstname = "";
		country = "";
		image = "";
		photoURL = "";
	}

	virtual ~LSLCQuickMatchLady() {

	}

	/**
	 * 获取女士列表回调
	 * @param age			年龄
	 * @param womanid		女士ID
	 * @param firstname		女士first name
	 * @param country		国家
	 * @param image			图片URL
	 * @param photoURL		头像URL
	 */

	int age;
	string womanid;
	string firstname;
	string country;
	string image;
	string photoURL;
};

#endif /* LSLCQUICKMATCHLADY_H_ */
