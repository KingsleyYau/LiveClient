/*
 * HttpVersionCheckItem.h
 *
 *  Created on: 2018-9-20
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTVERSIONCHECKITEM_H_
#define HTTVERSIONCHECKITEM_H_

#include <string>
#include <list>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"

class HttpVersionCheckItem {
public:
	void Parse(Json::Value root) {
		if( root.isObject() ) {
            if (root[LIVEROOM_VERSIONCHECK_VERCODE].isIntegral()) {
                versionCode = root[LIVEROOM_VERSIONCHECK_VERCODE].asInt();
            }
            if (root[LIVEROOM_VERSIONCHECK_VERNAME].isString()) {
                versionName = root[LIVEROOM_VERSIONCHECK_VERNAME].asString();
            }
            if (root[LIVEROOM_VERSIONCHECK_VERDESC].isString()) {
                versionDesc = root[LIVEROOM_VERSIONCHECK_VERDESC].asString();
            }
            if (root[LIVEROOM_VERSIONCHECK_FORCEUPDATE].isNumeric()) {
                isForceUpdate = root[LIVEROOM_VERSIONCHECK_FORCEUPDATE].asInt();
            }
            if (root[LIVEROOM_VERSIONCHECK_URL].isString()) {
                url = root[LIVEROOM_VERSIONCHECK_URL].asString();
            }
            if (root[LIVEROOM_VERSIONCHECK_STOREURL].isString()) {
                storeUrl = root[LIVEROOM_VERSIONCHECK_STOREURL].asString();
            }
            if (root[LIVEROOM_VERSIONCHECK_PUBTIME].isString()) {
                pubTime = root[LIVEROOM_VERSIONCHECK_PUBTIME].asString();
            }
            if (root[LIVEROOM_VERSIONCHECK_CHECKTIME].isIntegral()) {
                checkTime = root[LIVEROOM_VERSIONCHECK_CHECKTIME].asInt();
            }
        }
	}

	HttpVersionCheckItem() {
        versionCode = 0;
        versionName = "";
        versionDesc = "";
        isForceUpdate = false;
        url = "";
        storeUrl = "";
        pubTime = "";
        checkTime = 0;
	}
	virtual ~HttpVersionCheckItem() {

	}

	/**
	 * 更新版本信息
	 * versionCode			最新的客户端内部版本号
	 * versionName			客户端显示本号
	 * versionDesc			客户端描述
	 * isForceUpdate			是否强制升级（1：是，0：否）
	 * url			        客户端安装包下载URL
	 * storeUrl			    Store URL，客户端使用系统浏览器打开
	 * pubTime				客户端发布时间
	 * checkTime			    检测更新时间（Unix Timestamp）
	 */

	int versionCode;
	string versionName;
	string versionDesc;
	bool isForceUpdate;
	string url;
	string storeUrl;
    string pubTime;
    long checkTime;
};

#endif /* HTTVERSIONCHECKITEM_H_ */
