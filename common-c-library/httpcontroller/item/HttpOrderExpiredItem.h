/*
 * HttpOrderExpiredItem.h
 *
 *  Created on: 2020-04-10
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPORDEREXPIREDITEM_H_
#define HTTPORDEREXPIREDITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"

class HttpOrderExpiredItem {
public:
//	void Parse(const Json::Value& root) {
//		if( root.isObject() ) {
//
//            /* itemCode */
//            if (root[LIVEROOM_GETPOSTSTAMPSPRICELIST_ITEMCODE].isString()) {
//                itemCode = root[LIVEROOM_GETPOSTSTAMPSPRICELIST_ITEMCODE].asString();
//            }
//
//            /* itemName */
//            if (root[LIVEROOM_GETPOSTSTAMPSPRICELIST_ITEMNAME].isString()) {
//                itemName = root[LIVEROOM_GETPOSTSTAMPSPRICELIST_ITEMNAME].asString();
//            }
//
//            /* originalPrice */
//            if (root[LIVEROOM_GETPOSTSTAMPSPRICELIST_ORIGINALPRICE].isString()) {
//                originalPrice = root[LIVEROOM_GETPOSTSTAMPSPRICELIST_ORIGINALPRICE].asString();
//            }
//
//            /* discountPrice */
//            if (root[LIVEROOM_GETPOSTSTAMPSPRICELIST_DISCOUNTPRICE].isString()) {
//                discountPrice = root[LIVEROOM_GETPOSTSTAMPSPRICELIST_DISCOUNTPRICE].asString();
//            }
//
//            /* saveDesc */
//            if (root[LIVEROOM_GETPOSTSTAMPSPRICELIST_SAVEDESC].isString()) {
//                saveDesc = root[LIVEROOM_GETPOSTSTAMPSPRICELIST_SAVEDESC].asString();
//            }
//
//            /* postStampsNum */
//            if (root[LIVEROOM_GETPOSTSTAMPSPRICELIST_POSTSTAMPSNUM].isString()) {
//                postStampsNum = root[LIVEROOM_GETPOSTSTAMPSPRICELIST_POSTSTAMPSNUM].asString();
//            }
//
//        }
//	}
    
    Json::Value PackInfo() {
        Json::Value value;
        value[LIVEROOM_ORDEREXPIREDREPORT_ORDERINFOS_ORDERNO] = orderNo;
        value[LIVEROOM_ORDEREXPIREDREPORT_ORDERINFOS_ORDERTIME] = orderTime;
//        Json::FastWriter writer;
//        string json = writer.write(msg.PackInfo());
//        string jdata = json.substr(0, json.length() - 1);
//        value[LSLCSCHEDULEINFOITEM_MSG_PARAM] = jdata;
        
        return value;
    }

	HttpOrderExpiredItem() {
        orderNo = "";
        orderTime = 0;
	}

	virtual ~HttpOrderExpiredItem() {

	}
    /**
     * 失效订单列表结构体
     * orderNo                   产品编码
     * orderTime                   产品名称
     */

    string orderNo;
    long long orderTime;

};

typedef list<HttpOrderExpiredItem> OrderExpiredList;

#endif /* HTTPORDEREXPIREDITEM_H_ */
