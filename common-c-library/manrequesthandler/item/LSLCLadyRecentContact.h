/*
 * LSLCLadyRecentContact.h
 *
 *  Created on: 2015-04-21
 *      Author: Samson Fan
 */

#ifndef LSLCLADYRECENTCONTACT_H_
#define LSLCLADYRECENTCONTACT_H_

#include <string>
using namespace std;


#include <json/json/json.h>

#include "../LSLiveChatRequestLadyDefine.h"

class LSLCLadyRecentContact {
public:
	bool Parse(Json::Value root) {
		bool result = false;
		if( root.isObject() ) {
			if( root[LADY_WOMAN_ID].isString() ) {
				womanId = root[LADY_WOMAN_ID].asString().c_str();
			}

			if( root[LADY_FIRST_NAME].isString() ) {
				firstname = root[LADY_FIRST_NAME].asString().c_str();
			}

			if( root[LADY_AGE].isIntegral() ) {
				age = root[LADY_AGE].asInt();
			}

			if( root[LADY_PHOTO_URL].isString() ) {
				photoURL = root[LADY_PHOTO_URL].asString().c_str();
			}

			if( root[LADY_PHOTO_BIG_URL].isString() ) {
				photoBigURL = root[LADY_PHOTO_BIG_URL].asString().c_str();
			}

			if( root[LADY_ISFAVORITE].isIntegral() ) {
				isFavorite = (root[LADY_ISFAVORITE].asInt() == 1 ? true : false);
			}

			if( root[LADY_VIDEOCOUNT].isIntegral() ) {
				videoCount = root[LADY_VIDEOCOUNT].asInt();
			}

			if( root[LADY_LASTTIME].isIntegral() ) {
				lasttime = root[LADY_LASTTIME].asInt();
			}

			if( root[LADY_CAN_CAM].isInt() ) {
				int status = root[LADY_CAN_CAM].asInt();
				camStatus = (status == 1)?true:false;
			}
		}

		if (!womanId.empty()) {
			result = true;
		}

		return result;
	}

	LSLCLadyRecentContact() {
		womanId = "";
		firstname = "";
		age = 0;
		photoURL = "";
		photoBigURL = "";
		isFavorite = false;
		videoCount = 0;
		lasttime = 0;
		camStatus = false;
	}

	virtual ~LSLCLadyRecentContact() {

	}

	string womanId;
	string firstname;
	int age;
	string photoURL;
	string photoBigURL;
	bool isFavorite;
	int videoCount;
	long lasttime;
	bool camStatus;
};

#endif /* LSLCLADYRECENTCONTACT_H_ */
