/*
 * LSLCRegisterItem.h
 *
 *  Created on: 2015-3-6
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef LSLCREGISTERITEM_H_
#define LSLCREGISTERITEM_H_

#include <string>
using namespace std;

#include <json/json/json.h>

#include "../LSLiveChatRequestAuthorizationDefine.h"

class LSLCRegisterItem {
public:
	void Parse(Json::Value root) {
		if( root.isObject() ) {
			if( root[AUTHORIZATION_LOGIN].isInt() ) {
				login = root[AUTHORIZATION_LOGIN].asInt() != 0;
			}
			if( root[AUTHORIZATION_MAN_ID].isString() ) {
				manid = root[AUTHORIZATION_MAN_ID].asString();
			}
			if( root[AUTHORIZATION_EMAIL].isString() ) {
				email = root[AUTHORIZATION_EMAIL].asString();
			}
			if( root[AUTHORIZATION_FIRSTNAME].isString() ) {
				firstname = root[AUTHORIZATION_FIRSTNAME].asString();
			}
			if( root[AUTHORIZATION_LASTNAME].isString() ) {
				lastname = root[AUTHORIZATION_LASTNAME].asString();
			}
			if( root[COMMON_SID].isString() ) {
				sid = root[COMMON_SID].asString();
			}
			if( root[AUTHORIZATION_REG_STEP].isString() ) {
				reg_step = root[AUTHORIZATION_REG_STEP].asString();
			}
			if( root[AUTHORIZATION_ERRNO].isString() ) {
				errnum = root[AUTHORIZATION_ERRNO].asString();
			}
			if( root[AUTHORIZATION_ERRTEXT].isString() ) {
				errtext = root[AUTHORIZATION_ERRTEXT].asString();
			}
			if( root[AUTHORIZATION_PHOTOURL].isString() ) {
				photoURL = root[AUTHORIZATION_PHOTOURL].asString();
			}
			if( root[AUTHORIZATION_SESSIONID].isString() ) {
				sessionid = root[AUTHORIZATION_SESSIONID].asString();
			}
			if( root[AUTHORIZATION_GA_UID].isString() ) {
				ga_uid = root[AUTHORIZATION_GA_UID].asString();
			}
			if( root[AUTHORIZATION_PHOTOSEND].isString() ) {
				string strValue = root[AUTHORIZATION_PHOTOSEND].asString();
				photosend = (atoi(strValue.c_str()) == 0) ? false : true;
			}

			if( root[AUTHORIZATION_PHOTORECEIVED].isString() ) {
				string strValue = root[AUTHORIZATION_PHOTORECEIVED].asString();
				photoreceived = (atoi(strValue.c_str()) == 0) ? false : true;
			}
			if( root[AUTHORIZATION_VIDEORECEIVED].isString() ) {
				string strValue = root[AUTHORIZATION_VIDEORECEIVED].asString();
				videoreceived = (atoi(strValue.c_str()) == 0) ? false : true;
			}

			if ( root[AUTHORIZATION_GAACTIVITY].isString() ) {
				gaActivity = root[AUTHORIZATION_GAACTIVITY].asString();
			}

			if ( root[AUTHORIZATION_ADOVERVIEW].isString() ) {
				adOverview = root[AUTHORIZATION_ADOVERVIEW].asString();
			}

			if ( root[AUTHORIZATION_ADTIMESTAMP].isInt() ) {
				adTimestamp = root[AUTHORIZATION_ADTIMESTAMP].asInt();
			}
		}
	}
	LSLCRegisterItem() {
		login = false;
		manid = "";
		email = "";
		firstname = "";
		lastname = "";
		sid = "";
		reg_step = "";
		errnum = "";
		errtext = "";
		photoURL = "";
		sessionid = "";
		ga_uid = "";

		photosend = true;
		photoreceived = true;
		videoreceived = true;
		gaActivity = "";
		adOverview = "";
		adTimestamp = 0;
	}
	virtual ~LSLCRegisterItem() {

	}

	/**
	 * 注册成功回调
	 * @param login				是否登录成功
	 * @param manid				用户id
	 * @param email				电子邮箱
	 * @param firstname			用户first name
	 * @param lastname			用户last name
	 * @param sid				跨服务器唯一标识
	 * @param reg_step			已进行的注册步骤数
	 * @param errnum			登录错误代码
	 * @param errtext			登录错误描述
	 * @param photoURL			头像URL
	 * @param sessionid			跨服务器的唯一标识
	 * @param ga_uid			Google Analytics UserID参数
	 * @param photosend			私密照片发送权限
	 * @param photoreceived		私密照片接收权限
	 * @param videoreceived		微视频接收权限（true：允许，false：不能）
	 * @param gaActivity		活动统计GA值
	 * @param adOverview        主界面弹窗参数
	 * @param adTimestamp       广告更新有效时间间隔
	 */
	bool login;
	string manid;
	string email;
	string firstname;
	string lastname;
	string sid;
	string reg_step;
	string errnum;
	string errtext;
	string photoURL;
	string sessionid;
	string ga_uid;
	bool photosend;
	bool photoreceived;
	bool videoreceived;
	string gaActivity;
	string adOverview;
	int adTimestamp;
};

#endif /* LSLCREGISTERITEM_H_ */
