/*
 * LSLCEMF.h
 *
 *  Created on: 2015-3-5
 *      Author: Samson.Fan
 */

#ifndef LSLCEMF_H_
#define LSLCEMF_H_

#include <string>
#include <list>
using namespace std;

#include "../LSLiveChatRequestEMFDefine.h"
#include <json/json/json.h>
#include <common/CommonFunc.h>

// 私密照
class LSLCEMFPrivatePhotoItem {
public:
	LSLCEMFPrivatePhotoItem()
	{
		sendId = "";
		photoId = "";
		photoFee = false;
		photoDesc = "";
	}
	virtual ~LSLCEMFPrivatePhotoItem() {}

public:
	bool Parsing(const Json::Value& data)
	{
		bool result = false;
		if (data.isObject()) {
			if (data[EMF_INBOXMSG_SENDID].isString()) {
				sendId = data[EMF_INBOXMSG_SENDID].asString();
			}
			if (data[EMF_INBOXMSG_PHOTOID].isString()) {
				photoId = data[EMF_INBOXMSG_PHOTOID].asString();
			}
			if (data[EMF_INBOXMSG_PHOTOFEE].isIntegral()) {
				int iPhotoFee = data[EMF_INBOXMSG_PHOTOFEE].asInt();
				photoFee = (iPhotoFee != 0 ? true : false);
			}
			if (data[EMF_INBOXMSG_PHOTODESC].isString()) {
				photoDesc = data[EMF_INBOXMSG_PHOTODESC].asString();
			}

			if (!sendId.empty() && !photoId.empty()) {
				result = true;
			}
		}
		return result;
	}
public:
	string	sendId;		// 发送ID
	string	photoId;	// 照片ID
	bool	photoFee;	// 照片是否已扣费
	string	photoDesc;	// 照片描述
};

// 微视频
class LSLCEMFShortVideoItem {
public:
	LSLCEMFShortVideoItem()
	{
		sendId = "";
		videoId = "";
		videoFee = false;
		videoDesc = "";
	}
	virtual ~LSLCEMFShortVideoItem() {}

public:
	bool Parsing(const Json::Value& data)
	{
		bool result = false;
		if (data.isObject()) {
			if (data[EMF_INBOXMSG_SENDID].isString()) {
				sendId = data[EMF_INBOXMSG_SENDID].asString();
			}
			if (data[EMF_INBOXMSG_VIDEOID].isString()) {
				videoId = data[EMF_INBOXMSG_VIDEOID].asString();
			}
			if (data[EMF_INBOXMSG_VIDEOFEE].isIntegral()) {
				int iPhotoFee = data[EMF_INBOXMSG_VIDEOFEE].asInt();
				videoFee = (iPhotoFee != 0 ? true : false);
			}
			if (data[EMF_INBOXMSG_VIDEODESC].isString()) {
				videoDesc = data[EMF_INBOXMSG_VIDEODESC].asString();
			}

			if (!sendId.empty() && !videoId.empty()) {
				result = true;
			}
		}
		return result;
	}
public:
	string	sendId;		// 发送ID
	string	videoId;	// 微视频ID
	bool	videoFee;	// 微视频是否已扣费
	string	videoDesc;	// 微视频描述
};
// 私密照列表定义
typedef list<LSLCEMFPrivatePhotoItem> EMFPrivatePhotoList;
// 微视频列表定义
typedef list<LSLCEMFShortVideoItem> EMFShortVideoList;
// 邮件附件URL列表定义
typedef list<string> EMFPhotoUrlList;
// 邮件附件文件路径列表定义
typedef list<string> EMFFileNameList;
// 女士ID列表定义
typedef list<string> EMFWomanidList;

