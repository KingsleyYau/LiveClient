/*
 * HttpResponseSayHiListItem.h
 *
 *  Created on: 2018-4-18
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPRESPONSESAYHILISTITEM_H_
#define HTTPRESPONSESAYHILISTITEM_H_

#include <string>
using namespace std;

#include "../HttpLoginProtocol.h"

class HttpResponseSayHiListItem {
public:
    class ResponseSayHiItem {
    public:
        bool Parse(const Json::Value& root) {
            bool result = false;
            /* sayHiId */
            if (root[LIVEROOM_WAITINGREPLYSAYHILIST_LIST_SAYHIID].isString()) {
                sayHiId = root[LIVEROOM_WAITINGREPLYSAYHILIST_LIST_SAYHIID].asString();
            }
            /* responseId */
            if (root[LIVEROOM_WAITINGREPLYSAYHILIST_LIST_RESPONSEID].isString()) {
                responseId = root[LIVEROOM_WAITINGREPLYSAYHILIST_LIST_RESPONSEID].asString();
            }
            /* anchorId */
            if (root[LIVEROOM_WAITINGREPLYSAYHILIST_LIST_ANCHORID].isString()) {
                anchorId = root[LIVEROOM_WAITINGREPLYSAYHILIST_LIST_ANCHORID].asString();
            }
            /* nickName */
            if (root[LIVEROOM_WAITINGREPLYSAYHILIST_LIST_ANCHORNICKNAME].isString()) {
                nickName = root[LIVEROOM_WAITINGREPLYSAYHILIST_LIST_ANCHORNICKNAME].asString();
            }
            /* cover */
            if (root[LIVEROOM_WAITINGREPLYSAYHILIST_LIST_ANCHORCOVER].isString()) {
                cover = root[LIVEROOM_WAITINGREPLYSAYHILIST_LIST_ANCHORCOVER].asString();
            }
            /* avatar */
            if (root[LIVEROOM_WAITINGREPLYSAYHILIST_LIST_ANCHORAVATAR].isString()) {
                avatar = root[LIVEROOM_WAITINGREPLYSAYHILIST_LIST_ANCHORAVATAR].asString();
            }
            /* age */
            if (root[LIVEROOM_WAITINGREPLYSAYHILIST_LIST_ANCHORAGE].isNumeric()) {
                age = root[LIVEROOM_WAITINGREPLYSAYHILIST_LIST_ANCHORAGE].asInt();
            }
            /* responseTime */
            if (root[LIVEROOM_WAITINGREPLYSAYHILIST_LIST_RESPONSETIME].isNumeric()) {
                responseTime = root[LIVEROOM_WAITINGREPLYSAYHILIST_LIST_RESPONSETIME].asLong();
            }
            /* content */
            if (root[LIVEROOM_WAITINGREPLYSAYHILIST_LIST_CONTENT].isString()) {
                content = root[LIVEROOM_WAITINGREPLYSAYHILIST_LIST_CONTENT].asString();
            }
            /* hasImg */
            if (root[LIVEROOM_WAITINGREPLYSAYHILIST_LIST_HASIMG].isNumeric()) {
                hasImg = root[LIVEROOM_WAITINGREPLYSAYHILIST_LIST_HASIMG].asInt() == 1 ? true : false;
            }
            /* hasRead */
            if (root[LIVEROOM_WAITINGREPLYSAYHILIST_LIST_HASREAD].isNumeric()) {
                hasRead = root[LIVEROOM_WAITINGREPLYSAYHILIST_LIST_HASREAD].asInt() == 1 ? true : false;
            }
            /* isFree */
            if (root[LIVEROOM_WAITINGREPLYSAYHILIST_LIST_ISFREE].isNumeric()) {
                isFree = root[LIVEROOM_WAITINGREPLYSAYHILIST_LIST_ISFREE].asInt() == 1 ? true : false;
            }
            result = true;
            return result;
        }
        
        ResponseSayHiItem() {
            sayHiId = "";
            responseId = "";
            anchorId = "";
            nickName = "";
            cover = "";
            avatar = "";
            age = 0;
            responseTime = 0;
            content = "";
            hasImg = false;
            hasRead = false;
            isFree = false;
        }
        
        virtual ~ResponseSayHiItem() {
            
        }
        /**
         *  Waiting for your reply列表
         *  sayHiId         sayHi的ID
         *  responseId      回复ID
         *  anchorId        主播ID
         *  nickName        主播昵称
         *  cover           主播封面
         *  avatar          主播头像
         *  age             主播年龄
         *  responseTime    回复时间戳
         *  content         回复内容的摘要
         *  hasImg          是否有图片（1：有，0：无）
         *  hasRead         是否已读（1：是，0：否）
         *  isFree          是否免费（1：是，0：否）
         */
        string      sayHiId;
        string      responseId;
        string      anchorId;
        string      nickName;
        string      cover;
        string      avatar;
        int         age;
        long long   responseTime;
        string      content;
        bool        hasImg;
        bool        hasRead;
        bool        isFree;
    };
    typedef list<ResponseSayHiItem> ResponseSayHiList;
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            
            /* totalCount */
            if (root[LIVEROOM_WAITINGREPLYSAYHILIST_TOTALCOUNT].isNumeric()) {
                totalCount = root[LIVEROOM_WAITINGREPLYSAYHILIST_TOTALCOUNT].asInt();
            }
            
            /* responseList */
            if( root[LIVEROOM_WAITINGREPLYSAYHILIST_LIST].isArray()) {
                for (int i = 0; i < root[LIVEROOM_WAITINGREPLYSAYHILIST_LIST].size(); i++) {
                    Json::Value element = root[LIVEROOM_WAITINGREPLYSAYHILIST_LIST].get(i, Json::Value::null);
                    ResponseSayHiItem item;
                    if (item.Parse(element)) {
                        responseList.push_back(item);
                    }
                }
            }

        }
        result = true;
        return result;
    }

    HttpResponseSayHiListItem() {
        totalCount = 0;
    }
    
    virtual ~HttpResponseSayHiListItem() {
        
    }
    
    /**
     * Waiting for your reply列表
     * totalCount       总数
     * list             Waiting for your reply列表
     */
    int totalCount;
    ResponseSayHiList responseList;
};

#endif /* HTTPRESPONSESAYHILISTITEM_H_*/
