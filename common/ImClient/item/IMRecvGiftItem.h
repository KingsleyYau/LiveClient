/*
 * IMRecvGiftItem.h
 *
 *  Created on: 2018-04-13
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef IMRECVGIFTITEM_H_
#define IMRECVGIFTITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "IMGiftNumItem.h"

#define IMRECVGIFTITEM_USERID_PARAM          "user_id"
#define IMRECVGIFTITEM_BUYFORLIST_PARAM      "buyfor_list"


class IMRecvGiftItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* userId */
            if (root[IMRECVGIFTITEM_USERID_PARAM].isString()) {
                userId = root[IMRECVGIFTITEM_USERID_PARAM].asString();
            }
            /* buyforList */
            if (root[IMRECVGIFTITEM_BUYFORLIST_PARAM].isArray()) {
                int i = 0;
                for (i = 0; i < root[IMRECVGIFTITEM_BUYFORLIST_PARAM].size(); i++) {
                    IMGiftNumItem item;
                    item.Parse(root[IMRECVGIFTITEM_BUYFORLIST_PARAM].get(i, Json::Value::null));
                    buyforList.push_back(item);
                }
            }
        }
        return result;
    }
    
    IMRecvGiftItem() {
        userId = "";
    }
    
    virtual ~IMRecvGiftItem() {
        
    }
    /**
     * 已收礼物列表
     * @userId                  用户ID，包括观众及主播
     * @buyforList              已收吧台礼物列表
     */
    string              userId;
    GiftNumList         buyforList;
    
};

typedef list<IMRecvGiftItem> RecvGiftList;


#endif /* IMRECVGIFTITEM_H_*/
