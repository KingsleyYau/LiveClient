package com.qpidnetwork.anchor.httprequest.item;

/**
 * Created by Hunter Mun on 2017/5/17.
 */

public class LoginItem {
	
	public LoginItem(){
		
	}

	/**
	 * 登录信息bean
	 * @param userId
	 * @param token
	 * @param nickName
	 * @param photoUrl
	 */
    public LoginItem(
            String userId,
            String token,
            String nickName,
            String photoUrl) {
        this.userId = userId;
        this.token = token;
        this.nickName = nickName;
        this.photoUrl = photoUrl;
    }

    public String userId;
    public String token;
    public String nickName;
    public String photoUrl;
}
