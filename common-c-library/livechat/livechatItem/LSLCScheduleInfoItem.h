/*
 * LSLCScheduleInfoItem.h
 *
 *  Created on: 2015-3-6
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LSLCSCHEDULEINFOITEM_H_
#define LSLCSCHEDULEINFOITEM_H_

#include <string>
using namespace std;


#include "LSLCScheduleMsgItem.h"
#include "../LSLiveChatAmfPublicParse.h"

#define LSLCSCHEDULEINFOITEM_WOMANID_PARAM          "womanId"
#define LSLCSCHEDULEINFOITEM_MANID_PARAM            "manId"
#define LSLCSCHEDULEINFOITEM_MSG_PARAM              "msg"
#define LSLCSCHEDULEINFOITEM_TARGETID_PARAM         "targetId"

class LSLCScheduleInfoItem {
public:
	void Parse(amf_object_handle root) {
        bool result = false;
		if( !root.isnull()
        && root->type == DT_OBJECT) {
            // manId
            amf_object_handle womanIdObject = root->get_child(LSLCSCHEDULEINFOITEM_MANID_PARAM);
            result = !womanIdObject.isnull() && womanIdObject->type == DT_STRING;
            if (result) {
                manId = womanIdObject->strValue;
            }

            // womanId
            amf_object_handle manIdObject = root->get_child(LSLCSCHEDULEINFOITEM_WOMANID_PARAM);
            result = !manIdObject.isnull() && manIdObject->type == DT_STRING;
            if (result) {
                womanId = manIdObject->strValue;
            }
            
            // msg
            amf_object_handle msgObject = root->get_child(LSLCSCHEDULEINFOITEM_MSG_PARAM);
            result = !msgObject.isnull() && msgObject->type == DT_STRING;
            if (result) {
                Json::Value jRoot;
                Json::Reader reader;
                if( reader.parse(msgObject->strValue, jRoot) ) {
                    if( jRoot.isObject() ) {
                        msg.Parse(jRoot);
                    }
                }
            }
		}
	}
    
    Json::Value PackInfo() {
        Json::Value value;
        value[LSLCSCHEDULEINFOITEM_MANID_PARAM] = manId;
        value[LSLCSCHEDULEINFOITEM_TARGETID_PARAM] = womanId;
        Json::FastWriter writer;
        string json = writer.write(msg.PackInfo());
        string jdata = json.substr(0, json.length() - 1);
        value[LSLCSCHEDULEINFOITEM_MSG_PARAM] = jdata;
        
        return value;
    }

	LSLCScheduleInfoItem() {
		manId = "";
		womanId = "";
	}
	virtual ~LSLCScheduleInfoItem() {

	}

	/**
	 * 预约信息
	 * @param manId             难会员ID
	 * @param womanId	   女会员ID
	 * @param msg                   预约消息协议
	 */
    string manId;
    string womanId;
	LSLCScheduleMsgItem msg;

};

#endif /* LSLCSCHEDULEINFOITEM_H_ */
