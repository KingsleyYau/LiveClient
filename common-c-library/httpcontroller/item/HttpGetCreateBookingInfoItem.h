/*
 * HttpGetCreateBookingInfoItem.h
 *
 *  Created on: 2017-8-28
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPGETCREATEBOOKINGINFOITEM_H_
#define HTTPGETCREATEBOOKINGINFOITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"

class HttpGetCreateBookingInfoItem {
public:
    class BookTimeItem {
    public:
        bool Parse(const Json::Value& root) {
            bool result = false;
            /* timeId */
            if (root[LIVEROOM_GETCREATEBOOKINGINFO_BOOKTIME_TIMEID].isString()) {
                timeId = root[LIVEROOM_GETCREATEBOOKINGINFO_BOOKTIME_TIMEID].asString();
            }
            /* time */
            if (root[LIVEROOM_GETCREATEBOOKINGINFO_BOOKTIME_TIME].isInt()) {
                time = root[LIVEROOM_GETCREATEBOOKINGINFO_BOOKTIME_TIME].asInt();
            }
            
            /* status */
            if (root[LIVEROOM_GETCREATEBOOKINGINFO_BOOKTIME_STATUS].isInt()) {
                status = (BookTimeStatus)root[LIVEROOM_GETCREATEBOOKINGINFO_BOOKTIME_STATUS].asInt();
            }
            if (!timeId.empty()) {
                result = true;
            }
            return result;
        }

        BookTimeItem() {
            timeId = "";
            time = 0.0;
            status = BOOKTIMESTATUS_BOOKING;
        }
        
        virtual ~BookTimeItem() {
            
        }
        
        /**
         * 新建预约邀请信息结构体
         * timeId			预约时间ID
         * time              预约时间（1970年起的秒数）
         * status            预约时间状态（0:可预约 1:本人已邀请 2:本人已确认）
         */
        string   timeId;
        long     time;
        BookTimeStatus status;

    };
    typedef list<BookTimeItem> BookTimeList;
    
    class GiftNumItem {
    public:
        bool Parse(const Json::Value& root) {
            bool result = false;
            /* num */
            if (root[LIVEROOM_GETCREATEBOOKINGINFO_BOOKGIFT_GIFTLIST_GIFTNUMLIST_NUM].isInt()) {
                num = root[LIVEROOM_GETCREATEBOOKINGINFO_BOOKGIFT_GIFTLIST_GIFTNUMLIST_NUM].asInt();
            }
            
            /* isDefault */
            if (root[LIVEROOM_GETCREATEBOOKINGINFO_BOOKGIFT_GIFTLIST_GIFTNUMLIST_ISDEFAULT].isInt()) {
                isDefault = root[LIVEROOM_GETCREATEBOOKINGINFO_BOOKGIFT_GIFTLIST_GIFTNUMLIST_ISDEFAULT].asInt();
            }
            if (num > 0) {
                result = true;
            }
            return result;
        }
        
        GiftNumItem() {
            num = 0;
            isDefault = false;
        }
        
        virtual ~GiftNumItem() {
        
        }
        /**
         * 有效直播间结构体
         * num			可选礼物数量
         * isDefault     是否默认选中（0:否 1:是）
         */
        int  num;
        bool isDefault;
    };
    typedef list<GiftNumItem> GiftNumList;
    
    class GiftItem {
    public:
        bool Parse(const Json::Value& root) {
            bool result = false;
            /* giftId */
            if (root[LIVEROOM_GETCREATEBOOKINGINFO_BOOKGIFT_GIFTLIST_GIFTID].isString()) {
                giftId = root[LIVEROOM_GETCREATEBOOKINGINFO_BOOKGIFT_GIFTLIST_GIFTID].asString();
            }
            
            /* giftNumList */
            if (root[LIVEROOM_GETCREATEBOOKINGINFO_BOOKGIFT_GIFTLIST_GIFTNUMLIST].isArray()) {
                for (int i = 0; i < root[LIVEROOM_GETCREATEBOOKINGINFO_BOOKGIFT_GIFTLIST_GIFTNUMLIST].size(); i++) {
                    Json::Value element = root[LIVEROOM_GETCREATEBOOKINGINFO_BOOKGIFT_GIFTLIST_GIFTNUMLIST].get(i, Json::Value::null);
                    GiftNumItem item;
                    if ( item.Parse(element)) {
                        giftNumList.push_back(item);
                    }
                    
                }
                
            }
            if (!giftId.empty()) {
                result = true;
            }
            return result;
        }
        
        GiftItem() {
            giftId = "";
        }
        
        virtual ~GiftItem() {
            
        }
        /**
         * 有效直播间结构体
         * giftId		礼物ID
         * giftNumList   可选礼物数量列表
         */
        string      giftId;
        GiftNumList giftNumList;
    };
    typedef list<GiftItem> GiftList;
    
    class BookGiftItem {
    public:
        bool Parse(const Json::Value& root) {
            bool result = false;
            /* giftList */
            if (root[LIVEROOM_GETCREATEBOOKINGINFO_BOOKGIFT_GIFTLIST].isArray()) {
                for (int i = 0; i < root[LIVEROOM_GETCREATEBOOKINGINFO_BOOKGIFT_GIFTLIST].size(); i++) {
                    Json::Value element = root[LIVEROOM_GETCREATEBOOKINGINFO_BOOKGIFT_GIFTLIST].get(i, Json::Value::null);
                    GiftItem item;
                    if ( item.Parse(element)) {
                        giftList.push_back(item);
                    }
                    
                }
            }
            result = true;
            return result;
        }
        
        BookGiftItem() {
        }
        
        virtual ~BookGiftItem() {
            
        }
        /**
         *
         * giftList   预约列表
         */
        GiftList   giftList;
    };
    
    void Parse(const Json::Value& root) {
		if( root.isObject() ) {
            
            /* bookDeposit */
            if (root[LIVEROOM_GETCREATEBOOKINGINFO_BOOKDEPOSIT].isDouble()) {
                bookDeposit = root[LIVEROOM_GETCREATEBOOKINGINFO_BOOKDEPOSIT].asDouble();
            }
            /* bookTime */
            if (root[LIVEROOM_GETCREATEBOOKINGINFO_BOOKTIME].isArray()) {
                for (int i = 0; i < root[LIVEROOM_GETCREATEBOOKINGINFO_BOOKTIME].size(); i++) {
                    Json::Value element = root[LIVEROOM_GETCREATEBOOKINGINFO_BOOKTIME].get(i, Json::Value::null);
                    BookTimeItem item;
                    if ( item.Parse(element)) {
                        bookTime.push_back(item);
                    }
                   
                }
                
            }
            
            /* bookGift */
            if( root[LIVEROOM_GETCREATEBOOKINGINFO_BOOKGIFT].isObject() ) {
                bookGift.Parse(root[LIVEROOM_GETCREATEBOOKINGINFO_BOOKGIFT]);
            }

            
        }
    }

	HttpGetCreateBookingInfoItem() {
        bookDeposit = 0.0;
	}

	virtual ~HttpGetCreateBookingInfoItem() {

	}

    /**
     * 登录成功结构体
     * bookDeposit	预约定金数
     * bookTime      预约时间表
     * bookGift      预约礼物
     */
    double bookDeposit;
    BookTimeList bookTime;
    BookGiftItem bookGift;

};


#endif /* HTTPGETCREATEBOOKINGINFOITEM_H_ */