// 查询收件箱列表  EMF_INBOXLIST_PATH(/emf/inboxlist) item
class LSLCEMFInboxListItem
{
public:
	LSLCEMFInboxListItem()
	{
		id = "";
		attachnum = 0;
        shortVideo = 0;
		virtual_gifts = false;
		womanid = "";
		readflag = false;
		rflag = false;
		fflag = false;
		pflag = false;
		firstname = "";
		lastname = "";
		weight = "";
		height = "";
		country = "";
		province = "";
        online_status = 0;
        camStatus = 0;
		age = 0;
		sendTime = "";
		photoURL = "";
		intro = "";
		vgId = "";
	}
	virtual ~LSLCEMFInboxListItem() {}

public:
	bool Parsing(const Json::Value& data)
	{
		bool result = false;
		if (data.isObject()) {
			if (data[EMF_INBOXLIST_ID].isString()) {
				id = data[EMF_INBOXLIST_ID].asString();
			}
			if (data[EMF_INBOXLIST_ATTACHNUM].isString()) {
				string strAttachnum = data[EMF_INBOXLIST_ATTACHNUM].asString();
				attachnum = atoi(strAttachnum.c_str());
			}
            if (data[EMF_INBOXLIST_SHORTVIDEO].isInt()) {
                shortVideo = data[EMF_INBOXLIST_SHORTVIDEO].asInt();
            }
			if (data[EMF_INBOXLIST_VIRTUALGIFTS].isIntegral()) {
				virtual_gifts = data[EMF_INBOXLIST_VIRTUALGIFTS].asInt() == 1 ? true : false;
			}
			if (data[EMF_INBOXLIST_WOMANID].isString()) {
				womanid = data[EMF_INBOXLIST_WOMANID].asString();
			}
			if (data[EMF_INBOXLIST_READFLAG].isString()) {
				string strReadFlag = data[EMF_INBOXLIST_READFLAG].asString();
				readflag = atoi(strReadFlag.c_str()) == 1 ? true : false;
			}
			if (data[EMF_INBOXLIST_RFLAG].isString()) {
				string strRFlag = data[EMF_INBOXLIST_RFLAG].asString();
				rflag = atoi(strRFlag.c_str()) == 1 ? true : false;
			}
			if (data[EMF_INBOXLIST_FFLAG].isString()) {
				string strPFlag = data[EMF_INBOXLIST_FFLAG].asString();
				fflag = atoi(strPFlag.c_str()) == 1 ? true : false;
			}
			if (data[EMF_INBOXLIST_PFLAG].isString()) {
				string strPFlag = data[EMF_INBOXLIST_PFLAG].asString();
				pflag = atoi(strPFlag.c_str()) == 1 ? true : false;
			}
			if (data[EMF_INBOXLIST_FIRSTNAME].isString()) {
				firstname = data[EMF_INBOXLIST_FIRSTNAME].asString();
			}
			if (data[EMF_INBOXLIST_LASTNAME].isString()) {
				lastname = data[EMF_INBOXLIST_LASTNAME].asString();
			}
			if (data[EMF_INBOXLIST_WEIGHT].isString()) {
				weight = data[EMF_INBOXLIST_WEIGHT].asString();
			}
			if (data[EMF_INBOXLIST_HEIGHT].isString()) {
				height = data[EMF_INBOXLIST_HEIGHT].asString();
			}
			if (data[EMF_INBOXLIST_COUNTRY].isString()) {
				country = data[EMF_INBOXLIST_COUNTRY].asString();
			}
			if (data[EMF_INBOXLIST_PROVINCE].isString()) {
				province = data[EMF_INBOXLIST_PROVINCE].asString();
			}
            if (data[EMF_INBOXLIST_ONLINESTATUS].isInt()) {
                online_status = data[EMF_INBOXLIST_ONLINESTATUS].asInt();
            }
            if (data[EMF_INBOXLIST_CAMSTATUS].isInt()) {
                camStatus = data[EMF_INBOXLIST_CAMSTATUS].asInt();
            }
			if (data[EMF_INBOXLIST_AGE].isIntegral()) {
				age = data[EMF_INBOXLIST_AGE].asInt();
			}
			if (data[EMF_INBOXLIST_SENDTIME].isString()) {
				sendTime = data[EMF_INBOXLIST_SENDTIME].asString();
			}
			if (data[EMF_INBOXLIST_PHOTOURL].isString()) {
				photoURL = data[EMF_INBOXLIST_PHOTOURL].asString();
			}
			if (data[EMF_INBOXLIST_INTRO].isString()) {
				intro = data[EMF_INBOXLIST_INTRO].asString();
			}
			if (data[EMF_INBOXLIST_VGID].isString()) {
				vgId = data[EMF_INBOXLIST_VGID].asString();
			}

			if (!id.empty()) {
				result = true;
			}
		}
		return result;
	}

public:
	string	id;				// 邮件ID
	int		attachnum;		// 附件数量
    int     shortVideo;     // 微视频数量
	bool	virtual_gifts;	// 是否有虚拟礼物
	string 	womanid;		// 女士ID
	bool	readflag;		// 是否已读
	bool	rflag;			// 是否已回复
	bool	fflag;			// 是否转发
	bool	pflag;			// 是否已打印
	string 	firstname;		// 女士first name
	string	lastname;		// 女士last name
	string	weight;			// 体重
	string	height;			// 身高
	string	country;		// 国家
	string	province;		// 省份
    int     online_status;  // 在线状态（1:livechat在线， 0:不在线）
    int     camStatus;      // Cam是否可以（0:未打开 1:已打开）
	int		age;			// 年龄
	string	sendTime;		// 发送时间
	string	photoURL;		// 头像URL
	string	intro;			// 邮件简介
	string	vgId;			// 虚拟礼物ID
};
typedef list<LSLCEMFInboxListItem> EMFInboxList;


