/*
 * ScheduleRoomItem.h
 *
 *  Created on: 2017-09-07
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef SCHEDULEROOMITEM_H_
#define SCHEDULEROOMITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#define ANCHORIMG_PARAM             "anchor_img"
#define ANCHORCOVERIMG_PARAM        "anchor_cover_img"
#define CANENTERTIME_PARAM          "can_enter_time"
#define ROOMID_PARAM                "roomid"


class ScheduleRoomItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* anchorImg */
            if (root[ANCHORIMG_PARAM].isString()) {
                anchorImg = root[ANCHORIMG_PARAM].asString();
            }
            /* anchorCoverImg */
            if (root[ANCHORCOVERIMG_PARAM].isString()) {
                anchorCoverImg = root[ANCHORCOVERIMG_PARAM].isString();
            }
            /* canEnterTime */
            if (root[CANENTERTIME_PARAM].isIntegral()) {
                canEnterTime = root[CANENTERTIME_PARAM].asInt();
            }
            /* roomId */
            if (root[ROOMID_PARAM].isString()) {
                roomId = root[ROOMID_PARAM].asString();
            }
        }
        result = true;
        return result;
    }
    
    ScheduleRoomItem() {
        anchorImg = "";
        anchorCoverImg = "";
        canEnterTime = 0;
        roomId = "";

    }
    
    virtual ~ScheduleRoomItem() {
        
    }
    /**
     * 立即私密邀请结构体
     * anchorImg                主播头像url
     * anchorCoverImg           主播封面图url
     * anchorCoverImg		    最晚可进入的时间（1970年起的秒数）
     * roomId                   直播间ID
     */
    string      anchorImg;
    string      anchorCoverImg;
    long        canEnterTime;
    string      roomId;
    
};

typedef list<ScheduleRoomItem> ScheduleRoomList;


#endif /* SCHEDULEROOMITEM_H_*/
