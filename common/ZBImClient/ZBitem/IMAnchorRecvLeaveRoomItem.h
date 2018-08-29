/*
 * IMAnchorRecvLeaveRoomItem.h
 *
 *  Created on: 2018-04-10
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef IMANCHORRECVLEAVEROOMITEM_H_
#define IMANCHORRECVLEAVEROOMITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "IMAnchorUserInfoItem.h"
#include "AnchorGiftNumItem.h"

#define IMANCHORRECVLEAVEROOMITEM_ROOMID_PARAM              "roomid"
#define IMANCHORRECVLEAVEROOMITEM_ISANCHOR_PARAM            "is_anchor"
#define IMANCHORRECVLEAVEROOMITEM_USERID_PARAM              "user_id"
#define IMANCHORRECVLEAVEROOMITEM_NICKNAME_PARAM            "nickname"
#define IMANCHORRECVLEAVEROOMITEM_PHOTOURL_PARAM            "photourl"
#define IMANCHORRECVLEAVEROOMITEM_ERRNO_PARAM               "errno"
#define IMANCHORRECVLEAVEROOMITEM_ERRMSG_PARAM              "errmsg"


class IMAnchorRecvLeaveRoomItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* roomId */
            if (root[IMANCHORRECVLEAVEROOMITEM_ROOMID_PARAM].isString()) {
                roomId = root[IMANCHORRECVLEAVEROOMITEM_ROOMID_PARAM].asString();
            }
            /* isAnchor */
            if (root[IMANCHORRECVLEAVEROOMITEM_ISANCHOR_PARAM].isNumeric()) {
                isAnchor = root[IMANCHORRECVLEAVEROOMITEM_ISANCHOR_PARAM].asInt() == 0 ? false : true;
            }
            /* userId */
            if (root[IMANCHORRECVLEAVEROOMITEM_USERID_PARAM].isString()) {
                userId = root[IMANCHORRECVLEAVEROOMITEM_USERID_PARAM].asString();
            }
            /* nickName */
            if (root[IMANCHORRECVLEAVEROOMITEM_NICKNAME_PARAM].isString()) {
                nickName = root[IMANCHORRECVLEAVEROOMITEM_NICKNAME_PARAM].asString();
            }
            /* photoUrl */
            if (root[IMANCHORRECVLEAVEROOMITEM_PHOTOURL_PARAM].isString()) {
                photoUrl = root[IMANCHORRECVLEAVEROOMITEM_PHOTOURL_PARAM].asString();
            }
            /* errNo */
            if (root[IMANCHORRECVLEAVEROOMITEM_ERRNO_PARAM].isNumeric()) {
                errNo = (ZBLCC_ERR_TYPE)root[IMANCHORRECVLEAVEROOMITEM_ERRNO_PARAM].asInt();
            }
            /* errMsg */
            if (root[IMANCHORRECVLEAVEROOMITEM_ERRMSG_PARAM].isString()) {
                errMsg = root[IMANCHORRECVLEAVEROOMITEM_ERRMSG_PARAM].asString();
            }
            result = true;
        }
        return result;
    }
    
    IMAnchorRecvLeaveRoomItem() {
        roomId = "";
        isAnchor = false;
        userId = "";
        nickName = "";
        photoUrl = "";
        errNo = ZBLCC_ERR_FAIL;
        errMsg = "";
    }
    
    virtual ~IMAnchorRecvLeaveRoomItem() {
        
    }
    /**
     * 观众/主播退出多人互动直播间信息
     * @roomId              直播间ID
     * @isAnchor            是否主播（0：否，1：是）
     * @userId              观众/主播ID
     * @nickName            观众/主播昵称
     * @photoUrl            观众/主播头像url
     * @errNo               退出原因错误码
     * @errMsg              退出原因错误描述
     */
    string                      roomId;
    bool                        isAnchor;
    string                      userId;
    string                      nickName;
    string                      photoUrl;
    ZBLCC_ERR_TYPE                         errNo;
    string                      errMsg;

};



#endif /* IMANCHORRECVLEAVEROOMITEM_H_*/
