/*
 * IMRecvLeaveRoomItem.h
 *
 *  Created on: 2018-04-13
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef IMRECVLEAVEROOMITEM_H_
#define IMRECVLEAVEROOMITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#define IMRECVLEAVEROOMITEM_ROOMID_PARAM              "roomid"
#define IMRECVLEAVEROOMITEM_ISANCHOR_PARAM            "is_anchor"
#define IMRECVLEAVEROOMITEM_USERID_PARAM              "user_id"
#define IMRECVLEAVEROOMITEM_NICKNAME_PARAM            "nickname"
#define IMRECVLEAVEROOMITEM_PHOTOURL_PARAM            "photourl"
#define IMRECVLEAVEROOMITEM_ERRNO_PARAM               "errno"
#define IMRECVLEAVEROOMITEM_ERRMSG_PARAM              "errmsg"


class IMRecvLeaveRoomItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* roomId */
            if (root[IMRECVLEAVEROOMITEM_ROOMID_PARAM].isString()) {
                roomId = root[IMRECVLEAVEROOMITEM_ROOMID_PARAM].asString();
            }
            /* isAnchor */
            if (root[IMRECVLEAVEROOMITEM_ISANCHOR_PARAM].isNumeric()) {
                isAnchor = root[IMRECVLEAVEROOMITEM_ISANCHOR_PARAM].asInt() == 0 ? false : true;
            }
            /* userId */
            if (root[IMRECVLEAVEROOMITEM_USERID_PARAM].isString()) {
                userId = root[IMRECVLEAVEROOMITEM_USERID_PARAM].asString();
            }
            /* nickName */
            if (root[IMRECVLEAVEROOMITEM_NICKNAME_PARAM].isString()) {
                nickName = root[IMRECVLEAVEROOMITEM_NICKNAME_PARAM].asString();
            }
            /* photoUrl */
            if (root[IMRECVLEAVEROOMITEM_PHOTOURL_PARAM].isString()) {
                photoUrl = root[IMRECVLEAVEROOMITEM_PHOTOURL_PARAM].asString();
            }
            /* errNo */
            if (root[IMRECVLEAVEROOMITEM_ERRNO_PARAM].isNumeric()) {
                errNo = (LCC_ERR_TYPE)root[IMRECVLEAVEROOMITEM_ERRNO_PARAM].asInt();
            }
            /* errMsg */
            if (root[IMRECVLEAVEROOMITEM_ERRMSG_PARAM].isString()) {
                errMsg = root[IMRECVLEAVEROOMITEM_ERRMSG_PARAM].asString();
            }
            result = true;
        }
        return result;
    }
    
    IMRecvLeaveRoomItem() {
        roomId = "";
        isAnchor = false;
        userId = "";
        nickName = "";
        photoUrl = "";
        errNo = LCC_ERR_FAIL;
        errMsg = "";
    }
    
    virtual ~IMRecvLeaveRoomItem() {
        
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
    LCC_ERR_TYPE                errNo;
    string                      errMsg;

};



#endif /* IMRECVLEAVEROOMITEM_H_*/
