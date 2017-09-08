/*
 * HttpBookingInviteListItem.h
 *
 *  Created on: 2017-8-18
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPBOOKINGINVITELISTITEM_H_
#define HTTPBOOKINGINVITELISTITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "HttpBookingPrivateInviteItem.h"

class HttpBookingInviteListItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* total */
            if (root[LIVEROOM_MANHANDLEBOOKINGLIST_TOTAL].isInt()) {
                total = root[LIVEROOM_MANHANDLEBOOKINGLIST_TOTAL].asInt();
            }
            /* list */
            if (root[LIVEROOM_MANHANDLEBOOKINGLIST_LIST].isArray()) {
                for (int i = 0; i < root[LIVEROOM_MANHANDLEBOOKINGLIST_LIST].size(); i++) {
                    Json::Value element = root[LIVEROOM_MANHANDLEBOOKINGLIST_LIST].get(i, Json::Value::null);
                    HttpBookingPrivateInviteItem item;
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
    
    HttpBookingInviteListItem() {
        total = 0;

    }
    
    virtual ~HttpBookingInviteListItem() {
        
    }
    /**
     * 获取预约邀请列表
     * total           预约列表总数
     * list            预约列表
     */
    int total;
    BookingPrivateInviteItemList list;
};

#endif /* HTTPBOOKINGINVITELISTITEM_H_*/
