/*
 * LSLiveChatRequestAuthorizationController.cpp
 *
 *  Created on: 2015-2-27
 *      Author: Max.Chiu
 *      Email: Kingsleyyau@gmail.com
 */

#include "LSLiveChatRequestAuthorizationController.h"

#include "LSLiveChatRequestEnumDefine.h"

#include <amf/AmfParser.h>



/**
 * 验证类型
 * 2.默认为首次验证，3.下單驗證（可选字段）
 */
#define VerifyArrayCount 2
string VerifyArray[VerifyArrayCount] = {
		"1",
		"3",
};

LSLiveChatRequestAuthorizationController::LSLiveChatRequestAuthorizationController(LSLiveChatHttpRequestManager *pHttpRequestManager, LSLiveChatRequestAuthorizationControllerCallback callback/* CallbackManager* pCallbackManager*/) {
	// TODO Auto-generated constructor stub
	SetHttpRequestManager(pHttpRequestManager);
	mLSLiveChatRequestAuthorizationControllerCallback = callback;
}

LSLiveChatRequestAuthorizationController::~LSLiveChatRequestAuthorizationController() {
	// TODO Auto-generated destructor stub
}

/* ILSLiveChatHttpRequestManagerCallback */
void LSLiveChatRequestAuthorizationController::onSuccess(long requestId, string url, const char* buf, int size) {
	FileLevelLog("httprequest", KLog::LOG_WARNING,
			"LSLiveChatRequestAuthorizationController::onSuccess( url : %s, content-type : %s, buf( size : %d ) )",
			url.c_str(),
			GetContentTypeById(requestId).c_str(),
			size
			);

	if (size < MAX_LOG_BUFFER) {
		FileLevelLog("httprequest", KLog::LOG_WARNING, "LSLiveChatRequestAuthorizationController::onSuccess(), buf: %s", buf);
	}

	/* parse base result */
	string errnum = "";
	string errmsg = "";
	Json::Value data;
	Json::Value errdata;

	bool bFlag = HandleResult(buf, size, errnum, errmsg, &data, &errdata);

	/* resopned parse ok, callback success */
	if( url.compare(FACEBOOK_LOGIN_PATH) == 0 ) {
		/* 2.1.Facebook注册及登录 */
		LSLCLoginFacebookItem item;
		item.Parse(data);
		LSLCLoginErrorItem errItem;
		errItem.Parse(errdata);
		if( mLSLiveChatRequestAuthorizationControllerCallback.onLoginWithFacebook != NULL ) {
			mLSLiveChatRequestAuthorizationControllerCallback.onLoginWithFacebook(requestId, bFlag, item, errnum, errmsg, errItem);
		}
	} else if( url.compare(REGISTER_PATH) == 0 ) {
		/* 2.2.注册帐号 */
		LSLCRegisterItem item;
		item.Parse(data);
		if( mLSLiveChatRequestAuthorizationControllerCallback.onRegister != NULL ) {
			mLSLiveChatRequestAuthorizationControllerCallback.onRegister(requestId, bFlag, item, errnum, errmsg);
		}
	} else if( url.compare(CEHCKCODE_PATH) == 0 ) {
		/* 2.3.获取验证码 */
		bool bParse = false;
		if( GetContentTypeById(requestId).compare("image/png") == 0 ) {
			bParse = true;
		}

		if( mLSLiveChatRequestAuthorizationControllerCallback.onGetCheckCode != NULL ) {
			mLSLiveChatRequestAuthorizationControllerCallback.onGetCheckCode(requestId, bParse, buf, size, errnum, errmsg);
		}
	} else if( url.compare(LOGIN_PATH) == 0 ) {
		/* 2.4.登录 */
		LSLCLoginItem item;
		item.Parse(data);
        // serverid:是否真服务器帐号（1:真服务器 0:假服务器）
        int errServerId = -1;
        if (errdata.isObject()) {
            if(errdata[COMMON_ERRDATA_SERVERID].isInt()){
                errServerId = errdata[COMMON_ERRDATA_SERVERID].asInt();
            }
        }
        
		if( mLSLiveChatRequestAuthorizationControllerCallback.onLogin != NULL ) {
			mLSLiveChatRequestAuthorizationControllerCallback.onLogin(requestId, bFlag, item, errnum, errmsg, errServerId);
		}
	} else if( url.compare(FINDPASSWORD_PATH) == 0 ) {
		/* 2.5.找回密码 */
		if( mLSLiveChatRequestAuthorizationControllerCallback.onFindPassword != NULL ) {
			if( data.isString() ) {
				mLSLiveChatRequestAuthorizationControllerCallback.onFindPassword(requestId, bFlag,
						data.asString(), errnum, errmsg);
			} else {
				mLSLiveChatRequestAuthorizationControllerCallback.onFindPassword(requestId, bFlag,
						"", errnum, errmsg);
			}
		}

	} else if( url.compare(GET_SMS_PATH) == 0 ) {
		/* 2.6.手机获取认证短信 */
		if( mLSLiveChatRequestAuthorizationControllerCallback.onGetSms != NULL ) {
			mLSLiveChatRequestAuthorizationControllerCallback.onGetSms(requestId, bFlag, errnum, errmsg);
		}
	} else if( url.compare(VERIFY_SMS_PATH) == 0 ) {
		/* 2.7.手机短信认证  */
		if( mLSLiveChatRequestAuthorizationControllerCallback.onVerifySms != NULL ) {
			mLSLiveChatRequestAuthorizationControllerCallback.onVerifySms(requestId, bFlag, errnum, errmsg);
		}
	} else if( url.compare(GET_FIXED_PHONE_PATH) == 0 ) {
		/* 2.8.固定电话获取认证短信 */
		if( mLSLiveChatRequestAuthorizationControllerCallback.onGetFixedPhone != NULL ) {
			mLSLiveChatRequestAuthorizationControllerCallback.onGetFixedPhone(requestId, bFlag, errnum, errmsg);
		}
	} else if( url.compare(VERIFY_FIXED_PHONE_PATH) == 0 ) {
		/* 2.9.固定电话短信认证 */
		if( mLSLiveChatRequestAuthorizationControllerCallback.onVerifyFixedPhone != NULL ) {
			mLSLiveChatRequestAuthorizationControllerCallback.onVerifyFixedPhone(requestId, bFlag, errnum, errmsg);
		}
    }else if( url.compare(GET_WEBSITEURL_TOKEN_PATH) == 0 ) {
         /* 2.10.获取token */
        string token = "";
        if (data.isObject()) {
            if(data[AUTHORIZATION_TOKEN_ID].isString()){
                token = data[AUTHORIZATION_TOKEN_ID].asString();
            }
        }
       
        if( mLSLiveChatRequestAuthorizationControllerCallback.onGetWebsiteUrlToken != NULL ) {
            mLSLiveChatRequestAuthorizationControllerCallback.onGetWebsiteUrlToken(requestId, bFlag, errnum, errmsg, token);
        }
    }else if( url.compare(SUMMIT_APP_TOKEN_PATH) == 0 ) {
		/* 2.11.添加App token */
		if( mLSLiveChatRequestAuthorizationControllerCallback.onSummitAppToken != NULL ) {
			mLSLiveChatRequestAuthorizationControllerCallback.onSummitAppToken(requestId, bFlag, errnum, errmsg);
		}
	} else if( url.compare(UNBIND_APP_TOKEN_PATH) == 0 ) {
		/* 2.12.销毁App token */
		if( mLSLiveChatRequestAuthorizationControllerCallback.onUnbindAppToken != NULL ) {
			mLSLiveChatRequestAuthorizationControllerCallback.onUnbindAppToken(requestId, bFlag, errnum, errmsg);
		}
    } else if( url.compare(REACTIVATE_MEMBER_SHIP_PATH) == 0 ) {
        /* 2.13.重新激活账号 */
        if( mLSLiveChatRequestAuthorizationControllerCallback.onReactivateMemberShip != NULL ) {
            mLSLiveChatRequestAuthorizationControllerCallback.onReactivateMemberShip(requestId, bFlag, errnum, errmsg);
        }
    }else if( url.compare(VERIFY_TOKEN_LOGIN_PATH) == 0 ) {
        /* 2.14. token登录认证 */
        LSLCLoginItem item;
        item.Parse(data);
        
        if( mLSLiveChatRequestAuthorizationControllerCallback.onTokenLogin != NULL ) {
            mLSLiveChatRequestAuthorizationControllerCallback.onTokenLogin(requestId, bFlag, item, errnum, errmsg);
        }
    }else if( url.compare(GET_VALID_SITEID_PATH) == 0 ) {
        /* 2.15. 可登录的站点列表 */
        ValidSiteIdList siteIdList;
        
        if (data.isObject()) {
            if (data[AUTHORIZATION_DATALIST].isArray()) {
                for (int i = 0; i < data[AUTHORIZATION_DATALIST].size(); i++) {
                    LSLCValidSiteIdItem item;
                    item.Parse(data[AUTHORIZATION_DATALIST].get(i, Json::Value::null));
                    siteIdList.push_back(item);
                }
            }
        }
        
        if( mLSLiveChatRequestAuthorizationControllerCallback.onGetValidSiteId != NULL ) {
            mLSLiveChatRequestAuthorizationControllerCallback.onGetValidSiteId(requestId, bFlag, errnum, errmsg, siteIdList);
        }
    }
    
    FileLog("httprequest", "LSLiveChatRequestAuthorizationController::onSuccess() end, url:%s", url.c_str());
}
void LSLiveChatRequestAuthorizationController::onFail(long requestId, string url) {
	FileLevelLog("httprequest", KLog::LOG_WARNING, "LSLiveChatRequestAuthorizationController::onFail( url : %s )", url.c_str());
	/* request fail, callback fail */
	if( url.compare(FACEBOOK_LOGIN_PATH) == 0 ) {
		/* 2.1.Facebook注册及登录 */
		LSLCLoginFacebookItem item;
		LSLCLoginErrorItem errItem;
		if( mLSLiveChatRequestAuthorizationControllerCallback.onLoginWithFacebook != NULL ) {
			mLSLiveChatRequestAuthorizationControllerCallback.onLoginWithFacebook(requestId, false, item,
					LOCAL_ERROR_CODE_TIMEOUT, LOCAL_ERROR_CODE_TIMEOUT_DESC, errItem);
		}
	} else if( url.compare(REGISTER_PATH) == 0 ) {
		/* 2.2.注册帐号 */
		if( mLSLiveChatRequestAuthorizationControllerCallback.onRegister != NULL ) {
			LSLCRegisterItem item;
			mLSLiveChatRequestAuthorizationControllerCallback.onRegister(requestId, false, item, LOCAL_ERROR_CODE_TIMEOUT, LOCAL_ERROR_CODE_TIMEOUT_DESC);
		}
	} else if( url.compare(CEHCKCODE_PATH) == 0 ) {
		/* 2.3.获取验证码 */
		if( mLSLiveChatRequestAuthorizationControllerCallback.onGetCheckCode != NULL ) {
			mLSLiveChatRequestAuthorizationControllerCallback.onGetCheckCode(requestId, false, NULL, 0, LOCAL_ERROR_CODE_TIMEOUT, LOCAL_ERROR_CODE_TIMEOUT_DESC);
		}
	} else if( url.compare(LOGIN_PATH) == 0 ) {
		/* 2.4.登录 */
		if( mLSLiveChatRequestAuthorizationControllerCallback.onLogin != NULL ) {
			LSLCLoginItem item;
			mLSLiveChatRequestAuthorizationControllerCallback.onLogin(requestId, false, item, LOCAL_ERROR_CODE_TIMEOUT, LOCAL_ERROR_CODE_TIMEOUT_DESC, 1);
		}
	} else if( url.compare(FINDPASSWORD_PATH) == 0 ) {
		/* 2.5.找回密码 */
		if( mLSLiveChatRequestAuthorizationControllerCallback.onFindPassword != NULL ) {
			mLSLiveChatRequestAuthorizationControllerCallback.onFindPassword(requestId, false,
					"", LOCAL_ERROR_CODE_TIMEOUT, LOCAL_ERROR_CODE_TIMEOUT_DESC);
		}
	} else if( url.compare(GET_SMS_PATH) == 0 ) {
		/* 2.6.手机获取认证短信 */
		if( mLSLiveChatRequestAuthorizationControllerCallback.onGetSms != NULL ) {
			mLSLiveChatRequestAuthorizationControllerCallback.onGetSms(requestId, false, LOCAL_ERROR_CODE_TIMEOUT, LOCAL_ERROR_CODE_TIMEOUT_DESC);
		}
	} else if( url.compare(VERIFY_SMS_PATH) == 0 ) {
		/* 2.7.手机短信认证  */
		if( mLSLiveChatRequestAuthorizationControllerCallback.onVerifySms != NULL ) {
			mLSLiveChatRequestAuthorizationControllerCallback.onVerifySms(requestId, false, LOCAL_ERROR_CODE_TIMEOUT, LOCAL_ERROR_CODE_TIMEOUT_DESC);
		}
	} else if( url.compare(GET_FIXED_PHONE_PATH) == 0 ) {
		/* 2.8.固定电话获取认证短信 */
		if( mLSLiveChatRequestAuthorizationControllerCallback.onGetFixedPhone != NULL ) {
			mLSLiveChatRequestAuthorizationControllerCallback.onGetFixedPhone(requestId, false, LOCAL_ERROR_CODE_TIMEOUT, LOCAL_ERROR_CODE_TIMEOUT_DESC);
		}
	} else if( url.compare(VERIFY_FIXED_PHONE_PATH) == 0 ) {
		/* 2.9.固定电话短信认证 */
		if( mLSLiveChatRequestAuthorizationControllerCallback.onVerifyFixedPhone != NULL ) {
			mLSLiveChatRequestAuthorizationControllerCallback.onVerifyFixedPhone(requestId, false, LOCAL_ERROR_CODE_TIMEOUT, LOCAL_ERROR_CODE_TIMEOUT_DESC);
		}
    } else if( url.compare(GET_WEBSITEURL_TOKEN_PATH) == 0 ) {
        /* 2.10.获取token */
        if( mLSLiveChatRequestAuthorizationControllerCallback.onGetWebsiteUrlToken != NULL ) {
            mLSLiveChatRequestAuthorizationControllerCallback.onGetWebsiteUrlToken(requestId, false, LOCAL_ERROR_CODE_TIMEOUT, LOCAL_ERROR_CODE_TIMEOUT_DESC, "");
        }
    }else if( url.compare(SUMMIT_APP_TOKEN_PATH) == 0 ) {
		/* 2.11.添加App token */
		if( mLSLiveChatRequestAuthorizationControllerCallback.onSummitAppToken != NULL ) {
			mLSLiveChatRequestAuthorizationControllerCallback.onSummitAppToken(requestId, false, LOCAL_ERROR_CODE_TIMEOUT, LOCAL_ERROR_CODE_TIMEOUT_DESC);
		}
	} else if( url.compare(UNBIND_APP_TOKEN_PATH) == 0 ) {
		/* 2.12.销毁App token*/
		if( mLSLiveChatRequestAuthorizationControllerCallback.onUnbindAppToken != NULL ) {
			mLSLiveChatRequestAuthorizationControllerCallback.onUnbindAppToken(requestId, false, LOCAL_ERROR_CODE_TIMEOUT, LOCAL_ERROR_CODE_TIMEOUT_DESC);
		}
    } else if( url.compare(REACTIVATE_MEMBER_SHIP_PATH) == 0 ) {
        /* 2.13.重新激活账号 */
        if( mLSLiveChatRequestAuthorizationControllerCallback.onReactivateMemberShip != NULL ) {
            mLSLiveChatRequestAuthorizationControllerCallback.onReactivateMemberShip(requestId, false, LOCAL_ERROR_CODE_TIMEOUT, LOCAL_ERROR_CODE_TIMEOUT_DESC);
        }
    }else if( url.compare(VERIFY_TOKEN_LOGIN_PATH) == 0 ) {
        /* 2.14. token登录认证 */
        
        if( mLSLiveChatRequestAuthorizationControllerCallback.onTokenLogin != NULL ) {
            LSLCLoginItem item;
            mLSLiveChatRequestAuthorizationControllerCallback.onTokenLogin(requestId, false, item, LOCAL_ERROR_CODE_TIMEOUT, LOCAL_ERROR_CODE_TIMEOUT_DESC);
        }
    }else if( url.compare(GET_VALID_SITEID_PATH) == 0 ) {
        /* 2.15. 可登录的站点列表 */

        if( mLSLiveChatRequestAuthorizationControllerCallback.onGetValidSiteId != NULL ) {
            ValidSiteIdList siteIdList;
            mLSLiveChatRequestAuthorizationControllerCallback.onGetValidSiteId(requestId, false, LOCAL_ERROR_CODE_TIMEOUT, LOCAL_ERROR_CODE_TIMEOUT_DESC, siteIdList);
        }
    }
	FileLog("httprequest", "LSLiveChatRequestAuthorizationController::onFail() end, url:%s", url.c_str());
}


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
long LSLiveChatRequestAuthorizationController::LoginWithFacebook(
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
		) {
//	char temp[16];

	HttpEntiy entiy;
	entiy.SetSaveCookie(true);

	if( token.length() > 0 ) {
		entiy.AddContent(AUTHORIZATION_FACEBOOK_TOKEN, token.c_str());
	}

	if( email.length() > 0 ) {
		entiy.AddContent(AUTHORIZATION_EMAIL, email.c_str());
	}

	if( password.length() > 0 ) {
		entiy.AddContent(AUTHORIZATION_PASSWORD2, password.c_str());
	}

	if( versioncode.length() > 0 ) {
		entiy.AddContent(AUTHORIZATION_VERSIONCODE, versioncode.c_str());
	}

	if( model.length() > 0 ) {
		entiy.AddContent(AUTHORIZATION_MODEL, model.c_str());
	}

	if( deviceId.length() > 0 ) {
		entiy.AddContent(AUTHORIZATION_DEVICEID, deviceId.c_str());
	}

	if( manufacturer.length() > 0 ) {
		entiy.AddContent(AUTHORIZATION_MANUFACTURER, manufacturer.c_str());
	}

	if (prevcode.length() > 0) {
		entiy.AddContent(AUTHORIZATION_PREVCODE, prevcode.c_str());
	}

	if( birthday_y.length() > 0 && birthday_m.length() > 0 && birthday_d.length() > 0 ) {
		string birthday = birthday_y + "-" + birthday_m + "-" + birthday_d;
		entiy.AddContent(AUTHORIZATION_BIRTHDAY, birthday.c_str());
	}

	if (referrer.length() > 0) {
		entiy.AddContent(AUTHORIZATION_UTMREFERRER, referrer.c_str());
	}

	string url = FACEBOOK_LOGIN_PATH;
	FileLog("httprequest", "LSLiveChatRequestAuthorizationController::LoginWithFacebook( "
			"url : %s, "
			"token : %s, "
			"email : %s, "
			"password : %s, "
			"versioncode : %s, "
			"model : %s, "
			"deviceId : %s, "
			"manufacturer : %s "
			"prevcode : %s, "
			"birthday_y : %s, "
			"birthday_m : %s, "
			"birthday_d : %s, "
			"referrer : %s"
			" )",
			url.c_str(),
			token.c_str(),
			email.c_str(),
			password.c_str(),
			versioncode.c_str(),
			model.c_str(),
			deviceId.c_str(),
			manufacturer.c_str(),
			prevcode.c_str(),
			birthday_y.c_str(),
			birthday_m.c_str(),
			birthday_d.c_str(),
			referrer.c_str()
			);

	return StartRequest(url, entiy, this);
}

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
long LSLiveChatRequestAuthorizationController::Register(
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
		) {
	char temp[16];

	HttpEntiy entiy;
	entiy.SetSaveCookie(true);

	if( email.length() > 0 ) {
		entiy.AddContent(AUTHORIZATION_EMAIL, email.c_str());
	}

	if( password.length() > 0 ) {
		entiy.AddContent(AUTHORIZATION_PASSWORD, password.c_str());
	}

	if( male ) {
		// 男人
		entiy.AddContent(AUTHORIZATION_GENDER, "M");
	} else {
		// 女人
		entiy.AddContent(AUTHORIZATION_GENDER, "F");
	}

	if( first_name.length() > 0 ) {
		entiy.AddContent(AUTHORIZATION_FIRST_NAME, first_name.c_str());
	}

	if( last_name.length() > 0 ) {
		entiy.AddContent(AUTHORIZATION_LAST_NAME, last_name.c_str());
	}

	string strCountry = GetCountryCode(country);
	if( !strCountry.empty() ) {
		entiy.AddContent(AUTHORIZATION_COUNTRY, strCountry.c_str());
	}

	if( birthday_y.length() > 0 ) {
		entiy.AddContent(AUTHORIZATION_BIRTHDAY_Y, birthday_y.c_str());
	}

	if( birthday_m.length() > 0 ) {
		entiy.AddContent(AUTHORIZATION_BIRTHDAY_M, birthday_m.c_str());
	}

	if( birthday_d.length() > 0 ) {
		entiy.AddContent(AUTHORIZATION_BIRTHDAY_D, birthday_d.c_str());
	}

	sprintf(temp, "%s", weeklymail?"true":"false");
	entiy.AddContent(AUTHORIZATION_WEEKLY_MAIL, temp);

	if( model.length() > 0 ) {
		entiy.AddContent(AUTHORIZATION_MODEL, model.c_str());
	}

	if( deviceId.length() > 0 ) {
		entiy.AddContent(AUTHORIZATION_DEVICEID, deviceId.c_str());
	}

	if( manufacturer.length() > 0 ) {
		entiy.AddContent(AUTHORIZATION_MANUFACTURER, manufacturer.c_str());
	}

	if (referrer.length() > 0) {
		entiy.AddContent(AUTHORIZATION_UTMREFERRER, referrer.c_str());
	}

	string url = REGISTER_PATH;
	FileLog("httprequest", "LSLiveChatRequestAuthorizationController::Register( "
			"url : %s, "
			"email : %s, "
			"password : %s, "
			"first_name : %s, "
			"last_name : %s, "
			"country : %s, "
			"birthday_y : %s, "
			"birthday_m : %s, "
			"birthday_d : %s, "
			"weeklymail : %s, "
			"model : %s, "
			"deviceId : %s, "
			"manufacturer : %s, "
			"referrer : %s "
			")",
			url.c_str(),
			email.c_str(),
			password.c_str(),
			first_name.c_str(),
			last_name.c_str(),
			strCountry.c_str(),
			birthday_y.c_str(),
			birthday_m.c_str(),
			birthday_d.c_str(),
			weeklymail?"true":"false",
			model.c_str(),
			deviceId.c_str(),
			manufacturer.c_str(),
			referrer.c_str()
			);

	return StartRequest(url, entiy, this);
}

