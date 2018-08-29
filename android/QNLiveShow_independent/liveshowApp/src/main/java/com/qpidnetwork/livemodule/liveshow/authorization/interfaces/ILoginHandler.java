package com.qpidnetwork.livemodule.liveshow.authorization.interfaces;

import android.app.Activity;

import com.qpidnetwork.livemodule.httprequest.item.GenderType;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.liveshow.model.LoginAccount;

/**
 * 后台登录
 * Created by Hunter Mun on 2017/12/25.
 */

public interface ILoginHandler {

    /**
     * 跟否自动登录
     * @return
     */
    public boolean isCanAutoLogin();

    /**
     * 自动登录接口
     * @return
     */
    public void autoLogin();

    /**
     * 邮箱登录
     * @param email
     * @param password
     * @return
     */
    public boolean login(String email, String password);

    /**
     * 第三方受权登录
     * @param activity
     * @return
     */
    public boolean authorizedLogin(Activity activity);

    /**
     * 登录注销
     * @param isManal      是否手动
     * @return
     */
    public boolean logout(boolean isManal);

    /**
     * 注册接口
     * @param email
     * @param password  可为空（区分是否邮箱注册）
     * @param gender
     * @param nickName
     * @param birthday
     * @param inviteCode
     * @return
     */
    public boolean register(String email, String password, GenderType gender, String nickName, String birthday,
                            String inviteCode , final onRegisterListener listener);

    /**
     * 注册登录事件监听器
     * @param listener
     */
    public void addLoginListener(ILoginHandlerListener listener);

    /**
     * 反注册登录事件监听器
     * @param listener
     */
    public void removeLoginListener(ILoginHandlerListener listener);

    /**
     * 登录结果
     * @param isSuccess
     * @param errCode
     * @param errMsg
     * @param item
     */
    public void onLoginResult(boolean isSuccess, int errCode, String errMsg, LoginItem item);

    /**
     * 保存登录信息
     */
    public void saveAccount();

    /**
     * 获取登录状态信息
     * @return
     */
    public LoginAccount getLoginAccount();

    /**
     * 获取登录成功返回sessionId
     * @return
     */
    public String getSessionId();

    /**
     * 取第三方平台用户信息
     * @return
     */
    public Object getAuthorizedUserInfo();

    /**
     * 销毁
     */
    public void destroy();
}
