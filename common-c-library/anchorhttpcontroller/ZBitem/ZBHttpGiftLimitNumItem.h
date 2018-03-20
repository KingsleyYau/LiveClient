/*
 * ZBHttpGiftLimitNumItem.h
 *
 *  Created on: 2018-2-27
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef ZBHTTPGIFTLIMITNUMITEM_H_
#define ZBHTTPGIFTLIMITNUMITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../ZBHttpLoginProtocol.h"
#include "../ZBHttpRequestEnum.h"

class ZBHttpGiftLimitNumItem {
public:
    void Parse(const Json::Value& root) {
        if( root.isObject() ) {
            /* giftId */
            if( root[GIFTLIST_LIST_GIFTID].isString() ) {
                giftId = root[GIFTLIST_LIST_GIFTID].asString();
            }
            
            /* giftNum */
            if( root[GIFTLIST_LIST_GIFTNUM].isIntegral() ) {
                giftNum = root[GIFTLIST_LIST_GIFTNUM].asInt();
            }
        }
    }
    
    ZBHttpGiftLimitNumItem() {
        giftId = "";
        giftNum = 0;
    }
    
    virtual ~ZBHttpGiftLimitNumItem() {
        
    }
    
    /**
     * 获取主播直播间礼物结构体
     * giftId			礼物ID
     * giftNum			礼物数量
     */
    string       giftId;
    int          giftNum;
};

typedef list<ZBHttpGiftLimitNumItem> ZBHttpGiftLimitNumItemList;

#endif /* ZBHTTPGIFTLIMITNUMITEM_H_*/
