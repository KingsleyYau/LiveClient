/*
 * AnchorItem.h
 *
 *  Created on: 2018-04-09
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef ANCHORITEM_H_
#define ANCHORITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#define ANCHOR_ANCHORID_PARAM             "anchor_id"
#define ANCHOR_ANCHORNICKNAME_PARAM       "anchor_nickname"
#define ANCHOR_ANCHORPHOTOURL_PARAM       "anchor_photourl"



class AnchorItem {
public:
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            /* anchorId */
            if (root[ANCHOR_ANCHORID_PARAM].isString()) {
                anchorId = root[ANCHOR_ANCHORID_PARAM].asString();
            }
            /* anchorNickName */
            if (root[ANCHOR_ANCHORNICKNAME_PARAM].isString()) {
                anchorNickName = root[ANCHOR_ANCHORNICKNAME_PARAM].asString();
            }
            /* anchorPhotoUrl */
            if (root[ANCHOR_ANCHORPHOTOURL_PARAM].isString()) {
                anchorPhotoUrl = root[ANCHOR_ANCHORPHOTOURL_PARAM].asString();
            }
            
        }
        return result;
    }
    
    AnchorItem() {
        anchorId = "";
        anchorNickName = "";
        anchorPhotoUrl = "";
    }
    
    virtual ~AnchorItem() {
        
    }
    /**
     * 已在直播间的主播列表
     * @anchorId            主播ID
     * @anchorNickName      主播昵称
     * @anchorPhotoUrl      主播头像
     */

    string      anchorId;
    string      anchorNickName;
    string      anchorPhotoUrl;
    
};

typedef list<AnchorItem> AnchorItemList;


#endif /* ANCHORITEM_H_*/
