package com.qpidnetwork.livemodule.liveshow.liveroom;

import android.os.Bundle;
import android.os.Message;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.View;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.OnGetAccountBalanceCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetHangoutGiftListCallback;
import com.qpidnetwork.livemodule.httprequest.item.HangoutAnchorInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.HangoutGiftListItem;
import com.qpidnetwork.livemodule.httprequest.item.LSLeftCreditItem;
import com.qpidnetwork.livemodule.httprequest.item.LiveRoomType;
import com.qpidnetwork.livemodule.im.IMClient;
import com.qpidnetwork.livemodule.im.listener.IMAuthorityItem;
import com.qpidnetwork.livemodule.im.listener.IMClientListener;
import com.qpidnetwork.livemodule.im.listener.IMDealInviteItem;
import com.qpidnetwork.livemodule.im.listener.IMHangoutAnchorItem;
import com.qpidnetwork.livemodule.im.listener.IMHangoutCountDownItem;
import com.qpidnetwork.livemodule.im.listener.IMHangoutRecommendItem;
import com.qpidnetwork.livemodule.im.listener.IMHangoutRoomItem;
import com.qpidnetwork.livemodule.im.listener.IMMessageItem;
import com.qpidnetwork.livemodule.im.listener.IMRecvEnterRoomItem;
import com.qpidnetwork.livemodule.im.listener.IMRecvKnockRequestItem;
import com.qpidnetwork.livemodule.im.listener.IMRecvLeaveRoomItem;
import com.qpidnetwork.livemodule.im.listener.IMSysNoticeMessageContent;
import com.qpidnetwork.livemodule.im.listener.IMTextMessageContent;
import com.qpidnetwork.livemodule.im.listener.IMUserBaseInfoItem;
import com.qpidnetwork.livemodule.liveshow.liveroom.announcement.WarningDialog;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.HangOutGiftSendReqManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.HangOutGiftSender;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.HangoutRoomGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.dialog.HangoutAddCreditsDialog;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.dialog.HangoutGiftDialog;
import com.qpidnetwork.livemodule.liveshow.liveroom.rebate.LiveRoomCreditRebateManager;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpReqStatus;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.liveshow.personal.chatemoji.ChatEmojiManager;
import com.qpidnetwork.livemodule.view.SimpleDoubleBtnTipsDialog;
import com.qpidnetwork.qnbridgemodule.util.Log;
import com.qpidnetwork.qnbridgemodule.util.ToastUtil;

import java.util.ArrayList;
import java.util.List;

import io.reactivex.disposables.Disposable;

/**
 * 直播间公共处理界面类(处理业务)
 * 1.通用的业务处理逻辑，放在当前Activity处理
 * 2.直播间界面操作及不同类型直播间界面的刷新展示放到子类activity处理
 * Created by Hunter Mun on 2017/6/16.
 * copy by Jagger 2019-3-14
 */

public abstract class BaseHangOutLiveRoomActivity extends BaseImplHangOutRoomActivity {
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
    protected static final int EVENT_ANCHOR_SWITCH_ROOM_RETRY = 1006;
    // 发送礼物成功
    protected static final int EVENT_HANG_OUT_SEND_GIFT = 1008;


    //聊天展示区域
    protected LiveRoomChatManager liveRoomChatManager;
    protected boolean isSoftInputOpen = false;
    private long lastMsgSentTime = 0l;
    protected int leavingRoomTimeCount = 30;//30-default

    //礼物列表
    protected HangoutRoomGiftManager mHangoutRoomGiftManager;
    protected HangoutGiftDialog liveGiftDialog;
    protected HangoutAddCreditsDialog addCreditsDialog;

    //视频
    protected boolean hasVedioDisconTipsAgain = false;
    protected WarningDialog warningDialog;
    private int mStartVideoPushReqId, mStopVideoPushReqId;  //男士推流开始/停止线程ID
    protected boolean mIsFirstTimePushVideo = true;         //男士是否首次打开推流

    //RxJava回调对象列表
    private List<Disposable> mDisposableList = new ArrayList<>();
    //无点对话框标识
    private boolean hasShowCreditsLackTips = false;

    //-----------------------直播间底部--------------------------
    protected boolean hasRoomInClosingStatus = false;
    protected String lastSwitchLiveRoomId = null;
    protected LiveRoomType lastSwitchLiveRoomType = LiveRoomType.Unknown;
    protected IMUserBaseInfoItem lastSwitchUserBaseInfoItem;
    protected String lastInviteManUserId = null;
    protected String lastInviteManPhotoUrl = null;
    protected String lastInviteManNickname = null;
    protected String lastInviteSendSucManNickName = null;

