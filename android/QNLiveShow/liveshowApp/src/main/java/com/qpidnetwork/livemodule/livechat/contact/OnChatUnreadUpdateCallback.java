package com.qpidnetwork.livemodule.livechat.contact;

/**
 * Created by Hardy on 2018/11/20.
 * 主界面、侧滑菜单栏的未读消息更新
 * <p>
 * 三种状态：
 * 1、有联系人未读消息，显示未读数字
 * 2、仅有邀请消息，则显示未读红点
 * 3、否则不显示
 */
public interface OnChatUnreadUpdateCallback {

    /**
     * 优先判断 unreadChatCount
     * @param unreadChatCount chat 未读消息数 > 0，显示未读数字
     * @param unreadInviteCount  邀请数 > 0，显示小红点
     */
    void onUnreadUpdate(int unreadChatCount, int unreadInviteCount);
}
