/*
 * HttpHangoutGiftListItem.h
 *
 *  Created on: 2018-4-12
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPHANGOUTGIFTLISTITEM_H_
#define HTTPHANGOUTGIFTLISTITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"

typedef list<string> BuyForGiftList;

class HttpHangoutGiftListItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* buyforList */
            if (root[LIVEROOM_HANGOUTGIFTLIST_BUYFORLIST].isArray()) {
                int i = 0;
                for (i = 0; i < root[LIVEROOM_HANGOUTGIFTLIST_BUYFORLIST].size(); i++) {
                    Json::Value element = root[LIVEROOM_HANGOUTGIFTLIST_BUYFORLIST].get(i, Json::Value::null);
                    if (element[LIVEROOM_HANGOUTGIFTLIST_BUYFORLIST_ID].isString()) {
                        string giftId = element[LIVEROOM_HANGOUTGIFTLIST_BUYFORLIST_ID].asString();
                        buyforList.push_back(giftId);
                    }
                }
            }
            /* normalList */
            if (root[LIVEROOM_HANGOUTGIFTLIST_NORMALLIST].isArray()) {
                int i = 0;
                for (i = 0; i < root[LIVEROOM_HANGOUTGIFTLIST_NORMALLIST].size(); i++) {
                    Json::Value element = root[LIVEROOM_HANGOUTGIFTLIST_NORMALLIST].get(i, Json::Value::null);
                    if (element[LIVEROOM_HANGOUTGIFTLIST_BUYFORLIST_ID].isString()) {
                        string giftId = element[LIVEROOM_HANGOUTGIFTLIST_BUYFORLIST_ID].asString();
                        normalList.push_back(giftId);
                    }
                }
            }
            /* celebrationList */
            if (root[LIVEROOM_HANGOUTGIFTLIST_CELEBRATIONLIST].isArray()) {
                int i = 0;
                for (i = 0; i < root[LIVEROOM_HANGOUTGIFTLIST_CELEBRATIONLIST].size(); i++) {
                    Json::Value element = root[LIVEROOM_HANGOUTGIFTLIST_CELEBRATIONLIST].get(i, Json::Value::null);
                    if (element[LIVEROOM_HANGOUTGIFTLIST_BUYFORLIST_ID].isString()) {
                        string giftId = element[LIVEROOM_HANGOUTGIFTLIST_BUYFORLIST_ID].asString();
                        celebrationList.push_back(giftId);
                    }
                }
            }


        }
        result = true;
        return result;
    }

    HttpHangoutGiftListItem() {

    }
    
    virtual ~HttpHangoutGiftListItem() {
        
    }
    
    /**
     * 多人互动的主播列表结构体
     * buyforList         吧台礼物列表
     * normalList         连击礼物及大礼物列表
     * celebrationList    庆祝礼物列表
     */
    BuyForGiftList   buyforList;
    BuyForGiftList   normalList;
    BuyForGiftList   celebrationList;

};


#endif /* HTTPHANGOUTGIFTLISTITEM_H_*/
