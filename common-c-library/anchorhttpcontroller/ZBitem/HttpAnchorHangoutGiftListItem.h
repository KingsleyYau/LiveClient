/*
 * HttpAnchorHangoutGiftListItem.h
 *
 *  Created on: 2018-4-4
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPANCHORHANGOUTGIFTLISTITEM_H_
#define HTTPANCHORHANGOUTGIFTLISTITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "HttpAnchorGiftNumItem.h"

class HttpAnchorHangoutGiftListItem {
public:
	void Parse(const Json::Value& root) {
		if( root.isObject() ) {
			/* buyforList */
			if( root[HANGOUTGIFTLIST_BUYFORLIST].isArray() ) {
                int i = 0;
                for (i = 0; i < root[HANGOUTGIFTLIST_BUYFORLIST].size(); i++) {
                    HttpAnchorGiftNumItem item;
                    item.Parse(root[HANGOUTGIFTLIST_BUYFORLIST].get(i, Json::Value::null));
                    buyforList.push_back(item);
                }
			}
            
            /* normalList */
            if( root[HANGOUTGIFTLIST_NORMALLIST].isArray() ) {
                int i = 0;
                for (i = 0; i < root[HANGOUTGIFTLIST_NORMALLIST].size(); i++) {
                    HttpAnchorGiftNumItem item;
                    item.Parse(root[HANGOUTGIFTLIST_NORMALLIST].get(i, Json::Value::null));
                    normalList.push_back(item);
                }
            }
            
            
            /* celebrationList */
            if( root[HANGOUTGIFTLIST_CELEBRATIONLIST].isArray() ) {
                int i = 0;
                for (i = 0; i < root[HANGOUTGIFTLIST_CELEBRATIONLIST].size(); i++) {
                    HttpAnchorGiftNumItem item;
                    item.Parse(root[HANGOUTGIFTLIST_CELEBRATIONLIST].get(i, Json::Value::null));
                    celebrationList.push_back(item);
                }
            }
            

            
        }
	}

	HttpAnchorHangoutGiftListItem() {

	}

	virtual ~HttpAnchorHangoutGiftListItem() {

	}
    /**
     * 多人互动直播间礼物列表
     * buyforList		    吧台礼物列表
     * normalList           连击礼物&大礼物列表
     * celebrationList      庆祝礼物列表
     */
    HttpAnchorGiftNumItemList buyforList;
	HttpAnchorGiftNumItemList normalList;
	HttpAnchorGiftNumItemList celebrationList;
};

#endif /* HTTPANCHORHANGOUTGIFTLISTITEM_H_ */
