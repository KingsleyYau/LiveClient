package com.qpidnetwork.livemodule.liveshow.authorization;

/**
 * Description:
 * <p>
 * Created by Harry on 2017/12/21.
 */

public class ThirdPlatformUserInfo {
    /**
     * 第三方账户ID
     */
    public String id=null;
    /**
     * 第三方账户token
     */
    public String token=null;
    /**
     * 第三方账户注册邮箱
     */
    public String email = null;
    /**
     * 第三方账户用户名
     */
    public String name = null;

    /**
     * 第三方账户用户头像地址
     */
    public String picture = null;
    /**
     * 第三方账户用户生日信息
     */
    public String birthday = null;
    /**
     * 第三方账户用户性别
     */
    public String gender;
    /**
     *
     */
    public String locale;

    @Override
    public String toString() {
        StringBuilder builder = new StringBuilder();
        builder.append("{ThirdPlatformUserInfo");
        builder.append(" id:").append(id);
        builder.append(" token:").append(token);
        builder.append(" email:").append(email);
        builder.append(" name:").append(name);
        builder.append(" picture:").append(picture);
        builder.append(" birthday:").append(birthday);
        builder.append(" gender:").append(gender);
        builder.append(" locale:").append(locale);
        builder.append("}");
        return builder.toString();
    }
}
