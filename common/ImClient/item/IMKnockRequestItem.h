/*
 * IMKnockRequestItem.h
 *
 *  Created on: 2018-04-13
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef IMKNOCKREQUESTITEM_H_
#define IMKNOCKREQUESTITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#define IMKNOCKREQUESTITEM_ROOMID_PARAM                 "room_id"
#define IMKNOCKREQUESTITEM_ANCHORID_PARAM               "anchor_id"
#define IMKNOCKREQUESTITEM_NICKNAME_PARAM               "nickname"
#define IMKNOCKREQUESTITEM_PHOTOURL_PARAM               "photourl"
#define IMKNOCKREQUESTITEM_AGE_PARAM                    "age"
#define IMKNOCKREQUESTITEM_COUNTRY_PARAM                "country"
#define IMKNOCKREQUESTITEM_KNOCKID_PARAM                "knock_id"
#define IMKNOCKREQUESTITEM_EXPIRE_PARAM                 "expire"


class IMKnockRequestItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* roomId */
            if (root[IMKNOCKREQUESTITEM_ROOMID_PARAM].isString()) {
                roomId = root[IMKNOCKREQUESTITEM_ROOMID_PARAM].asString();
            }
            /* anchorId */
            if (root[IMKNOCKREQUESTITEM_ANCHORID_PARAM].isString()) {
                anchorId = root[IMKNOCKREQUESTITEM_ANCHORID_PARAM].asString();
            }
            /* nickName */
            if (root[IMKNOCKREQUESTITEM_NICKNAME_PARAM].isString()) {
                nickName = root[IMKNOCKREQUESTITEM_NICKNAME_PARAM].asString();
            }
            /* photoUrl */
            if (root[IMKNOCKREQUESTITEM_PHOTOURL_PARAM].isString()) {
                photoUrl = root[IMKNOCKREQUESTITEM_PHOTOURL_PARAM].asString();
            }
            /* age */
            if (root[IMKNOCKREQUESTITEM_AGE_PARAM].isNumeric()) {
                age = root[IMKNOCKREQUESTITEM_AGE_PARAM].asInt();
            }
            /* country */
            if (root[IMKNOCKREQUESTITEM_COUNTRY_PARAM].isString()) {
                country = root[IMKNOCKREQUESTITEM_COUNTRY_PARAM].asString();
            }
            /* knockId */
            if (root[IMKNOCKREQUESTITEM_KNOCKID_PARAM].isString()) {
                knockId = root[IMKNOCKREQUESTITEM_KNOCKID_PARAM].asString();
            }
            /* expire */
            if (root[IMKNOCKREQUESTITEM_EXPIRE_PARAM].isNumeric()) {
                expire = root[IMKNOCKREQUESTITEM_EXPIRE_PARAM].asInt();
            }
            
            
            result = true;
        }
        return result;
    }
    
    IMKnockRequestItem() {
        roomId = "";
        anchorId = "";
        nickName = "";
        photoUrl = "";
        age = 0;
        country = "";
        knockId = "";
        expire = 0;
    }
    
    virtual ~IMKnockRequestItem() {
        
    }
    /**
     * 主播敲门信息
     * @roomId              直播间ID
     * @anchorId            主播ID
     * @nickName            主播昵称
     * @photoUrl            主播头像
     * @age                 年龄
     * @country             国家
     * @knockId             敲门ID
     * @expire              敲门请求的有效剩余秒数
     */
    string                      roomId;
    string                      anchorId;
    string                      nickName;
    string                      photoUrl;
    int                         age;
    string                      country;
    string                      knockId;
    int                         expire;
    
};



#endif /* IMKNOCKREQUESTITEM_H_*/

