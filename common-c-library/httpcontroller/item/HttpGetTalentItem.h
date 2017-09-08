/*
 * HttpGetTalentItem.h
 *
 *  Created on: 2017-8-28
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPGETTALENTITEM_H_
#define HTTPGETTALENTITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"

class HttpGetTalentItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* talentId */
            if (root[LIVEROOM_GETTALENTLIST_LIST_ID].isString()) {
                talentId = root[LIVEROOM_GETTALENTLIST_LIST_ID].asString();
            }
            /* name */
            if (root[LIVEROOM_GETTALENTLIST_LIST_NAME].isString()) {
                name = root[LIVEROOM_GETTALENTLIST_LIST_NAME].asString();
            }
            /* credit */
            if (root[LIVEROOM_GETTALENTLIST_LIST_CREDIT].isNumeric()) {
                credit = root[LIVEROOM_GETTALENTLIST_LIST_CREDIT].asDouble();
            }
        }
        if (!talentId.empty()) {
            result = true;
        }
        return result;
    }
    
    HttpGetTalentItem() {
        talentId = "";
        name = "";
        credit = 0.0;

    }
    
    virtual ~HttpGetTalentItem() {
        
    }
    /**
     * 才艺结构体
     * talentId       才艺ID
     * name           才艺名称
     * credit         发送礼物所需的信用点
     */
    string talentId;
    string name;
    double credit;
};

typedef list<HttpGetTalentItem> TalentItemList;

#endif /* HTTPGETTALENTITEM_H_*/
