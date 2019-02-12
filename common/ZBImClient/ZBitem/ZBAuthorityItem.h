/*
 * ZBAuthorityItem.h
 *
 *  Created on: 2017-9-05
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef ZBAUTHORITYITEM_H_
#define ZBAUTHORITYITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#define PRIV_ONEONNOE_PARAM          "oneonone"
#define PRIV_BOOKING_PARAM           "booking"

class ZBAuthorityItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            if (root[PRIV_ONEONNOE_PARAM].isNumeric()) {
                isHasOneOnOneAuth = root[PRIV_ONEONNOE_PARAM].asInt() == 0 ? false : true;
            }
            if (root[PRIV_BOOKING_PARAM].isNumeric()) {
                isHasBookingAuth = root[PRIV_BOOKING_PARAM].asInt() == 0 ? false : true;
            }

        }

        result = true;

        return result;
    }

    ZBAuthorityItem() {
        isHasOneOnOneAuth = true;
        isHasBookingAuth = true;
    }
    
    virtual ~ZBAuthorityItem() {
        
    }
    
    /**
     * 权限
     * isHasOneOnOneAuth          私密直播开播权限
     * isHasBookingAuth			  预约私密直播开播权限
     */
    bool          isHasOneOnOneAuth;
    bool          isHasBookingAuth;
};


#endif /* ZBAUTHORITYITEM_H_*/
