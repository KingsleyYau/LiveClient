/*
 * HttpAdWomanListAdvertItem.h
 *
 *  Created on: 2019-10-09
 *      Author: Alex
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef HTTPADWOMANLISTADVERTITEM_H_
#define HTTPADWOMANLISTADVERTITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../HttpLoginProtocol.h"
#include "../HttpRequestEnum.h"

class HttpAdWomanListAdvertItem {
public:

	bool Parse(const Json::Value& root) {
        bool result = false;
		if( root.isObject() ) {
            
			/* advertId */
			if( root[LIVEROOM_ADVERT_WOMANLISTADVERT_RETURN_ADVERTID].isString() ) {
				advertId = root[LIVEROOM_ADVERT_WOMANLISTADVERT_RETURN_ADVERTID].asString();
			}
            
            /* image */
            if (root[LIVEROOM_ADVERT_WOMANLISTADVERT_RETURN_IMAGE].isString()) {
                image = root[LIVEROOM_ADVERT_WOMANLISTADVERT_RETURN_IMAGE].asString();
            }
            
            /* width */
            if( root[LIVEROOM_ADVERT_WOMANLISTADVERT_RETURN_WIDTH].isNumeric() ) {
                width = root[LIVEROOM_ADVERT_WOMANLISTADVERT_RETURN_WIDTH].asInt();
            }
            
            /* height */
            if( root[LIVEROOM_ADVERT_WOMANLISTADVERT_RETURN_HEIGHT].isNumeric() ) {
                height = root[LIVEROOM_ADVERT_WOMANLISTADVERT_RETURN_HEIGHT].asInt();
            }
            
            /* adurl */
            if (root[LIVEROOM_ADVERT_WOMANLISTADVERT_RETURN_ADURL].isString()) {
                adurl = root[LIVEROOM_ADVERT_WOMANLISTADVERT_RETURN_ADURL].asString();
            }
            
            /* openType */
            if( root[LIVEROOM_ADVERT_WOMANLISTADVERT_RETURN_OPENTYPE].isNumeric() ) {
                openType = GetLSAdvertOpenTypWithInt(root[LIVEROOM_ADVERT_WOMANLISTADVERT_RETURN_OPENTYPE].asInt());
            }
            
            /* advertTitle */
            if (root[LIVEROOM_ADVERT_WOMANLISTADVERT_RETURN_ADVERTTITLE].isString()) {
                advertTitle = root[LIVEROOM_ADVERT_WOMANLISTADVERT_RETURN_ADVERTTITLE].asString();
            }
            
            result = true;
        }
        return result;
    }

	HttpAdWomanListAdvertItem() {
		advertId = "";
        image = "";
        width = 0;
        height = 0;
        adurl = "";
        openType = LSAD_OT_HIDE;
        advertTitle = "";
	}

	virtual ~HttpAdWomanListAdvertItem() {

	}
    
    /**
     * 女士列表广告结构体
     * advertId             广告ID
     * image                图片URL
     * width                广告图片的宽度
     * height               广告图片的高度
     * adurl                用户点击打开web页面
     * openType             打开adurl方法
     * advertTitle          广告标题
     */
	string advertId;
    string image;
    int width;
    int height;
    string adurl;
    LSAdvertOpenType openType;
    string advertTitle;

};

#endif /* HTTPADWOMANLISTADVERTITEM_H_ */
