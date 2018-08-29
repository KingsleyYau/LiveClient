/*
 * HttpEmoticonItem.h
 *
 *  Created on: 2017-8-16
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPEMOTICONITEM_H_
#define HTTPEMOTICONITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "HttpEmoticonInfoItem.h"

class HttpEmoticonItem {
public:
	void Parse(const Json::Value& root) {
		if( root.isObject() ) {
            
            /* type */
            if( root[LIVEROOM_EMOTICON_LIST_EMOTYPE].isInt() ) {
                type = GetIntToEmoticonType(root[LIVEROOM_EMOTICON_LIST_EMOTYPE].asInt());
            }
            /* name */
            if( root[LIVEROOM_EMOTICON_LIST_NAME].isString() ) {
                name = root[LIVEROOM_EMOTICON_LIST_NAME].asString();
            }
            
            /* errMsg */
            if( root[LIVEROOM_EMOTICON_LIST_ERRMSG].isString() ) {
                errMsg = root[LIVEROOM_EMOTICON_LIST_ERRMSG].asString();
            }
            
            /* emoUrl */
            if( root[LIVEROOM_EMOTICON_LIST_EMOURL].isString() ) {
                emoUrl = root[LIVEROOM_EMOTICON_LIST_EMOURL].asString();
            }
            
            
            /* emoList */
            if (root[LIVEROOM_EMOTICON_LIST_EMOLIST].isArray()) {
                for (int i = 0; i < root[LIVEROOM_EMOTICON_LIST_EMOLIST].size(); i++) {
                    Json::Value element = root[LIVEROOM_EMOTICON_LIST_EMOLIST].get(i, Json::Value::null);
                    HttpEmoticonInfoItem item;
                    if (item.Parse(element)) {
                        emoList.push_back(item);
                    }
                }
            }
            
        }
    }

	HttpEmoticonItem() {
        type = EMOTICONTYPE_STANDARD;
        name = "";
        errMsg = "";
        emoUrl = "";
	}

	virtual ~HttpEmoticonItem() {

	}
    /**
     * 登录成功结构体
     * type      表情类型（0:Standard， 1:Advanced）
     * name      表情类型名称
     * errMsg    表情类型不可用的错误描述
     * emoUrl    表情类型icon url
     * emoList   表情信息队列
     */
    EmoticonType           type;
    string                 name;
    string                 errMsg;
    string                 emoUrl;
    EmoticonInfoItemList   emoList;
};

typedef list<HttpEmoticonItem> EmoticonItemList;


#endif /* HTTPEMOTICONITEM_H_ */
