/*
 * LSLCLadySignListItem.h
 *
 *  Created on: 2015-04-21
 *      Author: Samson Fan
 */

#ifndef LSLCLADYSIGNLISTITEM_H_
#define LSLCLADYSIGNLISTITEM_H_

#include <string>
using namespace std;


#include <json/json/json.h>

#include "../LSLiveChatRequestLadyDefine.h"

class LSLCLadySignListItem {
public:
	bool Parse(Json::Value root) {
		bool result = false;
		if( root.isObject() ) {
			if( root[LADY_SIGNID].isString() ) {
				signId = root[LADY_SIGNID].asString();
			}

			if( root[LADY_SIGNNAME].isString() ) {
				name = root[LADY_SIGNNAME].asString();
			}

			if( root[LADY_SIGNCOLOR].isString() ) {
				color = root[LADY_SIGNCOLOR].asString();
			}

			if( root[LADY_ISSIGNED].isIntegral() ) {
				isSigned = (root[LADY_ISSIGNED].asInt() == 1 ? true : false);
			}
		}

		if ( signId.length() > 0 ) {
			result = true;
		}

		return result;
	}

	LSLCLadySignListItem() {
		signId = "";
		name = "";
		color = "";
		isSigned = false;
	}

	virtual ~LSLCLadySignListItem() {

	}

	string signId;
	string name;
	string color;
	bool isSigned;
};

#endif /* LSLCLADYSIGNLISTITEM_H_ */
