package com.qpidnetwork.livemodule.httprequest.item;


/**
 * Created by Hunter Mun on 2019/3/19.
 */

public class MailPrivItem {

	public MailPrivItem(){

	}

    /**
     *  信件及意向信权限相关
     * @param userSendMailPriv              是否有权限发送信件
     * @param userSendMailImgPriv           发送照片相关
     */
    public MailPrivItem(
            boolean userSendMailPriv,
            UserSendMailPrivItem userSendMailImgPriv
            ) {

        this.userSendMailPriv = userSendMailPriv;
        this.userSendMailImgPriv = userSendMailImgPriv;
    }

    // 是否有权限发送信件
    public boolean userSendMailPriv;
    // 发送照片相关
    public UserSendMailPrivItem userSendMailImgPriv;

}
