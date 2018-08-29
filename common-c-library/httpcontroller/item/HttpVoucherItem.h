/*
 * HttpVoucherItem.h
 *
 *  Created on: 2017-8-29
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPVOUCHERITEM_H_
#define HTTPVOUCHERITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>
#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"

class HttpVoucherItem {
public:
    void Parse(const Json::Value& root) {
        if (root.isObject()) {
            /* voucherId */
            if (root[LIVEROOM_VOUCHERLIST_LIST_ID].isString()) {
                voucherId = root[LIVEROOM_VOUCHERLIST_LIST_ID].asString();
            }
            /* photoUrl */
            if (root[LIVEROOM_VOUCHERLIST_LIST_PHOTOURL].isString()) {
                photoUrl = root[LIVEROOM_VOUCHERLIST_LIST_PHOTOURL].asString();
            }
            /* photoUrlMobile */
            if (root[LIVEROOM_VOUCHERLIST_LIST_PHOTOURLMOBILE].isString()) {
                photoUrlMobile = root[LIVEROOM_VOUCHERLIST_LIST_PHOTOURLMOBILE].asString();
            }
            /* desc */
            if (root[LIVEROOM_VOUCHERLIST_LIST_DESC].isString()) {
                desc = root[LIVEROOM_VOUCHERLIST_LIST_DESC].asString();
            }
            /* useRoomType */
            if (root[LIVEROOM_VOUCHERLIST_LIST_USEROOMTYPE].isInt()) {
                useRoomType = GetIntToUseRoomType(root[LIVEROOM_VOUCHERLIST_LIST_USEROOMTYPE].asInt());
            }
            /* anchorType */
            if (root[LIVEROOM_VOUCHERLIST_LIST_ANCHORTYPE].isInt()) {
                anchorType = GetIntToAnchorType(root[LIVEROOM_VOUCHERLIST_LIST_ANCHORTYPE].asInt());
            }
            /* anchorId */
            if (root[LIVEROOM_VOUCHERLIST_LIST_ANCHORID].isString()) {
                anchorId = root[LIVEROOM_VOUCHERLIST_LIST_ANCHORID].asString();
            }
            /* anchorNcikName */
            if (root[LIVEROOM_VOUCHERLIST_LIST_ANCHORNICKNAME].isString()) {
                anchorNcikName = root[LIVEROOM_VOUCHERLIST_LIST_ANCHORNICKNAME].asString();
            }
            /* anchorPhotoUrl */
            if (root[LIVEROOM_VOUCHERLIST_LIST_ANCHORPHOTORUL].isString()) {
                anchorPhotoUrl = root[LIVEROOM_VOUCHERLIST_LIST_ANCHORPHOTORUL].asString();
            }
            /* grantedDate */
            if (root[LIVEROOM_VOUCHERLIST_LIST_GRANTEDDATE].isIntegral()) {
                grantedDate = root[LIVEROOM_VOUCHERLIST_LIST_GRANTEDDATE].asInt();
            }
            /* startValidDate */
            if (root[LIVEROOM_VOUCHERLIST_LIST_STARTVALIDDATE].isIntegral()) {
                startValidDate = root[LIVEROOM_VOUCHERLIST_LIST_STARTVALIDDATE].asInt();
            }
            /* expDate */
            if (root[LIVEROOM_VOUCHERLIST_LIST_EXPDATE].isIntegral()) {
                expDate = root[LIVEROOM_VOUCHERLIST_LIST_EXPDATE].asInt();
            }
            /* read */
            if (root[LIVEROOM_VOUCHERLIST_LIST_READ].isIntegral()) {
                read = root[LIVEROOM_VOUCHERLIST_LIST_READ].asInt() == 0 ? false : true;
            }
        }

    }
    
    HttpVoucherItem() {
        voucherId = "";
        photoUrl = "";
        photoUrlMobile = "";
        desc = "";
        useRoomType = USEROOMTYPE_LIMITLESS;
        anchorType = ANCHORTYPE_LIMITLESS;
        anchorId = "";
        anchorNcikName = "";
        anchorPhotoUrl = "";
        grantedDate = 0;
        startValidDate = 0;
        expDate = 0;
        read = false;

    }
    
    virtual ~HttpVoucherItem() {
        
    }
    
    /**
     * 有效邀请数组结构体
     * voucherId       试用劵ID
     * photoUrl        试用劵图标url
     * photoUrlMobile  试用券图标url（移动端使用）
     * desc            试用劵描述
     * useRoomType     可用的直播间类型（0: 不限 1:公开 2:私密）
     * anchorType      主播类型（0:不限 1:没看过直播的主播 2:指定主播）
     * anchorId        主播ID
     * anchorNcikName  主播昵称
     * anchorPhotoUrl  主播头像url
     * grantedDate     获取时间
     * startValidDate  有效开始时间
     * expDate         过期时间
     * read            已读状态（0:未读 1:已读）
     */
    string voucherId;
    string photoUrl;
    string photoUrlMobile;
    string desc;
    UseRoomType useRoomType;
    AnchorType anchorType;
    string anchorId;
    string anchorNcikName;
    string anchorPhotoUrl;
    long grantedDate;
    long startValidDate;
    long expDate;
    bool read;
};

typedef list<HttpVoucherItem> VoucherList;

#endif /* HTTPVOUCHERITEM_H_*/