// 查询已收邮件详细 EMF_INBOXMSG_PATH(/emf/inboxmsg) item
class LSLCEMFInboxMsgItem
{
public:
	LSLCEMFInboxMsgItem()
	{
		id = "";
		womanid = "";
		firstname = "";
		lastname = "";
		weight = "";
		height = "";
		country = "";
		province = "";
        online_status = 0;
        camStatus = 0;
		age = 0;
		photoURL = "";
		body = "";
		notetoman = "";
		sendTime = "";
		vgId = "";
	}
	virtual ~LSLCEMFInboxMsgItem() {}

public:
	bool Parsing(const Json::Value& data)
	{
		bool result = false;
		if (data.isObject()) {
			if (data[EMF_INBOXMSG_ID].isString()) {
				id = data[EMF_INBOXMSG_ID].asString();
			}
			if (data[EMF_INBOXMSG_WOMANID].isString()) {
				womanid = data[EMF_INBOXMSG_WOMANID].asString();
			}
			if (data[EMF_INBOXMSG_FIRSTNAME].isString()) {
				firstname = data[EMF_INBOXMSG_FIRSTNAME].asString();
			}
			if (data[EMF_INBOXMSG_LASTNAME].isString()) {
				lastname = data[EMF_INBOXMSG_LASTNAME].asString();
			}
			if (data[EMF_INBOXMSG_WEIGHT].isString()) {
				weight = data[EMF_INBOXMSG_WEIGHT].asString();
			}
			if (data[EMF_INBOXMSG_HEIGHT].isString()) {
				height = data[EMF_INBOXMSG_HEIGHT].asString();
			}
			if (data[EMF_INBOXMSG_COUNTRY].isString()) {
				country = data[EMF_INBOXMSG_COUNTRY].asString();
			}
			if (data[EMF_INBOXMSG_PROVINCE].isString()) {
				province = data[EMF_INBOXMSG_PROVINCE].asString();
			}
			if (data[EMF_INBOXMSG_AGE].isIntegral()) {
				age = data[EMF_INBOXMSG_AGE].asInt();
			}
            if (data[EMF_INBOXMSG_ONLINESTATUS].isInt()) {
                online_status = data[EMF_INBOXMSG_ONLINESTATUS].asInt();
            }
            if (data[EMF_INBOXMSG_CAMSTATUS].isInt()) {
                camStatus = data[EMF_INBOXMSG_CAMSTATUS].asInt();
            }
			if (data[EMF_INBOXMSG_PHOTOURL].isString()) {
				photoURL = data[EMF_INBOXMSG_PHOTOURL].asString();
			}
			if (data[EMF_INBOXMSG_BODY].isString()) {
				body = data[EMF_INBOXMSG_BODY].asString();
			}
			if (data[EMF_INBOXMSG_NOTETOMAN].isString()) {
				notetoman = data[EMF_INBOXMSG_NOTETOMAN].asString();
			}
			if (data[EMF_INBOXMSG_SENDTIME].isString()) {
				sendTime = data[EMF_INBOXMSG_SENDTIME].asString();
			}
			if (data[EMF_INBOXMSG_VGID].isString()) {
				vgId = data[EMF_INBOXMSG_VGID].asString();
			}
			if (data[EMF_INBOXMSG_PHOTOSURL].isString()) {
				string strPhotosURL = data[EMF_INBOXMSG_PHOTOSURL].asString();

				size_t startPos = 0;
				size_t endPos = 0;
				while (true)
				{
					endPos = strPhotosURL.find(EMF_PHOTOSURL_DELIMITER, startPos);
					if (string::npos != endPos) {
						// 获取photoURL并添加至列表
						string strPhotoURL = strPhotosURL.substr(startPos, endPos - startPos);
						if (!strPhotoURL.empty()) {
							photosURL.push_back(strPhotoURL);
						}

						// 移到下一个photoURL起始
						startPos = endPos + strlen(EMF_PHOTOSURL_DELIMITER);
					}
					else {
						// 添加最后一个URL
						string lastPhotoURL = strPhotosURL.substr(startPos);
						if (!lastPhotoURL.empty()) {
							photosURL.push_back(lastPhotoURL);
						}
						break;
					}
				}
			}
			if (data[EMF_INBOXMSG_PRIVATEPHOTOS].isArray()) {
				int i = 0;
				for (i = 0; i < data[EMF_INBOXMSG_PRIVATEPHOTOS].size(); i++) {
					LSLCEMFPrivatePhotoItem item;
					if (item.Parsing(data[EMF_INBOXMSG_PRIVATEPHOTOS].get(i, Json::Value::null))) {
						privatePhotoList.push_back(item);
					}
				}
			}
			//微视频
			if (data[EMF_INBOXMSG_SHORTVIDEOS].isArray()) {
				int i = 0;
				for (i = 0; i < data[EMF_INBOXMSG_SHORTVIDEOS].size(); i++) {
					LSLCEMFShortVideoItem item;
					if (item.Parsing(data[EMF_INBOXMSG_SHORTVIDEOS].get(i, Json::Value::null))) {
						shortVideoList.push_back(item);
					}
				}
			}

			if (!id.empty()) {
				result = true;
			}
		}
		return result;
	}

public:
	string	id;				// 邮件ID
	string	womanid;		// 女士ID
	string	firstname;		// 女士first name
	string	lastname;		// 女士last name
	string	weight;			// 体重
	string	height;			// 身高
	string	country;		// 国家
	string	province;		// 省份
	int		age;			// 年龄
    int     online_status;  // 在线状态（1:livechat在线， 0:不在线）
    int     camStatus;      // Cam是否可以（0:未打开 1:已打开）
	string	photoURL;		// 头像URL
	string	body;			// 邮件内容
	string	notetoman;		// 翻译内容
	EMFPhotoUrlList	photosURL;	// 附件URL列表
	string	sendTime;		// 发送时间
	EMFPrivatePhotoList privatePhotoList;	// 私密照 private_photos
	EMFShortVideoList shortVideoList; //微视频列表
	string	vgId;			// 虚拟礼物ID
};

