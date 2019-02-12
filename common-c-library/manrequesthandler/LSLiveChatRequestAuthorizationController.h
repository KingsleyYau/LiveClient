/*
 * LSLiveChatRequestAuthorizationController.h
 *
 *  Created on: 2015-2-27
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#ifndef REQUESTAUTHORIZATIONCONTROLLER_H_
#define REQUESTAUTHORIZATIONCONTROLLER_H_

#include "LSLiveChatRequestBaseController.h"

#include <list>
using namespace std;

#include <json/json/json.h>

#include "LSLiveChatRequestAuthorizationDefine.h"
#include "LSLiveChatRequestOtherDefine.h"

#include "item/LSLCRegisterItem.h"
#include "item/LSLCLoginItem.h"
#include "item/LSLCLoginErrorItem.h"
#include "item/LSLCLoginFacebookItem.h"
#include "item/LSLCValidSiteIdItem.h"

typedef void (*OnLoginWithFacebook)(long requestId, bool success, LSLCLoginFacebookItem item, string errnum, string errmsg,
		LSLCLoginErrorItem errItem);
typedef void (*OnRegister)(long requestId, bool success, LSLCRegisterItem item, string errnum, string errmsg);
typedef void (*OnGetCheckCode)(long requestId, bool success, const char* data, int len, string errnum, string errmsg);
typedef void (*OnLogin)(long requestId, bool success, LSLCLoginItem item, string errnum, string errmsg, int serverId);
typedef void (*OnFindPassword)(long requestId, bool success, string tips, string errnum, string errmsg);
typedef void (*OnGetSms)(long requestId, bool success, string errnum, string errmsg);
typedef void (*OnVerifySms)(long requestId, bool success, string errnum, string errmsg);
typedef void (*OnGetFixedPhone)(long requestId, bool success, string errnum, string errmsg);
typedef void (*OnVerifyFixedPhone)(long requestId, bool success, string errnum, string errmsg);
typedef void (*OnGetWebsiteUrlToken)(long requestId, bool success, string errnum, string errmsg, string token);
typedef void (*OnSummitAppToken)(long requestId, bool success, string errnum, string errmsg);
typedef void (*OnUnbindAppToken)(long requestId, bool success, string errnum, string errmsg);
typedef void (*OnReactivateMemberShip)(long requestId, bool success, string errnum, string errmsg);
typedef void (*OnTokenLogin)(long requestId, bool success, LSLCLoginItem item, string errnum, string errmsg);
typedef void (*OnGetValidSiteId)(long requestId, bool success, string errnum, string errmsg, ValidSiteIdList siteIdList);

typedef struct LSLiveChatRequestAuthorizationControllerCallback {
	OnLoginWithFacebook onLoginWithFacebook;
	OnRegister onRegister;
	OnGetCheckCode onGetCheckCode;
	OnLogin onLogin;
	OnFindPassword onFindPassword;
	OnGetSms onGetSms;
	OnVerifySms onVerifySms;
	OnGetFixedPhone onGetFixedPhone;
	OnVerifyFixedPhone onVerifyFixedPhone;
    OnGetWebsiteUrlToken onGetWebsiteUrlToken;
	OnSummitAppToken onSummitAppToken;
	OnUnbindAppToken onUnbindAppToken;
    OnReactivateMemberShip onReactivateMemberShip;
    OnTokenLogin onTokenLogin;
    OnGetValidSiteId onGetValidSiteId;
} LSLiveChatRequestAuthorizationControllerCallback;


class LSLiveChatRequestAuthorizationController : public LSLiveChatRequestBaseController, public ILSLiveChatHttpRequestManagerCallback {
public:
	LSLiveChatRequestAuthorizationController(LSLiveChatHttpRequestManager* pHttpRequestManager, LSLiveChatRequestAuthorizationControllerCallback callback/*, CallbackManager* pCallbackManager*/);
	virtual ~LSLiveChatRequestAuthorizationController();

    /**
     * 2.1.Facebook注册及登录
     * @param token				Facebook登录返回的token
     * @param email				电子邮箱
     * @param password			密码
     * @param deviceId			设备唯一标识
     * @param versioncode		客户端内部版本号
     * @param model				移动设备型号
     * @param manufacturer		制造厂商
     * @param prevcode			上一步操作的错误代码
     * @param birthday_y		生日的年
     * @param birthday_m		生日的月
     * @param birthday_d		生日的日
     * @param referrer			app推广参数（安装成功app第一次运行时GooglePlay返回）
     * @return					请求唯一标识
     */
    long LoginWithFacebook(
    		string token,
    		string email,
    		string password,
    		string deviceId,
    		string versioncode,
    		string model,
    		string manufacturer,
    		string prevcode,
    		string birthday_y,
    		string birthday_m,
    		string birthday_d,
    		string referrer
    		);

    /**
     * 2.2.注册帐号
     * @param email				电子邮箱
     * @param password			密码
     * @param male				性别, true:男性/false:女性
     * @param first_name		用户first name
     * @param last_name			用户last name
     * @param country			国家区号,参考数组<CountryArray>
     * @param birthday_y		生日的年
     * @param birthday_m		生日的月
     * @param birthday_d		生日的日
     * @param weeklymail		是否接收订阅
     * @param model				移动设备型号
     * @param deviceId			设备唯一标识
     * @param manufacturer		制造厂商
     * @param referrer			app推广参数（安装成功app第一次运行时GooglePlay返回）
     * @return					请求唯一标识
     */
	long Register(
			string email,
			string password,
			bool male,
			string first_name,
			string last_name,
			int country,
			string birthday_y,
			string birthday_m,
			string birthday_d,
			bool weeklymail,
			string model,
			string deviceId,
			string manufacturer,
			string referrer
			);

    /**
     * 2.3.获取验证码
     * @param isUseCode        是否需要验证码（1: 必须（如取回密码时） 0:无限，服务器自动检测ip国家 ）
     * @param callback
     * @return					请求唯一标识
     */
	long GetCheckCode(bool isUseCode = false);

    /**
     * 2.4.登录
     * @param email				电子邮箱
     * @param password			密码
     * @param checkcode			验证码
     * @param deviceId			设备唯一标识
     * @param versioncode		客户端内部版本号
     * @param model				移动设备型号
     * @param manufacturer		制造厂商
     * @return					请求唯一标识
     */
    long Login(
    		string email,
    		string password,
    		string checkcode,
    		string deviceId,
    		string versioncode,
    		string model,
    		string manufacturer
    		);

    /**
     * 2.5.找回密码
     * @param email			用户注册的邮箱
     * @param checkcode		验证码
     * @return				请求唯一标识
     */
    long FindPassword(string email, string checkcode);

    /**
     * 2.6.手机获取认证短信
     * @param telephone			电话号码
     * @param telephone_cc		国家区号,参考参考数组<CountryArray>
     * @param device_id			设备唯一标识
     * @return					请求唯一标识
     */
    long GetSms(string telephone, int telephone_cc, string device_id);

    /**
     * 2.7.手机短信认证
     * @param verify_code		验证码
     * @param v_type			验证类型
     * @return					请求唯一标识
     */
    long VerifySms(string verify_code, int v_type);

    /**
     * 2.8.固定电话获取认证短信
     * @param landline			电话号码
     * @param telephone_cc		国家区号,参考数组<CountryArray>
     * @param landline_ac		区号
     * @param device_id			设备唯一标识
     * @return					请求唯一标识
     */
    long GetFixedPhone(string landline, int telephone_cc, string landline_ac, string device_id);

    /**
     * 2.9.固定电话短信认证
     * @param verify_code		验证码
     * @return					请求唯一标识
     */
    long VerifyFixedPhone(string verify_code);
    
    /**
     * 2.10.获取token
     * @param siteType        前往的站点ID
     * @param clientType      前往的客户端标识（可无， 默认是app）
     * @param siteUrl         前往分站的目标url（可无， App端默认为无）
     * @return                    请求唯一标识
     */
    long GetWebsiteUrlToken(OTHER_SITE_TYPE siteType, VERIFY_CLIENT_TYPE clientType = VERIFY_CLIENT_TYPE_APP, string siteUrl = "");

    /**
     * 2.11. 添加App token
     * @param deviceId
     * @param tokenId
     * @param appId
     */
    long SummitAppToken(string deviceId, string tokenId, string appId);

    /**
     * 2.12. 销毁App token
     */
    long UnbindAppToken();
    
    /**
     * 2.13. 重新激活账号
     */
    long ReactivateMemberShip();
    
    /**
     * 2.14.token登录认证
     * @param token               用于登录其他站点的加密串
     * @param memberId            会员
     * @param deviceId            设备唯一标识
     * @param versioncode         客户端内部版本号
     * @param model               移动设备型号
     * @param manufacturer        制造厂商
     * @return                    请求唯一标识
     */
    long TokenLogin(
               string token,
               string memberId,
               string deviceId,
               string versioncode,
               string model,
               string manufacturer
               );
    
    /**
     * 2.15.可登录的站点列表
     * @param email               用户的email或id
     * @param password            登录密码
     * @return                    请求唯一标识
     */
    long GetValidSiteId(
                    string email,
                    string password
                    );
    
protected:
	void onSuccess(long requestId, string path, const char* buf, int size);
	void onFail(long requestId, string path);

private:
	LSLiveChatRequestAuthorizationControllerCallback mLSLiveChatRequestAuthorizationControllerCallback;
};

#endif /* LSLiveChatRequestAuthorizationController_H_ */
