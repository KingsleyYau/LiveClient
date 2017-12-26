package com.qpidnetwork.livemodule.liveshow.liveroom;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.PixelFormat;
import android.graphics.Rect;
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
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
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

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.livemodule.framework.widget.statusbar.StatusBarUtil;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnRequestCallback;
import com.qpidnetwork.livemodule.httprequest.item.AudienceBaseInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.EmotionCategory;
import com.qpidnetwork.livemodule.httprequest.item.EmotionItem;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.httprequest.item.SendableGiftItem;
import com.qpidnetwork.livemodule.httprequest.item.TalentInfoItem;
import com.qpidnetwork.livemodule.im.IMClient;
import com.qpidnetwork.livemodule.im.listener.IMClientListener;
import com.qpidnetwork.livemodule.im.listener.IMMessageItem;
import com.qpidnetwork.livemodule.im.listener.IMPackageUpdateItem;
import com.qpidnetwork.livemodule.im.listener.IMRebateItem;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem.IMLiveRoomType;
import com.qpidnetwork.livemodule.im.listener.IMSysNoticeMessageContent;
import com.qpidnetwork.livemodule.im.listener.IMUserBaseInfoItem;
import com.qpidnetwork.livemodule.liveshow.WebViewActivity;
import com.qpidnetwork.livemodule.liveshow.anchor.AnchorProfileActivity;
import com.qpidnetwork.livemodule.liveshow.datacache.file.FileCacheManager;
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
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.PackageGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.dialog.LiveGiftDialog;
import com.qpidnetwork.livemodule.liveshow.liveroom.interactivevideo.OpenInterVideoTipsPopupWindow;
import com.qpidnetwork.livemodule.liveshow.liveroom.intimacy.UserIntimacyWithHostPopupWindow;
import com.qpidnetwork.livemodule.liveshow.liveroom.rebate.LiveRoomCreditRebateManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.rebate.RoomRebateTipsPopupWindow;
import com.qpidnetwork.livemodule.liveshow.liveroom.recharge.AudienceBalanceInfoPopupWindow;
import com.qpidnetwork.livemodule.liveshow.liveroom.talent.TalentManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.talent.interfaces.onRequestConfirmListener;
import com.qpidnetwork.livemodule.liveshow.liveroom.tariffprompt.TariffPromptManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.vedio.VedioLoadingAnimManager;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.liveshow.personal.chatemoji.ChatEmojiManager;
import com.qpidnetwork.livemodule.liveshow.personal.chatemoji.EmojiTabScrollLayout;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.ImageUtil;
import com.qpidnetwork.livemodule.utils.Log;
import com.qpidnetwork.livemodule.utils.SystemUtils;
import com.qpidnetwork.livemodule.view.CircleImageHorizontScrollView;
import com.qpidnetwork.livemodule.view.LiveRoomHeaderBezierView;
import com.qpidnetwork.livemodule.view.SoftKeyboradListenFrameLayout;
import com.qpidnetwork.livemodule.view.listener.ViewDragTouchListener;
import com.qpidnetwork.qnbridgemodule.sysPermissions.manager.PermissionManager;
import com.squareup.picasso.Picasso;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import static com.qpidnetwork.livemodule.im.IMManager.IM_INVALID_REQID;
import static com.qpidnetwork.livemodule.im.listener.IMClientListener.LCC_ERR_TYPE.LCC_ERR_INCONSISTENT_CREDIT_FAIL;
import static com.qpidnetwork.livemodule.im.listener.IMClientListener.LCC_ERR_TYPE.LCC_ERR_NO_CREDIT;
import static com.qpidnetwork.livemodule.liveshow.liveroom.LiveRoomNormalErrorActivity.PageErrorType.PAGE_ERROR_LIEV_EDN;
import static com.qpidnetwork.livemodule.liveshow.liveroom.LiveRoomNormalErrorActivity.PageErrorType.PAGE_ERROR_NOMONEY;

/**
 * 直播间公共处理界面类
 * 1.界面刷新，数据展示的处理放在该BaseActivity内处理
 * 2.设计到具体的房间类型内的，各种业务请求预处理，返回数据处理，各类型房间业务流程等的处理，都放到子类中做
 * 3.需要不断的review code，保证baseActivity、baseImplActivity及子类的职责明确
 * Created by Hunter Mun on 2017/6/16.
 */

public class BaseCommonLiveRoomActivity extends BaseImplLiveRoomActivity {
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
    private static final int EVENT_UPDATE_REBATE=1012;
    /**
     * 直播间界面进入后台
     */
    private static final int EVENT_TIMEOUT_BACKGROUND = 1013;
    /**
     * 直播间关闭倒计时
     */
    private static final int EVENT_LEAVING_ROOM_TIMECOUNT= 1014;
    /**
     * 亲密度等级升级，更新界面展示
     */
    private static final int EVENT_INTIMACY_LEVEL_UPDATE=1015;
    /**
     * 更新推荐礼物
     */
    private static final int EVENT_UPDATE_RECOMMANDGIFT=1016;

    //整个view的父，用于解决软键盘等监听
    public SoftKeyboradListenFrameLayout flContentBody;
    public RoomThemeManager roomThemeManager = new RoomThemeManager();

    //--------------------------------直播间头部视图层--------------------------------
    protected View view_roomHeader;
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

    //返点
    private TextView tv_rebateTips;
    private TextView tv_rebateValue;
    private View ll_rebate;
    private View view_roomHeader_buttomLine;
    private RoomRebateTipsPopupWindow roomRebateTipsPopupWindow;

    //亲密度
    public UserIntimacyWithHostPopupWindow userIntimacyWithHostPopupWindow;

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
    public SurfaceView sv_player;
    private View rl_media;
    private View imBody;
    protected View include_audience_area;
    private LivePlayerManager mLivePlayerManager;
    protected SimpleDraweeView sdv_vedioLoading;
    protected VedioLoadingAnimManager vedioLoadingAnimManager;


    //座驾
    protected LinearLayout ll_entranceCar;

    //私密预约按钮
    protected ImageView iv_privateLiveNow;
    protected TextView tv_enterPrvRoomTimerCount;
    protected LinearLayout ll_enterPriRoomTimeCount;
    private int leavingRoomTimeCount = 30;//30-default

    //男士互动区域
    protected View includePublish;
    protected SurfaceView svPublisher;
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
    protected ImageView iv_inputMsg;
    protected ImageView iv_gift;
    protected ImageView iv_recommendGift;
    protected ImageView iv_talent;
    protected ImageView iv_recommGiftFloat;
    protected View fl_recommendGift;

    protected boolean hasBackgroundTimeOut = false;
    protected boolean closeRoomByUser = false;

