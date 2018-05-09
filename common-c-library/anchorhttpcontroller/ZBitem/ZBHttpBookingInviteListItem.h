/*
 * ZBHttpBookingInviteListItem.h
 *
 *  Created on: 2018-2-28
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef ZBHTTPBOOKINGINVITELISTITEM_H_
#define ZBHTTPBOOKINGINVITELISTITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "ZBHttpBookingPrivateInviteItem.h"

class ZBHttpBookingInviteListItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* total */
            if (root[MANHANDLEBOOKINGLIST_TOTAL].isInt()) {
                total = root[MANHANDLEBOOKINGLIST_TOTAL].asInt();
            }
            /* noReadCount */
            if (root[MANHANDLEBOOLINGLIST_NOREADCOUNT].isInt()) {
                noReadCount = root[MANHANDLEBOOLINGLIST_NOREADCOUNT].asInt();
            }
            /* list */
            if (root[MANHANDLEBOOKINGLIST_LIST].isArray()) {
                for (int i = 0; i < root[MANHANDLEBOOKINGLIST_LIST].size(); i++) {
                    Json::Value element = root[MANHANDLEBOOKINGLIST_LIST].get(i, Json::Value::null);
                   
                    ZBHttpBookingPrivateInviteItem item;
                    if (item.Parse(element)) {
                        list.push_back(item);
                    }

                }
            }
        }
        if (total > 0) {
            result = true;
        }
        return result;
    }
    
    ZBHttpBookingInviteListItem() {
        total = 0;
        noReadCount = 0;

    }
    
    virtual ~ZBHttpBookingInviteListItem() {
        
    }
    /**
     * 获取预约邀请列表
     * total           预约列表总数
     * noReadCount     未读总数
     * list            预约列表
     */
    int total;
    int noReadCount;
    ZBBookingPrivateInviteItemList list;
};

#endif /* ZBHTTPBOOKINGINVITELISTITEM_H_*/
