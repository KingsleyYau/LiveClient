/*
 * HttpFansiInfoItem.h
 *
 *  Created on: 2020-08-04
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPFANSIINFOITEM_H_
#define HTTPFANSIINFOITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "HttpFansiPrivItem.h"


class HttpFansiInfoItem {
public:
	void Parse(const Json::Value& root) {
		if( root.isObject() ) {
            
            if ( root[LIVEROOM_GETUSRRINFO_FANSIINFO_PRIV].isObject()) {
                fansiPriv.Parse(root[LIVEROOM_GETUSRRINFO_FANSIINFO_PRIV]);
            }
            
        }
	}

	HttpFansiInfoItem() {

	}

	virtual ~HttpFansiInfoItem() {

	}
    /**
     * 观众信息结构体
     * fansiPriv             观众权限
     */

    HttpFansiPrivItem fansiPriv;
};

#endif /* HTTPFANSIINFOITEM_H_ */
