package com.qpidnetwork.httprequest.item;

import java.io.Serializable;

/**
 * Created by Hunter Mun on 2017/5/17.
 */

public class LoginItem implements Serializable{
	
	public LoginItem(){
		
	}

    /**
     * 登录返回Bean
     * @param userId		 用户ID
     * @param sessionId		 跨服务器身份验证Cookie
     * @param nickName   	 昵称
     * @param level 		 会员等级
     * @param country  		 国家
     * @param photoUrl		 头像Url
     * @param sign			 签名
     * @param isAnchor		 是否主播
     * @param needModifyInfo 是否需要修改资料
     */
    public LoginItem(
            String userId,
            String sessionId,
            String nickName,
            int level,
            String country,
            String photoUrl,
            String sign,
            boolean isAnchor,
            boolean needModifyInfo) {
        this.userId = userId;
        this.sessionId = sessionId;
        this.nickName = nickName;
        this.level = level;
        this.country = country;
        this.photoUrl = photoUrl;
        this.sign = sign;
        this.isAnchor = isAnchor;
        this.needModifyInfo = needModifyInfo;
    }

    public String userId;
    public String sessionId;
    public String nickName;
    public int level;			
    public String country;
    public String photoUrl;
    public String sign;
    public boolean isAnchor;
    public boolean needModifyInfo;
}
