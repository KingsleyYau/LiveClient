/*
 * LSLCVideoShow.h
 *
 *  Created on: 2015-3-13
 *      Author: Samson.Fan
 * Description: 其它协议
 */

#ifndef LSLCOTHER_H_
#define LSLCOTHER_H_

#include <string>
#include <list>
using namespace std;

#include "../LSLiveChatRequestOtherDefine.h"
#include <json/json/json.h>
#include "../LSLiveChatRequestEnumDefine.h"

// 查询高级表情配置 OTHER_EMOTIONCONFIG_PATH(/member/emotionconfig)
class LSLCOtherEmotionConfigItem {
public:
	// type节点
	class LSLCTypeItem {
	public:
		LSLCTypeItem() {
			toflag = 0;
			typeId = "";
			typeName = "";
		}
		LSLCTypeItem(const LSLCTypeItem& item) {
			toflag = item.toflag;
			typeId = item.typeId;
			typeName = item.typeName;
		}
		virtual ~LSLCTypeItem() {}
	public:
		bool Parsing(const Json::Value& data) {
			bool result = false;
			if (data.isObject()) {
				if (data[OTHER_EMOTIONCONFIG_TOFLAG].isString()) {
					string strToFlag = data[OTHER_EMOTIONCONFIG_TOFLAG].asString();
					toflag = atoi(strToFlag.c_str());
				}

				if (data[OTHER_EMOTIONCONFIG_TYPEID].isString()) {
					typeId = data[OTHER_EMOTIONCONFIG_TYPEID].asString();
				}

				if (data[OTHER_EMOTIONCONFIG_TYPENAME].isString()) {
					typeName = data[OTHER_EMOTIONCONFIG_TYPENAME].asString();
				}

				if (!typeId.empty()) {
					result = true;
				}
			}
			return result;
		}
	public:
		int		toflag;		// 终端使用标志
		string	typeId;		// 分类ID
		string	typeName;	// 分类名称
	};
	typedef list<LSLCTypeItem> TypeList;

	// tag节点
	class LSLCTagItem {
	public:
		LSLCTagItem() {
			toflag = 0;
			typeId = "";
			tagId = "";
			tagName = "";
		}
		LSLCTagItem(const LSLCTagItem& item) {
			toflag = item.toflag;
			typeId = item.typeId;
			tagId = item.tagId;
			tagName = item.tagName;
		}
		virtual ~LSLCTagItem() {}
	public:
		bool Parsing(const Json::Value& data) {
			bool result = false;
			if (data.isObject()) {
				if (data[OTHER_EMOTIONCONFIG_TOFLAG].isString()) {
					string strToFlag = data[OTHER_EMOTIONCONFIG_TOFLAG].asString();
					toflag = atoi(strToFlag.c_str());
				}

				if (data[OTHER_EMOTIONCONFIG_TYPEID].isString()) {
					typeId = data[OTHER_EMOTIONCONFIG_TYPEID].asString();
				}

				if (data[OTHER_EMOTIONCONFIG_TAGSID].isString()) {
					tagId = data[OTHER_EMOTIONCONFIG_TAGSID].asString();
				}

				if (data[OTHER_EMOTIONCONFIG_TAGSNAME].isString()) {
					tagName = data[OTHER_EMOTIONCONFIG_TAGSNAME].asString();
				}

				if (!tagId.empty()) {
					result = true;
				}
			}
			return result;
		}
	public:
		int		toflag;		// 终端使用标志
		string	typeId;		// 分类ID
		string	tagId;		// tag ID
		string	tagName;	// tag名称
	};
	typedef list<LSLCTagItem> TagList;

