/*
 * LSLCMonthlyFeeInstructionItem.h
 *
 *  Created on: 2015-3-6
 *      Author: alex
 *      desc  : 买点送月费的文字说明
 */

#ifndef LSLCMONTHLY_FEE_INSTRUCTION_ITEM_H_
#define LSLCMONTHLY_FEE_INSTRUCTION_ITEM_H_

using namespace std;
#include "LSLCProductItem.h"

class LSLCMonthlyFeeInstructionItem {
public:
	void Parse(Json::Value root) {
		if( root.isObject() ) {
			if( root[MONTHLY_FEE_PREMIUM_TITLE].isString() ) {
				title = root[MONTHLY_FEE_PREMIUM_TITLE].asString();
			}

			if( root[MONTHLY_FEE_PREMIUM_SUBTITLE].isString() ) {
				subtitle = root[MONTHLY_FEE_PREMIUM_SUBTITLE].asString();
			}

			if( root[MONTHLY_FEE_PREMIUM_DESC].isString() ) {
				desc = root[MONTHLY_FEE_PREMIUM_DESC].asString();
			}
            
            if( root[MONTHLY_FEE_PREMIUM_MORE].isString() ) {
                more = root[MONTHLY_FEE_PREMIUM_MORE].asString();
            }
            
            if( root[MONTHLY_FEE_PREMIUM_PRODUCTS].isArray() ) {
                for(int i = 0; i < root[MONTHLY_FEE_PREMIUM_PRODUCTS].size(); i++ ) {
                    LSLCProductItem item;
                    item.Parse(root[MONTHLY_FEE_PREMIUM_PRODUCTS].get(i, Json::Value::null));
                    productList.push_back(item);
                }
            }
            
        }
	}

	LSLCMonthlyFeeInstructionItem() {
		title = "";
		subtitle = "";
        desc = "";
        more = "";
	}
	virtual ~LSLCMonthlyFeeInstructionItem() {

	}
    
    
    /**
     * 登录成功回调
     * @param title				主标题
     * @param subtitle          副标题
     * @param productList		产品列表
     * @param desc				描述
     * @param more              详细描述
     */
    
    string title;
	string subtitle;
	ProductItemList productList;
    string desc;
    string more;

};

#endif /* PROFILEITEM_H_ */
