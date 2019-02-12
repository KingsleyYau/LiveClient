/*
 * IMAuthorityItem.h
 *
 *  Created on: 2017-9-05
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef IMAUTHORITYITEM_H_
#define IMAUTHORITYITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#define PRIV_ONEONNOE_PARAM          "oneonone"
#define PRIV_BOOKING_PARAM           "booking"

class IMAuthorityItem {
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

    IMAuthorityItem() {
        isHasOneOnOneAuth = true;
        isHasBookingAuth = true;
    }
    
    virtual ~IMAuthorityItem() {
        
    }
    
    /**
     * 权限
     * isHasOneOnOneAuth          私密直播开播权限
     * isHasBookingAuth			  预约私密直播开播权限
     */
    bool          isHasOneOnOneAuth;
    bool          isHasBookingAuth;
};


#endif /* IMAUTHORITYITEM_H_*/
