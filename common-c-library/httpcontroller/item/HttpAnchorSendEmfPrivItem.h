/*
 * HttpAnchorSendEmfPrivItem.h
 *
 *  Created on: 2018-4-12
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPANCHORSENDEMFPRIVITEM_H_
#define HTTPANCHORSENDEMFPRIVITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../HttpLoginProtocol.h"

class HttpAnchorSendEmfPrivItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* userCanSend */
            if (root[LIVEROOM_CANSENDEMF_USER_CAN_SEND].isNumeric()) {
                userCanSend = root[LIVEROOM_CANSENDEMF_USER_CAN_SEND].asInt() == 0 ? false : true;
            }
            
            /* anchorCanSend */
            if (root[LIVEROOM_CANSENDEMF_ANCHOR_CAN_SEND].isNumeric()) {
                anchorCanSend = root[LIVEROOM_CANSENDEMF_ANCHOR_CAN_SEND].asInt() == 0 ? false : true;
            }

        }
        result = true;
        return result;
    }

    HttpAnchorSendEmfPrivItem() {
        userCanSend = false;
        anchorCanSend = false;
    }
    
    virtual ~HttpAnchorSendEmfPrivItem() {
        
    }
    
    /**
     * 余额信息
     * userCanSend       男士是否有发信权限
     * anchorCanSend     主播是否有发送及接收信件权限
     */
    bool userCanSend;
    bool anchorCanSend;
};


#endif /* HTTPANCHORSENDEMFPRIVITEM_H_*/