/**
 * 2.3.获取验证码
 * @param callback
 * @return					请求唯一标识
 */
long LSLiveChatRequestAuthorizationController::GetCheckCode(bool isUseCode) {
	HttpEntiy entiy;
    // 接口是否是下载文件（为了如果服务器返回的大小不知道，而curl会按照超时判断断http停止，如果是文件这个已经收到数据了，服务器已经记录完成了）alex,2019-09-21
    entiy.SetIsDownLoadFile(true);
	entiy.SetSaveCookie(true);
    
    if(isUseCode) {
        // 需要验证码
        entiy.AddContent(AUTHORIZATION_USECODE, "1");
    } else {
        // 无限制
        entiy.AddContent(AUTHORIZATION_USECODE, "0");
    }

	string url = CEHCKCODE_PATH;
	FileLog("httprequest", "LSLiveChatRequestAuthorizationController::GetCheckCode( "
			"url : %s, "
			")",
			url.c_str()
			);

	return StartRequest(url, entiy, this);
}
/**
 * 2.4.登录
 * @param email				电子邮箱
 * @param password			密码
 * @param deviceId			设备唯一标识
 * @param versioncode		客户端内部版本号
 * @param model				移动设备型号
 * @param manufacturer		制造厂商
 * @return
 */
long LSLiveChatRequestAuthorizationController::Login(
		string email,
		string password,
		string checkcode,
		string deviceId,
		string versioncode,
		string model,
		string manufacturer
		) {

//	char temp[16];

	HttpEntiy entiy;

	entiy.SetSaveCookie(true);

	if( email.length() > 0 ) {
		entiy.AddContent(AUTHORIZATION_EMAIL, email.c_str());
	}

	if( password.length() > 0 ) {
		entiy.AddContent(AUTHORIZATION_PASSWORD2, password.c_str());
	}

	if( checkcode.length() > 0 ) {
		entiy.AddContent(AUTHORIZATION_CHECKCODE, checkcode.c_str());
	}

	if( deviceId.length() > 0 ) {
		entiy.AddContent(AUTHORIZATION_DEVICEID, deviceId.c_str());
	}

	if( versioncode.length() > 0 ) {
		entiy.AddContent(AUTHORIZATION_VERSIONCODE, versioncode.c_str());
	}

	if( model.length() > 0 ) {
		entiy.AddContent(AUTHORIZATION_MODEL, model.c_str());
	}

	if( manufacturer.length() > 0 ) {
		entiy.AddContent(AUTHORIZATION_MANUFACTURER, manufacturer.c_str());
	}

	string url = LOGIN_PATH;
	FileLog("httprequest", "LSLiveChatRequestAuthorizationController::Login( "
			"url : %s, "
			"email : %s, "
			"password : %s, "
			"checkcode : %s, "
			"deviceId : %s, "
			"versioncode : %s, "
			"model : %s, "
			"manufacturer : %s "
			")",
			url.c_str(),
			email.c_str(),
			password.c_str(),
			checkcode.c_str(),
			deviceId.c_str(),
			versioncode.c_str(),
			model.c_str(),
			manufacturer.c_str());

	return StartRequest(url, entiy, this);
}