	// 表情item
	class LSLCEmotionItem {
	public:
		LSLCEmotionItem() {
			fileName = "";
			price = 0;
			isNew = false;
			isSale = false;
			sortId = 0;
			typeId = "";
			tagId = "";
			title = "";
		}
		LSLCEmotionItem(const LSLCEmotionItem& item) {
			fileName = item.fileName;
			price = item.price;
			isNew = item.isNew;
			isSale = item.isSale;
			sortId = item.sortId;
			typeId = item.typeId;
			tagId = item.tagId;
			title = item.title;
		}
		virtual ~LSLCEmotionItem() {}
	public:
		bool Parsing(const Json::Value& data) {
			bool result = false;
			if (data.isObject()) {
				if (data[OTHER_EMOTIONCONFIG_FILENAME].isString()) {
					fileName = data[OTHER_EMOTIONCONFIG_FILENAME].asString();
				}
				if (data[OTHER_EMOTIONCONFIG_PRICE].isString()) {
					string strPrice = data[OTHER_EMOTIONCONFIG_PRICE].asString();
					price = atof(strPrice.c_str());
				}
				if (data[OTHER_EMOTIONCONFIG_ISNEW].isString()) {
					isNew = data[OTHER_EMOTIONCONFIG_ISNEW].asString() == "1" ? true : false;
				}
				if (data[OTHER_EMOTIONCONFIG_ISSALE].isString()) {
					isSale = data[OTHER_EMOTIONCONFIG_ISSALE].asString() == "1" ? true : false;
				}
				if (data[OTHER_EMOTIONCONFIG_SORTID].isString()) {
					string strSortId = data[OTHER_EMOTIONCONFIG_SORTID].asString();
					sortId = atoi(strSortId.c_str());
				}
				if (data[OTHER_EMOTIONCONFIG_TYPEID].isString()) {
					typeId = data[OTHER_EMOTIONCONFIG_TYPEID].asString();
				}
				if (data[OTHER_EMOTIONCONFIG_TAGSID].isString()) {
					tagId = data[OTHER_EMOTIONCONFIG_TAGSID].asString();
				}
				if (data[OTHER_EMOTIONCONFIG_TITLE].isString()) {
					title = data[OTHER_EMOTIONCONFIG_TITLE].asString();
				}

				if (!fileName.empty()) {
					result = true;
				}
			}
			return result;
		}
	public:
		string	fileName;	// 文件名
		double	price;		// 所需点数
		bool	isNew;		// 是否有new标志
		bool	isSale;		// 是否打折
		int		sortId;		// 排序字段（降序）
		string	typeId;		// 分类ID
		string	tagId;		// tag ID
		string	title;		// 表情标题
	};
	typedef list<LSLCEmotionItem> EmotionList;

public:
	LSLCOtherEmotionConfigItem()
	{
		version = 0;
		path = "";
	}
	LSLCOtherEmotionConfigItem(const LSLCOtherEmotionConfigItem& item) {
		version = item.version;
		path = item.path;
		typeList = item.typeList;
		tagList = item.tagList;
		manEmotionList = item.manEmotionList;
		ladyEmotionList = item.ladyEmotionList;
	}
	virtual ~LSLCOtherEmotionConfigItem() {}

public:
	bool Parsing(const Json::Value& data)
	{
		bool result = false;
		if (data.isObject()) {
			if (data[OTHER_EMOTIONCONFIG_VERSION].isIntegral()) {
				version = data[OTHER_EMOTIONCONFIG_VERSION].asInt();
			}
			if (data[OTHER_EMOTIONCONFIG_FSPATH].isString()) {
				path = data[OTHER_EMOTIONCONFIG_FSPATH].asString();
			}
			if (data[OTHER_EMOTIONCONFIG_TYPELIST].isArray()) {
				for(int i = 0; i < data[OTHER_EMOTIONCONFIG_TYPELIST].size(); i++) {
					LSLCTypeItem item;
					if (item.Parsing(data[OTHER_EMOTIONCONFIG_TYPELIST].get(i, Json::Value::null))) {
						typeList.push_back(item);
					}
				}
			}
			if (data[OTHER_EMOTIONCONFIG_TAGSLIST].isArray()) {
				for(int i = 0; i < data[OTHER_EMOTIONCONFIG_TAGSLIST].size(); i++) {
					LSLCTagItem item;
					if (item.Parsing(data[OTHER_EMOTIONCONFIG_TAGSLIST].get(i, Json::Value::null))) {
						tagList.push_back(item);
					}
				}
			}
			if (data[OTHER_EMOTIONCONFIG_FORMANLIST].isArray()) {
				for(int i = 0; i < data[OTHER_EMOTIONCONFIG_FORMANLIST].size(); i++) {
					LSLCEmotionItem item;
					if (item.Parsing(data[OTHER_EMOTIONCONFIG_FORMANLIST].get(i, Json::Value::null))) {
						manEmotionList.push_back(item);
					}
				}
			}
			if (data[OTHER_EMOTIONCONFIG_FORLADYLIST].isArray()) {
				for(int i = 0; i < data[OTHER_EMOTIONCONFIG_FORLADYLIST].size(); i++) {
					LSLCEmotionItem item;
					if (item.Parsing(data[OTHER_EMOTIONCONFIG_FORLADYLIST].get(i, Json::Value::null))) {
						ladyEmotionList.push_back(item);
					}
				}
			}

			if (!path.empty()) {
				result = true;
			}
		}

		return result;
	}

public:
	int			version;		// 高级表情版本号
	string		path;			// 路径
	TypeList	typeList;		// 分类列表
	TagList		tagList;		// tag列表
	EmotionList	manEmotionList;	// 男士表情列表
	EmotionList	ladyEmotionList;// 女士表情列表
};

