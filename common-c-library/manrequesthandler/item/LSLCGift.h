/*
 * LSLCGift.h
 *
 *  Created on: 2015-3-2
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LSLCGift_H_
#define LSLCGift_H_

#include <string>
using namespace std;

#include <xml/tinyxml.h>

#include "../LSLiveChatRequestLiveChatDefine.h"

class LSLCGift {
public:
	void Parse(TiXmlNode* node) {
		const char *p = NULL;
		TiXmlElement* itemElement;
		TiXmlNode* vgidNode = node->FirstChild(LIVECHAT_VGID);
		if( vgidNode != NULL ) {
			itemElement = vgidNode->ToElement();
			if ( itemElement != NULL ) {
				p = itemElement->GetText();
				if( p != NULL ) {
					vgid = p;

				}
			}
		}

		TiXmlNode* titleNode = node->FirstChild(LIVECHAT_TITLE);
		if( titleNode != NULL ) {
			itemElement = titleNode->ToElement();
			if ( itemElement != NULL ) {
				p = itemElement->GetText();
				if( p != NULL ) {
					title = itemElement->GetText();

				}
			}
		}

		TiXmlNode* priceNode = node->FirstChild(LIVECHAT_PRICE);
		if( priceNode != NULL ) {
			itemElement = priceNode->ToElement();
			if ( itemElement != NULL ) {
				p = itemElement->GetText();
				if( p != NULL ) {
					price = itemElement->GetText();
				}
			}
		}
	}

	LSLCGift() {
		vgid = "";
		title = "";
		price = "";
	}

	virtual ~LSLCGift() {

	}

	/**
	 * 5.3.获取虚拟礼物列表回调
	 * @param vgid		id
	 * @param title		标题
	 * @param price		点数
	 */

	string vgid;
	string title;
	string price;
};

#endif /* LSLCGift_H_ */