/**
 * 2.5.找回密码
 * @param email			用户注册的邮箱
 * @return				请求唯一标识
 */
long LSLiveChatRequestAuthorizationController::FindPassword(string email, string checkcode) {
	HttpEntiy entiy;

	if( email.length() > 0 ) {
		entiy.AddContent(AUTHORIZATION_SENDMAIL, email.c_str());
	}

	if( checkcode.length() > 0 ) {
		entiy.AddContent(AUTHORIZATION_CHECKCODE, checkcode.c_str());
	}

	string url = FINDPASSWORD_PATH;
	FileLog("httprequest", "LSLiveChatRequestAuthorizationController::FindPassword( "
			"url : %s, "
			"email : %s, "
			"checkcode : %s "
			")",
			url.c_str(),
			email.c_str(),
			checkcode.c_str()
			);

	return StartRequest(url, entiy, this);
}

/**
 * 2.6.手机获取认证短信
 * @param telephone			电话号码
 * @param telephone_cc		国家区号,参考参考数组<CountryArray>
 * @param device_id			设备唯一标识
 * @return					请求唯一标识
 */
long LSLiveChatRequestAuthorizationController::GetSms(string telephone, int telephone_cc, string device_id) {
	HttpEntiy entiy;

	if( telephone.length() > 0 ) {
		entiy.AddContent(AUTHORIZATION_TELEPHONE, telephone.c_str());
	}

	string strCountry = GetCountryCode(telephone_cc);
	if( !strCountry.empty() ) {
		entiy.AddContent(AUTHORIZATION_TELEPHONE_CC, strCountry.c_str());
	}

	if( device_id.length() > 0 ) {
		entiy.AddContent(AUTHORIZATION_DEVICE_ID, device_id.c_str());
	}

	string url = GET_SMS_PATH;
	FileLog("httprequest", "LSLiveChatRequestAuthorizationController::GetSms( "
			"url : %s, "
			"telephone : %s, "
			"telephone_cc : %d, "
			"device_id : %s, "
			")",
			url.c_str(),
			telephone.c_str(),
			telephone_cc,
			device_id.c_str()
			);

	return StartRequest(url, entiy, this);
}

