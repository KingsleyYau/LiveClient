/*
 * HttpStoreFlowerGiftItem.h
 *
 *  Created on: 2019-8-27
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPSTOREFLOWERGIFTITEM_H_
#define HTTPSTOREFLOWERGIFTITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"
#include "HttpFlowerGiftItem.h"

class HttpStoreFlowerGiftItem {
public:

	void Parse(const Json::Value& root) {
		if( root.isObject() ) {
			/* typeId */
			if( root[LIVEROOM_GETSTOREGIFTLIST_TYPEID].isString() ) {
				typeId = root[LIVEROOM_GETSTOREGIFTLIST_TYPEID].asString();
			}
            
			/* typeName */
			if( root[LIVEROOM_GETSTOREGIFTLIST_TYPENAME].isString() ) {
				typeName = root[LIVEROOM_GETSTOREGIFTLIST_TYPENAME].asString();
			}
            
            /* isHasGreeting */
            if (root[LIVEROOM_GETSTOREGIFTLIST_ISHASGREETING].isNumeric()) {
                isHasGreeting = root[LIVEROOM_GETSTOREGIFTLIST_ISHASGREETING].asInt() == 0 ? false : true;
            }
            
            /* giftList */
            if( root[LIVEROOM_GETSTOREGIFTLIST_GIFTLIST].isArray()) {
                for (int i = 0; i < root[LIVEROOM_GETSTOREGIFTLIST_GIFTLIST].size(); i++) {
                    Json::Value element = root[LIVEROOM_GETSTOREGIFTLIST_GIFTLIST].get(i, Json::Value::null);
                    HttpFlowerGiftItem item;
                    if (item.Parse(element)) {
                        giftList.push_back(item);
                    }
                }
            }
        }
    }

	HttpStoreFlowerGiftItem() {
		typeId = "";
		typeName = "";
        isHasGreeting = false;
	}

	virtual ~HttpStoreFlowerGiftItem() {

	}
    
    /**
     * 商店的鲜花礼品列表结构体
     * typeId	        类型ID
     * typeName         类型名称
     * isHasGreeting    是否有免费贺卡
     * giftList         礼品列表
     */
    string typeId;
	string typeName;
    bool isHasGreeting;
    FlowerGiftList giftList;
};

typedef list<HttpStoreFlowerGiftItem> StoreFlowerGiftList;

#endif /* HTTPSTOREFLOWERGIFTITEM_H_ */
