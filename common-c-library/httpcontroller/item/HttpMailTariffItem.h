/*
 * HttpMailTariffItem.h
 *
 *  Created on: 2020-04-10
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPMAILTARIFFITEM_H_
#define HTTPMAILTARIFFITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "HttpLetterPriceItem.h"

class HttpMailTariffItem {
public:
	void Parse(const Json::Value& root) {
		if( root.isObject() ) {
            
            /* mailSendBase */
            if( root[LIVEROOM_MAIL_TATIFF_MAIL_SEND_BASE].isObject() ) {
                mailSendBase.Parse(root[LIVEROOM_MAIL_TATIFF_MAIL_SEND_BASE]);
            }
            
            /* mailReadBase */
            if( root[LIVEROOM_MAIL_TATIFF_MAIL_READ_BASE].isObject() ) {
                mailReadBase.Parse(root[LIVEROOM_MAIL_TATIFF_MAIL_READ_BASE]);
            }

            /* mailPhotoAttachBase */
            if( root[LIVEROOM_MAIL_TATIFF_MAIL_PHOTO_ATTACH_BASE].isObject() ) {
                mailPhotoAttachBase.Parse(root[LIVEROOM_MAIL_TATIFF_MAIL_PHOTO_ATTACH_BASE]);
            }
            
            /* mailPhotoBuyBase */
            if( root[LIVEROOM_MAIL_TATIFF_MAIL_PHOTO_BUY_BASE].isObject() ) {
                mailPhotoBuyBase.Parse(root[LIVEROOM_MAIL_TATIFF_MAIL_PHOTO_BUY_BASE]);
            }
            
            /* mailVideoBuyBase */
            if( root[LIVEROOM_MAIL_TATIFF_MAIL_VIDEO_BUY_BASE].isObject() ) {
                mailVideoBuyBase.Parse(root[LIVEROOM_MAIL_TATIFF_MAIL_VIDEO_BUY_BASE]);
            }
            
        }
	}

	HttpMailTariffItem() {
	}

	virtual ~HttpMailTariffItem() {

	}
    /**
     * 信件资费相关结构体
     * mailSendBase                   发送信件基础资费
     * mailReadBase                   读信基础资费
     * mailPhotoAttachBase       发送信件照片附件基础资费
     * mailPhotoBuyBase           私密照购买基础资费
     * mailVideoBuyBase           视频购买基础资费
     */

    HttpLetterPriceItem mailSendBase;
    HttpLetterPriceItem mailReadBase;
    HttpLetterPriceItem mailPhotoAttachBase;
    HttpLetterPriceItem mailPhotoBuyBase;
    HttpLetterPriceItem mailVideoBuyBase;

};

#endif /* HTTPMAILTARIFFITEM_H_ */
