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
#include"LSLoginRoomItem.h"
#include"LSIMOngoingshowItem.h"
using namespace std;

#include <json/json/json.h>

#define NOTICE_PARAM                    "notice"
#define ROOMLIST_PARAM                  "roomlist"
#define INVITELIST_PARAM                "invitelist"
#define SCHEDULEROOMLIST_PARAM          "schedule_roomlist"
#define ONGOINGSHOWLIST_PARAM           "ongoing_show_list"
typedef list<LSLoginRoomItem> LSLoginRoomList;
typedef list<ScheduleRoomItem> ScheduleRoomList;
typedef list<LSIMOngoingshowItem> OngoingShowList;
class LoginReturnItem {
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
                        LSLoginRoomItem item;
                        if (item.Parse(element)) {
                            roomList.push_back(item);
                        }
                    }
                }
                if (dataJson[INVITELIST_PARAM].isArray()) {
                    for (int i = 0; i < dataJson[INVITELIST_PARAM].size(); i++) {
                        Json::Value element = dataJson[INVITELIST_PARAM].get(i, Json::Value::null);
                        PrivateInviteItem item;
                        if (item.Parse(element)) {
                            inviteList.push_back(item);
                        }
                    }
                }
                if (dataJson[SCHEDULEROOMLIST_PARAM].isArray()) {
                    for (int i = 0; i < dataJson[SCHEDULEROOMLIST_PARAM].size(); i++) {
                        Json::Value element = dataJson[SCHEDULEROOMLIST_PARAM].get(i, Json::Value::null);
                        ScheduleRoomItem item;
                        if (item.Parse(element)) {
                            scheduleRoomList.push_back(item);
                        }
                    }
                }
                if (dataJson[ONGOINGSHOWLIST_PARAM].isArray()) {
                    for (int i = 0; i < dataJson[ONGOINGSHOWLIST_PARAM].size(); i++) {
                        Json::Value element = dataJson[ONGOINGSHOWLIST_PARAM].get(i, Json::Value::null);
                        LSIMOngoingshowItem item;
                        if (item.Parse(element)) {
                            ongoingShowList.push_back(item);
                        }
                    }
                }
                
//                // alextest
//                if (ongoingShowList.size() <= 0) {
//                    LSIMOngoingshowItem item;
//                    item.type = IMPROGRAMNOTICETYPE_FOLLOW;
//                    item.msg = "123456";
//                    item.showInfo.showLiveId = "item.showInfo.showLiveId";
//                    item.showInfo.anchorId = "item.showInfo.anchorId";
//                    item.showInfo.anchorNickName = "item.showInfo.anchorNickName";
//                    item.showInfo.anchorAvatar = "item.showInfo.anchorAvatar";
//                    item.showInfo.showTitle = "item.showInfo.showTitle";
//                    item.showInfo.showIntroduce = "item.showInfo.showIntroduce";
//                    item.showInfo.cover = "item.showInfo.cover";
//                    item.showInfo.approveTime = 50;
//                    item.showInfo.startTime = 40;
//                    item.showInfo.duration = 30;
//                    item.showInfo.leftSecToStart = 200;
//                    item.showInfo.leftSecToEnter = 100;
//                    item.showInfo.price = 5.7;
//                    item.showInfo.status = IMPROGRAMSTATUS_VERIFYPASS;
//                    item.showInfo.ticketStatus = IMPROGRAMTICKETSTATUSS_BUYED;
//                    item.showInfo.isHasFollow = true;
//                    item.showInfo.isTicketFull = true;
//                    ongoingShowList.push_back(item);
//                }
                
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
     * ongoingShowList          将要开播的节目
     */
    LSLoginRoomList         roomList;
    InviteList              inviteList;
    ScheduleRoomList        scheduleRoomList;
    OngoingShowList         ongoingShowList;
};




#endif /* LOGINRETURNITEM_H_*/