// 男士会员统计 OTHER_GETCOUNT_PATH("/member/get_count")
class LSLCOtherGetCountItem {
public:
	LSLCOtherGetCountItem() {
		money = 0.0;
		coupon = 0;
		integral = 0;
		regstep = 0;
		allowAlbum = false;
		admirerUr = 0;
	}
	virtual ~LSLCOtherGetCountItem() {}
public:
	bool Parsing(const Json::Value& data) {
		bool result = false;
		if (data.isObject()) {
			if (data[OTHER_GETCOUNT_MONEY].isString()) {
				string strMoney = data[OTHER_GETCOUNT_MONEY].asString();
				money = atof(strMoney.c_str());
			}
			if (data[OTHER_GETCOUNT_COUPON].isIntegral()) {
				coupon = data[OTHER_GETCOUNT_COUPON].asInt();
			}
			if (data[OTHER_GETCOUNT_INTEGRAL].isIntegral()) {
				integral = data[OTHER_GETCOUNT_INTEGRAL].asInt();
			}
			if (data[OTHER_GETCOUNT_REGSTEP].isIntegral()) {
				regstep = data[OTHER_GETCOUNT_REGSTEP].asInt();
			}
			if (data[OTHER_GETCOUNT_ALLOWALBUM].isIntegral()) {
				allowAlbum = data[OTHER_GETCOUNT_ALLOWALBUM].asInt() == 1 ? true : false;
			}
			if (data[OTHER_GETCOUNT_ADMIRERUR].isString()) {
				string strAdmirerUr = data[OTHER_GETCOUNT_ADMIRERUR].asString();
				admirerUr = atoi(strAdmirerUr.c_str());
			}

			result = true;
		}
		return result;
	}
public:
	double	money;		// 余额
	int		coupon;		// 优惠券数量
	int		integral;	// 积分数量
	int		regstep;	// 注册步骤
	bool	allowAlbum;	// 相册权限
	int		admirerUr;	// 未读意向信数量
};

