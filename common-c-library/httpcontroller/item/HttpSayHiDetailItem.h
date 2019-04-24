/*
 * HttpSayHiDetailItem.h
 *
 *  Created on: 2018-4-18
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPSAYHIDETAILITEM_H_
#define HTTPSAYHIDETAILITEM_H_

#include <string>
using namespace std;

#include "../HttpLoginProtocol.h"

class HttpSayHiDetailItem {
public:
    class SayHiDetailItem {
    public:
        bool Parse(const Json::Value& root) {
            bool result = false;
            /* sayHiId */
            if (root[LIVEROOM_SAYHIDETAIL_DETAIL_SAYHIID].isString()) {
                sayHiId = root[LIVEROOM_SAYHIDETAIL_DETAIL_SAYHIID].asString();
            }
            /* anchorId */
            if (root[LIVEROOM_SAYHIDETAIL_DETAIL_ANCHORID].isString()) {
                anchorId = root[LIVEROOM_SAYHIDETAIL_DETAIL_ANCHORID].asString();
            }
            /* nickName */
            if (root[LIVEROOM_SAYHIDETAIL_DETAIL_ANCHORNICKNAME].isString()) {
                nickName = root[LIVEROOM_SAYHIDETAIL_DETAIL_ANCHORNICKNAME].asString();
            }
            /* cover */
            if (root[LIVEROOM_SAYHIDETAIL_DETAIL_ANCHORCOVER].isString()) {
                cover = root[LIVEROOM_SAYHIDETAIL_DETAIL_ANCHORCOVER].asString();
            }
            /* avatar */
            if (root[LIVEROOM_SAYHIDETAIL_DETAIL_ANCHORAVATAR].isString()) {
                avatar = root[LIVEROOM_SAYHIDETAIL_DETAIL_ANCHORAVATAR].asString();
            }
            /* age */
            if (root[LIVEROOM_SAYHIDETAIL_DETAIL_ANCHORAGE].isNumeric()) {
                age = root[LIVEROOM_SAYHIDETAIL_DETAIL_ANCHORAGE].asInt();
            }
            /* sendTime */
            if (root[LIVEROOM_SAYHIDETAIL_DETAIL_SENDTIME].isNumeric()) {
                sendTime = root[LIVEROOM_SAYHIDETAIL_DETAIL_SENDTIME].asInt();
            }
            /* text */
            if (root[LIVEROOM_SAYHIDETAIL_DETAIL_TEXT].isString()) {
                text = root[LIVEROOM_SAYHIDETAIL_DETAIL_TEXT].asString();
            }
            /* img */
            if (root[LIVEROOM_SAYHIDETAIL_DETAIL_IMG].isString()) {
                img = root[LIVEROOM_SAYHIDETAIL_DETAIL_IMG].asString();
            }
            /* responseNum */
            if (root[LIVEROOM_SAYHIDETAIL_DETAIL_RESPONSENUM].isNumeric()) {
                responseNum = root[LIVEROOM_SAYHIDETAIL_DETAIL_RESPONSENUM].asInt();
            }
            /* unreadNum */
            if (root[LIVEROOM_SAYHIDETAIL_DETAIL_UNREADNUM].isNumeric()) {
                unreadNum = root[LIVEROOM_SAYHIDETAIL_DETAIL_UNREADNUM].asInt();
            }

            result = true;
            return result;
        }
        
        SayHiDetailItem() {
            sayHiId = "";
            anchorId = "";
            nickName = "";
            cover = "";
            avatar = "";
            age = 0;
            sendTime = 0;
            text = "";
            img = "";
            responseNum = 0;
            unreadNum = 0;
        }
        
        virtual ~SayHiDetailItem() {
            
        }
        /**
         *  sayHi详情
         *  sayHiId         sayHi的ID
         *  anchorId        主播ID
         *  nickName        主播昵称
         *  cover           主播封面
         *  avatar          主播头像
         *  age             主播年龄
         *  sendTime        发送时间戳
         *  text            文本内容
         *  img             图片地址
         *  responseNum     回复数
         *  unreadNum       未读数
         */
        string      sayHiId;
        string      anchorId;
        string      nickName;
        string      cover;
        string      avatar;
        int         age;
        long long   sendTime;
        string      text;
        string      img;
        int         responseNum;
        int         unreadNum;
    };
    class ResponseSayHiDetailItem {
    public:
        bool Parse(const Json::Value& root) {
            bool result = false;
            /* responseId */
            if (root[LIVEROOM_SAYHIDETAIL_RESPONSELIST_RESPONSEID].isString()) {
                responseId = root[LIVEROOM_SAYHIDETAIL_RESPONSELIST_RESPONSEID].asString();
            }
            /* responseTime */
            if (root[LIVEROOM_SAYHIDETAIL_RESPONSELIST_RESPONSETIME].isNumeric()) {
                responseTime = root[LIVEROOM_SAYHIDETAIL_RESPONSELIST_RESPONSETIME].asInt();
            }
            /* content */
            if (root[LIVEROOM_SAYHIDETAIL_RESPONSELIST_CONTENT].isString()) {
                content = root[LIVEROOM_SAYHIDETAIL_RESPONSELIST_CONTENT].asString();
            }
            /* isFree */
            if (root[LIVEROOM_SAYHIDETAIL_RESPONSELIST_ISFREE].isNumeric()) {
                isFree = root[LIVEROOM_SAYHIDETAIL_RESPONSELIST_ISFREE].asInt() == 1 ? true : false;
            }
            /* hasRead */
            if (root[LIVEROOM_SAYHIDETAIL_RESPONSELIST_HASREAD].isNumeric()) {
                hasRead = root[LIVEROOM_SAYHIDETAIL_RESPONSELIST_HASREAD].asInt() == 1 ? true : false;
            }
            /* hasImg */
            if (root[LIVEROOM_SAYHIDETAIL_RESPONSELIST_HASIMG].isNumeric()) {
                hasImg = root[LIVEROOM_SAYHIDETAIL_RESPONSELIST_HASIMG].asInt() == 1 ? true : false;
            }
            /* img */
            if (root[LIVEROOM_SAYHIDETAIL_RESPONSELIST_IMG].isString()) {
                img = root[LIVEROOM_SAYHIDETAIL_RESPONSELIST_IMG].asString();
            }

            result = true;
            return result;
        }
        
        ResponseSayHiDetailItem() {
            responseId = "";
            responseTime = 0;
            content = "";
            isFree = false;
            hasRead = false;
            hasImg = false;
            img = "";
        }
        
        virtual ~ResponseSayHiDetailItem() {
            
        }
        /**
         *  sayHi回复列表
         *  responseId          回复ID
         *  responseTime        回复时间戳
         *  content             回复内容
         *  isFree              是否免费（1：是，0：否）
         *  hasRead             是否已读（1：是，0：否）
         *  hasImg              是否有图片（1：有，0：无）
         *  img                 图片地址
         */
        string      responseId;
        long long   responseTime;
        string      content;
        bool        isFree;
        bool        hasRead;
        bool        hasImg;
        string      img;
        
    };
    typedef list<ResponseSayHiDetailItem> ResponseSayHiDetailList;
    bool Parse(const Json::Value& root) {
        bool result = false;
        if (root.isObject()) {
            
            /* detail */
            if (root[LIVEROOM_SAYHIDETAIL_DETAIL].isObject()) {
                detail.Parse(root[LIVEROOM_SAYHIDETAIL_DETAIL]);
            }
            
            /* responseList */
            if( root[LIVEROOM_SAYHIDETAIL_RESPONSELIST].isArray()) {
                for (int i = 0; i < root[LIVEROOM_SAYHIDETAIL_RESPONSELIST].size(); i++) {
                    Json::Value element = root[LIVEROOM_SAYHIDETAIL_RESPONSELIST].get(i, Json::Value::null);
                    ResponseSayHiDetailItem item;
                    if (item.Parse(element)) {
                        responseList.push_back(item);
                    }
                }
            }

        }
        result = true;
        return result;
    }

    HttpSayHiDetailItem() {
    }
    
    virtual ~HttpSayHiDetailItem() {
        
    }
    
    /**
     * SayHi详情
     * detail          详情
     * responseList    sayHi回复列表
     */
    SayHiDetailItem detail;
    ResponseSayHiDetailList responseList;
};

#endif /* HTTPSAYHIDETAILITEM_H_*/
