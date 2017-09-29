package com.qpidnetwork.livemodule.liveshow.liveroom;

import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.os.Message;
import android.support.annotation.Nullable;
import android.support.v4.view.ViewCompat;
import android.text.Editable;
import android.text.SpannableString;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.SurfaceView;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationSet;
import android.view.animation.AnimationUtils;
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.livemodule.framework.widget.statusbar.StatusBarUtil;
import com.qpidnetwork.livemodule.httprequest.OnGetGiftDetailCallback;
import com.qpidnetwork.livemodule.httprequest.OnRequestCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniLiveShow;
import com.qpidnetwork.livemodule.httprequest.RequestJniOther;
import com.qpidnetwork.livemodule.httprequest.item.AudienceBaseInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.httprequest.item.SendableGiftItem;
import com.qpidnetwork.livemodule.im.IMClient;
import com.qpidnetwork.livemodule.im.listener.IMClientListener;
import com.qpidnetwork.livemodule.im.listener.IMMessageItem;
import com.qpidnetwork.livemodule.im.listener.IMPackageUpdateItem;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem.IMLiveRoomType;
import com.qpidnetwork.livemodule.im.listener.IMSysNoticeMessageContent;
import com.qpidnetwork.livemodule.im.listener.IMUserBaseInfoItem;
import com.qpidnetwork.livemodule.liveshow.LiveApplication;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.datacache.file.FileCacheManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.barrage.BarrageManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.barrage.IBarrageViewFiller;
import com.qpidnetwork.livemodule.liveshow.liveroom.car.CarInfo;
import com.qpidnetwork.livemodule.liveshow.liveroom.car.CarManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.GiftSendReqManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.GiftSender;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.GiftToast;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.ModuleGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.NormalGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.PackageGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.dialog.LiveGiftDialog;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.downloader.FileDownloadManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.downloader.IFileDownloadedListener;
import com.qpidnetwork.livemodule.liveshow.liveroom.tariffprompt.TariffPromptManager;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.liveshow.personal.chatemoji.ChatEmoji;
import com.qpidnetwork.livemodule.liveshow.personal.chatemoji.ChatEmojiManager;
import com.qpidnetwork.livemodule.liveshow.personal.chatemoji.EmojiTabScrollLayout;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.Log;
import com.qpidnetwork.livemodule.utils.TestDataUtil;
import com.qpidnetwork.livemodule.view.CircleImageHorizontScrollView;
import com.qpidnetwork.livemodule.view.CreditsNoEnoughTipsPopupWindow;
import com.qpidnetwork.livemodule.view.LiveRoomHeaderBezierView;
import com.qpidnetwork.livemodule.view.MaterialProgressBar;
import com.qpidnetwork.livemodule.view.SoftKeyboradListenFrameLayout;
import com.squareup.picasso.Picasso;

import net.qdating.LSPlayer;
import net.qdating.LSPublisher;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

import static com.qpidnetwork.livemodule.im.IMManager.IM_INVALID_REQID;

/**
 * 直播间公共处理界面类
 * 1.界面刷新，数据展示的处理放在该BaseActivity内处理
 * 2.设计到具体的房间类型内的，各种业务请求预处理，返回数据处理，各类型房间业务流程等的处理，都放到子类中做
 * 3.需要不断的review code，保证baseActivity、baseImplActivity及子类的职责明确
 * Created by Hunter Mun on 2017/6/16.
 */

public class BaseCommonLiveRoomActivity extends BaseImplLiveRoomActivity{
    /**
     * 直播间消息更新
     */
    private static final int EVENT_MESSAGE_UPDATE = 1001;
    /**
     * 在线观众头像列表更新
     */
    protected static final int EVENT_MESSAGE_UPDATE_ONLINEFANS = 1002;
    /**
     * 隐藏资费提示
     */
    private static final int EVENT_MESSAGE_HIDE_TARIFFPROMPT = 1003;
    /**
     * 接受观众进入直播间通知
     */
    public static final int EVENT_MESSAGE_ENTERROOMNOTICE = 1004;
    /**
     * 成功获取房间可发送礼物配置信息
     */
    private static final int EVENT_UPDATE_SENDABLEGIFT =1005;
    /**
     * 成功获取所有背包礼物配置信息
     */
    private static final int EVENT_UPDATE_BACKPACKGIFT =1006;
    /**
     * 收藏/取消收藏主播
     */
    protected static final int EVENT_FAVORITE_RESULT =1007;
    /**
     * 直播已结束
     */
    private static final int EVENT_AUDIENCE_ROOMEND = 1008;
    /**
     * 直播间观众数量更新
     */
    protected static final int EVENT_UPDATE_ONLINEFANSNUM = 1009;
    private static final int EVENT_GIFT_ADVANCE_SEND_FAILED = 10010;

    private static final int EVENT_UPDATE_CREDITS = 10011;

    /**
     * 进入房间
     */
    private static final int EVENT_ROOMIN = 1010;

    //整个view的父，用于解决软键盘等监听
    public SoftKeyboradListenFrameLayout flContentBody;

    //--------------------------------直播间头部视图层--------------------------------
    protected View view_roomHeader;
    private View ll_liveRoomHeader;
    private ImageView iv_roomHeaderBg;
    private LiveRoomHeaderBezierView lrhbv_flag;
    //主播信息
    private TextView tv_hostName;
    private ImageView iv_follow;
    //资费提示
    private View view_tariff_prompt;
    private ImageView iv_roomFlag;
    private Button btn_OK;
    private TextView tv_triffMsg;
    protected TariffPromptManager tpManager;

    //----------------------直播间头部-在线用户头像列表--------------------------------
    //**公开直播间
    protected LinearLayout ll_publicRoomHeader;
    //免费公开直播间
    protected CircleImageHorizontScrollView cihsv_onlineFreePublic;
    protected RelativeLayout rl_freePublic;
    protected TextView tv_onlineNum;
    //付费公开直播间
    protected RelativeLayout rl_vipPublic;
    protected TextView tv_vipGuestData;
    protected CircleImageHorizontScrollView cihsv_onlineVIPPublic;
    //返点
    private TextView tv_creditTips;
    private TextView tv_creditValue;
    private View ll_credits;
    private View view_roomHeader_buttomLine;

    //---------------------消息编辑区域--------------------------------------
    private View rl_inputMsg;
    private LinearLayout ll_input_edit_body;
    private LinearLayout ll_roomEditMsgiInput;
    private ImageView iv_msgType;
    private View v_roomEditMegBg;
    private EditText et_liveMsg;
    private Button btn_sendMsg;
    private EmojiTabScrollLayout etsl_emojiContainer;
    private ChatEmoji choosedChatEmoji = null;
    public boolean isEmojiOpera = false;//标识表情列表状态切换
    protected ImageView iv_emojiSwitch;

    //聊天展示区域
    private LiveRoomChatManager liveRoomChatManager;
    private long lastMsgSentTime = 0l;
    //弹幕
    private boolean isBarrage = false;
    private View ll_bulletScreen;

    //礼物模块
    protected ModuleGiftManager mModuleGiftManager;
    //礼物列表
    private LiveGiftDialog liveGiftDialog;
    //大礼物
    private SimpleDraweeView advanceGift;

    protected GiftToast giftToast;

    //视频播放
    protected ImageView iv_vedioBg;
    public SurfaceView sv_player;
    private View rl_media;
    private View imBody;
    protected LSPlayer player = null;
    protected View include_audience_area;

    //座驾
    protected LinearLayout ll_entranceCar;

    //私密预约按钮
    protected ImageView iv_privateLiveNow;

    //男士互动区域
    protected View includePublish;
    protected SurfaceView svPublisher;
    protected RelativeLayout rlPublishOperate;
    protected ImageView ivPublishStart;
    protected ImageView ivPublishMute;
    protected MaterialProgressBar publishLoading;

