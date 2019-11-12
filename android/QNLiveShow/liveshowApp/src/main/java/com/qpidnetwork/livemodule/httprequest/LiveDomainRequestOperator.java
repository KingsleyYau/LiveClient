package com.qpidnetwork.livemodule.httprequest;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Handler;
import android.os.Message;

import com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType;
import com.qpidnetwork.livemodule.httprequest.item.IntToEnumUtils;
import com.qpidnetwork.livemodule.httprequest.item.LSOtherVersionCheckItem;
import com.qpidnetwork.livemodule.httprequest.item.LSProfileItem;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum;
import com.qpidnetwork.livemodule.httprequest.item.LSValidSiteIdItem;
import com.qpidnetwork.livemodule.liveshow.authorization.DomainManager;
import com.qpidnetwork.livemodule.liveshow.authorization.IDomainListener;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;

/**
 * Created by Hunter on 18/9/29.
 */
public class LiveDomainRequestOperator {

    private Handler mHandler = null;
    private static LiveDomainRequestOperator gRequestOperate;

    /***
     * 单例初始化
     * @param context
     * @return
     */
    public static LiveDomainRequestOperator newInstance(Context context) {
        if (gRequestOperate == null) {
            gRequestOperate = new LiveDomainRequestOperator(context);
        }
        return gRequestOperate;
    }

    public static LiveDomainRequestOperator getInstance() {
        return gRequestOperate;
    }

    @SuppressLint("HandlerLeak")
    private LiveDomainRequestOperator(Context context) {
        mHandler = new Handler() {
            @Override
            public void handleMessage(Message msg) {
                super.handleMessage(msg);
                HttpRespObject response = (HttpRespObject) msg.obj;
                if(response.isSuccess){
                    // 去除回调
                    DomainManager.getInstance().unRegister((IDomainListener)response.data);
                }else{
                    HttpLccErrType errType = IntToEnumUtils.intToHttpErrorType(response.errCode);
                    switch (errType) {
                        case HTTP_LCC_ERR_NO_LOGIN: {
                            // 增加回调监听
                            DomainManager.getInstance().register((IDomainListener)response.data);
                            // 调用域名接口返回没有登录，则调用2.19.获取认证token
                            DomainManager.getInstance().getAuthToken();
                        }
                        break;
                        default: {
                            // 去除回调
                            DomainManager.getInstance().unRegister((IDomainListener)response.data);
                        }
                        break;
                    }
                }
            }
        };
    }


    /**
     * 错误公共处理
     *
     * @param isSuccess
     * @param errCode
     * @param errMsg
     * @param callback
     * @return
     */
    private boolean HandleRequestCallback(boolean isSuccess, int errCode, String errMsg, IDomainListener callback) {
        //判断错误码是否需要拦截
        boolean bFlag = false;
        HttpLccErrType errType = IntToEnumUtils.intToHttpErrorType(errCode);
        if (!isSuccess) {
            switch (errType) {
                case HTTP_LCC_ERR_NO_LOGIN: {
                    bFlag = true;
                }
                break;
            }
        }

        //切换线程处理拦截任务
        Message msg = Message.obtain();
        HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, callback);
        msg.obj = response;
        mHandler.sendMessage(msg);

