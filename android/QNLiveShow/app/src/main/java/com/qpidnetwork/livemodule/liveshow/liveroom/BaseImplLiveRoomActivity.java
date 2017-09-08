package com.qpidnetwork.livemodule.liveshow.liveroom;

import android.os.Bundle;
import android.view.View;

import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.httprequest.item.LiveRoomType;
import com.qpidnetwork.livemodule.im.IMInviteLaunchEventListener;
import com.qpidnetwork.livemodule.im.IMLiveRoomEventListener;
import com.qpidnetwork.livemodule.im.IMManager;
import com.qpidnetwork.livemodule.im.IMOtherEventListener;
import com.qpidnetwork.livemodule.im.listener.IMClientListener;
import com.qpidnetwork.livemodule.im.listener.IMMessageItem;
import com.qpidnetwork.livemodule.im.listener.IMPackageUpdateItem;
import com.qpidnetwork.livemodule.im.listener.IMRebateItem;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.downloader.IFileDownloadedListener;
import com.qpidnetwork.livemodule.liveshow.liveroom.tariffprompt.TariffPromptManager;
import com.qpidnetwork.livemodule.view.SoftKeyboradListenFrameLayout;

/**
 * Description:直播间接口实现基类
 * view层baseactivity或者业务层roomactivity需要重写该类响应的方法以实现对应的视图刷新/业务处理逻辑
 * <p>
 * Created by Harry on 2017/9/1.
 */

public abstract class BaseImplLiveRoomActivity extends BaseFragmentActivity
        implements View.OnClickListener, SoftKeyboradListenFrameLayout.InputWindowListener,
        IFileDownloadedListener, IMInviteLaunchEventListener,IMLiveRoomEventListener,
        IMOtherEventListener, TariffPromptManager.OnGetRoomTariffInfoListener {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        //TODO:反注释
//        initIMListener();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        //TODO:反注释
//        clearIMListener();
    }

    //----------------------------------IM相关---------------------------------------
    protected IMManager mIMManager;
    /**
     * 初始化IM底层相关
     */
    private void initIMListener(){
        mIMManager = IMManager.getInstance();
        mIMManager.registerIMInviteLaunchEventListener(this);
        mIMManager.registerIMLiveRoomEventListener(this);
        mIMManager.registerIMOtherEventListener(this);
    }

    /**
     * 清除IM底层类相关监听事件
     */
    private void clearIMListener(){
        mIMManager.unregisterIMInviteLaunchEventListener(this);
        mIMManager.unregisterIMLiveRoomEventListener(this);
        mIMManager.unregisterIMOtherEventListener(this);
    }

    //------------------点击事件-------------------------------
    @Override
    public void onClick(View v) {

    }

    //------------------软键盘监听、视图高度发生变化--------------
    @Override
    public void onSoftKeyboardShow() {

    }

    @Override
    public void onSoftKeyboardHide() {

    }

    //------------------图片文件等的下载监听--------------
    @Override
    public void onCompleted(boolean isSuccess, String localFilePath, String fileUrl) {

    }

    //------------------用户进入房间、退出房间、直播开始、发送私密邀请、取消私密邀请、邀请响应--------------
    @Override
    public void OnRoomIn(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType,
                         String errMsg, IMRoomInItem roomInfo) {

    }

    @Override
    public void OnRoomOut(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType,
                          String errMsg) {

    }

    @Override
    public void OnRecvLiveStart(String roomId, int leftSeconds) {

    }

    @Override
    public void OnSendImmediatePrivateInvite(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, String invitationId, int timeout, String roomId) {

    }

    @Override
    public void OnCancelImmediatePrivateInvite(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, String roomId) {

    }

    @Override
    public void OnRecvInviteReply(String inviteId, IMClientListener.InviteReplyType replyType, String roomId, LiveRoomType roomType, String anchorId, String nickName, String avatarImg, String message) {

    }

    //------------------直播间IM事件监听--------------
    @Override
    public void OnRecvRoomCloseNotice(String roomId, String userId, String nickName, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnRecvEnterRoomNotice(String roomId, String userId, String nickName, String photoUrl, String riderId, String riderName, String riderUrl, int fansNum) {

    }

    @Override
    public void OnRecvLeaveRoomNotice(String roomId, String userId, String nickName, String photoUrl, int fansNum) {

    }

    @Override
    public void OnRecvRebateInfoNotice(String roomId, IMRebateItem item) {

    }

    @Override
    public void OnRecvLeavingPublicRoomNotice(String roomId, IMClientListener.LCC_ERR_TYPE err, String errMsg) {

    }

    @Override
    public void OnRecvRoomKickoffNotice(String roomId, IMClientListener.LCC_ERR_TYPE err, String errMsg, double credit) {

    }

    @Override
    public void OnRecvChangeVideoUrl(String roomId, boolean isAnchor, String playUrl) {

    }

    @Override
    public void OnSendRoomMsg(boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMMessageItem msgItem) {

    }

    @Override
    public void OnRecvRoomMsg(IMMessageItem msgItem) {

    }

    @Override
    public void OnSendGift(boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMMessageItem msgItem, double credit, double rebateCredit) {

    }

    @Override
    public void OnRecvRoomGiftNotice(IMMessageItem msgItem) {

    }

    @Override
    public void OnSendBarrage(boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMMessageItem msgItem, double credit, double rebateCredit) {

    }

    @Override
    public void OnRecvRoomToastNotice(IMMessageItem msgItem) {

    }

    @Override
    public void OnSendTalent(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnRecvSendTalentNotice(String roomId, String talentInviteId, String talentId, String name, double credit, IMClientListener.TalentInviteStatus status) {

    }

    //------------------------其他断线重连、踢出房间等IM消息监听-------------------------------
    @Override
    public void OnLogin(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnLogout(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnKickOff(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnRecvLackOfCreditNotice(String roomId, String message, double credit) {

    }

    @Override
    public void OnRecvCreditNotice(String roomId, double credit) {

    }

    @Override
    public void OnRecvAnchoeInviteNotify(String logId, String anchorId, String anchorName, String anchorPhotoUrl, String message) {

    }

    @Override
    public void OnRecvScheduledInviteNotify(String inviteId, String anchorId, String anchorName, String anchorPhotoUrl, String message) {

    }

    @Override
    public void OnRecvSendBookingReplyNotice(String inviteId, IMClientListener.BookInviteReplyType replyType) {

    }

    @Override
    public void OnRecvBookingNotice(String roomId, String userId, String nickName, String photoUrl, int leftSeconds) {

    }

    @Override
    public void OnRecvLevelUpNotice(int level) {

    }

    @Override
    public void OnRecvLoveLevelUpNotice(int lovelevel) {

    }

    @Override
    public void OnRecvBackpackUpdateNotice(IMPackageUpdateItem item) {

    }

    //----------------------------其他自定义--------------------------

    @Override
    public void onGetRoomTariffInfo(String tariffPrompt, boolean showOkBtn, String regex) {

    }
}
