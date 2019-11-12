/*
 * ZBCurrentPushInfoItem.h
 *
 *  Created on: 2019-11-07
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef ZBCURRENTPUSHINFOITEM_H_
#define ZBCURRENTPUSHINFOITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#define ZBCPII_STATUS_PARAM             "status"
#define ZBCPII_MESSAGE_PARAM            "message"

class ZBCurrentPushInfoItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            if (root[ZBCPII_STATUS_PARAM].isNumeric()) {
                int type = root[ZBCPII_STATUS_PARAM].asInt();
                status = GetIMCurrentPushStatus(type);
            }
            
            if (root[ZBCPII_MESSAGE_PARAM].isString()) {
                message = root[ZBCPII_MESSAGE_PARAM].asString();
            }
            
        }

        result = true;

        return result;
    }

    ZBCurrentPushInfoItem() {
        status = IMCURRENTPUSHSTATUS_NOTPUSH;
        message = "";
    }
    
    virtual ~ZBCurrentPushInfoItem() {
        
    }
    
    /**
     * 当前推流状态结构体
     * status  当前推流状态（IMCURRENTPUSHSTATUS_NOTPUSH：未推流，IMCURRENTPUSHSTATUS_PCPUSH：PC推流，IMCURRENTPUSHSTATUS_APPPUSH：APP推流）
     * message					推流消息
     */
    IMCurrentPushStatus      status;
    string                  message;
};


#endif /* ZBCURRENTPUSHINFOITEM_H_ */
