/*
 * LoginReturnItem.h
 *
 *  Created on: 2017-09-07
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LOGINRETURNITEM_H_
#define LOGINRETURNITEM_H_

#include <string>
#include"ScheduleRoomItem.h"
#include"PrivateInviteItem.h"
using namespace std;

#include <json/json/json.h>

#define NOTICE_PARAM                    "notice"
#define ROOMLIST_PARAM                  "roomlist"
#define ROOMID_PARAM                    "roomid"
#define INVITELIST_PARAM                "invitelist"
#define SCHEDULEROOMLIST_PARAM          "schedule_roomlist"

typedef list<string> RoomList;

class LoginReturnItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* anchorImg */
            if (root[NOTICE_PARAM].isObject()) {
                Json::Value dataJson = root[NOTICE_PARAM];
                if (dataJson[ROOMLIST_PARAM].isArray()) {
                    for (int i = 0; i < dataJson[ROOMLIST_PARAM].size(); i++) {
                        Json::Value element = dataJson[ROOMLIST_PARAM].get(i, Json::Value::null);
                        if (element[ROOMID_PARAM].isString()) {
                            roomList.push_back(element[ROOMID_PARAM].asString());
                        }
                    }
                }
                if (dataJson[INVITELIST_PARAM].isArray()) {
                    for (int i = 0; i < root[INVITELIST_PARAM].size(); i++) {
                        Json::Value element = root[INVITELIST_PARAM].get(i, Json::Value::null);
                        PrivateInviteItem item;
                        if (item.Parse(element)) {
                            inviteList.push_back(item);
                        }
                    }
                }
                if (dataJson[SCHEDULEROOMLIST_PARAM].isArray()) {
                    for (int i = 0; i < root[SCHEDULEROOMLIST_PARAM].size(); i++) {
                        Json::Value element = root[SCHEDULEROOMLIST_PARAM].get(i, Json::Value::null);
                        ScheduleRoomItem item;
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
    
    LoginReturnItem() {

    }
    
    virtual ~LoginReturnItem() {
        
    }
    /**
     * 立即私密邀请结构体
     * roomList                 需要强制进入的直播间数组
     * inviteList               本人邀请中有效的立即私密邀请
     * scheduleRoomList		    预约且未进入过直播
     */
    RoomList                roomList;
    InviteList              inviteList;
    ScheduleRoomList        scheduleRoomList;
    
};

typedef list<ScheduleRoomItem> ScheduleRoomList;


#endif /* LOGINRETURNITEM_H_*/
