/*
 * HttpGiftTypeItem.h
 *
 *  Created on: 2019-8-27
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPGIFTTYPEITEM_H_
#define HTTPGIFTTYPEITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"

class HttpGiftTypeItem {
public:

	void Parse(const Json::Value& root) {
		if( root.isObject() ) {
			/* typeId */
			if( root[LIVEROOM_GETTYPELIST_TYPEID].isString() ) {
				typeId = root[LIVEROOM_GETTYPELIST_TYPEID].asString();
			}
            
			/* typeName */
			if( root[LIVEROOM_GETTYPELIST_TYPENAME].isString() ) {
				typeName = root[LIVEROOM_GETTYPELIST_TYPENAME].asString();
			}
        }
    }

	HttpGiftTypeItem() {
		typeId = "";
		typeName = "";
	}

	virtual ~HttpGiftTypeItem() {

	}
    
    /**
     * 虚拟礼物分类列表结构体
     * typeId	    类型ID
     * typeName     类型名称
     */
    string typeId;
	string typeName;
};

typedef list<HttpGiftTypeItem> GiftTypeList;

#endif /* HTTPGIFTTYPEITEM_H_ */
