package com.qpidnetwork.livemodule.liveshow.liveroom;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Color;
import android.graphics.PixelFormat;
import android.graphics.drawable.AnimationDrawable;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.opengl.GLSurfaceView;
import android.os.Build;
import android.os.Bundle;
import android.os.Message;
import android.support.annotation.Nullable;
import android.support.v4.app.FragmentManager;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.Editable;
import android.text.SpannableString;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.SurfaceHolder;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.view.animation.TranslateAnimation;
import android.view.inputmethod.EditorInfo;
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.dou361.dialogui.DialogUIUtils;
import com.facebook.drawee.backends.pipeline.Fresco;
import com.facebook.drawee.controller.AbstractDraweeController;
import com.facebook.drawee.view.SimpleDraweeView;
import com.facebook.imagepipeline.common.ResizeOptions;
import com.facebook.imagepipeline.postprocessors.IterativeBoxBlurPostProcessor;
import com.facebook.imagepipeline.request.ImageRequest;
import com.facebook.imagepipeline.request.ImageRequestBuilder;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetSendableGiftListCallback;
import com.qpidnetwork.livemodule.httprequest.OnRequestCallback;
import com.qpidnetwork.livemodule.httprequest.item.AudienceBaseInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.EmotionCategory;
import com.qpidnetwork.livemodule.httprequest.item.EmotionItem;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.httprequest.item.HangoutOnlineAnchorItem;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.httprequest.item.SendableGiftItem;
import com.qpidnetwork.livemodule.httprequest.item.TalentInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.TalentInviteItem;
import com.qpidnetwork.livemodule.im.IMClient;
import com.qpidnetwork.livemodule.im.listener.IMAuthorityItem;
import com.qpidnetwork.livemodule.im.listener.IMClientListener;
import com.qpidnetwork.livemodule.im.listener.IMGiftMessageContent;
import com.qpidnetwork.livemodule.im.listener.IMHangoutRecommendItem;
import com.qpidnetwork.livemodule.im.listener.IMLoveLeveItem;
import com.qpidnetwork.livemodule.im.listener.IMMessageItem;
import com.qpidnetwork.livemodule.im.listener.IMPackageUpdateItem;
import com.qpidnetwork.livemodule.im.listener.IMRebateItem;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem.IMLiveRoomType;
import com.qpidnetwork.livemodule.im.listener.IMSysNoticeMessageContent;
import com.qpidnetwork.livemodule.im.listener.IMTextMessageContent;
import com.qpidnetwork.livemodule.im.listener.IMUserBaseInfoItem;
import com.qpidnetwork.livemodule.liveshow.WebViewActivity;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseRecyclerViewAdapter;
import com.qpidnetwork.livemodule.liveshow.adapter.HorizontalLineDecoration;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.datacache.preference.LocalPreferenceManager;
import com.qpidnetwork.livemodule.liveshow.flowergift.store.FlowersAnchorShopListActivity;
import com.qpidnetwork.livemodule.liveshow.liveroom.announcement.WarningDialog;
import com.qpidnetwork.livemodule.liveshow.liveroom.car.CarInfo;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.GiftSendReqManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.GiftSender;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.ModuleGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.NormalGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.RoomGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.adapter.LiveVirtualGiftRecommandAdapter;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.dialog.LiveVirtualGiftDialog;
import com.qpidnetwork.livemodule.liveshow.liveroom.hangout.view.HangOutDetailDialogFragment;
import com.qpidnetwork.livemodule.liveshow.liveroom.interactivevideo.OpenInterVideoTipsPopupWindow;
import com.qpidnetwork.livemodule.liveshow.liveroom.rebate.LiveRoomCreditRebateManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.rebate.RoomRebateTipsPopupWindow;
import com.qpidnetwork.livemodule.liveshow.liveroom.recharge.AudienceBalanceInfoPopupWindow;
import com.qpidnetwork.livemodule.liveshow.liveroom.talent.TalentManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.tariffprompt.TariffPromptManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.vedio.VedioLoadingAnimManager;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.liveshow.personal.chatemoji.ChatEmojiManager;
import com.qpidnetwork.livemodule.liveshow.personal.chatemoji.EmoJiTabIconLayout;
import com.qpidnetwork.livemodule.liveshow.urlhandle.AppUrlHandler;
import com.qpidnetwork.livemodule.utils.ApplicationSettingUtil;
import com.qpidnetwork.livemodule.utils.FrescoLoadUtil;
import com.qpidnetwork.livemodule.utils.PicassoLoadUtil;
import com.qpidnetwork.livemodule.utils.StringUtil;
import com.qpidnetwork.livemodule.utils.SystemUtils;
import com.qpidnetwork.livemodule.view.CircleImageHorizontScrollView;
import com.qpidnetwork.livemodule.view.LiveRoomHeaderBezierView;
import com.qpidnetwork.livemodule.view.LiveRoomScrollView;
import com.qpidnetwork.livemodule.view.dialog.CommonBuyCreditDialog;
import com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder;
import com.qpidnetwork.qnbridgemodule.util.DisplayUtil;
import com.qpidnetwork.qnbridgemodule.util.Log;
import com.qpidnetwork.qnbridgemodule.view.keyboardLayout.KeyBoardManager;
import com.qpidnetwork.qnbridgemodule.view.keyboardLayout.SoftKeyboardSizeWatchLayout;
import com.xiao.nicevideoplayer.VideoPlaylerBroadcastReceiver;

import net.qdating.LSPlayer;
import net.qdating.LSPublisher;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static com.qpidnetwork.livemodule.im.IMManager.IM_INVALID_REQID;
import static com.qpidnetwork.livemodule.im.listener.IMClientListener.LCC_ERR_TYPE.LCC_ERR_INCONSISTENT_CREDIT_FAIL;
import static com.qpidnetwork.livemodule.im.listener.IMClientListener.LCC_ERR_TYPE.LCC_ERR_NO_CREDIT;
import static com.qpidnetwork.livemodule.im.listener.IMClientListener.LCC_ERR_TYPE.LCC_ERR_NO_CREDIT_DOUBLE_VIDEO;
import static com.qpidnetwork.livemodule.im.listener.IMClientListener.LCC_ERR_TYPE.LCC_ERR_NO_CREDIT_DOUBLE_VIDEO_NOTICE;
import static com.qpidnetwork.livemodule.liveshow.liveroom.LiveRoomNormalErrorActivity.PageErrorType.PAGE_ERROR_LIEV_EDN;
import static com.qpidnetwork.livemodule.liveshow.liveroom.LiveRoomNormalErrorActivity.PageErrorType.PAGE_ERROR_NOMONEY;
import static com.xiao.nicevideoplayer.VideoPlaylerBroadcastReceiver.ACTION_START_PLAY;
import static com.xiao.nicevideoplayer.VideoPlaylerBroadcastReceiver.ACTION_STOP_PLAY;

/**
 * 全屏直播间公共处理界面类
 * 1.界面刷新，数据展示的处理放在该BaseActivity内处理
 * 2.设计到具体的房间类型内的，各种业务请求预处理，返回数据处理，各类型房间业务流程等的处理，都放到子类中做
 * 3.需要不断的review code，保证baseActivity、baseImplActivity及子类的职责明确
 *
 * 以 {@link BaseCommonLiveRoomActivity} 为基础修改
 * Copy by Jagger 2019-9-2.
 * 4.继承这个类，要使用android:windowSoftInputMode="stateHidden|adjustPan"模式
 */

public class BaseCommonFullScreenLiveRoomActivity extends BaseImplLiveRoomActivity
        implements SoftKeyboardSizeWatchLayout.OnResizeListener,
        FullScreenLiveRoomChatMsgListItemUiManager.LiveMessageListItemClickListener,
        HangoutInvitationManager.OnHangoutInvitationEventListener {

    /**
     * 直播间消息更新
     */
    private final int EVENT_MESSAGE_UPDATE = 1001;
    /**
     * 在线观众头像列表更新
     */
    protected final int EVENT_MESSAGE_UPDATE_ONLINEFANS = 1002;
    /**
     * 隐藏资费提示
     */
    private final int EVENT_MESSAGE_HIDE_TARIFFPROMPT = 1003;
    /**
     * 接受观众进入直播间通知
     */
    public final int EVENT_MESSAGE_ENTERROOMNOTICE = 1004;
//    /**
//     * 成功获取房间可发送礼物配置信息
//     */
//    private static final int EVENT_UPDATE_SENDABLEGIFT =1005;
//    /**
//     * 成功获取所有背包礼物配置信息
//     */
//    private static final int EVENT_UPDATE_BACKPACKGIFT =1006;
    /**
     * 收藏/取消收藏主播
     */
    protected final int EVENT_FAVORITE_RESULT = 1007;
    /**
     * 直播间观众数量更新
     */
    protected final int EVENT_UPDATE_ONLINEFANSNUM = 1009;
    /**
     * 高级礼物发送失败，3秒toast提示
     */
    private final int EVENT_GIFT_ADVANCE_SEND_FAILED = 1010;
    /**
     * 礼物发送失败-信用点不足
     */
    private final int EVENT_GIFT_SEND_FAILED_CREDITS_NOENOUGH = 1011;
    /**
     * 更新返点
     */
    private final int EVENT_UPDATE_REBATE = 1012;
    /**
     * 直播间界面进入后台
     */
    private final int EVENT_TIMEOUT_BACKGROUND = 1013;
    /**
     * 直播间关闭倒计时
     */
    private final int EVENT_LEAVING_ROOM_TIMECOUNT = 1014;
    /**
     * 亲密度等级升级，更新界面展示
     */
    private final int EVENT_INTIMACY_LEVEL_UPDATE = 1015;
    /**
     * 播放礼物动画
     */
    private final int EVENT_SHOW_GIFT = 1017;
    /**
     * 用户等级升级
     */
    private final int EVENT_MAN_LEVEL_UPDATE = 1018;

    /**
     * 才艺发送成功
     */
    private final int EVENT_TALENT_SENT_SUCCESS = 1019;

    /**
     * 才艺发送失败
     */
    private final int EVENT_TALENT_SENT_FAIL = 1020;

    /**
     * 接收才艺消息
     */
    private final int EVENT_REC_TALENT_NOTICE = 1021;

    /**
     * 消息列表最大占屏高
     */
    private final double MSG_LIST_MAX_HEIGTH_FOR_SCREEN = 0.35;

    /**
     * 入场座驾 平移时间
     */
    private final int CAR_ANIM_TRANSLATE_TIME = 1000;

    /**
     * 入场座驾 渐隐时间
     */
    private final int CAR_ANIM_ALPHA_TIME = 1000;

    /**
     * 输入键盘类型
     */
    private enum InputAreaStatus {
        HIDE,       //隐藏
        EMOJI,      //表情
        KEYBOARD    //键盘
    }

    /**
     * 输入框旁边的，表情/键盘切换按钮 的状态
     */
    private enum InputChangeBtnStatus {
        EMOJI,      //表情
        KEYBOARD    //键盘
    }

    //整个view的父，用于解决软键盘等监听
    public SoftKeyboardSizeWatchLayout flContentBody;
    public LiveRoomScrollView lrsv_roomBody;
    public RoomThemeManager roomThemeManager = new RoomThemeManager();

    //--------------------------------直播间头部视图层--------------------------------
    protected View view_roomHeader;
    private LiveRoomHeaderBezierView lrhbv_flag;
    //主播信息
    private CircleImageView civ_hostIcon;
    private TextView tv_hostName;
    private TextView tv_hostId;
    private TextView tv_roomFlag;
    //    private ImageView iv_follow;
    private View ll_hostInfoView;
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
    protected View ll_freePublic;
    protected TextView tv_onlineNum;
    //付费公开直播间
    protected RelativeLayout rl_vipPublic;
    protected TextView tv_vipGuestData;
    protected CircleImageHorizontScrollView cihsv_onlineVIPPublic;
    //**私密直播间
    protected View ll_privateRoomHeader;
    protected ImageView iv_prvUserIconBg;
    protected CircleImageView civ_prvUserIcon;
    protected CircleImageView civ_prvHostIcon;
    protected ImageView iv_intimacyPrv;
    protected ImageView iv_prvHostIconBg;
    protected ImageView iv_followPrvHost;

    protected ImageView iv_closeLiveRoom;

    //新增头部hangout按钮
//    protected TextView tvInviteTips;        //邀请状态处理

    //返点
    private TextView tv_rebateTips;
    private TextView tv_rebateValue;
    private View ll_rebate;
    private View view_roomHeader_buttomLine;
    private RoomRebateTipsPopupWindow roomRebateTipsPopupWindow;

    //---------------------消息编辑区域--------------------------------------
    private View rl_inputMsg;
    private FrameLayout v_roomEditMegBg;
    private LinearLayout ll_input_edit_body;
    private FrameLayout fl_inputArea;
    private EditText et_liveMsg;
    private TextView iv_sendMsg;
    // 2019/9/5 Hardy
    private EmoJiTabIconLayout emoJiTabIconLayout;
    private int mEmojiTextWH;

    private EmotionItem chooseEmotionItem = null;
    protected ImageView iv_emojiSwitch;
    private int mKeyBoardHeight = 0;    //键盘高度
    private InputAreaStatus mInputAreaStatus = InputAreaStatus.HIDE;
    private InputChangeBtnStatus mInputChangeBtnStatus = InputChangeBtnStatus.EMOJI;

    //聊天展示区域
    private RelativeLayout fl_imMsgContainer;
    private FullScreenLiveRoomChatManager liveRoomChatManager;
    private long lastMsgSentTime = 0l;
    //弹幕
    private boolean isBarrage = false;

    //礼物模块
    protected ModuleGiftManager mModuleGiftManager;

    // 2019/9/3 Hardy
    private LiveVirtualGiftDialog liveVirtualGiftDialog;

    //大礼物
    private SimpleDraweeView advanceGift;

    private boolean hasShowCreditsLackTips = false;

    //视频播放
    protected SimpleDraweeView iv_vedioBg;
    public GLSurfaceView sv_player;
    private View rl_media;
    private View imBody;
    protected View include_audience_area;
    private LivePlayerManager mLivePlayerManager;
    protected SimpleDraweeView sdv_vedioLoading;
    protected VedioLoadingAnimManager vedioLoadingAnimManager;

    //座驾
    protected LinearLayout ll_entranceCar;
    private SimpleDraweeView iv_car;
    private TextView  tv_joined;

    //私密预约按钮
    protected TextView tv_enterPrvRoomTimerCount;
    protected LinearLayout ll_enterPriRoomTimeCount;
    private int leavingRoomTimeCount = 30;//30-default

    //------------ 男士互动区域 ------------
    private LinearLayout ll_msg_menu;   //消息列表旁边菜单
    protected ImageButton iv_publish_cam, iv_flowers;
    protected View includePublish;
    protected GLSurfaceView svPublisher;
    protected FrameLayout flPublishOperate;
    protected ImageView iv_publishstart;
    protected ImageView iv_publishstop;
    protected ImageView iv_publishsoundswitch;
    protected ProgressBar publishLoading;
    protected View view_gaussian_blur_me;
    protected SimpleDraweeView iv_gaussianBlur;
    protected View v_gaussianBlurFloat;

    //------------直播间底部---------------
    protected ImageView iv_gift;        //显示礼物弹框

    protected boolean hasBackgroundTimeOut = false;
    protected boolean closeRoomByUser = false;

    //处理后台(即当前页不可用见时收到直播间关闭处理)
    private boolean mIsNeedRecommand = false;
    private boolean mIsNeedCommand = true;
    private boolean mIsRoomBackgroundClose = false;
    private LiveRoomNormalErrorActivity.PageErrorType mClosePageErrorType;
    private String mCloseErrMsg = "";

    //房间礼物管理器
    private RoomGiftManager mRoomGiftManager;

    //Hang-out邀请管理器
    private HangoutInvitationManager mHangoutInvitationManager;
    private String mInvitationRoomId = "";


    private VideoPlaylerBroadcastReceiver receiver = new VideoPlaylerBroadcastReceiver() {
        @Override
        protected void onVideoStateChange(String s) {

            switch (s) {
                case ACTION_START_PLAY:
                    mLivePlayerManager.setPullStreamSilent(true);
                    break;
                case ACTION_STOP_PLAY:
                    mLivePlayerManager.setPullStreamSilent(false);
                    break;
            }
        }
    };

    private IntentFilter filter = new IntentFilter();

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        TAG = BaseCommonFullScreenLiveRoomActivity.class.getName();
        super.onCreate(savedInstanceState);
        initReceiver();

        //直播间中不熄灭屏幕
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON,
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

        setContentView(R.layout.activity_full_screen_live_room);
        setImmersionBarArtts(R.color.live_room_header_gradient_start_color);

        //初始化房间礼物管理器
        if (mIMRoomInItem != null) {
            mRoomGiftManager = new RoomGiftManager(mIMRoomInItem);
        }

        initViews();

        if (null != mIMRoomInItem) {
            initData();
            GiftSender.getInstance().currRoomId = mIMRoomInItem.roomId;
        }

        GiftSendReqManager.getInstance().executeNextReqTask();
        ChatEmojiManager.getInstance().getEmojiList(null);
        //同步模块直播进行中
        String targetId = "";
        if (mIMRoomInItem != null) {
            targetId = mIMRoomInItem.userId;
        }
        //才艺点播
        initTalentManager();
    }

    private void initReceiver() {

        filter.addAction(ACTION_START_PLAY);
        filter.addAction(ACTION_STOP_PLAY);
        registerReceiver(receiver, filter);
    }

    private void initViews() {
        Log.d(TAG, "initViews");
        //解决软键盘关闭的监听问题
        flContentBody = findViewById(R.id.flContentBody);
        flContentBody.addOnResizeListener(this);

        lrsv_roomBody = (LiveRoomScrollView) findViewById(R.id.lrsv_roomBody);
        //邀请中提示文字区域
//        tvInviteTips = (TextView) findViewById(R.id.tvInviteTips);

        initRoomHeader();
        if (null != mIMRoomInItem) {
            initRoomViewDataAndStyle();
        }
        imBody = findViewById(R.id.include_im_body);

        //键盘高度
        mKeyBoardHeight = KeyBoardManager.getKeyboardHeight(this);
        //edit by Jagger 2018-9-6
        //黑莓手机，有物理键盘，取出键盘高度只有 100＋PX，效果不好。如果取出键盘高度，小于min_keyboard_height，就用默认的吧
        if (mKeyBoardHeight < getResources().getDimensionPixelSize(R.dimen.min_keyboard_height)) {
            mKeyBoardHeight = getResources().getDimensionPixelSize(R.dimen.min_keyboard_height);
        }

        initVideoPlayer();
        initRebateView();
        initLiveRoomCar();

        // 2019/9/4 Hardy
        initLiveVirtualGiftDialog();

        initMultiGift();
        initMessageList();
//        initBarrage();
        initEditAreaView();
        initEditAreaViewStyle();
        //互动模块初始化
        initPublishView();
        //加载推荐礼物模块
        initRecommandViews();
    }

    /**
     * 初始化数据
     */
    public void initData() {
        if (null != mIMRoomInItem) {
            //添加主播头像信息,方便web端主播送礼时客户端能够在小礼物动画上展示其头像
            mIMManager.updateOrAddUserBaseInfo(mIMRoomInItem.userId,
                    mIMRoomInItem.nickName, mIMRoomInItem.photoUrl);
        }
        //添加试用券使用提示
        if (null != mIMRoomInItem && mIMRoomInItem.usedVoucher) {
            Log.d(TAG, "initData-mIMRoomInItem.usedVoucher");
            sendMessageVoucherEvent(mIMRoomInItem);
        }


        if (null != loginItem) {
            //获取本人座驾
            LiveRequestOperator.getInstance().GetAudienceDetailInfo(loginItem.userId, this);
        }
        //返点信息初始化
        if (mIMRoomInItem.roomType != IMLiveRoomType.FreePublicRoom
                && null != mIMRoomInItem.rebateItem && null != roomRebateTipsPopupWindow
                && (mIMRoomInItem.videoUrls != null && mIMRoomInItem.videoUrls.length > 0)) {
            //主播已推流才开始进行返点倒计时操作
            roomRebateTipsPopupWindow.notifyReBateUpdate(mIMRoomInItem.rebateItem);
            tv_rebateValue.setText(ApplicationSettingUtil.formatCoinValue(mIMRoomInItem.rebateItem.cur_credit));
        }
        //主播视频流加载
        if (mIMRoomInItem.videoUrls != null && mIMRoomInItem.videoUrls.length > 0) {
            startLivePlayer(mIMRoomInItem.videoUrls);
        } else {
            if (null != vedioLoadingAnimManager) {
                vedioLoadingAnimManager.showLoadingAnim();
            }
        }

        //初始化推荐礼物区域
        initRecommandData();

        //load package gift
        if (mRoomGiftManager != null) {
            //刷新直播间背包列表
            mRoomGiftManager.getPackageGiftItems(null);
        }

        //load recommand gift
        loadRecommandGiftList();
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);
        int i = v.getId();
        if (i == R.id.ll_rebate) {
            if (null != roomRebateTipsPopupWindow) {
                roomRebateTipsPopupWindow.showAtLocation(flContentBody, Gravity.CENTER, 0, 0);
            }
            //GA返点点击GA统计
            onAnalyticsEvent(getResources().getString(R.string.Live_Broadcast_Category),
                    getResources().getString(R.string.Live_Broadcast_Action_RewardedCredit),
                    getResources().getString(R.string.Live_Broadcast_Label_RewardedCredit));

        } else if (i == R.id.iv_prvHostIconBg || i == R.id.civ_prvHostIcon || i == R.id.tv_hostName
                || i == R.id.civ_hostIcon) {
            visitHostInfo();
        }
        else if (i == R.id.iv_emojiSwitch) {
            //处理表情view顶起后的输入框跟随顶起逻辑--用户端
            if (mInputChangeBtnStatus == InputChangeBtnStatus.EMOJI) {
                showEmojiBoard();
            } else if (mInputChangeBtnStatus == InputChangeBtnStatus.KEYBOARD) {
                showKeyBoard();
            }
        } else if (i == R.id.iv_sendMsg) {
            if (0 != lastMsgSentTime && System.currentTimeMillis() - lastMsgSentTime <
                    getResources().getInteger(R.integer.minMsgSendTimeInterval) && !TextUtils.isEmpty(et_liveMsg.getText())) {
                showThreeSecondTips(getResources().getString(R.string.live_msg_send_tips), Gravity.CENTER);
                return;
            }
            lastMsgSentTime = System.currentTimeMillis();
            sendTextMessage(isBarrage);
            //清空消息
            et_liveMsg.setText("");
            //收起键盘
            hideInputArea();
        } else if (i == R.id.view_roomHeader || i == R.id.rl_media || i == R.id.fl_imMsgContainer) {//点击界面区域关闭键盘或者点赞处理
            hideInputArea();
        }
        else if (i == R.id.iv_follow || i == R.id.iv_followPrvHost) {
            sendFollowHostReq();

            //GA点击关注
            onAnalyticsEvent(getResources().getString(R.string.Live_Broadcast_Category),
                    getResources().getString(R.string.Live_Broadcast_Action_Follow),
                    getResources().getString(R.string.Live_Broadcast_Label_Follow));

        } else if (i == R.id.iv_closeLiveRoom || i == R.id.ll_closeLiveRoom) {
            userCloseRoom();
        } else if (i == R.id.iv_publishstart) {
            onStartPublishClick();
        } else if (i == R.id.iv_publish_cam) {
            onStartPublishClick();
        } else if (i == R.id.iv_flowers) {
            onFlowersClicked();
        } else if (i == R.id.iv_publishstop) {
            if (System.currentTimeMillis() - mPublishEndlastClickTime > PUBLIC_CLICK_TIME) {//判断距离上次点击小于2秒
                mPublishEndlastClickTime = System.currentTimeMillis();//记录这次点击时间
//                startOrStopVideoInteraction();
                doReqStopVideoInteraction();
            }
        } else if (i == R.id.iv_publishsoundswitch) {
            setPublishMute();
        } else if (i == R.id.includePublish) {
            if(publishLoading != null && publishLoading.getVisibility() != View.VISIBLE){
                refreshPublishViews();
            }
        } else if(i == R.id.iv_publish_cam){
            //TODO

        } else if (i == R.id.iv_gift) {
//            showLiveGiftDialog("");

            // 2019/9/3 Hardy
            showLiveVirtualGiftDialog();

            //GA点击打开礼物列表
            onAnalyticsEvent(getResources().getString(R.string.Live_Broadcast_Category),
                    getResources().getString(R.string.Live_Broadcast_Action_GiftList),
                    getResources().getString(R.string.Live_Broadcast_Label_GiftList));

        }
