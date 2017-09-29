/*
 * HttpBackGiftItem.h
 *
 *  Created on: 2017-8-17
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPBACKGIFTITEM_H_
#define HTTPBACKGIFTITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "HttpGiftInfoItem.h"

//typedef list<int> HttpSendNumList;
class HttpBackGiftItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* giftId */
            if (root[LIVEROOM_BACKPACK_GIFT_LIST_GIFTID].isString()) {
                giftId = root[LIVEROOM_BACKPACK_GIFT_LIST_GIFTID].asString();
            }

            /* num */
            if (root[LIVEROOM_BACKPACK_GIFT_LIST_NUM].isInt()) {
                num = root[LIVEROOM_BACKPACK_GIFT_LIST_NUM].asInt();
            }
            /* grantedDate */
            if (root[LIVEROOM_BACKPACK_GIFT_LIST_GRANTEDDATE].isInt()) {
                grantedDate = root[LIVEROOM_BACKPACK_GIFT_LIST_GRANTEDDATE].asInt();
            }
  
            /* expDate */
            if (root[LIVEROOM_BACKPACK_GIFT_LIST_EXPDATE].isInt()) {
                expDate = root[LIVEROOM_BACKPACK_GIFT_LIST_EXPDATE].asInt();
            }

            /* read */
            if (root[LIVEROOM_BACKPACK_GIFT_LIST_READ].isInt()) {
                read = root[LIVEROOM_BACKPACK_GIFT_LIST_READ].asInt() == 1 ? true : false;
            }
            
        }
        if (num > 0) {
            result = true;
        }
        return result;
    }

    HttpBackGiftItem() {
        giftId = "";
        num = 0;
        grantedDate = 0;
        expDate = 0;
        read = false;
    }
    
    virtual ~HttpBackGiftItem() {
        
    }
    
    /**
     * 礼物列表结构体
     * giftId                 礼物ID
     * num                    礼物数量
     * grantedDate            获取时间（1970年起的秒数）
     * expDate		         过期时间（1970年起的秒数）
     * read                   已读状态（0:未读 1:已读）
     */
    string giftId;
    int    num;
    long   grantedDate;
    long   expDate;
    bool   read;
};

typedef list<HttpBackGiftItem> BackGiftItemList;


#endif /* HTTPBACKGIFTITEM_H_*/