    private String TAG;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        TAG = "BaseHangOutLiveRoomActivity";//.class.getName();
        initRoomManagers();
    }

    /**
     * 初始化各管理器模块
     */
    private void initRoomManagers() {
        HangOutGiftSendReqManager.getInstance().executeNextReqTask();
//        LiveGiftView.MAX_GIFT_SUM = 1;
    }

    /**
     * 初始化数据
     */
    public void initData() {
        super.initData();
        if (null != mIMHangoutRoomInItem) {
            HangOutGiftSender.getInstance().currRoomId = mIMHangoutRoomInItem.roomId;

            //添加主播头像信息,方便web端主播送礼时客户端能够在小礼物动画上展示其头像
            if (null != loginItem && null != mIMManager) {
                mIMManager.updateOrAddUserBaseInfo(loginItem.userId,
                        loginItem.nickName, loginItem.photoUrl);
            }
        }
        ChatEmojiManager.getInstance().getEmojiList(null);
        // 初始化礼物弹窗
        initRoomGiftDataSet();
        // 初始化 add credits 弹窗
        initAddCreditsDialog();
    }

    private void initAddCreditsDialog() {
        if (addCreditsDialog == null) {
            addCreditsDialog = new HangoutAddCreditsDialog(mContext);
        }
    }

    /**
     * 需要模糊背景的弹窗
     *
     * @param view
     */
    protected void setDialogBlurView(View view) {
        if (liveGiftDialog != null) {
            liveGiftDialog.setBlurBgView(view);
        }
        if (addCreditsDialog != null) {
            addCreditsDialog.setBlurBgView(view);
        }
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        switch (msg.what) {
            case EVENT_GIFT_ADVANCE_SEND_FAILED:
                //豪华非背包礼物，发送失败，弹toast，清理发送队列，关闭倒计时动画
                showThreeSecondTips(getResources().getString(R.string.live_gift_send_failed, msg.obj.toString()),
                        Gravity.BOTTOM | Gravity.CENTER_HORIZONTAL);
                if (null != liveGiftDialog) {
                    liveGiftDialog.notifyGiftSentFailed();
                }
                break;

            case EVENT_MESSAGE_UPDATE:
                IMMessageItem msgItem = (IMMessageItem) msg.obj;
                if (msgItem != null && msgItem.msgId > 0) {
                    //更新消息列表
                    if (null != liveRoomChatManager) {
                        liveRoomChatManager.addMessageToList(msgItem);
                    }
                }
                break;


            case EVENT_HANG_OUT_SEND_GIFT:
                HttpRespObject object = (HttpRespObject) msg.obj;
                if (object.isSuccess) {
                    // TODO: 2019/3/15


                } else {
                    ToastUtil.showToast(mContext, object.errMsg);
                }
                break;
        }
    }

    /**
     * 消息切换主线程
     *
     * @param msgItem
     */
    public void sendMessageUpdateEvent(IMMessageItem msgItem) {
        Log.d(TAG, "sendMessageUpdateEvent-msgItem:" + msgItem);
        Message msg = Message.obtain();
        msg.what = EVENT_MESSAGE_UPDATE;
        msg.obj = msgItem;
        sendUiMessage(msg);
    }

    @Override
    protected void onPause() {
        super.onPause();
        Log.d(TAG, "onPause");
        preStopLive();
    }

    protected void preStopLive() {
        Log.d(TAG, "preStopLive-isActivityFinishByUser:" + isActivityFinishByUser);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        //退出房间成功，就清空送礼队列，并停止服务
        HangOutGiftSendReqManager.getInstance().shutDownReqQueueServNow();

        if(null != liveRoomChatManager){
            liveRoomChatManager.destroy();
        }

        //rxjava回收相关，防止生命周期结束，请求一步返回导致业务错误
        if(mDisposableList != null && mDisposableList.size() > 0){
            for(Disposable disposable : mDisposableList){
                if(disposable!=null&&!disposable.isDisposed()){
                    disposable.dispose();
                }
            }
        }
        //del by Jagger 不能在这置空，子类销毁逻辑还有需要用到
//        mIMHangoutRoomInItem = null;
    }

    /**
     * 关闭直播间
     */
    protected void exitHangOutLiveRoom() {
        Log.d(TAG, "exitHangOutLiveRoom");
        if (null != mIMManager && null != mIMHangoutRoomInItem) {
            mIMManager.exitHangoutRoom(mIMHangoutRoomInItem.roomId);
        }
    }

    /**
     * 关闭直播间
     */
    protected void outHangOutRoomAndClearFlag() {
        Log.d(TAG, "exitHangOutLiveRoom");
        if (null != mIMManager && null != mIMHangoutRoomInItem) {
            mIMManager.outHangOutRoomAndClearFlag(mIMHangoutRoomInItem.roomId);
        }
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        Log.d(TAG, "onKeyDown-keyCode:" + keyCode + " event.action:" + event.getAction());
        if (keyCode == KeyEvent.KEYCODE_BACK && event.getAction() == KeyEvent.ACTION_DOWN) {
            if (!hasRoomInClosingStatus) {
                lastSwitchLiveRoomId = null;
                lastSwitchUserBaseInfoItem = null;
                lastSwitchLiveRoomType = LiveRoomType.Unknown;
                showUserCloseRoomDialog();
            }
            return false;
        }
        return super.onKeyDown(keyCode, event);
    }

    //标识activity走onPause是否是用户主播关闭所致，是则隐藏surfaceView，避免在huawei nexus 6p的手机上出现闪一下黑框的问题
    protected boolean isActivityFinishByUser = false;

    //手动点击退出直播间询问框
    protected void showUserCloseRoomDialog(){
        showSimpleTipsDialog(R.string.hangout_liveroom_close_room_notify,
                R.string.common_btn_cancel, R.string.common_btn_sure, new SimpleDoubleBtnTipsDialog.OnTipsDialogBtnClickListener() {
                    @Override
                    public void onCancelBtnClick() {

                    }

                    @Override
                    public void onConfirmBtnClick() {
                        endLiveRoom(HangoutEndActivity.HangoutEndType.NORMAL, false, true);
                    }
                });
    }

    /**
     * 用户手动点击退出直播间
     */
    protected void userCloseRoom() {
        //先关送礼窗
        if (liveGiftDialog != null) {
            liveGiftDialog.dismiss();
        }
        isActivityFinishByUser = true;
        clearIMListener();
//                        unRegisterConfictReceiver();
        outHangOutRoomAndClearFlag();
        //退出直播间清除本地缓存信息
        clearUserInfoList();
    }

    protected void clearUserInfoList() {
        if (null != mIMManager) {
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
                onPushStreamDisconnect();
            }
        });
    }

    protected void onPushStreamDisconnect() {
        Log.d(TAG, "onPushStreamDisconnect");
    }

    //******************************** 礼物模块 ****************************************************************

    /**
     * 初始化礼物配置
     */
    public void initRoomGiftDataSet() {
        if (null != mIMHangoutRoomInItem && !TextUtils.isEmpty(mIMHangoutRoomInItem.roomId)) {
            mHangoutRoomGiftManager = new HangoutRoomGiftManager(mIMHangoutRoomInItem.roomId);

            //初始化礼物弹框（必须先于请求接口，否则同步不到礼物数据，后续修改此逻辑）
            initLiveGiftDialog();

            getHangoutRoomGiftList();
        }
    }

    /**
     * 点击reload响应
     */
    public void reloadLimitGiftData() {
        getHangoutRoomGiftList();
    }

    /**
     * 获取hangout直播间礼物列表
     */
    private void getHangoutRoomGiftList() {
        if (mHangoutRoomGiftManager != null) {
            mHangoutRoomGiftManager.getRoomGiftList(new OnGetHangoutGiftListCallback() {
                @Override
                public void onGetHangoutGiftList(boolean isSuccess, int errCode, String errMsg, HangoutGiftListItem item) {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            if (null != liveGiftDialog) {
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
    private void initLiveGiftDialog() {
        if (null == liveGiftDialog) {
            liveGiftDialog = new HangoutGiftDialog(this, mHangoutRoomGiftManager) {
                @Override
                public void reloadGiftData() {
                    super.reloadGiftData();

                    reloadLimitGiftData();
                }

                @Override
                public void addCredits() {
                    super.addCredits();

                    if (addCreditsDialog != null) {
                        addCreditsDialog.show();
                    }
                }

                @Override
                public void showNoCreditsDialog() {
                    super.showNoCreditsDialog();

//                    showNoCreditsTipDialog();
                    showCreditNoEnoughDialog(R.string.hangout_gift_send_no_credits_tip);
                }
            };

            if (null != mIMHangoutRoomInItem) {
                liveGiftDialog.setImHangoutRoomItem(mIMHangoutRoomInItem);
            }
        }
    }

//    /**
//     * 信用点不够的弹窗
//     */
//    protected void showNoCreditsTipDialog() {
////        // 引用系统的样式
////        AlertDialog.Builder builder = new AlertDialog.Builder(mContext);
////        builder.setMessage(mContext.getString(R.string.hangout_gift_send_no_credits_tip);
////        builder.setPositiveButton(mContext.getString(R.string.hand_out_add_credit), new DialogInterface.OnClickListener() {
////            @Override
////            public void onClick(DialogInterface dialog, int which) {
////                if (addCreditsDialog != null) {
////                    addCreditsDialog.show();
////                }
////            }
////        });
////        builder.setNegativeButton(mContext.getString(R.string.common_btn_cancel), null);
////        builder.create().show();
//
//
//        DialogUIUtils.showAlert(mContext, "", mContext.getString(R.string.hangout_gift_send_no_credits_tip),
//                mContext.getString(R.string.common_btn_cancel),
//                mContext.getString(R.string.hand_out_add_credit),
//                R.color.blue_color, R.color.blue_color, true, true, new DialogUIListener() {
//                    @Override
//                    public void onPositive() {
//
//                    }
//
//                    @Override
//                    public void onNegative() {
//                        if (addCreditsDialog != null) {
//                            addCreditsDialog.gotoAddCredits();
//                        }
//                    }
//                }).show();
//    }

    //--------------------------- 发送礼物 start -----------------------------

    protected void showHangoutGiftDialog() {
        //增加每次点击显示，如果本地数据刷新失败（即本地无数据）
        if (mHangoutRoomGiftManager != null) {
            HttpReqStatus sendableGiftReqStatus = mHangoutRoomGiftManager.getRoomGiftRequestStatus();
            if (sendableGiftReqStatus == HttpReqStatus.ResFailed
                    || sendableGiftReqStatus == HttpReqStatus.NoReq) {
                getHangoutRoomGiftList();
            }
        }

        // 2019/4/23 Hardy  每次打开都拿接口取最新信用点余额数，由于订单后台充值后，app 不会收到充值通知，故这里手动取接口刷新本地余额数
        loadCredits();

        if (liveGiftDialog != null) {
            liveGiftDialog.show();
        }

        //GA点击打开礼物列表
        onAnalyticsEvent(getResources().getString(R.string.Live_Broadcast_Category),
                getResources().getString(R.string.Live_Broadcast_Action_GiftList),
                getResources().getString(R.string.Live_Broadcast_Label_GiftList));
    }

    /**
     *
     * @param isAnchorMain
     * @param anchorItem
     */
    protected void addAnchor2GiftDialog(boolean isAnchorMain, HangoutAnchorInfoItem anchorItem){
        if(liveGiftDialog != null){
            liveGiftDialog.addAnchor(isAnchorMain, anchorItem);
        }
    }

    /**
     *
     * @param isAnchorMain
     * @param imHangoutAnchorItem
     */
    protected void addAnchor2GiftDialog(boolean isAnchorMain, IMHangoutAnchorItem imHangoutAnchorItem){
        if(liveGiftDialog != null){
            HangoutAnchorInfoItem anchorItem = new HangoutAnchorInfoItem(imHangoutAnchorItem.anchorId, imHangoutAnchorItem.nickName, imHangoutAnchorItem.photoUrl, 0, "", 0, "");
            liveGiftDialog.addAnchor(isAnchorMain, anchorItem);
        }
    }

    /**
     *
     * @param isAnchorMain
     * @param imRecvEnterRoomItem
     */
    protected void addAnchor2GiftDialog(boolean isAnchorMain, IMRecvEnterRoomItem imRecvEnterRoomItem){
        if(liveGiftDialog != null){
            HangoutAnchorInfoItem anchorItem = new HangoutAnchorInfoItem(imRecvEnterRoomItem.userId, imRecvEnterRoomItem.nickName, imRecvEnterRoomItem.photoUrl, 0, "", 0, "");
            liveGiftDialog.addAnchor(isAnchorMain, anchorItem);
        }
    }

    /**
     *
     * @param imRecvLeaveRoomItem
     */
    protected void removeAnchorInGiftDialog(IMRecvLeaveRoomItem imRecvLeaveRoomItem){
        if(liveGiftDialog != null){
            liveGiftDialog.hideAnchor(imRecvLeaveRoomItem.userId);
        }
    }

//    @Override
//    public void OnSendGift(boolean success, final IMClientListener.LCC_ERR_TYPE errType, String errMsg,
//                           IMMessageItem msgItem, double credit, double rebateCredit) {
//        super.OnSendGift(success, errType, errMsg, msgItem, credit, rebateCredit);
//        if (errType != IMClientListener.LCC_ERR_TYPE.LCC_ERR_SUCCESS) {
//            //需要查询是否是大礼物发送失败，提示用户
//            final Message msg = Message.obtain();
//            if (null != msgItem && null != msgItem.giftMsgContent) {
//                GiftItem giftDetail = NormalGiftManager.getInstance().getLocalGiftDetail(msgItem.giftMsgContent.giftId);
//                if (null != giftDetail && giftDetail.giftType == GiftItem.GiftType.Advanced) {
//                    msg.what = EVENT_GIFT_ADVANCE_SEND_FAILED;
//                    msg.obj = giftDetail.name;
//                    sendUiMessage(msg);
//                }
//            }
//        }
//    }

//    @Override
//    public void OnRecvAnchorGiftNotice(IMRecvHangoutGiftItem item) {
//        super.OnRecvAnchorGiftNotice(item);
//        if(!isCurrentRoom(item.roomId)){
//            return;
//        }
//        //生成聊天列表消息
//        Log.d(TAG,"OnRecvAnchorGiftNotice-isSecretly:"+item.isPrivate+" item:"+item);
//        IMUserBaseInfoItem infoItem = mIMManager.getUserInfo(item.toUid);
//        IMGiftMessageContent giftMsgContent = new IMGiftMessageContent(item.giftId, item.giftName, item.giftNum,
//                item.isMultiClick, item.multiClickStart, item.multiClickEnd, item.multiClickId,item.isPrivate);
//        IMMessageItem msgItem = new IMMessageItem(item.roomId, mIMManager.mMsgIdIndex.getAndIncrement(),
//                item.fromId, item.nickName, null, -1, IMMessageItem.MessageType.Gift,
//                new IMTextMessageContent(null == infoItem ? "" : infoItem.nickName), giftMsgContent);
//        sendMessageUpdateEvent(msgItem);
//        launchGiftAnimByMessage(item.toUid,msgItem);
//    }


    @Override
    public void OnRecvHangoutGiftNotice(IMMessageItem item) {
        super.OnRecvHangoutGiftNotice(item);

        if(!isCurrentRoom(item.roomId)){
            return;
        }
        //生成聊天列表消息
        Log.d(TAG,"OnRecvAnchorGiftNotice-isSecretly:"+item.isPrivate+" item:"+item);
//        IMUserBaseInfoItem infoItem = mIMManager.getUserInfo(item.toUid);
//        IMGiftMessageContent giftMsgContent = new IMGiftMessageContent(item.giftId, item.giftName, item.giftNum,
//                item.isMultiClick, item.multiClickStart, item.multiClickEnd, item.multiClickId,item.isPrivate);
//        IMMessageItem msgItem = new IMMessageItem(item.roomId, mIMManager.mMsgIdIndex.getAndIncrement(),
//                item.fromId, item.nickName, null, -1, IMMessageItem.MessageType.Gift,
//                new IMTextMessageContent(null == infoItem ? "" : infoItem.nickName), giftMsgContent);
//        sendMessageUpdateEvent(msgItem);
//        launchGiftAnimByMessage(item.toUid,msgItem);

        sendMessageUpdateEvent(item);
        launchGiftAnimByMessage(item.toUids,item);
    }

    /**
     * 启动礼物消息动画
     *
     * @param toUids
     * @param msgItem
     */
    protected void launchGiftAnimByMessage(String[] toUids, IMMessageItem msgItem) {
        Log.d(TAG, "launchGiftAnimByMessage-msgItem.fromUserId:" + msgItem.userId );
    }
    //--------------------------- 发送礼物 end -----------------------------

    //------------------------------ 推荐/邀请主播 start--------------------------------------
    @Override
    public void OnRecvDealInvitationHangoutNotice(IMDealInviteItem item) {
        super.OnRecvDealInvitationHangoutNotice(item);
        if(!isCurrentRoom(item.roomId)){
            return;
        }
        if(null != mIMManager){
            //主播同意进来，本地缓存各主播信息
            mIMManager.updateOrAddUserBaseInfo(new IMUserBaseInfoItem(item.anchorId,
                    item.nickName,item.photoUrl));
        }
    }

    @Override
    public void OnRecvAnchorCountDownEnterHangoutRoomNotice(IMHangoutCountDownItem item) {
        super.OnRecvAnchorCountDownEnterHangoutRoomNotice(item);
        Log.i(TAG,"OnRecvAnchorCountDownEnterHangoutRoomNotice");
    }

    //------------------------------ 推荐/邀请主播 end--------------------------------------

    //-----------------------------------文本消息-----------------------------------------

    /**
     * 回车键盘发送信息
     */
    protected boolean enterKey2SendMsg(String message, String targetId, String targetNickname) {
        if (TextUtils.isEmpty(message) || TextUtils.isEmpty(message.trim())) {
            return false;
        }
        Log.d(TAG, "enterKey2SendMsg-message:" + message + " targetId:" + targetId + " targetNickname:" + targetNickname);
//        long timeLosed = System.currentTimeMillis() - lastMsgSentTime;
//        Log.d(TAG,"enterKey2SendMsg-timeLosed:"+timeLosed);
//        if (timeLosed < getResources().getInteger(R.integer.minMsgSendTimeInterval)) {
        //2018年4月8日 15:30:35 Randy同Jasper和Martin商量不再需要1秒间隔的判断逻辑
//            showThreeSecondTips(getResources().getString(R.string.live_msg_send_tips), Gravity.CENTER);
//            return false;
//        }
//        lastMsgSentTime = System.currentTimeMillis();

        //2018年5月14日 15:15:07 多人直播间 发送文本消息时 不再插入@昵称文本内容，底层接口文本时会判断拼接 @ 用户
        //插入@昵称文本内容
//        if(null != targetNickname && !targetId.equals("0")){
//            StringBuilder sb = new StringBuilder("@");
//            sb.append(targetNickname);
//            sb.append(" ");
//            sb.append(message);
//            message = sb.toString();
//        }

        //聊天目标ID为0，则为 @All
        if (null != mIMHangoutRoomInItem && !TextUtils.isEmpty(mIMHangoutRoomInItem.roomId)) {
            IMMessageItem msgItem = mIMManager.sendHangoutRoomMessage(mIMHangoutRoomInItem.roomId, message,
                    targetId.equals("0") ? null : new String[]{targetId});
        }

        return true;
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
        if (!isCurrentRoom(msgItem.roomId)) {
            return;
        }
        sendMessageUpdateEvent(msgItem);
        if (null != msgItem && null != msgItem.sysNoticeContent
                && msgItem.sysNoticeContent.sysNoticeType == IMSysNoticeMessageContent.SysNoticeType.Warning) {
            if (!TextUtils.isEmpty(msgItem.sysNoticeContent.message)) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        showWarningDialog(msgItem.sysNoticeContent.message);
                    }
                });
            }
        }
    }

    protected void showWarningDialog(String warnContent) {
        Log.d(TAG, "showWarningDialog-warnContent:" + warnContent);
        if (null == warningDialog) {
            warningDialog = new WarningDialog(this);
        }
        warningDialog.show(warnContent);
    }

    /********************************* IMManager事件监听回调  *******************************************/
    @Override
    public void OnRecvRoomToastNotice(IMMessageItem msgItem) {
        if (!isCurrentRoom(msgItem.roomId)) {
            return;
        }
        super.OnRecvRoomToastNotice(msgItem);
        sendMessageUpdateEvent(msgItem);
    }

    @Override
    public void OnRecvRoomKickoffNotice(String roomId, final IMClientListener.LCC_ERR_TYPE err, final String errMsg, double credit, final IMAuthorityItem privItem) {
        if (!isCurrentRoom(roomId)) {
            return;
        }
        super.OnRecvRoomKickoffNotice(roomId, err, errMsg, credit, privItem);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                endLiveRoom(err, errMsg);
            }
        });
    }

    /**
     * 用户收到房间关闭通知
     *
     * @param roomId
     */
    @Override
    public void OnRecvRoomCloseNotice(String roomId, final IMClientListener.LCC_ERR_TYPE errType, final String errMsg, final IMAuthorityItem privItem) {
        super.OnRecvRoomCloseNotice(roomId, errType, errMsg, privItem);
        Log.i(TAG, "OnRecvRoomCloseNotice roomId:" + roomId + ",errType:" + errType + ",errMsg:" + errMsg);
        if (!isCurrentRoom(roomId)) {
            return;
        }
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                endLiveRoom(errType, errMsg);
            }
        });
    }

    //----------------------- 男士推流相关 start ----------------------
    /**
     * 开始视频推流
     */
    protected void startVideoPush() {
//        if (mIMRoomInItem != null) {
//            lastVideoInteractiveOperateType = IMClient.IMVideoInteractiveOperateType.Start;
//            if (isPublishing) {
//                lastVideoInteractiveOperateType = IMClient.IMVideoInteractiveOperateType.Close;
//            }
//            mVideoInteractionReqId = mIMManager.ControlManPush(mIMRoomInItem.roomId, lastVideoInteractiveOperateType);
//            if (IM_INVALID_REQID != mVideoInteractionReqId) {
//                //发出请求成功
//                flPublishOperate.setVisibility(View.GONE);
//                publishLoading.setVisibility(View.VISIBLE);
//            }
//        }

        if(mIMHangoutRoomInItem != null){
            mStartVideoPushReqId = mIMManager.ControlHangoutManPush(mIMHangoutRoomInItem.roomId, IMClient.IMVideoInteractiveOperateType.Start);
            mIsFirstTimePushVideo = false;
        }
    }

    /**
     * 停止视频推流
     */
    protected void stopVideoPush() {
        if(mIMHangoutRoomInItem != null){
            mStopVideoPushReqId = mIMManager.ControlHangoutManPush(mIMHangoutRoomInItem.roomId, IMClient.IMVideoInteractiveOperateType.Close);
        }
    }

    protected abstract void onStartVideoPushSuccess(String[] manPushUrl);
    protected abstract void onStartVideoPushFail(IMClientListener.LCC_ERR_TYPE errType, String errMsg );
    protected abstract void onStopVideoPushSuccess();

    /**
     * 释放流媒体资源占用
     */
    public void stopLSPubilsher() {
        Log.d(TAG, "stopLSPubilsher");
    }

    /**
     * 检测男士是否需要重新推流（断线重连，APP重启进入Hangout，调用）
     */
    protected void doCheckManPushReconnect(){
        //如果男士坐在位置上且推流被断开，则重连
        if(mIMHangoutRoomInItem.pushUrl !=null && mIMHangoutRoomInItem.pushUrl.length > 0 ){//&& mManPushDisconnect){
            startVideoPush();
        }
    }

    /**
     * 检测男士是否首次推流
     */
    protected boolean doCheckIsManPushFirstTime(){
        boolean pushFirstTime = true;
        if((mIMHangoutRoomInItem.pushUrl !=null && mIMHangoutRoomInItem.pushUrl.length > 0) || !mIsFirstTimePushVideo){
            pushFirstTime = false;
        }

        return pushFirstTime;
    }

    //----------------------- 男士推流相关 end ----------------------

    /**
     * 关闭直播间，跳转到结束页
     * @param err_type
     * @param description
     */
    protected void endLiveRoom(IMClientListener.LCC_ERR_TYPE err_type, String description){
        if(err_type == IMClientListener.LCC_ERR_TYPE.LCC_ERR_NO_CREDIT_CLOSE_LIVE
                || err_type == IMClientListener.LCC_ERR_TYPE.LCC_ERR_NO_CREDIT
                || err_type == IMClientListener.LCC_ERR_TYPE.LCC_ERR_NO_CREDIT_CLOSE_LIVE){
            endLiveRoom(HangoutEndActivity.HangoutEndType.ADD_CREDITS, true, true);
        }else {
            endLiveRoom(HangoutEndActivity.HangoutEndType.NORMAL, true, true);
        }
    }

    /**
     * 关闭直播间
     * @param isOpenEndActivity 是否跳转到结束页
     * @param isFinish 是否关闭自己
     */
    protected void endLiveRoom(HangoutEndActivity.HangoutEndType hangoutEndType, boolean isOpenEndActivity, boolean isFinish) {
        Log.i(TAG, "endLiveRoom");

        stopLSPubilsher();

        userCloseRoom();

        if(isOpenEndActivity){
            // TODO: 2019/3/21 Hardy 男士不需区分上次的 lastSwitchLiveRoomType ，因为男士中途不能被邀请去公开或私密直播间
            // mAnchorList 主播的数组，第一个 index ，必须为“主”主播
            // HangoutEndActivity.HangoutEndType    3 种情况
            //类型转换
            ArrayList<IMUserBaseInfoItem> imUserBaseInfoItems = new ArrayList<>();
            if(mIMHangoutRoomInItem != null){
                for (IMHangoutAnchorItem imHangoutAnchorItem:mIMHangoutRoomInItem.livingAnchorList){
                    IMUserBaseInfoItem imUserBaseInfoItem = new IMUserBaseInfoItem();
                    imUserBaseInfoItem.nickName = imHangoutAnchorItem.nickName;
                    imUserBaseInfoItem.photoUrl = imHangoutAnchorItem.photoUrl;
                    imUserBaseInfoItem.userId = imHangoutAnchorItem.anchorId;

                    imUserBaseInfoItems.add(imUserBaseInfoItem);
//            Log.i("Jagger" , "endLiveRoom imUserBaseInfoItem:" + imUserBaseInfoItem.nickName);
                }
            }

            HangoutEndActivity.startAct(mContext, imUserBaseInfoItems, hangoutEndType);
            finish();
        }else{
            if(isFinish){
                finish();
            }
        }

    }

    /**
     * 提供给基类处理自己结束页面前操作
     *
     * @param description
     */
    protected void preEndLiveRoom(String description) {
        Log.d(TAG, "preEndLiveRoom-description:" + description);
    }

    /**
     * 断线重连重新进入房间，视频模块处理
     */
    protected void onDisconnectRoomIn() {
        Log.d(TAG, "onDisconnectRoomIn");
        //拉流处理
        if (null != mIMHangoutRoomInItem) {
            //同步刷新礼物数据
            getHangoutRoomGiftList();
        }
    }

    @Override
    protected void onCreditUpdate() {
        super.onCreditUpdate();

        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                double total = LiveRoomCreditRebateManager.getInstance().getCredit();
                if (liveGiftDialog != null) {
                    liveGiftDialog.setCredits(total);
                }
            }
        });
    }

    @Override
    protected void onResume() {
        super.onResume();

        loadCredits();
    }

    protected void loadCredits(){
        // 2019/4/17 Hardy 刷新余额，避免充值买点之后没有刷新余额
        LiveRoomCreditRebateManager.getInstance().loadCredits(new OnGetAccountBalanceCallback() {
            @Override
            public void onGetAccountBalance(boolean isSuccess, int errCode, String errMsg, LSLeftCreditItem creditItem) {
                onCreditUpdate();
            }
        });
    }

    @Override
    public void OnSendHangoutGift(boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMMessageItem item, double credit) {
        super.OnSendHangoutGift(success, errType, errMsg, item, credit);

        Log.d(TAG, "OnSendHangoutGift: success: " + success + "-----> credit: " + credit);
        // 更新信用点
        if (errType == IMClientListener.LCC_ERR_TYPE.LCC_ERR_SUCCESS) {
            if (credit > 0) {
                LiveRoomCreditRebateManager.getInstance().setCredit(credit);
                onCreditUpdate();
            }
        }

        HttpRespObject object = new HttpRespObject(errType == IMClientListener.LCC_ERR_TYPE.LCC_ERR_SUCCESS,
                errType.ordinal(), errMsg, item);
        Message msg = Message.obtain();
        msg.obj = object;
        msg.what = EVENT_HANG_OUT_SEND_GIFT;
        sendUiMessage(msg);
    }

    /*******************************断线重连****************************************/
    @Override
    public void OnLogin(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
        super.OnLogin(errType, errMsg);
        //断线重连，需要拿roomId重新登录房间
        Log.d(TAG, "onIMAutoReLogined-mIMHangoutRoomInItem:" + mIMHangoutRoomInItem);
        if (errType == IMClientListener.LCC_ERR_TYPE.LCC_ERR_SUCCESS) {
            //断线重连成功才执行进入直播间逻辑
            HangOutGiftSender.getInstance().notifyIMReconnect();
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    if (null != mIMHangoutRoomInItem && !TextUtils.isEmpty(mIMHangoutRoomInItem.roomId)) {
                        if (null != mIMManager) {
                            int result = mIMManager.enterHangoutRoom(mIMHangoutRoomInItem.roomId);
                            Log.d(TAG, "onIMAutoReLogined-result:" + result);
                        }
                    }
                }
            });
        }
    }

