package com.qpidnetwork.anchor.im;

import com.qpidnetwork.anchor.im.listener.IMHangoutInviteItem;

/**
 * Description:HangOut直播间邀请事件回调
 * <p>
 * Created by Harry on 2018/5/12.
 */
public interface IMHangOutInviteEventListener {
    /**
     * 10.3 接收观众邀请多人互动通知
     * @param item
     */
    void OnRecvInvitationHangoutNotice(IMHangoutInviteItem item);

}