// 查询是否可对某女士使用积分 OTHER_INTEGRALCHECK_PATH("/member/integral_check")
class LSLCOtherIntegralCheckItem {
public:
	LSLCOtherIntegralCheckItem() {
		integral = 0;
	}
	virtual ~LSLCOtherIntegralCheckItem() {}
public:
	bool Parsing(const Json::Value& data) {
		bool result = false;
		if (data.isObject()) {
			if (data[OTHER_INTEGRALCHECK_INTEGRAL].isIntegral()) {
				integral = data[OTHER_INTEGRALCHECK_INTEGRAL].asInt();

				result = true;
			}
		}
		return result;
	}
public:
	int		integral;	// 积分数
};

// 检查客户端更新 OTHER_VERSIONCHECK_PATH("/member/versioncheck")
class LSLCOtherVersionCheckItem {
public:
	LSLCOtherVersionCheckItem() {
		versionCode = 0;
		versionName = "";
		versionDesc = "";
		url = "";
		checkTime = 0;
        isForceUpdate = false;
	}
	virtual ~LSLCOtherVersionCheckItem() {}
public:
	bool Parsing(const Json::Value& data) {
		bool result = false;
		if (data.isObject()) {
			if (data[OTHER_VERSIONCHECK_VERCODE].isIntegral()) {
				versionCode = data[OTHER_VERSIONCHECK_VERCODE].asInt();
			}
			if (data[OTHER_VERSIONCHECK_VERNAME].isString()) {
				versionName = data[OTHER_VERSIONCHECK_VERNAME].asString();
			}
			if (data[OTHER_VERSIONCHECK_VERDESC].isString()) {
				versionDesc = data[OTHER_VERSIONCHECK_VERDESC].asString();
			}
            if (data[OTHER_VERSIONCHECK_FORCEUPDATE].isNumeric()) {
                isForceUpdate = data[OTHER_VERSIONCHECK_FORCEUPDATE].asInt() == 0 ? false : true;
            }
			if (data[OTHER_VERSIONCHECK_URL].isString()) {
				url = data[OTHER_VERSIONCHECK_URL].asString();
			}
			if (data[OTHER_VERSIONCHECK_STOREURL].isString()) {
				storeUrl = data[OTHER_VERSIONCHECK_STOREURL].asString();
			}
			if (data[OTHER_VERSIONCHECK_PUBTIME].isString()) {
				pubTime = data[OTHER_VERSIONCHECK_PUBTIME].asString();
			}
			if (data[OTHER_VERSIONCHECK_CHECKTIME].isIntegral()) {
				checkTime = data[OTHER_VERSIONCHECK_CHECKTIME].asInt();
			}
			result = true;
		}
		return result;
	}
public:
	int		versionCode;	// 内部版本号
	string	versionName;	// 显示的版本号
	string	versionDesc;	// 版本描述
    bool    isForceUpdate;  // 是否强制升级（1：是，0：否）
	string	url;			// Android客户端下载的URL
	string	storeUrl;		// Store URL
	string	pubTime;		// 客户端发布时间
	long	checkTime;		// 检测更新时间（Unix timestamp）
};

// 同步配置 LSLCOTHER_SYNCONFIG_PATH("/other/syn_config")
class LSLCOtherSynConfigItem {
public:
	// proxy host列表
	typedef list<string> ProxyHostList;
	// 国家列表
	typedef list<string> CountryList;