    //处理后台(即当前页不可用见时收到直播间关闭处理)
    private boolean mIsNeedRecommand = false;
    private boolean mIsRoomBackgroundClose = false;
    private LiveRoomNormalErrorActivity.PageErrorType mClosePageErrorType;
    private String mCloseErrMsg = "";


    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        TAG = BaseCommonLiveRoomActivity.class.getName();
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_live_room);

        initViews();
        if(null != mIMRoomInItem){
            initData();
            GiftSender.getInstance().currRoomId = mIMRoomInItem.roomId;
        }
        initRoomGiftDataSet();
        GiftSendReqManager.getInstance().executeNextReqTask();
        ChatEmojiManager.getInstance().getEmojiList(null);
        //同步模块直播进行中
        String targetId = "";
        if(mIMRoomInItem != null){
            targetId = mIMRoomInItem.userId;
        }
        //才艺点播
        initTalentManager();
    }

    private void initViews(){
        Log.d(TAG,"initViews");
        //解决软键盘关闭的监听问题
        flContentBody = (SoftKeyboradListenFrameLayout)findViewById(R.id.flContentBody);
        flContentBody.setInputWindowListener(this);
        initRoomHeader();
        if(null != mIMRoomInItem){
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
    public void initData(){
        if(null != mIMRoomInItem){
            //添加主播头像信息,方便web端主播送礼时客户端能够在小礼物动画上展示其头像
            mIMManager.updateOrAddUserBaseInfo(new IMUserBaseInfoItem(mIMRoomInItem.userId,
                    mIMRoomInItem.nickName,mIMRoomInItem.photoUrl));
        }
        //添加试用券使用提示
        if(null != mIMRoomInItem && mIMRoomInItem.usedVoucher){
            Log.d(TAG,"initData-mIMRoomInItem.usedVoucher:"+mIMRoomInItem.usedVoucher);
            showThreeSecondTips(String.format(getResources().getString(R.string.liveroom_paypublic_usedVoucher), String.valueOf(mIMRoomInItem.useCoupon)), Gravity.CENTER);
        }

        //获取本人座驾
        if(null != loginItem){
            LiveRequestOperator.getInstance().GetAudienceDetailInfo(loginItem.userId,this);
            //添加我的头像信息
            mIMManager.updateOrAddUserBaseInfo(new IMUserBaseInfoItem(loginItem.userId,
                    loginItem.nickName,loginItem.photoUrl));
        }
        //返点信息初始化
        if(mIMRoomInItem.roomType != IMLiveRoomType.FreePublicRoom
                && null != mIMRoomInItem.rebateItem && null!=roomRebateTipsPopupWindow){
            roomRebateTipsPopupWindow.notifyReBateUpdate(mIMRoomInItem.rebateItem);
            tv_rebateValue.setText(String.format ("%.2f", mIMRoomInItem.rebateItem.cur_credit));
        }
        //主播视频流加载
        if(mIMRoomInItem.videoUrls!=null && mIMRoomInItem.videoUrls.length > 0){
            startLivePlayer(mIMRoomInItem.videoUrls);
        }else{
//            ll_rebate.setVisibility(View.INVISIBLE);
            if(null != vedioLoadingAnimManager){
                vedioLoadingAnimManager.showLoadingAnim();
            }
        }
    }

    /**
     * 权限检查
     */
    private void checkPermissions(){
        PermissionManager permissionManager = new PermissionManager(mContext, new PermissionManager.PermissionCallback() {
            @Override
            public void onSuccessful() {
                publishStart();
            }

            @Override
            public void onFailure() {

            }
        });

        permissionManager.requestVideo();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
//		super.onActivityResult(requestCode, resultCode, data);
        //系统<设置>界面权限返回处理
        switch (requestCode) {
            case PermissionManager.REQUEST_CODE_SYSSETTING: {
                publishStart();
            }break;
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

        } else if (i == R.id.iv_prvHostIconBg || i == R.id.civ_prvHostIcon || i == R.id.tv_hostName) {
            visitHostInfo();
        } else if (i == R.id.iv_inputMsg || i == R.id.btn_showInputView) {
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
                showThreeSecondTips(getResources().getString(R.string.live_msg_send_tips),Gravity.CENTER);
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
        } else if (i == R.id.iv_follow || i == R.id.iv_followPrvHost)  {
            sendFollowHostReq();

            //GA点击关注
            onAnalyticsEvent(getResources().getString(R.string.Live_Broadcast_Category),
                    getResources().getString(R.string.Live_Broadcast_Action_Follow),
                    getResources().getString(R.string.Live_Broadcast_Label_Follow));

        } else if (i == R.id.iv_closeLiveRoom || i == R.id.ll_closeLiveRoom) {
            closeRoomByUser = true;
            closeLiveRoom();
        } else if (i == R.id.iv_publishstart) {
            if (System.currentTimeMillis() - mPublishStartlastClickTime > PUBLIC_CLICK_TIME) {//判断距离上次点击小于2秒
                mPublishStartlastClickTime = System.currentTimeMillis();//记录这次点击时间
                checkPermissions();
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
        } else if(i == R.id.iv_gift) {
            showLiveGiftDialog(false);
            //GA点击打开礼物列表
            onAnalyticsEvent(getResources().getString(R.string.Live_Broadcast_Category),
                    getResources().getString(R.string.Live_Broadcast_Action_GiftList),
                    getResources().getString(R.string.Live_Broadcast_Label_GiftList));

        } else if( i == R.id.fl_recommendGift ||i == R.id.iv_recommGiftFloat ||i == R.id.iv_recommendGift ){
            showLiveGiftDialog(null != lastRecommendGiftItem);
            //GA推荐礼物点击
            onAnalyticsEvent(getResources().getString(R.string.Live_Broadcast_Category),
                    getResources().getString(R.string.Live_Broadcast_Action_RecommendGift),
                    getResources().getString(R.string.Live_Broadcast_Label_RecommendGift));
        } else if(i == R.id.iv_intimacyPrv){
            startActivity(WebViewActivity.getIntent(this,
                    getResources().getString(R.string.live_intimacy_title_h5),
                    WebViewActivity.UrlIntent.View_Audience_Intimacy_With_Anchor,
                    mIMRoomInItem.userId,
                    true));
        } else if(i == R.id.iv_talent){
            if(null != mIMRoomInItem){
                talentManager.showTalentsList(flContentBody);
            }
            //GA点击才艺点播
            onAnalyticsEvent(getResources().getString(R.string.Live_Broadcast_Category),
                    getResources().getString(R.string.Live_Broadcast_Action_Talent),
                    getResources().getString(R.string.Live_Broadcast_Label_Talent));
        } else if(i == R.id.iv_privateLiveNow){
            closeLiveRoom();
            startActivity(LiveRoomTransitionActivity.getIntent(this,
                    LiveRoomTransitionActivity.CategoryType.Audience_Invite_Enter_Room,
                    mIMRoomInItem.userId, mIMRoomInItem.nickName, mIMRoomInItem.photoUrl,
                    null,null));
        }
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        switch(msg.what){
            case EVENT_UPDATE_RECOMMANDGIFT:
                //更新推荐礼物btn,并标记当前推荐礼物,点击推荐礼物，打开礼物列表弹框，选中并跳转显示该推荐礼物
                if(!TextUtils.isEmpty(lastRecommendGiftItem.middleImgUrl)){
                    String localImgPath = FileCacheManager.getInstance()
                            .getGiftLocalPath(lastRecommendGiftItem.id, lastRecommendGiftItem.middleImgUrl);
                    boolean localFileExists = SystemUtils.fileExists(localImgPath);
                    Log.d(TAG,"EVENT_UPDATE_RECOMMANDGIFT-localImgPath:"+localImgPath+" localFileExists:"+localFileExists);
                    if(localFileExists){
                        iv_recommendGift.setImageBitmap(ImageUtil.toRoundBitmap(ImageUtil.decodeSampledBitmapFromFile(
                                localImgPath,DisplayUtil.dip2px(mContext,39f),
                                DisplayUtil.dip2px(mContext,39f))));
                    }else{
                        FileDownloadManager.getInstance().start(lastRecommendGiftItem.middleImgUrl, localImgPath, new IFileDownloadedListener() {
                            @Override
                            public void onCompleted(boolean isSuccess, String localFilePath, String fileUrl) {
                                if(isSuccess){
                                    sendEmptyUiMessage(EVENT_UPDATE_RECOMMANDGIFT);
                                }
                            }
                        });
                    }
                }
                break;
            case EVENT_INTIMACY_LEVEL_UPDATE:
                if(null != roomThemeManager && null != mIMRoomInItem){
                    Drawable lovelLevelDrawable = roomThemeManager.getPrivateRoomLoveLevelDrawable(this,mIMRoomInItem.loveLevel);
                    if(null != lovelLevelDrawable){
                        iv_intimacyPrv.setImageDrawable(lovelLevelDrawable);
                    }
                }

                break;
            case EVENT_LEAVING_ROOM_TIMECOUNT:
                //关闭直播间倒计时
                if(leavingRoomTimeCount>=0){
                    tv_enterPrvRoomTimerCount.setText(getResources().getString(R.string.liveroom_leaving_room_time_count,
                            String.valueOf(leavingRoomTimeCount)));
                    leavingRoomTimeCount-=1;
                    sendEmptyUiMessageDelayed(EVENT_LEAVING_ROOM_TIMECOUNT,1000l);
                }
                break;
            case EVENT_TIMEOUT_BACKGROUND:
                //关闭直播间，进入过度页
                Log.d(TAG,"EVENT_TIMEOUT_BACKGROUND-app处于后台超过1分钟的时间，退出房间，提示用户");
                hasBackgroundTimeOut = true;
                Log.d(TAG,"EVENT_TIMEOUT_BACKGROUND-hasBackgroundTimeOut:"+hasBackgroundTimeOut);
                break;
            case EVENT_UPDATE_REBATE:
                IMRebateItem tempIMRebateItem =mLiveRoomCreditRebateManager.getImRebateItem();
                if(null != tempIMRebateItem && null != roomRebateTipsPopupWindow){
                    tv_rebateValue.setText(String.format ("%.2f", tempIMRebateItem.cur_credit));
                    roomRebateTipsPopupWindow.notifyReBateUpdate(tempIMRebateItem);
                }
                break;
            case EVENT_GIFT_ADVANCE_SEND_FAILED:
                //豪华非背包礼物，发送失败，弹toast，清理发送队列，关闭倒计时动画
                showThreeSecondTips(getResources().getString(R.string.live_gift_send_failed,msg.obj.toString()),
                        Gravity.BOTTOM|Gravity.CENTER_HORIZONTAL);
                if(null != liveGiftDialog){
                    liveGiftDialog.notifyGiftSentFailed(IMClientListener.LCC_ERR_TYPE.LCC_ERR_FAIL);
                }
                break;
            case EVENT_GIFT_SEND_FAILED_CREDITS_NOENOUGH:
                //非豪华非背包礼物，发送失败(信用点不足)，弹充值对话框，清理发送队列，关闭倒计时动画
                showCreditNoEnoughDialog(R.string.live_common_noenough_money_tips);
                if(null != liveGiftDialog){
                    liveGiftDialog.notifyGiftSentFailed(IMClientListener.LCC_ERR_TYPE.LCC_ERR_FAIL);
                }
                break;
            case EVENT_FAVORITE_RESULT:
                HttpRespObject hrObject = (HttpRespObject)msg.obj;
                onRecvFollowHostResp(hrObject.isSuccess,hrObject.errMsg);
                break;

            case EVENT_MESSAGE_ENTERROOMNOTICE: {
                final CarInfo carInfo = (CarInfo) msg.obj;
                if (!TextUtils.isEmpty(carInfo.riderUrl) && !TextUtils.isEmpty(carInfo.riderId)
                        && !TextUtils.isEmpty(carInfo.riderName)) {
                    //聊天区域插入座驾进入直播间消息
                    boolean playCarInAnimAfterDownImg = msg.getData().getBoolean("playCarInAnimAfterDownImg",false);
                    final String honorImg = msg.getData().getString("honorImg");
                    //避免首次未下载座驾img，下载成功后回调重复生成入场消息
                    if(!playCarInAnimAfterDownImg){
                        String str = getResources().getString(
                                R.string.enterlive_withrider, carInfo.nickName, carInfo.riderName);
                        IMMessageItem msgItem = new IMMessageItem(mIMRoomInItem.roomId,
                                mIMManager.mMsgIdIndex.getAndIncrement(),
                                honorImg,
                                IMMessageItem.MessageType.SysNotice,
                                new IMSysNoticeMessageContent(str,"",
                                        IMSysNoticeMessageContent.SysNoticeType.CarIn));
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
                    Log.d(TAG,"EVENT_MESSAGE_ENTERROOMNOTICE-localCarImgExists:"+localCarImgExists);
                    if (localCarImgExists) {
                        if(null != carManager){
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
                    liveGiftDialog.notifyStoreGiftData(giftItems);
                }
            }break;
            case EVENT_UPDATE_BACKPACKGIFT: {
                if (liveGiftDialog != null) {
                    liveGiftDialog.notifyBackPackDataChanged(msg.getData().getBoolean("isSuccess"));
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

        //同步模块直播已结束
        String targetId = "";
        if(mIMRoomInItem != null){
            targetId = mIMRoomInItem.userId;
        }

        //回收拉流播放器
        if(mLivePlayerManager != null){
            mLivePlayerManager.uninit();
            mLivePlayerManager = null;
        }
        //add by Jagger 2017-12-1
        destroyPublisher();
        //销毁互动UI
        removeCallback(mHideOperateRunnable);

        tpManager.clear();
        carManager.shutDownAnimQueueServNow();
        carManager = null;
        mModuleGiftManager.onMultiGiftDestroy();
        //清除资源及动画
        if(mBarrageManager != null) {
            mBarrageManager.onDestroy();
        }
        //退出房间成功，就清空送礼队列，并停止服务
        GiftSendReqManager.getInstance().shutDownReqQueueServNow();
        normalGiftManager.unregisterListener(mIMRoomInItem.roomId);
        packageGiftManager.unregisterListener(mIMRoomInItem.roomId);
        //推荐礼物
        if(null != giftRecommandManager){
            giftRecommandManager.setRecommandListener(null);
            giftRecommandManager.stopRecommand();
            giftRecommandManager = null;
        }

        //del by Jagger 2017-12-1
        //清除互动相关
//        onPublisherDestroy();

        //清理资费提示manager
        if(mIMRoomInItem.roomType != IMLiveRoomType.FreePublicRoom){
            roomRebateTipsPopupWindow.release();
            if(roomRebateTipsPopupWindow.isShowing()){
                roomRebateTipsPopupWindow.dismiss();
            }
            roomRebateTipsPopupWindow = null;
        }
        removeUiMessages(EVENT_TIMEOUT_BACKGROUND);
        removeUiMessages(EVENT_LEAVING_ROOM_TIMECOUNT);
        //才艺
        if(null != talentManager){
            talentManager.release();
        }
        talentManager = null;

        if(null != vedioLoadingAnimManager){
            vedioLoadingAnimManager.hideLoadingAnim();
        }
    }

    /**
     * 关闭直播间
     */
    public void closeLiveRoom(){
        Log.d(TAG,"closeLiveRoom");
        if(null != mIMRoomInItem && !TextUtils.isEmpty(mIMRoomInItem.roomId) && null != mIMManager){
            mIMManager.RoomOut(mIMRoomInItem.roomId);
        }
        finish();
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if(keyCode == KeyEvent.KEYCODE_BACK && event.getAction() == KeyEvent.ACTION_DOWN){
            //拦截返回键
            closeRoomByUser = true;
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
    protected View.OnClickListener tpOKClickListener = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            showRoomTariffPrompt(null,false);
            if(null != tpManager){
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
            if(null != view_tariff_prompt && view_tariff_prompt.getVisibility() == View.GONE){
                isUserWantSeeTariffPrompt = true;
                if(null != tpManager){
                    tpManager.getRoomTariffInfo(BaseCommonLiveRoomActivity.this);
                }
                Message msg = Message.obtain();
                msg.what =EVENT_MESSAGE_HIDE_TARIFFPROMPT;
                sendUiMessageDelayed(msg,3000l);
            }
        }
    };

    private void initRoomHeader(){
        view_roomHeader = findViewById(R.id.view_roomHeader);
        view_roomHeader.setOnClickListener(this);
        iv_roomHeaderBg = (ImageView) findViewById(R.id.iv_roomHeaderBg);
        lrhbv_flag = (LiveRoomHeaderBezierView) findViewById(R.id.lrhbv_flag);
        iv_roomFlag = (ImageView) findViewById(R.id.iv_roomFlag);
        RelativeLayout.LayoutParams roomFlagLp = (RelativeLayout.LayoutParams) iv_roomFlag.getLayoutParams();
        findViewById(R.id.ll_closeLiveRoom).setOnClickListener(this);
        //背景图高度写死
        if(null != mIMRoomInItem){
            FrameLayout.LayoutParams lp1 = (FrameLayout.LayoutParams)iv_roomHeaderBg.getLayoutParams();
            lp1.height = roomThemeManager.getRoomHeadViewHeight(this,mIMRoomInItem.roomType);
            iv_roomHeaderBg.setLayoutParams(lp1);
            iv_roomFlag.setImageDrawable(roomThemeManager.getRoomFlagDrawable(this,mIMRoomInItem.roomType));
            roomFlagLp.height =roomThemeManager.getRoomFlagHeight(this,mIMRoomInItem.roomType);
            roomFlagLp.topMargin = roomThemeManager.getRoomFlagTopMargin(this,mIMRoomInItem.roomType);
            roomFlagLp.bottomMargin = roomThemeManager.getRoomFlagBottomMargin(this,mIMRoomInItem.roomType);
            iv_roomFlag.setLayoutParams(roomFlagLp);

        }
        iv_roomFlag.measure(0,0);
        //资费提示
        view_tariff_prompt = findViewById(R.id.view_tariff_prompt);
        FrameLayout.LayoutParams tpLp = (FrameLayout.LayoutParams) view_tariff_prompt.getLayoutParams();
        tpLp.topMargin = iv_roomFlag.getMeasuredHeight()+roomFlagLp.topMargin+tpLp.topMargin;
        tpLp.width = iv_roomFlag.getMeasuredWidth();
        view_tariff_prompt.setLayoutParams(tpLp);
        btn_OK = (Button) findViewById(R.id.btn_OK);
        btn_OK.setOnClickListener(tpOKClickListener);
        iv_roomFlag.setOnClickListener(roomFlagClickListener);
        tpManager = new TariffPromptManager(this);
        tv_triffMsg = (TextView) findViewById(R.id.tv_triffMsg);
        if(null != mIMRoomInItem){
            tpManager.init(mIMRoomInItem).getRoomTariffInfo(this);
        }

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
        if(null != mIMRoomInItem){
            LinearLayout.LayoutParams buttomLineLp = (LinearLayout.LayoutParams) view_roomHeader_buttomLine.getLayoutParams();
            buttomLineLp.height = roomThemeManager.getRoomHeadViewButtomLineHeight(this,mIMRoomInItem.roomType);
            view_roomHeader_buttomLine.setLayoutParams(buttomLineLp);
        }
    }

    private void initRoomViewDataAndStyle(){
        int color = roomThemeManager.getRootViewTopColor(this,mIMRoomInItem.roomType);
        StatusBarUtil.setColor(this,color,0);
        lrhbv_flag.setRoomHeaderBgColor(color);
        iv_roomHeaderBg.setImageDrawable(roomThemeManager.getRoomHeaderViewBgDrawable(this,mIMRoomInItem.roomType));
        flContentBody.setBackgroundDrawable(roomThemeManager.getRoomThemeDrawable(this,mIMRoomInItem.roomType));
        if(mIMRoomInItem.roomType==IMLiveRoomType.NormalPrivateRoom
                || mIMRoomInItem.roomType==IMLiveRoomType.AdvancedPrivateRoom){
            iv_prvUserIconBg.setImageDrawable(roomThemeManager.getPrivateRoomUserIconBg(this,mIMRoomInItem.roomType));
            iv_prvHostIconBg.setImageDrawable(roomThemeManager.getPrivateRoomHostIconBg(this,mIMRoomInItem.roomType));
            if(null != mIMRoomInItem && !TextUtils.isEmpty((mIMRoomInItem.photoUrl))){
                Picasso.with(getApplicationContext())
                        .load(mIMRoomInItem.photoUrl)
                        .error(R.drawable.ic_default_photo_woman)
                        .placeholder(R.drawable.ic_default_photo_woman)
                        .into(civ_prvHostIcon);
            }
            if(null != loginItem && !TextUtils.isEmpty(loginItem.photoUrl)){
                Picasso.with(getApplicationContext())
                        .load(loginItem.photoUrl)
                        .error(R.drawable.ic_default_photo_man)
                        .placeholder(R.drawable.ic_default_photo_man)
                        .into(civ_prvUserIcon);
            }
            Drawable prvFollowDrawable = roomThemeManager.getPrivateRoomFollowBtnDrawable(this,mIMRoomInItem.roomType);
            if(null != prvFollowDrawable){
                iv_followPrvHost.setImageDrawable(prvFollowDrawable);
            }

            Drawable lovelLevelDrawable = roomThemeManager.getPrivateRoomLoveLevelDrawable(this,mIMRoomInItem.loveLevel);
            if(null != lovelLevelDrawable){
                iv_intimacyPrv.setImageDrawable(lovelLevelDrawable);
            }
        }else{
            tv_hostName.setText(mIMRoomInItem.nickName);
        }
        //是否已经关注
        onRecvFollowHostResp(mIMRoomInItem.isFavorite,"");
    }

    protected void updatePublicRoomOnlineData(int fansNum){
        Log.d(TAG,"updatePublicRoomOnlineData-fansNum:"+fansNum);
        tv_onlineNum.setVisibility(fansNum >0 ? View.VISIBLE : View.GONE);
        tv_onlineNum.setText(String.valueOf(fansNum));
        tv_vipGuestData.setText(getResources().getString(R.string.liveroom_header_vipguestdata,
                String.valueOf(fansNum),String.valueOf(mIMRoomInItem.audienceLimitNum)));
        //查询头像列表
        LiveRequestOperator.getInstance().GetAudienceListInRoom(mIMRoomInItem.roomId,0,0,this);
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
        startActivity(AnchorProfileActivity.getAnchorInfoIntent(this,
                getResources().getString(R.string.live_webview_anchor_profile_title),
                mIMRoomInItem.userId, false));
    }

    /**
     * 关注主播，用户端的实现类，
     * 需要在调用关注接口成功后，通过super.sendFollowHotRseq()实现界面的交互响应
     */
    public void sendFollowHostReq(){
        if(null != mIMRoomInItem){
            Log.d(TAG,"sendFollowHostReq-hostId:"+mIMRoomInItem.userId);
            //接口调用
            LiveRequestOperator.getInstance().AddOrCancelFavorite(mIMRoomInItem.userId, mIMRoomInItem.roomId, true, new OnRequestCallback() {
                @Override
                public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                    Log.d(TAG,"sendFollowHostReq-AddOrCancelFavorite-isSuccess:"+isSuccess+" errCode:"+errCode+" errMsg:"+errMsg);
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
        Log.d(TAG,"onRecvFollowHostResp-isSuccess:"+isSuccess+" errMsg:"+errMsg);
        if(!TextUtils.isEmpty(errMsg)){
            showToast(errMsg);
        }
        iv_follow.setVisibility(isSuccess ? View.GONE : View.VISIBLE);
        iv_followPrvHost.setVisibility(isSuccess ? View.GONE : View.VISIBLE);
    }

    /**
     * 播放房间header的淡入动画
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
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                onDisconnectRoomIn();
            }
        });
    }

    //******************************** 视频播放组件 ****************************************************************
    private void initVideoPlayer(){
        include_audience_area = findViewById(R.id.include_audience_area);
        iv_vedioBg = (ImageView) findViewById(R.id.iv_vedioBg);
        //视频播放组件
        sv_player = (SurfaceView)findViewById(R.id.sv_player);
        //add by Jagger 2017-11-29 解决小窗口能浮在大窗口上的问题
//        sv_player.getHolder().setFormat(PixelFormat.TRANSPARENT);

        rl_media = findViewById(R.id.rl_media);
        rl_media.setOnClickListener(this);

        int screenWidth = DisplayUtil.getScreenWidth(BaseCommonLiveRoomActivity.this);
        int scaleHeight= screenWidth*3/4;
        //具体的宽高比例，其实也可以根据服务器动态返回来控制
        RelativeLayout.LayoutParams svPlayerLp = (RelativeLayout.LayoutParams)sv_player.getLayoutParams();
        RelativeLayout.LayoutParams ivVedioBgLp = (RelativeLayout.LayoutParams)iv_vedioBg.getLayoutParams();
        LinearLayout.LayoutParams rlMediaLp = (LinearLayout.LayoutParams)rl_media.getLayoutParams();
        view_roomHeader.measure(0,0);
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
        mLivePlayerManager.init(sv_player);

        sdv_vedioLoading = (SimpleDraweeView) findViewById(R.id.sdv_vedioLoading);
        sdv_vedioLoading.setVisibility(View.GONE);
        vedioLoadingAnimManager = new VedioLoadingAnimManager(this,sdv_vedioLoading);
    }

    /**
     * 开始拉流
     * @param videoUrls
     */
    private void startLivePlayer(String[] videoUrls){
        if(mLivePlayerManager != null && mLivePlayerManager.isInited()){
            mLivePlayerManager.setOrChangeVideoUrls(videoUrls, "", "", "");

            if(videoUrls != null && videoUrls.length > 0) {
                //处理停止视频加载中
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (null != vedioLoadingAnimManager) {
                            vedioLoadingAnimManager.hideLoadingAnim();
                        }
                        if(null != mIMRoomInItem && mIMRoomInItem.roomType!= IMLiveRoomType.FreePublicRoom) {
                            Drawable drawable = null;
                            if (null != roomThemeManager) {
                                drawable = roomThemeManager.getRoomCreditsBgDrawable(BaseCommonLiveRoomActivity.this,
                                        mIMRoomInItem.roomType);
                            }
                            if (null != drawable) {
                                ll_rebate.setBackgroundDrawable(drawable);
                                ll_rebate.setVisibility(View.VISIBLE);
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
                if(null != pw_audienceBalanceInfo && pw_audienceBalanceInfo.isShowing()){
                    pw_audienceBalanceInfo.updateBalanceViewData();
                }
            }
        });
    }

    //------------------------用户信用点信息对话框-----------------------------------------
    protected AudienceBalanceInfoPopupWindow pw_audienceBalanceInfo;

    public void showAudienceBalanceInfoDialog(View rootView){
        if(null == pw_audienceBalanceInfo){
            pw_audienceBalanceInfo = new AudienceBalanceInfoPopupWindow(getApplicationContext());
            pw_audienceBalanceInfo.setBackgroundDrawable(new ColorDrawable(Color.WHITE));
        }
        pw_audienceBalanceInfo.setUserLevel(mIMRoomInItem.manLevel);
        pw_audienceBalanceInfo.showAtLocation(rootView,Gravity.BOTTOM, ViewGroup.LayoutParams.FILL_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT);

    }

    //-----------------------亲密度说明----------------------------------------
    private void showUserIntimacyWithHostPopupWindow(){
        if(null == userIntimacyWithHostPopupWindow){
            userIntimacyWithHostPopupWindow = new UserIntimacyWithHostPopupWindow(this);
            userIntimacyWithHostPopupWindow.setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
        }
        if(null != mIMRoomInItem){
            userIntimacyWithHostPopupWindow.updateViewData(mIMRoomInItem.nickName,mIMRoomInItem.loveLevel);
        }
        if(!userIntimacyWithHostPopupWindow.isShowing()){
            userIntimacyWithHostPopupWindow.showAtLocation(flContentBody, Gravity.CENTER,0,0);
        }
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
    }

    public void reloadPkgGiftData(){
        Log.d(TAG,"reloadPkgGiftData");
        if(null != packageGiftManager){
            packageGiftManager.getAllPackageGiftItems(null);
        }
    }

    public void reloadStoreGiftData(){
        if(null != mIMRoomInItem && !TextUtils.isEmpty(mIMRoomInItem.roomId) && null != normalGiftManager){
            normalGiftManager.getSendableGiftItems(mIMRoomInItem.roomId,this);
            normalGiftManager.getAllGiftItems(this);
        }
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
        if(null != mIMRoomInItem){
            liveGiftDialog.setImRoomInItem(mIMRoomInItem);
        }
    }

    protected void showLiveGiftDialog(boolean showPromoGift){
        Log.d(TAG,"showLiveGiftDialog-showPromoGift:"+showPromoGift);
        initLiveGiftDialog();
        liveGiftDialog.show(showPromoGift ? lastRecommendGiftItem : null);
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
        //推荐礼物
        if(null != mIMRoomInItem && (mIMRoomInItem.roomType == IMLiveRoomType.NormalPrivateRoom
                || mIMRoomInItem.roomType == IMLiveRoomType.AdvancedPrivateRoom)){
            giftRecommandManager = new GiftRecommandManager(this);
            giftRecommandManager.setRecommandListener(this);
        }
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

    @Override
    public void OnSendGift(boolean success, final IMClientListener.LCC_ERR_TYPE errType, String errMsg,
                           IMMessageItem msgItem, double credit, double rebateCredit) {
        super.OnSendGift(success,errType,errMsg,msgItem,credit,rebateCredit);
        if(errType != IMClientListener.LCC_ERR_TYPE.LCC_ERR_SUCCESS){
            //需要查询是否是大礼物发送失败，提示用户
            final Message msg = Message.obtain();
            if(errType == LCC_ERR_NO_CREDIT){
                msg.what = EVENT_GIFT_SEND_FAILED_CREDITS_NOENOUGH;
                sendUiMessage(msg);
            }else{
                if(null != msgItem && null != msgItem.giftMsgContent){
                    GiftItem giftDetail = normalGiftManager.getLocalGiftDetail(msgItem.giftMsgContent.giftId);
                    if(null != giftDetail && giftDetail.giftType == GiftItem.GiftType.Advanced){
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
        if(null!=normalGiftManager && null != mIMRoomInItem && !TextUtils.isEmpty(mIMRoomInItem.roomId)){
            normalGiftManager.getSendableGiftItems(mIMRoomInItem.roomId,this);
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
    public void onGetSendableGiftList(boolean isSuccess, int errCode, String errMsg, SendableGiftItem[] giftIds) {
        super.onGetSendableGiftList(isSuccess, errCode, errMsg, giftIds);
        if(isSuccess){
            if(null != giftRecommandManager){
                giftRecommandManager.startRecommand();
            }
        }
    }

    @Override
    public void onGiftRecommand(final GiftItem giftItem) {
        super.onGiftRecommand(giftItem);
        //获取到推荐礼物
        lastRecommendGiftItem = giftItem;
        sendEmptyUiMessage(EVENT_UPDATE_RECOMMANDGIFT);
    }

    @Override
    public void OnRecvRoomGiftNotice(IMMessageItem msgItem) {
        super.OnRecvRoomGiftNotice(msgItem);
        sendMessageUpdateEvent(msgItem);
    }


    @Override
    public void onPkgGiftDataChanged(boolean isSuccess, String currRoomId) {
        super.onPkgGiftDataChanged(isSuccess,currRoomId);
        if(!currRoomId.equals(mIMRoomInItem.roomId)){
           return;
        }
        Message msg = Message.obtain();
        msg.what = EVENT_UPDATE_BACKPACKGIFT;
        Bundle bundle = msg.getData();
        bundle.putBoolean("isSuccess",isSuccess);
        sendUiMessage(msg);
    }

    //******************************** 预约私密直播 **************************************************
    private void initPrePriView(){
        iv_privateLiveNow = (ImageView) findViewById(R.id.iv_privateLiveNow);
        if(null != mIMRoomInItem){
            Drawable drawable = roomThemeManager.getRoomPriLiveNowBtnDrawable(this,mIMRoomInItem.roomType);
            if(null != drawable){
                iv_privateLiveNow.setImageDrawable(drawable);
            }else{
                iv_privateLiveNow.setVisibility(View.GONE);
            }
            if(IMLiveRoomType.FreePublicRoom == mIMRoomInItem.roomType || IMLiveRoomType.PaidPublicRoom == mIMRoomInItem.roomType){
                iv_privateLiveNow.setVisibility(View.VISIBLE);
            }else{
                iv_privateLiveNow.setVisibility(View.GONE);
            }
        }

        ll_enterPriRoomTimeCount = (LinearLayout) findViewById(R.id.ll_enterPriRoomTimeCount);
        iv_privateLiveNow.setOnClickListener(this);
        ll_enterPriRoomTimeCount.setVisibility(View.GONE);
        tv_enterPrvRoomTimerCount = (TextView) findViewById(R.id.tv_enterPrvRoomTimerCount);
    }

    //******************************** 入场座驾 ******************************************************
    protected CarManager carManager = new CarManager();

    private void initLiveRoomCar(){
        FrameLayout.LayoutParams lp = (FrameLayout.LayoutParams) ll_rebate.getLayoutParams();
        ll_rebate.measure(0,0);
        int mH = ll_rebate.getMeasuredHeight();
        ll_entranceCar = (LinearLayout) findViewById(R.id.ll_entranceCar);
        int topMargin = (int) getResources().getDimension(R.dimen.liveroom_rebate_tips_margintop);
        carManager.init(this,ll_entranceCar,mH+topMargin);
    }

    private void initRebateView(){
        //ll_rebate从原本的im浮层布局移到
        ll_rebate = findViewById(R.id.ll_rebate);
        view_roomHeader.measure(0,0);
        int roomHeaderMeasuredHeight = view_roomHeader.getMeasuredHeight();
        FrameLayout.LayoutParams lp = (FrameLayout.LayoutParams)ll_rebate.getLayoutParams();
        lp.topMargin+=roomHeaderMeasuredHeight;
        ll_rebate.setLayoutParams(lp);
        tv_rebateTips = (TextView) findViewById(R.id.tv_rebateTips);
        tv_rebateTips.setText(getResources().getString(R.string.tip_roomGiftCredit," "));
        tv_rebateValue = (TextView) findViewById(R.id.tv_rebateValue);

        ll_rebate.setOnClickListener(this);
        if((null != mIMRoomInItem && mIMRoomInItem.roomType != IMLiveRoomType.FreePublicRoom)){
            roomRebateTipsPopupWindow = new RoomRebateTipsPopupWindow(this);
            roomRebateTipsPopupWindow.setListener(this);
        }
    }

    @Override
    public void OnRecvEnterRoomNotice(String roomId, String userId, String nickName,
                                      String photoUrl, String riderId, String riderName,
                                      String riderUrl, int fansNum, String honorImg) {
        super.OnRecvEnterRoomNotice(roomId,userId,nickName,photoUrl,riderId,riderName,riderUrl,fansNum, honorImg);
        Log.d(TAG,"OnRecvEnterRoomNotice-userId:"+userId);
        if(!TextUtils.isEmpty(userId) && null != loginItem && userId.equals(loginItem.userId)){
            //断线重登陆，接收到自己的进入房间通知，过滤处理
            Log.d(TAG,"OnRecvEnterRoomNotice-断线重登陆，接收到自己的进入房间通知，过滤处理");
            return;
        }
        if(null != mIMManager){
            mIMManager.updateOrAddUserBaseInfo(new IMUserBaseInfoItem(userId,nickName,photoUrl));
        }
        addEnterRoomMsgToList(roomId,userId,nickName,riderId,riderName,riderUrl,honorImg);
    }

    @Override
    public void onGetAudienceDetailInfo(boolean isSuccess, int errCode, String errMsg, AudienceBaseInfoItem audienceInfo) {
        super.onGetAudienceDetailInfo(isSuccess, errCode, errMsg, audienceInfo);
        Message msg = null;
        Log.d(TAG,"onGetAudienceDetailInfo-audienceInfo.userId:"+audienceInfo.userId);
        if(isSuccess && null != loginItem && audienceInfo.userId.equals(loginItem.userId)){
            addEnterRoomMsgToList(mIMRoomInItem.roomId,audienceInfo.userId,audienceInfo.nickName,
                    audienceInfo.riderId,audienceInfo.riderName,audienceInfo.riderUrl,mIMRoomInItem.honorImg);
        }
    }

    private void addEnterRoomMsgToList(String roomId,String userId,String nickName,String riderId,
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
            bundle.putBoolean("playCarInAnimAfterDownImg",false);
            msg.setData(bundle);
            msg.obj = carInfo;
            sendUiMessage(msg);
        }else{
            IMMessageItem msgItem = new IMMessageItem(roomId,
                    mIMManager.mMsgIdIndex.getAndIncrement(), userId,
                    nickName, honorImg, mIMRoomInItem.manLevel, IMMessageItem.MessageType.RoomIn, null,null);
            msg = Message.obtain();
            msg.what = EVENT_MESSAGE_UPDATE;
            msg.obj = msgItem;
            sendUiMessage(msg);
        }
    }

    //******************************** 弹幕消息编辑区域处理 ********************************************
    private TextWatcher tw_msgEt;
    private static int liveMsgMaxLength = 10;
    private String lastInputEmoSign = null;
    /**
     * 处理编辑框区域view初始化
     */
    @SuppressWarnings("WrongConstant")
    private void initEditAreaView(){
        liveMsgMaxLength = getResources().getInteger(R.integer.liveMsgMaxLength);
        //共用的软键盘弹起输入部分
        rl_inputMsg = findViewById(R.id.rl_inputMsg);
        ll_input_edit_body = (LinearLayout)findViewById(R.id.ll_input_edit_body);
        v_roomEditMegBg = (ImageView) findViewById(R.id.iv_roomEditMegBg);
        ll_roomEditMsgiInput = (LinearLayout)findViewById(R.id.ll_roomEditMsgiInput);
        iv_msgType = (ImageView)findViewById(R.id.iv_msgType);
        iv_msgType.setOnClickListener(this);
        et_liveMsg = (EditText)findViewById(R.id.et_liveMsg);
        if(null != mIMRoomInItem){
            iv_msgType.setImageDrawable(roomThemeManager.getRoomMsgTypeSwitchDrawable(this,mIMRoomInItem.roomType,isBarrage));
            et_liveMsg.setHintTextColor(roomThemeManager.getRoomETHintTxtColor(mIMRoomInItem.roomType,isBarrage));
        }
        String editHint = "";
        if(isBarrage){
            double price = 0.0;
            if(mIMRoomInItem != null){
                price = mIMRoomInItem.popPrice;
            }
            editHint = String.format(getResources().getString(R.string.txt_hint_input_barrage), String.valueOf(price));
        }else{
            editHint = getResources().getString(R.string.txt_hint_input_general);
        }
        et_liveMsg.setHint(editHint);
//        et_liveMsg.setHint(isBarrage ? R.string.txt_hint_input_barrage : R.string.txt_hint_input_general);
        et_liveMsg.setOnClickListener(this);
        et_liveMsg.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                Log.d(TAG,"onFocusChange-hasFocus:"+hasFocus);
                if (hasFocus && etsl_emojiContainer.getVisibility() == View.VISIBLE) {
                    etsl_emojiContainer.setVisibility(View.GONE);
                    iv_emojiSwitch.setImageDrawable(getResources().getDrawable(R.drawable.ic_liveroom_emojiswitch));
                }
            }
        });
        iv_sendMsg = (ImageView)findViewById(R.id.iv_sendMsg);
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
                    Log.logD(TAG,"afterTextChanged-s:"+s.toString());
                    if(null != et_liveMsg){
                        if(s.toString().length()>liveMsgMaxLength){
                            int selectedStartIndex = et_liveMsg.getSelectionStart();
                            int selectedEndIndex = et_liveMsg.getSelectionEnd();
                            if(etsl_emojiContainer.getVisibility() == View.VISIBLE && !TextUtils.isEmpty(lastInputEmoSign)){
                                s.delete(selectedEndIndex-lastInputEmoSign.length(),selectedEndIndex);
                                lastInputEmoSign = null;
                            }else{
                                s.delete(selectedStartIndex-1,selectedEndIndex);
                            }
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
        etsl_emojiContainer.setTabTitles(ChatEmojiManager.getInstance().getEmotionTagNames());
        etsl_emojiContainer.setItemMap(ChatEmojiManager.getInstance().getTagEmotionMap());
        //xml来控制
        etsl_emojiContainer.setViewStatusChangedListener(
                new EmojiTabScrollLayout.ViewStatusChangeListener() {
                    @Override
                    public void onTabClick(int position, String title) {
                        //这里position基本就是title在EmotionTagNames和TagEmotionMap里面的排序
                        Log.d(TAG,"initEditAreaView-onTabClick position:"+position+" title:"+title);
                        String emoUnusableTips = null;
                        Map<String,EmotionCategory> emoNameCates = ChatEmojiManager.getInstance().getTagEmotionMap();
                        boolean currEmoTypeSendable = false;
                        if(null != mIMRoomInItem && null != mIMRoomInItem.emoTypeList){
                            int index = 0;
                            for(;index<mIMRoomInItem.emoTypeList.length; index++){
                                currEmoTypeSendable =mIMRoomInItem.emoTypeList[index] == position;
                                if(currEmoTypeSendable){
                                    break;
                                }
                            }
                            if(!currEmoTypeSendable && index==mIMRoomInItem.emoTypeList.length && null != emoNameCates){
                                EmotionCategory emotionCategory = emoNameCates.get(title);
                                if(null != emotionCategory){
                                    emoUnusableTips =emotionCategory.emotionErrorMsg;
                                }
                            }
                        }
                        Log.d(TAG,"initEditAreaView-onTabClick emoUnusableTips:"+emoUnusableTips+" currEmoTypeSendable:"+currEmoTypeSendable);
                        etsl_emojiContainer.setUnusableTip(emoUnusableTips);
                    }

                    @Override
                    public void onGridViewItemClick(View itemChildView,int position, String title, Object obj) {
                        chooseEmotionItem = (EmotionItem) obj;
                        et_liveMsg.append(chooseEmotionItem.emoSign);
                        lastInputEmoSign = chooseEmotionItem.emoSign;
                    }
                });
        etsl_emojiContainer.notifyDataChanged();
        iv_emojiSwitch = (ImageView)findViewById(R.id.iv_emojiSwitch);
        iv_emojiSwitch.setImageDrawable(getResources().getDrawable(R.drawable.ic_liveroom_emojiswitch));
        //底部输入+礼物btn
        iv_freePublicBg1 = (ImageView) findViewById(R.id.iv_freePublicBg1);
        iv_freePublicBg2 = (ImageView) findViewById(R.id.iv_freePublicBg2);
        iv_freePublicBg1.setVisibility(View.GONE);
        iv_freePublicBg2.setVisibility(View.GONE);
        ll_buttom_audience = findViewById(R.id.ll_buttom_audience);
        iv_inputMsg = (ImageView) findViewById(R.id.iv_inputMsg);
        iv_gift = (ImageView) findViewById(R.id.iv_gift);
        iv_recommendGift = (ImageView) findViewById(R.id.iv_recommendGift);
        iv_recommGiftFloat = (ImageView) findViewById(R.id.iv_recommGiftFloat);
        iv_talent = (ImageView) findViewById(R.id.iv_talent);
        iv_talent.setVisibility(View.GONE);

        fl_recommendGift = findViewById(R.id.fl_recommendGift);
        fl_recommendGift.setVisibility(View.GONE);
        fl_recommendGift.setOnClickListener(this);
        if(null != mIMRoomInItem){
            ll_input_edit_body.setBackgroundDrawable(roomThemeManager.getRoomETBgDrawable(this,mIMRoomInItem.roomType));
            v_roomEditMegBg.setImageDrawable(roomThemeManager.getRoomInputBgDrawable(this,mIMRoomInItem.roomType));
            iv_sendMsg.setImageDrawable(roomThemeManager.getRoomSendMsgBtnDrawable(this,mIMRoomInItem.roomType));
            iv_emojiSwitch.setVisibility(roomThemeManager.getRoomInputEmojiSwitchVisiable(this,mIMRoomInItem.roomType));
            //say something...
            Drawable inputDrawalbe = roomThemeManager.getRoomInputBtnDrawable(this,mIMRoomInItem.roomType);
            if(null != inputDrawalbe){
                iv_inputMsg.setImageDrawable(inputDrawalbe);
            }

            et_liveMsg.setTextColor(roomThemeManager.getRoomETTxtColor(mIMRoomInItem.roomType));

            //才艺点播按钮
            if(mIMRoomInItem.roomType == IMLiveRoomType.AdvancedPrivateRoom){
                iv_talent.setVisibility(View.VISIBLE);
            }

            //推荐礼物按钮
            int leftMargin = roomThemeManager.getRoomRecommGiftBtnLeftMargin(this,mIMRoomInItem.roomType);
            fl_recommendGift.setVisibility(0 == leftMargin ? View.GONE : View.VISIBLE);
            LinearLayout.LayoutParams recommGiftBtnLp = (LinearLayout.LayoutParams) fl_recommendGift.getLayoutParams();
            recommGiftBtnLp.leftMargin = leftMargin;
            fl_recommendGift.setLayoutParams(recommGiftBtnLp);
            Drawable recGiftDrawable = roomThemeManager.getRoomRecommGiftFloatDrawable(this,mIMRoomInItem.roomType);
            if(null != recGiftDrawable){
                iv_recommGiftFloat.setImageDrawable(recGiftDrawable);
            }

            //礼物按钮
            LinearLayout.LayoutParams giftBtnLp = (LinearLayout.LayoutParams) iv_gift.getLayoutParams();
            giftBtnLp.leftMargin = roomThemeManager.getRoomGiftBtnLeftMargin(this,mIMRoomInItem.roomType);
            iv_gift.setLayoutParams(giftBtnLp);
            Drawable giftDrawalbe = roomThemeManager.getRoomGiftBtnDrawable(this,mIMRoomInItem.roomType);
            if(null != giftDrawalbe){
                iv_gift.setImageDrawable(giftDrawalbe);
            }
        }
    }

    //显示免费公开直播间底部的背景图片-欢呼粉丝群.jpg
    protected void showFreePublicRoomButtomImGBg(){
        iv_freePublicBg1.setVisibility(View.VISIBLE);
        iv_freePublicBg2.setVisibility(View.VISIBLE);
    }

    private void initEditAreaViewStyle(){
        if(null != mIMRoomInItem && mIMRoomInItem.roomType == IMLiveRoomType.FreePublicRoom){
            iv_emojiSwitch.setVisibility(View.GONE);
        }
    }

    /**
     * 切换当前编辑状态（弹幕/普通消息）
     */
    private void switchEditType(){
        isBarrage = !isBarrage;
        if(null != mIMRoomInItem){
            iv_msgType.setImageDrawable(roomThemeManager.getRoomMsgTypeSwitchDrawable(this,mIMRoomInItem.roomType,isBarrage));
            et_liveMsg.setHintTextColor(roomThemeManager.getRoomETHintTxtColor(mIMRoomInItem.roomType,isBarrage));
        }
        ll_input_edit_body.setSelected(isBarrage);

        String editHint = "";
        if(isBarrage){
            double price = 0.0;
            if(mIMRoomInItem != null){
                price = mIMRoomInItem.popPrice;
            }
            editHint = String.format(getResources().getString(R.string.txt_hint_input_barrage), String.valueOf(price));
        }else{
            editHint = getResources().getString(R.string.txt_hint_input_general);
        }
        et_liveMsg.setHint(editHint);
//        et_liveMsg.setHint(isBarrage ? R.string.txt_hint_input_barrage : R.string.txt_hint_input_general);
    }

    /**
     * 发送文本或弹幕消息
     * @param isBarrage
     */
    public boolean sendTextMessage(boolean isBarrage){
        boolean result = false;
        sendTextMessagePreProcess(isBarrage);
        String message = et_liveMsg.getText().toString();
        IMMessageItem msgItem = null;
        if(!TextUtils.isEmpty(message)) {
            if(null != mIMRoomInItem && !TextUtils.isEmpty(mIMRoomInItem.roomId)){
                if (isBarrage) {
                    if(LiveRoomCreditRebateManager.getInstance().getCredit()<mIMRoomInItem.popPrice){
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
    @SuppressLint("WrongViewCast")
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

        //add by Jagger
        doMovePublishViewUnderEditView();
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
        if(etsl_emojiContainer.getVisibility() != View.VISIBLE){
            ll_buttom_audience.setVisibility(View.VISIBLE);

            if(rl_inputMsg != null){
                rl_inputMsg.setVisibility(View.INVISIBLE);
            }
        }
        //判断是否弹幕播放中，是则显示底部白底阴影
        mBarrageManager.changeBulletScreenBg(true);

        //add by Jagger
        doReMovePublishView();
    }

    //******************************** 消息展示列表 ****************************************************************
    /**
     * 初始化消息展示列表
     */
    private void initMessageList(){
        liveRoomChatManager = new LiveRoomChatManager(this);
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

    protected WarningDialog warningDialog;

    protected void showWarningDialog(String warnContent){
        Log.d(TAG,"showWarningDialog-warnContent:"+warnContent);
        if(null == warningDialog){
            warningDialog = new WarningDialog(this);
        }
        warningDialog.show(warnContent);
    }

    //******************************** 弹幕动画 ****************************************************************
    private BarrageManager<IMMessageItem> mBarrageManager;

    /**
     * 初始化弹幕
     */
    private void initBarrage(){
        if(null != mIMRoomInItem){
            ll_bulletScreen.setBackgroundDrawable(roomThemeManager.getRoomBarrageBgDrawable(mIMRoomInItem.roomType));
        }
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
                    tv_bulletContent.setText(ChatEmojiManager.getInstance().parseEmoji(BaseCommonLiveRoomActivity.this,
                            TextUtils.htmlEncode(item.textMsgContent.message),
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
            mBarrageManager.addBarrageItem(msgItem);
        }
    }

    @Override
    public void OnSendBarrage(boolean success, IMClientListener.LCC_ERR_TYPE errType,
                              String errMsg, IMMessageItem msgItem, double credit,
                              double rebateCredit) {
        super.OnSendBarrage(success,errType,errMsg,msgItem,credit,rebateCredit);
        if(errType != IMClientListener.LCC_ERR_TYPE.LCC_ERR_SUCCESS){
            //需要查询是否是大礼物发送失败，提示用户
            if(errType == LCC_ERR_NO_CREDIT){
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
        super.OnRoomOut(reqId,success,errType,errMsg);
    }

    @Override
    public void OnRecvRoomToastNotice(IMMessageItem msgItem) {
        super.OnRecvRoomToastNotice(msgItem);
        sendMessageUpdateEvent(msgItem);
    }

    @Override
    public void OnRecvRoomKickoffNotice(String roomId, final IMClientListener.LCC_ERR_TYPE err, final String errMsg, double credit) {
        super.OnRecvRoomKickoffNotice(roomId, err, errMsg, credit);

        removeUiMessages(EVENT_TIMEOUT_BACKGROUND);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                LiveRoomNormalErrorActivity.PageErrorType pageErrorType = LiveRoomNormalErrorActivity.PageErrorType.PAGE_ERROR_LIEV_EDN;
                if (err == LCC_ERR_NO_CREDIT) {
                    pageErrorType = PAGE_ERROR_NOMONEY;
                }
                if(isActivityVisible()){
                    endLive(pageErrorType, errMsg, false);
                }else{
                    mIsNeedRecommand = false;
                    mIsRoomBackgroundClose = true;
                    mCloseErrMsg = errMsg;
                    mClosePageErrorType = pageErrorType;
                }
            }
        });
    }

    @Override
    public void OnRecvLackOfCreditNotice(String roomId, String message, double credit) {
        super.OnRecvLackOfCreditNotice(roomId, message, credit);
        Log.d(TAG,"OnRecvLackOfCreditNotice-hasShowCreditsLackTips:"+hasShowCreditsLackTips);
        if(!hasShowCreditsLackTips){
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
                new IMSysNoticeMessageContent(getResources().getString(R.string.system_notice_level_upgraded,String.valueOf(level)),
                        null, IMSysNoticeMessageContent.SysNoticeType.Normal));
        Log.d(TAG,"OnRecvLevelUpNotice-msg:"+imMessageItem.sysNoticeContent.message+" link:"+imMessageItem.sysNoticeContent.link);
        if(null != loginItem){
            loginItem.level= level;
        }
        sendMessageUpdateEvent(imMessageItem);
        if(null!=normalGiftManager && null != mIMRoomInItem && !TextUtils.isEmpty(mIMRoomInItem.roomId)){
            normalGiftManager.getSendableGiftItems(mIMRoomInItem.roomId,this);
        }
    }

    @Override
    public void OnRecvLoveLevelUpNotice(int lovelevel) {
        super.OnRecvLoveLevelUpNotice(lovelevel);
        //添加消息列表
        IMMessageItem imMessageItem = new IMMessageItem(mIMRoomInItem.roomId,
                mIMManager.mMsgIdIndex.getAndIncrement(),
                "",
                IMMessageItem.MessageType.SysNotice,
                new IMSysNoticeMessageContent(getResources().getString(R.string.system_notice_intimacylevel_upgraded,
                        mIMRoomInItem.nickName,String.valueOf(lovelevel)),
                        null, IMSysNoticeMessageContent.SysNoticeType.Normal));
        Log.d(TAG,"OnRecvLoveLevelUpNotice-msg:"+imMessageItem.sysNoticeContent.message+" link:"+imMessageItem.sysNoticeContent.link);
        sendMessageUpdateEvent(imMessageItem);
        sendEmptyUiMessage(EVENT_INTIMACY_LEVEL_UPDATE);
    }

    //------------------------直播间关闭-------------------------------------------------------

    @Override
    public void OnRecvLeavingPublicRoomNotice(String roomId, int leftSeconds, IMClientListener.LCC_ERR_TYPE err, String errMsg) {
        super.OnRecvLeavingPublicRoomNotice(roomId, leftSeconds, err, errMsg);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                iv_privateLiveNow.setVisibility(View.GONE);
                ll_enterPriRoomTimeCount.setVisibility(View.VISIBLE);
                sendEmptyUiMessageDelayed(EVENT_LEAVING_ROOM_TIMECOUNT,0l);
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
        removeUiMessages(EVENT_TIMEOUT_BACKGROUND);

        if(null != mIMRoomInItem){
            if(closeRoomByUser){
                Log.d(TAG,"OnRecvRoomCloseNotice-closeRoomByUser:"+closeRoomByUser);
            }else if(!TextUtils.isEmpty(mIMRoomInItem.roomId) && roomId.equals(mIMRoomInItem.roomId)){
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        boolean isShowRecommand = false;
                        if(errType == IMClientListener.LCC_ERR_TYPE.LCC_ERR_RECV_REGULAR_CLOSE_ROOM){
                            //正常关闭才推荐
                            isShowRecommand = true;
                        }
                        if(isActivityVisible()) {
                            endLive(PAGE_ERROR_LIEV_EDN, errMsg, isShowRecommand);
                        }else{
                            mIsNeedRecommand = isShowRecommand;
                            mIsRoomBackgroundClose = true;
                            mCloseErrMsg = errMsg;
                            mClosePageErrorType = PAGE_ERROR_LIEV_EDN;
                        }
                    }
                });
            }
        }

    }

    protected void endLive(LiveRoomNormalErrorActivity.PageErrorType pageErrorType, String errMsg, boolean isRecommand){
        Log.d(TAG,"endLive");
        if(null != mIMRoomInItem && null != pageErrorType){
            startActivity(LiveRoomNormalErrorActivity.getIntent(this, pageErrorType, errMsg,
                    mIMRoomInItem.userId, mIMRoomInItem.nickName, mIMRoomInItem.photoUrl,roomPhotoUrl, isRecommand));
        }
        closeLiveRoom();
    }

    @Override
    public void OnRecvChangeVideoUrl(String roomId, boolean isAnchor, final String[] playUrls) {
        super.OnRecvChangeVideoUrl(roomId, isAnchor, playUrls);
        if(mIMRoomInItem != null && roomId.equals(mIMRoomInItem.roomId)) {
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
    private long mPublishStartlastClickTime = 0 , mPublishEndlastClickTime = 0;  //防快速点击
    /**
     * 初始化视频互动界面
     */
    private void initPublishView(){
        //视频上传预览
        includePublish = findViewById(R.id.includePublish);
        svPublisher = (SurfaceView)findViewById(R.id.svPublisher);
        //add by Jagger 2017-11-29 解决小窗口能浮在大窗口上的问题
        svPublisher.setZOrderOnTop(true);
        svPublisher.setZOrderMediaOverlay(true);
        svPublisher.getHolder().setFormat(PixelFormat.TRANSPARENT);
        //
        svPublisher.getHolder().setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);

        flPublishOperate = (FrameLayout)findViewById(R.id.flPublishOperate);
        iv_publishstart = (ImageView) findViewById(R.id.iv_publishstart);
        iv_publishstop = (ImageView) findViewById(R.id.iv_publishstop);
        iv_publishstop.setVisibility(View.GONE);
        iv_publishsoundswitch = (ImageView)findViewById(R.id.iv_publishsoundswitch);
        iv_publishsoundswitch.setVisibility(View.GONE);
        publishLoading = (ProgressBar) findViewById(R.id.publishLoading);

        iv_publishstart.setOnClickListener(this);
        iv_publishstop.setOnClickListener(this);
        iv_publishsoundswitch.setOnClickListener(this);
        includePublish.setOnClickListener(this);
        includePublish.setVisibility(View.GONE);
        ViewDragTouchListener listener = new ViewDragTouchListener();
        listener.setOnViewDragListener(new ViewDragTouchListener.OnViewDragStatusChangedListener() {
            @Override
            public void onViewDragged(int l, int t, int r, int b) {
                //避免父布局重绘后includePublish回到原来的位置
                FrameLayout.LayoutParams flIPublish = (FrameLayout.LayoutParams) includePublish.getLayoutParams();
                flIPublish.gravity = Gravity.TOP|Gravity.LEFT;
                flIPublish.leftMargin = includePublish.getLeft();
                flIPublish.topMargin = includePublish.getTop();
                includePublish.setLayoutParams(flIPublish);
            }
        });
        includePublish.setOnTouchListener(listener);
        //高斯模糊头像部分
        view_gaussian_blur_me = findViewById(R.id.view_gaussian_blur_me);
        v_gaussianBlurFloat = findViewById(R.id.v_gaussianBlurFloat);
        iv_gaussianBlur = (SimpleDraweeView)findViewById(R.id.iv_gaussianBlur);
        if(null != mIMRoomInItem && (mIMRoomInItem.roomType == IMLiveRoomType.NormalPrivateRoom
                || mIMRoomInItem.roomType == IMLiveRoomType.AdvancedPrivateRoom)){
            includePublish.setVisibility(View.VISIBLE);
        }else{
            includePublish.setVisibility(View.GONE);
        }

        openInterVideoTipsPopupWindow = new OpenInterVideoTipsPopupWindow(this);
        openInterVideoTipsPopupWindow.setOnBtnClickListener(new OpenInterVideoTipsPopupWindow.OnOpenTipsBtnClickListener() {
            @Override
            public void onBtnClicked(boolean isOpenVideo, boolean neverShowTipsAgain) {
                if(isOpenVideo){
                        startOrStopVideoInteraction();
                }
                BaseCommonLiveRoomActivity.this.neverShowTipsAgain = neverShowTipsAgain;
                if(null != localPreferenceManager){
                    try {
                        localPreferenceManager.save("neverShowTipsAgain",BaseCommonLiveRoomActivity.this.neverShowTipsAgain);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
        });
    }

    protected void initPublishData(){
        localPreferenceManager = new LocalPreferenceManager(this);
        Object obj = localPreferenceManager.getObject("neverShowTipsAgain");
        if(obj != null && obj instanceof Boolean){
            neverShowTipsAgain = (Boolean)obj;
        }

        Log.d(TAG,"initPublishData-neverShowTipsAgain:"+neverShowTipsAgain);
        if(checkCanInterVideo()){
            //豪华私密直播间才支持视频互动功能
            includePublish.setVisibility(View.VISIBLE);
            //del by Jagger 2017-12-1 改为每次启动互动视频上传时 重新初始化(因为不释放掉相机,LG-D820暂时几分钟后,会CHRASH)
            //播放器初始化
//            mPublisherManager = new PublisherManager(this);
//            mPublisherManager.init(svPublisher);
//
            if(mIMRoomInItem.manUploadRtmpUrls != null
                    && mIMRoomInItem.manUploadRtmpUrls.length > 0 && !TextUtils.isEmpty(mIMRoomInItem.manUploadRtmpUrls[0])){
//                startPublishStream(mIMRoomInItem.manUploadRtmpUrls[0]);
                startOrStopVideoInteraction();
            }
        }else{
            includePublish.setVisibility(View.GONE);
        }

    }

    /**
     * add by Jagger 2017-12-1
     * 回收拉流播放器
     */
    private void destroyPublisher(){
        //回收拉流播放器
        if(mPublisherManager != null){
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
    private void publishStart(){
        if(neverShowTipsAgain){
            startOrStopVideoInteraction();
        }else{
            if(null != openInterVideoTipsPopupWindow){
                String textDesc = "";
                if(mIMRoomInItem != null){
                    textDesc = String.format(getResources().getString(R.string.live_inter_video_open), String.valueOf(mIMRoomInItem.videoPrice));
                }
                if(!TextUtils.isEmpty(textDesc)) {
                    openInterVideoTipsPopupWindow.setTextDesc(textDesc);
                }
                openInterVideoTipsPopupWindow.showAtLocation(flContentBody, Gravity.CENTER,0,0);
            }
        }
        //GA统计点击开启互动视频
        onAnalyticsEvent(getResources().getString(R.string.Live_Broadcast_Category),
                getResources().getString(R.string.Live_Broadcast_Action_TwoWayVideo),
                getResources().getString(R.string.Live_Broadcast_Label_TwoWayVideo));
    }

    /**
     * 检测是否支持互动视频功能（仅标准私密直播间及豪华私密直播间支持该功能）
     * @return
     */
    private boolean checkCanInterVideo(){
        boolean canInterVideo = false;
        if(mIMRoomInItem != null && (mIMRoomInItem.roomType == IMLiveRoomType.AdvancedPrivateRoom
                || mIMRoomInItem.roomType == IMLiveRoomType.NormalPrivateRoom)){
            canInterVideo = true;
        }
        return canInterVideo;
    }

    /**
     * 互动视频断线相关处理
     */
    private void onPublishDisconnect(){
        if(isPublishing){
            stopPublishStream();
            flPublishOperate.setVisibility(View.GONE);
            publishLoading.setVisibility(View.VISIBLE);
        }
    }

    /**
     * 断线重连重新进入房间，互动模块处理
     */
    private void onDisconnectRoomIn(){
        //拉流处理
        if(mIMRoomInItem != null && mIMRoomInItem.videoUrls != null){
            startLivePlayer(mIMRoomInItem.videoUrls);
        }

        //推流处理
        if(mIMRoomInItem.manUploadRtmpUrls != null
                && mIMRoomInItem.manUploadRtmpUrls.length > 0 && !TextUtils.isEmpty(mIMRoomInItem.manUploadRtmpUrls[0])){
            //            startPublishStream(manPushUrl);
            startOrStopVideoInteraction();
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
            if(flPublishOperate != null){
                flPublishOperate.setVisibility(View.GONE);
            }
        }
    };

    /**
     * 开启／关闭视频互动返回 或 点击视频上传，显示按钮
     */
    private void refreshPublishViews(){
        flPublishOperate.setVisibility(View.VISIBLE);
        //清除隐藏操作区定时任务
        removeCallback(mHideOperateRunnable);
        if(isPublishing){
            view_gaussian_blur_me.setVisibility(View.GONE);
            iv_publishstop.setVisibility(View.VISIBLE);
            iv_publishstart.setVisibility(View.GONE);
            iv_publishsoundswitch.setVisibility(View.VISIBLE);
            //add by Jagger 2017-12-1
            svPublisher.setVisibility(View.VISIBLE);
            if(isPublishMute){
                //静音
                iv_publishsoundswitch.setImageResource(R.drawable.ic_live_publish_sound_off);
            }else{
                iv_publishsoundswitch.setImageResource(R.drawable.ic_live_publish_sound_on);
            }
            //启动3秒后隐藏操作区
            postUiRunnableDelayed(mHideOperateRunnable, 3 * 1000);
//            hasPublished = true;
        }else{
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
    private void startOrStopVideoInteraction(){
        if(mIMRoomInItem != null){
            lastVideoInteractiveOperateType = IMClient.IMVideoInteractiveOperateType.Start;
            if(isPublishing){
                lastVideoInteractiveOperateType = IMClient.IMVideoInteractiveOperateType.Close;
            }
            mVideoInteractionReqId = mIMManager.ControlManPush(mIMRoomInItem.roomId, lastVideoInteractiveOperateType);
            if(IM_INVALID_REQID != mVideoInteractionReqId){
                //发出请求成功
                flPublishOperate.setVisibility(View.GONE);
                publishLoading.setVisibility(View.VISIBLE);
            }
        }
    }

    /**
     * 设置静音
     */
    private void setPublishMute(){
        if(mPublisherManager != null){
            isPublishMute = !isPublishMute;
            if(isPublishMute){
                //静音
                iv_publishsoundswitch.setImageResource(R.drawable.ic_live_publish_sound_off);
            }else{
                iv_publishsoundswitch.setImageResource(R.drawable.ic_live_publish_sound_on);
            }
            mPublisherManager.setPublisherMute(isPublishMute);
            Log.d(TAG,"setPublishMute-isPublishMute:"+isPublishMute);
        }
    }

    /**
     * 开始视频上传
     * @param manPushUrls
     */
    private void startPublishStream(String[] manPushUrls){
        isPublishing = true;

        //stop清除publisher，开始推流才初始化
        mPublisherManager = new PublisherManager(this);
        mPublisherManager.init(svPublisher);

        //刷新界面
        refreshPublishViews();

        //初始化播放器
        if(mPublisherManager != null && mPublisherManager.isInited()){
            //del by Jagger 2017-12-1
//            mPublisherManager.stop();
            mPublisherManager.setPublisherMute(isPublishMute);
            mPublisherManager.setOrChangeManUploadUrls(manPushUrls, "", "");
        }
    }

    /**
     * 停止上传视频
     */
    public void stopPublishStream(){
        isPublishing = false;

        if(mPublisherManager != null){
            mPublisherManager.stop();
        }

        //add by Jagger 2017-12-1
        //销毁播放器
        destroyPublisher();

        //刷新界面
        refreshPublishViews();
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
    public void OnControlManPush(int reqId, final boolean success, final IMClientListener.LCC_ERR_TYPE errType,
                                 final String errMsg, final String[] manPushUrl) {
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
                                startPublishStream(manPushUrl);
                            }else{
                                //状态异常，处理为启动失败
                                showToast(getResources().getString(R.string.common_webview_load_error));
                                //调用关闭，防止持续扣费
                                mIMManager.ControlManPush(mIMRoomInItem.roomId, IMClient.IMVideoInteractiveOperateType.Close);
                            }
                        }
                    } else {
                        //开启或关闭失败
                        if(errType == LCC_ERR_INCONSISTENT_CREDIT_FAIL
                                || errType == LCC_ERR_NO_CREDIT){
                            showCreditNoEnoughDialog(R.string.live_common_noenough_money_tips);
                        }else {
                            if(lastVideoInteractiveOperateType == IMClient.IMVideoInteractiveOperateType.Start){
                                //开启失败
                                showToast(getResources().getString(R.string.live_inter_video_failed_open));
                            }else{
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
    private void doMovePublishViewUnderEditView(){
        //应用程序App区域宽高等尺寸获取
        Rect rect = new Rect();
        getWindow().getDecorView().getWindowVisibleDisplayFrame(rect);
        int edBottomY = rect.height() - 1;

        FrameLayout.LayoutParams flIPublish = (FrameLayout.LayoutParams) includePublish.getLayoutParams();
        //移动
        if(flIPublish.topMargin > edBottomY){
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
    private void doReMovePublishView(){
        if(mIsMovePublishViewUnderEditView && mIPublishTempTop != -1){
            FrameLayout.LayoutParams flIPublish = (FrameLayout.LayoutParams) includePublish.getLayoutParams();
            flIPublish.topMargin = mIPublishTempTop;
            includePublish.setLayoutParams(flIPublish);
            //
            mIsMovePublishViewUnderEditView = false;
        }
    }

    //------------------------------------才艺点播相关--------------------------------
    protected TalentManager talentManager;

    private void initTalentManager(){
        Log.d(TAG,"initTalentManager");
        if(null != mIMRoomInItem && mIMRoomInItem.roomType == IMLiveRoomType.AdvancedPrivateRoom){
            talentManager = new TalentManager(this);
            talentManager.getTalentsData(mIMRoomInItem.roomId);
            talentManager.setOnClickedRequestConfirmListener(new onRequestConfirmListener() {
                @Override
                public void onConfirm(TalentInfoItem talent) {
                    Log.i(TAG , "initTalentManager-onConfirm talent:" + talent);
                    //调用IM接口
                    if(null != mIMRoomInItem && null != mIMManager){
                        mIMManager.sendTalentInvite(mIMRoomInItem.roomId , talent.talentId);
                    }
                }
            });
        }
    }

    @Override
    public void OnSendTalent(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
        super.OnSendTalent(reqId, success, errType, errMsg);
        if(null != talentManager){
            talentManager.onTanlentSent(success , errMsg, errType);
        }
    }

    @Override
    public void OnRecvSendTalentNotice(String roomId, String talentInviteId,
                                       String talentId, String name, double credit,
                                       IMClientListener.TalentInviteStatus status, double rebateCredit) {
        super.OnRecvSendTalentNotice(roomId, talentInviteId, talentId, name, credit, status, rebateCredit);
        if(null != talentManager){
            talentManager.onTanlentProcessed(talentId,name,status);
        }
    }

    /*********************************  男士publisher逻辑end  *******************************************/

    /*******************************断线重连****************************************/
    @Override
    public void onIMAutoReLogined() {
        super.onIMAutoReLogined();
        //断线重连，需要拿roomId重新登录房间
        Log.d(TAG,"onIMAutoReLogined-mIMRoomInItem:"+mIMRoomInItem);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if(null != mIMRoomInItem && !TextUtils.isEmpty(mIMRoomInItem.roomId)){
                    if(null != mIMManager){
                        int result = mIMManager.RoomIn(mIMRoomInItem.roomId);
                        Log.d(TAG,"onIMAutoReLogined-result:"+result+"IM_INVALID_REQID:"+IM_INVALID_REQID);
                    }
                }
                if(null != talentManager){
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
                if(mPublisherManager != null){
                    mPublisherManager.onLogout();
                }
                if(mLivePlayerManager != null){
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
        Log.d(TAG,"onStop-开启app处于后台计时器 hasBackgroundTimeOut:"+hasBackgroundTimeOut);
        if(SystemUtils.isBackground(this) && !hasBackgroundTimeOut && !mIsRoomBackgroundClose){
            sendEmptyUiMessageDelayed(EVENT_TIMEOUT_BACKGROUND, 60 * 1000l);
        }

        //TODO:清空大礼物动画播放队列
        if(null != mModuleGiftManager){
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
        Log.d(TAG,"onResume-hasBackgroundTimeOut:"+hasBackgroundTimeOut);

        //直播中切换其他界面如主播资料时，收到直播间关闭等通知需要关闭直播间，延迟处理
        if(mIsRoomBackgroundClose){
            if(mClosePageErrorType != null){
                endLive(mClosePageErrorType, mCloseErrMsg, mIsNeedRecommand);
            }
        }else if(hasBackgroundTimeOut){
            //解决5.0以下startActivity会在后台打开页面，但是5.0以上会将应用带到前台
            endLive(LiveRoomNormalErrorActivity.PageErrorType.PAGE_ERROR_BACKGROUD_OVERTIME, "", true);
        }else{
            //刷新一次信用点解决信用点不足，充值返回，由于本地信用点未刷新导致直播间本地判断异常
            GetCredit();
        }

        //重置标志位
        mIsRoomBackgroundClose = false;
        mClosePageErrorType = null;
        hasBackgroundTimeOut = false;
        mIsNeedRecommand = false;
        mCloseErrMsg = "";
    }
}
