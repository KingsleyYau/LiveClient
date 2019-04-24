/*
 * HttpAppPushConfigItem.h
 *
 *  Created on: 2019-4-22
 *      Author: Alex
 *      Desc: App推送设置
 */

#ifndef HTTPAPPPUSHCONFIGITEM_H_
#define HTTPAPPPUSHCONFIGITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../HttpLoginProtocol.h"

class HttpAppPushConfigItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* isPriMsgAppPush */
            if (root[GETPUSHCONFIG_PRIVMSG_PUSH].isNumeric()) {
                isPriMsgAppPush = root[GETPUSHCONFIG_PRIVMSG_PUSH].asInt() == 1 ? true : false;
            }
            
            /* isMailAppPush */
            if (root[GETPUSHCONFIG_MAIL_PUSH].isNumeric()) {
                isMailAppPush = root[GETPUSHCONFIG_MAIL_PUSH].asInt() == 1 ? true : false;
            }
            
            /* isSayHiAppPush */
            if (root[GETPUSHCONFIG_SAYHI_PUSH].isNumeric()) {
                isSayHiAppPush = root[GETPUSHCONFIG_SAYHI_PUSH].asInt() == 1 ? true : false;
            }
            
        }
        result = true;
        return result;
    }

    HttpAppPushConfigItem() {
        isPriMsgAppPush = true;
        isMailAppPush = true;
        isSayHiAppPush = true;
    }
    
    virtual ~HttpAppPushConfigItem() {
        
    }
    
    /**
     * App推送设置
     * isPriMsgAppPush          是否接收私信推送通知（1：是，0：否）
     * isMailAppPush            是否接收私信推送通知（1：是，0：否）
     * isSayHiAppPush           是否接收SayHi推送通知（1：是，0：否）
     */
    bool   isPriMsgAppPush;
    bool   isMailAppPush;
    bool   isSayHiAppPush;
};

#endif /* HTTPAPPPUSHCONFIGITEM_H_*/
