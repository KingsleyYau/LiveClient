/*
 * HttpAnchorBaseInfoItem.h
 *
 *  Created on: 2018-4-3
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPANCHORBASEINFOITEM_H_
#define HTTPANCHORBASEINFOITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../ZBHttpLoginProtocol.h"

class HttpAnchorBaseInfoItem {
public:
	void Parse(const Json::Value& root) {
		if( root.isObject() ) {
			/* anchorId */
			if( root[GETONGOINGHANGOUTLIST_HANGOUTLIST_ANCHORLIST_ANCHORID].isString() ) {
				anchorId = root[GETONGOINGHANGOUTLIST_HANGOUTLIST_ANCHORLIST_ANCHORID].asString();
			}
            
			/* nickName */
			if( root[GETONGOINGHANGOUTLIST_HANGOUTLIST_ANCHORLIST_ANCHORNICKNAME].isString() ) {
				nickName = root[GETONGOINGHANGOUTLIST_HANGOUTLIST_ANCHORLIST_ANCHORNICKNAME].asString();
			}

			/* photoUrl */
			if( root[GETONGOINGHANGOUTLIST_HANGOUTLIST_ANCHORLIST_ANCHORPHOTOURL].isString() ) {
				photoUrl = root[GETONGOINGHANGOUTLIST_HANGOUTLIST_ANCHORLIST_ANCHORPHOTOURL].asString();
			}
            
        }
	}

	HttpAnchorBaseInfoItem() {
		anchorId = "";
		nickName = "";
		photoUrl = "";
	}

	virtual ~HttpAnchorBaseInfoItem() {

	}
    /**
     * 主播列表结构体
     * anchorId			主播ID
     * nickName         昵称
     * photoUrl		    头像url
     */
    string anchorId;
	string nickName;
	string photoUrl;
};

typedef list<HttpAnchorBaseInfoItem> HttpAnchorBaseInfoItemList;

#endif /* HTTPANCHORBASEINFOITEM_H_ */