	// 站点配置item
	class LSLCSiteItem {
	public:
		LSLCSiteItem() {
			host = "";
            domain = "";
			port = 0;
			minChat = 0;
			minEmf = 0;
            minCamshare = 0;
			camshareHost = "";
            camshareHeartCycle = 0;
            isAvaliable = true;
            gotoSiteType = OTHER_SITE_UNKNOW;
			followFaceBook = "";
            iOSVerCode = 0;
            iOSVerName = "";
            iOSForceUpdate = 0;
            iOSStoreUrl = "";
		}
		virtual ~LSLCSiteItem() {}
	public:
		bool Parsing(const Json::Value& data) {
			bool result = false;
			if (data.isObject()) {
				if (data[OTHER_SYNCONFIG_HOST].isString()) {
					host = data[OTHER_SYNCONFIG_HOST].asString();
				}
                if (data[OTHER_SYNCONFIG_HOST_DOMAIN].isString()) {
                    domain = data[OTHER_SYNCONFIG_HOST_DOMAIN].asString();
                }
				if (data[OTHER_SYNCONFIG_PROXYHOST].isString()) {
					string strProxyHostList = data[OTHER_SYNCONFIG_PROXYHOST].asString();

					size_t startPos = 0;
					size_t endPos = 0;
					while (true)
					{
						endPos = strProxyHostList.find(OTHER_PROXYHOST_DELIMITER, startPos);
						if (string::npos != endPos) {
							// 获取photoURL并添加至列表
							string strProxyHost = strProxyHostList.substr(startPos, endPos - startPos);
							if (!strProxyHost.empty()) {
								proxyHostList.push_back(strProxyHost);
							}

							// 移到下一个photoURL起始
							startPos = endPos + strlen(OTHER_PROXYHOST_DELIMITER);
						}
						else {
							// 添加最后一个URL
							string lastProxyHost = strProxyHostList.substr(startPos);
							if (!lastProxyHost.empty()) {
								proxyHostList.push_back(lastProxyHost);
							}
							break;
						}
					}
				}
				if (data[OTHER_SYNCONFIG_PORT].isIntegral()) {
					port = data[OTHER_SYNCONFIG_PORT].asInt();
				}
				if (data[OTHER_SYNCONFIG_MINCHAT].isString()) {
					string strMinChat = data[OTHER_SYNCONFIG_MINCHAT].asString();
					minChat = atof(strMinChat.c_str());
				}
                if (data[OTHER_SYNCONFIG_MINCAMSHARE].isString()) {
                    string strMinCamshare = data[OTHER_SYNCONFIG_MINCAMSHARE].asString();
                    minCamshare = atof(strMinCamshare.c_str());
                }
				if (data[OTHER_SYNCONFIG_MINEMF].isString()) {
					string strMinEmf = data[OTHER_SYNCONFIG_MINEMF].asString();
					minEmf = atof(strMinEmf.c_str());
				}
				if (data[OTHER_SYNCONFIG_COUNTRYLIST].isString()) {
					string strCountryList = data[OTHER_SYNCONFIG_COUNTRYLIST].asString();

					size_t startPos = 0;
					size_t endPos = 0;
					while (true)
					{
						endPos = strCountryList.find(OTHER_COUNTRYLIST_DELIMITER, startPos);
						if (string::npos != endPos) {
							// 获取photoURL并添加至列表
							string strCountry = strCountryList.substr(startPos, endPos - startPos);
							if (!strCountry.empty()) {
								countryList.push_back(strCountry);
							}

							// 移到下一个photoURL起始
							startPos = endPos + strlen(OTHER_COUNTRYLIST_DELIMITER);
						}
						else {
							// 添加最后一个URL
							string lastCountry = strCountryList.substr(startPos);
							if (!lastCountry.empty()) {
								countryList.push_back(lastCountry);
							}
							break;
						}
					}
				}

				if (data[OTHER_SYNCONFIG_CAMSHAREHOST].isString()) {
					camshareHost = data[OTHER_SYNCONFIG_CAMSHAREHOST].asString();
				}
                
                if (data[OTHER_SYNCONFIG_CAMSHAREHEARTBEATCYCLE].isIntegral()) {
                   camshareHeartCycle = data[OTHER_SYNCONFIG_CAMSHAREHEARTBEATCYCLE].asInt();
                }

                if (data[OTHER_SYNCONFIG_ISAVALIABLE].isIntegral()) {
                	isAvaliable = (data[OTHER_SYNCONFIG_ISAVALIABLE].asInt() == 1) ? true:false;
                }

				if (data[OTHER_SYNCONFIG_GOTOSITEID].isString()) {
					gotoSiteType = GetSiteTypeByServerSiteId(data[OTHER_SYNCONFIG_GOTOSITEID].asString());
				}
                
                if (data[OTHER_SYNCONFIG_FOLLOWFACEBOOK].isString()) {
                    followFaceBook = data[OTHER_SYNCONFIG_FOLLOWFACEBOOK].asString();
                }
                
                if (data[OTHER_SYNCONFIG_LIVEHOST].isString()) {
                    liveHost = data[OTHER_SYNCONFIG_LIVEHOST].asString();
                }
                

                // iOS
                if (data[OTHER_SYNCONFIG_IOSVERCODE].isIntegral()) {
                    iOSVerCode = data[OTHER_SYNCONFIG_IOSVERCODE].asInt();
                }
                if (data[OTHER_SYNCONFIG_IOSVERNAME].isString()) {
                    iOSVerName = data[OTHER_SYNCONFIG_IOSVERNAME].asString();
                }
                if (data[OTHER_SYNCONFIG_IOSFORCEUPDATE].isIntegral()) {
                    iOSForceUpdate = data[OTHER_SYNCONFIG_IOSFORCEUPDATE].asInt() == 1 ? true : false;
                }
                if (data[OTHER_SYNCONFIG_IOSSTOREURL].isString()) {
                    iOSStoreUrl = data[OTHER_SYNCONFIG_IOSSTOREURL].asString();
                }
                

				result = true;
			}
			return result;
		}
	public:
		string	host;		// LiveChat服务器host
        string  domain;     // LiveChat服务器domain
		ProxyHostList	proxyHostList;	// LiveChat proxy host
		int		port;		// LiveChat端口
		double	minChat;	// 使用LiveChat的最少点数
        double  minCamshare; // 使用Camshare的最少点数
		double	minEmf;		// 使用EMF的最少点数
		CountryList	countryList;	// 站点可查询女士的国家列表
		string  camshareHost;  //CamShare 服务器地址
        int camshareHeartCycle;  // 检查会话心跳超时时间步长
        bool isAvaliable;	//本站是否可用
        OTHER_SITE_TYPE gotoSiteType;	//本站不可用时要跳转的网站地址
        string  followFaceBook;         // 设置->follow us on facebook网址
        string  liveHost;               // 直播服务器地址
        int        iOSVerCode;        // iOS客户端内部版本号
        string    iOSVerName;        // iOS客户端版本名称
        bool    iOSForceUpdate;    // iOS是否强制升级
        string    iOSStoreUrl;    // appstore地址
	};

