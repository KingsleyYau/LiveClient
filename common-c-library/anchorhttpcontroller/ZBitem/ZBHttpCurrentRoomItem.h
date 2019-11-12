/*
 * ZBHttpCurrentRoomItem.h
 *
 *  Created on: 2019-11-07
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef ZBHTTPCURRENTROOMITEM_H_
#define ZBHTTPCURRENTROOMITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "ZBHttpUserInfoItem.h"

class ZBHttpCurrentRoomItem {
public:
	void Parse(const Json::Value& root) {
		if( root.isObject() ) {
			/* anchorId */
			if( root[GETCURRENTROOMINFO_ANCHORID].isString() ) {
				anchorId = root[GETCURRENTROOMINFO_ANCHORID].asString();
			}
            
			/* roomId */
			if( root[GETCURRENTROOMINFO_ROOMID].isString() ) {
				roomId = root[GETCURRENTROOMINFO_ROOMID].asString();
			}

            /* roomType */
            if( root[GETCURRENTROOMINFO_ROOMTYPE].isIntegral() ) {
                roomType = GetIntToZBHttpRoomType(root[GETCURRENTROOMINFO_ROOMTYPE].asInt());
            }
            
            if (root[GETCURRENTROOMINFO_USERINFO].isObject()) {
                userInfo.Parse(root[GETCURRENTROOMINFO_USERINFO]);
            }
        }
	}

	ZBHttpCurrentRoomItem() {
		anchorId = "";
		roomId = "";
        roomType = ZBHTTPROOMTYPE_NOLIVEROOM;
	}

	virtual ~ZBHttpCurrentRoomItem() {

	}
    /**
     * 主播当前直播间信息
     * anchorId			主播ID
     * roomId           直播间ID
     * roomType		    直播间类型
     * userInfo         私密直播间男士信息
     */
    string anchorId;
    string roomId;
    ZBHttpRoomType roomType;
    ZBHttpUserInfoItem userInfo;
};


#endif /* ZBHTTPCURRENTROOMITEM_H_ */