        return bFlag;
    }


    /**************************************  模块处理 Authorization ********************************************/
    /**
     * 2.13.可登录的站点列表
     * @param email             用户的email或id
     * @param password           登录密码
     * @param callback
     * @return
     */
    public long GetValidSiteId(final String email, final String password, final OnGetValidSiteIdCallback callback) {

        // Domain认证改变重新调用接口
        final IDomainListener callbackLogin = new IDomainListener() {

            @Override
            public void onDomainHandle(boolean isSuccess, int errCode, String errMsg) {
                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // Domain认证成功
                    // 再次调用jni接口
                    RequestJniAuthorization.GetValidSiteId(email, password, callback);
                } else {
                    // Domain认证不成功, 回调失败
                    if(callback != null) {
                        callback.onGetValidSiteId(isSuccess, errCode, errMsg, null);
                    }
                }
            }
        };

        return  RequestJniAuthorization.GetValidSiteId(email, password, new OnGetValidSiteIdCallback() {
            @Override
            public void onGetValidSiteId(boolean isSuccess, int errCode, String errMsg, LSValidSiteIdItem[] siteIdList) {
                // 公共处理
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    if(callback != null) {
                        callback.onGetValidSiteId(isSuccess, errCode, errMsg, siteIdList);
                    }
                }


            }
        });
    }


    /**
     * 2.14.添加App token
     * @param token           app token值 (GCM ID)
     * @param appId           app唯一标识（App包名或iOS App ID，详情参考《“App ID”对照表》） (包名)
     * @param deviceId        设备id
     * @param callback
     * @return
     */
    public long AddToken(final String token, final String appId, final String deviceId, final OnRequestCallback callback) {
        // Domain认证改变重新调用接口
        final IDomainListener callbackLogin = new IDomainListener() {

            @Override
            public void onDomainHandle(boolean isSuccess, int errCode, String errMsg) {
                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // Domain认证成功
                    // 再次调用jni接口
                    RequestJniAuthorization.AddToken(token, appId, deviceId, callback);
                } else {
                    // Domain认证不成功, 回调失败
                    if(callback != null) {
                        callback.onRequest(isSuccess, errCode, errMsg);
                    }
                }
            }
        };

        return RequestJniAuthorization.AddToken(token, appId, deviceId, new OnRequestCallback() {
            @Override
            public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                // 公共处理
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    if(callback != null) {
                        callback.onRequest(isSuccess, errCode, errMsg);
                    }
                }

            }
        });
    }

    /**
     * 2.15.销毁App token
     * @param callback
     * @return
     */
    public long DestroyToken(final OnRequestCallback callback) {
        // Domain认证改变重新调用接口
        final IDomainListener callbackLogin = new IDomainListener() {

            @Override
            public void onDomainHandle(boolean isSuccess, int errCode, String errMsg) {
                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // Domain认证成功
                    // 再次调用jni接口
                    RequestJniAuthorization.DestroyToken(callback);
                } else {
                    // Domain认证不成功, 回调失败
                    if(callback != null) {
                        callback.onRequest(isSuccess, errCode, errMsg);
                    }
                }
            }
        };

        return RequestJniAuthorization.DestroyToken(new OnRequestCallback() {
            @Override
            public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                // 公共处理
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    if(callback != null) {
                        callback.onRequest(isSuccess, errCode, errMsg);
                    }
                }
            }
        });
    }

