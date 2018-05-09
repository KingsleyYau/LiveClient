/*
 * AnchorRecvGiftItem.h
 *
 *  Created on: 2018-04-08
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef ANCHORRECVGIFTITEM_H_
#define ANCHORRECVGIFTITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "AnchorGiftNumItem.h"

#define BUYFOR_USERID_PARAM          "user_id"
#define BUYFOR_BUYFORLIST_PARAM      "buyfor_list"


class AnchorRecvGiftItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* userId */
            if (root[BUYFOR_USERID_PARAM].isString()) {
                userId = root[BUYFOR_USERID_PARAM].asString();
            }
            /* buyforList */
            if (root[BUYFOR_BUYFORLIST_PARAM].isArray()) {
                int i = 0;
                for (i = 0; i < root[BUYFOR_BUYFORLIST_PARAM].size(); i++) {
                    AnchorGiftNumItem item;
                    item.Parse(root[BUYFOR_BUYFORLIST_PARAM].get(i, Json::Value::null));
                    buyforList.push_back(item);
                }
            }
        }
        return result;
    }
    
    AnchorRecvGiftItem() {
        userId = "";
    }
    
    virtual ~AnchorRecvGiftItem() {
        
    }
    /**
     * 已收礼物列表
     * @userId                  用户ID，包括观众及主播
     * @buyforList              已收吧台礼物列表
     */
    string              userId;
    AnchorGiftNumList   buyforList;
    
};

typedef list<AnchorRecvGiftItem> AnchorRecvGiftList;


#endif /* ANCHORRECVGIFTITEM_H_*/
