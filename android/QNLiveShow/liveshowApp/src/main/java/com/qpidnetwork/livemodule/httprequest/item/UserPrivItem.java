package com.qpidnetwork.livemodule.httprequest.item;


/**
 * Created by Hunter Mun on 2019/3/19.
 */

public class UserPrivItem {

	public UserPrivItem(){

	}

    /**
     *  用户权限相关（LiveCha，信件及意向信，Hangout）
     * @param liveChatPriv       LiveChat权限相关
     * @param mailPriv           信件及意向信权限相关
     * @param hangoutPriv        Hangout权限相关
     */
    public UserPrivItem(
            LiveChatPrivItem liveChatPriv,
            MailPrivItem mailPriv,
            HangoutPrivItem hangoutPriv
            ) {

        this.liveChatPriv = liveChatPriv;
        this.mailPriv = mailPriv;
        this.hangoutPriv = hangoutPriv;
    }

    // LiveChat权限相关
    public LiveChatPrivItem liveChatPriv;
    // 信件及意向信权限相关
    public MailPrivItem mailPriv;
    //  Hangout权限相关
    public HangoutPrivItem hangoutPriv;
}
