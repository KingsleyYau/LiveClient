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
#include "HttpLoginItem.h"

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
            
            /* termsOfUse */
            if (root[LIVEROOM_TERMSOFUSE].isString()) {
                termsOfUse = root[LIVEROOM_TERMSOFUSE].asString();
            }
            
            /* privacyPolicy */
            if (root[LIVEROOM_PRIVACYPOLICY].isString()) {
                privacyPolicy = root[LIVEROOM_PRIVACYPOLICY].asString();
            }
            
            /* minAavilableVer */
            if (root[LIVEROOM_MINAVAILABLEVER].isNumeric()) {
                minAavilableVer = root[LIVEROOM_MINAVAILABLEVER].asInt();
            }
            
            /* minAvailableMsg */
            if (root[LIVEROOM_MINAVAILABLEMSG].isString()) {
                minAvailableMsg = root[LIVEROOM_MINAVAILABLEMSG].asString();
            }
            /* newestVer */
            if (root[LIVEROOM_NEWEST_VER].isNumeric()) {
                newestVer = root[LIVEROOM_NEWEST_VER].asInt();
            }
            
            /* newestMsg */
            if (root[LIVEROOM_NEWEST_MSG].isString()) {
                newestMsg = root[LIVEROOM_NEWEST_MSG].asString();
            }
            
            /* downloadAppUrl */
            if (root[LIVEROOM_DOWNLOADAPPURL_MSG].isString()) {
                downloadAppUrl = root[LIVEROOM_DOWNLOADAPPURL_MSG].asString();
            }
            
            /* svrList */
            if( root[LIVEROOM_SVRLIST].isArray()) {
                for (int i = 0; i < root[LIVEROOM_SVRLIST].size(); i++) {
                    Json::Value element = root[LIVEROOM_SVRLIST].get(i, Json::Value::null);
                    HttpLoginItem::SvrItem item;
                    if (item.Parse(element)) {
                        svrList.push_back(item);
                    }
                }
            }
            
            /* hangoutCredirMsg */
            if (root[LIVEROOM_HANGOUT].isObject()) {
                Json::Value element = root[LIVEROOM_HANGOUT];
                if (element[LIVEROOM_HANGOUT_CREDITPERMINUTE].isString()) {
                    hangoutCredirMsg = element[hangoutCredirMsg].asString();
                }
            }
            
            /* showDetailPage */
            if (root[LIVEROOM_SHOWDETAILPAGE].isString()) {
                showDetailPage = root[LIVEROOM_SHOWDETAILPAGE].asString();
            }
            
            /* showDescription */
            if (root[LIVEROOM_SHOWDESCRIPTION].isString()) {
                showDescription = root[LIVEROOM_SHOWDESCRIPTION].asString();
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
        termsOfUse = "";
        privacyPolicy = "";
        minAavilableVer = 0;
        minAvailableMsg = "";
        newestVer = 0;
        newestMsg = "";
        downloadAppUrl = "";
        hangoutCredirMsg = "";
        showDetailPage = "";
        showDescription = "";
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
     * termsOfUse                 使用条款URL（仅独立）
     * privacyPolicy              私隐政策URL（仅独立）
     * minAavilableVer            App最低可用的内部版本号（整型）
     * minAvailableMsg            App强制升级提示
     * newestVer                  App最新的内部版本号（整型）
     * newestMsg                  App普通升级提示
     * downloadAppUrl             下载App的url
     * svrList                    流媒体服务器ID
     * hangoutCredirMsg           多人互动资费提示
     * showDetailPage              节目详情页URL
     * showDescription             节目介绍
     */
    string imSvrUrl;
    string httpSvrUrl;
    string addCreditsUrl;
    string anchorPage;
    string userLevel;
    string intimacy;
    string userProtocol;
    string termsOfUse;
    string privacyPolicy;
    int minAavilableVer;
    string minAvailableMsg;
    int newestVer;
    string newestMsg;
    string downloadAppUrl;
    HttpLoginItem::SvrList svrList;
    string hangoutCredirMsg;
    string showDetailPage;
    string showDescription;
};

#endif /* HTTPCONFIGITEM_H_*/
