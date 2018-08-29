/*
 * IMLackCreditHangoutItem.h
 *
 *  Created on: 2018-04-13
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef IMLACKCREDITHANGOUTITEM_H_
#define IMLACKCREDITHANGOUTITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#define IMLACKCREDITHANGOUTITEM_ROOMID_PARAM              "roomid"
#define IMLACKCREDITHANGOUTITEM_ANCHORID_PARAM            "anchor_id"
#define IMLACKCREDITHANGOUTITEM_NICKNAME_PARAM            "nick_name"
#define IMLACKCREDITHANGOUTITEM_AVATATIMG_PARAM           "avatar_img"
#define IMLACKCREDITHANGOUTITEM_ERRNO_PARAM               "errno"
#define IMLACKCREDITHANGOUTITEM_ERRMSG_PARAM              "errmsg"


class IMLackCreditHangoutItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* roomId */
            if (root[IMLACKCREDITHANGOUTITEM_ROOMID_PARAM].isString()) {
                roomId = root[IMLACKCREDITHANGOUTITEM_ROOMID_PARAM].asString();
            }
            /* anchorId */
            if (root[IMLACKCREDITHANGOUTITEM_ANCHORID_PARAM].isString()) {
                anchorId = root[IMLACKCREDITHANGOUTITEM_ANCHORID_PARAM].asString();
            }
            /* nickName */
            if (root[IMLACKCREDITHANGOUTITEM_NICKNAME_PARAM].isString()) {
                nickName = root[IMLACKCREDITHANGOUTITEM_NICKNAME_PARAM].asString();
            }
            /* avatarImg */
            if (root[IMLACKCREDITHANGOUTITEM_AVATATIMG_PARAM].isString()) {
                avatarImg = root[IMLACKCREDITHANGOUTITEM_AVATATIMG_PARAM].asString();
            }
            /* errNo */
            if (root[IMLACKCREDITHANGOUTITEM_ERRNO_PARAM].isNumeric()) {
                errNo = (LCC_ERR_TYPE)root[IMLACKCREDITHANGOUTITEM_ERRNO_PARAM].asInt();
            }
            /* errMsg */
            if (root[IMLACKCREDITHANGOUTITEM_ERRMSG_PARAM].isString()) {
                errMsg = root[IMLACKCREDITHANGOUTITEM_ERRMSG_PARAM].asString();
            }
            result = true;
        }
        return result;
    }
    
    IMLackCreditHangoutItem() {
        roomId = "";
        anchorId = "";
        nickName = "";
        avatarImg = "";
        errNo = LCC_ERR_FAIL;
        errMsg = "";
    }
    
    virtual ~IMLackCreditHangoutItem() {
        
    }
    /**
     * 观众账号余额不足信息
     * @roomId              直播间ID
     * @anchorId            主播ID
     * @nickName            主播昵称
     * @avatarImg           主播头像
     * @errNo               离开的错误码
     * @errMsg              离开的错误描述
     */
    string                      roomId;
    string                      anchorId;
    string                      nickName;
    string                      avatarImg;
    LCC_ERR_TYPE               errNo;
    string                      errMsg;

};



#endif /* IMLACKCREDITHANGOUTITEM_H_*/
