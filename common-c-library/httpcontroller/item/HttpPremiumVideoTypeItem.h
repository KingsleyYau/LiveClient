/*
 * HttpPremiumVideoTypeItem.h
 *
 *  Created on: 2020-08-03
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPPREMIUMVIDEOTYPEITEM_H_
#define HTTPPREMIUMVIDEOTYPEITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"

class HttpPremiumVideoTypeItem {
public:
	bool Parse(const Json::Value& root) {
        bool result = false;
		if( root.isObject() ) {
            
            /* typeId */
            if (root[LIVEROOM_PREMIUMVIDEO_TYPE_ID].isString()) {
                typeId = root[LIVEROOM_PREMIUMVIDEO_TYPE_ID].asString();
            }
            
            /* typeName */
            if (root[LIVEROOM_PREMIUMVIDEO_TYPE_NAME].isString()) {
                typeName = root[LIVEROOM_PREMIUMVIDEO_TYPE_NAME].asString();
            }
            
            /* isDefault */
            if( root[LIVEROOM_PREMIUMVIDEO_IS_DEFAULT].isNumeric() ) {
                isDefault = root[LIVEROOM_PREMIUMVIDEO_IS_DEFAULT].asInt() == 1 ? true : false;
            }
            
            if (!typeId.empty()) {
                result = true;
            }
                
        }
        
        return result;
	}

	HttpPremiumVideoTypeItem() {
		typeId = "";
		typeName = "";
        isDefault = false;
	}

	virtual ~HttpPremiumVideoTypeItem() {

	}
    /**
     * 付费视频分类结构体
     * typeId               分类ID
     * typeName        分类名称
     * typeName        是否默认选中
     */

    string typeId;
    string typeName;
    bool isDefault;

};

typedef list<HttpPremiumVideoTypeItem> PremiumVideoTypeList;

#endif /* HTTPPREMIUMVIDEOTYPEITEM_H_ */
