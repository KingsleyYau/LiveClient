/*
 * HttpGetBackPackUnreadNumItem.h
 *
 *  Created on: 2017-8-28
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPGETBACKPACKUNREADNUMITEM_H_
#define HTTPGETBACKPACKUNREADNUMITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"

class HttpGetBackPackUnreadNumItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* total */
            if (root[LIVEROOM_GETBACKPACKUNREADNUM_TOTAL].isInt()) {
                total = root[LIVEROOM_GETBACKPACKUNREADNUM_TOTAL].asInt();
            }
            /* voucherUnreadNum */
            if (root[LIVEROOM_GETBACKPACKUNREADNUM_VOUCHERUNREADNUM].isInt()) {
                voucherUnreadNum = root[LIVEROOM_GETBACKPACKUNREADNUM_VOUCHERUNREADNUM].asInt();
            }
            
            /* giftUnreadNum */
            if (root[LIVEROOM_GETBACKPACKUNREADNUM_GIFTUNREADNUM].isInt()) {
                giftUnreadNum = root[LIVEROOM_GETBACKPACKUNREADNUM_GIFTUNREADNUM].asInt();
            }
            
            /* rideUnreadNum */
            if (root[LIVEROOM_GETBACKPACKUNREADNUM_RIDEUNREADNUM].isInt()) {
                rideUnreadNum = root[LIVEROOM_GETBACKPACKUNREADNUM_RIDEUNREADNUM].asInt();
            }

        }

        if (total > 0) {
            result = true;
        }
        return result;
    }
    
    HttpGetBackPackUnreadNumItem() {
        total = 0;
        voucherUnreadNum = 0;
        giftUnreadNum = 0;
        rideUnreadNum = 0;

    }
    
    virtual ~HttpGetBackPackUnreadNumItem() {
        
    }
    
    /**
     * 背包未读数量结构体
     * total                 以下参数数量总和
     * voucherUnreadNum      试用劵未读的数量
     * giftUnreadNum         背包礼物的未读数量
     * rideUnreadNum         座驾的未读数量
     */
    int total;
    int voucherUnreadNum;
    int giftUnreadNum;
    int rideUnreadNum;
};

#endif /* HTTPGETBACKPACKUNREADNUMITEM_H_*/