//    @Override
//    protected void onScheduledInvitePushNotify(String roomId, IMUserBaseInfoItem userInfo) {
//        super.onScheduledInvitePushNotify(roomId, userInfo);
//        //预约私密到期push通知，主播点击确认切换直播间
//        lastSwitchLiveRoomId = roomId;
//        lastSwitchUserBaseInfoItem = userInfo;
//        lastSwitchLiveRoomType = LiveRoomType.AdvancedPrivateRoom;
//        runOnUiThread(new Runnable() {
//            @Override
//            public void run() {
//                exitHangOutLiveRoom();
//            }
//        });
//
//    }
//
//    @Override
//    protected void onManInvite2HangOutPushNotify(String invitationId, final IMUserBaseInfoItem userInfo) {
//        super.onManInvite2HangOutPushNotify(invitationId, userInfo);
//        LiveRequestOperator.getInstance().DealInvitationHangout(invitationId, HangoutInviteReplyType.AGREE, new OnDealInvitationHangoutCallback() {
//
//            @Override
//            public void onDealInvitationHangout(final boolean isSuccess, int errCode, final String errMsg, final String roomId) {
//                Log.d(TAG,"onManInvite2HangOutPushNotify-onDealInvitationHangout isSuccess:"+isSuccess
//                        +" errCode:"+errCode+" errMsg:"+errMsg+" roomId:"+roomId);
//                runOnUiThread(new Runnable() {
//                    @Override
//                    public void run() {
//                        if(isSuccess){
//                            lastSwitchUserBaseInfoItem = userInfo;
//                            lastSwitchLiveRoomId = roomId;
//                            lastSwitchLiveRoomType = LiveRoomType.HangoutRoom;
//                            exitHangOutLiveRoom();
//                        }else{
//                            if(!TextUtils.isEmpty(errMsg)){
//                                showToast(errMsg);
//                            }
//                        }
//                    }
//                });
//            }
//        });
//    }
//
//    @Override
//    protected void onAudienceInvitePushNotify(String invitationId, final IMUserBaseInfoItem userInfo) {
//        super.onAudienceInvitePushNotify(invitationId, userInfo);
//        //1.先走应邀流程
//        LiveRequestOperator.getInstance().AcceptInstanceInvite(invitationId, new OnAcceptInstanceInviteCallback() {
//            @Override
//            public void onAcceptInstanceInvite(final boolean isSuccess, final int errCode,
//                                               final String errMsg, final String roomId, final int roomType) {
//                Log.d(TAG,"onAudienceInvitePushNotify-onAcceptInstanceInvite isSuccess:"+isSuccess
//                        +" errCode:"+errCode+" errMsg:"+errMsg+" roomId:"+roomId+" roomType:"+roomType);
//                runOnUiThread(new Runnable() {
//                    @Override
//                    public void run() {
//                        if(isSuccess){
//                            lastSwitchUserBaseInfoItem = userInfo;
//                            lastSwitchLiveRoomId = roomId;
//                            lastSwitchLiveRoomType = IntToEnumUtils.intToLiveRoomType(roomType);
//                            exitHangOutLiveRoom();
//                        }else{
//                            if(!TextUtils.isEmpty(errMsg)){
//                                showToast(errMsg);
//                            }
//                        }
//                    }
//                });
//            }
//        });
//    }
//
//    //----------------------------------其他主播资料弹框及好友关系逻辑------------------------------
//    /**
//     * 其他主播资料弹框
//     */
//    protected OtherAnchorInfoDialog otherAnchorInfoDialog;
//
//    /**
//     * 展示主播资料弹框
//     * @param anchorId
//     */
//    public void showOtherAnchorInfoDialog(String anchorId){
//        Log.d(TAG,"showOtherAnchorInfoDialog-anchorId:"+anchorId);
//        if(null == otherAnchorInfoDialog){
//            otherAnchorInfoDialog = new OtherAnchorInfoDialog(this);
//            otherAnchorInfoDialog.setOutSizeTouchHasChecked(true);
//        }
//        otherAnchorInfoDialog.show(anchorId);
//        /**在show之后,加上如下这段代码就能解决宽被压缩的bug*/
//        WindowManager windowManager = getWindowManager();
//        Display defaultDisplay = windowManager.getDefaultDisplay();
//        WindowManager.LayoutParams attributes = otherAnchorInfoDialog.getWindow().getAttributes();
//        attributes.width = defaultDisplay.getWidth();
//        attributes.gravity = Gravity.BOTTOM;
//        otherAnchorInfoDialog.getWindow().setAttributes(attributes);
//    }

    /**
     * 10.4.接收推荐好友通知
     * add by Jagger 2018-5-17
     * @param item
     */
    @Override
    public void OnRecvRecommendHangoutNotice(IMHangoutRecommendItem item) {
        Log.d(TAG,"OnRecvAnchorRecommendHangoutNotice-item:"+item);
        IMMessageItem msgItem = new IMMessageItem(item.roomId ,
                mIMManager.mMsgIdIndex.getAndIncrement(),
                IMMessageItem.MessageType.AnchorRecommand,
                item);
        sendMessageUpdateEvent(msgItem);
    }

    @Override
    public void OnRecvKnockRequestNotice(IMRecvKnockRequestItem item) {
        Log.d(TAG,"OnRecvKnockRequestNotice-item:"+item);
        IMMessageItem msgItem = new IMMessageItem(item.roomId ,
                mIMManager.mMsgIdIndex.getAndIncrement(),
                IMMessageItem.MessageType.AnchorKnock,
                item);
        sendMessageUpdateEvent(msgItem);
    }