	// 公共配置item
	class LSLCPublicItem {
	public:
		LSLCPublicItem() {
			vgVer = 0;
			apkVerCode = 0;
			apkVerName = "";
			apkVerDesc = "";
			apkForceUpdate = false;
			facebook_enable = false;
			chatscene_enable = true;
			apkFileVerify = "";
			apkVerURL = "";
			chatVoiceHostUrl = "";
			addCreditsUrl = "";
			addCredits2Url = "";
			ipcountry = GetOtherCountryCode();
			gcmProjectId = "";
            iOSVerCode = 0;
            iOSVerName = "";
            iOSForceUpdate = 0;
            iOSStoreUrl = "";
            
		}
		virtual ~LSLCPublicItem() {}
	public:
		bool Parsing(const Json::Value& data) {
			bool result = false;
			if (data.isObject()) {
				if (data[OTHER_SYNCONFIG_VGVER].isIntegral()) {
					vgVer = data[OTHER_SYNCONFIG_VGVER].asInt();
				}
				if (data[OTHER_SYNCONFIG_APKVERCODE].isIntegral()) {
					apkVerCode = data[OTHER_SYNCONFIG_APKVERCODE].asInt();
				}
				if (data[OTHER_SYNCONFIG_APKVERNAME].isString()) {
					apkVerName = data[OTHER_SYNCONFIG_APKVERNAME].asString();
				}
				if (data[OTHER_SYNCONFIG_APKVERDESC].isString()) {
					apkVerDesc = data[OTHER_SYNCONFIG_APKVERDESC].asString();
				}
				if (data[OTHER_SYNCONFIG_APKFORCEUPDATE].isIntegral()) {
					apkForceUpdate = data[OTHER_SYNCONFIG_APKFORCEUPDATE].asInt() == 1 ? true : false;
				}
				if (data[OTHER_SYNCONFIG_FACEBOOK_ENABLE].isIntegral()) {
					facebook_enable = data[OTHER_SYNCONFIG_FACEBOOK_ENABLE].asInt() == 1 ? true : false;
				}
				if (data[OTHER_SYNCONFIG_CHATSCENE_ENABLE].isIntegral()) {
					chatscene_enable = data[OTHER_SYNCONFIG_CHATSCENE_ENABLE].asInt() == 1 ? true : false;
				}
				if (data[OTHER_SYNCONFIG_APKVERIFY].isString()) {
					apkFileVerify = data[OTHER_SYNCONFIG_APKVERIFY].asString();
				}
				if (data[OTHER_SYNCONFIG_APKVERURL].isString()) {
					apkVerURL = data[OTHER_SYNCONFIG_APKVERURL].asString();
				}
				if (data[OTHER_SYNCONFIG_CHATVOICEURL].isString()) {
					chatVoiceHostUrl = data[OTHER_SYNCONFIG_CHATVOICEURL].asString();
				}
				if (data[OTHER_SYNCONFIG_ADDCREDITSURL].isString()) {
					addCreditsUrl = data[OTHER_SYNCONFIG_ADDCREDITSURL].asString();
				}
				if (data[OTHER_SYNCONFIG_ADDCREDITS2URL].isString()) {
					addCredits2Url = data[OTHER_SYNCONFIG_ADDCREDITS2URL].asString();
				}
				if (data[OTHER_SYNCONFIG_STOREURL].isString()) {
					apkStoreURL = data[OTHER_SYNCONFIG_STOREURL].asString();
				}

				if( data[OTHER_SYNCONFIG_IPCOUNTRY].isString() ) {
					string strCountry = data[OTHER_SYNCONFIG_IPCOUNTRY].asString();
					ipcountry = GetCountryCode(strCountry);
				}

				if (data[OTHER_SYNCONFIG_GCMPROJECTID].isString()) {
					gcmProjectId = data[OTHER_SYNCONFIG_GCMPROJECTID].asString();
				}

                // iOS
                if (data[OTHER_SYNCONFIG_IOSVERCODE].isIntegral()) {
                    iOSVerCode = data[OTHER_SYNCONFIG_IOSVERCODE].asInt();
                }
                if (data[OTHER_SYNCONFIG_IOSVERNAME].isString()) {
                    iOSVerName = data[OTHER_SYNCONFIG_IOSVERNAME].asString();
                }
                if (data[OTHER_SYNCONFIG_IOSFORCEUPDATE].isIntegral()) {
                    iOSForceUpdate = data[OTHER_SYNCONFIG_IOSFORCEUPDATE].asInt() == 1 ? true : false;
                }
                if (data[OTHER_SYNCONFIG_IOSSTOREURL].isString()) {
                    iOSStoreUrl = data[OTHER_SYNCONFIG_IOSSTOREURL].asString();
                }
                
                result = true;
			}
			return result;
		}
	public:
		int		vgVer;			// 虚拟礼物版本号
		int		apkVerCode;		// Android客户端内部版本号
		string	apkVerName;		// Android客户端版本名称
		string  apkVerDesc;     // Android版本升级描述
		bool	apkForceUpdate;	// 是否强制升级
		bool    facebook_enable; //是否开通facebook登录
		bool    chatscene_enable; //聊天主题开关
		string	apkFileVerify;	// 安装文件检验码
		string	apkVerURL;		// 安装包下载URL
		string	apkStoreURL;	// Store URL
		string	chatVoiceHostUrl;	// LiveChat语音下载/上传
		string	addCreditsUrl;	// 选择点数充值页面URL
		string	addCredits2Url;	// 指定点数充值页面URL
		int  ipcountry; //当前IP对应的国家代码
		string gcmProjectId; //gcm 项目ID
        
