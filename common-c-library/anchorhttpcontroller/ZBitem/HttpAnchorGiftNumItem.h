/*
 * HttpAnchorGiftNumItem.h
 *
 *  Created on: 2018-4-4
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPANCHORGIFTNUMITEM_H_
#define HTTPANCHORGIFTNUMITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../ZBHttpLoginProtocol.h"
#include "../ZBHttpRequestEnum.h"

class HttpAnchorGiftNumItem {
public:
    void Parse(const Json::Value& root) {
        if( root.isObject() ) {
            /* giftId */
            if( root[HANGOUTGIFTLIST_BUYFORLIST_ID].isString() ) {
                giftId = root[HANGOUTGIFTLIST_BUYFORLIST_ID].asString();
            }
            
            /* giftNum */
            if( root[HANGOUTGIFTLIST_BUYFORLIST_NUM].isIntegral() ) {
                giftNum = root[HANGOUTGIFTLIST_BUYFORLIST_NUM].asInt();
            }
        }
    }
    
    HttpAnchorGiftNumItem() {
        giftId = "";
        giftNum = 0;
    }
    
    virtual ~HttpAnchorGiftNumItem() {
        
    }
    
    /**
     * 获取主播直播间礼物结构体
     * giftId			礼物ID
     * giftNum			礼物数量
     */
    string       giftId;
    int          giftNum;
};

typedef list<HttpAnchorGiftNumItem> HttpAnchorGiftNumItemList;

#endif /* HTTPANCHORGIFTNUMITEM_H_*/
