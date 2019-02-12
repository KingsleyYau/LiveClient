/*
 * LSLCAdvert.h
 *
 *  Created on: 2015-04-22
 *      Author: Samson.Fan
 */

#ifndef ADVERT_H_
#define ADVERT_H_

#include <string>
#include <list>
using namespace std;

#include <json/json/json.h>

#include <common/CommonFunc.h>

#include "../LSLiveChatRequestAdvertDefine.h"

// 主界面广告
class LSLCAdMainAdvertItem {
public:
	LSLCAdMainAdvertItem()
	{
		advertId = "";
		image = "";
		width = 0;
		height = 0;
		adurl = "";
		openType = AD_OT_HIDE;
		isShow = false;
		valid = 0;
	}
	virtual ~LSLCAdMainAdvertItem() {}

public:
	bool Parsing(const Json::Value& data)
	{
		if (data.isObject()) {
			if (data[ADVERT_ADVERTID].isString()) {
				advertId = data[ADVERT_ADVERTID].asString();
			}
			if (data[ADVERT_IMAGE].isString()) {
				image = data[ADVERT_IMAGE].asString();
			}
			if (data[ADVERT_WIDTH].isIntegral()) {
				width = data[ADVERT_WIDTH].asInt();
			}
			if (data[ADVERT_HEIGHT].isIntegral()) {
				height = data[ADVERT_HEIGHT].asInt();
			}
			if (data[ADVERT_ADURL].isString()) {
				adurl = data[ADVERT_ADURL].asString();
			}
			if (data[ADVERT_OPENTYPE].isIntegral()) {
				openType = GetAdvertOpenTypWithInt(data[ADVERT_OPENTYPE].asInt());
			}
			if (data[ADVERT_ISSHOW].isIntegral()) {
				isShow = data[ADVERT_ISSHOW].asInt() == 1 ? true : false;
			}
			if (data[ADVERT_VALID].isIntegral()) {
				valid = data[ADVERT_VALID].asInt();
			}
		}

		return true;
	}
public:
	string	advertId;		// 广告ID
	string	image;			// 图片URL
	int		width;			// 图片宽度
	int 	height;			// 图片高度
	string	adurl;			// 点击打开的URL
	AdvertOpenType openType;	// URL打开方式
	bool	isShow;			// 是否显示
	long	valid;			// 有效时间
};

// 女士列表广告
class LSLCAdWomanListAdvertItem {
public:
	LSLCAdWomanListAdvertItem()
	{
		advertId = "";
		image = "";
		width = 0;
		height = 0;
		adurl = "";
		openType = AD_OT_HIDE;
        advertTitle = "";
	}
	virtual ~LSLCAdWomanListAdvertItem() {}

public:
	bool Parsing(const Json::Value& data)
	{
		if (data.isObject()) {
			if (data[ADVERT_ADVERTID].isString()) {
				advertId = data[ADVERT_ADVERTID].asString();
			}
			if (data[ADVERT_IMAGE].isString()) {
				image = data[ADVERT_IMAGE].asString();
			}
			if (data[ADVERT_WIDTH].isIntegral()) {
				width = data[ADVERT_WIDTH].asInt();
			}
			if (data[ADVERT_HEIGHT].isIntegral()) {
				height = data[ADVERT_HEIGHT].asInt();
			}
			if (data[ADVERT_ADURL].isString()) {
				adurl = data[ADVERT_ADURL].asString();
			}
			if (data[ADVERT_OPENTYPE].isIntegral()) {
				openType = GetAdvertOpenTypWithInt(data[ADVERT_OPENTYPE].asInt());
			}
            if (data[ADVERT_ADVERTTITLE].isString()) {
                advertTitle = data[ADVERT_ADVERTTITLE].asString();
            }
            
		}

		return true;
	}
public:
	string	advertId;		// 广告ID
	string	image;			// 图片URL
	int		width;			// 图片宽度
	int 	height;			// 图片高度
	string	adurl;			// 点击打开的URL
	AdvertOpenType openType;	// URL打开方式
    string advertTitle;         // 广告
};

// Push广告
class LSLCAdPushAdvertItem {
public:
	LSLCAdPushAdvertItem()
	{
		pushId = "";
		message = "";
		adurl = "";
		openType = AD_OT_HIDE;
	}
	virtual ~LSLCAdPushAdvertItem() {}

public:
	bool Parsing(const Json::Value& data)
	{
		bool result = false;
		if (data.isObject()) {
			if (data[ADVERT_PUSHID].isString()) {
				pushId = data[ADVERT_PUSHID].asString();
			}
			if (data[ADVERT_MESSAGE].isString()) {
				message = data[ADVERT_MESSAGE].asString();
			}
			if (data[ADVERT_ADURL].isString()) {
				adurl = data[ADVERT_ADURL].asString();
			}
			if (data[ADVERT_OPENTYPE].isIntegral()) {
				openType = GetAdvertOpenTypWithInt(data[ADVERT_OPENTYPE].asInt());
			}

			if (!pushId.empty()) {
				result = true;
			}
		}

		return result;
	}
public:
	string	pushId;		// push ID
	string	message;	// push消息显示内容
	string	adurl;			// 点击打开的URL
	AdvertOpenType openType;	// URL打开方式
};
typedef list<LSLCAdPushAdvertItem> AdPushAdvertList;

// Html5广告
class LSLCAdHtml5AdvertItem {
public:
    LSLCAdHtml5AdvertItem()
    {
        advertId = "";
        htmlCode = "";
        advertTitle = "";
        height = 0;
    }
    virtual ~LSLCAdHtml5AdvertItem() {}
    
public:
    bool Parsing(const Json::Value& data)
    {
        bool result = false;
        if (data.isObject()) {
            if (data[ADVERT_ADVERTID].isString()) {
                advertId = data[ADVERT_ADVERTID].asString();
            }
            if (data[ADVERT_HTMLCODE].isString()) {
                htmlCode = data[ADVERT_HTMLCODE].asString();
            }
            if (data[ADVERT_ADVERTTITLE].isString()) {
                advertTitle = data[ADVERT_ADVERTTITLE].asString();
            }
            if (data[ADVERT_HEIGHT].isIntegral()) {
                height = data[ADVERT_HEIGHT].asInt();
            }

            result = true;
        }
        
        return result;
    }
public:
    string    advertId;         // 广告ID（可无）
    string    htmlCode;         // 广告标题
    string    advertTitle;      // html页面代码（可无，仅当adverId不为空时有效）
    int       height;           // 广告高度（可无，仅当adverId不为空时有效）
};

#endif /* LSLCADVERT_H_ */