// 查询已发邮件详细 EMF_OUTBOXLIST_PATH(/emf/outboxlist) item
class LSLCEMFOutboxListItem
{
public:
	LSLCEMFOutboxListItem()
	{
		id = "";
		attachnum = 0;
		virtual_gifts = false;
		progress = 0;  // 可以参考 EMF_PROGRESS_TYPE 数组
		womanid = "";
		firstname = "";
		lastname = "";
		weight = "";
		height = "";
		country = "";
		province = "";
		age = 0;
        online_status = 0;
        camStatus = 0;
	}
	virtual ~LSLCEMFOutboxListItem() {}

public:
	bool Parsing(const Json::Value& data)
	{
		bool result = false;
		if (data.isObject()) {
			if (data[EMF_OUTBOXMSG_ID].isString()) {
				id = data[EMF_OUTBOXMSG_ID].asString();
			}
			if (data[EMF_OUTBOXLIST_ATTACHNUM].isString()) {
				string strAttachnum = data[EMF_OUTBOXLIST_ATTACHNUM].asString();
				attachnum = atoi(strAttachnum.c_str());
			}
			if (data[EMF_OUTBOXLIST_VIRTUALGIFTS].isIntegral()) {
				virtual_gifts = data[EMF_OUTBOXLIST_VIRTUALGIFTS].asInt() == 1 ? true : false;
			}
			if (data[EMF_OUTBOXLIST_PROGRESS].isString()) {
				string strProgress = data[EMF_OUTBOXLIST_PROGRESS].asString();
				if (strProgress == "0") {
					progress = 0;
				}
				else if (strProgress == "1" || strProgress == "5") {
					progress = 1;
				}
				else if (strProgress == "2" || strProgress == "3" || strProgress == "4") {
					progress = 2;
				}
				else {
					// _countof(EMF_PROGRESS_TYPE)+1：未定义类型（可参考 RequestJniEMF.java 的 ProgressType）
					progress = _countof(EMF_PROGRESS_TYPE)+1;
				}
			}
			if (data[EMF_OUTBOXLIST_WOMANID].isString()) {
				womanid = data[EMF_OUTBOXLIST_WOMANID].asString();
			}
			if (data[EMF_OUTBOXLIST_FIRSTNAME].isString()) {
				firstname = data[EMF_OUTBOXLIST_FIRSTNAME].asString();
			}
			if (data[EMF_OUTBOXLIST_LASTNAME].isString()) {
				lastname = data[EMF_OUTBOXLIST_LASTNAME].asString();
			}
			if (data[EMF_OUTBOXLIST_WEIGHT].isString()) {
				weight = data[EMF_OUTBOXLIST_WEIGHT].asString();
			}
			if (data[EMF_OUTBOXLIST_HEIGHT].isString()) {
				height = data[EMF_OUTBOXLIST_HEIGHT].asString();
			}
			if (data[EMF_OUTBOXLIST_COUNTRY].isString()) {
				country = data[EMF_OUTBOXLIST_COUNTRY].asString();
			}
			if (data[EMF_OUTBOXLIST_PROVINCE].isString()) {
				province = data[EMF_OUTBOXLIST_PROVINCE].asString();
			}
			if (data[EMF_OUTBOXLIST_AGE].isIntegral()) {
				age = data[EMF_OUTBOXLIST_AGE].asInt();
			}
            if (data[EMF_OUTBOXLIST_ONLINESTATUS].isInt()) {
                online_status = data[EMF_OUTBOXLIST_ONLINESTATUS].asInt();
            }
            if (data[EMF_OUTBOXLIST_CAMSTATUS].isInt()) {
                camStatus = data[EMF_OUTBOXLIST_CAMSTATUS].asInt();
            }
			if (data[EMF_OUTBOXLIST_SENDTIME].isString()) {
				sendTime = data[EMF_OUTBOXLIST_SENDTIME].asString();
			}
			if (data[EMF_OUTBOXLIST_PHOTOURL].isString()) {
				photoURL = data[EMF_OUTBOXLIST_PHOTOURL].asString();
			}
			if (data[EMF_OUTBOXLIST_INTRO].isString()) {
				intro = data[EMF_OUTBOXLIST_INTRO].asString();
			}

			if (!id.empty()) {
				result = true;
			}
		}
		return result;
	}

public:
	string	id;				// 邮件ID
	int		attachnum;		// 附件数量
	bool	virtual_gifts;	// 是否有虚拟礼物标志
	int		progress;		// 处理状态
	string	womanid;		// 女士ID
	string	firstname;		// 女士first name
	string	lastname;		// 女士last name
	string	weight;			// 体重
	string	height;			// 身高
	string	country;		// 国家
	string	province;		// 省份
	int		age;			// 年龄
    int     online_status;  // 在线状态（1:livechat在线， 0:不在线）
    int     camStatus;      // Cam是否可以（0:未打开 1:已打开）
	string	sendTime;		// 发送时间
	string	photoURL;		// 头像URL
	string	intro;			// 邮件简介
};
typedef list<LSLCEMFOutboxListItem> EMFOutboxList;

