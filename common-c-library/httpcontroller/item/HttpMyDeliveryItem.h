/*
 * HttpMyDeliveryItem.h
 *
 *  Created on: 2019-8-27
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPMYDELIVERYITEM_H_
#define HTTPMYDELIVERYITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "HttpDeliveryFlowerGiftItem.h"

class HttpMyDeliveryItem {
public:

	bool Parse(const Json::Value& root) {
        bool result = false;
		if( root.isObject() ) {
            
			/* orderNumber */
			if( root[LIVEROOM_GETDELIVERYLIST_LIST_ORDERNUMBER].isString() ) {
				orderNumber = root[LIVEROOM_GETDELIVERYLIST_LIST_ORDERNUMBER].asString();
			}
            
            /* orderDate */
            if( root[LIVEROOM_GETDELIVERYLIST_LIST_ORDERDATE].isNumeric() ) {
                orderDate = root[LIVEROOM_GETDELIVERYLIST_LIST_ORDERDATE].asLong();
            }
            
            /* anchorId */
            if (root[LIVEROOM_GETDELIVERYLIST_LIST_ANCHORID].isString()) {
                anchorId = root[LIVEROOM_GETDELIVERYLIST_LIST_ANCHORID].asString();
            }
            
            /* anchorNickName */
            if (root[LIVEROOM_GETDELIVERYLIST_LIST_ANCHORNICKNAME].isString()) {
                anchorNickName = root[LIVEROOM_GETDELIVERYLIST_LIST_ANCHORNICKNAME].asString();
            }
            
            /* anchorAvatar */
            if (root[LIVEROOM_GETDELIVERYLIST_LIST_ANCHORAVATAR].isString()) {
                anchorAvatar = root[LIVEROOM_GETDELIVERYLIST_LIST_ANCHORAVATAR].asString();
            }
            
            /* deliveryStatus */
            if( root[LIVEROOM_GETDELIVERYLIST_LIST_DELIVERYSTATUS].isNumeric() ) {
                deliveryStatus = GetLSDeliveryStatus(root[LIVEROOM_GETDELIVERYLIST_LIST_DELIVERYSTATUS].asInt());
            }
            
            /* deliveryStatusVal */
            if (root[LIVEROOM_GETDELIVERYLIST_LIST_DELIVERYSTATUSVAL].isString()) {
                deliveryStatusVal = root[LIVEROOM_GETDELIVERYLIST_LIST_DELIVERYSTATUSVAL].asString();
            }
            
            /* giftList */
            if( root[LIVEROOM_GETDELIVERYLIST_LIST_GIFTLIST].isArray()) {
                for (int i = 0; i < root[LIVEROOM_GETDELIVERYLIST_LIST_GIFTLIST].size(); i++) {
                    Json::Value element = root[LIVEROOM_GETDELIVERYLIST_LIST_GIFTLIST].get(i, Json::Value::null);
                    HttpDeliveryFlowerGiftItem item;
                    if (item.Parse(element)) {
                        giftList.push_back(item);
                    }
                }
            }
            
            /* greetingMessage */
            if (root[LIVEROOM_GETDELIVERYLIST_LIST_GREETINGMESSAGE].isString()) {
                greetingMessage = root[LIVEROOM_GETDELIVERYLIST_LIST_GREETINGMESSAGE].asString();
            }
            
            /* specialDeliveryRequest */
            if (root[LIVEROOM_GETDELIVERYLIST_LIST_SPECIALDELIVERYREQUEST].isString()) {
                specialDeliveryRequest = root[LIVEROOM_GETDELIVERYLIST_LIST_SPECIALDELIVERYREQUEST].asString();
            }
            
            result = true;
        }
        return result;
    }

	HttpMyDeliveryItem() {
		orderNumber = "";
        orderDate = 0;
        anchorId = "";
        anchorNickName = "";
        anchorAvatar = "";
        deliveryStatus = LSDELIVERYSTATUS_UNKNOW;
        deliveryStatusVal = "";
        greetingMessage = "";
        specialDeliveryRequest = "";
	}

	virtual ~HttpMyDeliveryItem() {

	}
    
    /**
     * Delivery结构体
     * orderNumber                  订单号
     * orderDate                    订单时间戳（1970年起的秒数）
     * anchorId                     主播ID
     * anchorNickName               主播昵称
     * anchorAvatar                 主播头像
     * deliveryStatus               状态（LSDELIVERYSTATUS_UNKNOW：--，LSDELIVERYSTATUS_PENDING：Pending，LSDELIVERYSTATUS_SHIPPED：Shipped，LSDELIVERYSTATUS_DELIVERED：Delivered，LSDELIVERYSTATUS_CANCELLED：Cancelled
     * deliveryStatusVal            状态文字
     * giftList                     产品列表
     * greetingMessage              文本信息
     * specialDeliveryRequest       文本请求
     */
	string orderNumber;
    long long orderDate;
    string anchorId;
    string anchorNickName;
    string anchorAvatar;
    LSDeliveryStatus deliveryStatus;
    string deliveryStatusVal;
    DeliveryFlowerGiftList giftList;
    string greetingMessage;
    string specialDeliveryRequest;
};

typedef list<HttpMyDeliveryItem> DeliveryList;

#endif /* HTTPMYDELIVERYITEM_H_ */
