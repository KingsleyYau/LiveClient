/*
 * LSLCVideoItem.h
 *
 *  Created on: 2015-3-2
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LSLCVIDEOITEM_H_
#define LSLCVIDEOITEM_H_

#include <string>
using namespace std;


#include <json/json/json.h>

#include "../LSLiveChatRequestLadyDefine.h"

class LSLCVideoItem {
public:
	void Parse(Json::Value root) {
		if( root.isObject() ) {
			if( root[LADY_VIDEO_ID].isString() ) {
				id = root[LADY_VIDEO_ID].asString();
			}

			if( root[LADY_VIDEO_THUMB].isString() ) {
				thumb = root[LADY_VIDEO_THUMB].asString();
			}

			if( root[LADY_VIDEO_TIME].isString() ) {
				time = root[LADY_VIDEO_TIME].asString();
			}

			if( root[LADY_VIDEO_PHOTO].isString() ) {
				photo = root[LADY_VIDEO_PHOTO].asString();
			}
		}
	}

	LSLCVideoItem() {
		id = "";
		thumb = "";
		time = "";
		photo = "";
	}
	virtual ~LSLCVideoItem() {

	}

	string id;
	string thumb;
	string time;
	string photo;

};

#endif /* LSLCVIDEOITEM_H_ */
