/*
 * HttpLiveRoomViewerItem.h
 *
 *  Created on: 2017-5-22
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LIVEROOMVIEWERITEM_H_
#define LIVEROOMVIEWERITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"

class HttpLiveRoomViewerItem {
public:
	void Parse(const Json::Value& root) {
		if( root.isObject() ) {
			/* userId */
			if( root[LIVEROOM_VIEWER_USERID].isString() ) {
				userId = root[LIVEROOM_VIEWER_USERID].asString();
			}
            
			/* nickName */
			if( root[LIVEROOM_VIEWER_NICK_NAME].isString() ) {
				nickName = root[LIVEROOM_VIEWER_NICK_NAME].asString();
			}

			/* photourl */
			if( root[LIVEROOM_VIEWER_PHOTO_URL].isString() ) {
				photoUrl = root[LIVEROOM_VIEWER_PHOTO_URL].asString();
			}

		}
	}

	/**
	 * 登录成功结构体
	 * @param userId			观众ID
	 * @param nickName          观众昵称
	 * @param photoUrl		    观众头像url
	 */
	HttpLiveRoomViewerItem() {
		userId = "";
		nickName = "";
		photoUrl = "";
	}

	virtual ~HttpLiveRoomViewerItem() {

	}

	string userId;
	string nickName;
	string photoUrl;
};

typedef list<HttpLiveRoomViewerItem> ViewerItemList;

#endif /* LIVEROOMVIEWERITEM_H_ */
