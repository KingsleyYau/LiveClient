/*
 * HttpAnchorHangoutItem.h
 *
 *  Created on: 2018-4-3
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPANCHORHANGOUTITEM_H_
#define HTTPANCHORHANGOUTITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "HttpAnchorBaseInfoItem.h"

class HttpAnchorHangoutItem {
public:
	void Parse(const Json::Value& root) {
		if( root.isObject() ) {
            
            /* userId */
            if( root[GETONGOINGHANGOUTLIST_HANGOUTLIST_USERID].isString() ) {
                userId = root[GETONGOINGHANGOUTLIST_HANGOUTLIST_USERID].asString();
            }
            
			/* nickName */
			if( root[GETONGOINGHANGOUTLIST_HANGOUTLIST_NICKNAME].isString() ) {
				nickName = root[GETONGOINGHANGOUTLIST_HANGOUTLIST_NICKNAME].asString();
			}

			/* photourl */
			if( root[GETONGOINGHANGOUTLIST_HANGOUTLIST_PHOTOURL].isString() ) {
				photoUrl = root[GETONGOINGHANGOUTLIST_HANGOUTLIST_PHOTOURL].asString();
			}
            
            if (root[GETONGOINGHANGOUTLIST_HANGOUTLIST_ANCHORLIST].isArray()) {
                int i = 0;
                for (i = 0; i < root[GETONGOINGHANGOUTLIST_HANGOUTLIST_ANCHORLIST].size(); i++) {
                    HttpAnchorBaseInfoItem item;
                    item.Parse(root[GETONGOINGHANGOUTLIST_HANGOUTLIST_ANCHORLIST].get(i, Json::Value::null));
                    anchorList.push_back(item);
                }
                
            }
            
            /* roomId */
            if( root[GETONGOINGHANGOUTLIST_HANGOUTLIST_ROOMID].isString() ) {
                roomId = root[GETONGOINGHANGOUTLIST_HANGOUTLIST_ROOMID].asString();
            }
            
        }
	}

	HttpAnchorHangoutItem() {
		userId = "";
		nickName = "";
		photoUrl = "";
        roomId = "";
	}

	virtual ~HttpAnchorHangoutItem() {

	}
    /**
     * 多人互动直播间列表结构体
     * userId           用户Id
     * nickName         用户昵称
     * photoUrl		    用户头像
     * anchorList       主播列表
     * roomId           直播间ID
     */
	string userId;
	string nickName;
	string photoUrl;
    HttpAnchorBaseInfoItemList anchorList;
    string roomId;
};

typedef list<HttpAnchorHangoutItem> HttpAnchorHangoutItemList;

#endif /* HTTPANCHORHANGOUTITEM_H_ */
