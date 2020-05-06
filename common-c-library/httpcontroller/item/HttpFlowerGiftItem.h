/*
 * HttpFlowerGiftItem.h
 *
 *  Created on: 2019-8-27
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPFLOWERGIFTITEM_H_
#define HTTPFLOWERGIFTITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"

#define FLOWERGIFT_TYPEID_DELIMITED    ","                    // 分隔符
typedef list<string> CountryList;
class HttpFlowerGiftItem {
public:

	bool Parse(const Json::Value& root) {
        bool result = false;
		if( root.isObject() ) {
			/* typeId */
			if( root[LIVEROOM_GETSTOREGIFTLIST_GIFTLIST_TYPEID].isString() ) {
				typeId = root[LIVEROOM_GETSTOREGIFTLIST_GIFTLIST_TYPEID].asString();
			}
            
			/* giftId */
			if( root[LIVEROOM_GETSTOREGIFTLIST_GIFTLIST_GIFTID].isString() ) {
				giftId = root[LIVEROOM_GETSTOREGIFTLIST_GIFTLIST_GIFTID].asString();
			}
            
            /* giftName */
            if (root[LIVEROOM_GETSTOREGIFTLIST_GIFTLIST_GIFTNAME].isString()) {
                giftName = root[LIVEROOM_GETSTOREGIFTLIST_GIFTLIST_GIFTNAME].asString();
            }
            
            /* giftImg */
            if (root[LIVEROOM_GETSTOREGIFTLIST_GIFTLIST_GIFTIMG].isString()) {
                giftImg = root[LIVEROOM_GETSTOREGIFTLIST_GIFTLIST_GIFTIMG].asString();
            }
            
            /* priceShowType */
            if (root[LIVEROOM_GETSTOREGIFTLIST_GIFTLIST_PRICESHOWTYPE].isNumeric()) {
                priceShowType = GetLSPriceShowType(root[LIVEROOM_GETSTOREGIFTLIST_GIFTLIST_PRICESHOWTYPE].asInt());
            }
            
            /* giftWeekdayPrice */
            if (root[LIVEROOM_GETSTOREGIFTLIST_GIFTLIST_GIFTWEEKDAYPRICE].isNumeric()) {
                giftWeekdayPrice = root[LIVEROOM_GETSTOREGIFTLIST_GIFTLIST_GIFTWEEKDAYPRICE].asDouble();
            }
            
            /* giftDiscountPrice */
            if (root[LIVEROOM_GETSTOREGIFTLIST_GIFTLIST_GIFTDISCOUNTPRICE].isNumeric()) {
                giftDiscountPrice = root[LIVEROOM_GETSTOREGIFTLIST_GIFTLIST_GIFTDISCOUNTPRICE].asDouble();
            }
            
            /* giftPrice */
            if (root[LIVEROOM_GETSTOREGIFTLIST_GIFTLIST_GIFTPRICE].isNumeric()) {
                giftPrice = root[LIVEROOM_GETSTOREGIFTLIST_GIFTLIST_GIFTPRICE].asDouble();
            }
            
            /* giftDiscount */
            if (root[LIVEROOM_GETSTOREGIFTLIST_GIFTLIST_GIFTDISCOUNT].isNumeric()) {
                giftDiscount = root[LIVEROOM_GETSTOREGIFTLIST_GIFTLIST_GIFTDISCOUNT].asDouble();
            }
            
            /* isNew */
            if (root[LIVEROOM_GETSTOREGIFTLIST_GIFTLIST_ISNEW].isNumeric()) {
                isNew = root[LIVEROOM_GETSTOREGIFTLIST_GIFTLIST_ISNEW].asInt() == 0 ? false : true;
            }
            
            /* deliverableCountry */
            if ( root[LIVEROOM_GETGIFTDETAIL_DETAIL_DELIVERABLECOUNTRY].isString()) {
                string typeId = "";
                typeId = root[LIVEROOM_GETGIFTDETAIL_DETAIL_DELIVERABLECOUNTRY].asString();
                size_t pos = 0;
                do {
                    size_t cur = typeId.find(FLOWERGIFT_TYPEID_DELIMITED, pos);
                    if (cur != string::npos) {
                        string temp = typeId.substr(pos, cur - pos);
                        if (!temp.empty()) {
                            deliverableCountry.push_back(temp);
                        }
                        pos = cur + 1;
                    }
                    else {
                        string temp = typeId.substr(pos);
                        if (!temp.empty()) {
                            deliverableCountry.push_back(temp);
                        }
                        break;
                    }
                } while(true);
                
            }
            
            /* giftDescription */
            if( root[LIVEROOM_GETGIFTDETAIL_DETAIL_GIFTDESCRIPTION].isString() ) {
                giftDescription = root[LIVEROOM_GETGIFTDETAIL_DETAIL_GIFTDESCRIPTION].asString();
            }
            
            result = true;
        }
        return result;
    }

	HttpFlowerGiftItem() {
		typeId = "";
		giftId = "";
        giftName = "";
        giftImg = "";
        priceShowType = LSPRICESHOWTYPE_WEEKDAY;
        giftWeekdayPrice = 0.0;
        giftDiscountPrice = 0.0;
        giftPrice = 0.0;
        giftDiscount = 0.0;
        isNew = false;
        giftDescription = "";
	}

	virtual ~HttpFlowerGiftItem() {

	}
    
    /**
     * 鲜花礼品结构体
     * typeId	            分类ID
     * giftId               礼品ID
     * giftName             礼品名称
     * giftImg              礼品图片
     * priceShowType        显示何种价格（LSPRICESHOWTYPE_WEEKDAY：平日价，LSPRICESHOWTYPE_HOLIDAY：节日价，LSPRICESHOWTYPE_DISCOUNT：优惠价）
     * giftWeekdayPrice     平日价
     * giftDiscountPrice    优惠价
     * giftPrice            显示价格
     * giftDiscount         优惠折扣
     * isNew                是否NEW
     * deliverableCountry   配送国家
     * giftDescription      描述
     */
    string typeId;
	string giftId;
    string giftName;
    string giftImg;
    LSPriceShowType priceShowType;
    double giftWeekdayPrice;
    double giftDiscountPrice;
    double giftPrice;
    double giftDiscount;
    bool isNew;
    CountryList deliverableCountry;
    string giftDescription;
};

typedef list<HttpFlowerGiftItem> FlowerGiftList;

#endif /* HTTPFLOWERGIFTITEM_H_ */
