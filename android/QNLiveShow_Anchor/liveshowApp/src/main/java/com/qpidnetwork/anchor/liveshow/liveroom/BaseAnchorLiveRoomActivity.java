package com.qpidnetwork.anchor.liveshow.liveroom;

import android.content.DialogInterface;
import android.os.Bundle;
import android.os.Message;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.anchor.httprequest.LiveRequestOperator;
import com.qpidnetwork.anchor.httprequest.OnAcceptInstanceInviteCallback;
import com.qpidnetwork.anchor.httprequest.OnDealInvitationHangoutCallback;
import com.qpidnetwork.anchor.httprequest.OnRequestCallback;
import com.qpidnetwork.anchor.httprequest.item.AudienceBaseInfoItem;
import com.qpidnetwork.anchor.httprequest.item.AudienceInfoItem;
import com.qpidnetwork.anchor.httprequest.item.HangoutInviteReplyType;
import com.qpidnetwork.anchor.httprequest.item.IntToEnumUtils;
import com.qpidnetwork.anchor.httprequest.item.LiveRoomType;
import com.qpidnetwork.anchor.im.listener.IMClientListener;
import com.qpidnetwork.anchor.im.listener.IMMessageItem;
import com.qpidnetwork.anchor.im.listener.IMRoomInItem;
import com.qpidnetwork.anchor.im.listener.IMRoomInItem.IMLiveRoomType;
import com.qpidnetwork.anchor.im.listener.IMRoomInMessageContent;
import com.qpidnetwork.anchor.im.listener.IMSysNoticeMessageContent;
import com.qpidnetwork.anchor.im.listener.IMUserBaseInfoItem;
import com.qpidnetwork.anchor.liveshow.datacache.file.FileCacheManager;
import com.qpidnetwork.anchor.liveshow.datacache.file.downloader.FileDownloadManager;
import com.qpidnetwork.anchor.liveshow.datacache.file.downloader.IFileDownloadedListener;
import com.qpidnetwork.anchor.liveshow.liveroom.announcement.WarningDialog;
import com.qpidnetwork.anchor.liveshow.liveroom.barrage.IBarrageViewFiller;
import com.qpidnetwork.anchor.liveshow.liveroom.barrage.BarrageManager;
import com.qpidnetwork.anchor.liveshow.liveroom.car.CarInfo;
import com.qpidnetwork.anchor.liveshow.liveroom.car.CarManager;
import com.qpidnetwork.anchor.liveshow.liveroom.gift.ModuleGiftManager;
import com.qpidnetwork.anchor.liveshow.liveroom.gift.GiftSendReqManager;
import com.qpidnetwork.anchor.liveshow.liveroom.gift.GiftSender;
import com.qpidnetwork.anchor.liveshow.liveroom.gift.RoomGiftManager;
import com.qpidnetwork.anchor.liveshow.liveroom.gift.dialog.LiveGiftDialog;
import com.qpidnetwork.anchor.liveshow.liveroom.gift.normal.LiveGiftView;
import com.qpidnetwork.anchor.liveshow.liveroom.vedio.VedioLoadingAnimManager;
import com.qpidnetwork.anchor.liveshow.personal.chatemoji.ChatEmojiManager;
import com.qpidnetwork.anchor.utils.Log;
import com.qpidnetwork.anchor.utils.SystemUtils;
import com.squareup.picasso.MemoryPolicy;
import com.squareup.picasso.Picasso;

import net.qdating.LSPublisher;

import java.util.List;

import static com.qpidnetwork.anchor.im.IMManager.IM_INVALID_REQID;
import static com.qpidnetwork.anchor.im.listener.IMRoomInItem.IMLiveStatus.ReciprocalEnd;

/**
 * 直播间公共处理界面类
 * 1.通用的业务处理逻辑，放在当前Activity处理
 * 2.直播间界面操作及不同类型直播间界面的刷新展示放到子类activity处理
 * Created by Hunter Mun on 2017/6/16.
 */

public class BaseAnchorLiveRoomActivity extends BaseImplLiveRoomActivity implements LiveStreamPushManager.ILSPublisherStatusListener {
    /**
     * 直播间消息更新
     */
    private static final int EVENT_MESSAGE_UPDATE = 1001;

    /**
     * 接受观众进入直播间通知
     */
    public static final int EVENT_MESSAGE_ENTERROOMNOTICE = 1002;

    /**
     * 直播间观众数量更新
     */
    protected static final int EVENT_UPDATE_ONLINEFANSNUM = 1003;

    /**
     * 直播间关闭倒计时
     */
    protected static final int EVENT_LEAVING_ROOM_TIMECOUNT= 1005;

    /**
     * 直播间关闭倒计时
     */
    protected static final int EVENT_ANCHOR_SWITCH_ROOM_RETRY= 1006;

    /**
     * 才艺点播超时关闭
     */
    protected static final int EVENT_TALENT_OVER_TIME_CLOSE= 1007;

    public RoomThemeManager roomThemeManager = new RoomThemeManager();
    protected CarManager carManager;