    //------------直播间底部---------------
    //免费公开
    protected ImageView iv_freePublicBg1;
    protected ImageView iv_freePublicBg2;
    protected View ll_buttom_audience;
    protected ImageView iv_inputMsg;
    protected ImageView iv_gift_public;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        TAG = BaseCommonLiveRoomActivity.class.getName();
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_live_room);
        initViews();
        initData();
        initRoomGiftDataSet();
        GiftSender.getInstance().currRoomId = mIMRoomInItem.roomId;
        GiftSendReqManager.getInstance().executeNextReqTask();
    }

    private void initViews(){
        Log.d(TAG,"initViews");
        //解决软键盘关闭的监听问题
        flContentBody = (SoftKeyboradListenFrameLayout)findViewById(R.id.flContentBody);
        flContentBody.setInputWindowListener(this);
        initRoomHeader();
        initRoomViewDataAndStyle();
        imBody = findViewById(R.id.include_im_body);
        initVideoPlayer();
        initLiveRoomCar();
        initPrePriView();
        initLiveGiftDialog();
        initMultiGift();
        initMessageList();
        initBarrage();
        initEditAreaView();
        initEditAreaViewStyle();
        //互动模块初始化
        initPublishView();
        setSizeUnChanageViewParams();
    }

    /**
     * 初始化数据
     */
    public void initData(){
        //互动模块初始化
        initPublishData();
        //获取本人座驾
        getSelfRiderData();

    }

    @Override
    public void onClick(View v) {
        super.onClick(v);
        switch (v.getId()){
            case R.id.tv_hostName:
                visitHostInfo();
                break;
            case R.id.iv_inputMsg:
            case R.id.btn_showInputView:{
                rl_inputMsg.setVisibility(View.VISIBLE);
                showSoftInput(et_liveMsg);
            }break;
            case R.id.iv_msgType:{
                switchEditType();
            }break;
            case R.id.iv_emojiSwitch:
                //处理表情view顶起后的输入框跟随顶起逻辑--用户端
                etsl_emojiContainer.measure(0,0);
                if(View.GONE == etsl_emojiContainer.getVisibility()){
                    isEmojiOpera = true;
                    //隐藏软键盘，但仍保持et_liveMsg获取焦点
                    hideSoftInput(et_liveMsg,false);
                    etsl_emojiContainer.setVisibility(View.VISIBLE);
                }else{
                    isEmojiOpera = true;
                    etsl_emojiContainer.setVisibility(View.GONE);
                    showSoftInput(et_liveMsg);
                }
                break;
            case R.id.btn_sendMsg:{
                //点击发送消息
                if(0 != lastMsgSentTime && System.currentTimeMillis()- lastMsgSentTime <
                        getResources().getInteger(R.integer.minMsgSendTimeInterval) && !TextUtils.isEmpty(et_liveMsg.getText())){
                    showGiftTips(getResources().getString(R.string.live_msg_send_tips));
                    return;
                }
                lastMsgSentTime = System.currentTimeMillis();
                if(sendTextMessage(isBarrage)){
                    //发送成功，清空消息
                    et_liveMsg.setText("");
                }
            }break;
            case R.id.view_roomHeader:
            case R.id.rl_media:
            case R.id.fl_imMsgContainer:
                //点击界面区域关闭键盘或者点赞处理
                if(isSoftInputOpen){
                    hideSoftInput(et_liveMsg,true);
                }else if(etsl_emojiContainer.getVisibility() == View.VISIBLE){
                    etsl_emojiContainer.setVisibility(View.GONE);
                    hideSoftInput(et_liveMsg,true);
                    onSoftKeyboardHide();
                }
                playRoomHeaderInAnim();
                break;
            case R.id.et_liveMsg:
                if(etsl_emojiContainer.getVisibility() == View.VISIBLE){
                    etsl_emojiContainer.setVisibility(View.GONE);
                }
                break;
            case R.id.iv_follow:
                sendFollowHostReq();
                break;
            case R.id.iv_closeLiveRoom:
                closeLiveRoom();
                break;
            case R.id.ivPublishStart: {
                //推流开始结束按钮
                startOrStopVideoInteraction();
            }break;
            case R.id.ivPublishMute: {
                //静音打开关闭
                setPublishMute();
            }break;
            case R.id.includePublish: {
                refreshPublishViews();
            }break;
            default:
                break;
        }
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        switch(msg.what){
            case EVENT_UPDATE_CREDITS:
                tv_creditValue.setText(String.valueOf(mLiveRoomCreditRebateManager.getCredit()));
                break;
            case EVENT_GIFT_ADVANCE_SEND_FAILED:
                showGiftTips(getResources().getString(R.string.live_gift_send_failed,msg.obj.toString()));
                break;

            case EVENT_AUDIENCE_ROOMEND:{
//                showLiveEndDialog();
                endLive(false,mIMRoomInItem.roomType);
            }break;
            case EVENT_FAVORITE_RESULT:
                HttpRespObject hrObject = (HttpRespObject)msg.obj;
                onRecvFollowHostResp(hrObject.isSuccess,hrObject.errMsg);
                break;

            case EVENT_MESSAGE_ENTERROOMNOTICE: {
                final CarInfo carInfo = (CarInfo) msg.obj;
                if (!TextUtils.isEmpty(carInfo.riderUrl) && !TextUtils.isEmpty(carInfo.riderId)
                        && !TextUtils.isEmpty(carInfo.riderName)) {
                    carInfo.riderLocalPath = FileCacheManager.getInstance().parseCarImgLocalPath(carInfo.riderId, carInfo.riderUrl);
                    Log.d(TAG, "EVENT_MESSAGE_ENTERROOMNOTICE-riderId:" + carInfo.riderId + " riderLocalPath:" + carInfo.riderLocalPath);
                    if (TextUtils.isEmpty(carInfo.riderLocalPath)) {
                        return;
                    }
                    File file = new File(carInfo.riderLocalPath);
                    if (null != file && file.exists()) {
                        if (null != carManager) {
                            carManager.putLiveRoomCarInfo(carInfo);
                        }
                        String str = LiveApplication.getContext().getResources().getString(
                                R.string.enterlive_withrider, carInfo.nickName, carInfo.riderName);
                        IMMessageItem msgItem = new IMMessageItem(mIMRoomInItem.roomId,
                                mIMManager.mMsgIdIndex.getAndIncrement(), IMMessageItem.MessageType.SysNotice,
                                new IMSysNoticeMessageContent(str,"", IMSysNoticeMessageContent.SysNoticeType.CarIn));
                        sendMessageUpdateEvent(msgItem);
                    } else {
                        FileDownloadManager.getInstance().start(carInfo.riderUrl, carInfo.riderLocalPath, new IFileDownloadedListener() {
                            @Override
                            public void onCompleted(boolean isSuccess, String localFilePath, String fileUrl) {
                                Log.d(TAG, "onCompleted-isSuccess:" + isSuccess + " localFilePath:" + localFilePath);
                                if (isSuccess) {
                                    Message msg = Message.obtain();
                                    msg.what = EVENT_MESSAGE_ENTERROOMNOTICE;
                                    msg.obj = carInfo;
                                    sendUiMessage(msg);

                                }
                            }
                        });
                    }
                }

            }break;
            case EVENT_MESSAGE_HIDE_TARIFFPROMPT:
                if(view_tariff_prompt.getVisibility() == View.VISIBLE){
                    showRoomTariffPrompt(null,false);
                }
                break;
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
            case EVENT_UPDATE_SENDABLEGIFT: {
                List<GiftItem> giftItems = (List<GiftItem>) msg.obj;
                if (liveGiftDialog != null) {
                    liveGiftDialog.updateStoreGiftData(giftItems);
                }
            }break;
            case EVENT_UPDATE_BACKPACKGIFT: {
                if (liveGiftDialog != null) {
                    liveGiftDialog.setBackPackDataChanged();
                }
            }break;
            default:
                break;
        }
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
    protected void onDestroy() {
        super.onDestroy();
        tpManager.clear();
        carManager.shutDownAnimQueueServNow();
        carManager = null;
        mModuleGiftManager.onMultiGiftDetroy();
        //清除资源及动画
        if(mBarrageManager != null) {
            mBarrageManager.onDestroy();
        }
        //退出房间成功，就清空送礼队列，并停止服务
        GiftSendReqManager.getInstance().shutDownReqQueueServNow();
        normalGiftManager.unregisterListener(mIMRoomInItem.roomId);
        packageGiftManager.unregisterListener(mIMRoomInItem.roomId);
        //清除互动相关
        onPublisherDestroy();
    }

    /**
     * 关闭直播间
     */
    public void closeLiveRoom(){
        if(null != mIMRoomInItem && !TextUtils.isEmpty(mIMRoomInItem.roomId) && null != mIMManager){
            mIMManager.RoomOut(mIMRoomInItem.roomId);
        }
        finish();
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if(keyCode == KeyEvent.KEYCODE_BACK && event.getAction() == KeyEvent.ACTION_DOWN){
            //拦截返回键
            closeLiveRoom();
            return false;
        }
        return super.onKeyDown(keyCode, event);
    }

    //******************************** 顶部房间信息模块 ****************************************************************

    @Override
    public void onGetRoomTariffInfo(final SpannableString tariffPromptSpan,final boolean isNeedUserConfirm) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if(isNeedUserConfirm || isUserWantSeeTariffPrompt){
                    showRoomTariffPrompt(tariffPromptSpan,isNeedUserConfirm);
                    isUserWantSeeTariffPrompt = false;
                }
            }
        });
    }

    protected boolean isUserWantSeeTariffPrompt = false;

    private void initRoomHeader(){
        view_roomHeader = findViewById(R.id.view_roomHeader);
        view_roomHeader.setOnClickListener(this);
        ll_liveRoomHeader = findViewById(R.id.ll_liveRoomHeader);
        iv_roomHeaderBg = (ImageView) findViewById(R.id.iv_roomHeaderBg);
        view_roomHeader_buttomLine = findViewById(R.id.view_roomHeader_buttomLine);
        lrhbv_flag = (LiveRoomHeaderBezierView) findViewById(R.id.lrhbv_flag);
        iv_roomFlag = (ImageView) findViewById(R.id.iv_roomFlag);
        iv_roomFlag.setImageDrawable(RoomThemeManager.getRoomFlagDrawable(mIMRoomInItem.roomType));
        iv_roomFlag.measure(0,0);
        RelativeLayout.LayoutParams roomFlagLp = (RelativeLayout.LayoutParams) iv_roomFlag.getLayoutParams();
        //资费提示
        view_tariff_prompt = findViewById(R.id.view_tariff_prompt);
        FrameLayout.LayoutParams tpLp = (FrameLayout.LayoutParams) view_tariff_prompt.getLayoutParams();
        tpLp.topMargin = iv_roomFlag.getMeasuredHeight()+roomFlagLp.topMargin+tpLp.topMargin;
        tpLp.width = iv_roomFlag.getMeasuredWidth();
        view_tariff_prompt.setLayoutParams(tpLp);
        btn_OK = (Button) findViewById(R.id.btn_OK);
        btn_OK.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showRoomTariffPrompt(null,false);
                if(null != tpManager){
                    tpManager.update();
                }
            }
        });
        iv_roomFlag.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(view_tariff_prompt.getVisibility() == View.GONE){
                    isUserWantSeeTariffPrompt = true;
                    tpManager.getRoomTariffInfo(BaseCommonLiveRoomActivity.this);
                    Message msg = Message.obtain();
                    msg.what =EVENT_MESSAGE_HIDE_TARIFFPROMPT;
                    sendUiMessageDelayed(msg,3000l);
                }
            }
        });
        tv_triffMsg = (TextView) findViewById(R.id.tv_triffMsg);
        tpManager = TariffPromptManager.getInstance();
        tpManager.init(mIMRoomInItem).getRoomTariffInfo(this);
        //---公开直播间----
        ll_publicRoomHeader = (LinearLayout) findViewById(R.id.ll_publicRoomHeader);
        ll_publicRoomHeader.setVisibility(View.GONE);
        iv_follow = (ImageView) findViewById(R.id.iv_follow);
        iv_follow.setOnClickListener(this);
        tv_hostName = (TextView) findViewById(R.id.tv_hostName);
        tv_hostName.setOnClickListener(this);
        //免费公开直播间
        cihsv_onlineFreePublic = (CircleImageHorizontScrollView) findViewById(R.id.cihsv_onlineFreePublic);
        tv_onlineNum = (TextView) findViewById(R.id.tv_onlineNum);
        rl_freePublic = (RelativeLayout) findViewById(R.id.rl_freePublic);
        rl_freePublic.setVisibility(View.GONE);
        //付费公开直播间
        rl_vipPublic = (RelativeLayout) findViewById(R.id.rl_vipPublic);
        cihsv_onlineVIPPublic = (CircleImageHorizontScrollView) findViewById(R.id.cihsv_onlineVIPPublic);
        tv_vipGuestData = (TextView) findViewById(R.id.tv_vipGuestData);
        rl_vipPublic.setVisibility(View.GONE);
        //-----私密直播间-----
        //普通私密直播间
        //豪华私密直播间

    }

    private void initRoomViewDataAndStyle(){
        int color = RoomThemeManager.getRootViewTopColor(mIMRoomInItem.roomType);
        StatusBarUtil.setColor(this,color,0);
        lrhbv_flag.setRoomHeaderBgColor(color);
        //是否已经关注
        onRecvFollowHostResp(mIMRoomInItem.isFavorite,"");
        tv_hostName.setText(mIMRoomInItem.nickName);
        iv_roomHeaderBg.setImageDrawable(RoomThemeManager.getRoomHeaderViewBgDrawable(mIMRoomInItem.roomType));
        flContentBody.setBackgroundDrawable(RoomThemeManager.getRoomThemeDrawable(mIMRoomInItem.roomType));
    }

    protected void resetRoomViewParams(){
        LinearLayout.LayoutParams buttomLineLp = (LinearLayout.LayoutParams) view_roomHeader_buttomLine.getLayoutParams();
        buttomLineLp.height = RoomThemeManager.getRoomHeadViewButtomLineHeight(mIMRoomInItem.roomType);
        view_roomHeader_buttomLine.setLayoutParams(buttomLineLp);
        ll_liveRoomHeader.measure(0,0);
        FrameLayout.LayoutParams lp1 = (FrameLayout.LayoutParams)iv_roomHeaderBg.getLayoutParams();
        lp1.height = ll_liveRoomHeader.getMeasuredHeight();
        iv_roomHeaderBg.setLayoutParams(lp1);

        view_roomHeader.measure(0,0);
        int screenWidth = DisplayUtil.getScreenWidth(BaseCommonLiveRoomActivity.this);
        int scaleHeight= screenWidth*3/4;
        //具体的宽高比例，其实也可以根据服务器动态返回来控制
        RelativeLayout.LayoutParams svPlayerLp = (RelativeLayout.LayoutParams)sv_player.getLayoutParams();
        RelativeLayout.LayoutParams ivVedioBgLp = (RelativeLayout.LayoutParams)iv_vedioBg.getLayoutParams();
        LinearLayout.LayoutParams rlMediaLp = (LinearLayout.LayoutParams)rl_media.getLayoutParams();
        int roomHeaderMeasuredHeight = view_roomHeader.getMeasuredHeight();
        svPlayerLp.topMargin = roomHeaderMeasuredHeight;
        ivVedioBgLp.topMargin = roomHeaderMeasuredHeight;
        rlMediaLp.topMargin = roomHeaderMeasuredHeight;
        svPlayerLp.height = scaleHeight;
        ivVedioBgLp.height = scaleHeight;
        rlMediaLp.height = scaleHeight;
        sv_player.setLayoutParams(svPlayerLp);
        iv_vedioBg.setLayoutParams(ivVedioBgLp);
        rl_media.setLayoutParams(rlMediaLp);
    }

    protected void updatePublicRoomOnlineData(int fansNum){
        Log.d(TAG,"updatePublicRoomOnlineData-fansNum:"+fansNum);
        tv_onlineNum.setVisibility(fansNum >0 ? View.VISIBLE : View.GONE);
        tv_onlineNum.setText(String.valueOf(fansNum));
        tv_vipGuestData.setText(getResources().getString(R.string.liveroom_header_vipguestdata,
                String.valueOf(fansNum),String.valueOf(mIMRoomInItem.audienceLimitNum)));
        //查询头像列表
        RequestJniLiveShow.GetAudienceListInRoom(mIMRoomInItem.roomId,0,0,this);
    }

    protected void showRoomTariffPrompt(SpannableString spannableString, boolean isShowOkBtn){
        if(null != spannableString){
            tv_triffMsg.setText(spannableString);
            //http://a.codekk.com/blogs/detail/54cfab086c4761e5001b253f
            tv_triffMsg.requestLayout();
            view_tariff_prompt.setVisibility(View.VISIBLE);
            btn_OK.setVisibility(isShowOkBtn ? View.VISIBLE : View.GONE);
        }else{
            view_tariff_prompt.setVisibility(View.GONE);
        }
    }

    protected void visitHostInfo(){
        showToast("主播个人信息页");
    }

    /**
     * 关注主播，用户端的实现类，
     * 需要在调用关注接口成功后，通过super.sendFollowHotRseq()实现界面的交互响应
     */
    public void sendFollowHostReq(){
        if(null != mIMRoomInItem){
            Log.d(TAG,"sendFollowHostReq-hostId:"+mIMRoomInItem.userId);
            //接口调用
            RequestJniOther.AddOrCancelFavorite(mIMRoomInItem.userId, mIMRoomInItem.roomId, true, new OnRequestCallback() {
                @Override
                public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                    Log.d(TAG,"sendFollowHostReq-isSuccess:"+isSuccess+" errCode:"+errCode+" errMsg:"+errMsg);
                    Message msg = Message.obtain();
                    msg.what = EVENT_FAVORITE_RESULT;
                    msg.obj = new HttpRespObject(isSuccess, errCode, errMsg, null);
                    sendUiMessage(msg);
                }
            });
        }
    }

    /**
     * 已经关注
     */
    protected void onRecvFollowHostResp(boolean isSuccess, String errMsg){
        if(!TextUtils.isEmpty(errMsg)){
            showToast(errMsg);
        }
        if(isSuccess){
            iv_follow.setVisibility(View.GONE);
//            if(TestDataUtil.isContinueTestTask){
//                TestDataUtil.changeViewVisityStatus(iv_follow,this,View.VISIBLE);
//            }`
        }
    }

    /**
     * 播放房间header的淡出动画
     */
    private void playRoomHeaderInAnim(){
        if(view_roomHeader.getVisibility() == View.GONE){
            AnimationSet animationSet = (AnimationSet) AnimationUtils.
                    loadAnimation(mContext, R.anim.liveroom_header_in);
            animationSet.setAnimationListener(new Animation.AnimationListener() {
                @Override
                public void onAnimationStart(Animation animation) {}

                @Override
                public void onAnimationEnd(Animation animation) {
                    view_roomHeader.setVisibility(View.VISIBLE);
                }

                @Override
                public void onAnimationRepeat(Animation animation) {}
            });
            view_roomHeader.startAnimation(animationSet);
        }

    }

    /**
     * 播放房间header的淡入动画
     */
    private void playRoomHeaderOutAnim(){
        if(view_roomHeader.getVisibility() == View.VISIBLE){
            AnimationSet animationSet = (AnimationSet) AnimationUtils.
                    loadAnimation(mContext, R.anim.liveroom_header_out);
            animationSet.setAnimationListener(new Animation.AnimationListener() {
                @Override
                public void onAnimationStart(Animation animation) {}

                @Override
                public void onAnimationEnd(Animation animation) {
                    view_roomHeader.setVisibility(View.GONE);
                }

                @Override
                public void onAnimationRepeat(Animation animation) {}
            });
            view_roomHeader.startAnimation(animationSet);
        }
    }

    @Override
    public void OnRoomIn(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType,
                         String errMsg, final IMRoomInItem roomInfo) {
        super.OnRoomIn(reqId,success,errType,errMsg,roomInfo);
    }

    //******************************** 视频播放组件 ****************************************************************
    private void initVideoPlayer(){
        include_audience_area = findViewById(R.id.include_audience_area);
        iv_vedioBg = (ImageView) findViewById(R.id.iv_vedioBg);
        //视频播放组件
        sv_player = (SurfaceView)findViewById(R.id.sv_player);
        rl_media = findViewById(R.id.rl_media);
        rl_media.setOnClickListener(this);
    }

    protected void initLPlayer(String videoUrl, String recordFilePath, String recordH264FilePath, String recordAACFilePath){
        player = new LSPlayer();
        player.init(sv_player, null);
        player.playUrl(videoUrl, recordFilePath, recordH264FilePath, recordAACFilePath);
    }

    protected void uninitLPlayer(){
        if(player != null){
            player.stop();
            player.uninit(); //防止内存泄漏
        }
    }

    //-----------------------信用点----------------------------------------

    @Override
    protected void onRebateUpdate() {
        super.onRebateUpdate();
    }


    //******************************** 礼物模块 ****************************************************************

    /**
     * 初始化礼物配置
     */
    public void initRoomGiftDataSet() {
        if(null != mIMRoomInItem && !TextUtils.isEmpty(mIMRoomInItem.roomId)){
            //获取房间可用礼物配置
            normalGiftManager.registerListener(mIMRoomInItem.roomId,this);
            normalGiftManager.getSendableGiftItems(mIMRoomInItem.roomId,this);
            packageGiftManager.currRoomId = mIMRoomInItem.roomId;
            packageGiftManager.registerListener(mIMRoomInItem.roomId,this);
        }
        normalGiftManager.getAllGiftItems(this);
        packageGiftManager.getAllPackageGiftItems(null);
    }

    private NormalGiftManager normalGiftManager = NormalGiftManager.getInstance();
    private PackageGiftManager packageGiftManager = PackageGiftManager.getInstance();

    /**
     * 初始化底部礼物选择界面
     */
    protected void initLiveGiftDialog(){
        if(null == liveGiftDialog){
            liveGiftDialog = new LiveGiftDialog(this);
        }
        liveGiftDialog.setImRoomInItem(mIMRoomInItem);
    }

    protected void showLiveGiftDialog(){
        initLiveGiftDialog();
        liveGiftDialog.show();
    }

    /**
     * 初始化模块
     */
    private void initMultiGift(){
        FrameLayout viewContent = (FrameLayout)findViewById(R.id.flMultiGift);
        /*礼物模块*/
        mModuleGiftManager = new ModuleGiftManager(this);
        mModuleGiftManager.initMultiGift(viewContent);
        ll_bulletScreen = findViewById(R.id.ll_bulletScreen);
        mModuleGiftManager.showMultiGiftAs(ll_bulletScreen);
        //大礼物
        advanceGift = (SimpleDraweeView)findViewById(R.id.advanceGift);
        mModuleGiftManager.initAdvanceGift(advanceGift);
        giftToast = new GiftToast(this,3000l);
    }

    /**
     * 启动消息动画
     * @param msgItem
     */
    private void launchAnimationByMessage(IMMessageItem msgItem){
        if(msgItem != null){
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

    public void showGiftTips(String msg){
        if(null != giftToast){
            giftToast.show(msg);
        }
    }

    @Override
    public void OnSendGift(boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg,
                           IMMessageItem msgItem, double credit, double rebateCredit) {
        super.OnSendGift(success,errType,errMsg,msgItem,credit,rebateCredit);
        if(errType == IMClientListener.LCC_ERR_TYPE.LCC_ERR_SUCCESS){
            Log.d(TAG,"OnSendMsg-一次送礼请求发送成功，执行下一个送礼请求");
            GiftSendReqManager.getInstance().executeNextReqTask();
        }else{
            Log.d(TAG,"OnSendMsg-一次送礼请求发送失败，清空送礼请求队列");
            GiftSendReqManager.getInstance().clearGiftSendReqQueue();
            //豪华礼物发送失败，提示用户
            normalGiftManager.getGiftDetail(msgItem.giftMsgContent.giftId, new OnGetGiftDetailCallback() {
                @Override
                public void onGetGiftDetail(boolean isSuccess, int errCode, String errMsg, GiftItem giftDetail) {
                    if(isSuccess && null != giftDetail && giftDetail.giftType == GiftItem.GiftType.Advanced){
                        Message msg = Message.obtain();
                        msg.obj = giftDetail.name;
                        msg.what = EVENT_GIFT_ADVANCE_SEND_FAILED;
                        sendUiMessage(msg);
                    }
                }
            });
        }
    }

    @Override
    public void onRoomSendableGiftChanged(String roomId, List<GiftItem> sendableGiftItemList) {
        super.onRoomSendableGiftChanged(roomId, sendableGiftItemList);
        Message msg = Message.obtain();
        msg.what = EVENT_UPDATE_SENDABLEGIFT;
        msg.obj = sendableGiftItemList;
        sendUiMessage(msg);
    }

    @Override
    public void onGetGiftList(boolean isSuccess, int errCode, String errMsg, GiftItem[] giftList) {
        super.onGetGiftList(isSuccess, errCode, errMsg, giftList);
        if(isSuccess){
            PackageGiftManager.getInstance().updatePackageGift();
        }
    }

    @Override
    public void onGetSendableGiftList(boolean isSuccess, int errCode, String errMsg, SendableGiftItem[] giftIds) {
        super.onGetSendableGiftList(isSuccess, errCode, errMsg, giftIds);
        if(isSuccess){
            PackageGiftManager.getInstance().updatePackageGift();
        }
    }

    @Override
    public void OnRecvRoomGiftNotice(IMMessageItem msgItem) {
        super.OnRecvRoomGiftNotice(msgItem);
        sendMessageUpdateEvent(msgItem);
    }


    @Override
    public void onPackageGiftDataChanged(String currRoomId) {
        super.onPackageGiftDataChanged(currRoomId);
        if(!currRoomId.equals(mIMRoomInItem.roomId)){
           return;
        }
        Message msg = Message.obtain();
        msg.what = EVENT_UPDATE_BACKPACKGIFT;
        sendUiMessage(msg);
    }

    @Override
    public void OnRecvBackpackUpdateNotice(IMPackageUpdateItem item) {
        super.OnRecvBackpackUpdateNotice(item);
        packageGiftManager.currRoomId = mIMRoomInItem.roomId;

        packageGiftManager.getAllPackageGiftItems(null);
    }

    //******************************** 信用点不足提示 ****************************************
    protected CreditsNoEnoughTipsPopupWindow creditsNoEnoughTipsPopupWindow;
    public void showCreditNoEnoughPopupWindow(int tipsResId, View parentView, boolean isFromDialog){
        if(null == creditsNoEnoughTipsPopupWindow){
            creditsNoEnoughTipsPopupWindow = new CreditsNoEnoughTipsPopupWindow(this);
            creditsNoEnoughTipsPopupWindow.setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
        }
        creditsNoEnoughTipsPopupWindow.setCreditsTips(getResources().getString(tipsResId));
        creditsNoEnoughTipsPopupWindow.showAtLocation(parentView, Gravity.CENTER, isFromDialog);
    }

    //******************************** 预约私密直播 **************************************************
    private void initPrePriView(){
        iv_privateLiveNow = (ImageView) findViewById(R.id.iv_privateLiveNow);
        Drawable drawable = RoomThemeManager.getRoomPriLiveNowBtnDrawable(mIMRoomInItem.roomType);
        if(null != drawable){
            iv_privateLiveNow.setImageDrawable(drawable);
        }else{
            iv_privateLiveNow.setVisibility(View.GONE);
        }

    }

    //******************************** 入场座驾 ******************************************************
    protected CarManager carManager = new CarManager();

    private void initLiveRoomCar(){
        tv_creditTips = (TextView) findViewById(R.id.tv_creditTips);
        tv_creditTips.setText(getResources().getString(R.string.tip_roomGiftCredit," "));
        tv_creditValue = (TextView) findViewById(R.id.tv_creditValue);
        ll_credits = findViewById(R.id.ll_credits);
        Drawable drawable = RoomThemeManager.getRoomCreditsBgDrawable(mIMRoomInItem.roomType);
        if(null != drawable){
            ll_credits.setBackgroundDrawable(drawable);
            ll_credits.setVisibility(View.VISIBLE);
        }else{
            ll_credits.setVisibility(View.INVISIBLE);
        }
        ll_entranceCar = (LinearLayout) findViewById(R.id.ll_entranceCar);
        FrameLayout.LayoutParams lp = (FrameLayout.LayoutParams) ll_credits.getLayoutParams();
        ll_credits.measure(0,0);
        int mH = ll_credits.getMeasuredHeight();
        carManager.init(this,ll_entranceCar,mH+lp.topMargin);
    }

    @Override
    public void OnRecvEnterRoomNotice(String roomId, String userId, String nickName,
                                      String photoUrl, String riderId, String riderName,
                                      String riderUrl, int fansNum) {
        super.OnRecvEnterRoomNotice(roomId,userId,nickName,photoUrl,riderId,riderName,riderUrl,fansNum);
        Log.d(TAG,"OnRecvEnterRoomNotice-userId:"+userId+" mIMRoomInItem.userId:"+mIMRoomInItem.userId);
        if(null != mIMRoomInItem || !TextUtils.isEmpty(userId) && userId.equals(mIMRoomInItem.userId)){
            //断线重登陆，接收到自己的进入房间通知，过滤处理
            Log.d(TAG,"OnRecvEnterRoomNotice-断线重登陆，接收到自己的进入房间通知，过滤处理");
            return;
        }
        CarInfo carInfo = new CarInfo(nickName,userId,riderId,riderName,riderUrl);
        Message msg = Message.obtain();
        msg.what = EVENT_MESSAGE_ENTERROOMNOTICE;
        msg.obj = carInfo;
        sendUiMessage(msg);
    }

    private void getSelfRiderData(){
        RequestJniLiveShow.GetAudienceDetailInfo(mIMRoomInItem.userId,this);
    }

    @Override
    public void onGetAudienceDetailInfo(boolean isSuccess, int errCode, String errMsg, AudienceBaseInfoItem audienceInfo) {
        super.onGetAudienceDetailInfo(isSuccess, errCode, errMsg, audienceInfo);
        Message msg = null;
        if(isSuccess && !TextUtils.isEmpty(audienceInfo.riderId) && audienceInfo.userId.equals(mIMRoomInItem.userId)){
            CarInfo carInfo = new CarInfo(audienceInfo.nickName,audienceInfo.userId,audienceInfo.riderId,audienceInfo.riderName,audienceInfo.riderUrl);
            msg = Message.obtain();
            msg.what = EVENT_MESSAGE_ENTERROOMNOTICE;
            msg.obj = carInfo;
            sendUiMessage(msg);
        }else{
            IMMessageItem msgItem = new IMMessageItem(mIMRoomInItem.roomId,
                    mIMManager.mMsgIdIndex.getAndIncrement(), audienceInfo.userId,
                    audienceInfo.nickName, mIMRoomInItem.manLevel, IMMessageItem.MessageType.RoomIn, null,null);
            msg = Message.obtain();
            msg.what = EVENT_MESSAGE_UPDATE;
            msg.obj = msgItem;
            sendUiMessage(msg);
        }
    }

    //******************************** 弹幕消息编辑区域处理 ********************************************
    private TextWatcher tw_msgEt;
    private static int liveMsgMaxLength = 10;
    /**
     * 处理编辑框区域view初始化
     */
    private void initEditAreaView(){
        liveMsgMaxLength = getResources().getInteger(R.integer.liveMsgMaxLength);
        rl_inputMsg = findViewById(R.id.rl_inputMsg);
        ll_input_edit_body = (LinearLayout)findViewById(R.id.ll_input_edit_body);
        v_roomEditMegBg = findViewById(R.id.v_roomEditMegBg);
        ll_roomEditMsgiInput = (LinearLayout)findViewById(R.id.ll_roomEditMsgiInput);
        ll_roomEditMsgiInput.measure(0,0);
        FrameLayout.LayoutParams bgLp = (FrameLayout.LayoutParams) v_roomEditMegBg.getLayoutParams();
        bgLp.height = ll_roomEditMsgiInput.getMeasuredHeight();
        v_roomEditMegBg.setLayoutParams(bgLp);
        iv_msgType = (ImageView)findViewById(R.id.iv_msgType);
        iv_msgType.setOnClickListener(this);
        et_liveMsg = (EditText)findViewById(R.id.et_liveMsg);
        et_liveMsg.setOnClickListener(this);
        btn_sendMsg = (Button)findViewById(R.id.btn_sendMsg);
        if(null == tw_msgEt){
            tw_msgEt = new TextWatcher() {
                @Override
                public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                }

                @Override
                public void onTextChanged(CharSequence s, int start, int before, int count) {
                }

                @Override
                public void afterTextChanged(Editable s) {
                    Log.d(TAG,"afterTextChanged-s:"+s.toString());
                    if(null != btn_sendMsg){
                        btn_sendMsg.setSelected(!TextUtils.isEmpty(s.toString()));
                    }
                    if(null != et_liveMsg){
                        int selectedStartIndex = et_liveMsg.getSelectionStart();
                        int selectedEndIndex = et_liveMsg.getSelectionEnd();
                        if(s.toString().length()>liveMsgMaxLength){
                            s.delete(selectedStartIndex-1,selectedEndIndex);
                            et_liveMsg.removeTextChangedListener(tw_msgEt);
                            et_liveMsg.setText(s.toString());
                            et_liveMsg.setSelection(s.toString().length());
                            et_liveMsg.addTextChangedListener(tw_msgEt);
                        }
                    }
                }
            };
        }
        et_liveMsg.addTextChangedListener(tw_msgEt);

        //Emoji
        etsl_emojiContainer = (EmojiTabScrollLayout) findViewById(R.id.etsl_emojiContainer);
        etsl_emojiContainer.setTabTitles(ChatEmojiManager.getInstance().getEmojiTypes());
        etsl_emojiContainer.setItemMap(ChatEmojiManager.getInstance().getAllChatEmojies());
        //xml来控制
        etsl_emojiContainer.setViewStatusChangedListener(
                new EmojiTabScrollLayout.ViewStatusChangeListener() {
                    @Override
                    public void onTabClick(int position, String title) {
                        boolean isUnusable = !TextUtils.isEmpty(title) && title.equals("advanced");
                        etsl_emojiContainer.setUnusableTip(
                                isUnusable ? getResources().getString(R.string.tip_emoji_unusable) : "");
                    }

                    @Override
                    public void onGridViewItemClick(View itemChildView,int position, String title, Object obj) {
                        choosedChatEmoji = (ChatEmoji) obj;
                        et_liveMsg.append(ChatEmojiManager.getInstance()
                                            .parseEmoji(BaseCommonLiveRoomActivity.this
                                                        ,choosedChatEmoji
                                                        ,ChatEmojiManager.CHATEMOJI_MODEL_EMOJIDES));
                    }
                });
        etsl_emojiContainer.notifyDataChanged();
        iv_emojiSwitch = (ImageView)findViewById(R.id.iv_emojiSwitch);
        iv_freePublicBg1 = (ImageView) findViewById(R.id.iv_freePublicBg1);
        iv_freePublicBg2 = (ImageView) findViewById(R.id.iv_freePublicBg2);
        iv_freePublicBg1.setVisibility(View.GONE);
        iv_freePublicBg2.setVisibility(View.GONE);

        ll_buttom_audience = findViewById(R.id.ll_buttom_audience);
        iv_inputMsg = (ImageView) findViewById(R.id.iv_inputMsg);
        Drawable inputDrawalbe = RoomThemeManager.getPublicRoomInputBtnDrawable(mIMRoomInItem.roomType);
        if(null != inputDrawalbe){
            iv_inputMsg.setImageDrawable(inputDrawalbe);
        }

        iv_gift_public = (ImageView) findViewById(R.id.iv_gift_public);
        Drawable giftDrawalbe = RoomThemeManager.getPublicRoomGiftBtnDrawable(mIMRoomInItem.roomType);
        if(null != giftDrawalbe){
            iv_gift_public.setImageDrawable(giftDrawalbe);
        }

    }

    //显示免费公开直播间底部的背景图片-欢呼粉丝群.jpg
    protected void showFreePublicRoomButtomImGBg(){
        iv_freePublicBg1.setVisibility(View.VISIBLE);
        iv_freePublicBg2.setVisibility(View.VISIBLE);
    }

    private void initEditAreaViewStyle(){
        if(mIMRoomInItem.roomType == IMLiveRoomType.FreePublicRoom){
            iv_emojiSwitch.setVisibility(View.GONE);
        }
    }

    /**
     * 切换当前编辑状态（弹幕/普通消息）
     */
    private void switchEditType(){
        isBarrage = !isBarrage;
        iv_msgType.setImageDrawable(getResources().getDrawable(
                isBarrage ? R.drawable.ic_popup_on_freepublic : R.drawable.ic_popup_off_freepublic));
        ll_input_edit_body.setSelected(isBarrage);
        et_liveMsg.setHint(isBarrage ? R.string.txt_hint_input_barrage : R.string.txt_hint_input_general);
        et_liveMsg.setHintTextColor(Color.parseColor(isBarrage ? "#b296df" : "#b5b5b5"));
    }

    /**
     * 发送文本或弹幕消息
     * @param isBarrage
     */
    public boolean sendTextMessage(boolean isBarrage){
        boolean result = false;
        sendTextMessagePreProcess(isBarrage);
        String message = et_liveMsg.getText().toString();
        Log.d(TAG,"sendTextMessage-isBarrage:"+isBarrage+" message:"+message);
        IMMessageItem msgItem = null;
        if(!TextUtils.isEmpty(message)) {
            if(null != mIMRoomInItem && !TextUtils.isEmpty(mIMRoomInItem.roomId)){
                if (isBarrage) {
                    if(LiveRoomCreditRebateManager.getInstance().getCredit()<0.1){
                        showCreditNoEnoughPopupWindow(R.string.liveroom_popup_credits_noenough,flContentBody,false);
                        return false;
                    }
                    msgItem = mIMManager.sendBarrage(mIMRoomInItem.roomId, message);
                } else {
                    msgItem = mIMManager.sendRoomMsg(mIMRoomInItem.roomId, message, new String[]{});
                }
            }

        }
        result = msgItem != null;
        Log.d(TAG,"sendTextMessage-result:"+result);
        return result;
    }

    /**
     * 发送文本或弹幕前消息预处理逻辑
     * @param isBarrage
     */
    public void sendTextMessagePreProcess(boolean isBarrage){}

    @Override
    public void OnRecvRoomMsg(IMMessageItem msgItem) {
        Log.d(TAG,"OnRecvRoomMsg-msgItem:"+msgItem);
        sendMessageUpdateEvent(msgItem);
    }

    //******************************** 软键盘打开关闭的监听****************************************************************
    private boolean isSoftInputOpen = false;

    /**
     * 调整view高度, 解决背景在AdjustSize时会被推上去问题
     */
    private void setSizeUnChanageViewParams(){
        int statusBarHeight = DisplayUtil.getStatusBarHeight(mContext);
        if(statusBarHeight > 0){
            int activityHeight = DisplayUtil.getScreenHeight(mContext) - statusBarHeight;
            LinearLayout.LayoutParams params = (LinearLayout.LayoutParams)findViewById(R.id.fl_bgContent).getLayoutParams();
            params.height = activityHeight;
            //设置固定宽高，解决键盘弹出挤压问题
            FrameLayout.LayoutParams advanceGiftParams = (FrameLayout.LayoutParams)advanceGift.getLayoutParams();
            advanceGiftParams.height = activityHeight;
            //设置IM区域高度，处理弹出效果
            FrameLayout.LayoutParams imParams = (FrameLayout.LayoutParams)imBody.getLayoutParams();
            imParams.height = activityHeight-(int)getResources().getDimension(R.dimen.imButtomMargin);
        }
    }

    @Override
    public void onSoftKeyboardShow() {
        Log.d(TAG, "onSoftKeyboardShow");
        isSoftInputOpen = true;
//        playRoomHeaderOutAnim();
        //判断是否弹幕播放中，是则隐藏底部白底阴影
        if(null != mBarrageManager){
            mBarrageManager.changeBulletScreenBg(false);
        }
    }

    @Override
    public void onSoftKeyboardHide() {
        android.util.Log.i(TAG, "onSoftKeyboardHide");
        isSoftInputOpen = false;
        //如果onSoftKeyboardHide回调是由表情控件触发
        if(isEmojiOpera){
            isEmojiOpera = false;
            return;
        }
        if(rl_inputMsg != null){
            rl_inputMsg.setVisibility(View.INVISIBLE);
        }
        //判断是否弹幕播放中，是则显示底部白底阴影
        mBarrageManager.changeBulletScreenBg(true);
    }

    //******************************** 消息展示列表 ****************************************************************
    /**
     * 初始化消息展示列表
     */
    private void initMessageList(){
        liveRoomChatManager = new LiveRoomChatManager();
        liveRoomChatManager.init(this,findViewById(R.id.fl_msglist));

        //incliude view id 必须通过setOnClickListener方式设置onclick监听,
        // xml中include标签下没有onclick和clickable属性
        findViewById(R.id.fl_imMsgContainer).setOnClickListener(this);
    }

    @Override
    public void OnRecvSendSystemNotice(IMMessageItem msgItem) {
        super.OnRecvSendSystemNotice(msgItem);
        sendMessageUpdateEvent(msgItem);
    }

    //******************************** 弹幕动画 ****************************************************************
    private BarrageManager<IMMessageItem> mBarrageManager;

    /**
     * 初始化弹幕
     */
    private void initBarrage(){
        ViewCompat.setElevation(ll_bulletScreen,DisplayUtil.dip2px(this,3f));
        List<View> mViews = new ArrayList<View>();
        mViews.add(findViewById(R.id.rl_bullet1));
        mBarrageManager = new BarrageManager<IMMessageItem>(this, mViews,ll_bulletScreen);
        mBarrageManager.setBarrageFiller(new IBarrageViewFiller<IMMessageItem>() {
            @Override
            public void onBarrageViewFill(View view, IMMessageItem item) {
                CircleImageView civ_bullletIcon = (CircleImageView) view.findViewById(R.id.civ_bullletIcon);
                TextView tv_bulletName = (TextView) view.findViewById(R.id.tv_bulletName);
                TextView tv_bulletContent = (TextView) view.findViewById(R.id.tv_bulletContent);
                if(item != null){
                    tv_bulletName.setText(item.nickName);
                    tv_bulletContent.setText(ChatEmojiManager.getInstance().parseEmoji(
                            item.textMsgContent.message, ChatEmojiManager.CHATEMOJI_MODEL_EMOJIDES,
                            (int)getResources().getDimension(R.dimen.liveroom_messagelist_barrage_width),
                            (int)getResources().getDimension(R.dimen.liveroom_messagelist_barrage_height)));
                    String photoUrl = null;
                    if(TestDataUtil.isContinueTestTask){
                        photoUrl = TestDataUtil.roomBgs[new Random().nextInt(TestDataUtil.roomBgs.length)];
                    }else{
                        if(null != mIMManager){
                            IMUserBaseInfoItem baseInfo = mIMManager.getUserInfo(item.userId);
                            if(baseInfo != null){
                                photoUrl = baseInfo.photoUrl;
                            }
                        }
                    }

                    if(!TextUtils.isEmpty(photoUrl)){
                        Picasso.with(BaseCommonLiveRoomActivity.this.getApplicationContext())
                                .load(photoUrl)
                                .placeholder(R.drawable.ic_default_photo_man)
                                .error(R.drawable.ic_default_photo_man)
                                .into(civ_bullletIcon);
                    }else{
                        civ_bullletIcon.setImageResource(R.drawable.circleimageview_hugh);
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
            LoginItem item = LoginManager.getInstance().getmLoginItem();
            mBarrageManager.addBarrageItem(msgItem);
        }
    }

    @Override
    public void OnSendBarrage(boolean success, IMClientListener.LCC_ERR_TYPE errType,
                              String errMsg, IMMessageItem msgItem, double credit,
                              double rebateCredit) {
        super.OnSendBarrage(success,errType,errMsg,msgItem,credit,rebateCredit);
    }


    /********************************* IMManager事件监听回调  *******************************************/

    @Override
    public void OnRoomOut(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
        super.OnRoomOut(reqId,success,errType,errMsg);
    }

    @Override
    public void OnRecvRoomToastNotice(IMMessageItem msgItem) {
        super.OnRecvRoomToastNotice(msgItem);
        sendMessageUpdateEvent(msgItem);
    }

    @Override
    protected void onCreditUpdate() {
        super.onCreditUpdate();
        Message msg = Message.obtain();
        msg.what = EVENT_UPDATE_CREDITS;
        sendUiMessage(msg);
    }

    //------------------------直播间关闭-------------------------------------------------------

    /**
     * 用户收到房间关闭通知
     * @param roomId
     */
    @Override
    public void OnRecvRoomCloseNotice(String roomId, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
        super.OnRecvRoomCloseNotice(roomId, errType, errMsg);
        if(null != mIMRoomInItem && !TextUtils.isEmpty(mIMRoomInItem.roomId) && roomId.equals(mIMRoomInItem.roomId)){
            Message msg = Message.obtain();
            msg.what = EVENT_AUDIENCE_ROOMEND;
            sendUiMessage(msg);
        }
    }

    protected void endLive(boolean isEndByLeaveTooLong,IMRoomInItem.IMLiveRoomType roomType){
        startActivity(EndLiveActivity.getEndLiveIntent(this,mIMRoomInItem.photoUrl,mIMRoomInItem.userId,
                mIMRoomInItem.nickName, roomType,mRoomPhotoUrl,isEndByLeaveTooLong));
        finish();
    }


    /********************************* 男士publisher逻辑start *******************************************/

    private boolean isPublishing = false;       //是否正在视频互动中
    private boolean isPublishMute = false;      //视频互动中是否静音
    private LSPublisher mPublisher;             //视频推流器
    private int mVideoInteractionReqId = -1;    //解决区分请求是否处理问题

    /**
     * 初始化视频互动界面
     */
    private void initPublishView(){
        //视频上传预览
        includePublish = (View) findViewById(R.id.includePublish);
        svPublisher = (SurfaceView)findViewById(R.id.svPublisher);
        rlPublishOperate = (RelativeLayout)findViewById(R.id.rlPublishOperate);
        ivPublishStart = (ImageView) findViewById(R.id.ivPublishStart);
        ivPublishMute = (ImageView)findViewById(R.id.ivPublishMute);
        publishLoading = (MaterialProgressBar) findViewById(R.id.publishLoading);

        ivPublishStart.setOnClickListener(this);
        ivPublishMute.setOnClickListener(this);
        includePublish.setOnClickListener(this);
    }

    /**
     * 初始化数据显示
     */
    private void initPublishData(){
        if(mIMRoomInItem != null && mIMRoomInItem.roomType == IMLiveRoomType.AdvancedPrivateRoom){
            //豪华私密直播间才支持视频互动功能
            includePublish.setVisibility(View.VISIBLE);

            //播放器初始化
            mPublisher = new LSPublisher();
            int rotation = getWindowManager().getDefaultDisplay().getRotation();
            mPublisher.init(svPublisher, rotation, null);
            if(mIMRoomInItem.manUploadRtmpUrls != null
                    && mIMRoomInItem.manUploadRtmpUrls.length > 0 && !TextUtils.isEmpty(mIMRoomInItem.manUploadRtmpUrls[0])){
                startPublishStream(mIMRoomInItem.manUploadRtmpUrls[0]);
            }
        }else{
            includePublish.setVisibility(View.GONE);
        }
    }

    /**
     * 断线重连重新进入房间，互动模块处理
     * @param manPushUrl
     */
    private void onDisconnectRoomIn(String manPushUrl){
        if(!TextUtils.isEmpty(manPushUrl)){
            startPublishStream(manPushUrl);
        }else{
            stopPublishStream();
        }
    }

    /**
     * 隐藏操作区
     */
    private Runnable mHideOperateRunnable = new Runnable() {
        @Override
        public void run() {
            if(rlPublishOperate != null){
                rlPublishOperate.setVisibility(View.GONE);
            }
        }
    };

    /**
     * 开启／关闭视频互动返回 或 点击视频上传，显示按钮
     */
    private void refreshPublishViews(){
        rlPublishOperate.setVisibility(View.VISIBLE);
        //清除隐藏操作区定时任务
        removeCallback(mHideOperateRunnable);
        if(isPublishing){
            ivPublishStart.setImageResource(R.drawable.live_publish_pause);
            ivPublishMute.setVisibility(View.VISIBLE);
            if(isPublishMute){
                //静音
                ivPublishMute.setImageResource(R.drawable.live_publish_mute);
            }else{
                ivPublishMute.setImageResource(R.drawable.live_publish_sound_open);
            }
            //启动3秒后隐藏操作区
            postUiRunnableDelayed(mHideOperateRunnable, 3 * 1000);
        }else{
            ivPublishStart.setImageResource(R.drawable.live_publish_start_btn);
            ivPublishMute.setVisibility(View.GONE);
        }
    }

    /**
     * 开始／关闭视频互动
     */
    private void startOrStopVideoInteraction(){
        if(mIMRoomInItem != null){
            IMClient.IMVideoInteractiveOperateType type = IMClient.IMVideoInteractiveOperateType.Start;
            if(isPublishing){
                type = IMClient.IMVideoInteractiveOperateType.Close;
            }
            mVideoInteractionReqId = mIMManager.ControlManPush(mIMRoomInItem.roomId, type);
            if(IM_INVALID_REQID != mVideoInteractionReqId){
                //发出请求成功
                rlPublishOperate.setVisibility(View.GONE);
                publishLoading.setVisibility(View.VISIBLE);
            }
        }
    }

    /**
     * 设置静音
     */
    private void setPublishMute(){
        if(mPublisher != null){
            isPublishMute = !isPublishMute;
            mPublisher.setMute(isPublishMute);
        }
    }

    /**
     * 开始视频上传
     * @param manPushUrl
     */
    private void startPublishStream(String manPushUrl){
        isPublishing = true;
        refreshPublishViews();     //刷新界面
        if(mPublisher != null){
            mPublisher.stop();
            mPublisher.setMute(isPublishMute);
            mPublisher.publisherUrl(manPushUrl, "", "");
        }
    }

    /**
     * 停止上传视频
     */
    public void stopPublishStream(){
        isPublishing = false;
        refreshPublishViews();     //刷新界面
        if(mPublisher != null){
            mPublisher.stop();
        }
    }

    /**
     * 开启／关闭视频互动回调
     * @param reqId
     * @param success
     * @param errType
     * @param errMsg
     * @param manPushUrl
     */
    @Override
    public void OnControlManPush(int reqId, final boolean success, IMClientListener.LCC_ERR_TYPE errType, final String errMsg, final String[] manPushUrl) {
        super.OnControlManPush(reqId, success, errType, errMsg, manPushUrl);
        if(mVideoInteractionReqId == reqId) {
            //请求需要处理
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    publishLoading.setVisibility(View.GONE);
                    if (success) {
                        if (isPublishing) {
                           //停止上传
                            stopPublishStream();
                        }else{
                            //启动上传
                            if(manPushUrl != null && manPushUrl.length > 0){
                                startPublishStream(manPushUrl[0]);
                            }else{
                                //状态异常，处理为启动失败
                                showToast(getResources().getString(R.string.common_webview_load_error));
                                //调用关闭，防止持续扣费
                                mIMManager.ControlManPush(mIMRoomInItem.roomId, IMClient.IMVideoInteractiveOperateType.Close);
                            }
                        }
                    } else {
                        //开启或关闭失败
                        showToast(errMsg);
                        refreshPublishViews();
                    }
                }
            });
        }
    }

    /**
     * 回收互动相关资源
     */
    private void onPublisherDestroy(){
        if(mPublisher != null){
            mPublisher.stop();
            mPublisher.uninit();
        }
        removeCallback(mHideOperateRunnable);
    }

    /*********************************  男士publisher逻辑end  *******************************************/

    /*******************************断线重连****************************************/
    @Override
    public void onIMAutoReLogined() {
        super.onIMAutoReLogined();
        //断线重连，需要拿roomId重新登录房间
        Log.d(TAG,"onIMAutoReLogined-mIMRoomInItem:"+mIMRoomInItem);
        if(null != mIMRoomInItem && !TextUtils.isEmpty(mIMRoomInItem.roomId)){
            switch (mIMRoomInItem.roomType){
                case FreePublicRoom:
                    if(null != mIMManager){
                        int result = mIMManager.RoomIn(mIMRoomInItem.roomId);
                        Log.d(TAG,"onIMAutoReLogined-result:"+result+"IM_INVALID_REQID:"+IM_INVALID_REQID);
                    }
                    break;
            }
        }
    }
}
