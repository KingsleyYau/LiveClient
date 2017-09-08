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
            /* imSvrIp */
            if (root[LIVEROOM_IMSVR_IP].isString()) {
                imSvrIp = root[LIVEROOM_IMSVR_IP].asString();
            }
            /* imSvrPort */
            if (root[LIVEROOM_IMSVR_PORT].isInt()) {
                imSvrPort = root[LIVEROOM_IMSVR_PORT].asInt();
            }
            /* httpSvrIp */
            if (root[LIVEROOM_HTTPSVR_IP].isString()) {
                httpSvrIp = root[LIVEROOM_HTTPSVR_IP].asString();
            }
            /* httpSvrPort */
            if (root[LIVEROOM_HTTPSVR_PORT].isInt()) {
                httpSvrPort = root[LIVEROOM_HTTPSVR_PORT].asInt();
            }
            /* uploadSvrIp */
            if (root[LIVEROOM_UPLOADSVR_IP].isString()) {
                uploadSvrIp = root[LIVEROOM_UPLOADSVR_IP].asString();
            }
            /* uploadSvrPort */
            if (root[LIVEROOM_UPLOADSVR_PORT].isInt()) {
                uploadSvrPort = root[LIVEROOM_UPLOADSVR_PORT].asInt();
            }
            /* addCreditsUrl */
            if (root[LIVEROOM_ADDCREDITS_URL].isString()) {
                addCreditsUrl = root[LIVEROOM_ADDCREDITS_URL].asString();
            }
        }
        if (!imSvrIp.empty()) {
            result = true;
        }
        return result;
    }
    
    HttpConfigItem() {
        imSvrIp = "";
        imSvrPort = 0;
        httpSvrIp = "";
        httpSvrPort = 0;
        uploadSvrIp = "";
        uploadSvrPort = 0;
        addCreditsUrl = "";

    }
    
    virtual ~HttpConfigItem() {
        
    }
    /**
     * 有效邀请数组结构体
     * imSvrIp                   IM服务器ip或域名
     * imSvrPort                 IM服务器端口
     * httpSvrIp                 http服务器ip或域名
     * httpSvrPort		        http服务器端口
     * uploadSvrIp		        上传图片服务器ip或域名
     * uploadSvrPort		        上传图片服务器端口
     * addCreditsUrl		        充值页面URL
     */
    string imSvrIp;
    int    imSvrPort;
    string httpSvrIp;
    int    httpSvrPort;
    string uploadSvrIp;
    int    uploadSvrPort;
    string addCreditsUrl;
};

#endif /* HTTPCONFIGITEM_H_*/
