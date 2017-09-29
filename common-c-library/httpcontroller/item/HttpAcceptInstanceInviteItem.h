/*
 * HttpAcceptInstanceInviteItem.h
 *
 *  Created on: 2017-9-11
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPACCEPTINSTANCEINVITEITEM_H_
#define HTTPACCEPTINSTANCEINVITEITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"

class HttpAcceptInstanceInviteItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* roomId */
            if (root[LIVEROOM_ACCEPTINSTACEINVITE_INVITEID].isString()) {
                roomId = root[LIVEROOM_ACCEPTINSTACEINVITE_INVITEID].asString();
            }
            
            /* roomType */
            if (root[LIVEROOM_ACCEPTINSTACEINVITE_ISCONFIRM].isIntegral()) {
                roomType = (HttpRoomType)root[LIVEROOM_ACCEPTINSTACEINVITE_ISCONFIRM].asInt();
            }
        }
        result = true;
        return result;
    }

    HttpAcceptInstanceInviteItem() {
        roomId = "";
        roomType = HTTPROOMTYPE_NOLIVEROOM;
    }
    
    virtual ~HttpAcceptInstanceInviteItem() {
        
    }
    
    /**
     * 观众处理立即私密邀请结构体
     * roomId                 直播间ID
     * roomType               直播间类型
     */
    string roomId;
    HttpRoomType roomType;

};


#endif /* HTTPACCEPTINSTANCEINVITEITEM_H_*/
