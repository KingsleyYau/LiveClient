/*
 * LSLCCheckServerItem.h
 *
 *  Created on: 2015-3-6
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LSLCCHECKSERVERITEM_H_
#define LSLCCHECKSERVERITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../LSLiveChatRequestFakeDefine.h"

class LSLCCheckServerItem {
public:
	void Parse(Json::Value root) {
		if( root.isObject() ) {
			/* webhost */
			if( root[FAKE_WEBHOST].isString() ) {
				webhost = root[FAKE_WEBHOST].asString();
			}
            
            /* apphost */
            if( root[FAKE_APPHOST].isString() ) {
                apphost = root[FAKE_APPHOST].asString();
            }
            
            /* waphost */
            if( root[FAKE_WAPHOST].isString() ) {
                waphost = root[FAKE_WAPHOST].asString();
            }

            /* pay api */
			if( root[FAKE_PAY_API].isString() ) {
				pay_api = root[FAKE_PAY_API].asString();
			}
            
            /* fake */
            if( root[FAKE_FAKE].isInt() ) {
                fake = root[FAKE_FAKE].asInt();
            }
		}
	}

	LSLCCheckServerItem() {
		webhost = "";
		apphost = "";
        waphost = "";
		pay_api = "";
        fake = 0;
	}
	virtual ~LSLCCheckServerItem() {

	}

	/**
	 * 检查真假服务器成功回调
	 * @param webhost				web域名
	 * @param apphost				app域名
	 * @param waphost               wap域名
     * @param pay_api               支付地址
	 */
	string webhost;
    string apphost;
    string waphost;
	string pay_api;
    bool fake;

};

#endif /* LSLCCheckServerItem_H_ */
