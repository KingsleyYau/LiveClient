/*
 * ZBHttpEmoticonItem.h
 *
 *  Created on: 2018-2-28
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef ZBHTTPEMOTICONITEM_H_
#define ZBHTTPEMOTICONITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "ZBHttpEmoticonInfoItem.h"

class ZBHttpEmoticonItem {
public:
	void Parse(const Json::Value& root) {
		if( root.isObject() ) {
            
            /* type */
            if( root[GETEMOTICONLIST_LIST_EMOTYPE].isInt() ) {
                type = (ZBEmoticonType)root[GETEMOTICONLIST_LIST_EMOTYPE].asInt();
            }
            /* name */
            if( root[GETEMOTICONLIST_LIST_NAME].isString() ) {
                name = root[GETEMOTICONLIST_LIST_NAME].asString();
            }
            
            /* errMsg */
            if( root[GETEMOTICONLIST_LIST_ERRMSG].isString() ) {
                errMsg = root[GETEMOTICONLIST_LIST_ERRMSG].asString();
            }
            
            /* emoUrl */
            if( root[GETEMOTICONLIST_LIST_EMOURL].isString() ) {
                emoUrl = root[GETEMOTICONLIST_LIST_EMOURL].asString();
            }
            
            
            /* emoList */
            if (root[GETEMOTICONLIST_LIST_EMOLIST].isArray()) {
                for (int i = 0; i < root[GETEMOTICONLIST_LIST_EMOLIST].size(); i++) {
                    Json::Value element = root[GETEMOTICONLIST_LIST_EMOLIST].get(i, Json::Value::null);
                    ZBHttpEmoticonInfoItem item;
                    if (item.Parse(element)) {
                        emoList.push_back(item);
                    }
                }
            }
            
        }
    }

	ZBHttpEmoticonItem() {
        type = ZBEMOTICONTYPE_STANDARD;
        name = "";
        errMsg = "";
        emoUrl = "";
	}

	virtual ~ZBHttpEmoticonItem() {

	}
    /**
     * 文本表情结构体
     * type      表情类型（0:Standard， 1:Advanced）
     * name      表情类型名称
     * errMsg    表情类型不可用的错误描述
     * emoUrl    表情类型icon url
     * emoList   表情信息队列
     */
    ZBEmoticonType         type;
    string                 name;
    string                 errMsg;
    string                 emoUrl;
    ZBEmoticonInfoItemList   emoList;
};

typedef list<ZBHttpEmoticonItem> ZBEmoticonItemList;


#endif /* ZBHTTPEMOTICONITEM_H_ */
