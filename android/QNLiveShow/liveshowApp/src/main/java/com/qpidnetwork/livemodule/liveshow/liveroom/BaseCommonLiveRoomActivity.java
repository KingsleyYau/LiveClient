package com.qpidnetwork.livemodule.liveshow.liveroom;

import android.annotation.SuppressLint;
import android.app.Dialog;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.PixelFormat;
import android.graphics.Rect;
import android.graphics.drawable.AnimationDrawable;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.opengl.GLSurfaceView;
import android.os.Bundle;
import android.os.Message;
import android.support.annotation.Nullable;
import android.support.v4.app.FragmentManager;
import android.support.v4.view.ViewCompat;
import android.text.Editable;
import android.text.SpannableString;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.SurfaceHolder;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.view.animation.Animation;
import android.view.animation.AnimationSet;
import android.view.animation.AnimationUtils;
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.dou361.dialogui.DialogUIUtils;
import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnRequestCallback;
import com.qpidnetwork.livemodule.httprequest.item.AudienceBaseInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.EmotionCategory;
import com.qpidnetwork.livemodule.httprequest.item.EmotionItem;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.httprequest.item.HangoutOnlineAnchorItem;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
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
import com.qpidnetwork.livemodule.liveshow.anchor.AnchorProfileActivity;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.datacache.file.downloader.FileDownloadManager;
import com.qpidnetwork.livemodule.liveshow.datacache.file.downloader.IFileDownloadedListener;
import com.qpidnetwork.livemodule.liveshow.datacache.preference.LocalPreferenceManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.announcement.WarningDialog;
import com.qpidnetwork.livemodule.liveshow.liveroom.barrage.BarrageManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.barrage.IBarrageViewFiller;
import com.qpidnetwork.livemodule.liveshow.liveroom.car.CarInfo;
import com.qpidnetwork.livemodule.liveshow.liveroom.car.CarManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.GiftRecommandManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.GiftSendReqManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.GiftSender;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.ModuleGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.NormalGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.RoomGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.dialog.LiveGiftDialog;
import com.qpidnetwork.livemodule.liveshow.liveroom.hangout.view.HangOutDetailDialogFragment;
import com.qpidnetwork.livemodule.liveshow.liveroom.interactivevideo.OpenInterVideoTipsPopupWindow;
import com.qpidnetwork.livemodule.liveshow.liveroom.rebate.LiveRoomCreditRebateManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.rebate.RoomRebateTipsPopupWindow;
import com.qpidnetwork.livemodule.liveshow.liveroom.recharge.AudienceBalanceInfoPopupWindow;
import com.qpidnetwork.livemodule.liveshow.liveroom.talent.TalentManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.tariffprompt.TariffPromptManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.vedio.VedioLoadingAnimManager;
import com.qpidnetwork.livemodule.liveshow.manager.URL2ActivityManager;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.liveshow.personal.chatemoji.ChatEmojiManager;
import com.qpidnetwork.livemodule.liveshow.personal.chatemoji.EmojiTabScrollLayout;
import com.qpidnetwork.livemodule.liveshow.urlhandle.AppUrlHandler;
import com.qpidnetwork.livemodule.utils.ApplicationSettingUtil;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.ImageUtil;
import com.qpidnetwork.livemodule.utils.PicassoLoadUtil;
import com.qpidnetwork.livemodule.utils.SystemUtils;
import com.qpidnetwork.livemodule.view.CircleImageHorizontScrollView;
import com.qpidnetwork.livemodule.view.LiveRoomHeaderBezierView;
import com.qpidnetwork.livemodule.view.LiveRoomScrollView;
import com.qpidnetwork.livemodule.view.SimpleDoubleBtnTipsDialog;
import com.qpidnetwork.livemodule.view.SoftKeyboradListenFrameLayout;
import com.qpidnetwork.livemodule.view.listener.ViewDragTouchListener;
import com.qpidnetwork.qnbridgemodule.datacache.FileCacheManager;
import com.qpidnetwork.qnbridgemodule.util.Log;

import net.qdating.LSPublisher;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static com.qpidnetwork.livemodule.im.IMManager.IM_INVALID_REQID;
import static com.qpidnetwork.livemodule.im.listener.IMClientListener.LCC_ERR_TYPE.LCC_ERR_INCONSISTENT_CREDIT_FAIL;
import static com.qpidnetwork.livemodule.im.listener.IMClientListener.LCC_ERR_TYPE.LCC_ERR_NO_CREDIT;
import static com.qpidnetwork.livemodule.im.listener.IMClientListener.LCC_ERR_TYPE.LCC_ERR_NO_CREDIT_DOUBLE_VIDEO;
import static com.qpidnetwork.livemodule.liveshow.liveroom.LiveRoomNormalErrorActivity.PageErrorType.PAGE_ERROR_LIEV_EDN;
import static com.qpidnetwork.livemodule.liveshow.liveroom.LiveRoomNormalErrorActivity.PageErrorType.PAGE_ERROR_NOMONEY;

/**
 * 直播间公共处理界面类
 * 1.界面刷新，数据展示的处理放在该BaseActivity内处理
 * 2.设计到具体的房间类型内的，各种业务请求预处理，返回数据处理，各类型房间业务流程等的处理，都放到子类中做
 * 3.需要不断的review code，保证baseActivity、baseImplActivity及子类的职责明确
 * Created by Hunter Mun on 2017/6/16.
 */

