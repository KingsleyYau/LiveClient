/*
 * LSLoginRoomItem.h
 *
 *  Created on: 2017-11-03
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LSLOGINROOMITEM_H_
#define LSLOGINROOMITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#define ROOMLIST_ROOMID_PARAM                       "roomid"
#define ROOMLIST_ANCHORID_PARAM                     "anchor_id"
#define ROOMLIST_NICKNAME_PARAM                     "nickname"

class LSLoginRoomItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* roomId */
            if (root[ROOMLIST_ROOMID_PARAM].isString()) {
                roomId = root[ROOMLIST_ROOMID_PARAM].asString();
            }
            
            /* anchorId */
            if (root[ROOMLIST_ANCHORID_PARAM].isString()) {
                anchorId = root[ROOMLIST_ANCHORID_PARAM].asString();
            }
            
            /* nickName */
            if (root[ROOMLIST_NICKNAME_PARAM].isString()) {
                nickName = root[ROOMLIST_NICKNAME_PARAM].asString();
            }
        }
        result = true;
        return result;
    }
    
    LSLoginRoomItem() {
        roomId = "";
        anchorId = "";
        nickName = "";
    }
    
    virtual ~LSLoginRoomItem() {
        
    }
    /**
     * 直播间结构体
     * roomId                   直播间ID
     * anchorId                 主播ID
     * nickName		            主播昵称
     */
    string                  roomId;
    string                  anchorId;
    string                  nickName;
    
};

#endif /* LSLOGINROOMITEM_H_*/
