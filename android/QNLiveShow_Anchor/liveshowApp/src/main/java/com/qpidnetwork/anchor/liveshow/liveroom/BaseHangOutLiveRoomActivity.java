package com.qpidnetwork.anchor.liveshow.liveroom;

import android.content.DialogInterface;
import android.os.Bundle;
import android.os.Message;
import android.support.annotation.Nullable;
import android.support.v4.app.FragmentManager;
import android.text.TextUtils;
import android.view.Display;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.WindowManager;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.httprequest.LiveRequestOperator;
import com.qpidnetwork.anchor.httprequest.OnAcceptInstanceInviteCallback;
import com.qpidnetwork.anchor.httprequest.OnDealInvitationHangoutCallback;
import com.qpidnetwork.anchor.httprequest.OnHangoutGiftListCallback;
import com.qpidnetwork.anchor.httprequest.item.AnchorHangoutGiftListItem;
import com.qpidnetwork.anchor.httprequest.item.GiftItem;
import com.qpidnetwork.anchor.httprequest.item.HangoutInviteReplyType;
import com.qpidnetwork.anchor.httprequest.item.IntToEnumUtils;
import com.qpidnetwork.anchor.httprequest.item.LiveRoomType;
import com.qpidnetwork.anchor.im.listener.IMClientListener;
import com.qpidnetwork.anchor.im.listener.IMGiftMessageContent;
import com.qpidnetwork.anchor.im.listener.IMHangoutRecommendItem;
import com.qpidnetwork.anchor.im.listener.IMMessageItem;
import com.qpidnetwork.anchor.im.listener.IMOtherInviteItem;
import com.qpidnetwork.anchor.im.listener.IMRecvEnterRoomItem;
import com.qpidnetwork.anchor.im.listener.IMRecvHangoutGiftItem;
import com.qpidnetwork.anchor.im.listener.IMRecvLeaveRoomItem;
import com.qpidnetwork.anchor.im.listener.IMRoomInMessageContent;
import com.qpidnetwork.anchor.im.listener.IMSysNoticeMessageContent;
import com.qpidnetwork.anchor.im.listener.IMTextMessageContent;
import com.qpidnetwork.anchor.im.listener.IMUserBaseInfoItem;
import com.qpidnetwork.anchor.liveshow.liveroom.announcement.WarningDialog;
import com.qpidnetwork.anchor.liveshow.liveroom.audience.OtherAnchorInfoDialog;
import com.qpidnetwork.anchor.liveshow.liveroom.gift.HangOutGiftSendReqManager;
import com.qpidnetwork.anchor.liveshow.liveroom.gift.HangOutGiftSender;
import com.qpidnetwork.anchor.liveshow.liveroom.gift.HangoutRoomGiftManager;
import com.qpidnetwork.anchor.liveshow.liveroom.gift.NormalGiftManager;
import com.qpidnetwork.anchor.liveshow.liveroom.gift.dialog.HangOutGiftDialog;
import com.qpidnetwork.anchor.liveshow.liveroom.gift.normal.LiveGiftView;
import com.qpidnetwork.anchor.liveshow.liveroom.recommend.RecommendDialogFragment;
import com.qpidnetwork.anchor.liveshow.model.http.HttpReqStatus;
import com.qpidnetwork.anchor.liveshow.personal.chatemoji.ChatEmojiManager;
import com.qpidnetwork.anchor.utils.Log;

import static com.qpidnetwork.anchor.im.IMManager.IM_INVALID_REQID;

/**
 * 直播间公共处理界面类
 * 1.通用的业务处理逻辑，放在当前Activity处理
 * 2.直播间界面操作及不同类型直播间界面的刷新展示放到子类activity处理
 * Created by Hunter Mun on 2017/6/16.
 */

public class BaseHangOutLiveRoomActivity extends BaseImplLiveRoomActivity {
    /**
     * 直播间消息更新
     */
    private static final int EVENT_MESSAGE_UPDATE = 1001;

    /**
     * 高级礼物发送失败，3秒toast提示
     */
    protected static final int EVENT_GIFT_ADVANCE_SEND_FAILED = 1004;
    /**
     * 直播间关闭倒计时
     */
    protected static final int EVENT_ANCHOR_SWITCH_ROOM_RETRY= 1006;