    //聊天展示区域
    protected LiveRoomChatManager liveRoomChatManager;
    protected boolean isSoftInputOpen = false;
    protected int leavingRoomTimeCount = 30;//30-default

    //礼物列表
    protected ModuleGiftManager mModuleGiftManager;

    protected LiveGiftDialog liveGiftDialog;

    protected BarrageManager<IMMessageItem> mBarrageManager;

    //视频
    protected LiveStreamPushManager mLiveStreamPushManager;
    protected VedioLoadingAnimManager vedioLoadingAnimManager;
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
    protected boolean privateLiveInvitedByAnchor = false;
    //处理后台(即当前页不可用见时收到直播间关闭处理)
    protected int onLineDataReqStep = 0;

    protected GiftSender giftSender;
    protected GiftSendReqManager giftSendReqManager;

    //标识activity走onPause是否是用户主播关闭所致，是则隐藏surfaceView，避免在huawei nexus 6p的手机上出现闪一下黑框的问题
    protected boolean isActivityFinishByUser = false;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        TAG = BaseAnchorLiveRoomActivity.class.getName();
        initRoomManagers();
    }

    /**
     * 初始化各管理器模块
     */
    private void initRoomManagers(){
        //初始化播放器
        mLiveStreamPushManager = new LiveStreamPushManager(this);
        mLiveStreamPushManager.setILSPublisherStatusListener(this);
        carManager = new CarManager();
        mModuleGiftManager = new ModuleGiftManager(this);
        giftSendReqManager = new GiftSendReqManager();
        giftSendReqManager.executeNextReqTask();
        giftSender = new GiftSender(giftSendReqManager);
        LiveGiftView.MAX_GIFT_SUM = 2;
    }

    /**
     * 初始化数据
     */
    public void initData(){
        super.initData();
        onLineDataReqStep = getResources().getInteger(R.integer.liveroom_online_step);
        if(null != mIMRoomInItem){
            onLineDataReqStep = mIMRoomInItem.audienceLimitNum;
            giftSender.currRoomId = mIMRoomInItem.roomId;
            //添加主播头像信息,方便web端主播送礼时客户端能够在小礼物动画上展示其头像
            if(null != loginItem){
                mIMManager.updateOrAddUserBaseInfo(loginItem.userId,
                        loginItem.nickName,loginItem.photoUrl);
            }
            //初始化礼物弹框（必须先于请求接口，否则同步不到礼物数据，后续修改此逻辑）
            initLiveGiftDialog();
        }
        ChatEmojiManager.getInstance().getEmojiList(null);
    }

    @Override
    protected void onRoomAudienceChangeUpdate() {
        super.onRoomAudienceChangeUpdate();
        Message msg = Message.obtain();
        msg.what = EVENT_UPDATE_ONLINEFANSNUM;
        sendUiMessage(msg);
    }

    /**
     * 初始化主播视频流加载状态
     */
    protected void initVedioPlayerStatus(){
        //主播视频流加载
        if(null != vedioLoadingAnimManager){
            vedioLoadingAnimManager.showLoadingAnim();
        }
        if(null != mIMRoomInItem && mIMRoomInItem.pushRtmpUrls!=null && mIMRoomInItem.pushRtmpUrls.length > 0){
            startAnchorLivePusher(mIMRoomInItem.pushRtmpUrls);
        }
    }

    /**
     * 初始化视频加载动画管理器
     * @param animPlayerView
     */
    protected void initVedioLoadingAnimManager(ImageView animPlayerView){
        vedioLoadingAnimManager = new VedioLoadingAnimManager(animPlayerView);
    }

    /**
     * 初始化座驾管理器
     * @param rootView
     */
    protected void initLiveRoomCar(LinearLayout rootView){
        carManager.init(this, rootView,
                roomThemeManager.getRoomCarViewTxtColor(mIMRoomInItem.roomType)
                , roomThemeManager.getRoomCarViewBgDrawableResId(mIMRoomInItem.roomType));
    }

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
        IMMessageItem msgItem = null;
        if(null != targetNickname && !targetId.equals("0")){
            StringBuilder sb = new StringBuilder("@");
            sb.append(targetNickname);
            sb.append(" ");
            sb.append(message);
            message = sb.toString();
        }
        if(null != mIMRoomInItem && !TextUtils.isEmpty(mIMRoomInItem.roomId)){
            msgItem = mIMManager.sendRoomMsg(mIMRoomInItem.roomId, message,
                    targetId.equals("0") ? null : new String[]{targetId});
        }

        return true;
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        switch(msg.what){
            case EVENT_ANCHOR_SWITCH_ROOM_RETRY:
                switchLiveRoom();
                break;
            case EVENT_LEAVING_ROOM_TIMECOUNT:
                //关闭直播间倒计时，仅处理界面倒计时的展示逻辑,跳转逻辑放到OnRecvRoomCloseNotice中统一处理
                if(leavingRoomTimeCount>=0){
                    updateRoomCloseTimeCount(leavingRoomTimeCount);
                    leavingRoomTimeCount-=1;
                    sendEmptyUiMessageDelayed(EVENT_LEAVING_ROOM_TIMECOUNT,1000l);
                }
                break;
            case EVENT_UPDATE_ONLINEFANSNUM:
                //房间人数更新完全依赖获取联系人列表，解决获取联系人列表失败，导致显示房间人数和头像数目不一致问题
//                updatePublicOnLineNum(mRoomAudienceNum);
                updatePublicRoomOnlineData();
                break;
            case EVENT_MESSAGE_ENTERROOMNOTICE: {
                final CarInfo carInfo = (CarInfo) msg.obj;
                if (!TextUtils.isEmpty(carInfo.riderUrl) && !TextUtils.isEmpty(carInfo.riderId)
                        && !TextUtils.isEmpty(carInfo.riderName)) {
                    //聊天区域插入座驾进入直播间消息
                    final String honorImg = msg.getData().getString("honorImg");
                    //判断并播放入场座驾动画
                    carInfo.riderLocalPath = FileCacheManager.getInstance()
                            .parseCarImgLocalPath(carInfo.riderId, carInfo.riderUrl);
                    Log.d(TAG, "EVENT_MESSAGE_ENTERROOMNOTICE-riderId:" + carInfo.riderId
                            + " riderLocalPath:" + carInfo.riderLocalPath);
                    if (TextUtils.isEmpty(carInfo.riderLocalPath)) {
                        return;
                    }
                    boolean localCarImgExists = SystemUtils.fileExists(carInfo.riderLocalPath);
                    Log.d(TAG,"EVENT_MESSAGE_ENTERROOMNOTICE-localCarImgExists:"+localCarImgExists);
                    if (localCarImgExists) {
                        IMMessageItem msgItem = new IMMessageItem(mIMRoomInItem.roomId,
                                mIMManager.mMsgIdIndex.getAndIncrement(),
                                IMMessageItem.MessageType.RoomIn,
                                new IMRoomInMessageContent(carInfo.nickName,
                                        carInfo.riderId,carInfo.riderName,carInfo.riderLocalPath));
                        //add Jagger 2018-5-8
                        msgItem.userId = carInfo.userId;
                        sendMessageUpdateEvent(msgItem);
                        if(null != carManager){
                            carManager.putLiveRoomCarInfo(carInfo);
                        }
                    } else {
                        FileDownloadManager.getInstance().start(carInfo.riderUrl,
                                carInfo.riderLocalPath,
                                new IFileDownloadedListener() {
                                    @Override
                                    public void onCompleted(boolean isSuccess, String localFilePath, String fileUrl) {
                                        Log.d(TAG, "EVENT_MESSAGE_ENTERROOMNOTICE-onCompleted-isSuccess:" + isSuccess
                                                + " localFilePath:" + localFilePath);
                                        if (isSuccess) {
                                            Message msg = Message.obtain();
                                            msg.what = EVENT_MESSAGE_ENTERROOMNOTICE;
                                            msg.obj = carInfo;
                                            Bundle bundle = msg.getData();
                                            bundle.putString("honorImg",honorImg);
                                            bundle.putBoolean("playCarInAnimAfterDownImg",true);
                                            msg.setData(bundle);
                                            sendUiMessage(msg);
                                        }
                                    }
                                });
                    }
                }

            }break;
            case EVENT_MESSAGE_UPDATE:
                IMMessageItem msgItem = (IMMessageItem)msg.obj;
                if(msgItem != null && msgItem.msgId > 0){
                    //更新消息列表
                    if(null != liveRoomChatManager){
                        liveRoomChatManager.addMessageToList(msgItem);
                    }
                    //启动消息特殊处理
                    launchAnimationByMessage(msgItem);
                }
                break;
        }
    }

    /**
     * 更新公开直播间在线观众头像数据
     * @param audienceList
     */
    protected void updatePublicOnLinePic(AudienceInfoItem[] audienceList){
        Log.d(TAG,"updatePublicOnLinePic");
        //更新对应观众的购票标记
        if(audienceList != null){
            for (AudienceInfoItem audienceInfoItem:audienceList) {
//                IMUserBaseInfoItem imUserBaseInfoItem = mIMManager.getUserInfo(audienceInfoItem.userId);
//                if(imUserBaseInfoItem != null){
//                    imUserBaseInfoItem.isHasTicket = audienceInfoItem.isHasTicket;
//                    mIMManager.updateOrAddUserBaseInfo(imUserBaseInfoItem);
//                    return;
//                }

                mIMManager.updateOrAddUserBaseInfo(new IMUserBaseInfoItem(audienceInfoItem.userId, audienceInfoItem.nickName, audienceInfoItem.photoUrl, audienceInfoItem.isHasTicket));
            }
        }
    }

    /**
     * 更新公开直播间在线人数
     * @param fansNum
     */
    protected void updatePublicOnLineNum(int fansNum){
        Log.d(TAG,"updatePublicOnLineNum-fansNum:"+fansNum);
    }

    /**
     * 消息切换主线程
     * @param msgItem
     */
    public void sendMessageUpdateEvent(IMMessageItem msgItem){
        Log.d(TAG,"sendMessageUpdateEvent");
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

    protected void switchCamera(){
        if(null != mLiveStreamPushManager && mLiveStreamPushManager.isInited()){
            mLiveStreamPushManager.switchCamera();
        }
    }

    private void releaseLSPManager(){
        Log.d(TAG,"releaseLSPManager");
        if(mLiveStreamPushManager != null){
            mLiveStreamPushManager.setILSPublisherStatusListener(null);
            mLiveStreamPushManager.stop();
            mLiveStreamPushManager.release();
            mLiveStreamPushManager = null;
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        //回收拉流播放器
        releaseLSPManager();
        carManager.shutDownAnimQueueServNow();
        carManager = null;
        mModuleGiftManager.onMultiGiftDestroy();
        //清除资源及动画
        if(mBarrageManager != null) {
            mBarrageManager.onDestroy();
        }
        //退出房间成功，就清空送礼队列，并停止服务
        if(null != giftSendReqManager){
            giftSendReqManager.shutDownReqQueueServNow();
        }
        removeUiMessages(EVENT_LEAVING_ROOM_TIMECOUNT);
        removeUiMessages(EVENT_ANCHOR_SWITCH_ROOM_RETRY);

        if(null != vedioLoadingAnimManager){
            vedioLoadingAnimManager.hideLoadingAnim();
        }
        if(null != liveRoomChatManager){
            liveRoomChatManager.setOnRoomMsgListClickListener(null);
        }
        if(null != liveGiftDialog){
            liveGiftDialog.unregisterIMLiveRoomEventListener();
        }
        //处理push分组或外部链接打开直接重启应用，导致直播间无法正常关闭问题
        if((mIMRoomInItem != null) && (mIMManager != null)){
            mIMManager.roomOutAndClearFlag(mIMRoomInItem.roomId);
        }
    }

    /**
     * 关闭直播间
     */
    public void closeLiveRoom(){
        Log.d(TAG,"closeLiveRoom");
        isActivityFinishByUser = true;
        if(null != mIMRoomInItem && !TextUtils.isEmpty(mIMRoomInItem.roomId) && null != mIMManager){
            mIMManager.RoomOut(mIMRoomInItem.roomId);
        }
    }

    /**
     * 主播切换直播间
     */
    protected void switchLiveRoom(){
        Log.d(TAG,"switchLiveRoom-lastSwitchLiveRoomId:"+lastSwitchLiveRoomId);
        if(!TextUtils.isEmpty(lastSwitchLiveRoomId)){
            LiveRequestOperator.getInstance().SetRoomCountDown(lastSwitchLiveRoomId, new OnRequestCallback() {
                @Override
                public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                    Log.d(TAG,"switchLiveRoom-onRequest isSuccess:"+isSuccess+" errCode:"+errCode+" errMsg:"+errMsg);
                    //成功，则等待IM 3.8直播间关闭倒数通知,这是保持closeRoomByUser为true，避免主播再次手动关闭
                    //失败，则间隔3秒后重试，此时大部分情况下处于断网状态，那么仍旧保持closeRoomByUser为true
                    if(!isSuccess){
                        sendEmptyUiMessageDelayed(EVENT_ANCHOR_SWITCH_ROOM_RETRY,3000l);
                    }
                }
            });
        }
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        Log.d(TAG,"onKeyDown-keyCode:"+keyCode+" event.action:"+event.getAction());
        if(keyCode == KeyEvent.KEYCODE_BACK && event.getAction() == KeyEvent.ACTION_DOWN){
            //add by Jagger 2018-5-9
            //取消响应返回按钮
            if(mIMRoomInItem.liveShowType == IMRoomInItem.IMPublicRoomType.Program){
                return true;
            }

            if(!hasRoomInClosingStatus){
                lastSwitchLiveRoomId = null;
                lastSwitchUserBaseInfoItem = null;
                lastSwitchLiveRoomType = LiveRoomType.Unknown;
                userCloseRoom();
            }
            return true;
        }
        return super.onKeyDown(keyCode, event);
    }

    /**
     * 用户手动点击退出直播间
     */
    protected void userCloseRoom(){
        showSimpleTipsDialog(0,R.string.liveroom_close_room_notify,
                R.string.common_btn_cancel,R.string.common_btn_sure,
                null,new DialogInterface.OnClickListener(){

                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        closeLiveRoom();
                    }
                });
    }

    @Override
    public void OnRecvLeavingPublicRoomNotice(String roomId, int leftSeconds, IMClientListener.LCC_ERR_TYPE err, String errMsg) {
        super.OnRecvLeavingPublicRoomNotice(roomId, leftSeconds, err, errMsg);
        if(!isCurrentRoom(roomId)){
            return;
        }
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                onRecvLeavingRoomNotice();
            }
        });
    }

    public void onRecvLeavingRoomNotice(){
        hasRoomInClosingStatus = true;
        Log.d(TAG,"onRecvLeavingRoomNotice-hasRoomInClosingStatus:"+hasRoomInClosingStatus+" lastInviteSendSucManNickName:"+lastInviteSendSucManNickName);
        removeUiMessages(EVENT_LEAVING_ROOM_TIMECOUNT);
        sendEmptyUiMessageDelayed(EVENT_LEAVING_ROOM_TIMECOUNT,0l);
    }

    public void updateRoomCloseTimeCount(int timeCount){
        Log.d(TAG,"updateRoomCloseTimeCount-timeCount:"+timeCount);
    }

    @Override
    public void OnLogout(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
        super.OnLogout(errType, errMsg);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                //断线互动视频处理
                onPullStreamDisconnect();
                //仅仅是IM断线，Toast提示
                if(isActivityVisible()) {
                    showToast(getResources().getString(R.string.live_push_stream_network_poor));
                }
                if(mLiveStreamPushManager != null){
                    //推流器内部先stop后start，那么界面展示就是先show loading后再hide loading推流
                    mLiveStreamPushManager.onLogout();
                }

            }
        });
    }

    public void onPullStreamDisconnect(){
        Log.d(TAG,"onPullStreamDisconnect");
    }

    //******************************** 顶部房间信息模块 ****************************************************************
    @Override
    public void OnRoomIn(int reqId, final boolean success, IMClientListener.LCC_ERR_TYPE errType,
                         final String errMsg, final IMRoomInItem roomInfo) {
        super.OnRoomIn(reqId,success,errType,errMsg,roomInfo);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if(!success){
                    //Samson:断线重连，重新调用RoomIn命令接口返回失败，视作退出直播间
                    //直接跳转到直播间结束页面
                    endLiveRoom(errMsg);
                    return;
                }else {
                    onLineDataReqStep = roomInfo.audienceLimitNum;
                }

                onDisconnectRoomIn();
            }
        });
    }

    /**
     * 刷新直播间观众头像列表
     */
    public void updatePublicRoomOnlineData(){
        Log.d(TAG,"updatePublicRoomOnlineData");
        if(null != mIMRoomInItem && (mIMRoomInItem.roomType==IMLiveRoomType.FreePublicRoom
                ||mIMRoomInItem.roomType==IMLiveRoomType.PaidPublicRoom)){
            //查询头像列表
            LiveRequestOperator.getInstance().GetAudienceListInRoom(mIMRoomInItem.roomId,0,onLineDataReqStep,this);
        }
    }

    @Override
    public void onGetAudienceList(boolean isSuccess, int errCode, String errMsg, final AudienceInfoItem[] audienceList) {
        super.onGetAudienceList(isSuccess,errCode,errMsg,audienceList);
        if(isSuccess){
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    updatePublicOnLinePic(audienceList);
                }
            });
        }
    }

    //******************************** 视频播放组件 ****************************************************************
    /**
     * 开始拉流
     * @param videoUrls
     */
    protected void startAnchorLivePusher(String[] videoUrls){
        if(mLiveStreamPushManager != null && mLiveStreamPushManager.isInited() && videoUrls.length > 0){
            mLiveStreamPushManager.setOrChangeManUploadUrls(videoUrls, "", "");
        }
    }

    //******************************** 礼物模块 ****************************************************************

    /**
     * 必须先初始化dialog，防止接口数据刷新不能同步到dialog（后续修改次逻辑）
     */
    private void initLiveGiftDialog(){
        if(liveGiftDialog == null){
            liveGiftDialog = new LiveGiftDialog(this, new RoomGiftManager(mIMRoomInItem.roomId),giftSender);
            liveGiftDialog.registerIMLiveRoomEventListener();
        }
    }

    protected void showLiveGiftDialog(){
        Log.d(TAG,"showLiveGiftDialog");
        if(liveGiftDialog != null) {
            liveGiftDialog.show();
        }
        //GA点击打开礼物列表
        onAnalyticsEvent(getResources().getString(R.string.Live_Broadcast_Category),
                getResources().getString(R.string.Live_Broadcast_Action_GiftList),
                getResources().getString(R.string.Live_Broadcast_Label_GiftList));
    }


    @Override
    public void OnRecvRoomGiftNotice(IMMessageItem msgItem) {
        if(!isCurrentRoom(msgItem.roomId)){
            return;
        }
        super.OnRecvRoomGiftNotice(msgItem);
        sendMessageUpdateEvent(msgItem);
    }

    @Override
    public void OnRecvEnterRoomNotice(String roomId, String userId, String nickName,
                                      String photoUrl, String riderId, String riderName,
                                      String riderUrl, int fansNum, boolean isHasTicket) {
        super.OnRecvEnterRoomNotice(roomId,userId,nickName,photoUrl,riderId,riderName,riderUrl,fansNum,isHasTicket);
        if(!isCurrentRoom(roomId)){
            return;
        }
        Log.d(TAG,"OnRecvEnterRoomNotice-userId:"+userId);
        if(!TextUtils.isEmpty(userId) && null != mIMRoomInItem && userId.equals(mIMRoomInItem.anchorId)){
            //断线重登陆，接收到自己的进入房间通知，过滤处理
            Log.d(TAG,"OnRecvEnterRoomNotice-断线重登陆，接收到自己的进入房间通知，过滤处理");
            return;
        }

        //add by Jagger 2018-5-8
        if(mIMManager != null){
            mIMManager.updateOrAddUserBaseInfo(new IMUserBaseInfoItem(userId , nickName , photoUrl, isHasTicket ));
        }

        addEnterRoomMsgToList(roomId,userId,nickName,riderId,riderName,riderUrl,"");
    }

    /**
     * 启动消息动画
     * @param msgItem
     */
    private void launchAnimationByMessage(IMMessageItem msgItem){
        if(msgItem != null){
            //观众发送礼物/弹幕的头像，使用3.12.获取指定观众信息（http post）接口，
            // 昵称使用5.2.接收直播间礼物通知（Server -> Client）接口和6.2接收直播间弹幕通知（Server -> Client）接口
            if(msgItem.msgType == IMMessageItem.MessageType.Barrage
                    || msgItem.msgType == IMMessageItem.MessageType.Gift){
                IMUserBaseInfoItem baseInfo = mIMManager.getUserInfo(msgItem.userId);
                if(null == baseInfo){
                    LiveRequestOperator.getInstance().GetAudienceDetailInfo(msgItem.userId,this);
                }
            }

            switch (msgItem.msgType){
                case Barrage:{
                    addBarrageItem(msgItem);
                }break;
                case Gift:{
                    mModuleGiftManager.dispatchIMMessage(msgItem);
                }break;
                default:
                    break;
            }
        }
    }

    /**
     * 插入直播间用户入场消息
     */
    protected void addEnterRoomMsgToList(String roomId,String userId,String nickName,String riderId,
                                         String riderName, String riderUrl,String honorImg){
        Log.d(TAG,"addEnterRoomMsgToList-roomId:"+roomId+" userId:"+userId+" nickName:"+nickName
                +" riderId:"+riderId+" riderName:"+riderName+" riderUrl:"+riderUrl+" honorImg:"+honorImg);
        Message msg = null;
        if(!TextUtils.isEmpty(riderId)){
            CarInfo carInfo = new CarInfo(nickName,userId,riderId,riderName,riderUrl);
            msg = Message.obtain();
            msg.what = EVENT_MESSAGE_ENTERROOMNOTICE;
            Bundle bundle = msg.getData();
            bundle.putString("honorImg",honorImg);
            msg.setData(bundle);
            msg.obj = carInfo;
            sendUiMessage(msg);
        }else{
            IMMessageItem msgItem = new IMMessageItem(roomId,
                    mIMManager.mMsgIdIndex.getAndIncrement(),
                    IMMessageItem.MessageType.RoomIn,
                    new IMRoomInMessageContent(nickName,null,null,null));
            //add by Jagger 2018-5-8
            //需要这个ID， 判断他是否有买票
            if(!TextUtils.isEmpty(userId)){
                msgItem.userId = userId;
            }

            msg = Message.obtain();
            msg.what = EVENT_MESSAGE_UPDATE;
            msg.obj = msgItem;
            sendUiMessage(msg);
        }
    }

    @Override
    public void onGetAudienceDetailInfo(boolean isSuccess, int errCode, String errMsg, AudienceBaseInfoItem audienceInfo) {
        super.onGetAudienceDetailInfo(isSuccess, errCode, errMsg, audienceInfo);
        Message msg = null;
        Log.d(TAG,"onGetAudienceDetailInfo-audienceInfo.userId:"+audienceInfo.userId);
        //接收到送礼通知userbaseinfomap里面获取不到的时候更新指定观众id的
        if(isSuccess && null != audienceInfo && null != mIMManager){
            mIMManager.updateOrAddUserBaseInfo(audienceInfo.userId,audienceInfo.nickName,audienceInfo.photoUrl);
        }
    }

    @Override
    public void OnRecvRoomMsg(IMMessageItem msgItem) {
        super.OnRecvRoomMsg(msgItem);
        if(!isCurrentRoom(msgItem.roomId)){
            return;
        }
        Log.d(TAG,"OnRecvRoomMsg-msgItem:"+msgItem);
        sendMessageUpdateEvent(msgItem);
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

    /**
     * 初始化弹幕
     */
    protected void initBarrage(List<View> listViews, View ll_bulletScreen){
        mBarrageManager = new BarrageManager<IMMessageItem>(this, listViews,ll_bulletScreen);
        mBarrageManager.setBarrageFiller(new IBarrageViewFiller<IMMessageItem>() {
            @Override
            public void onBarrageViewFill(View view, IMMessageItem item) {
                CircleImageView civ_bullletIcon = (CircleImageView) view.findViewById(R.id.civ_bullletIcon);
                TextView tv_bulletName = (TextView) view.findViewById(R.id.tv_bulletName);
                TextView tv_bulletContent = (TextView) view.findViewById(R.id.tv_bulletContent);
                if(item != null){
                    tv_bulletName.setText(item.nickName);
                    tv_bulletContent.setText(ChatEmojiManager.getInstance().parseEmoji(BaseAnchorLiveRoomActivity.this,
                            TextUtils.htmlEncode(getResources().getString(R.string.live_bullet_content,item.textMsgContent.message)),
                            ChatEmojiManager.PATTERN_MODEL_SIMPLESIGN,
                            (int)getResources().getDimension(R.dimen.liveroom_messagelist_barrage_width),
                            (int)getResources().getDimension(R.dimen.liveroom_messagelist_barrage_height)));
                    String photoUrl = null;
                    if(null != mIMManager){
                        IMUserBaseInfoItem baseInfo = mIMManager.getUserInfo(item.userId);
                        if(baseInfo != null){
                            photoUrl = baseInfo.photoUrl;
                        }
                    }
                    if(!TextUtils.isEmpty(photoUrl)){
                        Picasso.with(BaseAnchorLiveRoomActivity.this.getApplicationContext())
                                .load(photoUrl)
                                .placeholder(R.drawable.ic_default_photo_man)
                                .error(R.drawable.ic_default_photo_man)
                                .memoryPolicy(MemoryPolicy.NO_CACHE)
                                .into(civ_bullletIcon);
                    }else{
                        civ_bullletIcon.setImageResource(R.drawable.ic_default_photo_man);
                    }
                }
            }
        });
    }

    /**
     * 添加弹幕动画
     * @param msgItem
     */
    private void addBarrageItem(IMMessageItem msgItem){
        if(msgItem != null){
            mBarrageManager.addBarrageItem(msgItem);
        }
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
        //主播点击视频左上角关闭按钮、按下物理返回键、接受/发送立即私密邀请或者预约私密跳转等情况均属于主动关闭直播间的情况
        //且这些情况下服务器都会有一个同客户端相同时间间隔(30s)的定时器，定时器会下发OnRecvRoomCloseNotice通知
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                endLiveRoom(errMsg);
            }
        });
    }

    @Override
    public void OnRecvAnchorLeaveRoomNotice(String roomId, String anchorId) {
        super.OnRecvAnchorLeaveRoomNotice(roomId, anchorId);
        //Martin:收到这个通知直接关闭直播间，不跳转直播间结束页面
        if(!isCurrentRoom(roomId)){
            return;
        }
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if(mLiveStreamPushManager != null) {
                    mLiveStreamPushManager.setILSPublisherStatusListener(null);
                    mLiveStreamPushManager.stop();
                }
                finish();
            }
        });
    }

    /**
     * 关闭直播间，跳转到结束页
     * @param description
     */
    public void endLiveRoom(String description){
        boolean isShowRecommand = false;
        if(mLiveStreamPushManager != null) {
            mLiveStreamPushManager.setILSPublisherStatusListener(null);
            mLiveStreamPushManager.stop();
        }
        //主动关闭的情况不用考虑activity是否处于前台，毕竟这种情况下基本都是主播手动触发
        Log.d(TAG,"endLiveRoom-isShowRecommand:"+isShowRecommand
                +" lastSwitchLiveRoomId:"+lastSwitchLiveRoomId+" lastSwitchLiveRoomType:"+lastSwitchLiveRoomType);
        if(!TextUtils.isEmpty(lastSwitchLiveRoomId)){
            if(LiveRoomType.NormalPrivateRoom == lastSwitchLiveRoomType
                    || LiveRoomType.AdvancedPrivateRoom == lastSwitchLiveRoomType){
                startActivity(LiveRoomTransitionActivity.getEnterRoomIntent(
                        BaseAnchorLiveRoomActivity.this,
                        lastSwitchUserBaseInfoItem.userId,
                        lastSwitchUserBaseInfoItem.nickName,
                        lastSwitchUserBaseInfoItem.photoUrl,
                        lastSwitchLiveRoomId));
            }else if(LiveRoomType.HangoutRoom == lastSwitchLiveRoomType){
                startActivity(HangOutRoomTransActivity.getEnterRoomIntent(
                        BaseAnchorLiveRoomActivity.this,
                        lastSwitchUserBaseInfoItem.userId,
                        lastSwitchUserBaseInfoItem.nickName,
                        lastSwitchUserBaseInfoItem.photoUrl,
                        lastSwitchLiveRoomId));
            }
        }else {
            //私密男士结束当前直播间
            preEndLiveRoom(description);
        }
        //退出直播间置空房间信息对象
        mIMRoomInItem = null;
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
     * 更改直播间状态为结束倒计时状态
     */
    protected void changeRoomTimeCountEndStatus() {
        Log.d(TAG,"changeRoomTimeCountEndStatus");
        if(null !=mIMRoomInItem){
            Log.d(TAG,"changeRoomTimeCountEndStatus-leavingRoomTimeCount:"+leavingRoomTimeCount
                    +" leftSeconds:"+mIMRoomInItem.leftSeconds+" status:"+mIMRoomInItem.status.name());
            if(null !=mIMRoomInItem &&  mIMRoomInItem.leftSeconds>0
                    && mIMRoomInItem.status==ReciprocalEnd) {
                leavingRoomTimeCount = mIMRoomInItem.leftSeconds;
                onRecvLeavingRoomNotice();
            }
        }
    }

    /**
     * 断线重连重新进入房间，视频模块处理
     */
    protected void onDisconnectRoomIn(){
        Log.d(TAG,"onDisconnectRoomIn");
        //拉流处理
        if(null != mIMRoomInItem){
            changeRoomTimeCountEndStatus();
            if(mIMRoomInItem.pushRtmpUrls != null){
                startAnchorLivePusher(mIMRoomInItem.pushRtmpUrls);
            }
            //同步刷新礼物数据
            if(null != liveGiftDialog){
                liveGiftDialog.getRoomGiftList();
            }
        }
    }

    /*******************************断线重连****************************************/
    @Override
    public void OnLogin(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
        super.OnLogin(errType, errMsg);
        //断线重连，需要拿roomId重新登录房间
        Log.d(TAG,"onIMAutoReLogined-mIMRoomInItem:"+mIMRoomInItem);
        if(errType == IMClientListener.LCC_ERR_TYPE.LCC_ERR_SUCCESS) {
            //断线重连成功才执行进入直播间逻辑
            giftSender.notifyIMReconnect();
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    if (null != mIMRoomInItem && !TextUtils.isEmpty(mIMRoomInItem.roomId)) {
                        if (null != mIMManager) {
                            int result = mIMManager.RoomIn(mIMRoomInItem.roomId);
                            Log.d(TAG, "onIMAutoReLogined-result:" + result + " IM_INVALID_REQID:" + IM_INVALID_REQID);
                        }
                    }
                }
            });
        }
    }

    @Override
    protected void onStop() {
        super.onStop();
        //开启计时器
        Log.d(TAG,"onStop");
        if(null != mModuleGiftManager){
            mModuleGiftManager.stopAdvanceGiftAnim();
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        Log.d(TAG,"onResume");
    }

    @Override
    public void OnRecvInteractiveVideoNotice(final String roomId, final String userId, final String nickname, final String avatarImg,
                                             final IMClientListener.IMVideoInteractiveOperateType operateType,
                                             final String[] pushUrls) {
        super.OnRecvInteractiveVideoNotice(roomId, userId, nickname, avatarImg, operateType, pushUrls);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                onManVedioPushStatusChanged(roomId,userId,nickname,avatarImg,operateType,pushUrls);
            }
        });
    }

    /**
     * 男士互动视频推流状态发生更改
     * @param roomId
     * @param userId
     * @param nickname
     * @param avatarImg
     * @param operateType
     * @param pushUrls
     */
    public void onManVedioPushStatusChanged(String roomId, String userId, String nickname, String avatarImg,
                                            final IMClientListener.IMVideoInteractiveOperateType operateType,
                                            final String[] pushUrls){
        Log.d(TAG,"onManVedioPushStatusChanged-roomId:"+roomId+" userId:"+userId+" nickname:"+nickname
                +" operateType:"+operateType);
    }

    @Override
    protected void onScheduledInvitePushNotify(String roomId, IMUserBaseInfoItem userInfo) {
        super.onScheduledInvitePushNotify(roomId, userInfo);
        //预约私密到期push通知，主播点击确认切换直播间
        lastSwitchLiveRoomId = roomId;
        lastSwitchUserBaseInfoItem = userInfo;
        lastSwitchLiveRoomType = LiveRoomType.AdvancedPrivateRoom;
        switchLiveRoom();
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
                            lastSwitchLiveRoomId = roomId;
                            lastSwitchLiveRoomType = LiveRoomType.HangoutRoom;
                            lastSwitchUserBaseInfoItem = userInfo;
                            switchLiveRoom();
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
                            switchLiveRoom();
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
    public void onPushStreamConnect(LSPublisher lsPublisher) {
        Log.d(TAG,"onPushStreamConnect-hasVedioDisconTipsAgain:"+hasVedioDisconTipsAgain);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (null != vedioLoadingAnimManager) {
                    vedioLoadingAnimManager.hideLoadingAnim();
                    hasVedioDisconTipsAgain = false;
                }
            }
        });
    }

    @Override
    public void onPushStreamDisconnect(LSPublisher lsPublisher) {
        Log.d(TAG,"onPushStreamDisconnect-hasVedioDisconTipsAgain:"+hasVedioDisconTipsAgain
                +" leavingRoomTimeCount:"+leavingRoomTimeCount);
        //如果为离开直播间跳转直播结束页面或者私密直播间过度页面，则不展示toast及loading anim
        if(leavingRoomTimeCount<=0){
            return;
        }
        //视频断线时显示loading和toast提示网络不稳定
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (null != vedioLoadingAnimManager) {
                    vedioLoadingAnimManager.showLoadingAnim();
                }
                if(!hasVedioDisconTipsAgain){
                    //为了解决bug:#9831,更改为不提示toast，只显示loading动画
                    //主播视频推流连续断连通知仅toast一次，同时接收到主播视频重连成功时重置hasVedioDisconTipsAgain
                    hasVedioDisconTipsAgain = true;
//                    showToast(getResources().getString(R.string.live_push_stream_network_poor));
                }
            }
        });
    }
}
