package com.qpidnetwork.livemodule.liveshow.authorization;

/**
 * Created by Hunter Mun on 2017/12/25.
 */

public interface ILoginManager {

    /**
     * 自动登录接口
     * @return
     */
    public boolean Autologin();

    /**
     * 邮箱登录（三方绑定邮箱登录）
     * @param email
     * @param password
     * @return
     */
    public boolean login(String email, String password);

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
    public boolean register(String email, String password, int gender, String nickName, String birthday,
                            String inviteCode);

}
