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

#define TYPEID_DELIMITED    ","                    // 分隔符
typedef list<string> GiftTypeIdList;

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
            /* typeIdList */
            if ( root[LIVEROOM_GETGIFTLISTBYUSERID_TYPEID].isString()) {
                string typeId = "";
                typeId = root[LIVEROOM_GETGIFTLISTBYUSERID_TYPEID].asString();
                size_t pos = 0;
                do {
                    size_t cur = typeId.find(TYPEID_DELIMITED, pos);
                    if (cur != string::npos) {
                        string temp = typeId.substr(pos, cur - pos);
                        if (!temp.empty()) {
                            typeIdList.push_back(temp);
                        }
                        pos = cur + 1;
                    }
                    else {
                        string temp = typeId.substr(pos);
                        if (!temp.empty()) {
                            typeIdList.push_back(temp);
                        }
                        break;
                    }
                } while(true);
                
            }
            /* isFree */
            if ( root[LIVEROOM_GETGIFTLISTBYUSERID_ISFREE].isNumeric()) {
                isFree = root[LIVEROOM_GETGIFTLISTBYUSERID_ISFREE].asInt() == 1 ? true : false;
            }
        }
    }

	HttpGiftWithIdItem() {
        giftId = "";
        isShow = false;
        isPromo = false;
        isFree = false;
	}
    
    HttpGiftWithIdItem(const HttpGiftWithIdItem& giftItem) {
        giftId = giftItem.giftId;
        isShow = giftItem.isShow;
        isPromo = giftItem.isPromo;
        isFree = giftItem.isFree;
        for (GiftTypeIdList::const_iterator typeIter = giftItem.typeIdList.begin(); typeIter != giftItem.typeIdList.end(); typeIter++) {
            string temp = (*typeIter);
            if (!temp.empty()) {
                typeIdList.push_back(temp);
            }
        }
    }

	virtual ~HttpGiftWithIdItem() {

	}
    
    /**
     * 礼物显示结构体
     * giftId       礼物ID
     * isShow       是否在礼物列表显示（0:否 1:是） （不包括背包礼物列表）
     * isPromo      是否推荐礼物（0:否 1:是）（不包括背包礼物列表）
     * typeIdList   分类ID（多个用，隔开）
     * isFree       是否免费
     */
    string      giftId;
    bool        isShow;
    bool        isPromo;
    GiftTypeIdList      typeIdList;
    bool        isFree;
};

typedef list<HttpGiftWithIdItem> GiftWithIdItemList;

#endif /* HTTPGIFTITEM_H_ */
