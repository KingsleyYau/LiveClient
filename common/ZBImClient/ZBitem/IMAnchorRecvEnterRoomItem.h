/*
 * IMAnchorRecvEnterRoomItem.h
 *
 *  Created on: 2018-04-10
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef IMANCHORRECVENTERROOMITEM_H_
#define IMANCHORRECVENTERROOMITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "IMAnchorUserInfoItem.h"
#include "AnchorGiftNumItem.h"

#define IMANCHORRECVENTERROOMITEM_ROOMID_PARAM              "roomid"
#define IMANCHORRECVENTERROOMITEM_ISANCHOR_PARAM            "is_anchor"
#define IMANCHORRECVENTERROOMITEM_USERID_PARAM              "user_id"
#define IMANCHORRECVENTERROOMITEM_NICKNAME_PARAM            "nickname"
#define IMANCHORRECVENTERROOMITEM_PHOTOURL_PARAM            "photourl"
#define IMANCHORRECVENTERROOMITEM_USERINFO_PARAM            "user_info"
#define IMANCHORRECVENTERROOMITEM_PULLURL_PARAM             "pull_url"
#define IMANCHORRECVENTERROOMITEM_BUYFORLIST_PARAM          "buyfor_list"


class IMAnchorRecvEnterRoomItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* roomId */
            if (root[IMANCHORRECVENTERROOMITEM_ROOMID_PARAM].isString()) {
                roomId = root[IMANCHORRECVENTERROOMITEM_ROOMID_PARAM].asString();
            }
            /* isAnchor */
            if (root[IMANCHORRECVENTERROOMITEM_ISANCHOR_PARAM].isNumeric()) {
                isAnchor = root[IMANCHORRECVENTERROOMITEM_ISANCHOR_PARAM].asInt() == 0 ? false : true;
            }
            /* userId */
            if (root[IMANCHORRECVENTERROOMITEM_USERID_PARAM].isString()) {
                userId = root[IMANCHORRECVENTERROOMITEM_USERID_PARAM].asString();
            }
            /* nickName */
            if (root[IMANCHORRECVENTERROOMITEM_NICKNAME_PARAM].isString()) {
                nickName = root[IMANCHORRECVENTERROOMITEM_NICKNAME_PARAM].asString();
            }
            /* photoUrl */
            if (root[IMANCHORRECVENTERROOMITEM_PHOTOURL_PARAM].isString()) {
                photoUrl = root[IMANCHORRECVENTERROOMITEM_PHOTOURL_PARAM].asString();
            }
            /* userInfo */
            if (root[IMANCHORRECVENTERROOMITEM_USERINFO_PARAM].isObject()) {
                userInfo.Parse(root[IMANCHORRECVENTERROOMITEM_USERINFO_PARAM]);
            }
            /* pullUrl */
            if (root[IMANCHORRECVENTERROOMITEM_PULLURL_PARAM].isArray()) {
                int i = 0;
                for (i = 0; i < root[IMANCHORRECVENTERROOMITEM_PULLURL_PARAM].size(); i++) {
                    Json::Value element = root[IMANCHORRECVENTERROOMITEM_PULLURL_PARAM].get(i, Json::Value::null);
                    if (element.isString()) {
                        pullUrl.push_back(element.asString());
                    }
                }
            }
            /* pullUrl */
            if (root[IMANCHORRECVENTERROOMITEM_BUYFORLIST_PARAM].isArray()) {
                int i = 0;
                for (i = 0; i < root[IMANCHORRECVENTERROOMITEM_BUYFORLIST_PARAM].size(); i++) {
                    AnchorGiftNumItem item;
                    item.Parse(root[IMANCHORRECVENTERROOMITEM_BUYFORLIST_PARAM].get(i, Json::Value::null));
                    bugForList.push_back(item);
                }
            }

            result = true;
        }
        return result;
    }
    
    IMAnchorRecvEnterRoomItem() {
        roomId = "";
        isAnchor = false;
        userId = "";
        nickName = "";
        photoUrl = "";
    }
    
    virtual ~IMAnchorRecvEnterRoomItem() {
        
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
    IMAnchorUserInfoItem        userInfo;
    list<string>                pullUrl;
    AnchorGiftNumList           bugForList;

};



#endif /* IMANCHORRECVENTERROOMITEM_H_*/
