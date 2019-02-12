package com.qpidnetwork.qnbridgemodule.bean;

import android.graphics.drawable.Drawable;

import java.io.File;

/**
 * 主要用于不同模块传递站点配置信息
 * Created by Hunter on 18/7/18.
 */

public class WebSiteBean {

    private int siteId; 			// 站点Id
    private String appSiteHost;		// app 使用服务器地址
    private String siteShortName;	// 站点名称简写
    private String siteKey; 		// 站点名字 (与WebSiteType一致)
    private String siteName; 		// 站点名字 (带.COM)
    private String siteDesc;		// 站点描述
    private String webSiteHost; 	// 网站 对应服务器地址
    private int siteTheme; 			// 当前站点使用主题资源Id
    private int siteColor;			// 当前站点使用主题颜色
    private String cachePath; 		// 缓存路径
    private String databaseName;	// 数据库名称
    private String facebookLink;	// facebook关注
    private String helpLink;		// 帮助
    private String bounsLink; 		// 积分链接
    private String termsLink;		// 用户条款
    private String privacyLink;		// 私密条款
    private String membershipLink;	//会员月费相关

    private Drawable siteDrawable;  //站点对应头像

    public WebSiteBean(
            int siteId,
            String appSiteHost,
            String siteShortName,
            String siteKey,
            String siteName,
            String siteDesc,
            String webSiteHost,
            int siteTheme,
            int siteColor,
            String cachePath,
            String databaseName,
            String facebookLink,
            String helpLink,
            String bounsLink,
            String termsLink,
            String privacyLink,
            String membershipLink,
            Drawable siteDrawable
    ) {
        this.siteId = siteId;
        this.appSiteHost = appSiteHost;
        this.siteShortName = siteShortName;
        this.siteKey = siteKey;
        this.siteName = siteName;
        this.siteDesc = siteDesc;
        this.webSiteHost = webSiteHost;
        this.siteTheme = siteTheme;
        this.siteColor = siteColor;
        this.cachePath = cachePath;
        this.databaseName = databaseName;
        this.facebookLink = facebookLink;
        this.helpLink = helpLink;
        this.bounsLink = bounsLink;
        this.termsLink = termsLink;
        this.privacyLink = privacyLink;
        this.membershipLink = membershipLink;
        this.siteDrawable = siteDrawable;

        File file = new File(cachePath);
        if( !file.exists() ) {
            file.mkdirs();
        }
    }

    public String getAppSiteHost() {
        return appSiteHost;
    }

    public void setAppSiteHost(String appSiteHost) {
        this.appSiteHost = appSiteHost;
    }

    public int getSiteId() {
        return siteId;
    }

    public void setSiteId(int siteId) {
        this.siteId = siteId;
    }

    public String getWebSiteHost() {
        return webSiteHost;
    }

    public void setWebSiteHost(String webSiteHost) {
        this.webSiteHost = webSiteHost;
    }

    public String getSiteShortName() {
        return siteShortName;
    }

    public void setSiteShortName(String siteShortName) {
        this.siteShortName= siteShortName;
    }

    public String getSiteKey() {
        return siteKey;
    }

    public void setSiteKey(String siteKey) {
        this.siteKey = siteKey;
    }

    public String getSiteName() {
        return siteName;
    }

    public void setSiteName(String siteName) {
        this.siteName = siteName;
    }

    public String getSiteDesc() {
        return siteDesc;
    }

    public void setSiteDesc(String siteDesc) {
        this.siteDesc = siteDesc;
    }

    public String getCachePath() {
        return cachePath;
    }

    public void setCachePath(String cachePath) {
        this.cachePath = cachePath;
    }

    public String getDatabaseName() {
        return databaseName;
    }

    public void setDatabaseName(String databaseName) {
        this.databaseName = databaseName;
    }

    public int getSiteTheme() {
        return siteTheme;
    }

    public void setSiteTheme(int siteTheme) {
        this.siteTheme = siteTheme;
    }

    public int getSiteColor() {
        return siteColor;
    }

    public void setSiteColor(int siteColor) {
        this.siteColor = siteColor;
    }

    public String getFacebookLink() {
        return facebookLink;
    }

    public void setFacebookLink(String facebookLink) {
        this.facebookLink = facebookLink;
    }

    public String getHelpLink() {
        return helpLink;
    }

    public void setHelpLink(String helpLink) {
        this.helpLink = helpLink;
    }

    public String getBounsLink() {
        return bounsLink;
    }

    public void setBounsLink(String bounsLink) {
        this.bounsLink = bounsLink;
    }

    public String getTermsLink() {
        return termsLink;
    }

    public void setTermsLink(String termsLink) {
        this.termsLink = termsLink;
    }

    public String getPrivacyLink() {
        return privacyLink;
    }

    public void setPrivacyLink(String privacyLink) {
        this.privacyLink = privacyLink;
    }

    public String getMembershipLink() {
        return membershipLink;
    }

    public void setMembershipLink(String membershipLink) {
        this.membershipLink = membershipLink;
    }

    public Drawable getSiteDrawable() {
        return siteDrawable;
    }

    public void setSiteDrawable(Drawable drawable) {
        this.siteDrawable = drawable;
    }

}