// 查询已发邮件详细 EMF_OUTBOXMSG_PATH(/emf/outboxmsg)
class LSLCEMFOutboxMsgItem
{
public:
	LSLCEMFOutboxMsgItem()
	{
		id = "";
		vgId = "";
		content = "";
		sendTime = "";
		womanid = "";
		photoURL = "";
		firstname = "";
		lastname = "";
		weight = "";
		height = "";
		country = "";
		province = "";
		age = 0;
        online_status = 0;
        camStatus = 0;
	}
	virtual ~LSLCEMFOutboxMsgItem() {}

public:
	bool Parsing(const Json::Value& data)
	{
		bool result = false;
		if (data.isObject()) {
			if (data[EMF_OUTBOXMSG_ID].isString()) {
				id = data[EMF_OUTBOXMSG_ID].asString();
			}
			if (data[EMF_OUTBOXMSG_VGID].isString()) {
				vgId = data[EMF_OUTBOXMSG_VGID].asString();
			}
			if (data[EMF_OUTBOXMSG_CONTENT].isString()) {
				content = data[EMF_OUTBOXMSG_CONTENT].asString();
			}
			if (data[EMF_OUTBOXMSG_SENDTIME].isString()) {
				sendTime = data[EMF_OUTBOXMSG_SENDTIME].asString();
			}
			if (data[EMF_OUTBOXMSG_PHOTOSURL].isString()) {
				string strPhotosURL = data[EMF_OUTBOXMSG_PHOTOSURL].asString();

				size_t startPos = 0;
				size_t endPos = 0;
				while (true)
				{
					endPos = strPhotosURL.find(EMF_PHOTOSURL_DELIMITER, startPos);
					if (string::npos != endPos) {
						// 获取photoURL并添加至列表
						string strPhotoURL = strPhotosURL.substr(startPos, endPos - startPos);
						if (!strPhotoURL.empty()) {
							photosURL.push_back(strPhotoURL);
						}

						// 移到下一个photoURL起始
						startPos = endPos + strlen(EMF_PHOTOSURL_DELIMITER);
					}
					else {
						// 添加最后一个URL
						string lastPhotoURL = strPhotosURL.substr(startPos);
						if (!lastPhotoURL.empty()) {
							photosURL.push_back(lastPhotoURL);
						}
						break;
					}
				}
			}
			if (data[EMF_OUTBOXMSG_WOMANID].isString()) {
				womanid = data[EMF_OUTBOXMSG_WOMANID].asString();
			}
			if (data[EMF_OUTBOXMSG_PHOTOURL].isString()) {
				photoURL = data[EMF_OUTBOXMSG_PHOTOURL].asString();
			}
			if (data[EMF_OUTBOXMSG_FIRSTNAME].isString()) {
				firstname = data[EMF_OUTBOXMSG_FIRSTNAME].asString();
			}
			if (data[EMF_OUTBOXMSG_LASTNAME].isString()) {
				lastname = data[EMF_OUTBOXMSG_LASTNAME].asString();
			}
			if (data[EMF_OUTBOXMSG_WEIGHT].isString()) {
				weight = data[EMF_OUTBOXMSG_WEIGHT].asString();
			}
			if (data[EMF_OUTBOXMSG_HEIGHT].isString()) {
				height = data[EMF_OUTBOXMSG_HEIGHT].asString();
			}
			if (data[EMF_OUTBOXMSG_COUNTRY].isString()) {
				country = data[EMF_OUTBOXMSG_COUNTRY].asString();
			}
			if (data[EMF_OUTBOXMSG_PROVINCE].isString()) {
				province = data[EMF_OUTBOXMSG_PROVINCE].asString();
			}
			if (data[EMF_OUTBOXMSG_AGE].isIntegral()) {
				age = data[EMF_OUTBOXMSG_AGE].asInt();
			}
            if (data[EMF_OUTBOXMSG_ONLINESTATUS].isInt()) {
                online_status = data[EMF_OUTBOXMSG_ONLINESTATUS].asInt();
            }
            if (data[EMF_OUTBOXMSG_CAMSTATUS].isInt()) {
                camStatus = data[EMF_OUTBOXMSG_CAMSTATUS].asInt();
            }
            if (data[EMF_OUTBOXMSG_PRIVATEPHOTOS].isArray()) {
				int i = 0;
				for (i = 0; i < data[EMF_OUTBOXMSG_PRIVATEPHOTOS].size(); i++) {
					LSLCEMFPrivatePhotoItem item;
					if (item.Parsing(data[EMF_OUTBOXMSG_PRIVATEPHOTOS].get(i, Json::Value::null))) {
						privatePhotoList.push_back(item);
					}
				}
			}

			if (!id.empty()) {
				result = true;
			}
		}
		return result;
	}

public:
	string	id;				// 邮件ID
	string	vgId;			// 虚拟礼物ID
	string	content;		// 邮件内容
	string	sendTime;		// 发送时间
	EMFPhotoUrlList photosURL;	// 附件URL列表
	string	womanid;		// 女士ID
	string	photoURL;		// 女士头像URL
	string	firstname;		// 女士first name
	string	lastname;		// 女士last name
	string	weight;			// 体重
	string	height;			// 身高
	string	country;		// 国家
	string	province;		// 省份
	int		age;			// 年龄
    int     online_status;  // 在线状态（1:livechat在线， 0:不在线）
    int     camStatus;      // Cam是否可以（0:未打开 1:已打开）
	EMFPrivatePhotoList	privatePhotoList;	// 私密照列表
};

// 查询收件箱某状态邮件数量 EMF_MSGTOTAL_PATH(/emf/msgtotal)
class LSLCEMFMsgTotalItem
{
public:
	LSLCEMFMsgTotalItem()
	{
		msgTotal = 0;
	}
	virtual ~LSLCEMFMsgTotalItem() {}

public:
	bool Parsing(const Json::Value& data)
	{
		bool result = false;
		if (data.isIntegral()) {
			msgTotal = data.asInt();

			result = true;
		}
		return result;
	}

public:
	int		msgTotal;		// 邮件数量
};