/**
 * 2.7.手机短信认证
 * @param verify_code		验证码
 * @param v_type			验证类型
 * @return					请求唯一标识
 */
long LSLiveChatRequestAuthorizationController::VerifySms(string verify_code, int v_type) {
	HttpEntiy entiy;

	if( verify_code.length() > 0 ) {
		entiy.AddContent(AUTHORIZATION_VERIFY_CODE, verify_code.c_str());
	}

	if( v_type > -1 && v_type < VerifyArrayCount ) {
		entiy.AddContent(AUTHORIZATION_V_TYPE, VerifyArray[v_type]);
	}

	string url = VERIFY_SMS_PATH;
	FileLog("httprequest", "LSLiveChatRequestAuthorizationController::VerifySms( "
			"url : %s, "
			"verify_code : %s, "
			"v_type : %d, "
			")",
			url.c_str(),
			verify_code.c_str(),
			v_type
			);

	return StartRequest(url, entiy, this);
}

/**
 * 2.8.固定电话获取认证短信
 * @param landline			电话号码
 * @param telephone_cc		国家区号,参考数组<CountryArray>
 * @param landline_ac		区号
 * @param device_id			设备唯一标识
 * @return					请求唯一标识
 */
long LSLiveChatRequestAuthorizationController::GetFixedPhone(string landline, int telephone_cc, string landline_ac,
		string device_id) {
	HttpEntiy entiy;

	if( landline.length() > 0 ) {
		entiy.AddContent(AUTHORIZATION_LANDLINE, landline.c_str());
	}

	string strCountry = GetCountryCode(telephone_cc);
	if( !strCountry.empty() ) {
		entiy.AddContent(AUTHORIZATION_LANDLINE_CC, strCountry.c_str());
	}

	if( landline_ac.length() > 0 ) {
		entiy.AddContent(AUTHORIZATION_LANDLINE_AC, landline_ac.c_str());
	}

	string url = GET_FIXED_PHONE_PATH;
	FileLog("httprequest", "LSLiveChatRequestAuthorizationController::GetFixedPhone( "
			"url : %s, "
			"landline : %s, "
			"telephone_cc : %d, "
			"landline_ac : %s, "
			")",
			url.c_str(),
			landline.c_str(),
			telephone_cc,
			landline_ac.c_str()
			);

	return StartRequest(url, entiy, this);
}

