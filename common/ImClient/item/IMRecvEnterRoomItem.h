/*
 * IMRecvEnterRoomItem.h
 *
 *  Created on: 2018-04-10
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef IMRECVENTERROOMITEM_H_
#define IMRECVENTERROOMITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "IMUserInfoItem.h"
#include "IMGiftNumItem.h"

#define IMRECVENTERROOMITEM_ROOMID_PARAM              "roomid"
#define IMRECVENTERROOMITEM_ISANCHOR_PARAM            "is_anchor"
#define IMRECVENTERROOMITEM_USERID_PARAM              "user_id"
#define IMRECVENTERROOMITEM_NICKNAME_PARAM            "nickname"
#define IMRECVENTERROOMITEM_PHOTOURL_PARAM            "photourl"
#define IMRECVENTERROOMITEM_USERINFO_PARAM            "user_info"
#define IMRECVENTERROOMITEM_PULLURL_PARAM             "pull_url"
#define IMRECVENTERROOMITEM_BUYFORLIST_PARAM          "buyfor_list"


class IMRecvEnterRoomItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* roomId */
            if (root[IMRECVENTERROOMITEM_ROOMID_PARAM].isString()) {
                roomId = root[IMRECVENTERROOMITEM_ROOMID_PARAM].asString();
            }
            /* isAnchor */
            if (root[IMRECVENTERROOMITEM_ISANCHOR_PARAM].isNumeric()) {
                isAnchor = root[IMRECVENTERROOMITEM_ISANCHOR_PARAM].asInt() == 0 ? false : true;
            }
            /* userId */
            if (root[IMRECVENTERROOMITEM_USERID_PARAM].isString()) {
                userId = root[IMRECVENTERROOMITEM_USERID_PARAM].asString();
            }
            /* nickName */
            if (root[IMRECVENTERROOMITEM_NICKNAME_PARAM].isString()) {
                nickName = root[IMRECVENTERROOMITEM_NICKNAME_PARAM].asString();
            }
            /* photoUrl */
            if (root[IMRECVENTERROOMITEM_PHOTOURL_PARAM].isString()) {
                photoUrl = root[IMRECVENTERROOMITEM_PHOTOURL_PARAM].asString();
            }
            /* userInfo */
            if (root[IMRECVENTERROOMITEM_USERINFO_PARAM].isObject()) {
                userInfo.Parse(root[IMRECVENTERROOMITEM_USERINFO_PARAM]);
            }
            /* pullUrl */
            if (root[IMRECVENTERROOMITEM_PULLURL_PARAM].isArray()) {
                int i = 0;
                for (i = 0; i < root[IMRECVENTERROOMITEM_PULLURL_PARAM].size(); i++) {
                    Json::Value element = root[IMRECVENTERROOMITEM_PULLURL_PARAM].get(i, Json::Value::null);
                    if (element.isString()) {
                        pullUrl.push_back(element.asString());
                    }
                }
            }
            /* pullUrl */
            if (root[IMRECVENTERROOMITEM_BUYFORLIST_PARAM].isArray()) {
                int i = 0;
                for (i = 0; i < root[IMRECVENTERROOMITEM_BUYFORLIST_PARAM].size(); i++) {
                    IMGiftNumItem item;
                    item.Parse(root[IMRECVENTERROOMITEM_BUYFORLIST_PARAM].get(i, Json::Value::null));
                    bugForList.push_back(item);
                }
            }

            result = true;
        }
        return result;
    }
    
    IMRecvEnterRoomItem() {
        roomId = "";
        isAnchor = false;
        userId = "";
        nickName = "";
        photoUrl = "";
    }
    
    virtual ~IMRecvEnterRoomItem() {
        
    }
    /**
     * 观众/主播进入多人互动直播间信息
     * @roomId            直播间ID
     * @isAnchor          是否主播（0：否，1：是）
     * @userId            观众/主播ID
     * @nickName          观众/主播昵称
     * @photoUrl          观众/主播头像url
     * @userInfo          观众信息
     * @pullUrl           视频流url（字符串数组）（访问视频URL的协议参考《 “视频URL”协议描述》）
     * @bugForList        已收吧台礼物列表
     */
    string                      roomId;
    bool                        isAnchor;
    string                      userId;
    string                      nickName;
    string                      photoUrl;
    IMUserInfoItem              userInfo;
    list<string>                pullUrl;
    GiftNumList                 bugForList;

};



#endif /* IMRECVENTERROOMITEM_H_*/
