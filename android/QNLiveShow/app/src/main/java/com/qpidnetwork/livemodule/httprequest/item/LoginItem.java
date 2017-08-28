package com.qpidnetwork.livemodule.httprequest.item;

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
	 * @param level
	 * @param experience
	 * @param photoUrl
	 */
    public LoginItem(
            String userId,
            String token,
            String nickName,
            int level,
            int experience,
            String photoUrl) {
        this.userId = userId;
        this.token = token;
        this.nickName = nickName;
        this.level = level;
        this.experience = experience;
        this.photoUrl = photoUrl;
    }

    public String userId;
    public String token;
    public String nickName;
    public int level;
    public int experience;
    public String photoUrl;
}