        int        iOSVerCode;        // iOS客户端内部版本号
        string    iOSVerName;        // iOS客户端版本名称
        bool    iOSForceUpdate;    // iOS是否强制升级
        string    iOSStoreUrl;    // appstore地址
	};

public:
	LSLCOtherSynConfigItem() {

	}
	virtual ~LSLCOtherSynConfigItem() {}
public:
	bool Parsing(const Json::Value& data) {
		bool result = false;
		if (data.isObject()) {
			result = cl.Parsing(data[OTHER_SYNCONFIG_CL]);
			result = result && ida.Parsing(data[OTHER_SYNCONFIG_IDA]);
			result = result && ch.Parsing(data[OTHER_SYNCONFIG_CD]);
			result = result && la.Parsing(data[OTHER_SYNCONFIG_LA]);
			result = result && ad.Parsing(data[OTHER_SYNCONFIG_AD]);
			result = result && pub.Parsing(data[OTHER_SYNCONFIG_PUBLICCONFIG]);
		}
		return result;
	}
public:
	LSLCSiteItem	cl;		// CL站点
	LSLCSiteItem	ida;	// IDA站点
	LSLCSiteItem	ch;		// CH站点
	LSLCSiteItem	la;		// LA站点
	LSLCSiteItem	ad;		// AD站点
	LSLCPublicItem	pub;	// 公共配置
};