    //聊天展示区域
    protected LiveRoomChatManager liveRoomChatManager;
    protected boolean isSoftInputOpen = false;
    private long lastMsgSentTime = 0l;
    protected int leavingRoomTimeCount = 30;//30-default

    //礼物列表
    protected HangoutRoomGiftManager mHangoutRoomGiftManager;
    protected HangOutGiftDialog liveGiftDialog;

    //视频
    protected boolean hasVedioDisconTipsAgain = false;
    protected WarningDialog warningDialog;

    //-----------------------直播间底部--------------------------
    protected boolean hasRoomInClosingStatus = false;
    protected String lastSwitchLiveRoomId = null;
    protected LiveRoomType lastSwitchLiveRoomType = LiveRoomType.Unknown;
    protected IMUserBaseInfoItem lastSwitchUserBaseInfoItem;
    protected String lastInviteManUserId = null;
    protected String lastInviteManPhotoUrl = null;
    protected String lastInviteManNickname = null;
    protected String lastInviteSendSucManNickName = null;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        TAG = BaseHangOutLiveRoomActivity.class.getName();
        initRoomManagers();
    }

    /**
     * 初始化各管理器模块
     */
    private void initRoomManagers(){
        HangOutGiftSendReqManager.getInstance().executeNextReqTask();
    }

    /**
     * 初始化数据
     */
    public void initData(){
        super.initData();
        if(null != mIMHangOutRoomItem){
            HangOutGiftSender.getInstance().currRoomId = mIMHangOutRoomItem.roomId;
            //添加主播头像信息,方便web端主播送礼时客户端能够在小礼物动画上展示其头像
            if(null != loginItem && null != mIMManager){
                mIMManager.updateOrAddUserBaseInfo(loginItem.userId,
                        loginItem.nickName,loginItem.photoUrl);
            }
        }
        ChatEmojiManager.getInstance().getEmojiList(null);
        initRoomGiftDataSet();
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        switch(msg.what){
            case EVENT_GIFT_ADVANCE_SEND_FAILED:
                //豪华非背包礼物，发送失败，弹toast，清理发送队列，关闭倒计时动画
                showThreeSecondTips(getResources().getString(R.string.live_gift_send_failed,msg.obj.toString()),
                        Gravity.BOTTOM|Gravity.CENTER_HORIZONTAL);
                if(null != liveGiftDialog){
                    liveGiftDialog.notifyGiftSentFailed();
                }
                break;

            case EVENT_MESSAGE_UPDATE:
                IMMessageItem msgItem = (IMMessageItem)msg.obj;
                if(msgItem != null && msgItem.msgId > 0){
                    //更新消息列表
                    if(null != liveRoomChatManager){
                        liveRoomChatManager.addMessageToList(msgItem);
                    }
                }
                break;
        }
    }

    /**
     * 消息切换主线程
     * @param msgItem
     */
    public void sendMessageUpdateEvent(IMMessageItem msgItem){
        Log.d(TAG,"sendMessageUpdateEvent-msgItem:"+msgItem);
        Message msg = Message.obtain();
        msg.what = EVENT_MESSAGE_UPDATE;
        msg.obj = msgItem;
        sendUiMessage(msg);
    }

    @Override
    protected void onPause() {
        super.onPause();
        Log.d(TAG,"onPause");
        preStopLive();
    }

    protected void preStopLive(){
        Log.d(TAG,"preStopLive-isActivityFinishByUser:"+isActivityFinishByUser);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        //退出房间成功，就清空送礼队列，并停止服务
        HangOutGiftSendReqManager.getInstance().shutDownReqQueueServNow();
        if(null != liveRoomChatManager){
            liveRoomChatManager.setOnRoomMsgListClickListener(null);
        }
    }

    /**
     * 关闭直播间
     */
    protected void exitHangOutLiveRoom(){
        Log.d(TAG,"exitHangOutLiveRoom");
        if(null != mIMManager && null != mIMHangOutRoomItem){
            mIMManager.exitHangOutRoom(mIMHangOutRoomItem.roomId);
        }
    }

    /**
     * 关闭直播间
     */
    protected void outHangOutRoomAndClearFlag(){
        Log.d(TAG,"exitHangOutLiveRoom");
        if(null != mIMManager && null != mIMHangOutRoomItem){
            mIMManager.outHangOutRoomAndClearFlag(mIMHangOutRoomItem.roomId);
        }
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        Log.d(TAG,"onKeyDown-keyCode:"+keyCode+" event.action:"+event.getAction());
        if(keyCode == KeyEvent.KEYCODE_BACK && event.getAction() == KeyEvent.ACTION_DOWN){
            if(!hasRoomInClosingStatus){
                lastSwitchLiveRoomId = null;
                lastSwitchUserBaseInfoItem = null;
                lastSwitchLiveRoomType = LiveRoomType.Unknown;
                userCloseRoom();
            }
            return false;
        }
        return super.onKeyDown(keyCode, event);
    }

    //标识activity走onPause是否是用户主播关闭所致，是则隐藏surfaceView，避免在huawei nexus 6p的手机上出现闪一下黑框的问题
    protected boolean isActivityFinishByUser = false;

    /**
     * 用户手动点击退出直播间
     */
    protected void userCloseRoom(){
        showSimpleTipsDialog(0,R.string.hangout_liveroom_close_room_notify,
                R.string.common_btn_cancel,R.string.common_btn_sure,
                null,new DialogInterface.OnClickListener(){
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        isActivityFinishByUser = true;
                        clearIMListener();
                        unRegisterConfictReceiver();
                        outHangOutRoomAndClearFlag();
                        //退出直播间清除本地缓存信息
                        clearUserInfoList();
                        mIMHangOutRoomItem = null;
                        finish();
                    }
                });
    }

    protected void clearUserInfoList(){
        if(null != mIMManager){
            mIMManager.clearUserInfoList();
        }
    }


    @Override
    public void OnLogout(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
        super.OnLogout(errType, errMsg);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                //断线互动视频处理
                onPullStreamDisconnect();
            }
        });
    }

    public void onPullStreamDisconnect(){
        Log.d(TAG,"onPullStreamDisconnect");
    }

    //******************************** 礼物模块 ****************************************************************
    /**
     * 初始化礼物配置
     */
    public void initRoomGiftDataSet() {
        if(null != mIMHangOutRoomItem && !TextUtils.isEmpty(mIMHangOutRoomItem.roomId)){
            mHangoutRoomGiftManager = new HangoutRoomGiftManager(mIMHangOutRoomItem.roomId);

            //初始化礼物弹框（必须先于请求接口，否则同步不到礼物数据，后续修改此逻辑）
            initLiveGiftDialog();

            getHangoutRoomGiftList();
        }
    }

    /**
     * 点击reload响应
     */
    public void reloadLimitGiftData(){
        getHangoutRoomGiftList();
    }

    /**
     * 获取hangout直播间礼物列表
     */
    private void getHangoutRoomGiftList(){
        if(mHangoutRoomGiftManager != null){
            mHangoutRoomGiftManager.getRoomGiftList(new OnHangoutGiftListCallback() {
                @Override
                public void onHangoutGiftList(boolean isSuccess, int errCode, String errMsg, AnchorHangoutGiftListItem giftItem) {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            if(null != liveGiftDialog){
                                liveGiftDialog.notifyHangOutGiftDataChanged();
                            }
                        }
                    });
                }
            });
        }
    }

    /**
     * 必须先初始化dialog，防止接口数据刷新不能同步到dialog（后续修改次逻辑）
     */
    private void initLiveGiftDialog(){
        if(null == liveGiftDialog){
            liveGiftDialog = new HangOutGiftDialog(this, mHangoutRoomGiftManager);
            if(null != mIMHangOutRoomItem){
                liveGiftDialog.setImHangoutRoomItem(mIMHangOutRoomItem);
            }
            liveGiftDialog.setOutSizeTouchHasChecked(true);
        }
    }

    protected void showHangoutGiftDialog(){
        //增加每次点击显示，如果本地数据刷新失败（即本地无数据）
        if(mHangoutRoomGiftManager != null){
            HttpReqStatus sendableGiftReqStatus = mHangoutRoomGiftManager.getRoomGiftRequestStatus();
            if(sendableGiftReqStatus == HttpReqStatus.ResFailed
                    || sendableGiftReqStatus == HttpReqStatus.NoReq){
                getHangoutRoomGiftList();
            }
        }

        if(liveGiftDialog != null) {
            liveGiftDialog.show();
        }
        //GA点击打开礼物列表
        onAnalyticsEvent(getResources().getString(R.string.Live_Broadcast_Category),
                getResources().getString(R.string.Live_Broadcast_Action_GiftList),
                getResources().getString(R.string.Live_Broadcast_Label_GiftList));
    }

    @Override
    public void OnSendGift(boolean success, final IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMMessageItem msgItem) {
        super.OnSendGift(success,errType,errMsg,msgItem);
        if(errType != IMClientListener.LCC_ERR_TYPE.LCC_ERR_SUCCESS){
            //需要查询是否是大礼物发送失败，提示用户
            final Message msg = Message.obtain();
            if(null != msgItem && null != msgItem.giftMsgContent){
                GiftItem giftDetail = NormalGiftManager.getInstance().getLocalGiftDetail(msgItem.giftMsgContent.giftId);
                if(null != giftDetail && giftDetail.giftType == GiftItem.GiftType.Advanced){
                    msg.what = EVENT_GIFT_ADVANCE_SEND_FAILED;
                    msg.obj = giftDetail.name;
                    sendUiMessage(msg);
                }
            }
        }
    }

    @Override
    public void OnRecvAnchorGiftNotice(IMRecvHangoutGiftItem item) {
        super.OnRecvAnchorGiftNotice(item);
        if(!isCurrentRoom(item.roomId)){
            return;
        }
        //生成聊天列表消息
        Log.d(TAG,"OnRecvAnchorGiftNotice-isSecretly:"+item.isPrivate+" item:"+item);
        IMUserBaseInfoItem infoItem = mIMManager.getUserInfo(item.toUid);
        IMGiftMessageContent giftMsgContent = new IMGiftMessageContent(item.giftId, item.giftName, item.giftNum,
                item.isMultiClick, item.multiClickStart, item.multiClickEnd, item.multiClickId,item.isPrivate);
        IMMessageItem msgItem = new IMMessageItem(item.roomId, mIMManager.mMsgIdIndex.getAndIncrement(),
                item.fromId, item.nickName, null, -1, IMMessageItem.MessageType.Gift,
                new IMTextMessageContent(null == infoItem ? "" : infoItem.nickName), giftMsgContent);
        sendMessageUpdateEvent(msgItem);
        launchGiftAnimByMessage(item.toUid,msgItem);
    }

    /**
     * 启动礼物消息动画
     * @param toUid
     * @param msgItem
     */
    public void launchGiftAnimByMessage(String toUid,IMMessageItem msgItem){
        Log.d(TAG,"launchGiftAnimByMessage-msgItem.fromUserId:"+msgItem.userId+" toUid:"+toUid);
    }

    //-----------------------------------文本消息-----------------------------------------
    /**
     * 回车键盘发送信息
     */
    protected boolean enterKey2SendMsg(String message,String targetId,String targetNickname) {
        if(TextUtils.isEmpty(message) || TextUtils.isEmpty(message.trim())){
            return false;
        }
        Log.d(TAG,"enterKey2SendMsg-message:"+message+" targetId:"+targetId+" targetNickname:"+targetNickname);
//        long timeLosed = System.currentTimeMillis() - lastMsgSentTime;
//        Log.d(TAG,"enterKey2SendMsg-timeLosed:"+timeLosed);
//        if (timeLosed < getResources().getInteger(R.integer.minMsgSendTimeInterval)) {
        //2018年4月8日 15:30:35 Randy同Jasper和Martin商量不再需要1秒间隔的判断逻辑
//            showThreeSecondTips(getResources().getString(R.string.live_msg_send_tips), Gravity.CENTER);
//            return false;
//        }
//        lastMsgSentTime = System.currentTimeMillis();

        //2018年5月14日 15:15:07 多人直播间 发送文本消息时 不再插入@昵称文本内容
//        if(null != targetNickname && !targetId.equals("0")){
//            StringBuilder sb = new StringBuilder("@");
//            sb.append(targetNickname);
//            sb.append(" ");
//            sb.append(message);
//            message = sb.toString();
//        }
        if(null != mIMHangOutRoomItem && !TextUtils.isEmpty(mIMHangOutRoomItem.roomId)){
            IMMessageItem msgItem = mIMManager.sendHangOutRoomMsg(mIMHangOutRoomItem.roomId, message,
                    targetId.equals("0") ? null : new String[]{targetId});
        }

        return true;
    }

    @Override
    public void OnRecvHangoutMsg(IMMessageItem imMessageItem) {
        if(!isCurrentRoom(imMessageItem.roomId)){
            return;
        }
        super.OnRecvHangoutMsg(imMessageItem);
        sendMessageUpdateEvent(imMessageItem);
    }

    @Override
    public void onSoftKeyboardShow() {
        Log.d(TAG, "onSoftKeyboardShow");
        isSoftInputOpen = true;
    }

    @Override
    public void onSoftKeyboardHide() {
        Log.d(TAG, "onSoftKeyboardHide");
        isSoftInputOpen = false;
    }

    //******************************** 消息展示列表 ****************************************************************
    @Override
    public void OnRecvSendSystemNotice(final IMMessageItem msgItem) {
        super.OnRecvSendSystemNotice(msgItem);
        if(!isCurrentRoom(msgItem.roomId)){
            return;
        }
        sendMessageUpdateEvent(msgItem);
        if(null != msgItem && null != msgItem.sysNoticeContent
                && msgItem.sysNoticeContent.sysNoticeType == IMSysNoticeMessageContent.SysNoticeType.Warning){
            if(!TextUtils.isEmpty(msgItem.sysNoticeContent.message)){
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        showWarningDialog(msgItem.sysNoticeContent.message);
                    }
                });
            }
        }
    }

    protected void showWarningDialog(String warnContent){
        Log.d(TAG,"showWarningDialog-warnContent:"+warnContent);
        if(null == warningDialog){
            warningDialog = new WarningDialog(this);
        }
        warningDialog.show(warnContent);
    }

    /********************************* IMManager事件监听回调  *******************************************/
    @Override
    public void OnRecvRoomToastNotice(IMMessageItem msgItem) {
        if(!isCurrentRoom(msgItem.roomId)){
            return;
        }
        super.OnRecvRoomToastNotice(msgItem);
        sendMessageUpdateEvent(msgItem);
    }

    @Override
    public void OnRecvRoomKickoffNotice(String roomId, final IMClientListener.LCC_ERR_TYPE err, final String errMsg) {
        if(!isCurrentRoom(roomId)){
            return;
        }
        super.OnRecvRoomKickoffNotice(roomId, err, errMsg);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                endLiveRoom(errMsg);
            }
        });
    }

    /**
     * 用户收到房间关闭通知
     * @param roomId
     */
    @Override
    public void OnRecvRoomCloseNotice(String roomId, final IMClientListener.LCC_ERR_TYPE errType, final String errMsg) {
        super.OnRecvRoomCloseNotice(roomId, errType, errMsg);
        if(!isCurrentRoom(roomId)){
            return;
        }
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                endLiveRoom(errMsg);
            }
        });
    }

    @Override
    public void OnLeaveHangoutRoom(int reqId, final boolean success, IMClientListener.LCC_ERR_TYPE errType, final String errMsg) {
        super.OnLeaveHangoutRoom(reqId, success, errType, errMsg);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                endLiveRoom(errMsg);
                if(!TextUtils.isEmpty(errMsg)){
                    showToast(errMsg);
                }
            }
        });
    }

    /**
     * 释放流媒体资源占用
     */
    public void stopLSPubilsher(){
        Log.d(TAG,"stopLSPubilsher");
    }

    /**
     * 关闭直播间，跳转到结束页
     * @param description
     */
    public void endLiveRoom(String description){
        stopLSPubilsher();
        if(!TextUtils.isEmpty(lastSwitchLiveRoomId)){
            if(LiveRoomType.NormalPrivateRoom == lastSwitchLiveRoomType || LiveRoomType.AdvancedPrivateRoom == lastSwitchLiveRoomType){
                startActivity(LiveRoomTransitionActivity.getEnterRoomIntent(
                        BaseHangOutLiveRoomActivity.this,
                        lastSwitchUserBaseInfoItem.userId,
                        lastSwitchUserBaseInfoItem.nickName,
                        lastSwitchUserBaseInfoItem.photoUrl,
                        lastSwitchLiveRoomId));
            }else if(LiveRoomType.HangoutRoom == lastSwitchLiveRoomType){
                startActivity(HangOutRoomTransActivity.getEnterRoomIntent(
                        BaseHangOutLiveRoomActivity.this,
                        lastSwitchUserBaseInfoItem.userId,
                        lastSwitchUserBaseInfoItem.nickName,
                        lastSwitchUserBaseInfoItem.photoUrl,
                        lastSwitchLiveRoomId));
            }
        }else {
            preEndLiveRoom(description);
        }
        clearUserInfoList();
        //退出直播间成功，清空本地缓存信息
        mIMHangOutRoomItem = null;
        isActivityFinishByUser = true;
        finish();
    }

    /**
     * 提供给基类处理自己结束页面前操作
     * @param description
     */
    protected void preEndLiveRoom(String description){
        Log.d(TAG,"preEndLiveRoom-description:"+description+" manPhotoUrl:"+manPhotoUrl);
    }

    /**
     * 断线重连重新进入房间，视频模块处理
     */
    protected void onDisconnectRoomIn(){
        Log.d(TAG,"onDisconnectRoomIn");
        //拉流处理
        if(null != mIMHangOutRoomItem){
            //同步刷新礼物数据
            getHangoutRoomGiftList();
        }
    }

    /*******************************断线重连****************************************/
    @Override
    public void OnLogin(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
        super.OnLogin(errType, errMsg);
        //断线重连，需要拿roomId重新登录房间
        Log.d(TAG,"onIMAutoReLogined-mIMHangOutRoomItem:"+mIMHangOutRoomItem);
        if(errType == IMClientListener.LCC_ERR_TYPE.LCC_ERR_SUCCESS) {
            //断线重连成功才执行进入直播间逻辑
            HangOutGiftSender.getInstance().notifyIMReconnect();
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    if (null != mIMHangOutRoomItem && !TextUtils.isEmpty(mIMHangOutRoomItem.roomId)) {
                        if (null != mIMManager) {
                            int result = mIMManager.enterHangOutRoom(mIMHangOutRoomItem.roomId);
                            Log.d(TAG, "onIMAutoReLogined-result:" + result + " IM_INVALID_REQID:" + IM_INVALID_REQID);
                        }
                    }
                }
            });
        }
    }

    @Override
    protected void onScheduledInvitePushNotify(String roomId, IMUserBaseInfoItem userInfo) {
        super.onScheduledInvitePushNotify(roomId, userInfo);
        //预约私密到期push通知，主播点击确认切换直播间
        lastSwitchLiveRoomId = roomId;
        lastSwitchUserBaseInfoItem = userInfo;
        lastSwitchLiveRoomType = LiveRoomType.AdvancedPrivateRoom;
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                exitHangOutLiveRoom();
            }
        });

    }

    @Override
    protected void onManInvite2HangOutPushNotify(String invitationId, final IMUserBaseInfoItem userInfo) {
        super.onManInvite2HangOutPushNotify(invitationId, userInfo);
        LiveRequestOperator.getInstance().DealInvitationHangout(invitationId, HangoutInviteReplyType.AGREE, new OnDealInvitationHangoutCallback() {

            @Override
            public void onDealInvitationHangout(final boolean isSuccess, int errCode, final String errMsg, final String roomId) {
                Log.d(TAG,"onManInvite2HangOutPushNotify-onDealInvitationHangout isSuccess:"+isSuccess
                        +" errCode:"+errCode+" errMsg:"+errMsg+" roomId:"+roomId);
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if(isSuccess){
                            lastSwitchUserBaseInfoItem = userInfo;
                            lastSwitchLiveRoomId = roomId;
                            lastSwitchLiveRoomType = LiveRoomType.HangoutRoom;
                            exitHangOutLiveRoom();
                        }else{
                            if(!TextUtils.isEmpty(errMsg)){
                                showToast(errMsg);
                            }
                        }
                    }
                });
            }
        });
    }

    @Override
    protected void onAudienceInvitePushNotify(String invitationId, final IMUserBaseInfoItem userInfo) {
        super.onAudienceInvitePushNotify(invitationId, userInfo);
        //1.先走应邀流程
        LiveRequestOperator.getInstance().AcceptInstanceInvite(invitationId, new OnAcceptInstanceInviteCallback() {
            @Override
            public void onAcceptInstanceInvite(final boolean isSuccess, final int errCode,
                                               final String errMsg, final String roomId, final int roomType) {
                Log.d(TAG,"onAudienceInvitePushNotify-onAcceptInstanceInvite isSuccess:"+isSuccess
                        +" errCode:"+errCode+" errMsg:"+errMsg+" roomId:"+roomId+" roomType:"+roomType);
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if(isSuccess){
                            lastSwitchUserBaseInfoItem = userInfo;
                            lastSwitchLiveRoomId = roomId;
                            lastSwitchLiveRoomType = IntToEnumUtils.intToLiveRoomType(roomType);
                            exitHangOutLiveRoom();
                        }else{
                            if(!TextUtils.isEmpty(errMsg)){
                                showToast(errMsg);
                            }
                        }
                    }
                });
            }
        });
    }

    @Override
    public void OnRecvAnchorEnterRoomNotice(IMRecvEnterRoomItem item) {
        super.OnRecvAnchorEnterRoomNotice(item);
        if(!isCurrentRoom(item.roomId)){
            return;
        }
        if(null != mIMManager){
            mIMManager.updateOrAddUserBaseInfo(new IMUserBaseInfoItem(item.userId,
                    item.nickName,item.photoUrl));
            if(null != mIMHangOutRoomItem && !TextUtils.isEmpty(mIMHangOutRoomItem.manId)){
                //添加入场消息
                IMMessageItem msgItem = new IMMessageItem(item.roomId,
                        mIMManager.mMsgIdIndex.getAndIncrement(),
                        IMMessageItem.MessageType.RoomIn,
                        new IMRoomInMessageContent(item.nickName,null,null,null));
                msgItem.userId = item.userId;
                Message msg = Message.obtain();
                msg.what = EVENT_MESSAGE_UPDATE;
                msg.obj = msgItem;
                sendUiMessage(msg);
            }
        }
    }


    @Override
    public void OnRecvAnchorOtherInviteNotice(IMOtherInviteItem item) {
        super.OnRecvAnchorOtherInviteNotice(item);
        if(!isCurrentRoom(item.roomId)){
            return;
        }
        if(null != mIMManager){
            mIMManager.updateOrAddUserBaseInfo(new IMUserBaseInfoItem(item.anchorId,
                    item.nickName,item.photoUrl));
        }
    }

    @Override
    public void OnRecvAnchorLeaveRoomNotice(IMRecvLeaveRoomItem item) {
        super.OnRecvAnchorLeaveRoomNotice(item);
        if(!isCurrentRoom(item.roomId)){
            return;
        }
    }

    //----------------------------------其他主播资料弹框及好友关系逻辑------------------------------
    /**
     * 其他主播资料弹框
     */
    protected OtherAnchorInfoDialog otherAnchorInfoDialog;

    /**
     * 展示主播资料弹框
     * @param anchorId
     */
    public void showOtherAnchorInfoDialog(String anchorId){
        Log.d(TAG,"showOtherAnchorInfoDialog-anchorId:"+anchorId);
        if(null == otherAnchorInfoDialog){
            otherAnchorInfoDialog = new OtherAnchorInfoDialog(this);
            otherAnchorInfoDialog.setOutSizeTouchHasChecked(true);
        }
        otherAnchorInfoDialog.show(anchorId);
        /**在show之后,加上如下这段代码就能解决宽被压缩的bug*/
        WindowManager windowManager = getWindowManager();
        Display defaultDisplay = windowManager.getDefaultDisplay();
        WindowManager.LayoutParams attributes = otherAnchorInfoDialog.getWindow().getAttributes();
        attributes.width = defaultDisplay.getWidth();
        attributes.gravity = Gravity.BOTTOM;
        otherAnchorInfoDialog.getWindow().setAttributes(attributes);
    }

    //------------------------------推荐主播--------------------------------------
    /**
     * 推荐主播列表对话框
     */
    protected void showRecommendDialog(){
        Log.d(TAG,"showRecommendDialog");
        FragmentManager fragmentManager = getSupportFragmentManager();
        if(null != mIMHangOutRoomItem){
            RecommendDialogFragment.showDialog(fragmentManager , mIMHangOutRoomItem.roomId , mIMHangOutRoomItem.manNickName);
        }
    }

    /**
     * 10.4.接收推荐好友通知
     * add by Jagger 2018-5-17
     * @param item
     */
    @Override
    public void OnRecvAnchorRecommendHangoutNotice(IMHangoutRecommendItem item) {
        Log.d(TAG,"OnRecvAnchorRecommendHangoutNotice-item:"+item);
        //插入信息列表
        IMMessageItem msgItem = new IMMessageItem(item.roomId ,
                mIMManager.mMsgIdIndex.getAndIncrement(),
                IMMessageItem.MessageType.HangOut,
                item);
        sendMessageUpdateEvent(msgItem);
    }
}
