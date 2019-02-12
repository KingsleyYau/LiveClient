/*
 * HttpAuthorityItem.h
 *
 *  Created on: 2018-4-12
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPAUTHOTITYITEM_H_
#define HTTPAUTHOTITYITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../HttpLoginProtocol.h"


class HttpAuthorityItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* privteLiveAuth */
            if (root[LIVEROOM_HOT_PROGRAMLIST_PRIV_ONEONONE].isNumeric()) {
                privteLiveAuth = root[LIVEROOM_HOT_PROGRAMLIST_PRIV_ONEONONE].asInt() == 0 ? false : true;
            }
            /* bookingPriLiveAuth */
            if (root[LIVEROOM_HOT_PROGRAMLIST_PRIV_BOOKING].isNumeric()) {
                bookingPriLiveAuth = root[LIVEROOM_HOT_PROGRAMLIST_PRIV_BOOKING].asInt() == 0 ? false : true;
            }
            

        }
        result = true;
        return result;
    }

    HttpAuthorityItem() {
        privteLiveAuth = true;
        bookingPriLiveAuth = true;
    }
    
    virtual ~HttpAuthorityItem() {
        
    }
    
    /**
     * 权限
     * privteLiveAuth           私密直播权限
     * bookingPriLiveAuth       预约私密直播权限
     */
    bool    privteLiveAuth;
    bool    bookingPriLiveAuth;
};


#endif /* HTTPAUTHOTITYITEM_H_*/
