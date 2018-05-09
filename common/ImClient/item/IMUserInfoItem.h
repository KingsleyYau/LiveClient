/*
 * IMUserInfoItem.h
 *
 *  Created on: 2018-04-13
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef IMUSERINFOITEM_H_
#define IMUSERINFOITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#define IMUSERINFOITEM_RIDERID_PARAM              "riderid"
#define IMUSERINFOITEM_RIDERNAME_PARAM            "ridername"
#define IMUSERINFOITEM_RIDERURL_PARAM             "riderurl"
#define IMUSERINFOITEM_HONORIMG_PARAM             "honor_img"

class IMUserInfoItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* riderId */
            if (root[IMUSERINFOITEM_RIDERID_PARAM].isString()) {
                riderId = root[IMUSERINFOITEM_RIDERID_PARAM].asString();
            }
            /* riderName */
            if (root[IMUSERINFOITEM_RIDERNAME_PARAM].isString()) {
                riderName = root[IMUSERINFOITEM_RIDERNAME_PARAM].asString();
            }
            /* riderUrl */
            if (root[IMUSERINFOITEM_RIDERURL_PARAM].isString()) {
                riderUrl = root[IMUSERINFOITEM_RIDERURL_PARAM].asString();
            }
            /* honorImg */
            if (root[IMUSERINFOITEM_HONORIMG_PARAM].isString()) {
                honorImg = root[IMUSERINFOITEM_HONORIMG_PARAM].asString();
            }
            
            result = true;
        }
        return result;
    }
    
    IMUserInfoItem() {
        riderId = "";
        riderName = "";
        riderUrl = "";
        honorImg = "";
    }
    
    virtual ~IMUserInfoItem() {
        
    }
    /**
     * 观众信息信息
     * @riderId            座驾ID
     * @riderName          座驾名称
     * @riderUrl           座驾图片url
     * @honorImg           勋章图片url
     */
    string                      riderId;
    string                      riderName;
    string                      riderUrl;
    string                      honorImg;

};

#endif /* IMUSERINFOITEM_H_*/
