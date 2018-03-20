/*
 * ZBHttpConfigItem.h
 *
 *  Created on: 2018-2-28
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef ZBHTTPCONFIGITEM_H_
#define ZBHTTPCONFIGITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "ZBHttpSvrItem.h"

class ZBHttpConfigItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* imSvrUrl */
            if (root[GETCONFIG_IMSVR_URL].isString()) {
                imSvrUrl = root[GETCONFIG_IMSVR_URL].asString();
            }

            /* httpSvrUrl */
            if (root[GETCONFIG_HTTPSVR_URL].isString()) {
                httpSvrUrl = root[GETCONFIG_HTTPSVR_URL].asString();
            }

            /* mePageUrl */
            if (root[GETCONFIG_ME_PAGE_URL].isString()) {
                mePageUrl = root[GETCONFIG_ME_PAGE_URL].asString();
            }
            
            /* manPageUrl */
            if (root[GETCONFIG_MAN_PAGE_URL].isString()) {
                manPageUrl = root[GETCONFIG_MAN_PAGE_URL].asString();
            }
            
            /* minAavilableVer */
            if (root[GETCONFIG_MINAVAILABLEVER].isNumeric()) {
                minAavilableVer = root[GETCONFIG_MINAVAILABLEVER].asInt();
            }
            
            /* minAvailableMsg */
            if (root[GETCONFIG_MINAVAILABLEMSG].isString()) {
                minAvailableMsg = root[GETCONFIG_MINAVAILABLEMSG].asString();
            }
            /* newestVer */
            if (root[GETCONFIG_NEWEST_VER].isNumeric()) {
                newestVer = root[GETCONFIG_NEWEST_VER].asInt();
            }
            
            /* newestMsg */
            if (root[GETCONFIG_NEWEST_MSG].isString()) {
                newestMsg = root[GETCONFIG_NEWEST_MSG].asString();
            }
            
            /* downloadAppUrl */
            if (root[GETCONFIG_DOWNLOADAPPURL_MSG].isString()) {
                downloadAppUrl = root[GETCONFIG_DOWNLOADAPPURL_MSG].asString();
            }
            
            /* svrList */
            if( root[GETCONFIG_SVRLIST].isArray()) {
                for (int i = 0; i < root[GETCONFIG_SVRLIST].size(); i++) {
                    Json::Value element = root[GETCONFIG_SVRLIST].get(i, Json::Value::null);
                    ZBHttpSvrItem item;
                    if (item.Parse(element)) {
                        svrList.push_back(item);
                    }
                }
            }
            
        }

        result = true;

        return result;
    }
    
    ZBHttpConfigItem() {
        imSvrUrl = "";
        httpSvrUrl = "";
        mePageUrl = "";
        manPageUrl = "";
        minAavilableVer = 0;
        minAvailableMsg = "";
        newestVer = 0;
        newestMsg = "";
        downloadAppUrl = "";

    }
    
    virtual ~ZBHttpConfigItem() {
        
    }
    /**
     * 同步配置结构体
     * imSvrUrl                   IM服务器ip或域名
     * httpSvrUrl                 http服务器ip或域名
     * mePageUrl                  播个人中心页URL（请求时需要提交device参数，参数值与《1.1.http请求头格式》的“dev-type”一致）
     * manPageUrl                 男士资料页URL（请求时需要提交device参数，参数值与《1.1.http请求头格式》的“dev-type”一致）
     * minAavilableVer            App最低可用的内部版本号（整型）
     * minAvailableMsg            App强制升级提示
     * newestVer                  App最新的内部版本号（整型）
     * newestMsg                  App普通升级提示
     * downloadAppUrl             下载App的url
     * svrList                    流媒体服务器ID
     */
    string imSvrUrl;
    string httpSvrUrl;
    string mePageUrl;
    string manPageUrl;
    int minAavilableVer;
    string minAvailableMsg;
    int newestVer;
    string newestMsg;
    string downloadAppUrl;
    ZBSvrList svrList;
};

#endif /* ZBHTTPCONFIGITEM_H_*/