/**
 * 2.9.固定电话短信认证
 * @param verify_code		验证码
 * @return					请求唯一标识
 */
long LSLiveChatRequestAuthorizationController::VerifyFixedPhone(string verify_code) {
	HttpEntiy entiy;

	if( verify_code.length() > 0 ) {
		entiy.AddContent(AUTHORIZATION_VERIFY_CODE, verify_code.c_str());
	}

	string url = VERIFY_FIXED_PHONE_PATH;
	FileLog("httprequest", "LSLiveChatRequestAuthorizationController::VerifyFixedPhone( "
			"url : %s, "
			"verify_code : %s, "
			")",
			url.c_str(),
			verify_code.c_str()
			);

	return StartRequest(url, entiy, this);
}

/**
 * 2.10.获取token
 * @param siteType        前往的站点ID
 * @param clientType      前往的客户端标识（可无， 默认是app）
 * @param url             前往分站的目标url（可无， App端默认为无）
 * @return                    请求唯一标识
 */
long LSLiveChatRequestAuthorizationController::GetWebsiteUrlToken(OTHER_SITE_TYPE siteType, VERIFY_CLIENT_TYPE clientType, string siteUrl) {
    //char temp[16] = {0};
    HttpEntiy entiy;
    
    // siteid
    string strSite("");
    strSite = GetSiteId(siteType);
    entiy.AddContent(AUTHORIZATION_TOID, strSite);
    
    string strClient("");
    strClient = GetVerifyClientType(clientType);
    entiy.AddContent(AUTHORIZATION_CLIENT, strClient);
    
    if( siteUrl.length() > 0 ) {
        entiy.AddContent(AUTHORIZATION_URL, siteUrl.c_str());
    }
    
    string url = GET_WEBSITEURL_TOKEN_PATH;
    FileLog("httprequest", "LSLiveChatRequestAuthorizationController::GetWebsiteUrlToken( "
            "url : %s, "
            "siteType : %d, "
            "clientType : %d, "
            "siteUrl : %s, "
            ")",
            url.c_str(),
            siteType,
            clientType,
            siteUrl.c_str()
            );
    
    return StartRequest(url, entiy, this);
}

