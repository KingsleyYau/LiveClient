/*
 * IMAnchorUserInfoItem.h
 *
 *  Created on: 2018-04-10
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef IMANCHORUSERINFOITEM_H_
#define IMANCHORUSERINFOITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#define IMANCHORUSERINFOITEM_RIDERID_PARAM              "riderid"
#define IMANCHORUSERINFOITEM_RIDERNAME_PARAM            "ridername"
#define IMANCHORUSERINFOITEM_RIDERURL_PARAM             "riderurl"
#define IMANCHORUSERINFOITEM_HONORIMG_PARAM             "honor_img"

class IMAnchorUserInfoItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* riderId */
            if (root[IMANCHORUSERINFOITEM_RIDERID_PARAM].isString()) {
                riderId = root[IMANCHORUSERINFOITEM_RIDERID_PARAM].asString();
            }
            /* riderName */
            if (root[IMANCHORUSERINFOITEM_RIDERNAME_PARAM].isString()) {
                riderName = root[IMANCHORUSERINFOITEM_RIDERNAME_PARAM].asString();
            }
            /* riderUrl */
            if (root[IMANCHORUSERINFOITEM_RIDERURL_PARAM].isString()) {
                riderUrl = root[IMANCHORUSERINFOITEM_RIDERURL_PARAM].asString();
            }
            /* honorImg */
            if (root[IMANCHORUSERINFOITEM_HONORIMG_PARAM].isString()) {
                honorImg = root[IMANCHORUSERINFOITEM_HONORIMG_PARAM].asString();
            }
            
            result = true;
        }
        return result;
    }
    
    IMAnchorUserInfoItem() {
        riderId = "";
        riderName = "";
        riderUrl = "";
        honorImg = "";
    }
    
    virtual ~IMAnchorUserInfoItem() {
        
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



#endif /* IMANCHORUSERINFOITEM_H_*/
