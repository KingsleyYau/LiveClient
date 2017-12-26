package com.qpidnetwork.livemodule.liveshow.home;

/**
 * Description:
 * <p>
 * Created by Harry on 2017/10/31.
 */

public class BannerItem {
    public String bannerImgUrl = null;
    public String bannerLinkUrl = null;
    public String bannerName = null;

    public BannerItem(){

    }

    public BannerItem(String bannerImgUrl,String bannerLinkUrl, String bannerName){
        this.bannerImgUrl = bannerImgUrl;
        this.bannerLinkUrl = bannerLinkUrl;
        this.bannerName = bannerName;
    }
}
