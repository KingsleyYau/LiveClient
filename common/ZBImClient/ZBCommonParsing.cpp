/*
 * author: alex
 *   date: 2018-03-02
 *   file: ZBCommonParsing.cpp
 *   desc: ZBImClient公共解析协议
 */

#include "ZBCommonParsing.h"

//// UserInfo参数
//#define USERID_PARAM		"userId"		// 用户ID
//#define USERNAME_PARAM		"userName"		// 用户名称
//#define SERVER_PARAM		"server"		// 服务器名称
//#define IMGURL_PARAM		"imgUrl"		// 头像URL
//#define GENDER_PARAM		"gender"		// 性别
//#define AGE_PARAM			"age"			// 年龄
//#define WEIGHT_PARAM		"weight"		// 体重
//#define HEIGHT_PARAM		"height"		// 身高
//#define COUNTRY_PARAM		"country"		// 国家
//#define PROVINCE_PARAM		"province"		// 省份
//#define VIDEOCHAT_PARAM		"videochat"		// 是否能视频聊天
//#define VIDEO_PARAM			"video"			// 视频数目
//#define MARRY_PARAM			"marry"			// 是否已婚
//#define CHILDREN_PARAM		"children"		// 是否有子女
//#define STATUS_PARAM		"status"		// 在线状态
//#define TYPE_PARAM			"type"			// 用户类型
//#define TYPE_PARAM_WOMAN		0				// 女士
//#define TYPE_PARAM_MAN			1				// 男士
//#define TYPE_PARAM_TRANS		2				// 翻译
//#define ORDERVALUE_PARAM	"orderValue"	// 用户分值
//#define DEVICETYPE_PARAM	"deviceType"	// 设备类型
//#define CLIENTTYPE_PARAM	"clientType"	// 客户端类型
//#define CLIENTVERSION_PARAM	"clientVersion"	// 客户端版本号
//// --- 以下仅女士获取自己信息才有 ---
//#define TRANSINFO_PARAM		"transInfoBean"	// 翻译信息
//#define TRANSUSERID_PARAM	"userId"		// 翻译ID
//#define TRANSUSERNAME_PARAM	"userName"		// 翻译名称
//#define TRANSBIND_PARAM		"bind"			// 翻译是否绑定状态
//#define TRANSSTATUS_PARAM	"status"		// 翻译在线状态
//// 解析UserInfo
//bool ParsingUserInfoItem(amf_object_handle handle, UserInfoItem& item)
//{
//	bool result = false;
//	if (!handle.isnull()
//		&& handle->type == DT_OBJECT)
//	{
//		// userId
//		amf_object_handle userIdObject = handle->get_child(USERID_PARAM);
//		if (!userIdObject.isnull()
//			&& userIdObject->type == DT_STRING)
//		{
//			item.userId = userIdObject->strValue;
//		}
//
//		// userName
//		amf_object_handle userNameObject = handle->get_child(USERNAME_PARAM);
//		if (!userNameObject.isnull()
//			&& userNameObject->type == DT_STRING)
//		{
//			item.userName = userNameObject->strValue;
//		}
//
//		// server
//		amf_object_handle serverObject = handle->get_child(SERVER_PARAM);
//		if (!serverObject.isnull()
//			&& serverObject->type == DT_STRING)
//		{
//			item.server = serverObject->strValue;
//		}
//
//		// imgUrl
//		amf_object_handle imgUrlObject = handle->get_child(IMGURL_PARAM);
//		if (!imgUrlObject.isnull()
//			&& imgUrlObject->type == DT_STRING)
//		{
//			item.imgUrl = imgUrlObject->strValue;
//		}
//
//		// gender
//		amf_object_handle genderObject = handle->get_child(GENDER_PARAM);
//		if (!genderObject.isnull()
//			&& genderObject->type == DT_INTEGER)
//		{
//			item.sexType = GetUserSexType(genderObject->intValue);
//		}
//
//		// age
//		amf_object_handle ageObject = handle->get_child(AGE_PARAM);
//		if (!ageObject.isnull()
//			&& ageObject->type == DT_INTEGER)
//		{
//			item.age = ageObject->intValue;
//		}
//
//		// weight
//		amf_object_handle weightObject = handle->get_child(WEIGHT_PARAM);
//		if (!weightObject.isnull()
//			&& weightObject->type == DT_STRING)
//		{
//			item.weight = weightObject->strValue;
//		}
//
//		// height
//		amf_object_handle heightObject = handle->get_child(HEIGHT_PARAM);
//		if (!heightObject.isnull()
//			&& heightObject->type == DT_STRING)
//		{
//			item.height = heightObject->strValue;
//		}
//
//		// country
//		amf_object_handle countryObject = handle->get_child(COUNTRY_PARAM);
//		if (!countryObject.isnull()
//			&& countryObject->type == DT_STRING)
//		{
//			item.country = countryObject->strValue;
//		}
//
//		// province
//		amf_object_handle provinceObject = handle->get_child(PROVINCE_PARAM);
//		if (!provinceObject.isnull()
//			&& provinceObject->type == DT_STRING)
//		{
//			item.province = provinceObject->strValue;
//		}
//
//		// videochat
//		amf_object_handle videoChatObject = handle->get_child(VIDEOCHAT_PARAM);
//		if (!videoChatObject.isnull()
//			&& videoChatObject->type == DT_INTEGER)
//		{
//			item.videoChat = videoChatObject->intValue==1 ? true : false;
//		}
//
//		// video
//		amf_object_handle videoObject = handle->get_child(VIDEO_PARAM);
//		if (!videoObject.isnull()
//			&& videoObject->type == DT_INTEGER)
//		{
//			item.videoCount = videoObject->intValue;
//		}
//
//		// marry
//		amf_object_handle marryObject = handle->get_child(MARRY_PARAM);
//		if (!marryObject.isnull()
//			&& marryObject->type == DT_INTEGER)
//		{
//			item.marryType = GetMarryType(marryObject->intValue);
//		}
//
//		// children
//		amf_object_handle childrenObject = handle->get_child(CHILDREN_PARAM);
//		if (!childrenObject.isnull()
//			&& childrenObject->type == DT_INTEGER)
//		{
//			item.childrenType = (childrenObject->intValue > 0 ? CT_YES : CT_NO);
//		}
//
//		// status
//		amf_object_handle statusObject = handle->get_child(STATUS_PARAM);
//		if (!statusObject.isnull()
//			&& statusObject->type == DT_INTEGER)
//		{
//			item.status = GetUserStatusType(statusObject->intValue);
//		}
//
//		// type
//		amf_object_handle typeObject = handle->get_child(TYPE_PARAM);
//		if (!typeObject.isnull()
//			&& typeObject->type == DT_INTEGER)
//		{
//			item.userType = GetUserType(typeObject->intValue);
//		}
//
//		// orderValue
//		amf_object_handle orderValueObject = handle->get_child(ORDERVALUE_PARAM);
//		if (!orderValueObject.isnull()
//			&& orderValueObject->type == DT_INTEGER)
//		{
//			item.orderValue = orderValueObject->intValue;
//		}
//
//		// deviceValue
//		amf_object_handle deviceTypeObject = handle->get_child(DEVICETYPE_PARAM);
//		if (!deviceTypeObject.isnull()
//			&& deviceTypeObject->type == DT_INTEGER)
//		{
//			item.deviceType = (TDEVICE_TYPE)deviceTypeObject->intValue;
//		}
//
//		// clientValue
//		amf_object_handle clientTypeObject = handle->get_child(CLIENTTYPE_PARAM);
//		if (!clientTypeObject.isnull()
//			&& clientTypeObject->type == DT_INTEGER)
//		{
//			item.clientType = GetClientType(clientTypeObject->intValue);
//		}
//
//		// clientVersion
//		amf_object_handle clientVersionObject = handle->get_child(CLIENTVERSION_PARAM);
//		if (!clientVersionObject.isnull()
//			&& clientVersionObject->type == DT_STRING)
//		{
//			item.clientVersion = clientVersionObject->strValue;
//		}
//
//		// --- 以下仅女士端获取自己信息才有 ---
//		amf_object_handle transInfoObject = handle->get_child(TRANSINFO_PARAM);
//		if (!transInfoObject.isnull()
//			&& transInfoObject->type == DT_OBJECT)
//		{
//			// 需要翻译
//			item.needTrans = true;
//
//			// userId
//			amf_object_handle transUserIdObject = transInfoObject->get_child(TRANSUSERID_PARAM);
//			if (!transUserIdObject.isnull()
//				&& transUserIdObject->type == DT_STRING)
//			{
//				item.transUserId = transUserIdObject->strValue;
//			}
//
//			// userName
//			amf_object_handle transUserNameObject = transInfoObject->get_child(TRANSUSERNAME_PARAM);
//			if (!transUserNameObject.isnull()
//				&& transUserNameObject->type == DT_STRING)
//			{
//				item.transUserName = transUserNameObject->strValue;
//			}
//
//			// bind
//			amf_object_handle transBindObject = transInfoObject->get_child(TRANSBIND_PARAM);
//			if (!transBindObject.isnull()
//				&& (transBindObject->type == DT_TRUE || transBindObject->type == DT_FALSE))
//			{
//				item.transBind = (transBindObject->type == DT_TRUE);
//			}
//
//			// status
//			amf_object_handle transStatusObject = transInfoObject->get_child(TRANSSTATUS_PARAM);
//			if (!transStatusObject.isnull()
//				&& transStatusObject->type == DT_INTEGER)
//			{
//				item.transStatus = GetUserStatusType(transStatusObject->intValue);
//			}
//		}
//		else {
//			// 不需要翻译
//			item.needTrans = false;
//		}
//
//		// 判断是否解析成功
//		if (!item.userId.empty()) {
//			result = true;
//		}
//	}
//	return result;
//}
//
//
//// ThemeInfo参数
//#define	THEMEINFO_THEMEID_PARAM		"subjectId"
//#define THEMEINFO_MANID_PARAM		"manId"
//#define THEMEINFO_WOMANID_PARAM		"womanId"
//#define THEMEINFO_STARTTIME_PARAM	"startTime"
//#define THEMEINFO_ENDTIME_PARAM		"endTime"
//#define THEMEINFO_NOWTIME_PARAM		"now"
//#define THEMEINFO_UPDATETIME_PARAM	"updateTime"
//// 解析主题包
//bool ParsingThemeInfoItem(amf_object_handle handle, ThemeInfoItem& item)
//{
//	bool result = false;
//
//	if (!handle.isnull() && handle->type == DT_OBJECT)
//	{
//		// themeId
//		amf_object_handle themeIdObject = handle->get_child(THEMEINFO_THEMEID_PARAM);
//		if (!themeIdObject.isnull()
//			&& themeIdObject->type == DT_STRING)
//		{
//			item.themeId = themeIdObject->strValue;
//		}
//
//		// manId
//		amf_object_handle manIdObject = handle->get_child(THEMEINFO_MANID_PARAM);
//		if (!manIdObject.isnull()
//			&& manIdObject->type == DT_STRING)
//		{
//			item.manId = manIdObject->strValue;
//		}
//
//		// womanId
//		amf_object_handle womanIdObject = handle->get_child(THEMEINFO_WOMANID_PARAM);
//		if (!womanIdObject.isnull()
//			&& womanIdObject->type == DT_STRING)
//		{
//			item.womanId = womanIdObject->strValue;
//		}
//
//		// startTime
//		amf_object_handle startTimeObject = handle->get_child(THEMEINFO_STARTTIME_PARAM);
//		if (!startTimeObject.isnull()
//			&& startTimeObject->type == DT_DOUBLE)
//		{
//			double startTime = startTimeObject->doubleValue / 1000;
//			item.startTime = (int)startTime;
//		}
//
//		// endTime
//		amf_object_handle endTimeObject = handle->get_child(THEMEINFO_ENDTIME_PARAM);
//		if (!endTimeObject.isnull()
//			&& endTimeObject->type == DT_DOUBLE)
//		{
//			double endTime = endTimeObject->doubleValue / 1000;
//			item.endTime = (int)endTime;
//		}
//
//		// now
//		amf_object_handle nowObject = handle->get_child(THEMEINFO_NOWTIME_PARAM);
//		if (!nowObject.isnull()
//			&& nowObject->type == DT_DOUBLE)
//		{
//			double nowTime = nowObject->doubleValue / 1000;
//			item.nowTime = (int)nowTime;
//		}
//
//		// updateTime
//		amf_object_handle updateTimeObject = handle->get_child(THEMEINFO_UPDATETIME_PARAM);
//		if (!updateTimeObject.isnull()
//			&& updateTimeObject->type == DT_DOUBLE)
//		{
//			double updateTime = updateTimeObject->doubleValue / 1000;
//			item.updateTime = (int)updateTime;
//		}
//
//		// 解析成功
//		result = true;
//	}
//
//	return result;
//}
//
//
//// 用户会话信息（SessionInfo）
//#define	SESSIONINFO_TARGETID_PARAM		"targetId"
//#define SESSIONINFO_INVITEID_PARAM		"invitedId"
//#define SESSIONINFO_CHARGET_PARAM		"charget"
//#define SESSIONINFO_CHATTIME_PARAM		"chatTime"
//#define SESSIONINFO_FREECHAT_PARAM		"freeChat"
//#define SESSIONINFO_VIDEO_PARAM		    "video"
//#define SESSIONINFO_VIDEOTYPE_PARAM	    "videoType"
//#define SESSIONINFO_VIDEOTIME_PARAM		"videoTime"
//#define SESSIONINFO_FREETARGET_PARAM	"freeTarget"
//#define SESSIONINFO_FORBIT_PARAM		"forbit"
//#define SESSIONINFO_INVITETIME_PARAM	"inviteDtime"
//#define SESSIONINFO_CAMINVITED_PARAM	"camInvited"
//#define SESSIONINFO_SERVICETYPE_PARAM	"serviceType"
//// 解析会话信息
//bool ParsingSessionInfoItem(amf_object_handle handle, SessionInfoItem& item)
//{
//	bool result = false;
//	
//	if (!handle.isnull() && handle->type == DT_OBJECT) 
//	{
//		// targetId
//		amf_object_handle targetIdObject = handle->get_child(SESSIONINFO_TARGETID_PARAM);
//		if (!targetIdObject.isnull()
//			&& targetIdObject->type == DT_STRING)
//		{
//			item.targetId = targetIdObject->strValue;
//		}
//
//		// invitedId
//		amf_object_handle invitedIdObject = handle->get_child(SESSIONINFO_INVITEID_PARAM);
//		if (!invitedIdObject.isnull()
//			&& invitedIdObject->type == DT_STRING)
//		{
//			item.invitedId = invitedIdObject->strValue;
//		}
//
//		// charget
//		amf_object_handle chargetObject = handle->get_child(SESSIONINFO_CHARGET_PARAM);
//		if (!chargetObject.isnull()
//			&& (chargetObject->type == DT_TRUE || chargetObject->type == DT_FALSE))
//		{
//			item.charget = chargetObject->type == DT_TRUE;
//		}
//
//		// chatTime
//		amf_object_handle chatTimeObject = handle->get_child(SESSIONINFO_CHATTIME_PARAM);
//		if (!chatTimeObject.isnull()
//			&& chatTimeObject->type == DT_INTEGER)
//		{
//			item.chatTime = chatTimeObject->intValue;
//		}
//
//		// freeChat
//		amf_object_handle freeChatObject = handle->get_child(SESSIONINFO_FREECHAT_PARAM);
//		if (!freeChatObject.isnull()
//			&& (freeChatObject->type == DT_TRUE || freeChatObject->type == DT_FALSE))
//		{
//			item.freeChat = freeChatObject->type == DT_TRUE;
//		}
//
//		// video
//		amf_object_handle videoObject = handle->get_child(SESSIONINFO_VIDEO_PARAM);
//		if (!videoObject.isnull()
//			&& (videoObject->type == DT_TRUE || videoObject->type == DT_FALSE))
//		{
//			item.video = videoObject->type == DT_TRUE;
//		}
//
//		// videoType
//		amf_object_handle videoTypeObject = handle->get_child(SESSIONINFO_VIDEOTYPE_PARAM);
//		if (!videoTypeObject.isnull()
//			&& videoTypeObject->type == DT_INTEGER)
//		{
//			item.videoType = videoTypeObject->intValue;
//		}
//
//		// videoTime
//		amf_object_handle videoTimeObject = handle->get_child(SESSIONINFO_VIDEOTIME_PARAM);
//		if (!videoTimeObject.isnull()
//			&& videoTimeObject->type == DT_INTEGER)
//		{
//			item.videoTime = videoTimeObject->intValue;
//		}
//
//		// freeTarget
//		amf_object_handle freeTargetObject = handle->get_child(SESSIONINFO_FREETARGET_PARAM);
//		if (!freeTargetObject.isnull()
//			&& (freeTargetObject->type == DT_TRUE || freeTargetObject->type == DT_FALSE))
//		{
//			item.freeTarget = freeTargetObject->type == DT_TRUE;
//		}
//
//		// forbit
//		amf_object_handle forbitObject = handle->get_child(SESSIONINFO_FORBIT_PARAM);
//		if (!forbitObject.isnull()
//			&& (forbitObject->type == DT_TRUE || forbitObject->type == DT_FALSE))
//		{
//			item.forbit = forbitObject->type == DT_TRUE;
//		}
//
//		// inviteDtime
//		amf_object_handle inviteDtimeObject = handle->get_child(SESSIONINFO_INVITETIME_PARAM);
//		if (!inviteDtimeObject.isnull()
//			&& inviteDtimeObject->type == DT_INTEGER)
//		{
//			item.inviteDtime = inviteDtimeObject->intValue;
//		}
//
//		// camInvited
//		amf_object_handle camInvitedObject = handle->get_child(SESSIONINFO_CAMINVITED_PARAM);
//		if (!camInvitedObject.isnull()
//			&& (camInvitedObject->type == DT_TRUE || camInvitedObject->type == DT_FALSE))
//		{
//			item.camInvited = camInvitedObject->type == DT_TRUE;
//		}
//
//		// serviceType
//		amf_object_handle serviceTypeObject = handle->get_child(SESSIONINFO_SERVICETYPE_PARAM);
//		if (!serviceTypeObject.isnull()
//			&& serviceTypeObject->type == DT_INTEGER)
//		{
//			item.serviceType = serviceTypeObject->intValue;
//		}
//
//		// 解析成功
//		result = true;
//	}
//
//	return result;
//}
