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
	 * @param isPushAd
	 * @param svrList
	 * @param userType
     * @param qnMainAdUrl   QN主界面广告浮层的URL（可无，无则表示不弹广告）
     * @param qnMainAdTitle QN主界面广告浮层的标题（可无）
     * @param qnMainAdId    QN主界面广告浮层的ID（可无，无则表示不弹广告）
	 */
    public LoginItem(
            String userId,
            String token,
            String nickName,
            int level,
            int experience,
            String photoUrl,
            boolean isPushAd,
            ServerItem[] svrList,
            int userType,
            String qnMainAdUrl,
            String qnMainAdTitle,
            String qnMainAdId) {
        this.userId = userId;
        this.token = token;
        this.nickName = nickName;
        this.level = level;
        this.experience = experience;
        this.photoUrl = photoUrl;
        this.isPushAd = isPushAd;
        this.svrList = svrList;
		if( userType < 0 || userType >= UserType.values().length ) {
			this.userType = UserType.Unknown;
		} else {
			this.userType = UserType.values()[userType];
		}
		this.qnMainAdUrl = qnMainAdUrl;
        this.qnMainAdTitle = qnMainAdTitle;
        this.qnMainAdId = qnMainAdId;
    }

    public String userId;
    public String token;
    public String nickName;
    public int level;
    public int experience;
    public String photoUrl;
    public boolean isPushAd;
    public ServerItem[] svrList;
    public UserType userType;
    public String qnMainAdUrl;
    public String qnMainAdTitle;
    public String qnMainAdId;
}
