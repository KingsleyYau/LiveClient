/*
 * HttpPostStampsPriceItem.h
 *
 *  Created on: 2020-04-10
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPPOSTSTAMPSPRICEITEM_H_
#define HTTPPOSTSTAMPSPRICEITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"

class HttpPostStampsPriceItem {
public:
	void Parse(const Json::Value& root) {
		if( root.isObject() ) {
            
            /* itemCode */
            if (root[LIVEROOM_GETPOSTSTAMPSPRICELIST_ITEMCODE].isString()) {
                itemCode = root[LIVEROOM_GETPOSTSTAMPSPRICELIST_ITEMCODE].asString();
            }
            
            /* itemName */
            if (root[LIVEROOM_GETPOSTSTAMPSPRICELIST_ITEMNAME].isString()) {
                itemName = root[LIVEROOM_GETPOSTSTAMPSPRICELIST_ITEMNAME].asString();
            }

            /* originalPrice */
            if (root[LIVEROOM_GETPOSTSTAMPSPRICELIST_ORIGINALPRICE].isString()) {
                originalPrice = root[LIVEROOM_GETPOSTSTAMPSPRICELIST_ORIGINALPRICE].asString();
            }
            
            /* discountPrice */
            if (root[LIVEROOM_GETPOSTSTAMPSPRICELIST_DISCOUNTPRICE].isString()) {
                discountPrice = root[LIVEROOM_GETPOSTSTAMPSPRICELIST_DISCOUNTPRICE].asString();
            }
            
            /* saveDesc */
            if (root[LIVEROOM_GETPOSTSTAMPSPRICELIST_SAVEDESC].isString()) {
                saveDesc = root[LIVEROOM_GETPOSTSTAMPSPRICELIST_SAVEDESC].asString();
            }
            
            /* postStampsNum */
            if (root[LIVEROOM_GETPOSTSTAMPSPRICELIST_POSTSTAMPSNUM].isString()) {
                postStampsNum = root[LIVEROOM_GETPOSTSTAMPSPRICELIST_POSTSTAMPSNUM].asString();
            }
            
            /* isDefault */
            if (root[LIVEROOM_GETPOSTSTAMPSPRICELIST_ISDEFAULT].isNumeric()) {
                isDefault = root[LIVEROOM_GETPOSTSTAMPSPRICELIST_ISDEFAULT].asInt() == 0 ? false : true;
            }
            
        }
	}

	HttpPostStampsPriceItem() {
        itemCode = "";
        itemName = "";
        originalPrice = "";
        discountPrice = "";
        saveDesc = "";
        postStampsNum = "";
        isDefault = false;
	}

	virtual ~HttpPostStampsPriceItem() {

	}
    /**
     * 邮票产品结构体
     * itemCode                   产品编码
     * itemName                   产品名称
     * originalPrice             产品原价
     * discountPrice           产品折后价格
     * saveDesc                 产品节省描述
     * postStampsNum     产品对应邮票数目
     * isDefault                 是否默认（0: 否 1:是）
     */

    string itemCode;
    string itemName;
    string originalPrice;
    string discountPrice;
    string saveDesc;
    string postStampsNum;
    bool isDefault;

};

typedef list<HttpPostStampsPriceItem> PostStampsPriceList;

#endif /* HTTPPOSTSTAMPSPRICEITEM_H_ */
