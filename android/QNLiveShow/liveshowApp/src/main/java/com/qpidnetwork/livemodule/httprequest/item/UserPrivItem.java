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
     * @param isSayHiPriv        SayHi权限(1:有  0:无)
     * @param isGiftFlowerPriv   是否有鲜花礼品权限
     * @param isPublicRoomPriv   是否有观看公开直播限
     */
    public UserPrivItem(
            LiveChatPrivItem liveChatPriv,
            MailPrivItem mailPriv,
            HangoutPrivItem hangoutPriv,
            boolean isSayHiPriv,
            boolean isGiftFlowerPriv,
            boolean isPublicRoomPriv
            ) {

        this.liveChatPriv = liveChatPriv;
        this.mailPriv = mailPriv;
        this.hangoutPriv = hangoutPriv;
        this.isSayHiPriv = isSayHiPriv;
        this.isGiftFlowerPriv = isGiftFlowerPriv;
        this.isPublicRoomPriv = isPublicRoomPriv;
    }

    // LiveChat权限相关
    public LiveChatPrivItem liveChatPriv;
    // 信件及意向信权限相关
    public MailPrivItem mailPriv;
    //  Hangout权限相关
    public HangoutPrivItem hangoutPriv;
    // SayHi权限(true:有  false:无)
    public boolean isSayHiPriv;
    // 是否有鲜花礼品权限
    public boolean isGiftFlowerPriv;
    // 是否有观看公开直播限
    public boolean isPublicRoomPriv;
}
