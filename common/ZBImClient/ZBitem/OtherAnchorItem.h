/*
 * OtherAnchorItem.h
 *
 *  Created on: 2018-04-08
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef OTHERANCHORITEM_H_
#define OTHERANCHORITEM_H_

#include <string>
using namespace std;

#include "AnchorRecvGiftItem.h"
#include <json/json/json.h>

#define OTHERANCHOR_ANCHORID_PARAM          "anchor_id"
#define OTHERANCHOR_NICKNAME_PARAM          "nickname"
#define OTHERANCHOR_PHOTOURL_PARAM          "photourl"
#define OTHERANCHOR_ANVHORSTATUS_PARAM      "anchor_status"
#define OTHERANCHOR_LEFTSECONDS_PARAM       "left_seconds"
#define OTHERANCHOR_LOVELEVEL_PARAM         "love_level"
#define OTHERANCHOR_VIDEOURL_PARAM          "video_url"


class OtherAnchorItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* anchorId */
            if (root[OTHERANCHOR_ANCHORID_PARAM].isString()) {
                anchorId = root[OTHERANCHOR_ANCHORID_PARAM].asString();
            }
            /* nickName */
            if (root[OTHERANCHOR_NICKNAME_PARAM].isString()) {
                nickName = root[OTHERANCHOR_NICKNAME_PARAM].asString();
            }
            /* photoUrl */
            if (root[OTHERANCHOR_PHOTOURL_PARAM].isString()) {
                photoUrl = root[OTHERANCHOR_PHOTOURL_PARAM].asString();
            }
            /* anchorStatus */
            if (root[OTHERANCHOR_ANVHORSTATUS_PARAM].isNumeric()) {
                anchorStatus = GetAnchorStatus(root[OTHERANCHOR_ANVHORSTATUS_PARAM].asInt());
            }
            /* leftSeconds */
            if (root[OTHERANCHOR_LEFTSECONDS_PARAM].isNumeric()) {
                leftSeconds = root[OTHERANCHOR_LEFTSECONDS_PARAM].asInt();
            }
            /* loveLevel */
            if (root[OTHERANCHOR_LOVELEVEL_PARAM].isNumeric()) {
                loveLevel = root[OTHERANCHOR_LOVELEVEL_PARAM].asInt();
            }
            /* videoUrl */
            if (root[OTHERANCHOR_VIDEOURL_PARAM].isArray()) {
                int i = 0;
                for (i = 0; i < root[OTHERANCHOR_VIDEOURL_PARAM].size(); i++) {
                    Json::Value element = root[OTHERANCHOR_VIDEOURL_PARAM].get(i, Json::Value::null);
                    if (element.isString()) {
                        videoUrl.push_back(element.asString());
                    }
                }
            }

        }

        return result;
    }
    
    OtherAnchorItem() {
        anchorId = "";
        nickName = "";
        photoUrl = "";
        anchorStatus = ANCHORSTATUS_UNKNOW;
        leftSeconds = 0;
        loveLevel = 0;

    }
    
    virtual ~OtherAnchorItem() {
        
    }
    /**
     * 其它主播列表
     * @anchorId                主播ID
     * @nickName                主播昵称
     * @photoUrl                主播头像url
     * @anchorStatus            主播状态（0：邀请中，1：邀请已确认，2：敲门已确认，3：倒数进入中，4：在线）
     * @leftSeconds             倒数秒数（整型）（可无，仅当anchor_status=3时存在）
     * @loveLevel               与观众的私密等级
     * @videoUrl                主播视频流url（字符串数组）（访问视频URL的协议参考《“视频URL”协议描述》
     */
    string              anchorId;
    string              nickName;
    string              photoUrl;
    AnchorStatus        anchorStatus;
    int                 leftSeconds;
    int                 loveLevel;
    list<string>        videoUrl;
    
};

typedef list<OtherAnchorItem> OtherAnchorItemList;


#endif /* OTHERANCHORITEM_H_*/