// 发送邮件 EMF_SENDMSG_PATH(/emf/sendmsg)
class LSLCEMFSendMsgItem
{
public:
	LSLCEMFSendMsgItem()
	{
		messageId = "";
		sendTime = 0;
	}
	virtual ~LSLCEMFSendMsgItem() {}

public:
	bool Parsing(const Json::Value& data)
	{
		bool result = false;
		if (data.isObject()) {
			if (data[EMF_SENDMSG_MESSAGEID].isIntegral()) {
				unsigned int uiMessageId = data[EMF_SENDMSG_MESSAGEID].asUInt();
				char cMessageId[64] = {0};
				snprintf(cMessageId, sizeof(cMessageId), "%u", uiMessageId);
				messageId = cMessageId;
			}
			else if (data[EMF_SENDMSG_MESSAGEID].isString()) {
				// 兼容MessageId为字符串类型情况（可参考../document/客户端协议特殊处理记录.doc）
				messageId = data[EMF_SENDMSG_MESSAGEID].asString();
			}
			if (data[EMF_SENDMSG_SENDTIME].isIntegral()) {
				sendTime = data[EMF_SENDMSG_SENDTIME].asUInt();
			}

			if (!messageId.empty()) {
				result = true;
			}
		}
		return result;
	}

public:
	string	messageId;			// 邮件ID
	unsigned int	sendTime;	// 发送时间
};

// 追加邮件附件 EMF_UPLOADIMAGE_PATH(/emf/uploadimage)
class LSLCEMFUploadImageItem
{
public:
	LSLCEMFUploadImageItem() {}
	virtual ~LSLCEMFUploadImageItem() {}

public:
	bool Parsing(const Json::Value& data)
	{
		// data 无返回参数
		return true;
	}
};

// 上传邮件附件EMF_UPLOADATTACH_PATH(/emf/uploadattach)
class LSLCEMFUploadAttachItem
{
public:
	LSLCEMFUploadAttachItem() {};
	virtual ~LSLCEMFUploadAttachItem() {};

public:
	bool Parsing(const Json::Value& data)
	{
		// data 无返回参数
		return true;
	}
};

// 删除邮件 EMF_DELETEMSG_PATH(/emf/deletemsg)
class LSLCEMFDeleteMsgItem
{
public:
	LSLCEMFDeleteMsgItem() {}
	virtual ~LSLCEMFDeleteMsgItem() {}

public:
	bool Parsing(const Json::Value& data)
	{
		// data 无返回参数
		return true;
	}
};

// 查询意向信收件箱列表 EMF_ADMIRERLIST_PATH(/emf/admirerlist)
class LSLCEMFAdmirerListItem
{
public:
	LSLCEMFAdmirerListItem()
	{
		id = "";
		idcode = "";
		readflag = 0;
		replyflag = 0;
		womanid = "";
		firstname = "";
		weight = "";
		height = "";
		country = "";
		province = "";
		mtab = "";
		age = 0;
        online_status = 0;
        camStatus = 0;
		photoURL = "";
		sendTime = "";
		attachnum = 0;
		template_type = 0;
	}
	virtual ~LSLCEMFAdmirerListItem() {}

public:
	bool Parsing(const Json::Value& data)
	{
		bool result = false;
		if (data.isObject()) {
			if (data[EMF_ADMIRERLIST_ID].isString()) {
				id = data[EMF_ADMIRERLIST_ID].asString();
			}
			if (data[EMF_ADMIRERLIST_IDCODE].isString()) {
				idcode = data[EMF_ADMIRERLIST_IDCODE].asString();
			}
			if (data[EMF_ADMIRERLIST_READFLAG].isIntegral()) {
				readflag = data[EMF_ADMIRERLIST_READFLAG].asInt()== 1 ? true : false;
			}
			if (data[EMF_ADMIRERLIST_REPLYFLAG].isString()) {
				string strReplyFlag = data[EMF_ADMIRERLIST_REPLYFLAG].asString();
				replyflag = atoi(strReplyFlag.c_str());
				// _countof(EMF_REPLYFLAG_TYPE)+1：DEFAULT（可参考 RequestJniEMF.java 的 ReplyFlagType）
				replyflag = replyflag < _countof(EMF_REPLYFLAG_TYPE) ? replyflag : _countof(EMF_REPLYFLAG_TYPE)+1;
			}
			if (data[EMF_ADMIRERLIST_WOMANID].isString()) {
				womanid = data[EMF_ADMIRERLIST_WOMANID].asString();
			}
			if (data[EMF_ADMIRERLIST_FIRSTNAME].isString()) {
				firstname = data[EMF_ADMIRERLIST_FIRSTNAME].asString();
			}
			if (data[EMF_ADMIRERLIST_WEIGHT].isString()) {
				weight = data[EMF_ADMIRERLIST_WEIGHT].asString();
			}
			if (data[EMF_ADMIRERLIST_HEIGHT].isString()) {
				height = data[EMF_ADMIRERLIST_HEIGHT].asString();
			}
			if (data[EMF_ADMIRERLIST_COUNTRY].isString()) {
				country = data[EMF_ADMIRERLIST_COUNTRY].asString();
			}
			if (data[EMF_ADMIRERLIST_PROVINCE].isString()) {
				province = data[EMF_ADMIRERLIST_PROVINCE].asString();
			}
			if (data[EMF_ADMIRERLIST_MTAB].isString()) {
				mtab = data[EMF_ADMIRERLIST_MTAB].asString();
			}
			if (data[EMF_ADMIRERLIST_AGE].isIntegral()) {
				age = data[EMF_ADMIRERLIST_AGE].asInt();
			}
            if (data[EMF_ADMIRERLIST_ONLINESTATUS].isInt()) {
                online_status = data[EMF_ADMIRERLIST_ONLINESTATUS].asInt();
            }
            if (data[EMF_ADMIRERLIST_CAMSTATUS].isInt()) {
                camStatus = data[EMF_ADMIRERLIST_CAMSTATUS].asInt();
            }
			if (data[EMF_ADMIRERLIST_PHOTOURL].isString()) {
				photoURL = data[EMF_ADMIRERLIST_PHOTOURL].asString();
			}
			if (data[EMF_ADMIRERLIST_SENDTIME].isString()) {
				sendTime = data[EMF_ADMIRERLIST_SENDTIME].asString();
			}
			if (data[EMF_ADMIRERLIST_ATTACHNUM].isIntegral()) {
				attachnum = data[EMF_ADMIRERLIST_ATTACHNUM].asInt();
			}
			if (data[EMF_ADMIRERLIST_TEMPLATE_TYPE].isString()) {
				string type = data[EMF_ADMIRERLIST_TEMPLATE_TYPE].asString();
				if( strcmp(type.c_str(), "A") == 0 ) {
					template_type = 0;
				} else if( strcmp(type.c_str(), "B") == 0 ){
					template_type = 1;
				}
			}
			if (!id.empty()) {
				result = true;
			}
		}
		return result;
	}

public:
	string	id;			// 意向信ID
	string	idcode;		// 意向信外部ID
	bool	readflag;	// 是否未读
	int		replyflag;	// 回复状态
	string	womanid;	// 女士ID
	string	firstname;	// 女士first name
	string	weight;		// 体重
	string	height;		// 身高
	string	country;	// 国家
	string	province;	// 省份
	string	mtab;		// 表的后缀
	int		age;		// 年龄
    int     online_status;  // 在线状态（1:livechat在线， 0:不在线）
    int     camStatus;      // Cam是否可以（0:未打开 1:已打开）
	string	photoURL;	// 女士头像URL
	string	sendTime;	// 发送时间
	int		attachnum;	// 附件数目
	int		template_type; // 主题类型（A:信件主题，B:虚拟礼物主题）
};
typedef list<LSLCEMFAdmirerListItem> EMFAdmirerList;

