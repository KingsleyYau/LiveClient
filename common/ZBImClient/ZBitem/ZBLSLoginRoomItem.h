/*
 * ZBLSLoginRoomItem.h
 *
 *  Created on: 2018-03-02
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef ZBLSLOGINROOMITEM_H_
#define ZBLSLOGINROOMITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#define ROOMLIST_ROOMID_PARAM                       "roomid"
#define ROOMLIST_ROOMTYPE_PARAM                     "room_type"

class ZBLSLoginRoomItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* roomId */
            if (root[ROOMLIST_ROOMID_PARAM].isString()) {
                roomId = root[ROOMLIST_ROOMID_PARAM].asString();
            }
//            // alextest
//            if (root[ROOMLIST_ROOMID_PARAM].isNumeric()) {
//                //roomId = root[ROOMLIST_ROOMID_PARAM].asString();
//                char temp[16];
//                snprintf(temp, sizeof(temp), "%d",  root[ROOMLIST_ROOMID_PARAM].asInt());
//                roomId =  temp;
//            }
            
            /* roomType */
            if (root[ROOMLIST_ROOMTYPE_PARAM].isNumeric()) {
                int type = root[ROOMLIST_ROOMTYPE_PARAM].asInt();
                roomType = ZBGetRoomType(type);
            }

            
        }
        result = true;
        return result;
    }
    
    ZBLSLoginRoomItem() {
        roomId = "";
        roomType = ZBROOMTYPE_NOLIVEROOM;
    }
    
    virtual ~ZBLSLoginRoomItem() {
        
    }
    /**
     * 直播间结构体
     * roomId                   直播间ID
     * roomType                 直播间类型
     */
    string                  roomId;
    ZBRoomType              roomType;
    
};

#endif /* ZBLSLOGINROOMITEM_H_*/
