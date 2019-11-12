/*
 * HttpRecipientAnchorItem.h
 *
 *  Created on: 2019-8-27
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPRECIPIENTANCHORITEM_H_
#define HTTPRECIPIENTANCHORITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"

class HttpRecipientAnchorItem {
public:

	bool Parse(const Json::Value& root) {
        bool result = false;
		if( root.isObject() ) {
			/* anchorId */
			if( root[LIVEROOM_GETRESENTRECIPIENTLIST_LIST_ANCHORID].isString() ) {
				anchorId = root[LIVEROOM_GETRESENTRECIPIENTLIST_LIST_ANCHORID].asString();
			}
            
			/* anchorNickName */
			if( root[LIVEROOM_GETRESENTRECIPIENTLIST_LIST_ANCHORNICKNAME].isString() ) {
				anchorNickName = root[LIVEROOM_GETRESENTRECIPIENTLIST_LIST_ANCHORNICKNAME].asString();
			}
            
            /* anchorAvatarImg */
            if( root[LIVEROOM_GETRESENTRECIPIENTLIST_LIST_ANCHORAVATARIMG].isString() ) {
                anchorAvatarImg = root[LIVEROOM_GETRESENTRECIPIENTLIST_LIST_ANCHORAVATARIMG].asString();
            }
            
            /* anchorAge */
            if (root[LIVEROOM_GETRESENTRECIPIENTLIST_LIST_ANCHORAGE].isNumeric()) {
                anchorAge = root[LIVEROOM_GETRESENTRECIPIENTLIST_LIST_ANCHORAGE].asInt();
            }
            
            result = true;
        }
        return result;
    }

	HttpRecipientAnchorItem() {
		anchorId = "";
		anchorNickName = "";
        anchorAvatarImg = "";
        anchorAge = 0;
	}

	virtual ~HttpRecipientAnchorItem() {

	}
    
    /**
     * Recipient主播列表结构体
     * anchorId	            主播ID
     * anchorNickName       主播昵称
     * anchorAvatarImg      主播头像
     * anchorAge            主播年龄
     */
    string anchorId;
	string anchorNickName;
    string anchorAvatarImg;
    int anchorAge;
};

typedef list<HttpRecipientAnchorItem> RecipientAnchorList;

#endif /* HTTPRECIPIENTANCHORITEM_H_ */