// 查询站点当前在线人数 OTHER_ONLINECOUNT_PATH("/member/onlinecount")
class LSLCOtherOnlineCountItem {
public:
	LSLCOtherOnlineCountItem() {
		siteId = OTHER_SITE_UNKNOW;
		onlineCount = 0;
	}
	virtual ~LSLCOtherOnlineCountItem() {}
public:
	bool Parsing(const Json::Value& data) {
		bool result = false;
		if (data.isObject()) {
			if (data[OTHER_ONLINECOUNT_SITEID].isString()) {
				string strSiteId = data[OTHER_ONLINECOUNT_SITEID].asString();
//				if (strSiteId.compare(OTHER_SYNCONFIG_CL) == 0) {
//					siteId = OTHER_SITE_CL;
//				}
//				else if (strSiteId.compare(OTHER_SYNCONFIG_IDA) == 0) {
//					siteId = OTHER_SITE_IDA;
//				}
//				else if (strSiteId.compare(OTHER_SYNCONFIG_CD) == 0) {
//					siteId = OTHER_SITE_CD;
//				}
//				else if (strSiteId.compare(OTHER_SYNCONFIG_LA) == 0) {
//					siteId = OTHER_SITE_LA;
//				}
//				else if (strSiteId.compare(OTHER_SYNCONFIG_AD) == 0) {
//					siteId = OTHER_SITE_AD;
//				}
				siteId = GetSiteTypeByServerSiteId(strSiteId);
			}
			if (data[OTHER_ONLINECOUNT_ONLINECOUNT].isIntegral()) {
				onlineCount = data[OTHER_ONLINECOUNT_ONLINECOUNT].asInt();
			}

			if (OTHER_SITE_UNKNOW != siteId) {
				result = true;
			}
		}
		return result;
	}
public:
	OTHER_SITE_TYPE	siteId;			// 站点ID
	int		onlineCount;	// 在线人数
};
typedef list<LSLCOtherOnlineCountItem> OtherOnlineCountList;

#endif /* LSLCOTHER_H_ */
