/*
 * LSLCLady.h
 *
 *  Created on: 2015-3-2
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LSLCLADY_H_
#define LSLCLADY_H_

#include <string>
using namespace std;


#include <json/json/json.h>

#include "../LSLiveChatRequestLadyDefine.h"
#include "../LSLiveChatRequestEnumDefine.h"

class LSLCLady {
public:
	void Parse(Json::Value root) {
		if( root.isObject() ) {
			if( root[LADY_AGE].isInt() ) {
				age = root[LADY_AGE].asInt();
			}

			if( root[LADY_WOMAN_ID].isString() ) {
				womanid = root[LADY_WOMAN_ID].asString();
			}

			if( root[LADY_FIRST_NAME].isString() ) {
				firstname = root[LADY_FIRST_NAME].asString();
			}

			if( root[LADY_WEIGHT].isString() ) {
				weight = root[LADY_WEIGHT].asString();
			}

			if( root[LADY_HEIGHT].isString() ) {
				height = root[LADY_HEIGHT].asString();
			}

			if( root[LADY_COUNTRY].isString() ) {
				country = root[LADY_COUNTRY].asString();
                countryIndex = GetCountryCode(country);
			}

			if( root[LADY_PROVINCE].isString() ) {
				province = root[LADY_PROVINCE].asString();
			}

			if( root[LADY_PHOTO_URL].isString() ) {
				photoURL = root[LADY_PHOTO_URL].asString();
			}

			if ( root[LADY_ONLINE_STATUS].isInt() ) {
				int status = root[LADY_ONLINE_STATUS].asInt();
				onlineStatus = (LADY_OSTATUS_BEGIN <= status && status <= LADY_OSTATUS_END
										? (LadyOnlineStatus)status : LADY_OSTATUS_DEFAULT);
			}

			if( root[LADY_CAN_CAM].isInt() ) {
				int status = root[LADY_CAN_CAM].asInt();
				camStatus = (status == 1)?true:false;
			}
            
            if( root[LADY_ISFAVORITE].isNumeric() ) {
                isFavorite = root[LADY_ISFAVORITE].asInt() == 0 ? false : true;
                
            }
		}
	}

	LSLCLady() {
		age = 0;
		womanid = "";
		firstname = "";
		weight = "";
		height = "";
		country = "";
        countryIndex = GetOtherCountryCode();
		province = "";
		photoURL = "";
		onlineStatus = LADY_OSTATUS_DEFAULT;
		camStatus = false;
        isFavorite = false;
	}
	virtual ~LSLCLady() {

	}

	/**
	 * 女士列表成功回调
	 * @param age			年龄
	 * @param womanid		女士ID
	 * @param firstname		女士first name
	 * @param weight		重量
	 * @param height		高度
	 * @param country		国家
	 * @param province		省份
	 * @param photoURL		图片URL
	 * @param onlineStatus	在线状态
	 * @param camStatus     Cam是否打开
     * @param isFavorite    是否收藏
	 */
	int age;
	string womanid;
	string firstname;
	string weight;
	string height;
	string country;
    int countryIndex;
	string province;
	string photoURL;
	LadyOnlineStatus onlineStatus;
	bool camStatus;
    bool isFavorite;
};

#endif /* LSLCLADY_H_ */
