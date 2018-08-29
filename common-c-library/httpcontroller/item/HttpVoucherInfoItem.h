/*
 * HttpVoucherInfoItem.h
 *
 *  Created on: 2018-1-24
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPVOUCHERINFOITEM_H_
#define HTTPVOUCHERINFOITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../HttpLoginProtocol.h"

typedef list<string> WatchAnchorList;

class HttpVoucherInfoItem {
public:
    class BindAnchorItem {
    public:
        bool Parse(const Json::Value& root) {
            bool result = false;
            /* anchorId */
            if (root[LIVEROOM_GETVOUCHERAVAILABLEINFO_BINDANCHOR_ANCHORID].isString()) {
                anchorId = root[LIVEROOM_GETVOUCHERAVAILABLEINFO_BINDANCHOR_ANCHORID].asString();
            }
            /* useRoomType */
            if (root[LIVEROOM_GETVOUCHERAVAILABLEINFO_BINDANCHOR_USEROOMTYPE].isNumeric()) {
                useRoomType = GetIntToUseRoomType(root[LIVEROOM_GETVOUCHERAVAILABLEINFO_BINDANCHOR_USEROOMTYPE].asInt());
            }
            /* expTime */
            if (root[LIVEROOM_GETVOUCHERAVAILABLEINFO_BINDANCHOR_EXPTIME].isNumeric()) {
                expTime = root[LIVEROOM_GETVOUCHERAVAILABLEINFO_BINDANCHOR_EXPTIME].asInt();
            }
            
            result = true;
            return result;
        }
        
        BindAnchorItem() {
            anchorId = "";
            useRoomType = USEROOMTYPE_LIMITLESS;
            expTime = 0;
        }
        
        virtual ~BindAnchorItem() {
            
        }
        /**
         *  绑定主播
         *  anchorId       主播ID
         *  useRoomType    可用的直播间类型（0：不限，1：公开，2：私密）
         *  expTime        试用券到期时间（1970年起的秒数）
         */
        string      anchorId;
        UseRoomType useRoomType;
        long        expTime;
    };
    
     typedef list<BindAnchorItem> BindAnchorList;
    
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* onlypublicExpTime */
            if (root[LIVEROOM_GETVOUCHERAVAILABLEINFO_ONLYPUBLICEXPTIME].isNumeric()) {
                onlypublicExpTime = root[LIVEROOM_GETVOUCHERAVAILABLEINFO_ONLYPUBLICEXPTIME].asInt();
            }
            /* onlyprivateExpTime */
            if (root[LIVEROOM_GETVOUCHERAVAILABLEINFO_ONLYPRIVATEEXPTIME].isNumeric()) {
                onlyprivateExpTime = root[LIVEROOM_GETVOUCHERAVAILABLEINFO_ONLYPRIVATEEXPTIME].asInt();
            }
            
            /* bindAnchor */
            if( root[LIVEROOM_GETVOUCHERAVAILABLEINFO_BINDANCHOR].isArray()) {
                for (int i = 0; i < root[LIVEROOM_GETVOUCHERAVAILABLEINFO_BINDANCHOR].size(); i++) {
                    Json::Value element = root[LIVEROOM_GETVOUCHERAVAILABLEINFO_BINDANCHOR].get(i, Json::Value::null);
                    BindAnchorItem item;
                    if (item.Parse(element)) {
                        bindAnchor.push_back(item);
                    }
                }
            }
            
            /* onlypublicNewExpTime */
            if (root[LIVEROOM_GETVOUCHERAVAILABLEINFO_ONLYPUBLICNEWANCHOREXPTIME].isNumeric()) {
                onlypublicNewExpTime = root[LIVEROOM_GETVOUCHERAVAILABLEINFO_ONLYPUBLICNEWANCHOREXPTIME].asInt();
            }
            /* onlyprivateNewExpTime */
            if (root[LIVEROOM_GETVOUCHERAVAILABLEINFO_ONLYPRIVATENEWANCHOREXPTIME].isNumeric()) {
                onlyprivateNewExpTime = root[LIVEROOM_GETVOUCHERAVAILABLEINFO_ONLYPRIVATENEWANCHOREXPTIME].asInt();
            }
  
            /* watchedAnchor */
            if (root[LIVEROOM_GETVOUCHERAVAILABLEINFO_WATCHEDANCHOR].isArray()) {
                for (int i = 0; i < root[LIVEROOM_GETVOUCHERAVAILABLEINFO_WATCHEDANCHOR].size(); i++) {
                    Json::Value element = root[LIVEROOM_GETVOUCHERAVAILABLEINFO_WATCHEDANCHOR].get(i, Json::Value::null);
                    if (element.isObject()) {
                        if (element[LIVEROOM_GETVOUCHERAVAILABLEINFO_WATCHEDANCHOR_ANCHORID].isString()) {
                            string anchorId = element[LIVEROOM_GETVOUCHERAVAILABLEINFO_WATCHEDANCHOR_ANCHORID].asString();
                            watchedAnchor.push_back(anchorId);
                        }
                        
                    }
                }
                
            }
            
        }
        result = true;
        return result;
    }

    HttpVoucherInfoItem() {
        onlypublicExpTime = 0;
        onlyprivateExpTime = 0;
        onlypublicNewExpTime = 0;
        onlyprivateNewExpTime = 0;
    }
    
    virtual ~HttpVoucherInfoItem() {
        
    }
    
    /**
     * 试用券可用列表结构体
     * onlypublicExpTime            仅公开直播（且不限制主播且不限制新关系）试用券到期时间（1970年起的秒数）
     * onlyprivateExpTime           仅私密直播（且不限制主播且不限制新关系）试用券到期时间（1970年起的秒数）
     * bindAnchor                   绑定主播列表
     * onlypublicNewExpTime         仅公开的新关系试用券到期时间（1970年起的秒数）
     * onlyprivateNewExpTime		仅私密的新关系试用券到期时间（1970年起的秒数）
     * watchedAnchor                我看过的主播列表
     */
    long   onlypublicExpTime;
    long   onlyprivateExpTime;
    BindAnchorList bindAnchor;
    long   onlypublicNewExpTime;
    long   onlyprivateNewExpTime;
    WatchAnchorList watchedAnchor;
};

#endif /* HTTPVOUCHERINFOITEM_H_*/