// 查询意向信详细信息 EMF_ADMIRERVIEWER_PATH(/emf/admirerviewer)
class LSLCEMFAdmirerViewerItem
{
public:
	LSLCEMFAdmirerViewerItem()
	{
		id = "";
		body = "";
		womanid = "";
		firstname = "";
		weight = "";
		height = "";
		country = "";
		province = "";
		mtab = "";
		age = 0;
        online_status = 0;
        camStatus = 0;
		photoURL = "";
		sendTime = "";
		template_type = "";
		vg_id = "";
	}
	virtual ~LSLCEMFAdmirerViewerItem() {}

public:
	bool Parsing(const Json::Value& data)
	{
		bool result = false;
		if (data.isObject()) {
			if (data[EMF_ADMIRERVIEWER_ID].isString()) {
				id = data[EMF_ADMIRERVIEWER_ID].asString();
			}
			if (data[EMF_ADMIRERVIEWER_BODY].isString()) {
				body = data[EMF_ADMIRERVIEWER_BODY].asString();
			}
			if (data[EMF_ADMIRERVIEWER_PHOTOSURL].isString()) {
				string strPhotosURL = data[EMF_ADMIRERVIEWER_PHOTOSURL].asString();

				size_t startPos = 0;
				size_t endPos = 0;
				while (true)
				{
					endPos = strPhotosURL.find(EMF_PHOTOSURL_DELIMITER, startPos);
					if (string::npos != endPos) {
						// 获取photoURL并添加至列表
						string strPhotoURL = strPhotosURL.substr(startPos, endPos - startPos);
						if (!strPhotoURL.empty()) {
							photosURL.push_back(strPhotoURL);
						}

						// 移到下一个photoURL起始
						startPos = endPos + strlen(EMF_PHOTOSURL_DELIMITER);
					}
					else {
						// 添加最后一个URL
						string lastPhotoURL = strPhotosURL.substr(startPos);
						if (!lastPhotoURL.empty()) {
							photosURL.push_back(lastPhotoURL);
						}
						break;
					}
				}
			}
			if (data[EMF_ADMIRERVIEWER_WOMANID].isString()) {
				womanid = data[EMF_ADMIRERVIEWER_WOMANID].asString();
			}
			if (data[EMF_ADMIRERVIEWER_FIRSTNAME].isString()) {
				firstname = data[EMF_ADMIRERVIEWER_FIRSTNAME].asString();
			}
			if (data[EMF_ADMIRERVIEWER_WEIGHT].isString()) {
				weight = data[EMF_ADMIRERVIEWER_WEIGHT].asString();
			}
			if (data[EMF_ADMIRERVIEWER_HEIGHT].isString()) {
				height = data[EMF_ADMIRERVIEWER_HEIGHT].asString();
			}
			if (data[EMF_ADMIRERVIEWER_COUNTRY].isString()) {
				country = data[EMF_ADMIRERVIEWER_COUNTRY].asString();
			}
			if (data[EMF_ADMIRERVIEWER_PROVINCE].isString()) {
				province = data[EMF_ADMIRERVIEWER_PROVINCE].asString();
			}
			if (data[EMF_ADMIRERVIEWER_MTAB].isString()) {
				mtab = data[EMF_ADMIRERVIEWER_MTAB].asString();
			}
			if (data[EMF_ADMIRERVIEWER_AGE].isIntegral()) {
				age = data[EMF_ADMIRERVIEWER_AGE].asInt();
			}
            if (data[EMF_ADMIRERVIEWER_ONLINESTATUS].isInt()) {
                online_status = data[EMF_ADMIRERVIEWER_ONLINESTATUS].asInt();
            }
            if (data[EMF_ADMIRERVIEWER_CAMSTATUS].isInt()) {
                camStatus = data[EMF_ADMIRERVIEWER_CAMSTATUS].asInt();
            }
            if (data[EMF_ADMIRERVIEWER_PHOTOURL].isString()) {
				photoURL = data[EMF_ADMIRERVIEWER_PHOTOURL].asString();
			}
			if (data[EMF_ADMIRERVIEWER_SENDTIME].isString()) {
				sendTime = data[EMF_ADMIRERVIEWER_SENDTIME].asString();
			}
			if (data[EMF_ADMIRERVIEWER_TEMPLATE_TYPE].isString()) {
				template_type = data[EMF_ADMIRERVIEWER_TEMPLATE_TYPE].asString();
			}
			if (data[EMF_ADMIRERVIEWER_VGID].isString()) {
				vg_id = data[EMF_ADMIRERVIEWER_VGID].asString();
			}

			if (!id.empty()) {
				result = true;
			}
		}
		return result;
	}

public:
	string	id;			// 意向信ID
	string	body;		// 内容
	EMFPhotoUrlList	photosURL;	// 附件URL列表
	string	womanid;	// 女士ID
	string	firstname;	// 女士first name
	string	weight;		// 体重
	string	height;		// 身高
	string	country;	// 国家
	string	province;	// 省份
	string	mtab;		// 表的后缀
	int		age;		// 年龄
    int     online_status;  // 在线状态（1:livechat在线， 0:不在线）
    int     camStatus;      // Cam是否可以（0:未打开 1:已打开）
	string	photoURL;	// 女士头像
	string	sendTime;	// 发送时间
	string  template_type; //主题类型（A:信件主题，B:虚拟礼物主题）
	string  vg_id;   //虚拟礼物Id
};

