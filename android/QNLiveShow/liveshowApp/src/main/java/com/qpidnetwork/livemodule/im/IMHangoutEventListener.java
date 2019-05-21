package com.qpidnetwork.livemodule.im;

import com.qpidnetwork.livemodule.im.listener.IMClientListener;
import com.qpidnetwork.livemodule.im.listener.IMDealInviteItem;
import com.qpidnetwork.livemodule.im.listener.IMHangoutCountDownItem;
import com.qpidnetwork.livemodule.im.listener.IMHangoutInviteItem;
import com.qpidnetwork.livemodule.im.listener.IMHangoutRecommendItem;
import com.qpidnetwork.livemodule.im.listener.IMHangoutRoomItem;
import com.qpidnetwork.livemodule.im.listener.IMMessageItem;
import com.qpidnetwork.livemodule.im.listener.IMRecvEnterRoomItem;
import com.qpidnetwork.livemodule.im.listener.IMRecvKnockRequestItem;
import com.qpidnetwork.livemodule.im.listener.IMRecvLeaveRoomItem;

public interface IMHangoutEventListener {

    /**
     * 10.1.接收主播推荐好友通知
     * @param item    主播推荐好友信息
     */
    public void OnRecvRecommendHangoutNotice(IMHangoutRecommendItem item);

    /**
     * 10.2.接收主播回复观众多人互动邀请通知x
     * @param item    主播回复观众多人互动邀请信息
     */
    public void OnRecvDealInvitationHangoutNotice(IMDealInviteItem item);

    /**
     * 10.3.观众新建/进入多人互动直播间
     * @param item    主播回复观众多人互动邀请信息
     */
    public void OnEnterHangoutRoom(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMHangoutRoomItem item);

    /**
     * 10.4.退出多人互动直播间
     */
    public void OnLeaveHangoutRoom(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg);

    /**
     * 10.5.接收观众/主播进入多人互动直播间通知
     * @param item    接收观众/主播进入多人互动直播间信息
     */
    public void OnRecvEnterHangoutRoomNotice(IMRecvEnterRoomItem item);

    /**
     * 10.6.接收观众/主播退出多人互动直播间通知
     * @param item    接收观众/主播退出多人互动直播间信息
     */
    public void OnRecvLeaveHangoutRoomNotice(IMRecvLeaveRoomItem item);

    /**
     * 10.7.发送多人互动直播间礼物消息
     */
    public void OnSendHangoutGift(boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMMessageItem msgItem, double credit);

    /**
     * 10.8.接收多人互动直播间礼物通知
     * @param item    接收多人互动直播间礼物信息
     */
    public void OnRecvHangoutGiftNotice(IMMessageItem item);

    /**
     * 10.9.接收主播敲门通知
     * @param item    接收主播敲门信息
     */
    public void OnRecvKnockRequestNotice(IMRecvKnockRequestItem item);

    /**
     * 10.10.接收多人互动余额不足导致主播将要离开的通知
     * @param item    接收多人互动余额不足导致主播将要离开的信息
     */
    public void OnRecvLackCreditHangoutNotice(IMRecvLeaveRoomItem item);

    /**
     * 10.11.多人互动观众开始/结束视频互动
     */
    public void OnControlManPushHangout(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, String[] manPushUrl);

    /**
     * 10.12.发送多人互动直播间文本消息回调
     * @param errType
     * @param errMsg
     * @param msgItem
     */
    public void OnSendHangoutRoomMsg(boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMMessageItem msgItem);

    /**
     * 10.13.接收直播间文本消息
     * @param item
     */
    public void OnRecvHangoutRoomMsg(IMMessageItem item);

    /**
     * 10.14.接收进入多人互动直播间倒数通知
     * @param item
     */
    public void OnRecvAnchorCountDownEnterHangoutRoomNotice(IMHangoutCountDownItem item);

    /**
     * 10.15.接收主播Hang-out邀请通知
     * @param item
     */
    public void OnRecvHandoutInviteNotice(IMHangoutInviteItem item);

    /**
     * 10.16.接收Hangout直播间男士信用点不足两个周期通知
     * @param roomId		直播间ID
     * @param errType		错误码
     * @param errMsg		错误描述
     */
    public void OnRecvHangoutCreditRunningOutNotice(String roomId, IMClientListener.LCC_ERR_TYPE errType, String errMsg);
}