//    @Override
//    public void OnRecvRecommendHangoutNotice(IMHangoutRecommendItem item) {
//
//    }

    @Override
    public void OnEnterHangoutRoom(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMHangoutRoomItem item) {
        super.OnLeaveHangoutRoom(reqId, success, errType, errMsg);
        if(success && null != item && isCurrentRoom(item.roomId)){
            this.mIMHangoutRoomInItem = item;
        }
    }

    @Override
    public void OnLeaveHangoutRoom(int reqId, final boolean success,final IMClientListener.LCC_ERR_TYPE errType, final String errMsg) {
        super.OnLeaveHangoutRoom(reqId, success, errType, errMsg);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                endLiveRoom(errType , errMsg);
                if (!TextUtils.isEmpty(errMsg)) {
                    showToast(errMsg);
                }
            }
        });
    }

    @Override
    public void OnRecvEnterHangoutRoomNotice(IMRecvEnterRoomItem item) {
        super.OnRecvEnterHangoutRoomNotice(item);
        Log.i(TAG,"OnRecvEnterHangoutRoomNotice:" + item.nickName);
        if(!isCurrentRoom(item.roomId)){
            return;
        }
        if(null != mIMManager){
            mIMManager.updateOrAddUserBaseInfo(new IMUserBaseInfoItem(item.userId,
                    item.nickName,item.photoUrl));
            if(null != mIMHangoutRoomInItem ){//&& !TextUtils.isEmpty(mIMHangoutRoomInItem.userId)){
                //添加入场消息
                IMMessageItem msgItem = new IMMessageItem(item.roomId,
                        mIMManager.mMsgIdIndex.getAndIncrement(),
                        item.userId,
                        item.nickName,
                        item.photoUrl,
                        0,
                        IMMessageItem.MessageType.RoomIn,
                        new IMTextMessageContent(getResources().getString(R.string.enterlive_norider)), null);
                Message msg = Message.obtain();
                msg.what = EVENT_MESSAGE_UPDATE;
                msg.obj = msgItem;
                sendUiMessage(msg);
            }
        }
    }

    @Override
    public void OnRecvLeaveHangoutRoomNotice(IMRecvLeaveRoomItem item) {
        super.OnRecvLeaveHangoutRoomNotice(item);
        Log.i(TAG,"OnRecvLeaveHangoutRoomNotice:" + item.nickName);
        if(!isCurrentRoom(item.roomId)){
            return;
        }

        //如果主播离开
        if(item.isAnchor){
            //从主播列表中排除掉
            for (int i = 0; i < mIMHangoutRoomInItem.livingAnchorList.size(); i ++){
                if(mIMHangoutRoomInItem.livingAnchorList.get(i).anchorId.equals(item.userId)){
                    mIMHangoutRoomInItem.livingAnchorList.remove(i);
                    break;
                }
            }
        }
    }

    @Override
    public void OnRecvHangoutRoomMsg(IMMessageItem item) {
        super.OnRecvHangoutRoomMsg(item);
        Log.i(TAG, "OnRecvHangoutRoomMsg");
        if (!isCurrentRoom(item.roomId)) {
            return;
        }
        sendMessageUpdateEvent(item);
    }

    @Override
    public void OnControlManPushHangout(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType,
                                 String errMsg, String[] manPushUrl) {
        super.OnControlManPushHangout(reqId, success, errType, errMsg, manPushUrl);
        Log.i(TAG, "OnControlManPush reqId:" + reqId);
        //男士推流开始/停止回调，转化为更直接的回调事件给上层使用
        if(success){
            if( mStartVideoPushReqId == reqId && manPushUrl != null && manPushUrl.length > 0){
                onStartVideoPushSuccess(manPushUrl);
            }else if(mStopVideoPushReqId == reqId){
                onStopVideoPushSuccess();
            }
        }else{
            onStartVideoPushFail(errType , errMsg);
        }
    }

    @Override
    public void OnRecvLackCreditHangoutNotice(IMRecvLeaveRoomItem item) {
        super.OnRecvLackCreditHangoutNotice(item);

        //在IMManager的OnRecvLackCreditHangoutNotice中处理
//        if (!isCurrentRoom(item.roomId)) {
//            return;
//        }
//        String errMsg = getString(R.string.liveroom_noenough_money_tips_watching);
//        IMSysNoticeMessageContent msgContent = new IMSysNoticeMessageContent(errMsg, "", IMSysNoticeMessageContent.SysNoticeType.Normal);
//        IMMessageItem msgItem = new IMMessageItem(item.roomId, mIMManager.mMsgIdIndex.getAndIncrement(),"",
//                IMMessageItem.MessageType.SysNotice,msgContent);
//        sendMessageUpdateEvent(msgItem);
    }

    @Override
    public void OnRecvHangoutCreditRunningOutNotice(String roomId, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
        super.OnRecvHangoutCreditRunningOutNotice(roomId, errType, errMsg);
        Log.i(TAG,"OnRecvHangoutCreditRunningOutNotice");
        if (!hasShowCreditsLackTips) {
            hasShowCreditsLackTips = true;
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    showCreditNoEnoughDialog(R.string.liveroom_noenough_money_tips_watching);
                }
            });
        }
    }
}
