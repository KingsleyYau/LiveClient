/*
 * author: Samson.Fan
 *   date: 2015-03-19
 *   file: ILSLiveChatClient.h
 *   desc: LiveChat客户端接口类
 */

#pragma once

#include <string>
#include <list>
#include <vector>
#include "ILSLiveChatClientEnumDef.h"
#include "livechatItem/LSLCScheduleInfoItem.h"

using namespace std;

typedef list<string> UserIdList;	// 用户 id list
// 用户在线状态item
typedef struct _tagUserStatusItem
{
	USER_STATUS_TYPE	statusType;	// 用户在线状态
	string				userId;		// 用户Id
	
	_tagUserStatusItem()  {
		Reset();
	}
	_tagUserStatusItem(const _tagUserStatusItem& item) {
		statusType = item.statusType;
		userId = item.userId;
	}
	void Reset() {
		statusType = USTATUS_OFFLINE_OR_HIDDEN;
		userId = "";
	}
} UserStatusItem;
typedef list<UserStatusItem> UserStatusList;

// 邀请/在聊user列表item
typedef struct _tagUserInfoItem {
	string		userId;			// 用户ID
	string		userName;		// 用户名
	string		server;			// 服务器名
	string		imgUrl;			// 头像URL
    string      avatarImg;      // 头像Url
	USER_SEX_TYPE	sexType;	// 性别
	int			age;			// 年龄
	string		weight;			// 体重
	string		height;			// 身高
	string		country;		// 国家
	string		province;		// 省份
	bool		videoChat;		// 是否能视频聊天
	int			videoCount;		// 视频数量
	MARRY_TYPE	marryType;		// 婚姻状况
	CHILDREN_TYPE childrenType;	// 子女状况
	USER_STATUS_TYPE	status;	// 用户在线状态
	USER_TYPE	userType;		// 用户类型
	int			orderValue;		// 排序分值
	TDEVICE_TYPE	deviceType;		// 设备类型
	CLIENT_TYPE	clientType;		// 客户端类型
	string		clientVersion;	// 客户端版本号
	// 以下仅女士端获取自己信息才有
	bool		needTrans;		// 是否需要翻译
	string		transUserId;	// 翻译ID
	string		transUserName;	// 翻译名称
	bool		transBind;		// 是否绑定翻译
	USER_STATUS_TYPE	transStatus;	// 翻译在线状态
    
    // Add by Max 2018/08/16
    int    deviceTypeOriginal;        // 设备类型(原始int)

	_tagUserInfoItem() {
		userId = "";
		userName = "";
		server = "";
		imgUrl = "";
        avatarImg = "";
        
		sexType = USER_SEX_UNKNOW;
		age = 0;
		weight = "";
		height = "";
		country = "";
		province = "";
		videoChat = false;
		videoCount = 0;
		marryType = MT_UNKNOW;
		childrenType = CT_UNKNOW;
		status = USTATUS_OFFLINE_OR_HIDDEN;
		userType = UT_MAN;
		orderValue = 0;
		deviceType = DEVICE_TYPE_UNKNOW;
		clientType = CLIENT_UNKNOW;
		clientVersion = "";
		// --- 以下仅女士端获取自己信息才有 ---
		needTrans = false;
		transUserId = "";
		transUserName = "";
		transBind = false;
		transStatus = USTATUS_OFFLINE_OR_HIDDEN;
        
        // Add by Max 2018/08/16
        deviceTypeOriginal = LSUNKNOW_DEVICE_TYPE_ORIGINAL;
	}
	_tagUserInfoItem(const _tagUserInfoItem& item) {
		userId = item.userId;
		userName = item.userName;
		server = item.server;
		imgUrl = item.imgUrl;
        avatarImg = item.avatarImg;
		sexType = item.sexType;
		age = item.age;
		weight = item.weight;
		height = item.height;
		country = item.country;
		province = item.province;
		videoChat = item.videoChat;
		videoCount = item.videoCount;
		marryType = item.marryType;
		childrenType = item.childrenType;
		status = item.status;
		userType = item.userType;
		orderValue = item.orderValue;
		deviceType = item.deviceType;
		clientType = item.clientType;
		clientVersion = item.clientVersion;
		// --- 以下仅女士端获取自己信息才有 ---
		needTrans = item.needTrans;
		transUserId = item.transUserId;
		transUserName = item.transUserName;
		transBind = item.transBind;
		transStatus = item.transStatus;
        
        // Add by Max 2018/08/16
        deviceTypeOriginal = LSUNKNOW_DEVICE_TYPE_ORIGINAL;
	}
} UserInfoItem, TalkUserListItem;
// user列表
typedef list<UserInfoItem> UserInfoList;
// 邀请/在聊user列表
typedef list<TalkUserListItem> TalkUserList;

// 会话信息Item（CMD 87/55）
typedef struct _tagSessionInfoItem {
	string	targetId;	// 聊天对象ID
	string	invitedId;	// 邀请ID
	bool	charget;	// 是否已付费
	int		chatTime;	// 聊天时长
	bool    freeChat;   //是否正在使用试聊券
	bool    video;      //是否存在视频
	int     videoType;  //视频类型
	int     videoTime;  //视频有效期
	bool    freeTarget; //是否试聊券已经绑定目标
	bool    forbit;     //是否禁止
	int     inviteDtime;//最后发送时间
	bool    camInvited; //是否CamShare会话
	int     serviceType;//服务类型
	_tagSessionInfoItem() {
		targetId = "";
		invitedId = "";
		charget = false;
		chatTime = 0;
		freeChat = false;
		video = false;
		videoType = 0;
		videoTime = 0;
		freeTarget = false;
		forbit = false;
		inviteDtime = 0;
		camInvited = false;
		serviceType = 0;
	}
	_tagSessionInfoItem(const _tagSessionInfoItem& item) {
		targetId = item.targetId;
		invitedId = item.invitedId;
		charget = item.charget;
		chatTime = item.chatTime;
		freeChat = item.freeChat;
		video = item.video;
		videoType = item.videoType;
		videoTime = item.videoTime;
		freeTarget = item.freeTarget;
		forbit = item.forbit;
		inviteDtime = item.inviteDtime;
		camInvited = item.camInvited;
		serviceType = item.serviceType;
	}
} SessionInfoItem;


