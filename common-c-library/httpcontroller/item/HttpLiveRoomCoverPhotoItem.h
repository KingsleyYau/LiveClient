/*
 * HttpLiveRoomCoverPhotoItem.h
 *
 *  Created on: 2017-5-23
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LIVEROOMCOVERPHOTOITEM_H_
#define LIVEROOMCOVERPHOTOITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"

class HttpLiveRoomCoverPhotoItem {
public:
	void Parse(const Json::Value& root) {
		if( root.isObject() ) {
			/* photoId */
			if( root[LIVEROOM_PUBLIC_PHOTOID].isString() ) {
				photoId = root[LIVEROOM_PUBLIC_PHOTOID].asString();
			}
            
			/* photoUrl */
			if( root[LIVEROOM_PHOTOLIST_PHOTOURL].isString() ) {
				photoUrl = root[LIVEROOM_PHOTOLIST_PHOTOURL].asString();
			}

            /* status */
            if( root[LIVEROOM_PHOTOLIST_STATUS].isInt() ) {
                status = (ExamineStatus)root[LIVEROOM_PHOTOLIST_STATUS].asInt();
            }
            
            /* isIn_use */
            if( root[LIVEROOM_PHOTOLIST_INUSE].isInt() ) {
                isIn_use = root[LIVEROOM_PHOTOLIST_INUSE].asInt();
            }

        }
    }

	/**
	 * 封面图结构体
	 * @param photoId			封面图ID
	 * @param photoUrl          封面图url
	 * @param status		    审核状态（1.待审核， 2.通过 3.否决）
     * @param isIn_use			是否正在使用
     */
	HttpLiveRoomCoverPhotoItem() {
		photoId = "";
		photoUrl = "";
		status = EXAMINE_STATUS_WAITING;
        isIn_use = false;

	}

	virtual ~HttpLiveRoomCoverPhotoItem() {

	}

	string photoId;
	string photoUrl;
    ExamineStatus status;
    bool isIn_use;
};

typedef list<HttpLiveRoomCoverPhotoItem> CoverPhotoItemList;

#endif /* LIVEROOMCOVERPHOTOITEM_H_ */
