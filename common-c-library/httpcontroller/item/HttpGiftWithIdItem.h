/*
 * HttpGiftWithIdItem.h
 *
 *  Created on: 2017-8-28
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPGIFTITEM_H_
#define HTTPGIFTITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

class HttpGiftWithIdItem {
public:
	void Parse(const Json::Value& root) {
		if( root.isObject() ) {
            /* giftId */
            if( root[LIVEROOM_GIFTINFO_ID].isString() ) {
                giftId = root[LIVEROOM_GIFTINFO_ID].asString();
            }
            /* isShow */
            if( root[LIVEROOM_GETGIFTLISTBYUSERID_ISHOW].isIntegral() ) {
                isShow = root[LIVEROOM_GETGIFTLISTBYUSERID_ISHOW].asInt() == 1 ? true : false;
            }
            /* isPromo */
            if( root[LIVEROOM_GETGIFTLISTBYUSERID_ISPROMO].isIntegral() ) {
                isPromo = root[LIVEROOM_GETGIFTLISTBYUSERID_ISPROMO].asInt() == 1 ? true : false;
            }
            
        }
    }

	HttpGiftWithIdItem() {
        giftId = "";
        isShow = false;
        isPromo = false;
	}

	virtual ~HttpGiftWithIdItem() {

	}
    
    /**
     * 礼物显示结构体
     * giftId   礼物ID
     * isShow   是否在礼物列表显示（0:否 1:是） （不包括背包礼物列表）
     * isPromo  是否推荐礼物（0:否 1:是）（不包括背包礼物列表）
     */
    string      giftId;
    bool        isShow;
    bool        isPromo;
};

typedef list<HttpGiftWithIdItem> GiftWithIdItemList;

#endif /* HTTPGIFTITEM_H_ */
