/*
 * LSLCLadyDetail.cpp
 *
 *  Created on: 2015-3-2
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#include "LSLCLadyDetail.h"
#include "../LSLiveChatRequestEnumDefine.h"
#include <common/StringHandle.h>

void LSLCLadyDetail::Parse(Json::Value root) {
	if( root.isObject() ) {
		if( root[LADY_WOMAN_ID].isString() ) {
			womanid = root[LADY_WOMAN_ID].asString();
		}

		if( root[LADY_FIRST_NAME].isString() ) {
			firstname = root[LADY_FIRST_NAME].asString();
		}

		if( root[LADY_COUNTRY].isString() ) {
			country = root[LADY_COUNTRY].asString();
            countryIndex = GetCountryCode(country);
		}

		if( root[LADY_PROVINCE].isString() ) {
			province = root[LADY_PROVINCE].asString();
		}

		if( root[LADY_AGE].isInt() ) {
			age = root[LADY_AGE].asInt();
		}

		if( root[LADY_ZODIAC].isString() ) {
			zodiac = root[LADY_ZODIAC].asString();
		}

		if( root[LADY_WEIGHT].isString() ) {
			weight = root[LADY_WEIGHT].asString();
		}

		if( root[LADY_HEIGHT].isString() ) {
			height = root[LADY_HEIGHT].asString();
		}

		if( root[LADY_SMOKE].isString() ) {
			smoke = root[LADY_SMOKE].asString();
		}

		if( root[LADY_DRINK].isString() ) {
			drink = root[LADY_DRINK].asString();
		}

		if( root[LADY_ENGLISH].isString() ) {
			english = root[LADY_ENGLISH].asString();
		}

		if( root[LADY_RELIGION].isString() ) {
			religion = root[LADY_RELIGION].asString();
		}

		if( root[LADY_EDUCATION].isString() ) {
			education = root[LADY_EDUCATION].asString();
		}

		if( root[LADY_PROFESSION].isString() ) {
			profession = root[LADY_PROFESSION].asString();
		}

		if( root[LADY_CHILDREN].isString() ) {
			children = root[LADY_CHILDREN].asString();
		}

		if( root[LADY_MARRY].isString() ) {
			marry = root[LADY_MARRY].asString();
		}

		if( root[LADY_RESUME].isString() ) {
			resume = root[LADY_RESUME].asString();
		}

		if( root[LADY_AGE_RANGE_FROM].isInt() ) {
			age1 = root[LADY_AGE_RANGE_FROM].asInt();
		}

		if( root[LADY_AGE_RANGE_TO].isInt() ) {
			age2 = root[LADY_AGE_RANGE_TO].asInt();
		}

		if( root[LADY_ISONLINE].isInt() ) {
			isonline = (root[LADY_ISONLINE].asInt() == 0)?false:true;
		}

		if( root[LADY_ISFAVORITE].isInt() ) {
			isfavorite = (root[LADY_ISFAVORITE].asInt() == 0)?false:true;
		}

		if( root[LADY_LAST_UPDATE].isString() ) {
			last_update = root[LADY_LAST_UPDATE].asString();
		}

		if( root[LADY_SHOW_LOVECALL].isInt() ) {
			show_lovecall = root[LADY_SHOW_LOVECALL].asInt();
		}

		if( root[LADY_PHOTO_URL].isString() ) {
			photoURL = root[LADY_PHOTO_URL].asString();
		}

		if( root[LADY_MIN_PHOTO_URL].isString() ) {
			photoMinURL = root[LADY_MIN_PHOTO_URL].asString();
		}

		if( root[LADY_PHOTOURLLIST].isString() ) {
			string listString = root[LADY_PHOTOURLLIST].asString();
			photoList = StringHandle::split(listString, ",");
		}

		if( root[LADY_THUMBURLLIST].isString() ) {
			string listString = root[LADY_THUMBURLLIST].asString();
			thumbList = StringHandle::split(listString, ",");
		}

		if( root[LADY_VIDEOURLLIST].isArray() ) {
			for(int i = 0; i < root[LADY_VIDEOURLLIST].size(); i++ ) {
				LSLCVideoItem item;
				item.Parse(root[LADY_VIDEOURLLIST].get(i, Json::Value::null));
				videoList.push_back(item);
			}
		}

		if( root[LADY_PHOTOLOCKNUM].isInt() ) {
			photoLockNum = root[LADY_PHOTOLOCKNUM].asInt();
		}

		if( root[LADY_CAN_CAM].isInt() ) {
			int status = root[LADY_CAN_CAM].asInt();
			camStatus = (status == 1)?true:false;
		}
	}
}

LSLCLadyDetail::LSLCLadyDetail() {
	womanid = "";
	firstname = "";
	country = "";
    countryIndex = GetOtherCountryCode();
	province = "";
	birthday = "";
	age = 0;
	zodiac = "";
	weight = "";
	height  = "";
	smoke = "";
	drink = "";
	english = "";
	religion = "";
	education = "";
	profession = "";
	children = "";
	marry = "";
	resume = "";
	age1 = 0;
	age2 = 0;
	isonline = false;
	isfavorite = false;
	last_update = "";
	show_lovecall = 0;
	photoURL = "";
	photoMinURL = "";
	photoLockNum = 0;
	camStatus = false;
}

LSLCLadyDetail::~LSLCLadyDetail() {

}
