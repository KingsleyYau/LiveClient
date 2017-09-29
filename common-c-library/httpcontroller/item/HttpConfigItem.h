/*
 * HttpConfigItem.h
 *
 *  Created on: 2017-8-18
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPCONFIGITEM_H_
#define HTTPCONFIGITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"

class HttpConfigItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* imSvrUrl */
            if (root[LIVEROOM_IMSVR_URL].isString()) {
                imSvrUrl = root[LIVEROOM_IMSVR_URL].asString();
            }

            /* httpSvrUrl */
            if (root[LIVEROOM_HTTPSVR_URL].isString()) {
                httpSvrUrl = root[LIVEROOM_HTTPSVR_URL].asString();
            }

            /* addCreditsUrl */
            if (root[LIVEROOM_ADDCREDITS_URL].isString()) {
                addCreditsUrl = root[LIVEROOM_ADDCREDITS_URL].asString();
            }
        }

        result = true;

        return result;
    }
    
    HttpConfigItem() {
        imSvrUrl = "";
        httpSvrUrl = "";
        addCreditsUrl = "";

    }
    
    virtual ~HttpConfigItem() {
        
    }
    /**
     * 有效邀请数组结构体
     * imSvrUrl                   IM服务器ip或域名
     * httpSvrUrl                 http服务器ip或域名
     * addCreditsUrl		        充值页面URL
     */
    string imSvrUrl;
    string httpSvrUrl;
    string addCreditsUrl;
};

#endif /* HTTPCONFIGITEM_H_*/
