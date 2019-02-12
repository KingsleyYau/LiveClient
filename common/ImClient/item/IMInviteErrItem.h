/*
 * IMInviteErrItem.h
 *
 *  Created on: 2017-9-05
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef IMINVITEERRITEM_H_
#define IMINVITEERRITEM_H_

#include <string>
using namespace std;
#include "IMAuthorityItem.h"

#include <json/json/json.h>
// 请求参数定义
#define IMINVITEERRITEM_PRIV_PARAM                  "priv"
#define IMINVITEERRITEM_CHAT_ONLINE_STATUS_PARAM     "chat_online_status"


class IMInviteErrItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {

            if (root[IMINVITEERRITEM_PRIV_PARAM].isObject()) {
                priv.Parse(root[IMINVITEERRITEM_PRIV_PARAM]);
            }
            if (root[IMINVITEERRITEM_CHAT_ONLINE_STATUS_PARAM].isNumeric()) {
                status = GetIntToIMChatOnlineStatus(root[IMINVITEERRITEM_CHAT_ONLINE_STATUS_PARAM].asInt());
            }

        }

        result = true;

        return result;
    }

    IMInviteErrItem() {
        status = IMCHATONLINESTATUS_OFF;
    }
    
    virtual ~IMInviteErrItem() {
        
    }
    
    IMAuthorityItem  priv;
    IMChatOnlineStatus status;
};


#endif /* IMINVITEERRITEM_H_*/