//        else if (i == R.id.fl_recommendGift || i == R.id.iv_recommGiftFloat || i == R.id.iv_recommendGift) {
//            //GA推荐礼物点击
//            onAnalyticsEvent(getResources().getString(R.string.Live_Broadcast_Category),
//                    getResources().getString(R.string.Live_Broadcast_Action_RecommendGift),
//                    getResources().getString(R.string.Live_Broadcast_Label_RecommendGift));
//        }
        else if (i == R.id.iv_intimacyPrv) {
            startActivity(WebViewActivity.getIntent(this,
                    getResources().getString(R.string.live_intimacy_title_h5),
                    WebViewActivity.UrlIntent.View_Audience_Intimacy_With_Anchor,
                    mIMRoomInItem.userId,
                    true));
        }
        else if (i == R.id.btn_private) {
            startActivity(LiveRoomTransitionActivity.getIntent(this,
                    LiveRoomTransitionActivity.CategoryType.Audience_Invite_Enter_Room,
                    mIMRoomInItem.userId, mIMRoomInItem.nickName, mIMRoomInItem.photoUrl,
                    null, null));
            //先跳转再关闭
            closeLiveRoom(true);
        } else if (i == R.id.llHeaderHangout) {
            //点击，弹出start hangout 提示
            FragmentManager fragmentManager = getSupportFragmentManager();
            HangoutOnlineAnchorItem anchorInfoItem = new HangoutOnlineAnchorItem();
            anchorInfoItem.anchorId = mIMRoomInItem.userId;
            anchorInfoItem.nickName = mIMRoomInItem.nickName;
            anchorInfoItem.avatarImg = mIMRoomInItem.photoUrl;
            HangOutDetailDialogFragment.showDialog(fragmentManager, anchorInfoItem, new HangOutDetailDialogFragment.OnDialogClickListener() {
                @Override
                public void onStartHangoutClick(final HangoutOnlineAnchorItem anchorItem) {
                    //点击start按钮事件，直接发起邀请
                    startHangoutInvitation(anchorItem);
                }
            });
        } else if (i == R.id.btn_hangout) {
            //点击，弹出start hangout 提示
            FragmentManager fragmentManager = getSupportFragmentManager();
            HangoutOnlineAnchorItem anchorInfoItem = new HangoutOnlineAnchorItem();
            anchorInfoItem.anchorId = mIMRoomInItem.userId;
            anchorInfoItem.nickName = mIMRoomInItem.nickName;
            anchorInfoItem.avatarImg = mIMRoomInItem.photoUrl;
            HangOutDetailDialogFragment.showDialog(fragmentManager, anchorInfoItem, new HangOutDetailDialogFragment.OnDialogClickListener() {
                @Override
                public void onStartHangoutClick(final HangoutOnlineAnchorItem anchorItem) {
                    String url = LiveUrlBuilder.createHangoutTransitionActivity(anchorItem.anchorId, anchorItem.nickName);
                    new AppUrlHandler(mContext).urlHandle(url);
                }
            });
        }
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        switch (msg.what) {
            case EVENT_INTIMACY_LEVEL_UPDATE: {
                if (null != roomThemeManager && null != mIMRoomInItem) {
                    Drawable lovelLevelDrawable = roomThemeManager.getPrivateRoomLoveLevelDrawable(this, mIMRoomInItem.loveLevel);
                    if (null != lovelLevelDrawable) {
                        iv_intimacyPrv.setImageDrawable(lovelLevelDrawable);
                    }
                }

                // 2019/9/3 Hardy
                if (liveVirtualGiftDialog != null && (mIMRoomInItem != null)) {
                    liveVirtualGiftDialog.updateRoomInfo(mIMRoomInItem);
                }

                // 2019/9/5 Hardy 高级表情需亲密度达到 3 级时开放
                if (mIMRoomInItem != null && emoJiTabIconLayout != null) {
                    emoJiTabIconLayout.notifyAdvancedListViewClickStatus(mIMRoomInItem.loveLevel >= 3);
                }
            }
            break;
            case EVENT_MAN_LEVEL_UPDATE: {
//                //用户等级升级，通知礼物列表
                // 2019/9/3 Hardy
                if (liveVirtualGiftDialog != null && (mIMRoomInItem != null)) {
                    liveVirtualGiftDialog.updateRoomInfo(mIMRoomInItem);
                }
            }
            break;
            case EVENT_LEAVING_ROOM_TIMECOUNT:
                //关闭直播间倒计时
                if (leavingRoomTimeCount >= 0) {
                    tv_enterPrvRoomTimerCount.setText(getResources().getString(R.string.liveroom_leaving_room_time_count,
                            String.valueOf(leavingRoomTimeCount)));
                    leavingRoomTimeCount -= 1;
                    sendEmptyUiMessageDelayed(EVENT_LEAVING_ROOM_TIMECOUNT, 1000l);
                } else {
                    //add by Jagger 2018-4-9
                    //Bug#9972 修复断线后不会退出直播间的问题
                    if (isActivityVisible()) {
                        Log.i("Jagger", "BaseCommonLiveRoomActivity EVENT_LEAVING_ROOM_TIMECOUNT book:" + (mAuthorityItem == null ? "null" : mAuthorityItem.isHasBookingAuth));
                        endLive(PAGE_ERROR_LIEV_EDN, getString(R.string.liveroom_transition_broadcast_ended), true, true, mAuthorityItem);
                    }
                }
                break;
            case EVENT_TIMEOUT_BACKGROUND:
                //关闭直播间，进入过度页
                Log.d(TAG, "EVENT_TIMEOUT_BACKGROUND-app处于后台超过1分钟的时间，退出房间，提示用户");
                hasBackgroundTimeOut = true;
                if (null != mIMRoomInItem && !TextUtils.isEmpty(mIMRoomInItem.roomId) && null != mIMManager) {
                    mIMManager.RoomOut(mIMRoomInItem.roomId);
                    mIMRoomInItem.roomId = "";  //不再处理直播间消息、通知等
                }

                //停止上传和拉流
                //回收拉流播放器
                if (mLivePlayerManager != null) {
                    mLivePlayerManager.uninit();
                    mLivePlayerManager = null;
                }
                //add by Jagger 2017-12-1
                destroyPublisher();
                //销毁互动UI
                removeCallback(mHideOperateRunnable);

                Log.d(TAG, "EVENT_TIMEOUT_BACKGROUND-hasBackgroundTimeOut:" + hasBackgroundTimeOut);
                break;
            case EVENT_UPDATE_REBATE:
                IMRebateItem tempIMRebateItem = mLiveRoomCreditRebateManager.getImRebateItem();
                if (null != tempIMRebateItem && null != roomRebateTipsPopupWindow) {
                    tv_rebateValue.setText(ApplicationSettingUtil.formatCoinValue(tempIMRebateItem.cur_credit));
                    roomRebateTipsPopupWindow.notifyReBateUpdate(tempIMRebateItem);
                }
                break;
            case EVENT_GIFT_ADVANCE_SEND_FAILED:
                //豪华非背包礼物，发送失败，弹toast，清理发送队列，关闭倒计时动画
                showThreeSecondTips(getResources().getString(R.string.live_gift_send_failed, msg.obj.toString()),
                        Gravity.BOTTOM | Gravity.CENTER_HORIZONTAL);

                // 2019/9/3 Hardy
                if (liveVirtualGiftDialog != null) {
                    liveVirtualGiftDialog.notifyGiftSentFailed();
                }
                break;
            case EVENT_GIFT_SEND_FAILED_CREDITS_NOENOUGH:
                String errTips = (String)msg.obj;
                //非豪华非背包礼物，发送失败(信用点不足)，弹充值对话框，清理发送队列，关闭倒计时动画
                if(TextUtils.isEmpty(errTips)){
                    errTips = getResources().getString(R.string.live_common_noenough_money_tips);
                }
                showCreditNoEnoughDialog(errTips);

                // 2019/9/3 Hardy
                if (liveVirtualGiftDialog != null) {
                    liveVirtualGiftDialog.notifyGiftSentFailed();
                }
                break;
            case EVENT_FAVORITE_RESULT:
                HttpRespObject hrObject = (HttpRespObject) msg.obj;
                onRecvFollowHostResp(hrObject.isSuccess, hrObject.errMsg);
                break;

            case EVENT_MESSAGE_ENTERROOMNOTICE:
                final CarInfo carInfo = (CarInfo) msg.obj;
                // 播放入场座驾动画
                Log.i("Jagger" , "EVENT_MESSAGE_ENTERROOMNOTICE:" + carInfo.riderUrl);

                tv_joined.setVisibility(View.VISIBLE);
                iv_car.setVisibility(View.VISIBLE);

                tv_joined.setText(getString(R.string.liveroom_entrancecar_joined, StringUtil.truncateName(carInfo.nickName)));
                FrescoLoadUtil.loadUrl(iv_car, carInfo.riderUrl, getResources().getDimensionPixelSize(R.dimen.live_enter_car_size));
                doPlayEntranceCarAnim();

                // 入场消息列表插入一条消息
                IMMessageItem msgRoomInItem = new IMMessageItem(mIMRoomInItem.roomId,
                        mIMManager.mMsgIdIndex.getAndIncrement(),
                        carInfo.userId,
                        carInfo.nickName,
                        null,
                        mIMRoomInItem.manLevel,
                        IMMessageItem.MessageType.RoomIn,
                        new IMTextMessageContent(String.format(getResources().getString(R.string.enterlive_withrider), carInfo.riderName)),
                        null
                );
                sendMessageUpdateEvent(msgRoomInItem);
                break;
            case EVENT_MESSAGE_HIDE_TARIFFPROMPT:
                if (view_tariff_prompt.getVisibility() == View.VISIBLE) {
                    showRoomTariffPrompt(null, false);
                }
                break;
            case EVENT_MESSAGE_UPDATE:
                IMMessageItem msgItem = (IMMessageItem) msg.obj;
                if (msgItem != null && msgItem.msgId > 0) {
                    //更新消息列表
                    if (null != liveRoomChatManager) {

                        liveRoomChatManager.addMessageToList(msgItem);
                    }

                    //启动消息特殊处理
                    launchAnimationByMessage(msgItem);
                }
                break;
            case EVENT_SHOW_GIFT:
                IMMessageItem msgGiftItem = (IMMessageItem) msg.obj;
                if (msgGiftItem != null && msgGiftItem.msgId > 0) {
                    launchAnimationByMessage(msgGiftItem);
                }
                break;
            case EVENT_TALENT_SENT_SUCCESS:
                TalentInfoItem talentInfoItem = (TalentInfoItem) msg.obj;
                if (talentInfoItem != null) {
                    String msgStr;
                    String talentName;
                    talentName = talentInfoItem.talentName;
                    msgStr = getString(R.string.live_talent_request_success, talentName);

                    IMMessageItem talentMsgItem = new IMMessageItem(mIMRoomInItem.roomId,
                            mIMManager.mMsgIdIndex.getAndIncrement(),
                            "",
                            IMMessageItem.MessageType.SysNotice,
                            new IMSysNoticeMessageContent(msgStr, "", IMSysNoticeMessageContent.SysNoticeType.Normal));
                    sendMessageUpdateEvent(talentMsgItem);
                }
                break;
            case EVENT_TALENT_SENT_FAIL:
                if (msg.arg1 > -1 && msg.arg1 < IMClientListener.LCC_ERR_TYPE.values().length) {
                    IMClientListener.LCC_ERR_TYPE errType = IMClientListener.LCC_ERR_TYPE.values()[msg.arg1];

                    if (LCC_ERR_NO_CREDIT == errType) {
                        //信用点不足
                        showCreditNoEnoughDialog(R.string.live_common_noenough_money_tips);
                    } else {
                        //房间错误
                        //其它错误使用服务器返回信息
                        String errMsg = (String) msg.obj;
                        if (TextUtils.isEmpty(errMsg)) {
                            showToast(errMsg);
                        }
                    }
                }

                break;
            case EVENT_REC_TALENT_NOTICE:
                TalentInviteItem talentInviteItem = (TalentInviteItem) msg.obj;
                String msgRecTalentNotice = "";
//                IMRoomInItem currIMRoomInItem = ((BaseCommonLiveRoomActivity) mActivity).mIMRoomInItem;
                String nickName = mIMRoomInItem.nickName;
                if (talentInviteItem.inviteStatus == TalentInviteItem.TalentInviteStatus.Accept) {
                    msgRecTalentNotice = getString(R.string.live_talent_accepted, nickName, talentInviteItem.name);

                    //add by Jagger 2018-5-31 需求增加同时播放大礼物
                    IMMessageItem msgGiftItemRecTalent = new IMMessageItem(mIMRoomInItem.roomId,
                            mIMManager.mMsgIdIndex.getAndIncrement(),
                            "",
                            "",
                            "",
                            0,
                            IMMessageItem.MessageType.Gift,
                            null,
                            new IMGiftMessageContent(talentInviteItem.giftId, "", talentInviteItem.giftNum, false, -1, -1, -1)
                    );
                    sendMessageShowGiftEvent(msgGiftItemRecTalent);
                } else if (talentInviteItem.inviteStatus == TalentInviteItem.TalentInviteStatus.Denied) {
                    msgRecTalentNotice = getString(R.string.live_talent_declined, nickName, talentInviteItem.name);
                }
                if (!TextUtils.isEmpty(msgRecTalentNotice)) {
                    IMMessageItem msgItemRecTalent = new IMMessageItem(mIMRoomInItem.roomId,
                            mIMManager.mMsgIdIndex.getAndIncrement(),
                            "",
                            IMMessageItem.MessageType.SysNotice,
                            new IMSysNoticeMessageContent(msgRecTalentNotice, "", IMSysNoticeMessageContent.SysNoticeType.Normal));
                    sendMessageUpdateEvent(msgItemRecTalent);
                }
                break;
            default:
                break;
        }
    }

    /**
     * 消息切换主线程
     *
     * @param msgItem
     */
    public void sendMessageUpdateEvent(IMMessageItem msgItem) {
        Log.d(TAG, "sendMessageUpdateEvent");
        Message msg = Message.obtain();
        msg.what = EVENT_MESSAGE_UPDATE;
        msg.obj = msgItem;
        sendUiMessage(msg);
    }

    /**
     * 消息切换主线程(播放礼物)
     *
     * @param msgItem
     */
    public void sendMessageShowGiftEvent(IMMessageItem msgItem) {
        Log.d(TAG, "sendMessageUpdateEvent");
        Message msg = Message.obtain();
        msg.what = EVENT_SHOW_GIFT;
        msg.obj = msgItem;
        sendUiMessage(msg);
    }

    /**
     * 发送试聊卷消息
     * @param roomInfo
     */
    public void sendMessageVoucherEvent(IMRoomInItem roomInfo){
        IMMessageItem imMessageItem = new IMMessageItem(roomInfo.roomId, mIMManager.mMsgIdIndex.getAndIncrement(), roomInfo.roomPrice, roomInfo.useCoupon);
        Message msg = Message.obtain();
        msg.what = EVENT_MESSAGE_UPDATE;
        msg.obj = imMessageItem;
        sendUiMessage(msg);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        unregisterReceiver(receiver);

        //解绑监听器，防止泄漏
        if (flContentBody != null) {
            flContentBody.removeOnResizeListener(this);
        }

        //同步模块直播已结束
        String targetId = "";
        if (mIMRoomInItem != null) {
            targetId = mIMRoomInItem.userId;
        }

        //回收拉流播放器
        if (mLivePlayerManager != null) {
            mLivePlayerManager.uninit();
            mLivePlayerManager = null;
        }
        //add by Jagger 2017-12-1
        destroyPublisher();
        //销毁互动UI
        removeCallback(mHideOperateRunnable);

        if (tpManager != null) {
            tpManager.clear();
        }
        if (mModuleGiftManager != null) {
            mModuleGiftManager.destroy();
        }
        //退出房间成功，就清空送礼队列，并停止服务
        GiftSendReqManager.getInstance().shutDownReqQueueServNow();

        //推荐礼物
        if (null != mRoomGiftManager) {
            mRoomGiftManager.onDestroy();
        }

        //清理资费提示manager
        if (mIMRoomInItem.roomType != IMLiveRoomType.FreePublicRoom) {
            if (roomRebateTipsPopupWindow != null) {
                roomRebateTipsPopupWindow.release();
                if (roomRebateTipsPopupWindow.isShowing()) {
                    roomRebateTipsPopupWindow.dismiss();
                }
                roomRebateTipsPopupWindow = null;
            }
        }
        removeUiMessages(EVENT_TIMEOUT_BACKGROUND);
        removeUiMessages(EVENT_LEAVING_ROOM_TIMECOUNT);
        //才艺
        if (null != talentManager) {
            talentManager.destory();
            talentManager = null;
        }

        if (null != vedioLoadingAnimManager) {
            vedioLoadingAnimManager.hideLoadingAnim();
        }
        if (null != liveRoomChatManager) {
            liveRoomChatManager.destroy();
        }

        //礼物列表回收
        // 2019/9/3 Hardy
        if (liveVirtualGiftDialog != null) {
            liveVirtualGiftDialog.destroy();
            liveVirtualGiftDialog = null;
        }

        //
        if (talentManager != null) {
            talentManager.unregisterOnTalentEventListener(mTalentEventListener);
        }

        //Hang-out回收
        if (mHangoutInvitationManager != null) {
            mHangoutInvitationManager.release();
        }
        if (mHangoutInviteMap != null) {
            mHangoutInviteMap.clear();
        }

        //回收推荐礼物列表刷新动画
        hideRecommandRefreshAnimation();
    }

    /**
     * 关闭直播间
     *
     * @param needCommand
     */
    public void closeLiveRoom(boolean needCommand) {
        Log.d(TAG, "closeLiveRoom");
        if (null != mIMRoomInItem && !TextUtils.isEmpty(mIMRoomInItem.roomId) && null != mIMManager) {
            if (needCommand) {
                mIMManager.RoomOut(mIMRoomInItem.roomId);
            }
            //清理缓存直播间基本用户信息
            mIMManager.clearUserInfoList();
        }

        //退出直播间操作后，不再接收事件
        clearIMListener();

        //处理关闭拉流及推流，避免因为生命周期导致播放器停止延时
        if (mLivePlayerManager != null) {
            mLivePlayerManager.uninit();
            mLivePlayerManager = null;
        }
        //add by Jagger 2017-12-1
        destroyPublisher();

        finish();
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK && event.getAction() == KeyEvent.ACTION_DOWN) {
            //拦截返回键
//            closeRoomByUser = true;
//            closeLiveRoom();
            userCloseRoom();
            return false;
        }
        return super.onKeyDown(keyCode, event);
    }

    /**
     * 用户手动点击退出直播间
     */
    private void userCloseRoom() {
        if (null != mIMRoomInItem && mIMRoomInItem.roomType != IMLiveRoomType.FreePublicRoom) {
            AlertDialog.Builder builder = new AlertDialog.Builder(this)
                    .setMessage(getResources().getString(R.string.liveroom_close_room_notify))
                    .setCancelable(false)
                    .setPositiveButton(getResources().getString(R.string.live_common_btn_yes), new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialogInterface, int i) {
                            closeRoomByUser = true;
                            closeLiveRoom(true);
                        }
                    })
                    .setNegativeButton(getResources().getString(R.string.live_common_btn_no), new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {

                        }
                    });
            Dialog dialog = builder.create();
            dialog.setCanceledOnTouchOutside(false);
            if (isActivityVisible()) {
                dialog.show();
            }
        } else {
            closeRoomByUser = true;
            closeLiveRoom(true);
        }

    }

    //******************************** 顶部房间信息模块 ****************************************************************

    @Override
    public void onGetRoomTariffInfo(final SpannableString tariffPromptSpan, final boolean isNeedUserConfirm) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (isNeedUserConfirm || isUserWantSeeTariffPrompt) {
                    showRoomTariffPrompt(tariffPromptSpan, isNeedUserConfirm);
                    isUserWantSeeTariffPrompt = false;
                }
            }
        });
    }

    protected boolean isUserWantSeeTariffPrompt = false;
    protected View.OnClickListener tpOKClickListener = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            showRoomTariffPrompt(null, false);
            if (null != tpManager) {
                tpManager.update();
            }
            //GA统计，点击直播间说明
            onAnalyticsEvent(getResources().getString(R.string.Live_Broadcast_Category),
                    getResources().getString(R.string.Live_Broadcast_Action_BroadcastInfo),
                    getResources().getString(R.string.Live_Broadcast_Label_BroadcastInfo));
        }
    };
    protected View.OnClickListener roomFlagClickListener = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            if (null != view_tariff_prompt && view_tariff_prompt.getVisibility() == View.GONE) {
                isUserWantSeeTariffPrompt = true;
                if (null != tpManager) {
                    tpManager.getRoomTariffInfo(BaseCommonFullScreenLiveRoomActivity.this);
                }
                Message msg = Message.obtain();
                msg.what = EVENT_MESSAGE_HIDE_TARIFFPROMPT;
                sendUiMessageDelayed(msg, 3000l);
            }
        }
    };

    private void initRoomHeader() {
        //顶部菜单,留出系统状态栏高度
        view_roomHeader = findViewById(R.id.view_roomHeader);
        view_roomHeader.setOnClickListener(this);

        //4.3以上(不包括4.3)，留空状态栏距离
        if(Build.VERSION.SDK_INT > Build.VERSION_CODES.JELLY_BEAN_MR2) {
            RelativeLayout.LayoutParams headerLP = (RelativeLayout.LayoutParams) view_roomHeader.getLayoutParams();
            headerLP.topMargin = DisplayUtil.getStatusBarHeight(mContext);
        }

        lrhbv_flag = (LiveRoomHeaderBezierView) findViewById(R.id.lrhbv_flag);
        iv_roomFlag = (ImageView) findViewById(R.id.iv_roomFlag);
        FrameLayout.LayoutParams roomFlagLp = (FrameLayout.LayoutParams) iv_roomFlag.getLayoutParams();
        findViewById(R.id.ll_closeLiveRoom).setOnClickListener(this);
//        view_roomHeader.measure(0,0);
        if (null != mIMRoomInItem) {
            iv_roomFlag.setImageDrawable(roomThemeManager.getRoomFlagDrawable(this, mIMRoomInItem.roomType));
        }
        //资费提示
        view_tariff_prompt = findViewById(R.id.view_tariff_prompt);
        view_tariff_prompt.setVisibility(View.GONE);
        tpManager = new TariffPromptManager(this);
        tv_triffMsg = (TextView) findViewById(R.id.tv_triffMsg);

        //---公开直播间----
        ll_publicRoomHeader = (LinearLayout) findViewById(R.id.ll_publicRoomHeader);
        ll_publicRoomHeader.setVisibility(View.GONE);
        ll_hostInfoView = findViewById(R.id.ll_hostInfoView);
        civ_hostIcon = (CircleImageView) findViewById(R.id.civ_hostIcon);
        civ_hostIcon.setOnClickListener(this);
        tv_hostName = (TextView) findViewById(R.id.tv_hostName);
        tv_hostName.setOnClickListener(this);
        tv_hostId = (TextView) findViewById(R.id.tv_hostId);
        tv_roomFlag = findViewById(R.id.tv_roomFlag);

        //免费公开直播间
        cihsv_onlineFreePublic = (CircleImageHorizontScrollView) findViewById(R.id.cihsv_onlineFreePublic);
        tv_onlineNum = (TextView) findViewById(R.id.tv_onlineNum);
        ll_freePublic = findViewById(R.id.ll_freePublic);
        ll_freePublic.setVisibility(View.GONE);
        //付费公开直播间
        rl_vipPublic = (RelativeLayout) findViewById(R.id.rl_vipPublic);
        cihsv_onlineVIPPublic = (CircleImageHorizontScrollView) findViewById(R.id.cihsv_onlineVIPPublic);
        tv_vipGuestData = (TextView) findViewById(R.id.tv_vipGuestData);
        rl_vipPublic.setVisibility(View.GONE);
        //-----私密直播间-----
        ll_privateRoomHeader = findViewById(R.id.ll_privateRoomHeader);
        iv_prvUserIconBg = (ImageView) findViewById(R.id.iv_prvUserIconBg);
        civ_prvUserIcon = (CircleImageView) findViewById(R.id.civ_prvUserIcon);
        iv_intimacyPrv = (ImageView) findViewById(R.id.iv_intimacyPrv);
        iv_intimacyPrv.setOnClickListener(this);
        iv_prvHostIconBg = (ImageView) findViewById(R.id.iv_prvHostIconBg);
        iv_prvHostIconBg.setOnClickListener(this);
        civ_prvHostIcon = (CircleImageView) findViewById(R.id.civ_prvHostIcon);
        civ_prvHostIcon.setOnClickListener(this);
        iv_followPrvHost = (ImageView) findViewById(R.id.iv_followPrvHost);
        iv_followPrvHost.setOnClickListener(this);
        ll_privateRoomHeader.setVisibility(View.GONE);
        view_roomHeader_buttomLine = findViewById(R.id.view_roomHeader_buttomLine);

        iv_closeLiveRoom = (ImageView) findViewById(R.id.iv_closeLiveRoom);
    }

    private void initRoomViewDataAndStyle() {
        //房间类型标识
        tv_roomFlag.setBackgroundDrawable(roomThemeManager.getRoomFlagBgDrawable(this, mIMRoomInItem.roomType));
        tv_roomFlag.setText(roomThemeManager.getRoomFlagString(this, mIMRoomInItem.roomType));

        view_roomHeader_buttomLine.setBackgroundDrawable(roomThemeManager.getRoomHeadDeviderLineDrawable(mIMRoomInItem.roomType));
        flContentBody.setBackgroundDrawable(roomThemeManager.getRoomThemeDrawable(this, mIMRoomInItem.roomType));
        if (null != mIMRoomInItem && !TextUtils.isEmpty((mIMRoomInItem.photoUrl))) {
            //主播的头像是过渡页面带进来的，所以IMManager.getUserInfo拿到的同mIMRoomInItem的一样的
            PicassoLoadUtil.loadUrlNoMCache(civ_hostIcon, mIMRoomInItem.photoUrl, R.drawable.ic_default_photo_woman);
        }
        if (mIMRoomInItem.roomType == IMLiveRoomType.NormalPrivateRoom
                || mIMRoomInItem.roomType == IMLiveRoomType.AdvancedPrivateRoom) {
            if (null != mIMRoomInItem && !TextUtils.isEmpty((mIMRoomInItem.photoUrl))) {
                //主播的头像是过渡页面带进来的，所以IMManager.getUserInfo拿到的同mIMRoomInItem的一样的
                PicassoLoadUtil.loadUrlNoMCache(civ_prvHostIcon, mIMRoomInItem.photoUrl, R.drawable.ic_default_photo_woman);
            }

            if (null != mIMManager && null != loginItem) {
                //自己的通过3.12接口缓存的数据更新
                IMUserBaseInfoItem imUserBaseInfoItem = mIMManager.getUserInfo(loginItem.userId);
                if (null != imUserBaseInfoItem && !TextUtils.isEmpty(imUserBaseInfoItem.photoUrl)) {
                    PicassoLoadUtil.loadUrl(civ_prvUserIcon, imUserBaseInfoItem.photoUrl, R.drawable.ic_default_photo_man);
                }
            }
            Drawable prvFollowDrawable = roomThemeManager.getPrivateRoomFollowBtnDrawable(this, mIMRoomInItem.roomType);
            if (null != prvFollowDrawable) {
                iv_followPrvHost.setImageDrawable(prvFollowDrawable);
            }

            Drawable lovelLevelDrawable = roomThemeManager.getPrivateRoomLoveLevelDrawable(this, mIMRoomInItem.loveLevel);
            if (null != lovelLevelDrawable) {
                iv_intimacyPrv.setImageDrawable(lovelLevelDrawable);
            }
        }
        tv_hostName.setText(mIMRoomInItem.nickName);
        tv_hostId.setText(mIMRoomInItem.userId);

        //是否已经关注
        onRecvFollowHostResp(mIMRoomInItem.isFavorite, "");
        //根据直播间类型更换关闭直播间按钮图标
        iv_closeLiveRoom.setImageDrawable(roomThemeManager.getCloseRoomImgResId(this, mIMRoomInItem.roomType));
    }

    protected void showRoomTariffPrompt(SpannableString spannableString, boolean isShowOkBtn) {
        if (null != spannableString) {
            tv_triffMsg.setText(spannableString);
            //http://a.codekk.com/blogs/detail/54cfab086c4761e5001b253f
            tv_triffMsg.requestLayout();
            view_tariff_prompt.setVisibility(View.VISIBLE);
            btn_OK.setVisibility(isShowOkBtn ? View.VISIBLE : View.GONE);
        } else {
            view_tariff_prompt.setVisibility(View.GONE);
        }
    }

    protected void visitHostInfo() {
        showAnchorInfoDialog();
    }

    /**
     * 关注主播，用户端的实现类，
     * 需要在调用关注接口成功后，通过super.sendFollowHotRseq()实现界面的交互响应
     */
    public void sendFollowHostReq() {
        if (null != mIMRoomInItem) {
            Log.d(TAG, "sendFollowHostReq-hostId:" + mIMRoomInItem.userId);
            //接口调用
            LiveRequestOperator.getInstance().AddOrCancelFavorite(mIMRoomInItem.userId, mIMRoomInItem.roomId, true, new OnRequestCallback() {
                @Override
                public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                    Log.d(TAG, "sendFollowHostReq-AddOrCancelFavorite-isSuccess:" + isSuccess + " errCode:" + errCode + " errMsg:" + errMsg);
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
    protected void onRecvFollowHostResp(boolean isSuccess, String errMsg) {
        Log.d(TAG, "onRecvFollowHostResp-isSuccess:" + isSuccess + " errMsg:" + errMsg);
        if (!TextUtils.isEmpty(errMsg)) {
            showToast(errMsg);
        }
        iv_followPrvHost.setVisibility(isSuccess ? View.GONE : View.GONE);
    }

    @Override
    public void OnRoomIn(int reqId, final boolean success, final IMClientListener.LCC_ERR_TYPE errType,
                         String errMsg, final IMRoomInItem roomInfo, final IMAuthorityItem authorityItem) {
        super.OnRoomIn(reqId, success, errType, errMsg, roomInfo, authorityItem);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Log.i("Jagger", "BaseCommonLiveRoomActivity OnRoomIn book:" + (authorityItem == null ? "null" : authorityItem.isHasBookingAuth));
                Log.i("Jagger", "BaseCommonLiveRoomActivity OnRoomIn isHangout:" + (authorityItem == null ? "null" : roomInfo.isHangoutPriv));
                if (!success && errType != IMClientListener.LCC_ERR_TYPE.LCC_ERR_CONNECTFAIL) {
                    //关闭直播间逻辑
                    endLive(PAGE_ERROR_LIEV_EDN, getString(R.string.liveroom_transition_broadcast_ended), false, false, authorityItem);
                } else {
                    onDisconnectRoomIn();
                }
            }
        });
    }

    //******************************** 视频播放组件 ****************************************************************
    private void initVideoPlayer() {
        include_audience_area = findViewById(R.id.include_audience_area);
        iv_vedioBg = findViewById(R.id.iv_vedioBg);
        //中上对齐; 以长边比例裁剪;
        FrescoLoadUtil.setHierarchy(mContext, iv_vedioBg, R.color.live_ho_detail_dialog_bg, false);
        //视频播放组件
        sv_player = (GLSurfaceView) findViewById(R.id.sv_player);
        //add by Jagger 2017-11-29 解决小窗口能浮在大窗口上的问题

        rl_media = findViewById(R.id.rl_media);
        rl_media.setOnClickListener(this);

        int screenWidth = DisplayUtil.getScreenWidth(BaseCommonFullScreenLiveRoomActivity.this);
        int scaleHeight = screenWidth * 3 / 4;
        //具体的宽高比例，其实也可以根据服务器动态返回来控制
        LinearLayout.LayoutParams rlMediaLp = (LinearLayout.LayoutParams) rl_media.getLayoutParams();
        view_roomHeader.measure(0, 0);
        rlMediaLp.height = scaleHeight;
        rl_media.setLayoutParams(rlMediaLp);

        // 设置视频全屏高度
        int height = DisplayUtil.getScreenHeight(this);
        RelativeLayout.LayoutParams layoutParamsPlayer = (RelativeLayout.LayoutParams) sv_player.getLayoutParams();
        layoutParamsPlayer.height = height;
        // 设置视频封面全屏高度
        RelativeLayout.LayoutParams layoutParamsBg = (RelativeLayout.LayoutParams) iv_vedioBg.getLayoutParams();
        layoutParamsBg.height = height;
        //毛玻璃
        if(!TextUtils.isEmpty(roomPhotoUrl)){
            int bgSize = DisplayUtil.getScreenWidth(mContext);
            Uri uri = Uri.parse(roomPhotoUrl);    //主播封面
            ImageRequest requestBlur = ImageRequestBuilder.newBuilderWithSource(uri)
                    .setResizeOptions(new ResizeOptions(bgSize, bgSize)) //压缩、裁剪图片
                    .setPostprocessor(new IterativeBoxBlurPostProcessor(3, 30))    //迭代次数，越大越魔化。 //模糊图半径，必须大于0，越大越模糊。
                    .build();
            AbstractDraweeController controllerBlur = Fresco.newDraweeControllerBuilder()
                    .setOldController(iv_vedioBg.getController())
                    .setImageRequest(requestBlur)
                    .build();
            iv_vedioBg.setController(controllerBlur);
        }

        //初始化播放器
        mLivePlayerManager = new LivePlayerManager(this);
        mLivePlayerManager.init(LivePlayerManager.createPlayerRenderBinder(sv_player));
        mLivePlayerManager.setILSPlayerStatusListener(new LivePlayerManager.ILSPlayerStatusListener() {
            @Override
            public void onPullStreamConnect(LSPlayer var1) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        //接收流，隐藏封面
                        iv_vedioBg.setVisibility(View.GONE);
                    }
                });
            }

            @Override
            public void onPullStreamDisconnect(LSPlayer var1) {

            }
        });

        sdv_vedioLoading = (SimpleDraweeView) findViewById(R.id.sdv_vedioLoading);
        sdv_vedioLoading.setVisibility(View.GONE);
        vedioLoadingAnimManager = new VedioLoadingAnimManager(this, sdv_vedioLoading);
    }


    /**
     * 开始拉流
     *
     * @param videoUrls
     */
    private void startLivePlayer(String[] videoUrls) {
        if (mLivePlayerManager != null && mLivePlayerManager.isInited() && videoUrls.length > 0) {
            mLivePlayerManager.setOrChangeVideoUrls(videoUrls, "", "", "");

            if (videoUrls != null && videoUrls.length > 0) {
                //处理停止视频加载中
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (null != vedioLoadingAnimManager) {
                            vedioLoadingAnimManager.hideLoadingAnim();
                        }
                        if (null != mIMRoomInItem && mIMRoomInItem.roomType != IMLiveRoomType.FreePublicRoom) {
                            Drawable drawable = null;
                            if (null != roomThemeManager) {
                                drawable = roomThemeManager.getRoomCreditsBgDrawable(BaseCommonFullScreenLiveRoomActivity.this,
                                        mIMRoomInItem.roomType);
                            }
                            //通过photo控制免费公开直播间不显示返点信息
                            if (null != drawable) {
                                if (ll_rebate.getVisibility() != View.VISIBLE) {
                                    //第一次显示返点信息，返点倒计时才开始
                                    LiveRoomCreditRebateManager.getInstance().refreshRebateLastUpdate();
                                    //启动定时器
                                    onRebateUpdate();
                                }

                                ll_rebate.setBackgroundDrawable(drawable);
                                ll_rebate.setVisibility(View.INVISIBLE);
                            } else {
                                ll_rebate.setVisibility(View.INVISIBLE);
                            }
                        }
                    }
                });
            }
        }
    }

    //-----------------------信用点以及返点----------------------------------------

    @Override
    protected void onRebateUpdate() {
        super.onRebateUpdate();
        Message msg = Message.obtain();
        msg.what = EVENT_UPDATE_REBATE;
        sendUiMessage(msg);
    }

    @Override
    protected void onCreditUpdate() {
        super.onCreditUpdate();
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (null != pw_audienceBalanceInfo && pw_audienceBalanceInfo.isShowing()) {
                    pw_audienceBalanceInfo.updateBalanceViewData();
                }
            }
        });
    }

    //------------------------用户信用点信息对话框-----------------------------------------
    protected AudienceBalanceInfoPopupWindow pw_audienceBalanceInfo;

    public void showAudienceBalanceInfoDialog(View rootView) {
        if (null == pw_audienceBalanceInfo) {
            pw_audienceBalanceInfo = new AudienceBalanceInfoPopupWindow(this);
            pw_audienceBalanceInfo.setBackgroundDrawable(new ColorDrawable(Color.WHITE));
        }
        //AudienceBalanceInfoPopupWindow中会实时变动的数据为level和credits，credits使用直播间内部manager缓存,
        pw_audienceBalanceInfo.showAtLocation(rootView, Gravity.BOTTOM, ViewGroup.LayoutParams.FILL_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT);

    }

    //******************************** 礼物模块 ****************************************************************

    //=======================   2019/9/3 Hardy  ==============================
    protected void initLiveVirtualGiftDialog(){
        if (liveVirtualGiftDialog == null) {
            if (mIMRoomInItem != null && mRoomGiftManager != null) {
                liveVirtualGiftDialog = new LiveVirtualGiftDialog(this, mRoomGiftManager, mIMRoomInItem){
                    @Override
                    public void onDlgDismiss() {
                        super.onDlgDismiss();

                        // TODO: 2019/9/6 推荐礼物监听礼物弹窗消失后的重刷操作(若用户不重试，但点击展开了礼物列表，同样视为刷新推荐礼物)
                        Log.i("info","---------------onDlgDismiss-------------------------");
                        //如果推荐礼物刷新失败，重现刷新
                        loadRecommandGiftList();
                    }
                };

                liveVirtualGiftDialog.setLiveGiftDialogEventListener(new LiveVirtualGiftDialog.LiveGiftDialogEventListener() {
                    @Override
                    public void onShowToastTipsNotify(String message) {
                        //显示toast
                        if (!TextUtils.isEmpty(message)) {
                            showThreeSecondTips(message, Gravity.BOTTOM | Gravity.CENTER_HORIZONTAL);
                        }
                    }

                    @Override
                    public void onNoEnoughMoneyTips() {
                        //显示没钱提示
                        showCreditNoEnoughDialog(R.string.live_gift_send_failed_numnoenough);
                    }
                });
            }
        }
    }

    protected void showLiveVirtualGiftDialog() {
        initLiveVirtualGiftDialog();

        // 2018/12/28 Hardy
        if (isActivityVisible()) {
            liveVirtualGiftDialog.show();
        }
    }

    /**
     * 初始化模块
     */
    private void initMultiGift() {
        FrameLayout viewContent = (FrameLayout) findViewById(R.id.flMultiGift);
        /*礼物模块*/
        mModuleGiftManager = new ModuleGiftManager(this);
        mModuleGiftManager.initMultiGift(viewContent, 2);
        //大礼物
        advanceGift = (SimpleDraweeView) findViewById(R.id.advanceGift);
        mModuleGiftManager.initAdvanceGift(advanceGift);
    }

    /**
     * 启动消息动画
     *
     * @param msgItem
     */
    private void launchAnimationByMessage(IMMessageItem msgItem) {
        if (msgItem != null) {
            switch (msgItem.msgType) {
                case Gift: {
                    mModuleGiftManager.dispatchIMMessage(msgItem, mIMRoomInItem.roomType);
                }
                break;
                default:
                    break;
            }
        }
    }

    @Override
    public void OnSendGift(boolean success, final IMClientListener.LCC_ERR_TYPE errType, String errMsg,
                           IMMessageItem msgItem, double credit, double rebateCredit) {
        super.OnSendGift(success, errType, errMsg, msgItem, credit, rebateCredit);
        if (errType != IMClientListener.LCC_ERR_TYPE.LCC_ERR_SUCCESS) {
            //需要查询是否是大礼物发送失败，提示用户
            final Message msg = Message.obtain();
            if (errType == LCC_ERR_NO_CREDIT) {
                msg.what = EVENT_GIFT_SEND_FAILED_CREDITS_NOENOUGH;
                msg.obj = errMsg;
                sendUiMessage(msg);
            } else {
                if (null != msgItem && null != msgItem.giftMsgContent) {
                    GiftItem giftDetail = NormalGiftManager.getInstance().getLocalGiftDetail(msgItem.giftMsgContent.giftId);
                    if (null != giftDetail && giftDetail.giftType == GiftItem.GiftType.Advanced) {
                        msg.what = EVENT_GIFT_ADVANCE_SEND_FAILED;
                        msg.obj = giftDetail.name;
                        sendUiMessage(msg);
                    }
                }

            }

        }
    }

    @Override
    public void OnRecvBackpackUpdateNotice(IMPackageUpdateItem item) {
        super.OnRecvBackpackUpdateNotice(item);
    }

    @Override
    public void OnRecvRoomGiftNotice(IMMessageItem msgItem) {
        if (!isCurrentRoom(msgItem.roomId)) {
            return;
        }
        super.OnRecvRoomGiftNotice(msgItem);
        sendMessageUpdateEvent(msgItem);
    }

    //******************************** 入场座驾 start ****************************************************

    private void initLiveRoomCar() {
        ll_entranceCar = findViewById(R.id.ll_entranceCar);
        iv_car = ll_entranceCar.findViewById(R.id.iv_car);
        tv_joined = ll_entranceCar.findViewById(R.id.tv_joined);
    }

    /**
     * 播放入场座驾动画
     */
    private void doPlayEntranceCarAnim(){
        int startX, startY, endX, endY, paddingPx;
        paddingPx = 40;
        startX = 0;
        startY = 0;
        ll_entranceCar.measure(0, 0);
        endX = (DisplayUtil.getScreenWidth(mContext) - ll_entranceCar.getMeasuredWidth() - paddingPx ) * -1;    //屏幕边界 - View宽
        endY = rl_media.getHeight() - ll_entranceCar.getMeasuredHeight() - paddingPx ;  //父布局底边界 - View高

        Log.i("Jagger" , "doPlayEntranceCarAnim startX:"+startX+",startY:"+startY+",endX:"+endX+",endY:"+endY);

        Animation translateAnimation = new TranslateAnimation(startX, endX, startY, endY);//设置平移的起点和终点¡
        translateAnimation.setDuration(CAR_ANIM_TRANSLATE_TIME);//动画持续的时间为
        //如果不添加setFillEnabled和setFillAfter则动画执行结束后会自动回到远点
        translateAnimation.setFillEnabled(true);//使其可以填充效果从而不回到原地
        translateAnimation.setFillAfter(true);//不回到起始位置
//        translateAnimation.setFillBefore(false);//不回到起始位置
        translateAnimation.setAnimationListener(new Animation.AnimationListener(){

            @Override
            public void onAnimationStart(Animation animation) {

            }

            @Override
            public void onAnimationEnd(Animation animation) {
                //4.4W以下（不包括4.4W），那两台破3星手机和红米，动画会先移回起点再播放第二个动画，所以不让它播放了，直播结束
                if(Build.VERSION.SDK_INT <= Build.VERSION_CODES.KITKAT) {
                    doAnimationEnd();
                }else{
                    playCarOutAnim();
                }
            }

            @Override
            public void onAnimationRepeat(Animation animation) {

            }
        });
        ll_entranceCar.setAnimation(translateAnimation);//给iew添加的动画效果
        translateAnimation.startNow();//动画开始执行 放在最后即可
    }

    /**
     * 淡出动画
     */
    private void playCarOutAnim(){
        // 创建透明度动画，第一个参数是开始的透明度，第二个参数是要转换到的透明度
        AlphaAnimation alphaAni = new AlphaAnimation(1f, 0f);

        //设置动画执行的时间，单位是毫秒
        alphaAni.setDuration(CAR_ANIM_ALPHA_TIME);

        // 设置动画结束后停止在哪个状态（true表示动画完成后的状态）
        alphaAni.setFillAfter(true);
//        alphaAni.setFillBefore(false);//不回到起始位置,true动画结束后回到开始状态

        // 设置动画重复次数
        // -1或者Animation.INFINITE表示无限重复，正数表示重复次数，0表示不重复只播放一次
        alphaAni.setRepeatCount(0);

        // 设置动画模式（Animation.REVERSE 设置循环反转播放动画,Animation.RESTART 每次都从头开始）
        alphaAni.setRepeatMode(Animation.RESTART);

        alphaAni.setAnimationListener(new Animation.AnimationListener() {
            @Override
            public void onAnimationStart(Animation animation) {

            }

            @Override
            public void onAnimationEnd(Animation animation) {
                Log.i("Jagger" , "onAnimationEnd");
                doAnimationEnd();
            }

            @Override
            public void onAnimationRepeat(Animation animation) {

            }
        });

        // 启动动画
        ll_entranceCar.startAnimation(alphaAni);
    }

    /**
     * 动画结束
     */
    private void doAnimationEnd(){
        ll_entranceCar.removeAllViews();
        ll_entranceCar.setVisibility(View.GONE);
    }

    private void initRebateView() {
        //ll_rebate从原本的im浮层布局移到
        ll_rebate = findViewById(R.id.ll_rebate);
        view_roomHeader.measure(0, 0);
        tv_rebateTips = (TextView) findViewById(R.id.tv_rebateTips);
        tv_rebateTips.setText(getResources().getString(R.string.tip_roomGiftCredit, " "));
        tv_rebateValue = (TextView) findViewById(R.id.tv_rebateValue);

        ll_rebate.setOnClickListener(this);
        if ((null != mIMRoomInItem && mIMRoomInItem.roomType != IMLiveRoomType.FreePublicRoom)) {
            //
            tv_rebateTips.setTextColor(roomThemeManager.getRoomHeaderRebateTipsTxtColor(mIMRoomInItem.roomType));
            //
            roomRebateTipsPopupWindow = new RoomRebateTipsPopupWindow(this);
            roomRebateTipsPopupWindow.setListener(this);
        }

        //房间倒计时
        ll_enterPriRoomTimeCount = findViewById(R.id.ll_enterPriRoomTimeCount);
        ll_enterPriRoomTimeCount.setVisibility(View.GONE);
        tv_enterPrvRoomTimerCount = findViewById(R.id.tv_enterPrvRoomTimerCount);
    }

    @Override
    public void OnRecvEnterRoomNotice(String roomId, String userId, String nickName,
                                      String photoUrl, String riderId, String riderName,
                                      String riderUrl, int fansNum, String honorImg, boolean isHasTicket) {
        if (!isCurrentRoom(roomId)) {
            return;
        }
        super.OnRecvEnterRoomNotice(roomId, userId, nickName, photoUrl, riderId, riderName, riderUrl, fansNum, honorImg, isHasTicket);

        Log.d(TAG, "OnRecvEnterRoomNotice-userId:" + userId);

        if (!TextUtils.isEmpty(userId) && null != loginItem && userId.equals(loginItem.userId)) {
            //断线重登陆，接收到自己的进入房间通知，过滤处理
            Log.d(TAG, "OnRecvEnterRoomNotice-断线重登陆，接收到自己的进入房间通知，过滤处理");

            /*
                2019/9/24 Hardy
                解决在主播同意进入直播间邀请后，在过渡页断网，但已进入到直播间，此时用户信息 map 里没有会员的信息，
                导致其他地方在使用 getUserInfo 时为空，如私密直播间发礼物时，会员的 ticket 标签没去掉的问题.
             */
            if (mIMManager != null && mIMManager.getUserInfo(userId) == null) {
                mIMManager.updateOrAddUserBaseInfo(new IMUserBaseInfoItem(userId, nickName, photoUrl, isHasTicket));
            }

            return;
        }
        if (null != mIMManager) {
            mIMManager.updateOrAddUserBaseInfo(new IMUserBaseInfoItem(userId, nickName, photoUrl, isHasTicket));
        }
        addEnterRoomMsgToList(roomId, userId, nickName, riderId, riderName, riderUrl, honorImg);
    }

    @Override
    public void onGetAudienceDetailInfo(boolean isSuccess, int errCode, String errMsg,
                                        final AudienceBaseInfoItem audienceInfo) {
        super.onGetAudienceDetailInfo(isSuccess, errCode, errMsg, audienceInfo);
        Log.d(TAG, "onGetAudienceDetailInfo-audienceInfo.userId:" + audienceInfo.userId);
        if (isSuccess && null != audienceInfo) {
            //数据缓存到内存中，不用过滤是否是自己的
            if (null != mIMManager) {
                mIMManager.updateOrAddUserBaseInfo(audienceInfo.userId, audienceInfo.nickName, audienceInfo.photoUrl);
            }

            if (null != loginItem && audienceInfo.userId.equals(loginItem.userId)) {
                //自己的入场座驾动画
                addEnterRoomMsgToList(mIMRoomInItem.roomId, audienceInfo.userId, audienceInfo.nickName,
                        audienceInfo.riderId, audienceInfo.riderName, audienceInfo.riderUrl, mIMRoomInItem.honorImg);

                //私密直播间自己的头像使用该接口的数据获取并更新显示
                if (null != mIMRoomInItem && (mIMRoomInItem.roomType == IMLiveRoomType.NormalPrivateRoom
                        || mIMRoomInItem.roomType == IMLiveRoomType.AdvancedPrivateRoom)) {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            if (null != mIMManager && null != loginItem) {
                                //自己的通过3.12接口缓存的数据更新
                                PicassoLoadUtil.loadUrl(civ_prvUserIcon, audienceInfo.photoUrl, R.drawable.ic_default_photo_man);
                            }
                        }
                    });
                }
            }
        }
    }

    /**
     * 添加入场消息到消息列表
     *
     * @param roomId
     * @param userId
     * @param nickName
     * @param riderId
     * @param riderName
     * @param riderUrl
     * @param honorImg
     */
    private void addEnterRoomMsgToList(final String roomId, final String userId, final String nickName,
                                       final String riderId, final String riderName, final String riderUrl,
                                       final String honorImg) {
        Log.d(TAG, "addEnterRoomMsgToList-roomId:" + roomId + " userId:" + userId + " nickName:" + nickName
                + " riderId:" + riderId + " riderName:" + riderName + " riderUrl:" + riderUrl + " honorImg:" + honorImg);
        if (!TextUtils.isEmpty(riderId)) {
            Message msg = null;
            CarInfo carInfo = new CarInfo(nickName, userId, riderId, riderName, riderUrl);
            msg = Message.obtain();
            msg.what = EVENT_MESSAGE_ENTERROOMNOTICE;
            Bundle bundle = msg.getData();
            bundle.putBoolean("playCarInAnimAfterDownImg", false);
            msg.setData(bundle);
            msg.obj = carInfo;
            sendUiMessage(msg);
        } else {
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    Message msg = null;
                    IMMessageItem msgItem = new IMMessageItem(roomId,
                            mIMManager.mMsgIdIndex.getAndIncrement(),
                            userId,
                            nickName,
                            honorImg,
                            mIMRoomInItem.manLevel,
                            IMMessageItem.MessageType.RoomIn,
                            new IMTextMessageContent(BaseCommonFullScreenLiveRoomActivity.this.getResources().getString(R.string.enterlive_norider)), null);
                    msg = Message.obtain();
                    msg.what = EVENT_MESSAGE_UPDATE;
                    msg.obj = msgItem;
                    sendUiMessage(msg);
                }
            });

        }
    }

    //******************************** 入场座驾 end ****************************************************

    //******************************** 消息编辑区域处理 start ********************************************
    private TextWatcher tw_msgEt;
    private static int liveMsgMaxLength = 10;
    private int lastTxtChangedStart = 0;
    private int lastTxtChangedNumb = 0;
    private String lastInputEmoSign = null;

    /**
     * 处理编辑框区域view初始化
     */
    @SuppressLint("ClickableViewAccessibility")
    @SuppressWarnings("WrongConstant")
    private void initEditAreaView() {
        //4.4以下(不包括4.4)，修改键盘模式（为适配最破的那两台三星 SM-N7508V）
        if(Build.VERSION.SDK_INT <= Build.VERSION_CODES.JELLY_BEAN_MR2) {
            getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_PAN | WindowManager.LayoutParams.SOFT_INPUT_STATE_HIDDEN);
        }
        //
        liveMsgMaxLength = getResources().getInteger(R.integer.liveMsgMaxLength);
        //共用的软键盘弹起输入部分
        rl_inputMsg = findViewById(R.id.rl_inputMsg);
        v_roomEditMegBg = findViewById(R.id.v_roomEditMegBg);
        ll_input_edit_body = (LinearLayout) findViewById(R.id.ll_input_edit_body);
        et_liveMsg = (EditText) findViewById(R.id.et_liveMsg);
        fl_inputArea = findViewById(R.id.fl_inputArea);

        et_liveMsg.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View view, MotionEvent motionEvent) {
                //使用自己的方法弹出键盘
                if (motionEvent.getAction() == MotionEvent.ACTION_DOWN) {
                    showKeyBoard();
                }

//                showKeyBoard();
                return false;
            }
        });
        et_liveMsg.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                switch(actionId){
                    case EditorInfo.IME_ACTION_SEND:
                        // 触发操作栏发送按钮
                        iv_sendMsg.performClick();
                        break;
                    default:
                        return false;
                }
                return false;
            }
        });
        iv_sendMsg = findViewById(R.id.iv_sendMsg);
        if (null == tw_msgEt) {
            tw_msgEt = new TextWatcher() {
                @Override
                public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                    Log.logD(TAG, "beforeTextChanged-s:" + s.toString() + " start:" + start + " count:" + count + " after:" + after);
                }

                @Override
                public void onTextChanged(CharSequence s, int start, int before, int count) {
                    Log.logD(TAG, "onTextChanged-s:" + s.toString() + " start:" + start + " before:" + before + " count:" + count);
                    lastTxtChangedStart = start;
                    lastTxtChangedNumb = count;
                }

                @Override
                public void afterTextChanged(Editable s) {
                    Log.logD(TAG, "afterTextChanged-s:" + s.toString());
                    if (null == et_liveMsg) {
                        return;
                    }
                    if (s.toString().length() > liveMsgMaxLength) {
                        int selectedEndIndex = et_liveMsg.getSelectionEnd();
                        int outStart = 0;
                        //s.delete会瞬间触发TextChangedListener流程，导致lastTxtChangedNumb=0时多走一遍流程
                        et_liveMsg.removeTextChangedListener(tw_msgEt);

                        // 2019/9/5 Hardy
                        if (emoJiTabIconLayout.getVisibility() == View.VISIBLE && !TextUtils.isEmpty(lastInputEmoSign)) {
//                        if (etsl_emojiContainer.getVisibility() == View.VISIBLE && !TextUtils.isEmpty(lastInputEmoSign)) {
                            outStart = lastTxtChangedStart;
                            s.delete(outStart, outStart + lastTxtChangedNumb);
                            Log.logD(TAG, "afterTextChanged-outNumb:" + lastTxtChangedNumb
                                    + " outStart:" + outStart + " s:" + s.toString());
                            lastInputEmoSign = null;
                        } else {
                            int outNumb = s.toString().length() - liveMsgMaxLength;
                            outStart = lastTxtChangedStart + lastTxtChangedNumb - outNumb;
                            s.delete(outStart, lastTxtChangedStart + lastTxtChangedNumb);
                            Log.logD(TAG, "afterTextChanged-outNumb:" + outNumb + " outStart:" + outStart + " s:" + s);
                        }

                        // old
//                        et_liveMsg.setText(s.toString());

                        /*
                            2019/9/5 Hardy
                            解决 内容在已有表情显示情况下，再删除超过最大字数，取回文本时，防止内容又变回表情符号的问题.
                         */
                        et_liveMsg.setText(ChatEmojiManager.getInstance().formatEmojiString2Image(mContext,
                                        s.toString(),
                                        mEmojiTextWH,
                                        mEmojiTextWH));

                        et_liveMsg.setSelection(outStart);
                        et_liveMsg.addTextChangedListener(tw_msgEt);
                    }
                }
            };
        }
        et_liveMsg.addTextChangedListener(tw_msgEt);

        //Emoji
        mEmojiTextWH = getResources().getDimensionPixelSize(R.dimen.live_size_16dp);
        emoJiTabIconLayout = findViewById(R.id.layout_emoji_tab_icon_rootView);
        //默认不可视
        emoJiTabIconLayout.setVisibility(View.GONE);
        // data
        if (mIMRoomInItem != null) {
            // 可发送表情列表，用于显示禁止高级表情是否可发送的 UI 状态
            emoJiTabIconLayout.setEmoTypeList(mIMRoomInItem.emoTypeList);
        }
        emoJiTabIconLayout.setTabTitles(ChatEmojiManager.getInstance().getEmotionTagNames());
        emoJiTabIconLayout.setItemMap(ChatEmojiManager.getInstance().getTagEmotionMap());
        // listener
        emoJiTabIconLayout.setOnEmojiTabIconOperateListener(new EmoJiTabIconLayout.OnEmojiTabIconOperateListener() {
            @Override
            public void onSend() {
                // 触发操作栏发送按钮
                iv_sendMsg.performClick();
            }

            @Override
            public void onTabClick(int tabPos) {

            }

            @Override
            public void onEmojiClick(int tabPos, int emojiPos, String tabTitle,EmotionItem emotionItem) {
//                ToastUtil.showToast(mContext, "tabPos: " + tabPos + "----> emojiPos: " + emojiPos);
                // 亲密度等级不够时的判断提示，取服务器返回的错误信息进行提示
                if (!emotionItem.isEmoJiAdvancedCanClick) {
                    Map<String, EmotionCategory> map = ChatEmojiManager.getInstance().getTagEmotionMap();
                    if (map != null && map.get(tabTitle) != null) {
                        EmotionCategory emotionCategory = map.get(tabTitle);
                        if (emotionCategory != null) {
                            String errorMsg = emotionCategory.emotionErrorMsg;
                            //显示toast
                            showThreeSecondTips(errorMsg, Gravity.BOTTOM | Gravity.CENTER_HORIZONTAL);
                            return;
                        }
                    }
                }

                chooseEmotionItem = emotionItem;

                // 插入表情特定符号(old)
//                et_liveMsg.append(chooseEmotionItem.emoSign);

                // 2019/9/5 Hardy 将符号转换成表情插入到输入栏
                if(!TextUtils.isEmpty(emotionItem.emoSign)){
                    et_liveMsg.getEditableText().insert(et_liveMsg.getSelectionStart(),
                            ChatEmojiManager.getInstance().parseEmoji2SpannableString(mContext,
//                                TextUtils.htmlEncode(emotionItem.emoSign),
                                    emotionItem.emoSign,
                                    mEmojiTextWH,
                                    mEmojiTextWH));

                    lastInputEmoSign = chooseEmotionItem.emoSign;
                }
            }
        });
        // 加载 emoji 表情数据，显示 view 上
        emoJiTabIconLayout.updateView();

        iv_emojiSwitch = (ImageView) findViewById(R.id.iv_emojiSwitch);
        iv_gift = (ImageView) findViewById(R.id.iv_gift);

        // 默认输入框为降低状态
        onEditDown();
    }

    private void initEditAreaViewStyle() {
        if (null != mIMRoomInItem && mIMRoomInItem.roomType == IMLiveRoomType.FreePublicRoom) {
            iv_emojiSwitch.setVisibility(View.GONE);
        }
    }

    /**
     * 发送文本或弹幕消息
     *
     * @param isBarrage
     */
    public boolean sendTextMessage(boolean isBarrage) {
        boolean result = false;
        sendTextMessagePreProcess(isBarrage);
        String message = et_liveMsg.getText().toString();
        IMMessageItem msgItem = null;
        //过滤只发空格消息的情况
        if (!TextUtils.isEmpty(message) && !TextUtils.isEmpty(message.trim())) {
            if (null != mIMRoomInItem && !TextUtils.isEmpty(mIMRoomInItem.roomId)) {
                if (isBarrage) {
                    if (LiveRoomCreditRebateManager.getInstance().getCredit() < mIMRoomInItem.popPrice) {
                        showCreditNoEnoughDialog(R.string.live_common_noenough_money_tips);
                        return false;
                    }
                    msgItem = mIMManager.sendBarrage(mIMRoomInItem.roomId, message);
                } else {
                    msgItem = mIMManager.sendRoomMsg(mIMRoomInItem.roomId, message, new String[]{});
                }
            }

        }
        result = msgItem != null;
        Log.d(TAG, "sendTextMessage-result:" + result);
        return result;
    }

    /**
     * 发送文本或弹幕前消息预处理逻辑
     *
     * @param isBarrage
     */
    public void sendTextMessagePreProcess(boolean isBarrage) {
    }

    @Override
    public void OnRecvRoomMsg(IMMessageItem msgItem) {
        if (!isCurrentRoom(msgItem.roomId)) {
            return;
        }
        Log.d(TAG, "OnRecvRoomMsg-msgItem:" + msgItem);
        sendMessageUpdateEvent(msgItem);
    }

    /**
     * 输入栏升起时
     */
    private void onEditUp(){
//        Log.i("Jagger", "onEditDown+++");
        v_roomEditMegBg.setBackgroundResource(R.color.white);
        //Ps:输入法背景，会影响整个输入栏高度
        ll_input_edit_body.setBackgroundResource(R.drawable.full_screen_edittext_bg_transparent);
        iv_emojiSwitch.setVisibility(View.VISIBLE);
        iv_sendMsg.setVisibility(View.GONE);
    }

    /**
     * 输入栏降低时
     */
    private void onEditDown(){
//        Log.i("Jagger", "onEditDown---");
        v_roomEditMegBg.setBackgroundResource(R.color.transparent_full);
        ll_input_edit_body.setBackgroundResource(R.drawable.full_screen_edittext_bg_white);
        iv_emojiSwitch.setVisibility(View.GONE);
        iv_sendMsg.setVisibility(View.VISIBLE);
    }

    //******************************** 消息编辑区域处理 end ********************************************

    //******************************** 软键盘打开关闭的监听 start ****************************************************************
    /**
     * 显示输入法
     */
    private void showKeyBoard() {
        if (mInputAreaStatus == InputAreaStatus.KEYBOARD) return;
//        Log.i("Jagger", "showKeyBoard");

        //与其它控件显示关系的约束，最好不要乱改
        // ***start***
        showInputArea();
        showSoftInput(et_liveMsg);
        if (mInputAreaStatus == InputAreaStatus.EMOJI) {
            hideEmojiBoard();
        }
        mInputAreaStatus = InputAreaStatus.KEYBOARD;
        // ***end***
    }

    /**
     * 显示表情
     */
    private void showEmojiBoard(){
        if (mInputAreaStatus == InputAreaStatus.EMOJI) return;

//        etsl_emojiContainer.measure(0, 0);

        /*
            2019/9/6 Hardy
            由于在布局里已做表情区域高度的撑满容器的兼容，故这里不用每次 show 时都测量高度的操作.
         */
//        emoJiTabIconLayout.measure(0, 0);

        //隐藏软键盘，但仍保持et_liveMsg获取焦点
        hideSoftInput(et_liveMsg, true);
//        etsl_emojiContainer.setVisibility(View.VISIBLE);
        emoJiTabIconLayout.setVisibility(View.VISIBLE);
        iv_emojiSwitch.setImageDrawable(getResources().getDrawable(R.drawable.ic_full_screen_live_room_keyboard));

        mInputChangeBtnStatus = InputChangeBtnStatus.KEYBOARD;
        mInputAreaStatus = InputAreaStatus.EMOJI;
    }

    /**
     * 隐藏表情
     */
    private void hideEmojiBoard(){
//        etsl_emojiContainer.setVisibility(View.GONE);
        emoJiTabIconLayout.setVisibility(View.GONE);

        iv_emojiSwitch.setImageDrawable(getResources().getDrawable(R.drawable.ic_full_screen_live_room_emoji));
        mInputChangeBtnStatus = InputChangeBtnStatus.EMOJI;
    }

    /**
     * 隐藏输入区
     */
    private void hideInputArea(){
        if(mInputAreaStatus == InputAreaStatus.HIDE) return;

        mInputAreaStatus = InputAreaStatus.HIDE;
//        Log.i("Jagger", "hideInputArea---");

        hideEmojiBoard();
        hideSoftInput(et_liveMsg, true);

        //输入区大小
        ViewGroup.LayoutParams layoutParams = fl_inputArea.getLayoutParams();
        if (layoutParams.height > 0) {
            layoutParams.height = 0;
            fl_inputArea.setLayoutParams(layoutParams);
        }

        //消息区大小
        setMsgAreaMaxHeight();

        //推荐礼物区可视
        showRecommandArea();

        onEditDown();

        //左下角操作菜单可视
        ll_msg_menu.setVisibility(View.VISIBLE);
    }

    /**
     * 消息区设为最高高度
     */
    private void setMsgAreaMaxHeight(){
        //消息区大小
        ViewGroup.LayoutParams layoutParamsMsg = fl_imMsgContainer.getLayoutParams();
        layoutParamsMsg.height = (int)(DisplayUtil.getScreenHeight(mContext) * MSG_LIST_MAX_HEIGTH_FOR_SCREEN);
        fl_imMsgContainer.setLayoutParams(layoutParamsMsg);
    }

    /**
     * 消息区设为最小高度
     */
    private void setMsgAreaMinHeight(){
        //消息区大小
        ViewGroup.LayoutParams layoutParamsMsg = fl_imMsgContainer.getLayoutParams();
        layoutParamsMsg.height = getResources().getDimensionPixelSize(R.dimen.live_room_msg_area_max_height);
        fl_imMsgContainer.setLayoutParams(layoutParamsMsg);
    }

    /**
     * 显示输入区
     */
    private void showInputArea(){
        int inputAreaHeight = 0;
        if (mInputAreaStatus == InputAreaStatus.KEYBOARD) {
            //输入区, 使用键盘高度真实
            inputAreaHeight = mKeyBoardHeight;
        } else {
//            //因为黑霉手机有物理键盘,当虚拟键盘很小时,mKeyBoardHeight只有100+PX,表情区会显示不全,使用最小高度.
            inputAreaHeight = mKeyBoardHeight < getResources().getDimensionPixelSize(R.dimen.min_keyboard_height) ? getResources().getDimensionPixelSize(R.dimen.min_keyboard_height) : mKeyBoardHeight;
        }

        //输入区大小
        ViewGroup.LayoutParams layoutParams = fl_inputArea.getLayoutParams();
        if (layoutParams.height < 1) {
            layoutParams.height = inputAreaHeight;
            fl_inputArea.setLayoutParams(layoutParams);
        }

        //消息区大小
        setMsgAreaMinHeight();

        //缩小时先滚到最底
        if(liveRoomChatManager.getToggleStatus() == FullScreenLiveRoomChatManager.MsgListToggleStatus.OPEN){
            liveRoomChatManager.scrollToBottom();
        }

        //推荐礼物区可视
        hideRecommandArea();

        //左下角操作菜单隐藏
        ll_msg_menu.setVisibility(View.INVISIBLE);
    }

    @Override
    public void OnSoftPop(int height) {
//        Log.d("Jagger", "OnSoftPop");

        if (mKeyBoardHeight != height) {
            mKeyBoardHeight = height;
            KeyBoardManager.saveKeyboardHeight(mContext, height);
        }

        lrsv_roomBody.setScrollFuncEnable(false);
        onEditUp();
    }

    @Override
    public void OnSoftClose() {
//        Log.d("Jagger", "OnSoftClose");
        //add by Jagger
        doReMovePublishView();

        lrsv_roomBody.setScrollFuncEnable(true);

        //点击输入法收起按钮
        if(mInputAreaStatus == InputAreaStatus.KEYBOARD){
            hideInputArea();
        }
    }
    //******************************** 软键盘打开关闭的监听 end ****************************************************************

    //******************************** 消息展示列表 start *******************************************************
    /**
     * 初始化消息展示列表
     */
    private void initMessageList() {
        View fl_msglist = findViewById(R.id.fl_msglist);
        if (null != roomThemeManager && null != mIMRoomInItem) {
            liveRoomChatManager = new FullScreenLiveRoomChatManager(this, mIMRoomInItem.roomType,
                    mIMRoomInItem.userId, loginItem.userId, roomThemeManager);
        }else{
            liveRoomChatManager = new FullScreenLiveRoomChatManager(this, IMLiveRoomType.AdvancedPrivateRoom,
                    "", loginItem.userId, new RoomThemeManager());
        }

        liveRoomChatManager.init(this, fl_msglist);
        liveRoomChatManager.setLiveMessageListItemClickListener(this);

        //消息区大小
        fl_imMsgContainer = findViewById(R.id.fl_imMsgContainer);
        fl_imMsgContainer.setOnClickListener(this);
        setMsgAreaMaxHeight();
    }

    @Override
    public void OnRecvSendSystemNotice(IMMessageItem msgItem) {
        if (!isCurrentRoom(msgItem.roomId)) {
            return;
        }
        super.OnRecvSendSystemNotice(msgItem);
        sendMessageUpdateEvent(msgItem);
    }

    protected WarningDialog warningDialog;

    protected void showWarningDialog(String warnContent) {
        Log.d(TAG, "showWarningDialog-warnContent:" + warnContent);
        if (null == warningDialog) {
            warningDialog = new WarningDialog(this);
        }
        warningDialog.show(warnContent);
    }

    //******************************** 消息展示列表 end *******************************************************


    /********************************* IMManager事件监听回调  *******************************************/

    @Override
    public void OnRoomOut(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
        super.OnRoomOut(reqId, success, errType, errMsg);
    }

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
        removeUiMessages(EVENT_TIMEOUT_BACKGROUND);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Log.i("Jagger", "BaseCommonLiveRoomActivity OnRecvRoomKickoffNotice book:" + (privItem == null ? "null" : privItem.isHasBookingAuth));
                LiveRoomNormalErrorActivity.PageErrorType pageErrorType = LiveRoomNormalErrorActivity.PageErrorType.PAGE_ERROR_LIEV_EDN;
                if (err == LCC_ERR_NO_CREDIT) {
                    pageErrorType = PAGE_ERROR_NOMONEY;
                }
                if (isActivityVisible()) {
                    endLive(pageErrorType, errMsg, false, true, privItem);
                } else {
                    mIsNeedRecommand = false;
                    mIsNeedCommand = true;
                    mIsRoomBackgroundClose = true;
                    mCloseErrMsg = errMsg;
                    mClosePageErrorType = pageErrorType;
                }
            }
        });
    }

    @Override
    public void OnRecvLackOfCreditNotice(String roomId, final String message, double credit, IMClientListener.LCC_ERR_TYPE err) {
        if (!isCurrentRoom(roomId)) {
            return;
        }
        super.OnRecvLackOfCreditNotice(roomId, message, credit, err);
        Log.d(TAG, "OnRecvLackOfCreditNotice-hasShowCreditsLackTips:" + hasShowCreditsLackTips);

        if(err == LCC_ERR_NO_CREDIT_DOUBLE_VIDEO_NOTICE){
            //双向视频 信用点不足停止推流
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    doReqStopVideoInteraction();
                }
            });
        }

        // 信用点不足弹窗
        if (!hasShowCreditsLackTips) {
            hasShowCreditsLackTips = true;
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    String errTips = message;
                    if(TextUtils.isEmpty(errTips)){
                        errTips = getResources().getString(R.string.liveroom_noenough_money_tips_watching);
                    }
                    showCreditNoEnoughDialog(errTips);
                }
            });
        }


    }

    @Override
    public void OnRecvLevelUpNotice(int level) {
        super.OnRecvLevelUpNotice(level);
        //添加消息列表
        IMMessageItem imMessageItem = new IMMessageItem(mIMRoomInItem.roomId,
                mIMManager.mMsgIdIndex.getAndIncrement(),
                "",
                IMMessageItem.MessageType.SysNotice,
                new IMSysNoticeMessageContent(getResources().getString(R.string.system_notice_level_upgraded, String.valueOf(level)),
                        null, IMSysNoticeMessageContent.SysNoticeType.Normal));
        Log.d(TAG, "OnRecvLevelUpNotice-msg:" + imMessageItem.sysNoticeContent.message + " link:" + imMessageItem.sysNoticeContent.link);
        //IMManager.OnRecvLevelUpNotice中有更新level到LoginItem
        sendMessageUpdateEvent(imMessageItem);
        //通知用户等级升级
        sendEmptyUiMessage(EVENT_MAN_LEVEL_UPDATE);
    }

    @Override
    public void OnRecvLoveLevelUpNotice(IMLoveLeveItem lovelevelItem) {
        super.OnRecvLoveLevelUpNotice(lovelevelItem);
        //添加消息列表
        if (lovelevelItem != null) {
            IMMessageItem imMessageItem = new IMMessageItem(mIMRoomInItem.roomId,
                    mIMManager.mMsgIdIndex.getAndIncrement(),
                    "",
                    IMMessageItem.MessageType.SysNotice,
                    new IMSysNoticeMessageContent(getResources().getString(R.string.system_notice_intimacylevel_upgraded,
                            mIMRoomInItem.nickName, String.valueOf(lovelevelItem.loveLevel)),
                            null, IMSysNoticeMessageContent.SysNoticeType.Normal));
            Log.d(TAG, "OnRecvLoveLevelUpNotice-msg:" + imMessageItem.sysNoticeContent.message + " link:" + imMessageItem.sysNoticeContent.link);
            sendMessageUpdateEvent(imMessageItem);
            sendEmptyUiMessage(EVENT_INTIMACY_LEVEL_UPDATE);
        }
    }

    //------------------------直播间关闭-------------------------------------------------------

    @Override
    public void OnRecvLeavingPublicRoomNotice(String roomId, final int leftSeconds, IMClientListener.LCC_ERR_TYPE err, String errMsg, IMAuthorityItem privItem) {
        if (!isCurrentRoom(roomId)) {
            return;
        }
        super.OnRecvLeavingPublicRoomNotice(roomId, leftSeconds, err, errMsg, privItem);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
//                hideStartButtons();
                //修改倒计时秒数和服务器返回一致
                leavingRoomTimeCount = leftSeconds;
                ll_enterPriRoomTimeCount.setVisibility(View.VISIBLE);
                sendEmptyUiMessageDelayed(EVENT_LEAVING_ROOM_TIMECOUNT, 0l);
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
        if (!isCurrentRoom(roomId)) {
            return;
        }
        super.OnRecvRoomCloseNotice(roomId, errType, errMsg, privItem);
        removeUiMessages(EVENT_TIMEOUT_BACKGROUND);

        if (null != mIMRoomInItem) {
            if (closeRoomByUser) {
                Log.d(TAG, "OnRecvRoomCloseNotice-closeRoomByUser:" + true);
            } else if (!TextUtils.isEmpty(mIMRoomInItem.roomId) && roomId.equals(mIMRoomInItem.roomId)) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        boolean isShowRecommand = false;
                        Log.i("Jagger", "BaseCommonLiveRoomActivity OnRecvRoomCloseNotice book:" + (privItem == null ? "null" : privItem.isHasBookingAuth));
                        if (errType == IMClientListener.LCC_ERR_TYPE.LCC_ERR_RECV_REGULAR_CLOSE_ROOM) {
                            //正常关闭才推荐
                            isShowRecommand = true;
                        }
                        if (isActivityVisible()) {
                            endLive(PAGE_ERROR_LIEV_EDN, errMsg, isShowRecommand, true, privItem);
                        } else {
                            mIsNeedRecommand = isShowRecommand;
                            mIsNeedCommand = true;
                            mIsRoomBackgroundClose = true;
                            mCloseErrMsg = errMsg;
                            mClosePageErrorType = PAGE_ERROR_LIEV_EDN;
                        }
                    }
                });
            }
        }

    }

    protected void endLive(LiveRoomNormalErrorActivity.PageErrorType pageErrorType, String errMsg, boolean isRecommand, boolean needCommand, IMAuthorityItem priv) {
        Log.d(TAG, "endLive");
        if (!TextUtils.isEmpty(mInvitationRoomId)) {
            //关闭直播间是因为邀请成功导致
            enterHangoutTransition();
        } else {
            if (null != mIMRoomInItem && null != pageErrorType) {
                Intent intent = null;
                if (mIMRoomInItem.liveShowType == IMRoomInItem.IMPublicRoomType.Program) {
                    intent = LiveProgramEndActivity.getIntent(this, pageErrorType, errMsg, mIMRoomInItem.userId, mIMRoomInItem.nickName, mIMRoomInItem.photoUrl, roomPhotoUrl, isRecommand, priv);
                } else {
                    intent = LiveRoomNormalErrorActivity.getIntent(this, pageErrorType, errMsg, mIMRoomInItem.userId, mIMRoomInItem.nickName, mIMRoomInItem.photoUrl, roomPhotoUrl, isRecommand, priv);
                }
                startActivity(intent);
            }
            closeLiveRoom(needCommand);
        }
    }

    @Override
    public void OnRecvChangeVideoUrl(String roomId, boolean isAnchor, final String[] playUrls, String userId) {
        if (!isCurrentRoom(roomId)) {
            return;
        }
        super.OnRecvChangeVideoUrl(roomId, isAnchor, playUrls, userId);
        if (mIMRoomInItem != null && roomId.equals(mIMRoomInItem.roomId)) {
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    //观众或主播切换视频通知
                    startLivePlayer(playUrls);
                }
            });
        }
    }

    /********************************* 男士publisher逻辑start *******************************************/

    private PublisherManager mPublisherManager; //推流管理器
    private boolean isPublishing = false;       //是否正在视频互动中
    //    private boolean hasPublished = false;       //是否正在视频互动中
    private boolean isPublishMute = false;      //视频互动中是否静音
    private int mVideoInteractionReqId = -1;    //解决区分请求是否处理问题
    protected OpenInterVideoTipsPopupWindow openInterVideoTipsPopupWindow;
    protected boolean neverShowTipsAgain = false;
    protected LocalPreferenceManager localPreferenceManager = null;
    private IMClient.IMVideoInteractiveOperateType lastVideoInteractiveOperateType;
    private final int PUBLIC_CLICK_TIME = 3000;    //点击时间间隔
    private long mPublishStartlastClickTime = 0, mPublishEndlastClickTime = 0;  //防快速点击

    /**
     * 初始化视频互动界面
     */
    private void initPublishView() {
        ll_msg_menu = findViewById(R.id.ll_msg_menu);
        iv_publish_cam = (ImageButton)findViewById(R.id.iv_publish_cam);
        iv_flowers = findViewById(R.id.iv_flowers);
        LoginItem loginItem = LoginManager.getInstance().getLoginItem();
        if (null != loginItem) {
            if(loginItem.userPriv.isGiftFlowerPriv && loginItem.isGiftFlowerSwitch){
                iv_flowers.setVisibility(View.VISIBLE);
            }else{
                iv_flowers.setVisibility(View.GONE);
            }
        }
        //视频上传预览
        includePublish = findViewById(R.id.includePublish);
        includePublish.setVisibility(View.GONE);
        svPublisher = (GLSurfaceView) findViewById(R.id.svPublisher);
        //add by Jagger 2017-11-29 解决小窗口能浮在大窗口上的问题
        svPublisher.setZOrderOnTop(true);
        svPublisher.setZOrderMediaOverlay(true);
        svPublisher.getHolder().setFormat(PixelFormat.TRANSPARENT);
        //
        svPublisher.getHolder().setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);

        flPublishOperate = (FrameLayout) findViewById(R.id.flPublishOperate);
        iv_publishstart = (ImageView) findViewById(R.id.iv_publishstart);
        iv_publishstop = (ImageView) findViewById(R.id.iv_publishstop);
        iv_publishstop.setVisibility(View.GONE);
        iv_publishsoundswitch = (ImageView) findViewById(R.id.iv_publishsoundswitch);
        iv_publishsoundswitch.setVisibility(View.GONE);
        publishLoading = (ProgressBar) findViewById(R.id.publishLoading);

        iv_publish_cam.setOnClickListener(this);
        iv_flowers.setOnClickListener(this);
        iv_publishstart.setOnClickListener(this);
        iv_publishstop.setOnClickListener(this);
        iv_publishsoundswitch.setOnClickListener(this);
        includePublish.setOnClickListener(this);
        // 视频上传区拖动事件