public class BaseCommonLiveRoomActivity extends BaseImplLiveRoomActivity
        implements BarrageManager.OnBarrageEventListener, LiveRoomChatManager.LiveMessageListItemClickListener, GiftRecommandManager.OnGiftRecommandListener, HangoutInvitationManager.OnHangoutInvitationEventListener{

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
    protected static final int EVENT_FAVORITE_RESULT = 1007;
    /**
     * 直播间观众数量更新
     */
    protected static final int EVENT_UPDATE_ONLINEFANSNUM = 1009;
    /**
     * 高级礼物发送失败，3秒toast提示
     */
    private static final int EVENT_GIFT_ADVANCE_SEND_FAILED = 1010;
    /**
     * 礼物发送失败-信用点不足
     */
    private static final int EVENT_GIFT_SEND_FAILED_CREDITS_NOENOUGH = 1011;
    /**
     * 更新返点
     */
    private static final int EVENT_UPDATE_REBATE = 1012;
    /**
     * 直播间界面进入后台
     */
    private static final int EVENT_TIMEOUT_BACKGROUND = 1013;
    /**
     * 直播间关闭倒计时
     */
    private static final int EVENT_LEAVING_ROOM_TIMECOUNT = 1014;
    /**
     * 亲密度等级升级，更新界面展示
     */
    private static final int EVENT_INTIMACY_LEVEL_UPDATE = 1015;
    /**
     * 更新推荐礼物
     */
    private static final int EVENT_UPDATE_RECOMMANDGIFT = 1016;
    /**
     * 播放礼物动画
     */
    private static final int EVENT_SHOW_GIFT = 1017;
    /**
     * 用户等级升级
     */
    private static final int EVENT_MAN_LEVEL_UPDATE = 1018;

    /**
     * 才艺发送成功
     */
    private static final int EVENT_TALENT_SENT_SUCCESS = 1019;

    /**
     * 才艺发送失败
     */
    private static final int EVENT_TALENT_SENT_FAIL = 1020;

    /**
     * 接收才艺消息
     */
    private static final int EVENT_REC_TALENT_NOTICE = 1021;

    //整个view的父，用于解决软键盘等监听
    public SoftKeyboradListenFrameLayout flContentBody;
    public LiveRoomScrollView lrsv_roomBody;
    public RoomThemeManager roomThemeManager = new RoomThemeManager();

    //--------------------------------直播间头部视图层--------------------------------
    protected View view_roomHeader;
    //    private ImageView iv_roomHeaderBg;
    private LiveRoomHeaderBezierView lrhbv_flag;
    //主播信息
    private CircleImageView civ_hostIcon;
    private TextView tv_hostName;
    private TextView tv_roomFlag;
    private ImageView iv_follow;
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
    protected LinearLayout llHeaderHangout;
    protected TextView tvInviteTips;        //邀请状态处理

    //返点
    private TextView tv_rebateTips;
    private TextView tv_rebateValue;
    private View ll_rebate;
    private View view_roomHeader_buttomLine;
    private RoomRebateTipsPopupWindow roomRebateTipsPopupWindow;

    //---------------------消息编辑区域--------------------------------------
    private View rl_inputMsg;
    private LinearLayout ll_input_edit_body;
    private LinearLayout ll_roomEditMsgiInput;
    private ImageView iv_msgType;
    private ImageView v_roomEditMegBg;
    private EditText et_liveMsg;
    private ImageView iv_sendMsg;
    private EmojiTabScrollLayout etsl_emojiContainer;
    private EmotionItem chooseEmotionItem = null;
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
    protected GiftRecommandManager giftRecommandManager;
    //礼物列表
    private LiveGiftDialog liveGiftDialog;
    //大礼物
    private SimpleDraweeView advanceGift;

    private GiftItem lastRecommendGiftItem;

    private boolean hasShowCreditsLackTips = false;

    //视频播放
    protected ImageView iv_vedioBg;
    public GLSurfaceView sv_player;
    private View rl_media;
    private View imBody;
    protected View include_audience_area;
    private LivePlayerManager mLivePlayerManager;
    protected SimpleDraweeView sdv_vedioLoading;
    protected VedioLoadingAnimManager vedioLoadingAnimManager;

    //座驾
    protected LinearLayout ll_entranceCar;

    //私密预约按钮
    protected View ll_privateLive;
    protected LinearLayout llPrivateStart;
    protected LinearLayout llHangoutStart;
    protected TextView tv_enterPrvRoomTimerCount;
    protected LinearLayout ll_enterPriRoomTimeCount;
    private int leavingRoomTimeCount = 30;//30-default

    //男士互动区域
    protected View includePublish;
    protected GLSurfaceView svPublisher;
    protected FrameLayout flPublishOperate;
    protected ImageView iv_publishstart;
    protected ImageView iv_publishstop;
    protected ImageView iv_publishsoundswitch;
    protected ProgressBar publishLoading;
    protected View view_gaussian_blur_me;
    //    protected ImageView iv_gaussianBlur;
    protected SimpleDraweeView iv_gaussianBlur;
    protected View v_gaussianBlurFloat;

    //------------直播间底部---------------
    protected ImageView iv_freePublicBg1;
    protected ImageView iv_freePublicBg2;
    protected View ll_buttom_audience;
    protected TextView tv_inputMsg;
    protected ImageView iv_gift;
    protected ImageView iv_recommendGift;
    protected ImageView iv_talent;
    protected ImageView iv_recommGiftFloat;
    protected View fl_recommendGift;
    protected AnimationDrawable mAnimationDrawableTalent;

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

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        TAG = BaseCommonLiveRoomActivity.class.getName();
        super.onCreate(savedInstanceState);

        //直播间中不熄灭屏幕
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON,
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

        setContentView(R.layout.activity_live_room);

        //初始化房间礼物管理器
        if (mIMRoomInItem != null) {
            mRoomGiftManager = new RoomGiftManager(mIMRoomInItem);
        }

        initViews();
        if (null != mIMRoomInItem) {
            initData();
            GiftSender.getInstance().currRoomId = mIMRoomInItem.roomId;
        }
        initRoomGiftDataSet();
        GiftSendReqManager.getInstance().executeNextReqTask();
        ChatEmojiManager.getInstance().getEmojiList(null);
        //同步模块直播进行中
        String targetId = "";
        if (mIMRoomInItem != null) {
            targetId = mIMRoomInItem.userId;
        }
        //才艺点播
        initTalentManager();

        //邀请管理器
        mHangoutInvitationManager = HangoutInvitationManager.createInvitationClient(this);
        mHangoutInvitationManager.setClientEventListener(this);
    }

    private void initViews() {
        Log.d(TAG, "initViews");
        //解决软键盘关闭的监听问题
        flContentBody = (SoftKeyboradListenFrameLayout) findViewById(R.id.flContentBody);
        flContentBody.setInputWindowListener(this);
        lrsv_roomBody = (LiveRoomScrollView) findViewById(R.id.lrsv_roomBody);
        //邀请中提示文字区域
        tvInviteTips = (TextView)findViewById(R.id.tvInviteTips);

        initRoomHeader();
        if (null != mIMRoomInItem) {
            initRoomViewDataAndStyle();
        }
        imBody = findViewById(R.id.include_im_body);
        initVideoPlayer();
        initRebateView();
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
    public void initData() {
        if (null != mIMRoomInItem) {
            //添加主播头像信息,方便web端主播送礼时客户端能够在小礼物动画上展示其头像
            mIMManager.updateOrAddUserBaseInfo(mIMRoomInItem.userId,
                    mIMRoomInItem.nickName, mIMRoomInItem.photoUrl);
        }
        //添加试用券使用提示
        if (null != mIMRoomInItem && mIMRoomInItem.usedVoucher) {
            Log.d(TAG, "initData-mIMRoomInItem.usedVoucher:" + mIMRoomInItem.usedVoucher);
            showThreeSecondTips(String.format(getResources().getString(R.string.liveroom_paypublic_usedVoucher), String.valueOf(mIMRoomInItem.useCoupon)), Gravity.CENTER);
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
//            ll_rebate.setVisibility(View.INVISIBLE);
            if (null != vedioLoadingAnimManager) {
                vedioLoadingAnimManager.showLoadingAnim();
            }
        }
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
        } else if (i == R.id.tv_inputMsg) {
            ll_buttom_audience.setVisibility(View.GONE);
            rl_inputMsg.setVisibility(View.VISIBLE);
            showSoftInput(et_liveMsg);
        } else if (i == R.id.iv_msgType) {
            switchEditType();
        } else if (i == R.id.iv_emojiSwitch) {//处理表情view顶起后的输入框跟随顶起逻辑--用户端
            etsl_emojiContainer.measure(0, 0);
            if (View.GONE == etsl_emojiContainer.getVisibility()) {
                isEmojiOpera = true;
                //隐藏软键盘，但仍保持et_liveMsg获取焦点
                hideSoftInput(et_liveMsg, true);
                etsl_emojiContainer.setVisibility(View.VISIBLE);
                iv_emojiSwitch.setImageDrawable(getResources().getDrawable(R.drawable.ic_liveroom_softdisk));
            } else {
                isEmojiOpera = true;
                etsl_emojiContainer.setVisibility(View.GONE);
                iv_emojiSwitch.setImageDrawable(getResources().getDrawable(R.drawable.ic_liveroom_emojiswitch));
                showSoftInput(et_liveMsg);
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
        } else if (i == R.id.view_roomHeader || i == R.id.rl_media || i == R.id.fl_imMsgContainer) {//点击界面区域关闭键盘或者点赞处理
            if (isSoftInputOpen) {
                hideSoftInput(et_liveMsg, true);
            } else if (etsl_emojiContainer.getVisibility() == View.VISIBLE) {
                etsl_emojiContainer.setVisibility(View.GONE);
                iv_emojiSwitch.setImageDrawable(getResources().getDrawable(R.drawable.ic_liveroom_emojiswitch));
                hideSoftInput(et_liveMsg, true);
                onSoftKeyboardHide();
            }
            playRoomHeaderInAnim();

        } else if (i == R.id.et_liveMsg) {
            if (etsl_emojiContainer.getVisibility() == View.VISIBLE) {
                etsl_emojiContainer.setVisibility(View.GONE);
                iv_emojiSwitch.setImageDrawable(getResources().getDrawable(R.drawable.ic_liveroom_emojiswitch));
            }
        } else if (i == R.id.iv_follow || i == R.id.iv_followPrvHost) {
            sendFollowHostReq();

            //GA点击关注
            onAnalyticsEvent(getResources().getString(R.string.Live_Broadcast_Category),
                    getResources().getString(R.string.Live_Broadcast_Action_Follow),
                    getResources().getString(R.string.Live_Broadcast_Label_Follow));

        } else if (i == R.id.iv_closeLiveRoom || i == R.id.ll_closeLiveRoom) {
            userCloseRoom();
        } else if (i == R.id.iv_publishstart) {
            if (!isHasPermission) {
                doShowPublishNoPermissionDialog();
                return;
            }

            if (System.currentTimeMillis() - mPublishStartlastClickTime > PUBLIC_CLICK_TIME) {//判断距离上次点击小于2秒
                mPublishStartlastClickTime = System.currentTimeMillis();//记录这次点击时间
                publishStart();
            }
        } else if (i == R.id.iv_publishstop) {
            if (System.currentTimeMillis() - mPublishEndlastClickTime > PUBLIC_CLICK_TIME) {//判断距离上次点击小于2秒
                mPublishEndlastClickTime = System.currentTimeMillis();//记录这次点击时间
                startOrStopVideoInteraction();
            }
        } else if (i == R.id.iv_publishsoundswitch) {
            setPublishMute();
        } else if (i == R.id.includePublish) {
            refreshPublishViews();
        } else if (i == R.id.iv_gift) {
            showLiveGiftDialog("");
            //GA点击打开礼物列表
            onAnalyticsEvent(getResources().getString(R.string.Live_Broadcast_Category),
                    getResources().getString(R.string.Live_Broadcast_Action_GiftList),
                    getResources().getString(R.string.Live_Broadcast_Label_GiftList));

        } else if (i == R.id.fl_recommendGift || i == R.id.iv_recommGiftFloat || i == R.id.iv_recommendGift) {
            String recommandGiftId = "";
            if (lastRecommendGiftItem != null) {
                recommandGiftId = lastRecommendGiftItem.id;
            }
            showLiveGiftDialog(recommandGiftId);
            //GA推荐礼物点击
            onAnalyticsEvent(getResources().getString(R.string.Live_Broadcast_Category),
                    getResources().getString(R.string.Live_Broadcast_Action_RecommendGift),
                    getResources().getString(R.string.Live_Broadcast_Label_RecommendGift));
        } else if (i == R.id.iv_intimacyPrv) {
            startActivity(WebViewActivity.getIntent(this,
                    getResources().getString(R.string.live_intimacy_title_h5),
                    WebViewActivity.UrlIntent.View_Audience_Intimacy_With_Anchor,
                    mIMRoomInItem.userId,
                    true));
        } else if (i == R.id.iv_talent) {
            if (null != mIMRoomInItem) {
                talentManager.showTalentsList(this, flContentBody);
            }
            //GA点击才艺点播
            onAnalyticsEvent(getResources().getString(R.string.Live_Broadcast_Category),
                    getResources().getString(R.string.Live_Broadcast_Action_Talent),
                    getResources().getString(R.string.Live_Broadcast_Label_Talent));
        } else if (i == R.id.llPrivateStart) {
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
        }else if (i == R.id.llHangoutStart) {
            //点击，弹出start hangout 提示
            FragmentManager fragmentManager = getSupportFragmentManager();
            HangoutOnlineAnchorItem anchorInfoItem = new HangoutOnlineAnchorItem();
            anchorInfoItem.anchorId = mIMRoomInItem.userId;
            anchorInfoItem.nickName = mIMRoomInItem.nickName;
            anchorInfoItem.avatarImg = mIMRoomInItem.photoUrl;
            HangOutDetailDialogFragment.showDialog(fragmentManager, anchorInfoItem, new HangOutDetailDialogFragment.OnDialogClickListener() {
                @Override
                public void onStartHangoutClick(final HangoutOnlineAnchorItem anchorItem) {
                    String url = URL2ActivityManager.createHangoutTransitionActivity(anchorItem.anchorId, anchorItem.nickName);
                    new AppUrlHandler(mContext).urlHandle(url);
                }
            });
        }
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        switch (msg.what) {
            case EVENT_UPDATE_RECOMMANDGIFT:
                //更新推荐礼物btn,并标记当前推荐礼物,点击推荐礼物，打开礼物列表弹框，选中并跳转显示该推荐礼物
                if ((lastRecommendGiftItem != null) && !TextUtils.isEmpty(lastRecommendGiftItem.middleImgUrl)) {
                    String localImgPath = FileCacheManager.getInstance()
                            .getGiftLocalPath(lastRecommendGiftItem.id, lastRecommendGiftItem.middleImgUrl);
                    boolean localFileExists = SystemUtils.fileExists(localImgPath);
                    Log.d(TAG, "EVENT_UPDATE_RECOMMANDGIFT-localImgPath:" + localImgPath + " localFileExists:" + localFileExists);
                    if (localFileExists) {
                        iv_recommendGift.setImageBitmap(ImageUtil.toRoundBitmap(ImageUtil.decodeSampledBitmapFromFile(
                                localImgPath, DisplayUtil.dip2px(mContext, 39f),
                                DisplayUtil.dip2px(mContext, 39f))));
                    } else {
                        FileDownloadManager.getInstance().start(lastRecommendGiftItem.middleImgUrl, localImgPath, new IFileDownloadedListener() {
                            @Override
                            public void onCompleted(boolean isSuccess, String localFilePath, String fileUrl) {
                                if (isSuccess) {
                                    sendEmptyUiMessage(EVENT_UPDATE_RECOMMANDGIFT);
                                }
                            }

                            @Override
                            public void onProgress(String fileUrl, int progress) {

                            }
                        });
                    }
                }
                break;
            case EVENT_INTIMACY_LEVEL_UPDATE: {
                if (null != roomThemeManager && null != mIMRoomInItem) {
                    Drawable lovelLevelDrawable = roomThemeManager.getPrivateRoomLoveLevelDrawable(this, mIMRoomInItem.loveLevel);
                    if (null != lovelLevelDrawable) {
                        iv_intimacyPrv.setImageDrawable(lovelLevelDrawable);
                    }
                }

                //更新礼物列表显示
                if (liveGiftDialog != null && (mIMRoomInItem != null)) {
                    liveGiftDialog.updateRoomInfo(mIMRoomInItem);
                }
            }
            break;
            case EVENT_MAN_LEVEL_UPDATE: {
                //用户等级升级，通知礼物列表
                if (liveGiftDialog != null && (mIMRoomInItem != null)) {
                    liveGiftDialog.updateRoomInfo(mIMRoomInItem);
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
                        Log.i("Jagger" , "BaseCommonLiveRoomActivity EVENT_LEAVING_ROOM_TIMECOUNT book:" + (mAuthorityItem == null?"null":mAuthorityItem.isHasBookingAuth));
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
                if (null != liveGiftDialog) {
                    liveGiftDialog.notifyGiftSentFailed();
                }
                break;
            case EVENT_GIFT_SEND_FAILED_CREDITS_NOENOUGH:
                //非豪华非背包礼物，发送失败(信用点不足)，弹充值对话框，清理发送队列，关闭倒计时动画
                showCreditNoEnoughDialog(R.string.live_common_noenough_money_tips);
                if (null != liveGiftDialog) {
                    liveGiftDialog.notifyGiftSentFailed();
                }
                break;
            case EVENT_FAVORITE_RESULT:
                HttpRespObject hrObject = (HttpRespObject) msg.obj;
                onRecvFollowHostResp(hrObject.isSuccess, hrObject.errMsg);
                break;

            case EVENT_MESSAGE_ENTERROOMNOTICE: {
                final CarInfo carInfo = (CarInfo) msg.obj;
                if (!TextUtils.isEmpty(carInfo.riderUrl) && !TextUtils.isEmpty(carInfo.riderId)
                        && !TextUtils.isEmpty(carInfo.riderName)) {
                    //聊天区域插入座驾进入直播间消息
                    boolean playCarInAnimAfterDownImg = msg.getData().getBoolean("playCarInAnimAfterDownImg", false);
                    //避免首次未下载座驾img，下载成功后回调重复生成入场消息
                    if (!playCarInAnimAfterDownImg) {
                        IMMessageItem msgItem = new IMMessageItem(mIMRoomInItem.roomId,
                                mIMManager.mMsgIdIndex.getAndIncrement(),
                                carInfo.userId,
                                carInfo.nickName,
                                null,
                                mIMRoomInItem.manLevel,
                                IMMessageItem.MessageType.RoomIn,
                                new IMTextMessageContent(String.format(getResources().getString(R.string.enterlive_withrider), carInfo.riderName)),
                                null
                        );
                        sendMessageUpdateEvent(msgItem);
                    }
                    //判断并播放入场座驾动画
                    carInfo.riderLocalPath = FileCacheManager.getInstance()
                            .parseCarImgLocalPath(carInfo.riderId, carInfo.riderUrl);
                    Log.d(TAG, "EVENT_MESSAGE_ENTERROOMNOTICE-riderId:" + carInfo.riderId
                            + " riderLocalPath:" + carInfo.riderLocalPath);
                    if (TextUtils.isEmpty(carInfo.riderLocalPath)) {
                        return;
                    }
                    boolean localCarImgExists = SystemUtils.fileExists(carInfo.riderLocalPath);
                    Log.d(TAG, "EVENT_MESSAGE_ENTERROOMNOTICE-localCarImgExists:" + localCarImgExists);
                    if (localCarImgExists) {
                        if (null != carManager) {
                            carManager.putLiveRoomCarInfo(carInfo);
                        }
                    } else {
                        FileDownloadManager.getInstance().start(carInfo.riderUrl, carInfo.riderLocalPath,
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
                                            bundle.putBoolean("playCarInAnimAfterDownImg", true);
                                            msg.setData(bundle);
                                            sendUiMessage(msg);

                                        }
                                    }

                                    @Override
                                    public void onProgress(String fileUrl, int progress) {

                                    }
                                });
                    }
                }

            }
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
                if(talentInfoItem != null){
                    String msgStr;
                    String talentName ;
                    talentName = talentInfoItem.talentName;
                    msgStr = getString(R.string.live_talent_request_success , talentName);

                    IMMessageItem talentMsgItem = new IMMessageItem(mIMRoomInItem.roomId,
                            mIMManager.mMsgIdIndex.getAndIncrement(),
                            "",
                            IMMessageItem.MessageType.SysNotice,
                            new IMSysNoticeMessageContent(msgStr,"", IMSysNoticeMessageContent.SysNoticeType.Normal));
                            sendMessageUpdateEvent(talentMsgItem);
                }
                break;
            case EVENT_TALENT_SENT_FAIL:
                if(msg.arg1 > -1 && msg.arg1 < IMClientListener.LCC_ERR_TYPE.values().length){
                    IMClientListener.LCC_ERR_TYPE errType = IMClientListener.LCC_ERR_TYPE.values()[msg.arg1];

                    if(LCC_ERR_NO_CREDIT == errType){
                        //信用点不足
                        showCreditNoEnoughDialog(R.string.live_common_noenough_money_tips);
                    }else{
                        //房间错误
//                            if(LCC_ERR_ROOM_CLOSE == errType || LCC_ERR_NOT_FOUND_ROOM == errType){
//                                msg = mActivity.getString(R.string.live_talent_request_failed_room_closing);
//                            }else{
//                                msg = mActivity.getString(R.string.live_talent_request_failed);
//                            }
                        //其它错误使用服务器返回信息
                        String errMsg = (String) msg.obj;
                        if(TextUtils.isEmpty(errMsg)){
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
                if(talentInviteItem.inviteStatus == TalentInviteItem.TalentInviteStatus.Accept){
                    msgRecTalentNotice = getString(R.string.live_talent_accepted , nickName ,talentInviteItem.name);

                    //add by Jagger 2018-5-31 需求增加同时播放大礼物
                    IMMessageItem msgGiftItemRecTalent = new IMMessageItem(mIMRoomInItem.roomId,
                            mIMManager.mMsgIdIndex.getAndIncrement(),
                            "",
                            "",
                            "",
                            0,
                            IMMessageItem.MessageType.Gift,
                            null,
                            new IMGiftMessageContent(talentInviteItem.giftId , "" , talentInviteItem.giftNum , false , -1 , -1, -1 )
                    );
                    sendMessageShowGiftEvent(msgGiftItemRecTalent);
                }else if(talentInviteItem.inviteStatus == TalentInviteItem.TalentInviteStatus.Denied){
                    msgRecTalentNotice = getString(R.string.live_talent_declined , nickName ,talentInviteItem.name);
                }
                if(!TextUtils.isEmpty(msgRecTalentNotice)){
                    IMMessageItem msgItemRecTalent = new IMMessageItem(mIMRoomInItem.roomId,
                            mIMManager.mMsgIdIndex.getAndIncrement(),
                            "",
                            IMMessageItem.MessageType.SysNotice,
                            new IMSysNoticeMessageContent(msgRecTalentNotice,"", IMSysNoticeMessageContent.SysNoticeType.Normal));
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

    @Override
    protected void onDestroy() {
        super.onDestroy();

        //停止才艺动画
        if (mAnimationDrawableTalent != null && mAnimationDrawableTalent.isRunning()) {
            mAnimationDrawableTalent.stop();
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

        if(tpManager != null) {
            tpManager.clear();
        }
        if(carManager != null) {
            carManager.shutDownAnimQueueServNow();
            carManager = null;
        }
        if(mModuleGiftManager != null) {
            mModuleGiftManager.onMultiGiftDestroy();
        }
        //清除资源及动画
        if (mBarrageManager != null) {
            mBarrageManager.onDestroy();
        }
        //退出房间成功，就清空送礼队列，并停止服务
        GiftSendReqManager.getInstance().shutDownReqQueueServNow();

        //推荐礼物
        if (null != mRoomGiftManager) {
            mRoomGiftManager.onDestroy();
        }

        //del by Jagger 2017-12-1
        //清除互动相关
//        onPublisherDestroy();

        //清理资费提示manager
        if (mIMRoomInItem.roomType != IMLiveRoomType.FreePublicRoom) {
            if(roomRebateTipsPopupWindow != null) {
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
        if (liveGiftDialog != null) {
            liveGiftDialog.onDestroy();
            // 2018/12/28 Hardy
            liveGiftDialog = null;
        }

        //
        if(talentManager != null ) {
            talentManager.unregisterOnTalentEventListener(mTalentEventListener);
        }

        //Hang-out回收
        if(mHangoutInvitationManager != null){
            mHangoutInvitationManager.release();
        }
        if(mHangoutInviteMap != null) {
            mHangoutInviteMap.clear();
        }
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
            showSimpleTipsDialog(R.string.liveroom_close_room_notify,
                    R.string.live_common_btn_no, R.string.live_common_btn_yes,
                    new SimpleDoubleBtnTipsDialog.OnTipsDialogBtnClickListener() {
                        @Override
                        public void onCancelBtnClick() {

                        }

                        @Override
                        public void onConfirmBtnClick() {
                            closeRoomByUser = true;
                            closeLiveRoom(true);
                        }
                    });
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
                    tpManager.getRoomTariffInfo(BaseCommonLiveRoomActivity.this);
                }
                Message msg = Message.obtain();
                msg.what = EVENT_MESSAGE_HIDE_TARIFFPROMPT;
                sendUiMessageDelayed(msg, 3000l);
            }
        }
    };

    private void initRoomHeader() {
        view_roomHeader = findViewById(R.id.view_roomHeader);
        view_roomHeader.setOnClickListener(this);
//        iv_roomHeaderBg = (ImageView) findViewById(R.id.iv_roomHeaderBg);
        lrhbv_flag = (LiveRoomHeaderBezierView) findViewById(R.id.lrhbv_flag);
        iv_roomFlag = (ImageView) findViewById(R.id.iv_roomFlag);
        FrameLayout.LayoutParams roomFlagLp = (FrameLayout.LayoutParams) iv_roomFlag.getLayoutParams();
        findViewById(R.id.ll_closeLiveRoom).setOnClickListener(this);
//        view_roomHeader.measure(0,0);
        if (null != mIMRoomInItem) {
//            FrameLayout.LayoutParams lp1 = (FrameLayout.LayoutParams)iv_roomHeaderBg.getLayoutParams();
//            lp1.height = view_roomHeader.getMeasuredHeight();
//            iv_roomHeaderBg.setLayoutParams(lp1);
            iv_roomFlag.setImageDrawable(roomThemeManager.getRoomFlagDrawable(this, mIMRoomInItem.roomType));
//            roomFlagLp.height =roomThemeManager.getRoomFlagHeight(this,mIMRoomInItem.roomType);
//            roomFlagLp.topMargin = roomThemeManager.getRoomFlagTopMargin(this,mIMRoomInItem.roomType);
//            roomFlagLp.bottomMargin = roomThemeManager.getRoomFlagBottomMargin(this,mIMRoomInItem.roomType);
//            iv_roomFlag.setLayoutParams(roomFlagLp);
//
        }
//        iv_roomFlag.measure(0,0);
        //资费提示
        view_tariff_prompt = findViewById(R.id.view_tariff_prompt);
        view_tariff_prompt.setVisibility(View.GONE);
//        FrameLayout.LayoutParams tpLp = (FrameLayout.LayoutParams) view_tariff_prompt.getLayoutParams();
//        tpLp.topMargin += view_roomHeader.getMeasuredHeight()-roomFlagLp.bottomMargin;
//        tpLp.width = iv_roomFlag.getMeasuredWidth()*3/2;
//        view_tariff_prompt.setLayoutParams(tpLp);
//        btn_OK = (Button) findViewById(R.id.btn_OK);
//        btn_OK.setOnClickListener(tpOKClickListener);
//        iv_roomFlag.setOnClickListener(roomFlagClickListener);
        tpManager = new TariffPromptManager(this);
        tv_triffMsg = (TextView) findViewById(R.id.tv_triffMsg);
//        if(null != mIMRoomInItem){
//            tpManager.init(mIMRoomInItem).getRoomTariffInfo(this);
//        }

        //---公开直播间----
        ll_publicRoomHeader = (LinearLayout) findViewById(R.id.ll_publicRoomHeader);
        ll_publicRoomHeader.setVisibility(View.GONE);
        ll_hostInfoView = findViewById(R.id.ll_hostInfoView);
        civ_hostIcon = (CircleImageView) findViewById(R.id.civ_hostIcon);
        civ_hostIcon.setOnClickListener(this);
        iv_follow = (ImageView) findViewById(R.id.iv_follow);
        iv_follow.setOnClickListener(this);
        tv_hostName = (TextView) findViewById(R.id.tv_hostName);
        tv_hostName.setOnClickListener(this);
        tv_roomFlag = (TextView) findViewById(R.id.tv_roomFlag);

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
//        if(null != mIMRoomInItem){
//            LinearLayout.LayoutParams buttomLineLp = (LinearLayout.LayoutParams) view_roomHeader_buttomLine.getLayoutParams();
//            buttomLineLp.height = roomThemeManager.getRoomHeadViewButtomLineHeight(this,mIMRoomInItem.roomType);
//            view_roomHeader_buttomLine.setLayoutParams(buttomLineLp);
//        }

        iv_closeLiveRoom = (ImageView) findViewById(R.id.iv_closeLiveRoom);

        //新增hangout按钮
        llHeaderHangout = (LinearLayout)findViewById(R.id.llHeaderHangout);
        llHeaderHangout.setOnClickListener(this);
        showHangoutPrivateButton();
    }

    private void initRoomViewDataAndStyle() {
        int color = roomThemeManager.getRootViewTopColor(mIMRoomInItem.roomType);
//        StatusBarUtil.setColor(this,color,0);
//        lrhbv_flag.setRoomHeaderBgColor(color);
//        iv_roomHeaderBg.setImageDrawable(roomThemeManager.getRoomHeaderViewBgDrawable(this,mIMRoomInItem.roomType));
        ll_hostInfoView.setBackgroundDrawable(roomThemeManager.getRoomHeaderHostInfoViewBg(this, mIMRoomInItem.roomType));
        tv_roomFlag.setText(getResources().getString(roomThemeManager.getRoomHeaderRoomFlagStrResId(mIMRoomInItem.roomType)));
        view_roomHeader_buttomLine.setBackgroundDrawable(roomThemeManager.getRoomHeadDeviderLineDrawable(mIMRoomInItem.roomType));
        flContentBody.setBackgroundDrawable(roomThemeManager.getRoomThemeDrawable(this, mIMRoomInItem.roomType));
        if (null != mIMRoomInItem && !TextUtils.isEmpty((mIMRoomInItem.photoUrl))) {
            //主播的头像是过渡页面带进来的，所以IMManager.getUserInfo拿到的同mIMRoomInItem的一样的
//            Picasso.with(getApplicationContext())
//                    .load(mIMRoomInItem.photoUrl)
//                    .error(R.drawable.ic_default_photo_woman)
//                    .placeholder(R.drawable.ic_default_photo_woman)
//                    .memoryPolicy(MemoryPolicy.NO_CACHE)
//                    .into(civ_hostIcon);
            PicassoLoadUtil.loadUrlNoMCache(civ_hostIcon, mIMRoomInItem.photoUrl, R.drawable.ic_default_photo_woman);
        }
        if (mIMRoomInItem.roomType == IMLiveRoomType.NormalPrivateRoom
                || mIMRoomInItem.roomType == IMLiveRoomType.AdvancedPrivateRoom) {
//            iv_prvUserIconBg.setImageDrawable(
//                    roomThemeManager.getPrivateRoomUserIconBg(this,mIMRoomInItem.roomType));
//            iv_prvHostIconBg.setImageDrawable(
//                    roomThemeManager.getPrivateRoomHostIconBg(this,mIMRoomInItem.roomType));
            if (null != mIMRoomInItem && !TextUtils.isEmpty((mIMRoomInItem.photoUrl))) {
                //主播的头像是过渡页面带进来的，所以IMManager.getUserInfo拿到的同mIMRoomInItem的一样的
//                Picasso.with(getApplicationContext())
//                        .load(mIMRoomInItem.photoUrl)
//                        .error(R.drawable.ic_default_photo_woman)
//                        .placeholder(R.drawable.ic_default_photo_woman)
//                        .memoryPolicy(MemoryPolicy.NO_CACHE)
//                        .into(civ_prvHostIcon);
                PicassoLoadUtil.loadUrlNoMCache(civ_prvHostIcon, mIMRoomInItem.photoUrl, R.drawable.ic_default_photo_woman);
            }

            if (null != mIMManager && null != loginItem) {
                //自己的通过3.12接口缓存的数据更新
                IMUserBaseInfoItem imUserBaseInfoItem = mIMManager.getUserInfo(loginItem.userId);
                if (null != imUserBaseInfoItem && !TextUtils.isEmpty(imUserBaseInfoItem.photoUrl)) {
//                    Picasso.with(getApplicationContext())
//                            .load(imUserBaseInfoItem.photoUrl)
//                            .error(R.drawable.ic_default_photo_man)
//                            .placeholder(R.drawable.ic_default_photo_man)
//                            .into(civ_prvUserIcon);
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
        tv_hostName.setText(getResources().getString(R.string.live_room_host_nickname_tips, mIMRoomInItem.nickName));

        //是否已经关注
        onRecvFollowHostResp(mIMRoomInItem.isFavorite, "");
        //根据直播间类型更换关闭直播间按钮图标
        iv_closeLiveRoom.setImageDrawable(roomThemeManager.getCloseRoomImgResId(this, mIMRoomInItem.roomType));
    }

    protected void updatePublicRoomOnlineData(int fansNum) {
        Log.d(TAG, "updatePublicRoomOnlineData-fansNum:" + fansNum);
        tv_onlineNum.setVisibility(fansNum > 0 ? View.GONE : View.GONE);
        tv_onlineNum.setText(String.valueOf(fansNum));
        tv_vipGuestData.setText(getResources().getString(R.string.liveroom_header_vipguestdata,
                String.valueOf(fansNum), String.valueOf(mIMRoomInItem.audienceLimitNum)));
        //查询头像列表
        LiveRequestOperator.getInstance().GetAudienceListInRoom(mIMRoomInItem.roomId, 0, 0, this);
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
        AnchorProfileActivity.launchAnchorInfoActivty(this,
                getResources().getString(R.string.live_webview_anchor_profile_title),
                mIMRoomInItem.userId, false, AnchorProfileActivity.TagType.Album);
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
        iv_follow.setVisibility(isSuccess ? View.GONE : View.VISIBLE);
        iv_followPrvHost.setVisibility(isSuccess ? View.GONE : View.GONE);
    }

    /**
     * 播放房间header的淡入动画
     */
    private void playRoomHeaderInAnim() {
        if (view_roomHeader.getVisibility() == View.GONE) {
            AnimationSet animationSet = (AnimationSet) AnimationUtils.
                    loadAnimation(mContext, R.anim.liveroom_header_in);
            animationSet.setAnimationListener(new Animation.AnimationListener() {
                @Override
                public void onAnimationStart(Animation animation) {
                }

                @Override
                public void onAnimationEnd(Animation animation) {
                    view_roomHeader.setVisibility(View.VISIBLE);
                }

                @Override
                public void onAnimationRepeat(Animation animation) {
                }
            });
            view_roomHeader.startAnimation(animationSet);
        }

    }

    /**
     * 播放房间header的淡入动画
     */
    private void playRoomHeaderOutAnim() {
        if (view_roomHeader.getVisibility() == View.VISIBLE) {
            AnimationSet animationSet = (AnimationSet) AnimationUtils.
                    loadAnimation(mContext, R.anim.liveroom_header_out);
            animationSet.setAnimationListener(new Animation.AnimationListener() {
                @Override
                public void onAnimationStart(Animation animation) {
                }

                @Override
                public void onAnimationEnd(Animation animation) {
                    view_roomHeader.setVisibility(View.GONE);
                }

                @Override
                public void onAnimationRepeat(Animation animation) {
                }
            });
            view_roomHeader.startAnimation(animationSet);
        }
    }

    /**
     * 显示私密直播间Hangout按钮
     */
    private void showHangoutPrivateButton(){
        if (mIMRoomInItem !=  null && (mIMRoomInItem.roomType == IMLiveRoomType.NormalPrivateRoom
                || mIMRoomInItem.roomType == IMLiveRoomType.AdvancedPrivateRoom)){
            //私密直播间且无风控权限，显示多人互动邀请按钮
            LoginItem loginItem = LoginManager.getInstance().getLoginItem();
            //用户没有被风控 且 主播有权限
            if(loginItem != null && !loginItem.isHangoutRisk && mIMRoomInItem.isHangoutPriv){
                llHeaderHangout.setVisibility(View.VISIBLE);
            }else{
                llHeaderHangout.setVisibility(View.GONE);
            }
        }else{
            llHeaderHangout.setVisibility(View.GONE);
        }
    }

    /**
     * 显示公开直播间Hangout按钮
     */
    private void showHangoutPublicButton(){
        if (mIMRoomInItem !=  null && (mIMRoomInItem.roomType == IMLiveRoomType.FreePublicRoom
                || mIMRoomInItem.roomType == IMLiveRoomType.PaidPublicRoom)) {
            LoginItem loginItem = LoginManager.getInstance().getLoginItem();
            //用户没有被风控 且 主播有权限
            if (loginItem != null && !loginItem.isHangoutRisk && mIMRoomInItem.isHangoutPriv) {
                llHangoutStart.setVisibility(View.VISIBLE);
            } else {
                llHangoutStart.setVisibility(View.GONE);
            }
        }else{
            llHangoutStart.setVisibility(View.GONE);
        }
    }

    @Override
    public void OnRoomIn(int reqId, final boolean success, final IMClientListener.LCC_ERR_TYPE errType,
                         String errMsg, final IMRoomInItem roomInfo, final IMAuthorityItem authorityItem) {
        super.OnRoomIn(reqId, success, errType, errMsg, roomInfo, authorityItem);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Log.i("Jagger" , "BaseCommonLiveRoomActivity OnRoomIn book:" + (authorityItem == null?"null":authorityItem.isHasBookingAuth));
                Log.i("Jagger" , "BaseCommonLiveRoomActivity OnRoomIn isHangout:" + (authorityItem == null?"null":roomInfo.isHangoutPriv));
                if (!success && errType != IMClientListener.LCC_ERR_TYPE.LCC_ERR_CONNECTFAIL) {
                    //关闭直播间逻辑
                    endLive(PAGE_ERROR_LIEV_EDN, getString(R.string.liveroom_transition_broadcast_ended), false, false, authorityItem);
                } else {
                    onDisconnectRoomIn();
                    showHangoutPublicButton();
                    showHangoutPrivateButton();
                }
            }
        });
    }

    //******************************** 视频播放组件 ****************************************************************
    private void initVideoPlayer() {
        include_audience_area = findViewById(R.id.include_audience_area);
        iv_vedioBg = (ImageView) findViewById(R.id.iv_vedioBg);
        //视频播放组件
        sv_player = (GLSurfaceView) findViewById(R.id.sv_player);
        //add by Jagger 2017-11-29 解决小窗口能浮在大窗口上的问题
//        sv_player.getHolder().setFormat(PixelFormat.TRANSPARENT);

        rl_media = findViewById(R.id.rl_media);
        rl_media.setOnClickListener(this);

        int screenWidth = DisplayUtil.getScreenWidth(BaseCommonLiveRoomActivity.this);
        int scaleHeight = screenWidth * 3 / 4;
        //具体的宽高比例，其实也可以根据服务器动态返回来控制
        RelativeLayout.LayoutParams svPlayerLp = (RelativeLayout.LayoutParams) sv_player.getLayoutParams();
        RelativeLayout.LayoutParams ivVedioBgLp = (RelativeLayout.LayoutParams) iv_vedioBg.getLayoutParams();
        LinearLayout.LayoutParams rlMediaLp = (LinearLayout.LayoutParams) rl_media.getLayoutParams();
        view_roomHeader.measure(0, 0);
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

        //初始化播放器
        mLivePlayerManager = new LivePlayerManager(this);
        mLivePlayerManager.init(LivePlayerManager.createPlayerRenderBinder(sv_player));
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
                                drawable = roomThemeManager.getRoomCreditsBgDrawable(BaseCommonLiveRoomActivity.this,
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

    /**
     * 初始化礼物配置
     */
    public void initRoomGiftDataSet() {
        if (mRoomGiftManager != null) {
            //刷新房间可发送列表
            mRoomGiftManager.getSendableGiftList(null);
            //刷新直播间背包列表
            mRoomGiftManager.getPackageGiftItems(null);
        }
    }

    /**
     * 初始化底部礼物选择界面
     */
    protected void initLiveGiftDialog() {
        if (null == liveGiftDialog) {
            if (mIMRoomInItem != null && mRoomGiftManager != null) {
                liveGiftDialog = new LiveGiftDialog(this, mRoomGiftManager, mIMRoomInItem);
                liveGiftDialog.setLiveGiftDialogEventListener(new LiveGiftDialog.LiveGiftDialogEventListener() {
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
                        showCreditNoEnoughDialog(R.string.live_common_noenough_money_tips);
                    }

                    @Override
                    public void onAudiencBalanceClick(View rootView) {
                        showAudienceBalanceInfoDialog(rootView);
                    }
                });
            }
        }
    }

    /**
     * 显示礼物列表
     *
     * @param recommandGiftId 推荐id可为空
     */
    protected void showLiveGiftDialog(String recommandGiftId) {
        initLiveGiftDialog();
//        liveGiftDialog.show(recommandGiftId);

        // 2018/12/28 Hardy
        if (isActivityVisible()) {
            liveGiftDialog.show(recommandGiftId);
        }
    }

    /**
     * 初始化模块
     */
    private void initMultiGift() {
        FrameLayout viewContent = (FrameLayout) findViewById(R.id.flMultiGift);
        /*礼物模块*/
        ll_bulletScreen = findViewById(R.id.ll_bulletScreen);
        ll_bulletScreen.setVisibility(View.INVISIBLE);
        mModuleGiftManager = new ModuleGiftManager(this);
        mModuleGiftManager.initMultiGift(viewContent, 2);
//        ll_bulletScreen = findViewById(R.id.ll_bulletScreen);
//        ll_bulletScreen.setVisibility(View.INVISIBLE);
//        mModuleGiftManager.showMultiGiftAs(ll_bulletScreen);
        //大礼物
        advanceGift = (SimpleDraweeView) findViewById(R.id.advanceGift);
        mModuleGiftManager.initAdvanceGift(advanceGift);
        //推荐礼物
        if (null != mIMRoomInItem && (mIMRoomInItem.roomType == IMLiveRoomType.NormalPrivateRoom
                || mIMRoomInItem.roomType == IMLiveRoomType.AdvancedPrivateRoom)) {
            //设置绑定礼物推荐监听器
            if (mRoomGiftManager != null) {
                mRoomGiftManager.setOnGiftRecommandListener(this);
            }
        }
    }

    /**
     * 启动消息动画
     *
     * @param msgItem
     */
    private void launchAnimationByMessage(IMMessageItem msgItem) {
        if (msgItem != null) {
            switch (msgItem.msgType) {
                case Barrage: {
                    addBarrageItem(msgItem);
                }
                break;
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
        //max确认暂时屏蔽刷新功能
//        if(null!= mRoomGiftManager){
//            //背包更新通知，刷新直播间背包列表
//            mRoomGiftManager.getPackageGiftItems(null);
//        }
    }

    @Override
    public void onGiftRecommand(final GiftItem giftItem) {
        //获取到推荐礼物
        lastRecommendGiftItem = giftItem;
        sendEmptyUiMessage(EVENT_UPDATE_RECOMMANDGIFT);
    }

    @Override
    public void OnRecvRoomGiftNotice(IMMessageItem msgItem) {
        if (!isCurrentRoom(msgItem.roomId)) {
            return;
        }
        super.OnRecvRoomGiftNotice(msgItem);
        sendMessageUpdateEvent(msgItem);
    }

    //******************************** 预约私密直播 **************************************************
    private void initPrePriView() {
        ll_privateLive = findViewById(R.id.ll_privateLive);
        ll_privateLive.setVisibility(View.GONE);
        llPrivateStart = (LinearLayout) findViewById(R.id.llPrivateStart);
        llHangoutStart = (LinearLayout) findViewById(R.id.llHangoutStart);

        ll_enterPriRoomTimeCount = (LinearLayout) findViewById(R.id.ll_enterPriRoomTimeCount);
        llPrivateStart.setOnClickListener(this);
        llHangoutStart.setOnClickListener(this);
        ll_enterPriRoomTimeCount.setVisibility(View.GONE);
        tv_enterPrvRoomTimerCount = (TextView) findViewById(R.id.tv_enterPrvRoomTimerCount);

        showOrResetStartButtons();

        //启动私密邀请风控
        if(mAuthorityItem != null && mAuthorityItem.isHasOneOnOneAuth){
            llPrivateStart.setVisibility(View.VISIBLE);
        }else{
            llPrivateStart.setVisibility(View.GONE);
        }

        //hangout风控处理
        showHangoutPublicButton();
    }

    /**
     * 根据直播间类型及风控等控制直播间按钮区域的显示问题
     */
    private void showOrResetStartButtons(){
        if (null != mIMRoomInItem) {
            if ((IMLiveRoomType.FreePublicRoom == mIMRoomInItem.roomType || IMLiveRoomType.PaidPublicRoom == mIMRoomInItem.roomType)
                    && mIMRoomInItem.liveShowType != IMRoomInItem.IMPublicRoomType.Program) {   //add by Jagger 2018-12-5 增加私密权限判断
                ll_privateLive.setVisibility(View.VISIBLE);
            } else {
                ll_privateLive.setVisibility(View.GONE);
            }
        }
    }

    /**
     * 隐藏按钮区域
     */
    private void hideStartButtons(){
        if(ll_privateLive != null){
            ll_privateLive.setVisibility(View.GONE);
        }
    }

    //******************************** 入场座驾 ******************************************************
    protected CarManager carManager = new CarManager();

    private void initLiveRoomCar() {
//        FrameLayout.LayoutParams lp = (FrameLayout.LayoutParams) ll_rebate.getLayoutParams();
//        ll_rebate.measure(0,0);
//        int mH = ll_rebate.getMeasuredHeight();
        ll_entranceCar = (LinearLayout) findViewById(R.id.ll_entranceCar);
        carManager.init(this, ll_entranceCar,
                roomThemeManager.getRoomCarViewTxtColor(mIMRoomInItem.roomType),
                roomThemeManager.getRoomCarViewBgDrawableResId(mIMRoomInItem.roomType));
    }

    private void initRebateView() {
        //ll_rebate从原本的im浮层布局移到
        ll_rebate = findViewById(R.id.ll_rebate);
        view_roomHeader.measure(0, 0);
//        int roomHeaderMeasuredHeight = view_roomHeader.getMeasuredHeight();
//        FrameLayout.LayoutParams lp = (FrameLayout.LayoutParams)ll_rebate.getLayoutParams();
//        lp.topMargin+=roomHeaderMeasuredHeight;
//        ll_rebate.setLayoutParams(lp);
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
//                                Picasso.with(getApplicationContext())
//                                        .load(audienceInfo.photoUrl)
//                                        .error(R.drawable.ic_default_photo_man)
//                                        .placeholder(R.drawable.ic_default_photo_man)
//                                        .into(civ_prvUserIcon);
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
                            new IMTextMessageContent(BaseCommonLiveRoomActivity.this.getResources().getString(R.string.enterlive_norider)), null);
                    msg = Message.obtain();
                    msg.what = EVENT_MESSAGE_UPDATE;
                    msg.obj = msgItem;
                    sendUiMessage(msg);
                }
            });

        }
    }

    //******************************** 弹幕消息编辑区域处理 ********************************************
    private TextWatcher tw_msgEt;
    private static int liveMsgMaxLength = 10;
    private int lastTxtChangedStart = 0;
    private int lastTxtChangedNumb = 0;
    private String lastInputEmoSign = null;

    /**
     * 处理编辑框区域view初始化
     */
    @SuppressWarnings("WrongConstant")
    private void initEditAreaView() {
        liveMsgMaxLength = getResources().getInteger(R.integer.liveMsgMaxLength);
        //共用的软键盘弹起输入部分
        rl_inputMsg = findViewById(R.id.rl_inputMsg);
        ll_input_edit_body = (LinearLayout) findViewById(R.id.ll_input_edit_body);
        v_roomEditMegBg = (ImageView) findViewById(R.id.iv_roomEditMegBg);
        ll_roomEditMsgiInput = (LinearLayout) findViewById(R.id.ll_roomEditMsgiInput);
        iv_msgType = (ImageView) findViewById(R.id.iv_msgType);
        iv_msgType.setOnClickListener(this);
        et_liveMsg = (EditText) findViewById(R.id.et_liveMsg);
        if (null != mIMRoomInItem) {
            iv_msgType.setImageDrawable(roomThemeManager.getRoomMsgTypeSwitchDrawable(this, mIMRoomInItem.roomType, isBarrage));
            et_liveMsg.setHintTextColor(roomThemeManager.getRoomETHintTxtColor(mIMRoomInItem.roomType, isBarrage));
        }
        String editHint = "";
        if (isBarrage) {
            double price = 0.0;
            if (mIMRoomInItem != null) {
                price = mIMRoomInItem.popPrice;
            }
            editHint = String.format(getResources().getString(R.string.txt_hint_input_barrage),
                    ApplicationSettingUtil.formatCoinValue(price));
        } else {
            editHint = getResources().getString(R.string.txt_hint_input_general);
        }
        et_liveMsg.setHint(editHint);
//        et_liveMsg.setHint(isBarrage ? R.string.txt_hint_input_barrage : R.string.txt_hint_input_general);
        et_liveMsg.setOnClickListener(this);
        et_liveMsg.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                Log.d(TAG, "onFocusChange-hasFocus:" + hasFocus);
                if (hasFocus && etsl_emojiContainer.getVisibility() == View.VISIBLE) {
                    etsl_emojiContainer.setVisibility(View.GONE);
                    iv_emojiSwitch.setImageDrawable(getResources().getDrawable(R.drawable.ic_liveroom_emojiswitch));
                }
            }
        });
        iv_sendMsg = (ImageView) findViewById(R.id.iv_sendMsg);
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
                        if (etsl_emojiContainer.getVisibility() == View.VISIBLE && !TextUtils.isEmpty(lastInputEmoSign)) {
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
                        et_liveMsg.setText(s.toString());
                        et_liveMsg.setSelection(outStart);
                        et_liveMsg.addTextChangedListener(tw_msgEt);
                    }
                }
            };
        }
        et_liveMsg.addTextChangedListener(tw_msgEt);
        //Emoji
        etsl_emojiContainer = (EmojiTabScrollLayout) findViewById(R.id.etsl_emojiContainer);
        etsl_emojiContainer.setTabTitles(ChatEmojiManager.getInstance().getEmotionTagNames());
        etsl_emojiContainer.setItemMap(ChatEmojiManager.getInstance().getTagEmotionMap());
        //xml来控制
        etsl_emojiContainer.setViewStatusChangedListener(
                new EmojiTabScrollLayout.ViewStatusChangeListener() {
                    @Override
                    public void onTabClick(int position, String title) {
                        //这里position基本就是title在EmotionTagNames和TagEmotionMap里面的排序
                        Log.d(TAG, "initEditAreaView-onTabClick position:" + position + " title:" + title);
                        String emoUnusableTips = null;
                        Map<String, EmotionCategory> emoNameCates = ChatEmojiManager.getInstance().getTagEmotionMap();
                        boolean currEmoTypeSendable = false;
                        if (null != mIMRoomInItem && null != mIMRoomInItem.emoTypeList) {
                            int index = 0;
                            for (; index < mIMRoomInItem.emoTypeList.length; index++) {
                                currEmoTypeSendable = mIMRoomInItem.emoTypeList[index] == position;
                                if (currEmoTypeSendable) {
                                    break;
                                }
                            }
                            if (!currEmoTypeSendable && index == mIMRoomInItem.emoTypeList.length && null != emoNameCates) {
                                EmotionCategory emotionCategory = emoNameCates.get(title);
                                if (null != emotionCategory) {
                                    emoUnusableTips = emotionCategory.emotionErrorMsg;
                                }
                            }
                        }
                        Log.d(TAG, "initEditAreaView-onTabClick emoUnusableTips:" + emoUnusableTips + " currEmoTypeSendable:" + currEmoTypeSendable);
                        etsl_emojiContainer.setUnusableTip(emoUnusableTips);
                    }

                    @Override
                    public void onGridViewItemClick(View itemChildView, int position, String title, Object obj) {
                        chooseEmotionItem = (EmotionItem) obj;
                        et_liveMsg.append(chooseEmotionItem.emoSign);
                        lastInputEmoSign = chooseEmotionItem.emoSign;
                    }
                });
        etsl_emojiContainer.notifyDataChanged();
        iv_emojiSwitch = (ImageView) findViewById(R.id.iv_emojiSwitch);
        iv_emojiSwitch.setImageDrawable(getResources().getDrawable(R.drawable.ic_liveroom_emojiswitch));
        //底部输入+礼物btn
        iv_freePublicBg1 = (ImageView) findViewById(R.id.iv_freePublicBg1);
        iv_freePublicBg2 = (ImageView) findViewById(R.id.iv_freePublicBg2);
        iv_freePublicBg1.setVisibility(View.GONE);
        iv_freePublicBg2.setVisibility(View.GONE);
        ll_buttom_audience = findViewById(R.id.ll_buttom_audience);
        tv_inputMsg = (TextView) findViewById(R.id.tv_inputMsg);
        iv_gift = (ImageView) findViewById(R.id.iv_gift);
        iv_recommendGift = (ImageView) findViewById(R.id.iv_recommendGift);
        iv_recommGiftFloat = (ImageView) findViewById(R.id.iv_recommGiftFloat);
        iv_talent = (ImageView) findViewById(R.id.iv_talent);
        iv_talent.setVisibility(View.GONE);
        //动画播放一次
        mAnimationDrawableTalent = ((AnimationDrawable) iv_talent.getBackground());
