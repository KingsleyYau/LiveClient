/*
 * ZBIMSendInviteInfoItem.h
 *
 *  Created on: 2019-11-09
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef ZBIMSENDINVITEINFOITEM_H_
#define ZBIMSENDINVITEINFOITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../IMConvertEnum.h"

#define ZBSENDINVITEINFO_INVITEID_PARAM             "invite_id"
#define ZBSENDINVITEINFO_ROOMID_PARAM               "roomid"
#define ZBSENDINVITEINFO_TIMEOUT_PARAM              "timeout"
#define ZBSENDINVITEINFO_DEVICETYPE_PARAM           "device_type"
#define ZBSENDINVITEINFO_USERID_PARAM               "userid"
#define ZBSENDINVITEINFO_USERNAME_PARAM             "username"
#define ZBSENDINVITEINFO_USERPHOTOURL_PARAM         "userphotourl"


class ZBIMSendInviteInfoItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* inviteId */
            if (root[ZBSENDINVITEINFO_INVITEID_PARAM ].isString()) {
                inviteId = root[ZBSENDINVITEINFO_INVITEID_PARAM ].asString();
            }
            /* roomId */
            if (root[ZBSENDINVITEINFO_ROOMID_PARAM ].isString()) {
                roomId = root[ZBSENDINVITEINFO_ROOMID_PARAM ].asString();
            }
            
            /* timeOut */
            if (root[ZBSENDINVITEINFO_TIMEOUT_PARAM].isIntegral()) {
                timeOut = root[ZBSENDINVITEINFO_TIMEOUT_PARAM].asInt();
            }
            
            /* deviceType */
            if (root[ZBSENDINVITEINFO_DEVICETYPE_PARAM].isIntegral()) {
                deviceType = GetIMDeviceTypeWithInt(root[ZBSENDINVITEINFO_DEVICETYPE_PARAM].asInt());
            }
            
            /* userId */
            if (root[ZBSENDINVITEINFO_USERID_PARAM ].isString()) {
                userId = root[ZBSENDINVITEINFO_USERID_PARAM ].asString();
            }
            
            /* userName */
            if (root[ZBSENDINVITEINFO_USERNAME_PARAM ].isString()) {
                userName = root[ZBSENDINVITEINFO_USERNAME_PARAM ].asString();
            }
            
            /* userPhotoUrl */
            if (root[ZBSENDINVITEINFO_USERPHOTOURL_PARAM ].isString()) {
                userPhotoUrl = root[ZBSENDINVITEINFO_USERPHOTOURL_PARAM ].asString();
            }
            
        }
        return result;
    }
    
    ZBIMSendInviteInfoItem() {
        inviteId = "";
        roomId = "";
        timeOut = 0;
        deviceType = IMDEVICETYPE_UNKNOW;
        userId = "";
        userName = "";
        userPhotoUrl = "";
    }
    
    virtual ~ZBIMSendInviteInfoItem() {
        
    }
    /**
     * 主播邀请返回信息结构体
     * inviteId             邀请ID
     * roomId               直播间ID
     * timeOut              邀请剩余有效时间
     * deviceType           推流设备类型
     * userId               邀请私密男士ID
     * userName             邀请私密男士名字
     * userPhotoUrl         邀请私密男士头像
     */
    string inviteId;
    string roomId;
    int timeOut;
    IMDeviceType deviceType;
    string userId;
    string userName;
    string userPhotoUrl;
    
};

#endif /* ZBIMSENDINVITEINFOITEM_H_*/