/**
 * 2.11. 添加App token
 * @param tokenId
 */
long LSLiveChatRequestAuthorizationController::SummitAppToken(string deviceId, string tokenId, string appId) {
	HttpEntiy entiy;

	if( deviceId.length() > 0 ) {
		entiy.AddContent(AUTHORIZATION_TOKEN_DEVICE_ID, deviceId.c_str());
	}

	if( tokenId.length() > 0 ) {
		entiy.AddContent(AUTHORIZATION_TOKEN_ID, tokenId.c_str());
	}
    
    if( appId.length() > 0 ) {
        entiy.AddContent(AUTHORIZATION_APP_ID, appId.c_str());
    }

	string url = SUMMIT_APP_TOKEN_PATH;
	FileLog("httprequest", "LSLiveChatRequestAuthorizationController::SummitAppToken( "
			"url : %s, "
			"deviceId : %s, "
			"tokenId : %s, "
            "appId : %s, "
			")",
			url.c_str(),
			deviceId.c_str(),
			tokenId.c_str(),
            appId.c_str()
			);

	return StartRequest(url, entiy, this);
}

/**
 * 2.12. 销毁App token
 */
long LSLiveChatRequestAuthorizationController::UnbindAppToken() {
	HttpEntiy entiy;

	string url = UNBIND_APP_TOKEN_PATH;
	FileLog("httprequest", "LSLiveChatRequestAuthorizationController::UnbindAppToken( "
			"url : %s, "
			")",
			url.c_str()
			);

	return StartRequest(url, entiy, this);
}