//        mAnimationDrawableTalent.setOneShot(false);

        fl_recommendGift = findViewById(R.id.fl_recommendGift);
        fl_recommendGift.setVisibility(View.GONE);
        fl_recommendGift.setOnClickListener(this);
        if (null != mIMRoomInItem) {
            ll_input_edit_body.setBackgroundDrawable(roomThemeManager.getRoomETBgDrawable(this, mIMRoomInItem.roomType));
            v_roomEditMegBg.setImageDrawable(roomThemeManager.getRoomInputBgDrawable(this, mIMRoomInItem.roomType));
            iv_sendMsg.setImageDrawable(roomThemeManager.getRoomSendMsgBtnDrawable(this, mIMRoomInItem.roomType));
            iv_emojiSwitch.setVisibility(roomThemeManager.getRoomInputEmojiSwitchVisiable(this, mIMRoomInItem.roomType));
            //say something...
            Drawable inputDrawalbe = roomThemeManager.getRoomInputBtnDrawable(this, mIMRoomInItem.roomType);
            if (null != inputDrawalbe) {
                tv_inputMsg.setBackgroundDrawable(inputDrawalbe);
            }
            tv_inputMsg.setTextColor(roomThemeManager.getRoomInputTipsTxtColor(mIMRoomInItem.roomType));
            et_liveMsg.setTextColor(roomThemeManager.getRoomETTxtColor(mIMRoomInItem.roomType));

            //才艺点播按钮
            if (mIMRoomInItem.roomType == IMLiveRoomType.AdvancedPrivateRoom) {
                iv_talent.setVisibility(View.VISIBLE);
                //动画 播放,延时1秒，因为太早播放完，跟本看不到
                if (mAnimationDrawableTalent != null) {
                    if (mAnimationDrawableTalent.isRunning()) {
                        postUiRunnableDelayed(new Runnable() {
                            @Override
                            public void run() {
                                if (mAnimationDrawableTalent != null && mAnimationDrawableTalent.isRunning()) {
                                    mAnimationDrawableTalent.stop();
                                    if (iv_talent != null) {
                                        iv_talent.setBackgroundResource(R.drawable.live_talent_anim_12);
                                    }
                                }
                            }
                        }, 850 * 5 - 100);
                    } else {
                        //执行播放5次
                        iv_talent.postDelayed(new Runnable() {
                            @Override
                            public void run() {
                                mAnimationDrawableTalent.start();
                                //播放5次后停止动画播放,并调整100毫秒防止事件过慢，动画跳帧
                                postUiRunnableDelayed(new Runnable() {
                                    @Override
                                    public void run() {
                                        if (mAnimationDrawableTalent != null && mAnimationDrawableTalent.isRunning()) {
                                            mAnimationDrawableTalent.stop();
                                            if (iv_talent != null) {
                                                iv_talent.setBackgroundResource(R.drawable.live_talent_anim_12);
                                            }
                                        }
                                    }
                                }, 850 * 5 - 100);
                            }
                        }, 200);
                    }
                }
            }

            //推荐礼物按钮
            int rightMargin = roomThemeManager.getRoomRecommGiftBtnRightMargin(this, mIMRoomInItem.roomType);
            fl_recommendGift.setVisibility(0 == rightMargin ? View.GONE : View.VISIBLE);
            LinearLayout.LayoutParams recommGiftBtnLp = (LinearLayout.LayoutParams) fl_recommendGift.getLayoutParams();
            recommGiftBtnLp.rightMargin = rightMargin;
            fl_recommendGift.setLayoutParams(recommGiftBtnLp);
            Drawable recGiftDrawable = roomThemeManager.getRoomRecommGiftFloatDrawable(this, mIMRoomInItem.roomType);
            if (null != recGiftDrawable) {
                iv_recommGiftFloat.setImageDrawable(recGiftDrawable);
            }

            //礼物按钮
            LinearLayout.LayoutParams giftBtnLp = (LinearLayout.LayoutParams) iv_gift.getLayoutParams();
            giftBtnLp.leftMargin = roomThemeManager.getRoomGiftBtnLeftMargin(this, mIMRoomInItem.roomType);
            giftBtnLp.rightMargin = roomThemeManager.getRoomGiftBtnRightMargin(this, mIMRoomInItem.roomType);
            giftBtnLp.bottomMargin = roomThemeManager.getRoomGiftBtnButtomMargin(this, mIMRoomInItem.roomType);
            iv_gift.setLayoutParams(giftBtnLp);
            Drawable giftDrawalbe = roomThemeManager.getRoomGiftBtnDrawable(this, mIMRoomInItem.roomType);
            if (null != giftDrawalbe) {
                iv_gift.setImageDrawable(giftDrawalbe);
            }
        }
    }

    //显示免费公开直播间底部的背景图片-欢呼粉丝群.jpg
    protected void showFreePublicRoomButtomImGBg() {
        iv_freePublicBg1.setVisibility(View.GONE);
        iv_freePublicBg2.setVisibility(View.GONE);
    }

    private void initEditAreaViewStyle() {
        if (null != mIMRoomInItem && mIMRoomInItem.roomType == IMLiveRoomType.FreePublicRoom) {
            iv_emojiSwitch.setVisibility(View.GONE);
        }
    }

    /**
     * 切换当前编辑状态（弹幕/普通消息）
     */
    private void switchEditType() {
        isBarrage = !isBarrage;
        if (null != mIMRoomInItem) {
            iv_msgType.setImageDrawable(roomThemeManager.getRoomMsgTypeSwitchDrawable(this, mIMRoomInItem.roomType, isBarrage));
            et_liveMsg.setHintTextColor(roomThemeManager.getRoomETHintTxtColor(mIMRoomInItem.roomType, isBarrage));
        }
        ll_input_edit_body.setSelected(isBarrage);

        String editHint = "";
        if (isBarrage) {
            double price = 0.0;
            if (mIMRoomInItem != null) {
                price = mIMRoomInItem.popPrice;
            }
            editHint = String.format(getResources().getString(R.string.txt_hint_input_barrage),
                    ApplicationSettingUtil.formatCoinValue(price));
        } else {
            editHint = getResources().getString(R.string.txt_hint_input_general);
        }
        et_liveMsg.setHint(editHint);
//        et_liveMsg.setHint(isBarrage ? R.string.txt_hint_input_barrage : R.string.txt_hint_input_general);
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

    //******************************** 软键盘打开关闭的监听****************************************************************
    private boolean isSoftInputOpen = false;

    /**
     * 调整view高度, 解决背景在AdjustSize时会被推上去问题
     */
    @SuppressLint("WrongViewCast")
    private void setSizeUnChanageViewParams() {
        int statusBarHeight = DisplayUtil.getStatusBarHeight(mContext);
        if (statusBarHeight > 0) {
            int activityHeight = DisplayUtil.getScreenHeight(mContext) - statusBarHeight;
            LinearLayout.LayoutParams params = (LinearLayout.LayoutParams) findViewById(R.id.fl_bgContent).getLayoutParams();
            params.height = activityHeight;
            //设置固定宽高，解决键盘弹出挤压问题
            FrameLayout.LayoutParams advanceGiftParams = (FrameLayout.LayoutParams) advanceGift.getLayoutParams();
            advanceGiftParams.height = activityHeight;
            //设置IM区域高度，处理弹出效果
            FrameLayout.LayoutParams imParams = (FrameLayout.LayoutParams) imBody.getLayoutParams();
            imParams.height = activityHeight - (int) getResources().getDimension(R.dimen.imButtomMargin);
        }
    }

    @Override
    public void onSoftKeyboardShow() {
        Log.d(TAG, "onSoftKeyboardShow");
        isSoftInputOpen = true;
//        playRoomHeaderOutAnim();
        //判断是否弹幕播放中，是则隐藏底部白底阴影
        if (null != mBarrageManager) {
            mBarrageManager.changeBulletScreenBg(false);
            hideStartButtons();
        }

        //适配某些机型，当切换英文键盘到中文键盘，会先走onSoftKeyboardHide后走onSoftKeyboardShow，
        // 导致底部输入框被隐藏
        if (View.VISIBLE == ll_buttom_audience.getVisibility()) {
            ll_buttom_audience.setVisibility(View.GONE);
            rl_inputMsg.setVisibility(View.VISIBLE);
            showSoftInput(et_liveMsg);
        }

        //add by Jagger
        doMovePublishViewUnderEditView();

        lrsv_roomBody.setScrollFuncEnable(false);
    }

    @Override
    public void onSoftKeyboardHide() {
        Log.d(TAG, "onSoftKeyboardHide");
        isSoftInputOpen = false;
        //如果onSoftKeyboardHide回调是由表情控件触发
        //TODO:解决私密直播间，1.弹出软键盘显示输入框;2.点开表情;3.关闭表情;4.点空白地方试图隐藏输入框，ui展示不合预期的bug;5.3之后点击输入框隐藏表情再点击空白区域就正常
        //解决方案可以是在点击空白区域的onclick事件中处理?
        if (isEmojiOpera) {
            isEmojiOpera = false;
            return;
        }
        if (etsl_emojiContainer.getVisibility() != View.VISIBLE) {
            ll_buttom_audience.setVisibility(View.VISIBLE);

            if (rl_inputMsg != null) {
                rl_inputMsg.setVisibility(View.INVISIBLE);
            }
        }
        //判断是否弹幕播放中，是则显示底部白底阴影
        mBarrageManager.changeBulletScreenBg(true);
        showOrResetStartButtons();

        //add by Jagger
        doReMovePublishView();

        lrsv_roomBody.setScrollFuncEnable(true);
    }

    //******************************** 消息展示列表 ****************************************************************

    /**
     * 初始化消息展示列表
     */
    private void initMessageList() {
        View fl_msglist = findViewById(R.id.fl_msglist);
        FrameLayout.LayoutParams msgListLp = (FrameLayout.LayoutParams) fl_msglist.getLayoutParams();
        msgListLp.topMargin = roomThemeManager.getRoomMsgListTopMargin(this, mIMRoomInItem.roomType);
        fl_msglist.setLayoutParams(msgListLp);
        liveRoomChatManager = new LiveRoomChatManager(this, mIMRoomInItem.roomType,
                mIMRoomInItem.userId, loginItem.userId, roomThemeManager);
        liveRoomChatManager.init(this, fl_msglist);
        liveRoomChatManager.setLiveMessageListItemClickListener(this);

        //incliude view id 必须通过setOnClickListener方式设置onclick监听,
        // xml中include标签下没有onclick和clickable属性
        findViewById(R.id.fl_imMsgContainer).setOnClickListener(this);
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

    //******************************** 弹幕动画 ****************************************************************
    private BarrageManager<IMMessageItem> mBarrageManager;

    /**
     * 初始化弹幕
     */
    private void initBarrage() {
        if (null != mIMRoomInItem) {
            ll_bulletScreen.setBackgroundDrawable(roomThemeManager.getRoomBarrageBgDrawable(mIMRoomInItem.roomType));
        }
        ViewCompat.setElevation(ll_bulletScreen, DisplayUtil.dip2px(this, 3f));
        List<View> mViews = new ArrayList<View>();
        mViews.add(findViewById(R.id.rl_bullet1));
        mBarrageManager = new BarrageManager<IMMessageItem>(this, mViews, ll_bulletScreen);
        mBarrageManager.setOnBarrageEventListener(this);
        mBarrageManager.setBarrageFiller(new IBarrageViewFiller<IMMessageItem>() {
            @Override
            public void onBarrageViewFill(View view, IMMessageItem item) {
                CircleImageView civ_bullletIcon = (CircleImageView) view.findViewById(R.id.civ_bullletIcon);
                TextView tv_bulletName = (TextView) view.findViewById(R.id.tv_bulletName);
                TextView tv_bulletContent = (TextView) view.findViewById(R.id.tv_bulletContent);
                if (item != null) {
                    tv_bulletName.setText(item.nickName);
                    tv_bulletContent.setText(ChatEmojiManager.getInstance().parseEmoji(BaseCommonLiveRoomActivity.this,
                            TextUtils.htmlEncode(item.textMsgContent.message),
                            ChatEmojiManager.PATTERN_MODEL_SIMPLESIGN,
                            (int) getResources().getDimension(R.dimen.liveroom_messagelist_barrage_width),
                            (int) getResources().getDimension(R.dimen.liveroom_messagelist_barrage_height)));
                    String photoUrl = null;
                    if (null != mIMManager) {
                        IMUserBaseInfoItem baseInfo = mIMManager.getUserInfo(item.userId);
                        if (baseInfo != null) {
                            photoUrl = baseInfo.photoUrl;
                        }
                    }
                    if (!TextUtils.isEmpty(photoUrl)) {
//                        Picasso.with(BaseCommonLiveRoomActivity.this.getApplicationContext())
//                                .load(photoUrl)
//                                .placeholder(R.drawable.ic_default_photo_man)
//                                .error(R.drawable.ic_default_photo_man)
//                                .memoryPolicy(MemoryPolicy.NO_CACHE)
//                                .into(civ_bullletIcon);
                        PicassoLoadUtil.loadUrlNoMCache(civ_bullletIcon, photoUrl, R.drawable.ic_default_photo_man);
                    } else {
                        civ_bullletIcon.setImageResource(R.drawable.ic_default_photo_man);
                    }

                }
            }
        });
    }

    /**
     * 添加弹幕动画
     *
     * @param msgItem
     */
    private void addBarrageItem(IMMessageItem msgItem) {
        if (msgItem != null) {
            mBarrageManager.addBarrageItem(msgItem);
        }
    }

    @Override
    public void OnSendBarrage(boolean success, IMClientListener.LCC_ERR_TYPE errType,
                              String errMsg, IMMessageItem msgItem, double credit,
                              double rebateCredit) {
        super.OnSendBarrage(success, errType, errMsg, msgItem, credit, rebateCredit);
        if (errType != IMClientListener.LCC_ERR_TYPE.LCC_ERR_SUCCESS) {
            //需要查询是否是大礼物发送失败，提示用户
            if (errType == LCC_ERR_NO_CREDIT) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        //弹出充值提示
                        showCreditNoEnoughDialog(R.string.live_common_noenough_money_tips);
                    }
                });
            }
        }
    }


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
                Log.i("Jagger" , "BaseCommonLiveRoomActivity OnRecvRoomKickoffNotice book:" + (privItem == null?"null":privItem.isHasBookingAuth));
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
    public void OnRecvLackOfCreditNotice(String roomId, String message, double credit) {
        if (!isCurrentRoom(roomId)) {
            return;
        }
        super.OnRecvLackOfCreditNotice(roomId, message, credit);
        Log.d(TAG, "OnRecvLackOfCreditNotice-hasShowCreditsLackTips:" + hasShowCreditsLackTips);
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
    public void OnRecvLeavingPublicRoomNotice(String roomId, int leftSeconds, IMClientListener.LCC_ERR_TYPE err, String errMsg, IMAuthorityItem privItem) {
        if (!isCurrentRoom(roomId)) {
            return;
        }
        super.OnRecvLeavingPublicRoomNotice(roomId, leftSeconds, err, errMsg, privItem);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
               hideStartButtons();
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
                Log.d(TAG, "OnRecvRoomCloseNotice-closeRoomByUser:" + closeRoomByUser);
            } else if (!TextUtils.isEmpty(mIMRoomInItem.roomId) && roomId.equals(mIMRoomInItem.roomId)) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        boolean isShowRecommand = false;
                        Log.i("Jagger" , "BaseCommonLiveRoomActivity OnRecvRoomCloseNotice book:" + (privItem == null?"null":privItem.isHasBookingAuth));
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
        if(!TextUtils.isEmpty(mInvitationRoomId)){
            //关闭直播间是因为邀请成功导致
            enterHangoutTransition();
        }else{
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
        //视频上传预览
        includePublish = findViewById(R.id.includePublish);
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

        iv_publishstart.setOnClickListener(this);
        iv_publishstop.setOnClickListener(this);
        iv_publishsoundswitch.setOnClickListener(this);
        includePublish.setOnClickListener(this);
        ViewDragTouchListener listener = new ViewDragTouchListener(100l);
        listener.setOnViewDragListener(new ViewDragTouchListener.OnViewDragStatusChangedListener() {
            @Override
            public void onViewDragged(int l, int t, int r, int b) {
                Log.d(TAG, "onViewDragged-l:" + l + " t:" + t + " r:" + r + " b:" + b);
                //避免父布局重绘后includePublish回到原来的位置
                FrameLayout.LayoutParams flIPublish = (FrameLayout.LayoutParams) includePublish.getLayoutParams();
                flIPublish.gravity = Gravity.TOP | Gravity.LEFT;
                flIPublish.leftMargin = includePublish.getLeft();
                flIPublish.topMargin = includePublish.getTop();
                includePublish.setLayoutParams(flIPublish);
            }
        });
        includePublish.setOnTouchListener(listener);
        //高斯模糊头像部分
        view_gaussian_blur_me = findViewById(R.id.view_gaussian_blur_me);
        v_gaussianBlurFloat = findViewById(R.id.v_gaussianBlurFloat);
        iv_gaussianBlur = (SimpleDraweeView) findViewById(R.id.iv_gaussianBlur);

        //del by Jagger 2018-5-31 因为在initPublishData()已经做了这步，所以这里的代码不需要了
//        if(null != mIMRoomInItem && (mIMRoomInItem.roomType == IMLiveRoomType.NormalPrivateRoom
//                || mIMRoomInItem.roomType == IMLiveRoomType.AdvancedPrivateRoom)
//                && LSPublisher.checkDeviceSupport(mContext)){
////            includePublish.setVisibility(View.VISIBLE);
//        }else{
//            includePublish.setVisibility(View.GONE);
//        }

        openInterVideoTipsPopupWindow = new OpenInterVideoTipsPopupWindow(this);
        openInterVideoTipsPopupWindow.setOnBtnClickListener(new OpenInterVideoTipsPopupWindow.OnOpenTipsBtnClickListener() {
            @Override
            public void onBtnClicked(boolean isOpenVideo, boolean neverShowTipsAgain) {
                if (isOpenVideo) {
                    startOrStopVideoInteraction();
                }
                BaseCommonLiveRoomActivity.this.neverShowTipsAgain = neverShowTipsAgain;
                if (null != localPreferenceManager) {
                    try {
                        localPreferenceManager.save("neverShowTipsAgain", BaseCommonLiveRoomActivity.this.neverShowTipsAgain);
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
            includePublish.setVisibility(View.VISIBLE);
            //del by Jagger 2017-12-1 改为每次启动互动视频上传时 重新初始化(因为不释放掉相机,LG-D820暂时几分钟后,会CHRASH)
            //播放器初始化
//            mPublisherManager = new PublisherManager(this);
//            mPublisherManager.init(svPublisher);
//
            if (mIMRoomInItem.manUploadRtmpUrls != null
                    && mIMRoomInItem.manUploadRtmpUrls.length > 0 && !TextUtils.isEmpty(mIMRoomInItem.manUploadRtmpUrls[0])) {
//                startPublishStream(mIMRoomInItem.manUploadRtmpUrls[0]);
                startOrStopVideoInteraction();
            }
        } else {
            includePublish.setVisibility(View.GONE);
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

    //del by Jagger 2017-12-1
//    /**
//     * 回收互动相关资源
//     */
//    private void onPublisherDestroy(){
//        if(mPublisherManager != null){
//            mPublisherManager.uninit();
//        }
//        removeCallback(mHideOperateRunnable);
//    }

    /**
     * 开始互动
     */
    private void publishStart() {
        if (neverShowTipsAgain) {
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
            startOrStopVideoInteraction();
        } else {
            stopPublishStream();
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
            iv_publishsoundswitch.setVisibility(View.VISIBLE);
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
            iv_publishstop.setVisibility(View.GONE);
            iv_publishstart.setVisibility(View.VISIBLE);
            iv_publishsoundswitch.setVisibility(View.GONE);
        }
    }

    /**
     * 开始／关闭视频互动
     */
    private void startOrStopVideoInteraction() {
        if (mIMRoomInItem != null) {
            lastVideoInteractiveOperateType = IMClient.IMVideoInteractiveOperateType.Start;
            if (isPublishing) {
                lastVideoInteractiveOperateType = IMClient.IMVideoInteractiveOperateType.Close;
            }
            mVideoInteractionReqId = mIMManager.ControlManPush(mIMRoomInItem.roomId, lastVideoInteractiveOperateType);
            if (IM_INVALID_REQID != mVideoInteractionReqId) {
                //发出请求成功
                flPublishOperate.setVisibility(View.GONE);
                publishLoading.setVisibility(View.VISIBLE);
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

//        //stop清除publisher，开始推流才初始化
//        mPublisherManager = new PublisherManager(this);
//        mPublisherManager.init(svPublisher);

        //刷新界面
        refreshPublishViews();

        //初始化播放器
        if (mPublisherManager != null && mPublisherManager.isInited()) {
            //del by Jagger 2017-12-1
//            mPublisherManager.stop();
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

        //add by Jagger 2017-12-1
        //销毁播放器
//        destroyPublisher();

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
                        } else {
                            //启动上传
                            if (manPushUrl != null && manPushUrl.length > 0) {
                                startPublishStream(manPushUrl);
                            } else {
                                //状态异常，处理为启动失败
                                showToast(getResources().getString(R.string.common_webview_load_error));
                                //调用关闭，防止持续扣费
                                mIMManager.ControlManPush(mIMRoomInItem.roomId, IMClient.IMVideoInteractiveOperateType.Close);
                            }
                        }
                    } else {
                        //开启或关闭失败
                        if (errType == LCC_ERR_INCONSISTENT_CREDIT_FAIL
                                || errType == LCC_ERR_NO_CREDIT
                                || errType == LCC_ERR_NO_CREDIT_DOUBLE_VIDEO) {
                            showCreditNoEnoughDialog(R.string.live_common_noenough_money_tips);
                        } else {
                            if (lastVideoInteractiveOperateType == IMClient.IMVideoInteractiveOperateType.Start) {
                                //开启失败
                                showToast(getResources().getString(R.string.live_inter_video_failed_open));
                            } else {
                                //关闭失败
                                showToast(getResources().getString(R.string.live_inter_video_failed_close));
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
     * 因为在P6中,当看不见浮动的视频窗体时,小窗体的内容会显示在主播视频区中,
     * 所以,弹出键盘时,把它移到输入框下面
     */
    private void doMovePublishViewUnderEditView() {
        //应用程序App区域宽高等尺寸获取
        Rect rect = new Rect();
        getWindow().getDecorView().getWindowVisibleDisplayFrame(rect);
        int edBottomY = rect.height() - 1;

        FrameLayout.LayoutParams flIPublish = (FrameLayout.LayoutParams) includePublish.getLayoutParams();
        //移动
        if (flIPublish.topMargin > edBottomY) {
            //记录移动前的TOP
            mIPublishTempTop = flIPublish.topMargin;
            //
            flIPublish.topMargin = edBottomY;
            includePublish.setLayoutParams(flIPublish);
            //
            mIsMovePublishViewUnderEditView = true;
        }
    }

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
            if(currCredits<talent.talentCredit){
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
        if(success){
            TalentInfoItem talentInfoItem = talentManager.getTalentInfoItemById(talentId);

            Message msg = Message.obtain();
            msg.what = EVENT_TALENT_SENT_SUCCESS;
            msg.obj = talentInfoItem;
            sendUiMessage(msg);
        }else{
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
            if(talentManager.onTalentProcessed(talentId, name, credit, status, giftId, giftName, giftNum, talentInviteId)){
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
        if(item != null){
            switch (item.msgType){
                case AnchorRecommand:{
                    startHangoutInvitation(item.hangoutRecommendItem);
                }break;
                case TalentRecommand:{
                    //显示才艺列表
                    if (null != mIMRoomInItem) {
                        talentManager.showTalentsList(this, flContentBody);
                    }

                    //GA点击才艺点播
                    onAnalyticsEvent(getResources().getString(R.string.Live_Broadcast_Category),
                            getResources().getString(R.string.Live_Broadcast_Action_Talent),
                            getResources().getString(R.string.Live_Broadcast_Label_Talent));
                }break;
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
            mModuleGiftManager.onMultiGiftOnStop();
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
                Log.i("Jagger" , "BaseCommonLiveRoomActivity onResume1 book:" + (mAuthorityItem == null?"null":mAuthorityItem.isHasBookingAuth));
                endLive(mClosePageErrorType, mCloseErrMsg, mIsNeedRecommand, mIsNeedCommand, mAuthorityItem);
            }
        } else if (hasBackgroundTimeOut) {
            //解决5.0以下startActivity会在后台打开页面，但是5.0以上会将应用带到前台
            Log.i("Jagger" , "BaseCommonLiveRoomActivity onResume2 book:" + (mAuthorityItem == null?"null":mAuthorityItem.isHasBookingAuth));
            endLive(LiveRoomNormalErrorActivity.PageErrorType.PAGE_ERROR_BACKGROUD_OVERTIME, "", true, true, mAuthorityItem);
        } else {
            //刷新一次信用点解决信用点不足，充值返回，由于本地信用点未刷新导致直播间本地判断异常
            GetCredit();
        }

        //重置标志位
        mIsRoomBackgroundClose = false;
        mClosePageErrorType = null;
        hasBackgroundTimeOut = false;
        mIsNeedRecommand = false;
        mIsNeedCommand = true;
        mCloseErrMsg = "";
    }

    @Override
    public void onRecvBarrageEvent(boolean startOrOver) {
        Log.d(TAG, "onRecvBarrageEvent-startOrOver:" + startOrOver + " thread:" + Thread.currentThread().getName());
        ViewCompat.setElevation(ll_privateLive, startOrOver ? 0f : DisplayUtil.dip2px(this, 3f));
    }

    //--------------------------------多人互动邀请业务------------------------------------------------
    private HashMap<String, Object> mHangoutInviteMap = new HashMap<>();

    /**
     * 点击顶部hangout按钮发起hangout邀请
     * @param anchorItem
     */
    private void startHangoutInvitation(final HangoutOnlineAnchorItem anchorItem){
        if(mHangoutInviteMap.size() == 0) {
            mHangoutInviteMap.put(anchorItem.anchorId, anchorItem);
            mHangoutInvitationManager.startInvitationSession(new IMUserBaseInfoItem(anchorItem.anchorId, anchorItem.nickName, anchorItem.coverImg), mIMRoomInItem.roomId, "", true);
        }
    }

    /**
     * 点击推荐发起hangout邀请
     * @param recommendItem
     */
    private void startHangoutInvitation(final IMHangoutRecommendItem recommendItem){
        if(mHangoutInviteMap.size() == 0){
            mHangoutInviteMap.put(recommendItem.anchorId, recommendItem);
            mHangoutInvitationManager.startInvitationSession(new IMUserBaseInfoItem(recommendItem.anchorId, recommendItem.nickName, recommendItem.photoUrl), mIMRoomInItem.roomId, recommendItem.recommendId, true);
        }
    }

    /**
     * 提示hangout邀请发送成功，等待
     * @param anchorName
     */
    private void showHangoutInviteStart(String anchorName){
        if(tvInviteTips != null){
            tvInviteTips.setVisibility(View.VISIBLE);
            String message = String.format(getResources().getString(R.string.hangout_invtite_start_tips), anchorName);
            tvInviteTips.setText(message);
        }
    }

    /**
     * 进入hangout过渡页
     */
    private void enterHangoutTransition(){
        if(mIMRoomInItem != null && mHangoutInviteMap != null && mHangoutInviteMap.containsKey(mIMRoomInItem.userId)){
            //生成被邀请的主播列表（这里是目标主播一人）
            Object inviteItem = mHangoutInviteMap.remove(mIMRoomInItem.userId);
            if(inviteItem != null) {
                ArrayList<IMUserBaseInfoItem> anchorList = new ArrayList<>();
                String recommandId = "";
                if(inviteItem instanceof IMHangoutRecommendItem){
                    //推荐进入
                    IMHangoutRecommendItem tempRecommand = (IMHangoutRecommendItem)inviteItem;
                    anchorList.add(new IMUserBaseInfoItem(tempRecommand.anchorId, tempRecommand.nickName, tempRecommand.photoUrl));
                    anchorList.add(new IMUserBaseInfoItem(tempRecommand.firendId, tempRecommand.friendNickName, tempRecommand.friendPhotoUrl));
                    recommandId = tempRecommand.recommendId;
                }else if(inviteItem instanceof HangoutOnlineAnchorItem){
                    //点击头部进入
                    HangoutOnlineAnchorItem tempAnchorItem = (HangoutOnlineAnchorItem)inviteItem;
                    anchorList.add(new IMUserBaseInfoItem(tempAnchorItem.anchorId, tempAnchorItem.nickName, tempAnchorItem.avatarImg));
                }
                //过渡页
                Intent intent = HangoutTransitionActivity.getIntent(
                        mContext,
                        anchorList,
                        mInvitationRoomId,
                        "",
                        recommandId);
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
        Log.d(TAG,"OnRecvAnchorRecommendHangoutNotice-item:"+item);
        super.OnRecvRecommendHangoutNotice(item);
        if(mIMRoomInItem != null && (mIMRoomInItem.roomType == IMLiveRoomType.AdvancedPrivateRoom
                || mIMRoomInItem.roomType == IMLiveRoomType.NormalPrivateRoom)){
            IMMessageItem msgItem = new IMMessageItem(item.roomId ,
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
        if(isSuccess){
            mInvitationRoomId = roomId;
            if(tvInviteTips != null){
                tvInviteTips.setText(getResources().getString(R.string.hangout_invtite_success_tips));
            }
        }else{
            //邀请失败，清掉本地缓存，防止无法再发起多人互动请求
            mHangoutInviteMap.remove(userBaseInfoItem.userId);

            if(errorType == HangoutInvitationManager.HangoutInvationErrorType.NoCredit){
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
            else{
                if(tvInviteTips != null && tvInviteTips.getVisibility() == View.VISIBLE){
                    //邀请已发送成功
                    tvInviteTips.setText(errMsg);
                }else{
                    //邀请发送失败
                    showToast(errMsg);
                }
            }
        }

        //启动3秒关闭提示
        postUiRunnableDelayed(new Runnable() {
            @Override
            public void run() {
                //关闭提示
                if(tvInviteTips != null){
                    tvInviteTips.setVisibility(View.GONE);
                }
                if(isSuccess){
                    if(!TextUtils.isEmpty(mInvitationRoomId)){
                        enterHangoutTransition();
                    }
                }
            }
        }, 3 * 1000);
    }

    @Override
    public void onHangoutCancel(boolean isSuccess, int httpErrCode, String errMsg) {

    }
}
