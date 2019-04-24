/*
 * HttpAllSayHiListItem.h
 *
 *  Created on: 2018-4-18
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPALLSAYHILISTITEM_H_
#define HTTPALLSAYHILISTITEM_H_

#include <string>
using namespace std;

#include "../HttpLoginProtocol.h"

class HttpAllSayHiListItem {
public:
    class AllSayHiItem {
    public:
        bool Parse(const Json::Value& root) {
            bool result = false;
            /* sayHiId */
            if (root[LIVEROOM_ALLSAYHILIST_LIST_SAYHIID].isString()) {
                sayHiId = root[LIVEROOM_ALLSAYHILIST_LIST_SAYHIID].asString();
            }
            /* anchorId */
            if (root[LIVEROOM_ALLSAYHILIST_LIST_ANCHORID].isString()) {
                anchorId = root[LIVEROOM_ALLSAYHILIST_LIST_ANCHORID].asString();
            }
            /* nickName */
            if (root[LIVEROOM_ALLSAYHILIST_LIST_ANCHORNICKNAME].isString()) {
                nickName = root[LIVEROOM_ALLSAYHILIST_LIST_ANCHORNICKNAME].asString();
            }
            /* cover */
            if (root[LIVEROOM_ALLSAYHILIST_LIST_ANCHORCOVER].isString()) {
                cover = root[LIVEROOM_ALLSAYHILIST_LIST_ANCHORCOVER].asString();
            }
            /* avatar */
            if (root[LIVEROOM_ALLSAYHILIST_LIST_ANCHORAVATAR].isString()) {
                avatar = root[LIVEROOM_ALLSAYHILIST_LIST_ANCHORAVATAR].asString();
            }
            /* age */
            if (root[LIVEROOM_ALLSAYHILIST_LIST_ANCHORAGE].isNumeric()) {
                age = root[LIVEROOM_ALLSAYHILIST_LIST_ANCHORAGE].asInt();
            }
            /* responseNum */
            if (root[LIVEROOM_ALLSAYHILIST_LIST_RESPONSENUM].isNumeric()) {
                responseNum = root[LIVEROOM_ALLSAYHILIST_LIST_RESPONSENUM].asInt();
            }
            /* unreadNum */
            if (root[LIVEROOM_ALLSAYHILIST_LIST_UNREADNUM].isNumeric()) {
                unreadNum = root[LIVEROOM_ALLSAYHILIST_LIST_UNREADNUM].asInt();
            }
            result = true;
            return result;
        }
        
        AllSayHiItem() {
            sayHiId = "";
            anchorId = "";
            nickName = "";
            cover = "";
            avatar = "";
            age = 0;
            responseNum = 0;
            unreadNum = 0;
        }
        
        virtual ~AllSayHiItem() {
            
        }
        /**
         *  All列表
         *  sayHiId         sayHi的ID
         *  anchorId        主播ID
         *  nickName        主播昵称
         *  cover           主播封面
         *  avatar          主播头像
         *  age             主播年龄
         *  responseNum     回复数
         *  unreadNum       未读数
         */
        string      sayHiId;
        string      anchorId;
        string      nickName;
        string      cover;
        string      avatar;
        int         age;
        int         responseNum;
        int         unreadNum;
    };
    typedef list<AllSayHiItem> AllSayHiList;
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            
            /* totalCount */
            if (root[LIVEROOM_ALLSAYHILIST_TOTALCOUNT].isNumeric()) {
                totalCount = root[LIVEROOM_ALLSAYHILIST_TOTALCOUNT].asInt();
            }
            
            /* allList */
            if( root[LIVEROOM_ALLSAYHILIST_LIST].isArray()) {
                for (int i = 0; i < root[LIVEROOM_ALLSAYHILIST_LIST].size(); i++) {
                    Json::Value element = root[LIVEROOM_ALLSAYHILIST_LIST].get(i, Json::Value::null);
                    AllSayHiItem item;
                    if (item.Parse(element)) {
                        allList.push_back(item);
                    }
                }
            }

        }
        result = true;
        return result;
    }

    HttpAllSayHiListItem() {
        totalCount = 0;
    }
    
    virtual ~HttpAllSayHiListItem() {
        
    }
    
    /**
     * All ‘Say Hi’列表
     * totalCount       总数
     * list             All列表
     */
    int totalCount;
    AllSayHiList allList;
};

#endif /* HTTPALLSAYHILISTITEM_H_*/