// 查询黑名单列表 EMF_BLOCKLIST_PATH(/emf/blocklist)
class LSLCEMFBlockListItem
{
public:
	LSLCEMFBlockListItem()
	{
		womanid = "";
		firstname = "";
		age = 0;
		weight = "";
		height = "";
		country = "";
		province = "";
		city = "";
		photoURL = "";
		blockreason = 0;
	}
	virtual ~LSLCEMFBlockListItem() {}

public:
	bool Parsing(const Json::Value& data)
	{
		bool result = false;
		if (data.isObject()) {
			if (data[EMF_BLOCKLIST_WOMANID].isString()) {
				womanid = data[EMF_BLOCKLIST_WOMANID].asString();
			}
			if (data[EMF_BLOCKLIST_FIRSTNAME].isString()) {
				firstname = data[EMF_BLOCKLIST_FIRSTNAME].asString();
			}
			if (data[EMF_BLOCKLIST_AGE].isIntegral()) {
				age = data[EMF_BLOCKLIST_AGE].asInt();
			}
			if (data[EMF_BLOCKLIST_WEIGHT].isString()) {
				weight = data[EMF_BLOCKLIST_WEIGHT].asString();
			}
			if (data[EMF_BLOCKLIST_HEIGHT].isString()) {
				height = data[EMF_BLOCKLIST_HEIGHT].asString();
			}
			if (data[EMF_BLOCKLIST_COUNTRY].isString()) {
				country = data[EMF_BLOCKLIST_COUNTRY].asString();
			}
			if (data[EMF_BLOCKLIST_PROVINCE].isString()) {
				province = data[EMF_BLOCKLIST_PROVINCE].asString();
			}
			if (data[EMF_BLOCKLIST_CITY].isString()) {
				city = data[EMF_BLOCKLIST_CITY].asString();
			}
			if (data[EMF_BLOCKLIST_PHOTOURL].isString()) {
				photoURL = data[EMF_BLOCKLIST_PHOTOURL].asString();
			}
			if (data[EMF_BLOCKLIST_BLOCKREASON].isIntegral()) {
				/*hunter 修改默认对应错误问题*/
				blockreason = data[EMF_BLOCKLIST_BLOCKREASON].asInt() - 1;
				// _countof(EMF_BLOCKREASON_TYPE)+1：未定义类型（可参考 RequestJniEMF.java 的 BlockReasonType）
				blockreason = blockreason < _countof(EMF_BLOCKREASON_TYPE) ? blockreason : _countof(EMF_BLOCKREASON_TYPE);
			}

			if (!womanid.empty()) {
				result = true;
			}
		}
		return result;
	}

public:
	string	womanid;	// 女士ID
	string	firstname;	// 女士first name
	int		age;		// 年龄
	string	weight;		// 体重
	string	height;		// 身高
	string	country;	// 国家
	string	province;	// 省份
	string	city;		// 城市
	string	photoURL;	// 头像URL
	int		blockreason;// 原因
};
typedef list<LSLCEMFBlockListItem> EMFBlockList;

// 添加黑名单 EMF_BLOCK_PATH(/emf/block)
class LSLCEMFBlockItem
{
public:
	LSLCEMFBlockItem() {}
	virtual ~LSLCEMFBlockItem() {}

public:
	bool Parsing(const Json::Value& data)
	{
		// 无返回参数
		return true;
	}
};

// 删除黑名单 EMF_UNBLOCK_PATH(/emf/unblock)
class LSLCEMFUnblockItem
{
public:
	LSLCEMFUnblockItem() {}
	virtual ~LSLCEMFUnblockItem() {}

public:
	bool Parsing(const Json::Value& data)
	{
		// 无返回参数
		return true;
	}
};

#endif /* EMF_H_ */
