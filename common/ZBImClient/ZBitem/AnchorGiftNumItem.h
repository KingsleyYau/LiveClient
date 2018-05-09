/*
 * AnchorGiftNumItem.h
 *
 *  Created on: 2018-04-08
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef ANCHORGIFTNUMITEM_H_
#define ANCHORGIFTNUMITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#define BUYFOR_ID_PARAM             "id"
#define BUYFOR_NUM_PARAM            "num"



class AnchorGiftNumItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* giftId */
            if (root[BUYFOR_ID_PARAM].isString()) {
                giftId = root[BUYFOR_ID_PARAM].asString();
            }
            /* giftNum */
            if (root[BUYFOR_NUM_PARAM].isNumeric()) {
                giftNum = root[BUYFOR_NUM_PARAM].asInt();
            }
            
        }
        return result;
    }
    
    AnchorGiftNumItem() {
        giftId = "";
        giftNum = 0;
    }
    
    virtual ~AnchorGiftNumItem() {
        
    }
    /**
     * 礼物列表
     * @giftId            礼物ID
     * @giftNum           已收礼物数量
     */

    string      giftId;
    int         giftNum;
    
};

typedef list<AnchorGiftNumItem> AnchorGiftNumList;


#endif /* ANCHORGIFTNUMITEM_H_*/
