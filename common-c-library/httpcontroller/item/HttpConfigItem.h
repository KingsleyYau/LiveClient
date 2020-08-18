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
#include "HttpMailTariffItem.h"

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
                    hangoutCredirMsg = element[LIVEROOM_HANGOUT_CREDITPERMINUTE].asString();
                }
                if (element[LIVEROOM_HANGOUT_CREDITPRICE].isNumeric()) {
                    hangoutCreditPrice = element[LIVEROOM_HANGOUT_CREDITPRICE].asDouble();
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
            
            /* loiH5Url */
            if (root[LIVEROOM_LOIHURL].isString()) {
                loiH5Url = root[LIVEROOM_LOIHURL].asString();
            }
            
            /* emfH5Url */
            if (root[LIVEROOM_EMFHURL].isString()) {
                emfH5Url = root[LIVEROOM_EMFHURL].asString();
            }
            
            /* pmStartNotice */
            if (root[LIVEROOM_PMSTARTNOTICE].isString()) {
                pmStartNotice = root[LIVEROOM_PMSTARTNOTICE].asString();
            }
            
            /* postStampUrl */
            if (root[LIVEROOM_POSTSTAMPURL].isString()) {
                postStampUrl = root[LIVEROOM_POSTSTAMPURL].asString();
            }
            
            /* httpSvrMobileUrl */
            if (root[LIVEROOM_HTTPSVR_MOBILE_URL].isString()) {
                httpSvrMobileUrl = root[LIVEROOM_HTTPSVR_MOBILE_URL].asString();
            }
            
            /* socketHost */
            if (root[LIVEROOM_SOCKET_HOST].isString()) {
                socketHost = root[LIVEROOM_SOCKET_HOST].asString();
            }
            
            /* socketHostDomain */
            if (root[LIVEROOM_SOCKET_HOST_DOMAIN].isString()) {
                socketHostDomain = root[LIVEROOM_SOCKET_HOST_DOMAIN].asString();
            }
            
            /* socketPort */
            if (root[LIVEROOM_SOCKET_PORT].isNumeric()) {
                socketPort = root[LIVEROOM_SOCKET_PORT].asInt();
            }
            
            /* minBalanceForChat */
            if (root[LIVEROOM_MIN_BALANCE_FOR_CHAT].isString()) {
                minBalanceForChat = atof(root[LIVEROOM_MIN_BALANCE_FOR_CHAT].asString().c_str());
            }
            
            /* chatVoiceHostUrl */
            if (root[LIVEROOM_CHAT_VOICE_HOSTURL].isString()) {
                chatVoiceHostUrl = root[LIVEROOM_CHAT_VOICE_HOSTURL].asString();
            }
            
            /* sendLetter */
            if (root[LIVEROOM_SEND_LETTER].isString()) {
                sendLetter = root[LIVEROOM_SEND_LETTER].asString();
            }
            
            /* flowersGift */
            if (root[LIVEROOM_FLOWERS_GIFT].isNumeric()) {
                flowersGift = root[LIVEROOM_FLOWERS_GIFT].asInt();
            }
            
            /* scheduleSaveUp */
            if (root[LIVEROOM_SCHEDULE_SAVE_UP].isNumeric()) {
                scheduleSaveUp = root[LIVEROOM_SCHEDULE_SAVE_UP].asInt();
            }
            
            /* mailTariff */
            if (root[LIVEROOM_MAIL_TARIFF].isObject()) {
                mailTariff.Parse(root[LIVEROOM_MAIL_TARIFF]);
            }
            
            /* premiumVideoCredit */
            if (root[LIVEROOM_PREMIUM_VIDEO_CREDIT].isNumeric()) {
                premiumVideoCredit = root[LIVEROOM_PREMIUM_VIDEO_CREDIT].asDouble();
            }
            
            /* howItWorkUrl */
            if (root[LIVEROOM_HOWITWORKURL].isString()) {
                howItWorkUrl = root[LIVEROOM_HOWITWORKURL].asString();
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
        hangoutCreditPrice = 0.0;
        showDetailPage = "";
        showDescription = "";
        loiH5Url = "";
        emfH5Url = "";
        pmStartNotice = "";
        postStampUrl = "";
        httpSvrMobileUrl = "";
        socketHost = "";
        socketHostDomain = "";
        socketPort = 0;
        minBalanceForChat = 0.0;
        chatVoiceHostUrl = "";
        sendLetter = "";
        flowersGift = 0;
        scheduleSaveUp = 0;
        premiumVideoCredit = 0.0;
        howItWorkUrl = "";
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
     * hangoutCreditPrice         多人互动信用点资费价格
     * showDetailPage              节目详情页URL
     * showDescription             节目介绍
     * loiH5Url                     意向信页URL
     * emfH5Url                     EMF页URL
     * pmStartNotice                私信聊天界面没有聊天记录时的提示（New）
     * postStampUrl                 背包邮票页URL
     * httpSvrMobileUrl             http mobile服务器的URL（包括mobile.charmlive.com或demo-mobile.charmlive.com）
     * socketHost                   LiveChat服务器IP
     * socketHostDomain             sLiveChat服务器域名
     * socketPort                   LiveChat服务器端口
     * minBalanceForChat            使用LiveChat的最少点数
     * chatVoiceHostUrl             LiveChat上传/下载语音的URL
     * sendLetter                   发送信件页URL
     * flowersGift                  鲜花礼品的优惠价
     * scheduleSaveUp        预付费最大优惠折扣
     * mailTariff                   信件资费相关
     * premiumVideoCredit  付费视频信用点
     * howItWorkUrl
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
    double hangoutCreditPrice;
    string showDetailPage;
    string showDescription;
    string loiH5Url;
    string emfH5Url;
    string pmStartNotice;
    string postStampUrl;
    string httpSvrMobileUrl;
    string socketHost;
    string socketHostDomain;
    int socketPort;
    double minBalanceForChat;
    string chatVoiceHostUrl;
    string sendLetter;
    int flowersGift;
    int scheduleSaveUp;
    HttpMailTariffItem mailTariff;
    double premiumVideoCredit;
    string howItWorkUrl;
};

#endif /* HTTPCONFIGITEM_H_*/
