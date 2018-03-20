/*
 * ZBHttpSvrItem.h
 *
 *  Created on: 2018-2-28
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef ZBHTTPSVRITEM_H_
#define ZBHTTPSVRITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../ZBHttpLoginProtocol.h"
#include "../ZBHttpRequestEnum.h"

class ZBHttpSvrItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        /* svrId */
        if (root[GETCONFIG_SVRLIST_SVRID].isString()) {
            svrId = root[GETCONFIG_SVRLIST_SVRID].asString();
        }
        /* tUrl */
        if (root[GETCONFIG_SVRLIST_TURL].isString()) {
            tUrl = root[GETCONFIG_SVRLIST_TURL].asString();
        }
        result = true;
        return result;
    }
    
    ZBHttpSvrItem() {
        svrId = "";
        tUrl = "";
    }
    
    virtual ~ZBHttpSvrItem() {
    
    }
    /**
     *  流媒体服务器
     *  svrId       流媒体服务器ID
     *  tUrl        流媒体服务器测速url
     */
    string      svrId;
    string      tUrl;
};
typedef list<ZBHttpSvrItem> ZBSvrList;

#endif /* ZBHTTPSVRITEM_H_ */
