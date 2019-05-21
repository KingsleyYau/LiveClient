package com.qpidnetwork.livemodule.httprequest.item;

import com.qpidnetwork.livemodule.livechathttprequest.item.LCRequestEnum.LivechatInviteRiskType;

/**
 * Created by Hunter Mun on 2017/5/17.
 */

public class LiveChatPrivItem {

	public LiveChatPrivItem(){

	}

	/**
	 * LiveChat权限相关
     * @param isLiveChatPriv                LiveChat聊天总权限（0：禁止，1：正常，默认：1）
     * @param livechatInvite                聊天邀请限制类型
	 * @param isSendLiveChatPhotoPriv       观众发送私密照权限（0：禁止，1：正常，默认：1）
     * @param isSendLiveChatVoicePriv       观众发送语音权限（0：禁止，1：正常，默认：1）
     */
    public LiveChatPrivItem(
            boolean isLiveChatPriv,
            int livechatInvite,
            boolean isSendLiveChatPhotoPriv,
            boolean isSendLiveChatVoicePriv
            ) {

        this.isLiveChatPriv = isLiveChatPriv;
        if( livechatInvite < 0 || livechatInvite >= LivechatInviteRiskType.values().length ) {
            this.livechatInvite = LivechatInviteRiskType.UNLIMITED;
        } else {
            this.livechatInvite = LivechatInviteRiskType.values()[livechatInvite];
        }
        this.isSendLiveChatPhotoPriv = isSendLiveChatPhotoPriv;
        this.isSendLiveChatVoicePriv = isSendLiveChatVoicePriv;
    }

    public boolean isLiveChatPriv;// = true;
    public LivechatInviteRiskType livechatInvite;// = LivechatInviteRiskType.UNLIMITED;
    public boolean isSendLiveChatPhotoPriv;
    public boolean isSendLiveChatVoicePriv;



}
