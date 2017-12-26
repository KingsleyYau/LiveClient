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
            
            /* anchorPage */
            if (root[LIVEROOM_ANCHOR_PAGE].isString()) {
                anchorPage = root[LIVEROOM_ANCHOR_PAGE].asString();
            }
            
            /* userLevel */
            if (root[LIVEROOM_USER_LEVEL].isString()) {
                userLevel = root[LIVEROOM_USER_LEVEL].asString();
            }
            
            /* intimacy */
            if (root[LIVEROOM_INTIMACY].isString()) {
                intimacy = root[LIVEROOM_INTIMACY].asString();
            }
            
            /* userProtocol */
            if (root[LIVEROOM_USERPROTOCOL].isString()) {
                userProtocol = root[LIVEROOM_USERPROTOCOL].asString();
            }
            
        }

        result = true;

        return result;
    }
    
    HttpConfigItem() {
        imSvrUrl = "";
        httpSvrUrl = "";
        addCreditsUrl = "";
        anchorPage = "";
        userLevel = "";
        intimacy = "";
        userProtocol = "";

    }
    
    virtual ~HttpConfigItem() {
        
    }
    /**
     * 同步配置结构体
     * imSvrUrl                   IM服务器ip或域名
     * httpSvrUrl                 http服务器ip或域名
     * addCreditsUrl		      充值页面URL
     * anchorPage                 主播资料页URL（请求时需要提交device参数，参数值与《1.1.http请求头格式》的“dev-type”一致）
     * userLevel                  观众等级页URL（请求时需要提交device参数，参数值与《1.1.http请求头格式》的“dev-type”一致）
     * intimacy                   观众与主播亲密度页URL（请求时需要提交device参数，参数值与《1.1.http请求头格式》的“dev-type”一致）
     * userProtocol               观众协议页URL
     */
    string imSvrUrl;
    string httpSvrUrl;
    string addCreditsUrl;
    string anchorPage;
    string userLevel;
    string intimacy;
    string userProtocol;
};

#endif /* HTTPCONFIGITEM_H_*/
