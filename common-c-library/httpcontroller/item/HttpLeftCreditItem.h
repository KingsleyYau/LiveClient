/*
 * HttpLeftCreditItem.h
 *
 *  Created on: 2018-4-12
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPLEFTCREDITITEM_H_
#define HTTPLEFTCREDITITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../HttpLoginProtocol.h"

class HttpLeftCreditItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* credit */
            if (root[LIVEROOM_GETCREDIT_CREDIT].isNumeric()) {
                credit = root[LIVEROOM_GETCREDIT_CREDIT].asDouble();
            }
            
            /* coupon */
            if (root[LIVEROOM_GETCREDIT_COUPON].isNumeric()) {
                coupon = root[LIVEROOM_GETCREDIT_COUPON].asInt();
            }
            
            /* postStamp */
            if (root[LIVEROOM_GETCREDIT_POSTSTAMP].isNumeric()) {
                postStamp = root[LIVEROOM_GETCREDIT_POSTSTAMP].asDouble();
            }
            
            /* liveChatCount */
            if (root[LIVEROOM_GETCREDIT_LIVECHATCOUNT].isNumeric()) {
                liveChatCount = root[LIVEROOM_GETCREDIT_LIVECHATCOUNT].asInt();
            }

        }
        result = true;
        return result;
    }

    HttpLeftCreditItem() {
        credit = 0.0;
        coupon = 0;
        postStamp = 0;
        liveChatCount = 0;
    }
    
    virtual ~HttpLeftCreditItem() {
        
    }
    
    /**
     * 余额信息
     * credit       信用点
     * coupon       可用的试用券数量
     * postStamp    可用的邮票数量
     * liveChatCount  可用livechat的试用券数量
     */
    double credit;
    int coupon;
    double postStamp;
    int liveChatCount;
    
};


#endif /* HTTPLEFTCREDITITEM_H_*/