//        ViewDragTouchListener listener = new ViewDragTouchListener(100l);
//        listener.setOnViewDragListener(new ViewDragTouchListener.OnViewDragStatusChangedListener() {
//            @Override
//            public void onViewDragged(int l, int t, int r, int b) {
//                Log.d(TAG, "onViewDragged-l:" + l + " t:" + t + " r:" + r + " b:" + b);
//                //避免父布局重绘后includePublish回到原来的位置
//                RelativeLayout.LayoutParams flIPublish = (RelativeLayout.LayoutParams) includePublish.getLayoutParams();
////                flIPublish.gravity = Gravity.TOP | Gravity.LEFT;
//                flIPublish.leftMargin = includePublish.getLeft();
//                flIPublish.topMargin = includePublish.getTop();
//                includePublish.setLayoutParams(flIPublish);
//            }
//        });
//        includePublish.setOnTouchListener(listener);
        //高斯模糊头像部分
        view_gaussian_blur_me = findViewById(R.id.view_gaussian_blur_me);
        v_gaussianBlurFloat = findViewById(R.id.v_gaussianBlurFloat);
        iv_gaussianBlur = (SimpleDraweeView) findViewById(R.id.iv_gaussianBlur);

        openInterVideoTipsPopupWindow = new OpenInterVideoTipsPopupWindow(this);
        openInterVideoTipsPopupWindow.setOnBtnClickListener(new OpenInterVideoTipsPopupWindow.OnOpenTipsBtnClickListener() {
            @Override
            public void onBtnClicked(boolean isOpenVideo, boolean neverShowTipsAgain) {
                if (isOpenVideo) {
                    switchPublishStatus(true);
                    startOrStopVideoInteraction();
                }
                BaseCommonFullScreenLiveRoomActivity.this.neverShowTipsAgain = neverShowTipsAgain;
                if (null != localPreferenceManager) {
                    try {
                        localPreferenceManager.save("neverShowTipsAgain", BaseCommonFullScreenLiveRoomActivity.this.neverShowTipsAgain);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
        });

        //初始化推流器(这个东西只能初始化一次，跟GLSurfaceView生命周期一样。 而且初始化慢点也不行，一定要在这做)
        mPublisherManager = new PublisherManager(this);
        mPublisherManager.init(svPublisher);
    }

    protected void initPublishData() {
        localPreferenceManager = new LocalPreferenceManager(this);
        Object obj = localPreferenceManager.getObject("neverShowTipsAgain");
        if (obj != null && obj instanceof Boolean) {
            neverShowTipsAgain = (Boolean) obj;
        }

        Log.d(TAG, "initPublishData-neverShowTipsAgain:" + neverShowTipsAgain);
        if (checkCanInterVideo()) {
            //豪华私密直播间才支持视频互动功能
            iv_publish_cam.setVisibility(View.VISIBLE);
            //del by Jagger 2017-12-1 改为每次启动互动视频上传时 重新初始化(因为不释放掉相机,LG-D820暂时几分钟后,会CHRASH)
            //播放器初始化
//            mPublisherManager = new PublisherManager(this);
//            mPublisherManager.init(svPublisher);
//
            if (mIMRoomInItem.manUploadRtmpUrls != null
                    && mIMRoomInItem.manUploadRtmpUrls.length > 0 && !TextUtils.isEmpty(mIMRoomInItem.manUploadRtmpUrls[0])) {
                switchPublishStatus(true);
                startOrStopVideoInteraction();
            }
        } else {
            iv_publish_cam.setVisibility(View.GONE);
        }

    }

    /**
     * 点击开始按钮事件响应
     */
    private void onStartPublishClick(){
        if (!isHasPermission) {
            doShowPublishNoPermissionDialog();
            return;
        }

        if (System.currentTimeMillis() - mPublishStartlastClickTime > PUBLIC_CLICK_TIME) {//判断距离上次点击小于2秒
            mPublishStartlastClickTime = System.currentTimeMillis();//记录这次点击时间
            publishStart();
        }
    }

    /**
     * 点击鲜花礼品入口
     */
    private void onFlowersClicked(){
        //TODO
        if (mIMRoomInItem != null) {
            FlowersAnchorShopListActivity.startAct(mContext, mIMRoomInItem.userId,
                    mIMRoomInItem.nickName, mIMRoomInItem.photoUrl);
        }
    }

    /**
     * add by Jagger 2017-12-1
     * 回收拉流播放器
     */
    private void destroyPublisher() {
        //回收拉流播放器
        if (mPublisherManager != null) {
            mPublisherManager.uninit();
            mPublisherManager = null;
        }
    }

    /**
     * 开始互动
     */
    private void publishStart() {
        if (neverShowTipsAgain) {
            switchPublishStatus(true);
            startOrStopVideoInteraction();
        } else {
            if (null != openInterVideoTipsPopupWindow) {
                String textDesc = "";
                if (mIMRoomInItem != null) {
                    textDesc = String.format(getResources().getString(R.string.live_inter_video_open),
                            ApplicationSettingUtil.formatCoinValue(mIMRoomInItem.videoPrice));
                }
                if (!TextUtils.isEmpty(textDesc)) {
                    openInterVideoTipsPopupWindow.setTextDesc(textDesc);
                }
                openInterVideoTipsPopupWindow.showAtLocation(flContentBody, Gravity.CENTER, 0, 0);
            }
        }
        //GA统计点击开启互动视频
        onAnalyticsEvent(getResources().getString(R.string.Live_Broadcast_Category),
                getResources().getString(R.string.Live_Broadcast_Action_TwoWayVideo),
                getResources().getString(R.string.Live_Broadcast_Label_TwoWayVideo));
    }

    /**
     * 检测是否支持互动视频功能（仅标准私密直播间及豪华私密直播间支持该功能）
     *
     * @return
     */
    private boolean checkCanInterVideo() {
        boolean canInterVideo = false;
        if (mIMRoomInItem != null
                && (mIMRoomInItem.roomType == IMLiveRoomType.AdvancedPrivateRoom || mIMRoomInItem.roomType == IMLiveRoomType.NormalPrivateRoom)
                && LSPublisher.checkDeviceSupport(mContext)
        ) {
            canInterVideo = true;
        }
        return canInterVideo;
    }

    /**
     * 互动视频断线相关处理
     */
    private void onPublishDisconnect() {
        if (isPublishing) {
            stopPublishStream();
            flPublishOperate.setVisibility(View.GONE);
            publishLoading.setVisibility(View.VISIBLE);
        }
    }

    /**
     * 切换播放状态
     */
    private void switchPublishStatus(boolean isShowPublish){
        if(isShowPublish){
            iv_publish_cam.setVisibility(View.GONE);
            includePublish.setVisibility(View.VISIBLE);
        }else{
            iv_publish_cam.setVisibility(View.VISIBLE);
            includePublish.setVisibility(View.GONE);
        }
    }

    /**
     * 断线重连重新进入房间，互动模块处理
     */
    private void onDisconnectRoomIn() {
        //拉流处理
        if (mIMRoomInItem != null && mIMRoomInItem.videoUrls != null) {
            startLivePlayer(mIMRoomInItem.videoUrls);
        }

        //推流处理
        if (mIMRoomInItem.manUploadRtmpUrls != null
                && mIMRoomInItem.manUploadRtmpUrls.length > 0 && !TextUtils.isEmpty(mIMRoomInItem.manUploadRtmpUrls[0])) {
            //            startPublishStream(manPushUrl);
            switchPublishStatus(true);
            startOrStopVideoInteraction();
        } else {
            //断线重连后，男士上传被后台停止
            stopPublishStream();
            switchPublishStatus(false);
        }

        //公开直播间IM断线重登录成功并进入直播间（调用《3.4.获取直播间观众头像列表（http post）》）（缓存观众信息，包括头像、昵称、座驾等）
        if (null != mIMRoomInItem && (mIMRoomInItem.roomType == IMLiveRoomType.FreePublicRoom
                || mIMRoomInItem.roomType == IMLiveRoomType.PaidPublicRoom)) {
            //查询头像列表
            LiveRequestOperator.getInstance().GetAudienceListInRoom(mIMRoomInItem.roomId, 0, 0, this);
        }
    }

    /**
     * 隐藏操作区
     */
    private Runnable mHideOperateRunnable = new Runnable() {
        @Override
        public void run() {
            if (flPublishOperate != null) {
                flPublishOperate.setVisibility(View.GONE);
            }
        }
    };

    /**
     * 开启／关闭视频互动返回 或 点击视频上传，显示按钮
     */
    private void refreshPublishViews() {
        flPublishOperate.setVisibility(View.VISIBLE);
        //清除隐藏操作区定时任务
        removeCallback(mHideOperateRunnable);
        if (isPublishing) {
            view_gaussian_blur_me.setVisibility(View.GONE);
            iv_publishstop.setVisibility(View.VISIBLE);
            iv_publishstart.setVisibility(View.GONE);
            iv_publishsoundswitch.setVisibility(View.GONE);
            //add by Jagger 2017-12-1
            svPublisher.setVisibility(View.VISIBLE);
            if (isPublishMute) {
                //静音
                iv_publishsoundswitch.setImageResource(R.drawable.ic_live_publish_sound_off);
            } else {
                iv_publishsoundswitch.setImageResource(R.drawable.ic_live_publish_sound_on);
            }
            //启动3秒后隐藏操作区
            postUiRunnableDelayed(mHideOperateRunnable, 3 * 1000);
//            hasPublished = true;
        } else {
            //add by Jagger 2017-12-1
            svPublisher.setVisibility(View.GONE);
            svPublisher.destroyDrawingCache();

            view_gaussian_blur_me.setVisibility(View.VISIBLE);
            iv_publishstop.setVisibility(View.VISIBLE);
            iv_publishstart.setVisibility(View.GONE);
            iv_publishsoundswitch.setVisibility(View.GONE);
        }
    }

    /**
     * 开始／关闭视频互动
     */
    private void startOrStopVideoInteraction() {
        if (isPublishing) {
            doReqStopVideoInteraction();
        }else{
            doReqStartVideoInteraction();
        }
    }

    /**
     * 开始视频互动
     */
    private void doReqStartVideoInteraction(){
        lastVideoInteractiveOperateType = IMClient.IMVideoInteractiveOperateType.Start;
        doReqVideoInteraction();
    }

    /**
     * 关闭视频互动
     */
    private void doReqStopVideoInteraction(){
        lastVideoInteractiveOperateType = IMClient.IMVideoInteractiveOperateType.Close;
        doReqVideoInteraction();
    }

    /**
     * 请求操作推流接口
     */
    private void doReqVideoInteraction() {
        if (mIMRoomInItem != null) {
            mVideoInteractionReqId = mIMManager.ControlManPush(mIMRoomInItem.roomId, lastVideoInteractiveOperateType);
            if (IM_INVALID_REQID != mVideoInteractionReqId) {
                //发出请求成功
                flPublishOperate.setVisibility(View.GONE);
                publishLoading.setVisibility(View.VISIBLE);
            } else{
                //请求未发送成功，需要弹出dialog提示错误
                if (lastVideoInteractiveOperateType == IMClient.IMVideoInteractiveOperateType.Start) {
                    //开启失败
                    showStartPublishErrorDialog(getResources().getString(R.string.live_inter_video_failed_open));
                } else {
                    //关闭失败
                    showStopPublishErrorDialog(getResources().getString(R.string.live_inter_video_failed_close));
                }
                refreshPublishViews();
            }
        }
    }

    /**
     * 设置静音
     */
    private void setPublishMute() {
        if (mPublisherManager != null) {
            isPublishMute = !isPublishMute;
            if (isPublishMute) {
                //静音
                iv_publishsoundswitch.setImageResource(R.drawable.ic_live_publish_sound_off);
            } else {
                iv_publishsoundswitch.setImageResource(R.drawable.ic_live_publish_sound_on);
            }
            mPublisherManager.setPublisherMute(isPublishMute);
            Log.d(TAG, "setPublishMute-isPublishMute:" + isPublishMute);
        }
    }

    /**
     * 开始视频上传
     *
     * @param manPushUrls
     */
    private void startPublishStream(String[] manPushUrls) {
        isPublishing = true;

        //刷新界面
        refreshPublishViews();

        //初始化播放器
        if (mPublisherManager != null && mPublisherManager.isInited()) {
            mPublisherManager.setPublisherMute(isPublishMute);
            mPublisherManager.setOrChangeManUploadUrls(manPushUrls, "", "");
        }
    }

    /**
     * 停止上传视频
     */
    public void stopPublishStream() {
        isPublishing = false;

        if (mPublisherManager != null) {
            mPublisherManager.stop();
        }

        //刷新界面
        refreshPublishViews();
    }

    /**
     * 开启／关闭视频互动回调
     *
     * @param reqId
     * @param success
     * @param errType
     * @param errMsg
     * @param manPushUrl
     */
    @Override
    public void OnControlManPush(int reqId, final boolean success, final IMClientListener.LCC_ERR_TYPE errType,
                                 final String errMsg, final String[] manPushUrl) {
        super.OnControlManPush(reqId, success, errType, errMsg, manPushUrl);
        Log.i("hunter", "OnControlManPush mVideoInteractionReqId: " + mVideoInteractionReqId + " reqId: " + reqId + " sucess: " +  success
                + " isPublishing: " + isPublishing  + " errType: " + errType);
        if (mVideoInteractionReqId == reqId) {
            //请求需要处理
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    publishLoading.setVisibility(View.GONE);
                    if (success) {
                        if (isPublishing) {
                            //停止上传
                            stopPublishStream();
                            switchPublishStatus(false);
                        } else {
                            //启动上传
                            if (manPushUrl != null && manPushUrl.length > 0) {
                                switchPublishStatus(true);
                                startPublishStream(manPushUrl);
                            } else {
                                //状态异常，处理为启动失败
//                                showToast(getResources().getString(R.string.common_webview_load_error));
                                showStartPublishErrorDialog(getResources().getString(R.string.common_webview_load_error));
                                //调用关闭，防止持续扣费
                                mIMManager.ControlManPush(mIMRoomInItem.roomId, IMClient.IMVideoInteractiveOperateType.Close);
                            }
                        }
                    } else {
                        //开启或关闭失败
                        if (errType == LCC_ERR_INCONSISTENT_CREDIT_FAIL
                                || errType == LCC_ERR_NO_CREDIT
                                || errType == LCC_ERR_NO_CREDIT_DOUBLE_VIDEO) {
                            switchPublishStatus(false);
                            String errTips = errMsg;
                            if(TextUtils.isEmpty(errTips)){
                                errTips = getResources().getString(R.string.live_common_noenough_money_for_2ways_tips);
                            }
                            showCreditNoEnoughDialog(errTips);
                        } else {
                            if (lastVideoInteractiveOperateType == IMClient.IMVideoInteractiveOperateType.Start) {
                                //开启失败
//                                showToast(getResources().getString(R.string.live_inter_video_failed_open));
                                showStartPublishErrorDialog(getResources().getString(R.string.live_inter_video_failed_open));
                            } else {
                                //关闭失败
                                showStopPublishErrorDialog(getResources().getString(R.string.live_inter_video_failed_close));
                            }
                        }
                        refreshPublishViews();
                    }
                }
            });
        }
    }

    private int mIPublishTempTop = -1;
    private boolean mIsMovePublishViewUnderEditView = false;

    /**
     * add by Jagger 2017-12-6
     * 还原浮动的视频窗体位置,对应doMovePublishViewUnderEditView()
     */
    private void doReMovePublishView() {
        if (mIsMovePublishViewUnderEditView && mIPublishTempTop != -1) {
            FrameLayout.LayoutParams flIPublish = (FrameLayout.LayoutParams) includePublish.getLayoutParams();
            flIPublish.topMargin = mIPublishTempTop;
            includePublish.setLayoutParams(flIPublish);
            //
            mIsMovePublishViewUnderEditView = false;
        }
    }

    /**
     * 没权限，提示用户
     */
    private void doShowPublishNoPermissionDialog() {
        View view = View.inflate(this, R.layout.dialog_simple_double_btn, null);
        final Dialog dialog = DialogUIUtils.showCustomAlert(this, view,
                null,
                null,
                Gravity.CENTER, true, true,
                null).show();
        //VIEW内事件
        ((TextView) view.findViewById(R.id.tv_simpleTips)).setText(getString(R.string.liveroom_publish_no_permission_tips));
        view.findViewById(R.id.tv_confirm).setVisibility(View.GONE);

        TextView btnOk = (TextView) view.findViewById(R.id.tv_cancel);
        btnOk.setText(getString(R.string.common_btn_ok));
        btnOk.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                DialogUIUtils.dismiss(dialog);
            }
        });

        view.findViewById(R.id.iv_closeSimpleTips).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                DialogUIUtils.dismiss(dialog);
            }
        });
    }

    /**
     * 打开双向视频 显示错误提示
     * @param desc
     */
    private void showStartPublishErrorDialog(String desc){
        AlertDialog.Builder builder = new AlertDialog.Builder(this)
                .setMessage(desc)
                .setCancelable(false)
                .setPositiveButton(getResources().getString(R.string.live_common_btn_close), new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int i) {
                        //启动失败
                        if(!isPublishing){
                            switchPublishStatus(false);
                        }
                    }
                })
                .setNegativeButton(getResources().getString(R.string.live_common_btn_retry), new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int i) {
                        switchPublishStatus(true);
                        startOrStopVideoInteraction();
                    }
                });
        if (isActivityVisible()) {
            builder.create().show();
        }
    }

    /**
     * 关闭双向视频 显示错误提示
     * @param desc
     */
    private void showStopPublishErrorDialog(String desc){
        AlertDialog.Builder builder = new AlertDialog.Builder(this)
                .setMessage(desc)
                .setCancelable(false)
                .setPositiveButton(getResources().getString(R.string.live_common_btn_close), new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int i) {
                    }
                })
                .setNegativeButton(getResources().getString(R.string.live_common_btn_retry), new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int i) {
                        doReqStopVideoInteraction();
                    }
                });
        if (isActivityVisible()) {
            builder.create().show();
        }
    }

    //------------------------------------才艺点播相关--------------------------------
    protected TalentManager talentManager;
    private TalentManager.onTalentEventListener mTalentEventListener = new TalentManager.onTalentEventListener() {
        @Override
        public void onGetTalentList(HttpRespObject httpRespObject) {

        }

        @Override
        public void onConfirm(TalentInfoItem talent) {
            Log.i(TAG, "initTalentManager-onConfirm talent:" + talent);

            double currCredits = mLiveRoomCreditRebateManager.getCredit();
            if (currCredits < talent.talentCredit) {
                showCreditNoEnoughDialog(R.string.live_common_noenough_money_tips);
                return;
            }

            //调用IM接口
            if (null != mIMRoomInItem && null != mIMManager) {
                mIMManager.sendTalentInvite(mIMRoomInItem.roomId, talent.talentId);
            }
        }
    };

    private void initTalentManager() {
        Log.d(TAG, "initTalentManager");
        if (null != mIMRoomInItem && mIMRoomInItem.roomType == IMLiveRoomType.AdvancedPrivateRoom) {
            talentManager = TalentManager.newInstance(this, mIMRoomInItem);
            talentManager.registerOnTalentEventListener(mTalentEventListener);
        }
    }

    @Override
    public void OnSendTalent(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, String talentInviteId, String talentId) {
        super.OnSendTalent(reqId, success, errType, errMsg, talentInviteId, talentId);
        if (null != talentManager) {
            talentManager.onTalentSent(success, errMsg, errType, talentInviteId, talentId);
        }

        //回调结果
        if (success) {
            TalentInfoItem talentInfoItem = talentManager.getTalentInfoItemById(talentId);

            Message msg = Message.obtain();
            msg.what = EVENT_TALENT_SENT_SUCCESS;
            msg.obj = talentInfoItem;
            sendUiMessage(msg);
        } else {
            Message msg = Message.obtain();
            msg.what = EVENT_TALENT_SENT_FAIL;
            msg.arg1 = errType.ordinal();
            msg.obj = errMsg;
            sendUiMessage(msg);
        }

    }

    @Override
    public void OnRecvSendTalentNotice(String roomId, String talentInviteId,
                                       String talentId, String name, double credit,
                                       IMClientListener.TalentInviteStatus status, double rebateCredit, String giftId, String giftName, int giftNum) {
        if (!isCurrentRoom(roomId)) {
            return;
        }
        super.OnRecvSendTalentNotice(roomId, talentInviteId, talentId, name, credit, status, rebateCredit, giftId, giftName, giftNum);
        if (null != talentManager) {
            if (talentManager.onTalentProcessed(talentId, name, credit, status, giftId, giftName, giftNum, talentInviteId)) {
                //
                TalentInviteItem talentInviteItem = new TalentInviteItem(
                        talentInviteId,
                        talentId,
                        name,
                        credit,
                        status.ordinal(),
                        giftId,
                        giftName,
                        giftNum
                );
                Message msg = Message.obtain();
                msg.what = EVENT_REC_TALENT_NOTICE;
                msg.obj = talentInviteItem;
                sendUiMessage(msg);
            }
        }
    }

    @Override
    public void OnRecvTalentPromptNotice(String roomId, String introduction) {
        if (!isCurrentRoom(roomId) || (mIMRoomInItem == null)) {
            return;
        }

        IMMessageItem msgItem = new IMMessageItem(roomId,
                mIMManager.mMsgIdIndex.getAndIncrement(),
                mIMRoomInItem.userId,
                mIMRoomInItem.nickName,
                "",
                0,
                IMMessageItem.MessageType.TalentRecommand,
                new IMTextMessageContent(introduction), null);

        Message msg = Message.obtain();
        msg.what = EVENT_MESSAGE_UPDATE;
        msg.obj = msgItem;
        sendUiMessage(msg);
    }

    @Override
    public void onItemClick(IMMessageItem item) {
        //消息列表点击响应
        if (item != null) {
            switch (item.msgType) {
                case AnchorRecommand: {
                    startHangoutInvitation(item.hangoutRecommendItem);
                }
                break;
                case TalentRecommand: {
                    //显示才艺列表
                    if (null != mIMRoomInItem) {
                        talentManager.showTalentsList(this, flContentBody);
                    }

                    //GA点击才艺点播
                    onAnalyticsEvent(getResources().getString(R.string.Live_Broadcast_Category),
                            getResources().getString(R.string.Live_Broadcast_Action_Talent),
                            getResources().getString(R.string.Live_Broadcast_Label_Talent));
                }
                break;
            }
        }
    }

    /*********************************  男士publisher逻辑end  *******************************************/

    /*******************************断线重连****************************************/
    @Override
    public void onIMAutoReLogined() {
        super.onIMAutoReLogined();
        //断线重连，需要拿roomId重新登录房间
        Log.d(TAG, "onIMAutoReLogined-mIMRoomInItem:" + mIMRoomInItem);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (null != mIMRoomInItem && !TextUtils.isEmpty(mIMRoomInItem.roomId)) {
                    if (null != mIMManager) {
                        int result = mIMManager.RoomIn(mIMRoomInItem.roomId);
                        Log.d(TAG, "onIMAutoReLogined-result:" + result + "IM_INVALID_REQID:" + IM_INVALID_REQID);
                    }
                }
                if (null != talentManager) {
                    talentManager.getTalentStatus();
                }
            }
        });
    }

    @Override
    public void OnLogout(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
        super.OnLogout(errType, errMsg);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                //断线互动视频处理
                onPublishDisconnect();
                //通知推流和拉流管理器，IM 断开链接
                if (mPublisherManager != null) {
                    mPublisherManager.onLogout();
                }
                if (mLivePlayerManager != null) {
                    mLivePlayerManager.onLogout();
                }
            }
        });
    }

    //--------------------------------进入后台超过一定时间------------------------------------------------
    @Override
    protected void onStop() {
        super.onStop();
        //开启计时器
        Log.d(TAG, "onStop-开启app处于后台计时器 hasBackgroundTimeOut:" + hasBackgroundTimeOut);
        if (SystemUtils.isBackground(this) && !hasBackgroundTimeOut && !mIsRoomBackgroundClose) {
            sendEmptyUiMessageDelayed(EVENT_TIMEOUT_BACKGROUND, 60 * 1000l);
        }

        //TODO:清空大礼物动画播放队列
        if (null != mModuleGiftManager) {
            mModuleGiftManager.onAdvanceGiftOnStop();
        }
    }

    @Override
    protected void onStart() {
        super.onStart();
        removeUiMessages(EVENT_TIMEOUT_BACKGROUND);
    }


    @Override
    protected void onResume() {
        super.onResume();
        Log.d(TAG, "onResume-hasBackgroundTimeOut:" + hasBackgroundTimeOut);

        //直播中切换其他界面如主播资料时，收到直播间关闭等通知需要关闭直播间，延迟处理
        if (mIsRoomBackgroundClose) {
            if (mClosePageErrorType != null) {
//                Log.i("Jagger", "BaseCommonLiveRoomActivity onResume1 book:" + (mAuthorityItem == null ? "null" : mAuthorityItem.isHasBookingAuth));
                endLive(mClosePageErrorType, mCloseErrMsg, mIsNeedRecommand, mIsNeedCommand, mAuthorityItem);
            }
        } else if (hasBackgroundTimeOut) {
            //解决5.0以下startActivity会在后台打开页面，但是5.0以上会将应用带到前台
//            Log.i("Jagger", "BaseCommonLiveRoomActivity onResume2 book:" + (mAuthorityItem == null ? "null" : mAuthorityItem.isHasBookingAuth));
            endLive(LiveRoomNormalErrorActivity.PageErrorType.PAGE_ERROR_BACKGROUD_OVERTIME, "", true, true, mAuthorityItem);
        } else {
            //刷新一次信用点解决信用点不足，充值返回，由于本地信用点未刷新导致直播间本地判断异常
            GetCredit();
        }

        //
        if(mPublisherManager != null) {
            mPublisherManager.reconnect();
        }

        //重置标志位
        mIsRoomBackgroundClose = false;
        mClosePageErrorType = null;
        hasBackgroundTimeOut = false;
        mIsNeedRecommand = false;
        mIsNeedCommand = true;
        mCloseErrMsg = "";
    }

    //--------------------------------多人互动邀请业务------------------------------------------------
    private HashMap<String, Object> mHangoutInviteMap = new HashMap<>();

    /**
     * 点击顶部hangout按钮发起hangout邀请
     *
     * @param anchorItem
     */
    private void startHangoutInvitation(final HangoutOnlineAnchorItem anchorItem) {
        if (mHangoutInviteMap.size() == 0) {
            mHangoutInviteMap.put(anchorItem.anchorId, anchorItem);
            startInvitationInternal(new IMUserBaseInfoItem(anchorItem.anchorId, anchorItem.nickName, anchorItem.coverImg), mIMRoomInItem.roomId, "", true);
        }
    }

    /**
     * 点击推荐发起hangout邀请
     *
     * @param recommendItem
     */
    private void startHangoutInvitation(final IMHangoutRecommendItem recommendItem) {
        if (mHangoutInviteMap.size() == 0) {
            mHangoutInviteMap.put(recommendItem.anchorId, recommendItem);
            startInvitationInternal(new IMUserBaseInfoItem(recommendItem.anchorId, recommendItem.nickName, recommendItem.photoUrl), mIMRoomInItem.roomId, recommendItem.recommendId, true);
        }
    }

    /**
     * 内部发起邀请
     *
     * @param anchorInfo
     * @param roomId
     * @param recommandId
     * @param createOnly
     */
    private void startInvitationInternal(IMUserBaseInfoItem anchorInfo, String roomId, String recommandId, boolean createOnly) {
        if (mHangoutInvitationManager != null) {
            //清除旧的
            mHangoutInvitationManager.release();
        }
        //互斥关系创建新的邀请client
        mHangoutInvitationManager = HangoutInvitationManager.createInvitationClient(this);
        mHangoutInvitationManager.setClientEventListener(this);
        mHangoutInvitationManager.startInvitationSession(anchorInfo, roomId, recommandId, createOnly, false);
    }

    /**
     * 提示hangout邀请发送成功，等待
     *
     * @param anchorName
     */
    private void showHangoutInviteStart(String anchorName) {
//        if (tvInviteTips != null) {
//            tvInviteTips.setVisibility(View.VISIBLE);
//            String message = String.format(getResources().getString(R.string.hangout_invtite_start_tips), anchorName);
//            tvInviteTips.setText(message);
//        }

        String message = String.format(getResources().getString(R.string.hangout_invtite_start_tips), anchorName);
        sendHangOutMsg(message);
    }

    /**
     * 进入hangout过渡页
     */
    private void enterHangoutTransition() {
        if (mIMRoomInItem != null && mHangoutInviteMap != null && mHangoutInviteMap.containsKey(mIMRoomInItem.userId)) {
            //生成被邀请的主播列表（这里是目标主播一人）
            Object inviteItem = mHangoutInviteMap.remove(mIMRoomInItem.userId);
            if (inviteItem != null) {
                ArrayList<IMUserBaseInfoItem> anchorList = new ArrayList<>();
                String recommandId = "";
                if (inviteItem instanceof IMHangoutRecommendItem) {
                    //推荐进入
                    IMHangoutRecommendItem tempRecommand = (IMHangoutRecommendItem) inviteItem;
                    anchorList.add(new IMUserBaseInfoItem(tempRecommand.anchorId, tempRecommand.nickName, tempRecommand.photoUrl));
                    anchorList.add(new IMUserBaseInfoItem(tempRecommand.firendId, tempRecommand.friendNickName, tempRecommand.friendPhotoUrl));
                    recommandId = tempRecommand.recommendId;
                } else if (inviteItem instanceof HangoutOnlineAnchorItem) {
                    //点击头部进入
                    HangoutOnlineAnchorItem tempAnchorItem = (HangoutOnlineAnchorItem) inviteItem;
                    anchorList.add(new IMUserBaseInfoItem(tempAnchorItem.anchorId, tempAnchorItem.nickName, tempAnchorItem.avatarImg));
                }
                //过渡页
                Intent intent = HangoutTransitionActivity.getIntent(
                        mContext,
                        anchorList,
                        mInvitationRoomId,
                        "",
                        recommandId,
                        false);
                startActivity(intent);

                //重置本地缓存房间ID
                mInvitationRoomId = "";
            }

        }

        //先跳转再关闭
        closeLiveRoom(true);
    }

    /**************************************************  处理私密直播间主播推荐多人互动 *****************************************************/
    @Override
    public void OnRecvRecommendHangoutNotice(IMHangoutRecommendItem item) {
        Log.d(TAG, "OnRecvAnchorRecommendHangoutNotice-item:" + item);
        super.OnRecvRecommendHangoutNotice(item);
        if (mIMRoomInItem != null && (mIMRoomInItem.roomType == IMLiveRoomType.AdvancedPrivateRoom
                || mIMRoomInItem.roomType == IMLiveRoomType.NormalPrivateRoom)) {
            IMMessageItem msgItem = new IMMessageItem(item.roomId,
                    mIMManager.mMsgIdIndex.getAndIncrement(),
                    IMMessageItem.MessageType.AnchorRecommand,
                    item);
            sendMessageUpdateEvent(msgItem);
        }
    }

    @Override
    public void onHangoutInvitationStart(IMUserBaseInfoItem userBaseInfoItem) {
        showHangoutInviteStart(userBaseInfoItem.nickName);
    }

    @Override
    public void onHangoutInvitationFinish(final boolean isSuccess, HangoutInvitationManager.HangoutInvationErrorType errorType, String errMsg, final IMUserBaseInfoItem userBaseInfoItem, final String roomId) {
        if (isSuccess) {
            mInvitationRoomId = roomId;
//            if (tvInviteTips != null) {
//                tvInviteTips.setText(getResources().getString(R.string.hangout_invtite_success_tips));
//            }
            sendHangOutMsg(getResources().getString(R.string.hangout_invtite_success_tips));
        } else {
            //邀请失败，清掉本地缓存，防止无法再发起多人互动请求
            mHangoutInviteMap.remove(userBaseInfoItem.userId);

            if (errorType == HangoutInvitationManager.HangoutInvationErrorType.NoCredit) {
                //信用点不足
                showCreditNoEnoughDialog(R.string.hangout_invitation_noenough_money_tips);
            }
            //del by Jagger 2019-4-18 看BUG#17724
//            else if (errorType == HangoutInvitationManager.HangoutInvationErrorType.InviteDeny) {
//                // 2019/4/1 Hardy  系统提示：邀请被拒绝或主播180s后未响应 {主播昵称} is not responding. Please try again later.
//                IMSysNoticeMessageContent msgContent = new IMSysNoticeMessageContent(errMsg, "", IMSysNoticeMessageContent.SysNoticeType.Normal);
//                IMMessageItem msgItem = new IMMessageItem(roomId, mIMManager.mMsgIdIndex.getAndIncrement(),"",
//                        IMMessageItem.MessageType.SysNotice,msgContent);
//                sendMessageUpdateEvent(msgItem);
//            }
            else {
//                if (tvInviteTips != null && tvInviteTips.getVisibility() == View.VISIBLE) {
//                    //邀请已发送成功
//                    tvInviteTips.setText(errMsg);
//                } else {
//                    //邀请发送失败
//                    showToast(errMsg);
//                }

                sendHangOutMsg(errMsg);
            }
        }

        //启动3秒关闭提示
        postUiRunnableDelayed(new Runnable() {
            @Override
            public void run() {
                //关闭提示
//                if (tvInviteTips != null) {
//                    tvInviteTips.setVisibility(View.GONE);
//                }
                if (isSuccess) {
                    if (!TextUtils.isEmpty(mInvitationRoomId)) {
                        enterHangoutTransition();
                    }
                }
            }
        }, 3 * 1000);
    }

    @Override
    public void onHangoutCancel(boolean isSuccess, int httpErrCode, String errMsg, IMUserBaseInfoItem userBaseInfoItem) {

    }

    /**
     * 发送一条HangOut相关消息
     */
    private void sendHangOutMsg(String message){
        IMSysNoticeMessageContent msgContent = new IMSysNoticeMessageContent(message, "", IMSysNoticeMessageContent.SysNoticeType.Normal);
        IMMessageItem msgItem = new IMMessageItem(mIMRoomInItem.roomId, mIMManager.mMsgIdIndex.getAndIncrement(),"",
                IMMessageItem.MessageType.SysNotice,msgContent);
        sendMessageUpdateEvent(msgItem);
    }

    /**************************************************  处理推荐礼物区域 *****************************************************/
    private LinearLayout ll_recommendGift;
    private RecyclerView recycleView;
    private FrameLayout flStatus;
    private ImageView pb_waiting;
    private LinearLayout llEmptyError;
    private ImageView ivEmptyError;
    private TextView tvEmptyDesc;

    //是否加载成功
    private boolean mLoadRecommandGiftListSuccess = false;
    private LiveVirtualGiftRecommandAdapter mRecommandAdapter;

    private void initRecommandViews(){
        ll_recommendGift = (LinearLayout)findViewById(R.id.ll_recommendGift);
        recycleView = (RecyclerView)findViewById(R.id.recycleView);
        flStatus = (FrameLayout)findViewById(R.id.flStatus);
        pb_waiting = (ImageView)findViewById(R.id.pb_waiting);
        llEmptyError = (LinearLayout)findViewById(R.id.llEmptyError);
        ivEmptyError = (ImageView)findViewById(R.id.ivEmptyError);
        tvEmptyDesc = (TextView)findViewById(R.id.tvEmptyDesc);

        //初始化 recycleView
        LinearLayoutManager linearLayoutManager = new LinearLayoutManager(this);
        linearLayoutManager.setOrientation(LinearLayoutManager.HORIZONTAL);
        recycleView.setLayoutManager(linearLayoutManager);
        HorizontalLineDecoration gridMarginDecoration = new HorizontalLineDecoration(DisplayUtil.dip2px(mContext, 12));
        recycleView.addItemDecoration(gridMarginDecoration);

        llEmptyError.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(!mLoadRecommandGiftListSuccess){
                    //刷新
                    loadRecommandGiftList();
                }
            }
        });

        findViewById(R.id.flShowGift).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                //点击打开礼物列表
                showLiveVirtualGiftDialog();
            }
        });
    }

    /**
     * 初始化推荐数据
     */
    private void initRecommandData(){
        int screenwidth = DisplayUtil.getScreenWidth(this);
        int itemWidth = (screenwidth - DisplayUtil.dip2px(this, 4 * 2 + 58 + 12 * 2 + 12 * 4))/5;  //margin * 2 + 竖线 + 按钮宽度 + 列表内两边边距 + item间隔
        mRecommandAdapter = new LiveVirtualGiftRecommandAdapter(this, mRoomGiftManager, itemWidth);
        mRecommandAdapter.setOnItemClickListener(new BaseRecyclerViewAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(View v, int position) {
                GiftItem bean = mRecommandAdapter.getItemBean(position);
                if(liveVirtualGiftDialog != null && bean != null){
                    liveVirtualGiftDialog.sendGiftInternal(false, bean.id);
                }
            }
        });
        recycleView.setAdapter(mRecommandAdapter);
    }

    /**
     * 加载推荐礼物列表
     */
    private void loadRecommandGiftList(){
        if(!mLoadRecommandGiftListSuccess && mRoomGiftManager != null){
            showLoadingRecommandGift();
            mRoomGiftManager.getSendableGiftList(new OnGetSendableGiftListCallback() {
                @Override
                public void onGetSendableGiftList(final boolean isSuccess, int errCode, String errMsg, SendableGiftItem[] giftIds) {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            //刷新推荐列表返回
                            mLoadRecommandGiftListSuccess = isSuccess;
                            if(isSuccess){
                                List<GiftItem> giftItemList = mRoomGiftManager.getFilterRecommandGiftList();
                                if(giftItemList.size() > 0){
                                    showRecommandGiftList();
                                    if(mRecommandAdapter != null){
                                        mRecommandAdapter.setData(giftItemList);
                                    }
                                }else{
                                    showRecommandGiftListEmpty();
                                }
                            }else{
                                showRecommandGiftListLoadError();
                            }
                        }
                    });
                }
            });
        }
    }

    /**
     * 显示推荐区域
     */
    private void showRecommandArea(){
        ll_recommendGift.setVisibility(View.VISIBLE);
    }

    /**
     * 隐藏推荐区域
     */
    private void hideRecommandArea(){
        ll_recommendGift.setVisibility(View.GONE);
    }

    /**
     * 切换刷新推荐礼物列表
     */
    private void showLoadingRecommandGift(){
        recycleView.setVisibility(View.GONE);
        flStatus.setVisibility(View.VISIBLE);
        llEmptyError.setVisibility(View.GONE);
        showRecommandRefreshAnimation();
    }

    /**
     * 显示推荐礼物列表空页
     */
    private void showRecommandGiftListEmpty(){
        recycleView.setVisibility(View.GONE);
        flStatus.setVisibility(View.VISIBLE);
        llEmptyError.setVisibility(View.VISIBLE);
        hideRecommandRefreshAnimation();

        ivEmptyError.setBackgroundResource(R.drawable.ic_hangout_gift_empty);
        tvEmptyDesc.setText(R.string.liveroom_gift_store_empty);
    }

    /**
     * 显示推荐礼物错误页
     */
    private void showRecommandGiftListLoadError(){
        recycleView.setVisibility(View.GONE);
        flStatus.setVisibility(View.VISIBLE);
        llEmptyError.setVisibility(View.VISIBLE);
        hideRecommandRefreshAnimation();

        ivEmptyError.setBackgroundResource(R.drawable.ic_hangout_load_error);
        tvEmptyDesc.setText(R.string.live_common_taptoretry);
    }

    /**
     * 显示推荐礼物列表
     */
    private void showRecommandGiftList(){
        recycleView.setVisibility(View.VISIBLE);
        flStatus.setVisibility(View.GONE);
    }

    /**
     * 播放帧动画
     */
    private void showRecommandRefreshAnimation(){
        if(pb_waiting != null){
            pb_waiting.setVisibility(View.VISIBLE);
            AnimationDrawable progressDrawable = (AnimationDrawable) pb_waiting.getDrawable();
            if(!progressDrawable.isRunning()){
                progressDrawable.start();
            }
        }
    }

    /**
     * 回收帧动画
     */
    private void hideRecommandRefreshAnimation(){
        if(pb_waiting != null){
            AnimationDrawable progressDrawable = (AnimationDrawable) pb_waiting.getDrawable();
            if(progressDrawable.isRunning()){
                progressDrawable.stop();
            }
            pb_waiting.setVisibility(View.GONE);
        }
    }

    /***********************************  修改私密直播间没点提示样式  **********************************/
    protected CommonBuyCreditDialog mCommonBuyCreditDialog;

    @Override
    public void showCreditNoEnoughDialog(int tipsResId){
        if (null == mCommonBuyCreditDialog) {
            mCommonBuyCreditDialog = new CommonBuyCreditDialog(this);
        }
        if (!mCommonBuyCreditDialog.isShowing()) {
            mCommonBuyCreditDialog.setMessage(getResources().getString(tipsResId));
            mCommonBuyCreditDialog.show();
        }
    }

    public void showCreditNoEnoughDialog(String tipsResId){
        if (null == mCommonBuyCreditDialog) {
            mCommonBuyCreditDialog = new CommonBuyCreditDialog(this);
        }
        if (!mCommonBuyCreditDialog.isShowing()) {
            mCommonBuyCreditDialog.setMessage(tipsResId);
            mCommonBuyCreditDialog.show();
        }
    }
}
