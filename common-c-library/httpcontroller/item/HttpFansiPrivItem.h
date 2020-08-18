/*
 * HttpFansiPrivItem.h
 *
 *  Created on: 2020-08-04
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPFANSIPRIVITEM_H_
#define HTTPFANSIPRIVITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"

class HttpFansiPrivItem {
public:
	void Parse(const Json::Value& root) {
		if( root.isObject() ) {
            
            /* premiumVideoPriv */
            if( root[LIVEROOM_GETUSRRINFO_FANSIINFO_PRIV_PREMIUM_VIDEO].isNumeric() ) {
                premiumVideoPriv = root[LIVEROOM_GETUSRRINFO_FANSIINFO_PRIV_PREMIUM_VIDEO].asInt() == 1 ? true : false;
            }
            
        }
	}

	HttpFansiPrivItem() {
		premiumVideoPriv = false;
	}

	virtual ~HttpFansiPrivItem() {

	}
    /**
     * 观众权限结构体
     * premiumVideoPriv              是否有付费视频权限
     */

    bool premiumVideoPriv;

};

#endif /* HTTPFANSIPRIVITEM_H_ */
