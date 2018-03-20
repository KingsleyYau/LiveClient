/*
 * ZBScheduleRoomItem.h
 *
 *  Created on: 2018-03-02
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef ZBSCHEDULEROOMITEM_H_
#define ZBSCHEDULEROOMITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#define SCHEDULEROOM_ANCHORID_PARAM              "anchor_id"
#define SCHEDULEROOM_NICKNAME_PARAM              "nickname"
#define SCHEDULEROOM_ANCHORIMG_PARAM             "anchor_img"
#define SCHEDULEROOM_ANCHORCOVERIMG_PARAM        "anchor_cover_img"
#define SCHEDULEROOM_CANENTERTIME_PARAM          "can_enter_time"
#define SCHEDULEROOM_LEFTSECONDS_PARAM           "left_seconds"
#define SCHEDULEROOM_ROOMID_PARAM                "roomid"


class ZBScheduleRoomItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* anchorId */
            if (root[SCHEDULEROOM_ANCHORID_PARAM].isString()) {
                anchorId = root[SCHEDULEROOM_ANCHORID_PARAM].asString();
            }
            /* nickName */
            if (root[SCHEDULEROOM_NICKNAME_PARAM].isString()) {
                nickName = root[SCHEDULEROOM_NICKNAME_PARAM].asString();
            }
            /* anchorImg */
            if (root[SCHEDULEROOM_ANCHORIMG_PARAM].isString()) {
                anchorImg = root[SCHEDULEROOM_ANCHORIMG_PARAM].asString();
            }
            /* anchorCoverImg */
            if (root[SCHEDULEROOM_ANCHORCOVERIMG_PARAM].isString()) {
                anchorCoverImg = root[SCHEDULEROOM_ANCHORCOVERIMG_PARAM].asString();
            }
            /* canEnterTime */
            if (root[SCHEDULEROOM_CANENTERTIME_PARAM].isIntegral()) {
                canEnterTime = root[SCHEDULEROOM_CANENTERTIME_PARAM].asInt();
            }
            /* leftSeconds */
            if (root[SCHEDULEROOM_LEFTSECONDS_PARAM].isIntegral()) {
                leftSeconds = root[SCHEDULEROOM_LEFTSECONDS_PARAM].asInt();
            }
            /* roomId */
            if (root[SCHEDULEROOM_ROOMID_PARAM].isString()) {
                roomId = root[SCHEDULEROOM_ROOMID_PARAM].asString();
            }
        }
        result = true;
        return result;
    }
    
    ZBScheduleRoomItem() {
        anchorId = "";
        nickName = "";
        anchorImg = "";
        anchorCoverImg = "";
        canEnterTime = 0;
        leftSeconds = 0;
        roomId = "";

    }
    
    virtual ~ZBScheduleRoomItem() {
        
    }
    /**
     * 立即私密邀请结构体
     * anchorId                 主播ID
     * nickName                 主播昵称
     * anchorImg                主播头像url
     * anchorCoverImg           主播封面图url
     * anchorCoverImg		    最晚可进入的时间（1970年起的秒数）
     * leftSeconds              倒数时间（秒)
     * roomId                   直播间ID
     */
    string      anchorId;
    string      nickName;
    string      anchorImg;
    string      anchorCoverImg;
    long        canEnterTime;
    int         leftSeconds;
    string      roomId;
    
};

typedef list<ZBScheduleRoomItem> ZBScheduleRoomList;


#endif /* ZBSCHEDULEROOMITEM_H_*/
