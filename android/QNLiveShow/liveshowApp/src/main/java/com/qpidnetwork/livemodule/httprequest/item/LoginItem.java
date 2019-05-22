package com.qpidnetwork.livemodule.httprequest.item;

import com.qpidnetwork.livemodule.livechathttprequest.item.LCRequestEnum.LivechatInviteRiskType;

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
     * @param gaUid         GA统计用户ID
     * @param isHangoutRisk 多人互动风控标识（true：有风控，false：无）
	 * @param userPriv      用户权限相关
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
//            String qnMainAdUrl,
//            String qnMainAdTitle,
//            String qnMainAdId,
            String gaUid,
            String sessionId,
            boolean livechat,
            int livechatInvite,
            boolean isHangoutRisk,
            UserPrivItem userPriv
            ) {
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
//		this.qnMainAdUrl = qnMainAdUrl;
//        this.qnMainAdTitle = qnMainAdTitle;
//        this.qnMainAdId = qnMainAdId;
        this.gaUid = gaUid;

        this.sessionId = sessionId;
        this.livechat = livechat;
        if( livechatInvite < 0 || livechatInvite >= LivechatInviteRiskType.values().length ) {
            this.livechatInvite = LivechatInviteRiskType.UNLIMITED;
        } else {
            this.livechatInvite = LivechatInviteRiskType.values()[livechatInvite];
        }
        this.isHangoutRisk = isHangoutRisk;

        this.userPriv = userPriv;
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
//    public String qnMainAdUrl;
//    public String qnMainAdTitle;
//    public String qnMainAdId;
    public String gaUid;

    //LiveChat相关
    public String  sessionId; //= "dj649q56iuc5k7u3nvqc05umpu";
    public boolean livechat;// = true;
    public LivechatInviteRiskType livechatInvite;// = LivechatInviteRiskType.UNLIMITED;

    // Hangout相关
    public boolean isHangoutRisk;

    // 用户权限相关
    public UserPrivItem userPriv;

    //本地默认初始化，解决代码移植问题
    public boolean photosend = false;
    public boolean photoreceived = false;
    public boolean videoreceived = true;    //edit by Jagger 2019-5-6 改为true, 接口没返回对应的值，改为默认可接收LiveChat视频

    public boolean premit = true;
    public boolean ladyprofile = true;
    public boolean camshare = false;

    public boolean admirer = true;
    public boolean bpemf = true;
    public int rechargeCredit = 0; //默认关闭自动充值权限

}
