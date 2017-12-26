/*
 * HttpRideItem.h
 *
 *  Created on: 2017-8-29
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPRIDEITEM_H_
#define HTTPRIDEITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"

class HttpRideItem {
public:
    void Parse(const Json::Value& root) {
        if (root.isObject()) {
            /* rideId */
            if (root[LIVEROOM_RIDELIST_LIST_ID].isString()) {
                rideId = root[LIVEROOM_RIDELIST_LIST_ID].asString();
            }
            /* photoUrl */
            if (root[LIVEROOM_RIDELIST_LIST_PHOTOURL].isString()) {
                photoUrl = root[LIVEROOM_RIDELIST_LIST_PHOTOURL].asString();
            }
            /* name */
            if (root[LIVEROOM_RIDELIST_LIST_NAME].isString()) {
                name = root[LIVEROOM_RIDELIST_LIST_NAME].asString();
            }
            /* grantedDate */
            if (root[LIVEROOM_RIDELIST_LIST_GRANTEDDATE].isIntegral()) {
                grantedDate = root[LIVEROOM_RIDELIST_LIST_GRANTEDDATE].asInt();
            }
            /* grantedDate */
            if (root[LIVEROOM_RIDELIST_LIST_GRANTEDDATE].isIntegral()) {
                grantedDate = root[LIVEROOM_RIDELIST_LIST_GRANTEDDATE].asInt();
            }
            /* startValidDate */
            if (root[LIVEROOM_RIDELIST_LIST_STARTVALIDDATE].isIntegral()) {
                startValidDate = root[LIVEROOM_RIDELIST_LIST_STARTVALIDDATE].asInt();
            }
            /* expDate */
            if (root[LIVEROOM_RIDELIST_LIST_EXPDATE].isIntegral()) {
                expDate = root[LIVEROOM_RIDELIST_LIST_EXPDATE].asInt();
            }
            /* read */
            if (root[LIVEROOM_RIDELIST_LIST_READ].isIntegral()) {
                read = root[LIVEROOM_RIDELIST_LIST_READ].asInt() == 0 ? false : true;
            }
            /* isUse */
            if (root[LIVEROOM_RIDELIST_LIST_ISUSE].isIntegral()) {
                isUse = root[LIVEROOM_RIDELIST_LIST_ISUSE].asInt() == 0 ? false : true;
            }
        }

    }
    
    HttpRideItem() {
        rideId = "";
        photoUrl = "";
        name = "";
        grantedDate = 0;
        startValidDate = 0;
        expDate = 0;
        read = false;
        isUse = false;

    }
    
    virtual ~HttpRideItem() {
        
    }
    
    /**
     * 有效邀请数组结构体
     * rideId          座驾ID
     * photoUrl        座驾图片url
     * name            座驾名称
     * grantedDate     获取时间
     * startValidDate  有效开始时间
     * expDate         过期时间
     * read            已读状态（0:未读 1:已读）
     * isUse           是否使用中（0:否 1:是）
     */
    string rideId;
    string photoUrl;
    string name;
    long grantedDate;
    long startValidDate;
    long expDate;
    bool read;
    bool isUse;
};

typedef list<HttpRideItem> RideList;

#endif /* HTTPRIDEITEM_H_*/
