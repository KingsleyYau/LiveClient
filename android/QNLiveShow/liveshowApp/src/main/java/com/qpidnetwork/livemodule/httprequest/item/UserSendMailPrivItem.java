package com.qpidnetwork.livemodule.httprequest.item;


/**
 * Created by Hunter Mun on 2019/3/19.
 */

public class UserSendMailPrivItem {

	public UserSendMailPrivItem(){

	}

    /**
     *  发送照片相关
     * @param isPriv              发送照片权限（Normal：正常，OnlyFree：只能发免费，OnlyPayment：只能发付费，NoSend：不能发照片）
     * @param maxImg              单封信件可发照片最大数
     * @param postStampMsg        邮票回复/发送照片提示
     * @param coinMsg             信用点回复/发送照片提示
     * @param quickPostStampMsg        邮票快速回复照片提示
     * @param quickCoinMsg             信用点快速回复照片提示
     */
    public UserSendMailPrivItem(
            int isPriv,
            int maxImg,
            String postStampMsg,
            String coinMsg,
            String quickPostStampMsg,
            String quickCoinMsg
            ) {
        if( isPriv < 0 || isPriv >= SendImgRiskType.values().length ) {
            this.isPriv = SendImgRiskType.Normal;
        } else {
            this.isPriv = SendImgRiskType.values()[isPriv];
        }
        this.maxImg = maxImg;
        this.postStampMsg = postStampMsg;
        this.coinMsg = coinMsg;
        this.quickPostStampMsg = quickPostStampMsg;
        this.quickCoinMsg = quickCoinMsg;
    }

    // 发送照片权限（Normal：正常，OnlyFree：只能发免费，OnlyPayment：只能发付费，NoSend：不能发照片）
    public SendImgRiskType isPriv;
    // 单封信件可发照片最大数
    public int maxImg;
    // 邮票回复/发送照片提示
    public String postStampMsg;
    // 信用点回复/发送照片提示
    public String coinMsg;
    // 邮票快速回复照片提示
    public String quickPostStampMsg;
    // 信用点快速回复照片提示
    public String quickCoinMsg;
}
