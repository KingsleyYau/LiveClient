/*
 * IMOtherAnchorItem.h
 *
 *  Created on: 2018-04-13
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef IMOTHERANCHORITEM_H_
#define IMOTHERANCHORITEM_H_

#include <string>
using namespace std;

#include "IMRecvGiftItem.h"
#include <json/json/json.h>

#define IMOTHERANCHOR_ANCHORID_PARAM          "anchor_id"
#define IMOTHERANCHOR_NICKNAME_PARAM          "nickname"
#define IMOTHERANCHOR_PHOTOURL_PARAM          "photourl"
#define IMOTHERANCHOR_ANVHORSTATUS_PARAM      "anchor_status"
#define IMOTHERANCHOR_INVITEID_PARAM          "invite_id"
#define IMOTHERANCHOR_LEFTSECONDS_PARAM       "left_seconds"
#define IMOTHERANCHOR_LOVELEVEL_PARAM         "love_level"
#define IMOTHERANCHOR_VIDEOURL_PARAM          "video_url"


class IMOtherAnchorItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* anchorId */
            if (root[IMOTHERANCHOR_ANCHORID_PARAM].isString()) {
                anchorId = root[IMOTHERANCHOR_ANCHORID_PARAM].asString();
            }
            /* nickName */
            if (root[IMOTHERANCHOR_NICKNAME_PARAM].isString()) {
                nickName = root[IMOTHERANCHOR_NICKNAME_PARAM].asString();
            }
            /* photoUrl */
            if (root[IMOTHERANCHOR_PHOTOURL_PARAM].isString()) {
                photoUrl = root[IMOTHERANCHOR_PHOTOURL_PARAM].asString();
            }
            /* anchorStatus */
            if (root[IMOTHERANCHOR_ANVHORSTATUS_PARAM].isNumeric()) {
                anchorStatus = GetLiveAnchorStatus(root[IMOTHERANCHOR_ANVHORSTATUS_PARAM].asInt());
            }
            /* inviteId */
            if (root[IMOTHERANCHOR_INVITEID_PARAM].isString()) {
                inviteId = root[IMOTHERANCHOR_INVITEID_PARAM].asString();
            }
            /* leftSeconds */
            if (root[IMOTHERANCHOR_LEFTSECONDS_PARAM].isNumeric()) {
                leftSeconds = root[IMOTHERANCHOR_LEFTSECONDS_PARAM].asInt();
            }
            /* loveLevel */
            if (root[IMOTHERANCHOR_LOVELEVEL_PARAM].isNumeric()) {
                loveLevel = root[IMOTHERANCHOR_LOVELEVEL_PARAM].asInt();
            }
            /* videoUrl */
            if (root[IMOTHERANCHOR_VIDEOURL_PARAM].isArray()) {
                int i = 0;
                for (i = 0; i < root[IMOTHERANCHOR_VIDEOURL_PARAM].size(); i++) {
                    Json::Value element = root[IMOTHERANCHOR_VIDEOURL_PARAM].get(i, Json::Value::null);
                    if (element.isString()) {
                        videoUrl.push_back(element.asString());
                    }
                }
            }

        }

        return result;
    }
    
    IMOtherAnchorItem() {
        anchorId = "";
        nickName = "";
        photoUrl = "";
        anchorStatus = LIVEANCHORSTATUS_UNKNOW;
        inviteId = "";
        leftSeconds = 0;
        loveLevel = 0;

    }
    
    virtual ~IMOtherAnchorItem() {
        
    }
    /**
     * 直播间中的主播列表
     * @anchorId                主播ID
     * @nickName                主播昵称
     * @photoUrl                主播头像url
     * @anchorStatus            主播状态（0：邀请中，1：邀请已确认，2：敲门已确认，3：倒数进入中，4：在线）
     * @inviteId                邀请ID（可无，仅当anchor_status=0时存在）
     * @leftSeconds             倒数秒数（整型）（可无，仅当anchor_status=3时存在）
     * @loveLevel               与观众的私密等级
     * @videoUrl                主播视频流url（字符串数组）（访问视频URL的协议参考《“视频URL”协议描述》
     */
    string              anchorId;
    string              nickName;
    string              photoUrl;
    LiveAnchorStatus    anchorStatus;
    string              inviteId;
    int                 leftSeconds;
    int                 loveLevel;
    list<string>        videoUrl;
    
};

typedef list<IMOtherAnchorItem> IMOtherAnchorItemList;


#endif /* IMOTHERANCHORITEM_H_*/
