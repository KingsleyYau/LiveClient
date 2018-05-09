/*
 * IMGiftNumItem.h
 *
 *  Created on: 2018-04-13
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef GIFTNUMITEM_H_
#define GIFTNUMITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#define GIFTNUMITEM_ID_PARAM             "id"
#define GIFTNUMITEM_NUM_PARAM            "num"



class IMGiftNumItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* giftId */
            if (root[GIFTNUMITEM_ID_PARAM].isString()) {
                giftId = root[GIFTNUMITEM_ID_PARAM].asString();
            }
            /* giftNum */
            if (root[GIFTNUMITEM_NUM_PARAM].isNumeric()) {
                giftNum = root[GIFTNUMITEM_NUM_PARAM].asInt();
            }
            
        }
        return result;
    }
    
    IMGiftNumItem() {
        giftId = "";
        giftNum = 0;
    }
    
    virtual ~IMGiftNumItem() {
        
    }
    /**
     * 礼物列表
     * @giftId            礼物ID
     * @giftNum           已收礼物数量
     */

    string      giftId;
    int         giftNum;
    
};

typedef list<IMGiftNumItem> GiftNumList;


#endif /* GIFTNUMITEM_H_*/
