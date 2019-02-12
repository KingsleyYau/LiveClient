/*
 * LSLCRecordMutiple.h
 *
 *  Created on: 2015-3-2
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LSLCRecordMutiple_H_
#define LSLCRecordMutiple_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../LSLiveChatRequestLiveChatDefine.h"

#include "LSLCRecord.h"

class LSLCRecordMutiple {
public:
	void Parse(Json::Value root, int index) {
		if( root.isObject() ) {
            Json::Value::Members jsonMember = root.getMemberNames();
            inviteId = jsonMember[index];
            Json::Value jsonRecordArray = root[inviteId];
            if( jsonRecordArray.isArray() ) {
                for(int i = 0; i < jsonRecordArray.size(); i++ ) {
                    LSLCRecord record;
                    record.Parse(jsonRecordArray.get(i, Json::Value::null));
                    if (record.messageType != LRM_UNKNOW) {
                        recordList.push_back(record);
                    }
                }
            }
		}
	}
    

	LSLCRecordMutiple() {
		inviteId = "";
	}
    
    LSLCRecordMutiple(const LSLCRecordMutiple& item) {
        inviteId = item.inviteId;
        recordList = item.recordList;
    }

	virtual ~LSLCRecordMutiple() {

	}

	/**
	 * 5.5.批量查询聊天记录回调
	 * @param inviteId			邀请ID
	 * @param recordList		聊天记录
	 */

	string inviteId;
	list<LSLCRecord> recordList;
};

#endif /* LSLCRECORDMUTIPLE_H_ */