typedef struct _tagTalkSessionListItem {
	string                      targetId;	// 聊天对象ID
	string                      invitedId;	// 邀请ID
	bool                        charget;	// 是否已付费
	int                         chatTime;	// 聊天时长
	TalkSessionServiceType      serviceType;//服务类型（0：livechat 1： camshare）
    
	_tagTalkSessionListItem() {
		targetId = "";
		invitedId = "";
		charget = false;
		chatTime = 0;
		serviceType = TalkSessionServiceType_Unknow;
	}
    
	_tagTalkSessionListItem(const _tagTalkSessionListItem& item) {
		targetId = item.targetId;
		invitedId = item.invitedId;
		charget = item.charget;
		chatTime = item.chatTime;
		serviceType = item.serviceType;
	}
} TalkSessionListItem;
// 邀请/在聊session列表
typedef list<TalkSessionListItem> TalkSessionList;

// 获取邀请/在聊列表接口返回信息
typedef struct _tagTalkListInfo {
	TalkUserList	invite;			// 邀请列表
	TalkSessionList	inviteSession;	// 邀请的session列表
	TalkUserList	invited;		// 被邀请列表
	TalkSessionList	invitedSession;	// 被邀请的session列表
	TalkUserList	chating;		// 在聊天列表
	TalkSessionList	chatingSession;	// 在聊天的session列表
	TalkUserList	pause;			// 在聊天已暂停列表
	TalkSessionList	pauseSession;	// 在聊天已暂停的session列表
} TalkListInfo;

// 女士择偶条件item
typedef struct _tagLadyConditionItem {
	string womanId;				// 女士ID
	bool marriageCondition;		// 是否判断婚姻状况
	bool neverMarried;			// 是否从未结婚
	bool divorced;					// 是否离婚
	bool widowed;					// 是否丧偶
	bool separated;					// 是否分居
	bool married;					// 是否已婚
	bool childCondition;		// 是否判断子女状况
	bool noChild;					// 是否没有子女
	bool countryCondition;		// 是否判断国籍
	bool unitedstates;				// 是否美国国籍
	bool canada;					// 是否加拿大国籍
	bool newzealand;				// 是否新西兰国籍
	bool australia;					// 是否澳大利亚国籍
	bool unitedkingdom;				// 是否英国国籍
	bool germany;					// 是否德国国籍
	bool othercountries;			// 是否其它国籍
	int startAge;				// 起始年龄
	int endAge;					// 结束年龄

	_tagLadyConditionItem() {
		womanId = "";
		marriageCondition = false;
		neverMarried = false;
		divorced = false;
		widowed = false;
		separated = false;
		married = false;
		childCondition = false;
		noChild = false;
		countryCondition = false;
		unitedstates = false;
		canada = false;
		newzealand = false;
		australia = false;
		unitedkingdom = false;
		germany = false;
		othercountries = false;
		startAge = 0;
		endAge = 0;
	}
	_tagLadyConditionItem(const _tagLadyConditionItem& item) {
		womanId = item.womanId;
		marriageCondition = item.marriageCondition;
		neverMarried = item.neverMarried;
		divorced = item.divorced;
		widowed = item.widowed;
		separated = item.separated;
		married = item.married;
		childCondition = item.childCondition;
		noChild = item.noChild;
		countryCondition = item.countryCondition;
		unitedstates = item.unitedstates;
		canada = item.canada;
		newzealand = item.newzealand;
		australia = item.australia;
		unitedkingdom = item.unitedkingdom;
		germany = item.germany;
		othercountries = item.othercountries;
		startAge = 0;
		endAge = 0;
	}
} LadyConditionItem;

// 主题包item
typedef struct _tagThemeInfoItem {
	string themeId;		// 主题包ID
	string manId;		// 男士ID
	string womanId;		// 女士ID
	int startTime;		// 起始时间
	int endTime;		// 结束时间
	int nowTime;		// 服务器当前时间
	int updateTime;		// 最后购买/应用时间（值最大的为当前应用主题包）

	_tagThemeInfoItem() 
	{
		themeId = "";
		manId = "";
		womanId = "";
		startTime = 0;
		endTime = 0;
		nowTime = 0;
		updateTime = 0;
	}

	_tagThemeInfoItem(const _tagThemeInfoItem& item)
	{
		themeId = item.themeId;
		manId = item.manId;
		womanId = item.womanId;
		startTime = item.startTime;
		endTime = item.endTime;
		nowTime = item.nowTime;
		updateTime = item.updateTime;
	}
} ThemeInfoItem;
typedef list<ThemeInfoItem> ThemeInfoList;

// 女士用户Cam状态item
typedef struct _tagUserCamStatusItem
{
	USER_CAM_STATUS_TYPE	statusType;	// 用户Cam状态
	string				userId;		// 用户Id
	
	_tagUserCamStatusItem()  {
		Reset();
	}
	_tagUserCamStatusItem(const _tagUserCamStatusItem& item) {
		statusType = item.statusType;
		userId = item.userId;
	}
	void Reset() {
		statusType = USTATUS_CAM_OFF;
		userId = "";
	}
} UserCamStatusItem;
typedef list<UserCamStatusItem> UserCamStatusList;

