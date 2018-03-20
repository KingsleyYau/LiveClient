/*
 * ZBLoginReturnItem.h
 *
 *  Created on: 2018-03-02
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef ZBLOGINRETURNITEM_H_
#define ZBLOGINRETURNITEM_H_

#include <string>
#include"ZBScheduleRoomItem.h"
#include"ZBPrivateInviteItem.h"
#include"ZBLSLoginRoomItem.h"
using namespace std;

#include <json/json/json.h>

#define NOTICE_PARAM                    "notice"
#define ROOMLIST_PARAM                  "roomlist"
#define INVITELIST_PARAM                "invitelist"
#define SCHEDULEROOMLIST_PARAM          "schedule_roomlist"
typedef list<ZBLSLoginRoomItem> ZBLSLoginRoomList;
typedef list<ZBScheduleRoomItem> ZBScheduleRoomList;
class ZBLoginReturnItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* roomList */
            if (root[NOTICE_PARAM].isObject()) {
                Json::Value dataJson = root[NOTICE_PARAM];
                if (dataJson[ROOMLIST_PARAM].isArray()) {
                    for (int i = 0; i < dataJson[ROOMLIST_PARAM].size(); i++) {
                        Json::Value element = dataJson[ROOMLIST_PARAM].get(i, Json::Value::null);
                        ZBLSLoginRoomItem item;
                        if (item.Parse(element)) {
                            roomList.push_back(item);
                        }
                    }
                }
                if (dataJson[INVITELIST_PARAM].isArray()) {
                    for (int i = 0; i < dataJson[INVITELIST_PARAM].size(); i++) {
                        Json::Value element = dataJson[INVITELIST_PARAM].get(i, Json::Value::null);
                        ZBPrivateInviteItem item;
                        if (item.Parse(element)) {
                            inviteList.push_back(item);
                        }
                    }
                }
                if (dataJson[SCHEDULEROOMLIST_PARAM].isArray()) {
                    for (int i = 0; i < dataJson[SCHEDULEROOMLIST_PARAM].size(); i++) {
                        Json::Value element = dataJson[SCHEDULEROOMLIST_PARAM].get(i, Json::Value::null);
                        ZBScheduleRoomItem item;
                        if (item.Parse(element)) {
                            scheduleRoomList.push_back(item);
                        }
                    }
                }
            }
        }
        result = true;
        return result;
    }
    
    ZBLoginReturnItem() {

    }
    
    virtual ~ZBLoginReturnItem() {
        
    }
    /**
     * 立即私密邀请结构体
     * roomList                 需要强制进入的直播间数组
     * inviteList               本人邀请中有效的立即私密邀请
     * scheduleRoomList		    预约且未进入过直播
     */
    ZBLSLoginRoomList         roomList;
    ZBInviteList              inviteList;
    ZBScheduleRoomList        scheduleRoomList;
    
};




#endif /* ZBLOGINRETURNITEM_H_*/