//    /**
//     * 2.16.找回密码
//     * @param sendMail           用户注册的邮箱
//     * @param checkCode          验证码（ver3.0起）
//     * @param callback
//     * @return
//     */
//    public long FindPassword(final String sendMail, final String checkCode, final OnRequestCallback callback) {
//        return RequestJniAuthorization.FindPassword(sendMail, checkCode, new OnRequestCallback() {
//            @Override
//            public void onRequest(boolean isSuccess, int errCode, String errMsg) {
//
//            }
//        });
//    }

    /**
     * 2.17.修改密码
     * @param passwordNew          新密码
     * @param passwordOld          旧密码
     * @param callback
     * @return
     */
    public long ChangePassword(final String passwordNew, final String passwordOld, final OnRequestCallback callback) {
        // Domain认证改变重新调用接口
        final IDomainListener callbackLogin = new IDomainListener() {

            @Override
            public void onDomainHandle(boolean isSuccess, int errCode, String errMsg) {
                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // Domain认证成功
                    // 再次调用jni接口
                    RequestJniAuthorization.ChangePassword(passwordNew, passwordOld, callback);
                } else {
                    // Domain认证不成功, 回调失败
                    if(callback != null) {
                        callback.onRequest(isSuccess, errCode, errMsg);
                    }
                }
            }
        };

        return RequestJniAuthorization.ChangePassword(passwordNew, passwordOld, new OnRequestCallback() {
            @Override
            public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                // 公共处理
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    if(callback != null) {
                        callback.onRequest(isSuccess, errCode, errMsg);
                    }
                }
            }
        });
    }

    /**
     * 2.18.token登录认证
     * @param token
     * @param memberId
     * @param deviceId
     * @param versionCode
     * @param model
     * @param manufacturer
     * @param callback
     * @return
     */
    public long DoLogin(final String token, final String memberId, final String deviceId, final String versionCode, final String model, final String manufacturer, final OnRequestCallback callback) {
        // Domain认证改变重新调用接口
        final IDomainListener callbackLogin = new IDomainListener() {

            @Override
            public void onDomainHandle(boolean isSuccess, int errCode, String errMsg) {
                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // Domain认证成功
                    // 再次调用jni接口
                    RequestJniAuthorization.DoLogin(token, memberId, deviceId, versionCode, model, manufacturer, callback);
                } else {
                    // Domain认证不成功, 回调失败
                    if(callback != null) {
                        callback.onRequest(isSuccess, errCode, errMsg);
                    }
                }
            }
        };

        return RequestJniAuthorization.DoLogin(token, memberId, deviceId, versionCode, model, manufacturer, new OnRequestCallback() {
            @Override
            public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                // 公共处理
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    if(callback != null) {
                        callback.onRequest(isSuccess, errCode, errMsg);
                    }
                }
            }
        });
    }


    /**
     * 2.23.提交用户头像
     * @param callback
     * @return
     */
    public long UploadUserPhoto(final String photoName, final OnRequestCallback callback) {
        // Domain认证改变重新调用接口
        final IDomainListener callbackLogin = new IDomainListener() {

            @Override
            public void onDomainHandle(boolean isSuccess, int errCode, String errMsg) {
                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // Domain认证成功
                    // 再次调用jni接口
                    RequestJniAuthorization.UploadUserPhoto(photoName, callback);
                } else {
                    // Domain认证不成功, 回调失败
                    if(callback != null) {
                        callback.onRequest(isSuccess, errCode, errMsg);
                    }
                }
            }
        };

        return RequestJniAuthorization.UploadUserPhoto(photoName, new OnRequestCallback() {
            @Override
            public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                // 公共处理
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    if(callback != null) {
                        callback.onRequest(isSuccess, errCode, errMsg);
                    }
                }
            }
        });
    }



    /**************************************  模块处理 other ********************************************/
    /**
     * 6.18.查询个人信息
     * @param callback
     * @return
     */
    public long GetMyProfile(final OnGetMyProfileCallback callback) {

        // Domain认证改变重新调用接口
        final IDomainListener callbackLogin = new IDomainListener() {

            @Override
            public void onDomainHandle(boolean isSuccess, int errCode, String errMsg) {
                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // Domain认证成功
                    // 再次调用jni接口
                    RequestJniOther.GetMyProfile( callback);
                } else {
                    // Domain认证不成功, 回调失败
                    if(callback != null) {
                        callback.onGetMyProfile(isSuccess, errCode, errMsg, null);
                    }
                }
            }
        };

        return RequestJniOther.GetMyProfile(new OnGetMyProfileCallback() {
            @Override
            public void onGetMyProfile(boolean isSuccess, int errno, String errmsg, LSProfileItem item) {

                // 公共处理
                boolean bFlag = HandleRequestCallback(isSuccess, errno, errmsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    if(callback != null) {
                        callback.onGetMyProfile(isSuccess, errno, errmsg, item);
                    }
                }
            }
        });
    }

    /**
     * 6.19.修改个人信息
     * @param weight		体重
     * @param height		身高
     * @param language		语言
     * @param ethnicity		人种
     * @param religion		宗教
     * @param education		教育程度
     * @param profession	职业
     * @param income		收入情况
     * @param children		子女状况
     * @param smoke			吸烟情况
     * @param drink			喝酒情况
     * @param resume		个人简介
     * @param interest		兴趣爱好
     * @param zodiac		星座
     * @return				请求唯一标识
     */
    public long UpdateProfile(final LSRequestEnum.Weight weight, final LSRequestEnum.Height height,
                              final LSRequestEnum.Language language, final LSRequestEnum.Ethnicity ethnicity,
                              final LSRequestEnum.Religion religion, final LSRequestEnum.Education education,
                              final LSRequestEnum.Profession profession, final LSRequestEnum.Income income,
                              final LSRequestEnum.Children children, final LSRequestEnum.Smoke smoke, final LSRequestEnum.Drink drink,
                              final String resume, final String[] interest, final LSRequestEnum.Zodiac zodiac,
                              final OnUpdateMyProfileCallback callback) {

        // Domain认证改变重新调用接口
        final IDomainListener callbackLogin = new IDomainListener() {

            @Override
            public void onDomainHandle(boolean isSuccess, int errCode, String errMsg) {
                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // Domain认证成功
                    // 再次调用jni接口
                    RequestJniOther.UpdateProfile(weight, height, language, ethnicity, religion, education, profession, income, children, smoke, drink, resume, interest, zodiac, callback);
                } else {
                    // Domain认证不成功, 回调失败
                    if(callback != null) {
                        callback.onUpdateMyProfile(isSuccess, errCode, errMsg, false);
                    }
                }
            }
        };

        return RequestJniOther.UpdateProfile(weight, height, language, ethnicity, religion, education, profession, income, children, smoke, drink, resume, interest, zodiac, new OnUpdateMyProfileCallback() {
            @Override
            public void onUpdateMyProfile(boolean isSuccess, int errno, String errmsg, boolean rsModified) {

                // 公共处理
                boolean bFlag = HandleRequestCallback(isSuccess, errno, errmsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    if(callback != null) {
                        callback.onUpdateMyProfile(isSuccess, errno, errmsg, rsModified);
                    }
                }
            }
        });
    }

    /**
     * 6.20.检查客户端更新
     * @param currVer	当前客户端内部版本号
     * @param callback
     * @return
     */
    public long VersionCheck(final int currVer, final OnOtherVersionCheckCallback callback) {

        // Domain认证改变重新调用接口
        final IDomainListener callbackLogin = new IDomainListener() {

            @Override
            public void onDomainHandle(boolean isSuccess, int errCode, String errMsg) {
                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // Domain认证成功
                    // 再次调用jni接口
                    RequestJniOther.VersionCheck(currVer, callback);
                } else {
                    // Domain认证不成功, 回调失败
                    if(callback != null) {
                        callback.onOtherVersionCheck(isSuccess, errCode, errMsg, null);
                    }
                }
            }
        };

        return RequestJniOther.VersionCheck(currVer, new OnOtherVersionCheckCallback() {
            @Override
            public void onOtherVersionCheck(boolean isSuccess, int errno, String errmsg, LSOtherVersionCheckItem item) {
                // 公共处理
                boolean bFlag = HandleRequestCallback(isSuccess, errno, errmsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    if(callback != null) {
                        callback.onOtherVersionCheck(isSuccess, errno, errmsg, item);
                    }
                }
            }
        });
    }

    /**
     * 6.21.开始编辑简介触发计时
     * @param callback
     * @return
     */
    public long StartEditResume(final OnRequestCallback callback) {

        // Domain认证改变重新调用接口
        final IDomainListener callbackLogin = new IDomainListener() {

            @Override
            public void onDomainHandle(boolean isSuccess, int errCode, String errMsg) {
                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // Domain认证成功
                    // 再次调用jni接口
                    RequestJniOther.StartEditResume(callback);
                } else {
                    // Domain认证不成功, 回调失败
                    if(callback != null) {
                        callback.onRequest(isSuccess, errCode, errMsg);
                    }
                }
            }
        };

        return RequestJniOther.StartEditResume(new OnRequestCallback() {
            @Override
            public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                // 公共处理
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    if(callback != null) {
                        callback.onRequest(isSuccess, errCode, errMsg);
                    }
                }
            }
        });
    }

    public long PhoneInfo(final  String manId, final  int verCode, final  String verName, final  RequestJniOther.LSActionType action, final  int siteId
            , final double density, final int width, final int height, final String lineNumber, final String simOptName, final String simOpt, final String simCountryIso
            , final String simState, final int phoneType, final int networkType, final String deviceId
            , final OnRequestCallback callback) {
        // Domain认证改变重新调用接口
        final IDomainListener callbackLogin = new IDomainListener() {

            @Override
            public void onDomainHandle(boolean isSuccess, int errCode, String errMsg) {
                // 公共处理
                HandleRequestCallback(isSuccess, errCode, errMsg, this);
                if (isSuccess) {
                    // Domain认证成功
                    // 再次调用jni接口
                    RequestJniOther.PhoneInfo(manId, verCode, verName, action, siteId, density, width, height, lineNumber, simOptName, simOpt, simCountryIso, simState, phoneType, networkType, deviceId, callback);
                } else {
                    // Domain认证不成功, 回调失败
                    if(callback != null){
                        callback.onRequest(isSuccess, errCode, errMsg);
                    }
                }
            }
        };

        return RequestJniOther.PhoneInfo(manId, verCode, verName, action, siteId, density, width, height, lineNumber, simOptName, simOpt, simCountryIso, simState, phoneType, networkType, deviceId, new OnRequestCallback() {
            @Override
            public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                // 公共处理
                boolean bFlag = HandleRequestCallback(isSuccess, errCode, errMsg, callbackLogin);
                if (bFlag) {
                    // 已经匹配处理, 等待回调
                } else {
                    // 没有匹配处理, 直接回调
                    if(callback != null) {
                        callback.onRequest(isSuccess, errCode, errMsg);
                    }
                }
            }
        });

    }

}
