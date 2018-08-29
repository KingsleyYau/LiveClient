package com.qpidnetwork.anchor.im;

import com.qpidnetwork.anchor.im.listener.IMClientListener;
import com.qpidnetwork.anchor.im.listener.IMDealInviteItem;
import com.qpidnetwork.anchor.im.listener.IMHangoutRecommendItem;
import com.qpidnetwork.anchor.im.listener.IMHangoutRoomItem;
import com.qpidnetwork.anchor.im.listener.IMKnockRequestItem;
import com.qpidnetwork.anchor.im.listener.IMMessageItem;
import com.qpidnetwork.anchor.im.listener.IMOtherInviteItem;
import com.qpidnetwork.anchor.im.listener.IMRecvEnterRoomItem;
import com.qpidnetwork.anchor.im.listener.IMRecvHangoutGiftItem;
import com.qpidnetwork.anchor.im.listener.IMRecvLeaveRoomItem;

/**
 * Description:HangOut直播间事件回调
 * <p>
 * Created by Harry on 2018/5/2.
 */
public interface IMHangOutRoomEventListener {

    /**
     * 10.1.进入多人互动直播间（主播端进入多人互动直播间）
     * @param reqId
     * @param success
     * @param errType
     * @param errMsg
     * @param hangoutRoomItem		多人互动直播间
     * @param expire				倒数进入秒数，倒数完成后再调用本接口重新进入
     */
    void OnEnterHangoutRoom(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType,
                            String errMsg, IMHangoutRoomItem hangoutRoomItem, int expire);

    /**
     * 10.2.退出多人互动直播间（主播端请求退出多人互动直播间）
     * @param reqId
     * @param success
     * @param errType
     * @param errMsg
     */
    void OnLeaveHangoutRoom(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg);

    /**
     * 10.4.接收推荐好友通知
     * @param item		 主播端接收自己推荐好友给观众的信息
     */
    void OnRecvAnchorRecommendHangoutNotice(IMHangoutRecommendItem item);

    /**
     * 10.5.接收敲门回复通知
     * @param item		 接收敲门回复信息
     */
    void OnRecvAnchorDealKnockRequestNotice(IMKnockRequestItem item);

    /**
     * 10.6.接收观众邀请其它主播加入多人互动通知
     * @param item		接收观众邀请其它主播加入多人互动信息
     */
    void OnRecvAnchorOtherInviteNotice(IMOtherInviteItem item);

    /**
     * 10.7.接收主播回复观众多人互动邀请通知
     * @param item		接收主播回复观众多人互动邀请信息
     */
    void OnRecvAnchorDealInviteNotice(IMDealInviteItem item);

    /**
     * 10.8.观众端/主播端接收观众/主播进入多人互动直播间通知
     * @param item		接收主播回复观众多人互动邀请信息
     */
    void OnRecvAnchorEnterRoomNotice(IMRecvEnterRoomItem item);

    /**
     * 10.9.接收观众/主播退出多人互动直播间通知
     * @param item		接收观众/主播退出多人互动直播间信息
     */
    void OnRecvAnchorLeaveRoomNotice(IMRecvLeaveRoomItem item);

    /**
     * 10.10.接收观众/主播多人互动直播间视频切换通知
     * @param roomId		直播间ID
     * @param isAnchor		是否主播（0：否，1：是）
     * @param userId		观众/主播ID
     * @param playUrl		视频流url（字符串数组）（访问视频URL的协议参考《 “视频URL”协议描述》）
     */
    void OnRecvAnchorChangeVideoUrl(String roomId, boolean isAnchor, String userId, String[] playUrl);

    /**
     * 10.11.发送多人互动直播间礼物消息（观众端/主播端发送多人互动直播间礼物消息）
     * @param reqId
     * @param success
     * @param errType
     * @param errMsg
     */
    void OnSendHangoutGift(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg);

    /**
     * 10.12.接收多人互动直播间礼物通知
     * @param item		接收多人互动直播间礼物信息
     */
    void OnRecvAnchorGiftNotice(IMRecvHangoutGiftItem item);

    /**
     * 10.13.接收多人互动直播间观众启动/关闭视频互动通知
     * @param roomId
     * @param userId
     * @param nickname
     * @param avatarImg
     * @param operateType
     * @param pushUrls
     */
    void OnRecvHangoutInteractiveVideoNotice(String roomId, String userId, String nickname, String avatarImg,
                                             IMClientListener.IMVideoInteractiveOperateType operateType, String[] pushUrls);

    /**
     * 10.14.发送多人互动直播间文本消息回调
     * @param reqId
     * @param errType
     * @param errMsg
     */
    void OnSendHangoutMsg(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg);

    /**
     * 10.15.接收多人直播间文本消息通知
     * @param imMessageItem
     */
    void OnRecvHangoutMsg(IMMessageItem imMessageItem);

    /**
     * 10.16.接收进入多人互动直播间倒数通知回调
     * @param roomId				待进入的直播间ID
     * @param anchorId				主播ID
     * @param leftSecond			进入直播间的剩余秒数
     */
    void OnRecvAnchorCountDownEnterRoomNotice(String roomId, String anchorId, int leftSecond);
}