/**
 * 2.13. 重新激活账号
 */
long LSLiveChatRequestAuthorizationController::ReactivateMemberShip() {
    HttpEntiy entiy;
    
    string url = REACTIVATE_MEMBER_SHIP_PATH;
    FileLog("httprequest", "LSLiveChatRequestAuthorizationController::ReactivateMemberShip( "
            "url : %s, "
            ")",
            url.c_str()
            );
    
    return StartRequest(url, entiy, this);
}

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
long LSLiveChatRequestAuthorizationController::TokenLogin(
                                                string token,
                                                string memberId,
                                                string deviceId,
                                                string versioncode,
                                                string model,
                                                string manufacturer
                                                ) {
    HttpEntiy entiy;
    
    entiy.SetSaveCookie(true);
    
    if( token.length() > 0 ) {
        entiy.AddContent(AUTHORIZATION_TOKEN_ID, token.c_str());
    }
    
    if( memberId.length() > 0 ) {
        entiy.AddContent(AUTHORIZATION_MEMBER_ID, memberId.c_str());
    }

    
    if( deviceId.length() > 0 ) {
        entiy.AddContent(AUTHORIZATION_DEVICEID, deviceId.c_str());
    }
    
    if( versioncode.length() > 0 ) {
        entiy.AddContent(AUTHORIZATION_VERSIONCODE, versioncode.c_str());
    }
    
    if( model.length() > 0 ) {
        entiy.AddContent(AUTHORIZATION_MODEL, model.c_str());
    }
    
    if( manufacturer.length() > 0 ) {
        entiy.AddContent(AUTHORIZATION_MANUFACTURER, manufacturer.c_str());
    }
    
    string url = VERIFY_TOKEN_LOGIN_PATH;
    FileLog("httprequest", "TokenLogin::Login( "
            "url : %s, "
            "token : %s, "
            "memberId : %s, "
            "deviceId : %s, "
            "versioncode : %s, "
            "model : %s, "
            "manufacturer : %s "
            ")",
            url.c_str(),
            token.c_str(),
            memberId.c_str(),
            deviceId.c_str(),
            versioncode.c_str(),
            model.c_str(),
            manufacturer.c_str());
    
    return StartRequest(url, entiy, this);
}

/**
 * 2.15.可登录的站点列表
 * @param email               用户的email或id
 * @param password            登录密码
 * @return                    请求唯一标识
 */
long LSLiveChatRequestAuthorizationController::GetValidSiteId(
                                                    string email,
                                                    string password
                                                    ) {
    HttpEntiy entiy;
    
    if( email.length() > 0 ) {
        entiy.AddContent(AUTHORIZATION_EMAIL, email.c_str());
    }
    
    if( password.length() > 0 ) {
        entiy.AddContent(AUTHORIZATION_PASSWORD2, password.c_str());
    }
    
    string url = GET_VALID_SITEID_PATH;
    FileLog("httprequest", "LSLiveChatRequestAuthorizationController::GetValidSietId( "
            "email : %s, "
            "password : %s, "
            ")",
            email.c_str(),
            password.c_str()
            );
    
    return StartRequest(url, entiy, this, ChangeSite);
}
