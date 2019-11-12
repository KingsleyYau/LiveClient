package com.qpidnetwork.anchor.liveshow.liveroom;


import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.AnimationDrawable;
import android.graphics.drawable.Drawable;
import android.opengl.GLSurfaceView;
import android.os.Build;
import android.os.Bundle;
import android.os.Message;
import android.support.v4.app.FragmentManager;
import android.text.Editable;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.text.style.ForegroundColorSpan;
import android.view.Display;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.view.animation.TranslateAnimation;
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.framework.canadapter.CanOnItemListener;
import com.qpidnetwork.anchor.httprequest.LiveRequestOperator;
import com.qpidnetwork.anchor.httprequest.OnRequestCallback;
import com.qpidnetwork.anchor.httprequest.item.AudienceInfoItem;
import com.qpidnetwork.anchor.httprequest.item.EmotionItem;
import com.qpidnetwork.anchor.httprequest.item.HttpLccErrType;
import com.qpidnetwork.anchor.httprequest.item.IntToEnumUtils;
import com.qpidnetwork.anchor.httprequest.item.LiveRoomType;
import com.qpidnetwork.anchor.httprequest.item.TalentReplyType;
import com.qpidnetwork.anchor.im.listener.IMClientListener;
import com.qpidnetwork.anchor.im.listener.IMCurrentPushInfoItem;
import com.qpidnetwork.anchor.im.listener.IMHangoutRecommendItem;
import com.qpidnetwork.anchor.im.listener.IMMessageItem;
import com.qpidnetwork.anchor.im.listener.IMRoomInItem;
import com.qpidnetwork.anchor.im.listener.IMSendInviteInfoItem;
import com.qpidnetwork.anchor.im.listener.IMSysNoticeMessageContent;
import com.qpidnetwork.anchor.im.listener.IMUserBaseInfoItem;
import com.qpidnetwork.anchor.liveshow.liveroom.audience.AudienceInfoDialog;
import com.qpidnetwork.anchor.liveshow.liveroom.audience.AudienceSelectorAdapter;
import com.qpidnetwork.anchor.liveshow.liveroom.beautyfilter.BeautyFilterDialog;
import com.qpidnetwork.anchor.liveshow.liveroom.car.CarInfo;
import com.qpidnetwork.anchor.liveshow.liveroom.recommend.RecommendDialogFragment;
import com.qpidnetwork.anchor.utils.BeepAndVibrateUtil;
import com.qpidnetwork.anchor.utils.FrescoLoadUtil;
import com.qpidnetwork.anchor.utils.Log;
import com.qpidnetwork.anchor.utils.StringUtil;
import com.qpidnetwork.anchor.view.CircleImageHorizontScrollView;
import com.qpidnetwork.anchor.view.Dialogs.DialogNormal;
import com.qpidnetwork.anchor.view.LiveRoomScrollView;
import com.qpidnetwork.qnbridgemodule.sysPermissions.manager.PermissionManager;
import com.qpidnetwork.qnbridgemodule.util.DisplayUtil;
import com.qpidnetwork.qnbridgemodule.view.keyboardLayout.KeyBoardManager;
import com.qpidnetwork.qnbridgemodule.view.keyboardLayout.SoftKeyboardSizeWatchLayout;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;


/**
 * 免费公开直播间
 * Created by Hunter Mun on 2017/6/15.
 * edit by Jagger 2019-10-29 改为公开私密直播共用的全屏直播间
 */

public class FullScreenLiveRoomActivity extends BaseAnchorLiveRoomActivity implements SoftKeyboardSizeWatchLayout.OnResizeListener{

    /**
     * 直播间类型
     */
    public enum RoomType{
        Public,     //公开直播
        Private     //私密直播
    }

    private static final String KEY_ROOM_TYPE = "KEY_ROOM_TYPE";

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

    //直播间类型
    private RoomType mRoomType = RoomType.Public;

    //整个view的父，用于解决软键盘等监听
    private SoftKeyboardSizeWatchLayout flContentBody;
    private LiveRoomScrollView lrsv_roomBody;
    private View imBody;
    private View include_audience_area;
    //观众列表
    private TextView tv_vipGuestData;
    private CircleImageHorizontScrollView cihsv_onlineVIPPublic;
    private View includeOnline;
    private LinearLayout ll_pri_man_msg;
    private SimpleDraweeView img_man;
    private TextView tv_man_name;

    //视频推拉流
    private View rl_media;
    public GLSurfaceView sv_push;
    private ImageView iv_vedioBg;
    private ImageView iv_vedioLoading;
    //视频操作区域
//    private View fl_vedioOpear;
    private ImageView iv_beauty;
    private ImageView iv_close;
    private ImageView iv_switchCamera;
    //直播间操作提示
    private View fl_vedioTips;
    private TextView tv_vedioTip0;
    private TextView tv_vedioTip1;
    private TextView tv_vedioTip2;
    private TextView tv_vedioTip3;
    private TextView tv_vedioTip4;
    private ImageView iv_vedioTips;
    //座驾
    protected LinearLayout ll_entranceCar;
    private SimpleDraweeView iv_car;
    private TextView  tv_joined;
    //弹幕
    private View ll_bulletScreen;
    //大礼物
    private SimpleDraweeView advanceGift;
    //聊天展示区域
    private RelativeLayout fl_imMsgContainer;
    //PC转手机
    private LinearLayout ll_pc_to_mobile;
    private TextView tv_pc_to_mobile;
    private Button btn_to_mobile;

    //--------------------- 消息编辑区域 start --------------------
    private EditText et_liveMsg;
//    private EmojiTabScrollLayout etsl_emojiContainer;
    private EmotionItem chooseEmotionItem = null;
//    private ImageView iv_emojiSwitch;
    private ImageView iv_gift;

    private View ll_audienceChooser;
    private TextView tv_audienceNickname;
    private ImageView iv_audienceIndicator;
    private ListView lv_audienceList;
    private AudienceSelectorAdapter audienceSelectorAdapter;
    private List<AudienceInfoItem> currAudienceInfoItems;
    private AudienceInfoItem lastSelectedAudienceInfoItem = null;
    private AudienceInfoItem defaultAudienceInfoItem = null;
    private AudienceInfoDialog audienceInfoDialog;

    private static int liveMsgMaxLength = 10;
    private int lastTxtChangedStart = 0;
    private int lastTxtChangedNumb = 0;
    private String lastInputEmoSign = null;
    private boolean isBarrage = true;

    private FrameLayout fl_inputArea;
    private int mKeyBoardHeight = 0;    //键盘高度
    private InputAreaStatus mInputAreaStatus = InputAreaStatus.HIDE;

    //--------------------- 消息编辑区域 end --------------------

    //-------------------- 男士互动视频 start --------------------
    private SimpleDraweeView iv_gaussianBlur;
//    private View includePull;
    private GLSurfaceView sv_pull;
//    private View view_gaussian_blur_me;
    private View v_gaussianBlurFloat;
    private FrameLayout fl_man_video;
    private boolean isStreamPulling = false;       //是否正在视频互动中
    private String[] lastManPullUrls = new String[]{};
    private LiveStreamPullManager mLiveStreamPullManager; //推流管理器

    private int mIPublishTempTop = -1;
    private boolean mIsMovePullViewUnderEditView = false;

    //-------------------- 男士互动视频 end --------------------


    /**
     * 输入键盘类型
     */
    private enum InputAreaStatus {
        HIDE,       //隐藏
        EMOJI,      //表情
        KEYBOARD    //键盘
    }

    //------------------ 其它 ----------------
    private BeepAndVibrateUtil mBeepAndVibrateUtil;

    /**
     * 直播间关闭倒计时
     */
    private static final int EVENT_PRIVINVITE_RESP_TIMEOUT = 2001;
    private static final int EVENT_PRIVINVITE_RESP_TIPS_HINT= 2002;
    private static final int EVENT_SWITHFLOW_APP_OPEN = 2003;
    private static final int EVENT_SWITHFLOW_APP_CLOSE = 2004;

    private String lastPrivateLiveInvitationId = null;

    /**
     * 启动
     * @param context
     */
    public static void lanchActPublicLiveRoom(Context context, IMRoomInItem roomInfo){
        Intent intent = new Intent(context, FullScreenLiveRoomActivity.class);
        intent.putExtra(KEY_ROOM_TYPE, RoomType.Public.ordinal());
        intent.putExtra(LIVEROOM_ROOMINFO_ITEM, roomInfo);
        context.startActivity(intent);
    }

    /**
     * 启动
     * @param context
     */
    public static void lanchActPrivateLiveRoom(Context context, IMRoomInItem roomInfo, String userPhotoUrl, String userId, String userName){
        Intent intent = new Intent(context, FullScreenLiveRoomActivity.class);
        intent.putExtra(KEY_ROOM_TYPE, RoomType.Private.ordinal());
        intent.putExtra(LIVEROOM_ROOMINFO_ITEM, roomInfo);
        intent.putExtra(LIVEROOM_MAN_PHOTOURL, userPhotoUrl);
        intent.putExtra(TRANSITION_USER_ID, userId);
        intent.putExtra(LIVEROOM_MAN_NICKNAME, userName);
        context.startActivity(intent);
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        TAG = FullScreenLiveRoomActivity.class.getSimpleName();
        //直播中保持屏幕点亮不熄屏
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON,
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        setContentView(R.layout.activity_live_room_full_screen);
        //全屏
        setImmersionBarArtts(R.color.live_room_header_gradient_start_color);
        initData();
        initViews();

        initVedioPlayerStatus();
        if(mRoomType == RoomType.Public){
            updatePublicRoomOnlineData();
            updatePublicOnLinePic(new AudienceInfoItem[]{});
        }
    }

    private void initViews(){
        Log.d(TAG,"initViews");
        //解决软键盘关闭的监听问题
        flContentBody = findViewById(R.id.flContentBody);
        flContentBody.addOnResizeListener(this);
        lrsv_roomBody = (LiveRoomScrollView) findViewById(R.id.lrsv_roomBody);
        initRoomViewDataAndStyle();
        initRoomVedioHeader();
        initAnchorVideoPusher();
        imBody = findViewById(R.id.include_im_body);
        //FS
        //4.3以上(不包括4.3)，留空状态栏距离
        if(Build.VERSION.SDK_INT > Build.VERSION_CODES.JELLY_BEAN_MR2) {
            FrameLayout.LayoutParams headerLP = (FrameLayout.LayoutParams) imBody.getLayoutParams();
            headerLP.topMargin = DisplayUtil.getStatusBarHeight(mContext);
        }
        include_audience_area = findViewById(R.id.include_audience_area);
        include_audience_area.setOnClickListener(this);

        // FS
        //键盘高度
        mKeyBoardHeight = KeyBoardManager.getKeyboardHeight(this);
        //edit by Jagger 2018-9-6
        //黑莓手机，有物理键盘，取出键盘高度只有 100＋PX，效果不好。如果取出键盘高度，小于min_keyboard_height，就用默认的吧
        if (mKeyBoardHeight < getResources().getDimensionPixelSize(R.dimen.min_keyboard_height)) {
            mKeyBoardHeight = getResources().getDimensionPixelSize(R.dimen.min_keyboard_height);
        }

        initLiveRoomCar();
        initMultiGift();
        initMessageList();
        initBarrage();
        initEditAreaView();
        initEditAreaViewStyle();
        //互动模块初始化
//        setSizeUnChanageViewParams();

        if(mRoomType == RoomType.Private){
            //互动模块初始化
            initPublishView();
            initPriManHeader();
        }else{
            initOnLinePicView();
            initAtWho();
        }

    }

    /**
     * 私密直播头部男士信息
     */
    private void initPriManHeader(){
        ll_pri_man_msg = findViewById(R.id.ll_pri_man_msg);
        ll_pri_man_msg.setVisibility(View.VISIBLE);

        img_man = findViewById(R.id.img_man);
        tv_man_name = findViewById(R.id.tv_man_name);

        FrescoLoadUtil.loadUrl(mContext, img_man, manPhotoUrl, getResources().getDimensionPixelSize(R.dimen.live_room_pri_header_man_icon_size), R.color.black4, true);
        tv_man_name.setText(manNickName);
    }

    @Override
    public void initData() {
        super.initData();

        //传入的参数
        Bundle bundle = getIntent().getExtras();
        if(bundle != null){
            if(bundle.containsKey(KEY_ROOM_TYPE)){
                int indexRoomType = bundle.getInt(KEY_ROOM_TYPE);

                Log.i("Jagger" , "indexRoomType:" + indexRoomType);
                if(indexRoomType < RoomType.values().length){
                    mRoomType = RoomType.values()[indexRoomType];
                    Log.i("Jagger" , "mRoomType:" + mRoomType.name());
                }
            }
        }

        if(mRoomType == RoomType.Public){
            //公开直播间用
            //观众
            defaultAudienceInfoItem = new AudienceInfoItem("0","All","",null,null,0,"",false);
            lastSelectedAudienceInfoItem = defaultAudienceInfoItem;
            currAudienceInfoItems = new ArrayList<>();
            currAudienceInfoItems.add(lastSelectedAudienceInfoItem);
            mBeepAndVibrateUtil = new BeepAndVibrateUtil(this);
        }
    }

    /**
     * 初始化头部视频操作区域
     */
    private void initRoomVedioHeader(){
//        fl_vedioOpear = findViewById(R.id.fl_vedioOpear);
        iv_beauty = findViewById(R.id.iv_beauty);
        iv_beauty.setOnClickListener(this);
        iv_close = (ImageView) findViewById(R.id.iv_close);
        iv_close.setOnClickListener(this);
        //add by Jagger 2018-10
        if(null != mIMRoomInItem && mIMRoomInItem.liveShowType == IMRoomInItem.IMPublicRoomType.Program){
            iv_close.setVisibility(View.GONE);
        }
        iv_switchCamera = (ImageView) findViewById(R.id.iv_switchCamera);
        iv_switchCamera.setOnClickListener(this);
//        fl_vedioOpear.setVisibility(View.GONE);

        fl_vedioTips = findViewById(R.id.fl_vedioTips);
        fl_vedioTips.setVisibility(View.GONE);
        tv_vedioTip0 = (TextView) findViewById(R.id.tv_vedioTip0);
        tv_vedioTip1 = (TextView) findViewById(R.id.tv_vedioTip1);
        tv_vedioTip2 = (TextView) findViewById(R.id.tv_vedioTip2);
        tv_vedioTip3 = (TextView) findViewById(R.id.tv_vedioTip3);
        tv_vedioTip4 = (TextView) findViewById(R.id.tv_vedioTip4);
        iv_vedioTips = (ImageView) findViewById(R.id.iv_vedioTips);
        changeRoomTimeCountEndStatus();

        //PC转手机直播
        ll_pc_to_mobile = findViewById(R.id.ll_pc_to_mobile);
        tv_pc_to_mobile = findViewById(R.id.tv_pc_to_mobile);
        btn_to_mobile = findViewById(R.id.btn_to_mobile);
        btn_to_mobile.setOnClickListener(this);
    }

    /**
     * 设置直播间布局样式(皮肤)
     */
    private void initRoomViewDataAndStyle(){
        if(null != mIMRoomInItem){
            int color = roomThemeManager.getRootViewTopColor(mIMRoomInItem.roomType);
//            StatusBarUtil.setColor(this,color,0);
        }
    }

    private void initAnchorVideoPusher(){
        //视频播放组件
        sv_push = (GLSurfaceView)findViewById(R.id.sv_push);
        iv_vedioBg = (ImageView) findViewById(R.id.iv_vedioBg);
        rl_media = findViewById(R.id.rl_media);
        rl_media.setOnClickListener(this);
        //初始化播放器
        if(mLiveStreamPushManager != null){
            mLiveStreamPushManager.init(sv_push);
        }
        iv_vedioLoading = (ImageView) findViewById(R.id.iv_vedioLoading);
        iv_vedioLoading.setVisibility(View.GONE);
        iv_vedioLoading.setOnClickListener(this);

        int screenWidth = DisplayUtil.getScreenWidth(this);
        int scaleHeight= screenWidth/**3/4*/;
        //具体的宽高比例，其实也可以根据服务器动态返回来控制
//        RelativeLayout.LayoutParams svPlayerLp = (RelativeLayout.LayoutParams) sv_push.getLayoutParams();
//        RelativeLayout.LayoutParams ivVedioBgLp = (RelativeLayout.LayoutParams)iv_vedioBg.getLayoutParams();
        LinearLayout.LayoutParams rlMediaLp = (LinearLayout.LayoutParams)rl_media.getLayoutParams();
//        svPlayerLp.height = scaleHeight;
        rlMediaLp.height = scaleHeight;
//        ivVedioBgLp.height = scaleHeight;
//        sv_push.setLayoutParams(svPlayerLp);
        rl_media.setLayoutParams(rlMediaLp);
//        iv_vedioBg.setLayoutParams(ivVedioBgLp);

        // FS
        // 设置视频全屏高度
        int height = com.qpidnetwork.qnbridgemodule.util.DisplayUtil.getScreenHeight(this);
        RelativeLayout.LayoutParams layoutParamsPlayer = (RelativeLayout.LayoutParams) sv_push.getLayoutParams();
        layoutParamsPlayer.height = height;

        // 设置视频封面全屏高度
        RelativeLayout.LayoutParams layoutParamsBg = (RelativeLayout.LayoutParams) iv_vedioBg.getLayoutParams();
        layoutParamsBg.height = height;

        initVedioLoadingAnimManager(iv_vedioLoading);
    }

    @Override
    protected void initVedioPlayerStatus() {
        super.initVedioPlayerStatus();

        // PC推流，显示转换按钮
        if(null != mIMRoomInItem ) {
            if (mIMRoomInItem.currentPush.status == IMCurrentPushInfoItem.IMCurrentPushStatus.PcPush) {
                showToMobileCameraTips();
            }
        }
    }

    //-------------------------- 入场座驾 start --------------------------
    /**
     * 初始化座驾入场动画
     */
    private void initLiveRoomCar(){
//        ll_entranceCar = (LinearLayout) findViewById(R.id.ll_entranceCar);
//        ll_entranceCar.setClickable(true);
//        ll_entranceCar.setOnClickListener(this);
//        super.initLiveRoomCar(ll_entranceCar);

        ll_entranceCar = findViewById(R.id.ll_entranceCar);
        iv_car = ll_entranceCar.findViewById(R.id.iv_car);
        tv_joined = ll_entranceCar.findViewById(R.id.tv_joined);
    }

    @Override
    protected void playEnterCarAnim(CarInfo carInfo) {
        tv_joined.setVisibility(View.VISIBLE);
        iv_car.setVisibility(View.VISIBLE);

        tv_joined.setText(getString(R.string.liveroom_entrancecar_joined, StringUtil.truncateName(carInfo.nickName)));
        FrescoLoadUtil.loadUrl(iv_car, carInfo.riderUrl, getResources().getDimensionPixelSize(R.dimen.live_enter_car_size));
        doPlayEntranceCarAnim();
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
//        ll_entranceCar.removeAllViews();
//        ll_entranceCar.setVisibility(View.GONE);
    }

    //-------------------------- 入场座驾 end --------------------------

    /**
     * 初始化送礼动画管理器
     */
    private void initMultiGift(){
        FrameLayout viewContent = (FrameLayout)findViewById(R.id.flMultiGift);
        viewContent.setOnClickListener(this);
        /*礼物模块*/
        mModuleGiftManager.initMultiGift(viewContent, 2);
        ll_bulletScreen = findViewById(R.id.ll_bulletScreen);
        ll_bulletScreen.setOnClickListener(this);
        mModuleGiftManager.showMultiGiftAs(ll_bulletScreen);
        //大礼物
        advanceGift = (SimpleDraweeView)findViewById(R.id.advanceGift);
        mModuleGiftManager.initAdvanceGift(advanceGift);
    }

    /**
     * 初始化在线头像列表
     * (公开直播间用)
     */
    private void initOnLinePicView(){
        includeOnline = findViewById(R.id.includeOnline);
        includeOnline.setVisibility(View.VISIBLE);

        audienceInfoDialog = new AudienceInfoDialog(this);
        cihsv_onlineVIPPublic = (CircleImageHorizontScrollView) findViewById(R.id.cihsv_onlineVIPPublic);
        cihsv_onlineVIPPublic.setCircleImageClickListener(new CircleImageHorizontScrollView.OnCircleImageClickListener() {
            @Override
            public void onCircleImageClicked(CircleImageHorizontScrollView.CircleImageObj obj) {
                AudienceInfoItem item = (AudienceInfoItem) obj.obj;
                if(!item.userId.equals(defaultAudienceInfoItem.userId)){
                    boolean isShowPrivateBtn = true;
                    //add by Jagger 2018-5-9
                    //节目隐藏ONE-ON-ONE(主播无立即私密邀请权限)
                    if(mIMRoomInItem.liveShowType == IMRoomInItem.IMPublicRoomType.Program || !mIMRoomInItem.isHasOneOnOneAuth){
                        isShowPrivateBtn = false;
                    }
                    audienceInfoDialog.setInvitePriLiveBtnVisible(isShowPrivateBtn);
                    audienceInfoDialog.show(item);

                    /**在show之后,加上如下这段代码就能解决宽被压缩的bug*/
                    WindowManager windowManager = getWindowManager();
                    Display defaultDisplay = windowManager.getDefaultDisplay();
                    WindowManager.LayoutParams attributes = audienceInfoDialog.getWindow().getAttributes();
                    attributes.width = defaultDisplay.getWidth();
                    attributes.gravity = Gravity.BOTTOM;
                    audienceInfoDialog.getWindow().setAttributes(attributes);
                }
            }
        });
        tv_vipGuestData = (TextView) findViewById(R.id.tv_vipGuestData);
        updatePublicOnLineNum(0);
    }

    /**
     * 初始化消息展示列表
     */
    private void initMessageList(){

        if(loginItem != null) {
            liveRoomChatManager = new FullSrceenLiveRoomChatManager(this, mIMRoomInItem.roomType,
                    mIMRoomInItem.anchorId, roomThemeManager);
            View fl_msglist = findViewById(R.id.fl_msglist);
            fl_msglist.setClickable(true);
            liveRoomChatManager.init(this, fl_msglist);
            fl_msglist.setOnClickListener(this);
            liveRoomChatManager.setOnRoomMsgListClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
//                    Log.d(TAG, "OnRoomMsgListClickListener-isSoftInputOpen:" + isSoftInputOpen);
//                    if (isSoftInputOpen) {
//                        hideSoftInput(et_liveMsg, true);
//                    }
                    hideInputArea();
                }
            });
        }
        //incliude view id 必须通过setOnClickListener方式设置onclick监听,
        // xml中include标签下没有onclick和clickable属性
        //消息区大小
        fl_imMsgContainer = findViewById(R.id.fl_imMsgContainer);
        fl_imMsgContainer.setOnClickListener(this);
        setMsgAreaMaxHeight();
    }

    /**
     * 弹幕初始化
     */
    private void initBarrage(){
        List<View> mViews = new ArrayList<View>();
        mViews.add(findViewById(R.id.rl_bullet1));
        initBarrage(mViews,ll_bulletScreen);
    }

    //------------------------ 弹幕消息编辑区域处理 start ------------------------
    /**
     * 处理编辑框区域view初始化
     */
    @SuppressLint("ClickableViewAccessibility")
    @SuppressWarnings("WrongConstant")
    private void initEditAreaView(){
        liveMsgMaxLength = getResources().getInteger(R.integer.liveMsgMaxLength);
        fl_inputArea = findViewById(R.id.fl_inputArea);
        //共用的软键盘弹起输入部分
        et_liveMsg = (EditText)findViewById(R.id.et_liveMsg);

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
        et_liveMsg.setOnClickListener(this);
        et_liveMsg.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                Log.d(TAG,"onFocusChange-hasFocus:"+hasFocus);
//                if (hasFocus && etsl_emojiContainer.getVisibility() == View.VISIBLE) {
//                    etsl_emojiContainer.setVisibility(View.GONE);
//                    iv_emojiSwitch.setImageDrawable(getResources().getDrawable(R.drawable.ic_liveroom_emojiswitch));
//                }
            }
        });

        et_liveMsg.addTextChangedListener(tw_msgEt);
        et_liveMsg.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                Log.d(TAG,"onEditorAction-s:"+v.getText());
                //公开直播间判断目标男士是否已经退出房间
                if(null != lastSelectedAudienceInfoItem
                        && !lastSelectedAudienceInfoItem.equals(defaultAudienceInfoItem)){
                    synchronized (currAudienceInfoItems){
                        boolean isManStillInRoom = false;
                        AudienceInfoItem audienceInfoItem = null;
                        for(int index=0; index<currAudienceInfoItems.size(); index++){
                            audienceInfoItem = currAudienceInfoItems.get(index);
                            if(audienceInfoItem.userId.equals(defaultAudienceInfoItem.userId)){
                                continue;
                            }
                            if(audienceInfoItem.userId.equals(lastSelectedAudienceInfoItem.userId)){
                                isManStillInRoom = true;
                                break;
                            }
                        }
                        if(!isManStillInRoom){
                            showToast(R.string.public_live_sendmsg_manleave_tips);
                            return true;
                        }
                    }

                }

                sendMsg();

                return true;
            }
        });
//        //Emoji
//        etsl_emojiContainer = (EmojiTabScrollLayout) findViewById(R.id.etsl_emojiContainer);
//        etsl_emojiContainer.setTabTitles(ChatEmojiManager.getInstance().getEmotionTagNames());
//        etsl_emojiContainer.setItemMap(ChatEmojiManager.getInstance().getTagEmotionMap());
//        //xml来控制
//
//        etsl_emojiContainer.notifyDataChanged();
//        iv_emojiSwitch = (ImageView)findViewById(R.id.iv_emojiSwitch);
//        iv_emojiSwitch.setImageDrawable(getResources().getDrawable(R.drawable.ic_liveroom_emojiswitch));
//        if(null != mIMRoomInItem){
//            iv_emojiSwitch.setVisibility(roomThemeManager.getRoomInputEmojiSwitchVisiable(this,mIMRoomInItem.roomType));
//        }

        //底部输入+礼物btn
        iv_gift = (ImageView) findViewById(R.id.iv_gift);
        //@谁
//        ll_audienceChooser = findViewById(R.id.ll_audienceChooser);
//        if(mRoomType == RoomType.Private){
//            ll_audienceChooser.setVisibility(View.GONE);
//        }else{
//            ll_audienceChooser.setOnClickListener(this);
//            tv_audienceNickname = (TextView) findViewById(R.id.tv_audienceNickname);
//            tv_audienceNickname.setOnClickListener(this);
//            tv_audienceNickname.setText(StringUtil.addAtFirst(lastSelectedAudienceInfoItem.nickName));
//
//            //设置初始@all
//            iv_audienceIndicator = (ImageView) findViewById(R.id.iv_audienceIndicator);
//            iv_audienceIndicator.setOnClickListener(this);
//            iv_audienceIndicator.setSelected(true);
//            lv_audienceList = (ListView) findViewById(R.id.lv_audienceList);
//            audienceSelectorAdapter = new AudienceSelectorAdapter(this,R.layout.item_simple_list_audience);
//            lv_audienceList.setAdapter(audienceSelectorAdapter);
//            lv_audienceList.setOnTouchListener(new View.OnTouchListener() {
//                @Override
//                public boolean onTouch(View v, MotionEvent event) {
//                    audienceSelectorAdapter.notifyDataSetChanged();
//                    return false;
//                }
//            });
//            lv_audienceList.setVisibility(View.GONE);
//            audienceSelectorAdapter.setOnItemListener(new CanOnItemListener(){
//                @Override
//                public void onItemChildClick(View view, int position) {
//                    lv_audienceList.setVisibility(View.GONE);
//                    iv_audienceIndicator.setSelected(true);
//                    synchronized (currAudienceInfoItems){
//                        lastSelectedAudienceInfoItem = currAudienceInfoItems.get(position);
//                        tv_audienceNickname.setText(StringUtil.addAtFirst(lastSelectedAudienceInfoItem.nickName));
//                    }
//
//                }
//            });
//            audienceSelectorAdapter.setList(currAudienceInfoItems);
//        }
    }

    /**
     * @谁
     */
    private void initAtWho(){
        ll_audienceChooser = findViewById(R.id.ll_audienceChooser);

        ll_audienceChooser.setVisibility(View.VISIBLE);
        ll_audienceChooser.setOnClickListener(this);
        tv_audienceNickname = (TextView) findViewById(R.id.tv_audienceNickname);
        tv_audienceNickname.setOnClickListener(this);
        tv_audienceNickname.setText(StringUtil.addAtFirst(lastSelectedAudienceInfoItem.nickName));

        //设置初始@all
        iv_audienceIndicator = (ImageView) findViewById(R.id.iv_audienceIndicator);
        iv_audienceIndicator.setOnClickListener(this);
        iv_audienceIndicator.setSelected(true);
        lv_audienceList = (ListView) findViewById(R.id.lv_audienceList);
        audienceSelectorAdapter = new AudienceSelectorAdapter(this,R.layout.item_simple_list_audience);
        lv_audienceList.setAdapter(audienceSelectorAdapter);
        lv_audienceList.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                audienceSelectorAdapter.notifyDataSetChanged();
                return false;
            }
        });
        lv_audienceList.setVisibility(View.GONE);
        audienceSelectorAdapter.setOnItemListener(new CanOnItemListener(){
            @Override
            public void onItemChildClick(View view, int position) {
                lv_audienceList.setVisibility(View.GONE);
                iv_audienceIndicator.setSelected(true);
                synchronized (currAudienceInfoItems){
                    lastSelectedAudienceInfoItem = currAudienceInfoItems.get(position);
                    tv_audienceNickname.setText(StringUtil.addAtFirst(lastSelectedAudienceInfoItem.nickName));
                }

            }
        });
        audienceSelectorAdapter.setList(currAudienceInfoItems);
    }

    private TextWatcher tw_msgEt = new TextWatcher() {
        @Override
        public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            Log.logD(TAG,"beforeTextChanged-s:"+s.toString()+" start:"+start+" count:"+count+" after:"+after);
        }

        @Override
        public void onTextChanged(CharSequence s, int start, int before, int count) {
            Log.logD(TAG,"onTextChanged-s:"+s.toString()+" start:"+start+" before:"+before+" count:"+count);
            lastTxtChangedStart = start;
            lastTxtChangedNumb = count;
        }

        @Override
        public void afterTextChanged(Editable s) {
            Log.logD(TAG,"afterTextChanged-s:"+s.toString());
            if(null == et_liveMsg){
                return;
            }
            if(s.toString().length()>liveMsgMaxLength){
                int selectedEndIndex = et_liveMsg.getSelectionEnd();
                int outStart = 0;
                //s.delete会瞬间触发TextChangedListener流程，导致lastTxtChangedNumb=0时多走一遍流程
                et_liveMsg.removeTextChangedListener(tw_msgEt);
//                if(etsl_emojiContainer.getVisibility() == View.VISIBLE && !TextUtils.isEmpty(lastInputEmoSign)){
//                    outStart = lastTxtChangedStart;
//                    s.delete(outStart,outStart+lastTxtChangedNumb);
//                    Log.logD(TAG,"afterTextChanged-outNumb:"+lastTxtChangedNumb
//                            +" outStart:"+outStart+" s:"+s.toString());
//                    lastInputEmoSign = null;
//                }else{
                    int outNumb = s.toString().length() -liveMsgMaxLength;
                    outStart = lastTxtChangedStart+lastTxtChangedNumb-outNumb;
                    s.delete(outStart,lastTxtChangedStart+lastTxtChangedNumb);
                    Log.logD(TAG,"afterTextChanged-outNumb:"+outNumb+" outStart:"+outStart+" s:"+s);
//                }
                et_liveMsg.setText(s.toString());
                et_liveMsg.setSelection(outStart);
                et_liveMsg.addTextChangedListener(tw_msgEt);
            }
        }
    };

    private void initEditAreaViewStyle(){
//        if(null != mIMRoomInItem && mIMRoomInItem.roomType == IMRoomInItem.IMLiveRoomType.FreePublicRoom){
//            iv_emojiSwitch.setVisibility(View.GONE);
//        }
    }

    private BeautyFilterDialog beautyFilterDialog;
    private void showBeautyDialog(){
        if (beautyFilterDialog == null) {
            beautyFilterDialog = new BeautyFilterDialog(mContext);
            beautyFilterDialog.setPushManager(mLiveStreamPushManager);
        }
        beautyFilterDialog.show();
    }

    /**
     * 收起@谁列表
     */
    private void hideAudienceList(){
        if(mRoomType == RoomType.Public && lv_audienceList != null){
            if(View.VISIBLE == lv_audienceList.getVisibility()){
                lv_audienceList.setVisibility(View.GONE);
                iv_audienceIndicator.setSelected(true);
            }
        }
    }

    /**
     * 发送
     */
    private void sendMsg(){
        if(mRoomType == RoomType.Public){
            if(enterKey2SendMsg(et_liveMsg.getText().toString(),
                    lastSelectedAudienceInfoItem.userId,
                    lastSelectedAudienceInfoItem.nickName)){
                //清空消息
                et_liveMsg.setText("");
            }
        }else{
            if(enterKey2SendMsg(et_liveMsg.getText().toString(),"0",null)){
                //清空消息
                et_liveMsg.setText("");
            }
        }
    }

    //------------------------ 弹幕消息编辑区域处理 start ------------------------

    @Override
    public void onClick(View v) {
        super.onClick(v);
        switch (v.getId()){
            case R.id.rl_media:
            case R.id.include_audience_area:
            case R.id.flMultiGift:
            case R.id.iv_vedioLoading:
            case R.id.ll_entranceCar:
            case R.id.fl_imMsgContainer:
            case R.id.ll_bulletScreen:
            case R.id.fl_msglist:
//            case R.id.fl_vedioOpear:
//                if (isSoftInputOpen) {
//                    hideSoftInput(et_liveMsg, true);
//                }else if(View.VISIBLE == lv_audienceList.getVisibility()){
//                    lv_audienceList.setVisibility(View.GONE);
//                    iv_audienceIndicator.setSelected(true);
//                }
//                else {
//                    boolean hasOpearViewShow = fl_vedioOpear.getVisibility() == View.VISIBLE;
//                    fl_vedioOpear.setVisibility(hasOpearViewShow ? View.GONE : View.VISIBLE);
//                }

                hideInputArea();
                hideAudienceList();

                break;
            case R.id.iv_switchCamera:
                hideInputArea();
//                if(View.VISIBLE == lv_audienceList.getVisibility()){
//                    lv_audienceList.setVisibility(View.GONE);
//                    iv_audienceIndicator.setSelected(true);
//                }else {
//                    switchCamera();
////                    fl_vedioOpear.setVisibility(View.GONE);
//                }
                hideAudienceList();
                switchCamera();
                break;
            case R.id.iv_close:
                hideInputArea();
//                if(View.VISIBLE == lv_audienceList.getVisibility()){
//                    lv_audienceList.setVisibility(View.GONE);
//                    iv_audienceIndicator.setSelected(true);
//                }else {
//                    if(!hasRoomInClosingStatus){
//                        lastSwitchLiveRoomId = null;
//                        lastSwitchLiveRoomType = LiveRoomType.Unknown;
//                        lastSwitchUserBaseInfoItem = null;
//                        userCloseRoom();
//                    }
////                    fl_vedioOpear.setVisibility(View.GONE);
//                }
                hideAudienceList();
                if(!hasRoomInClosingStatus){
                    lastSwitchLiveRoomId = null;
                    lastSwitchLiveRoomType = LiveRoomType.Unknown;
                    lastSwitchUserBaseInfoItem = null;
                    userCloseRoom();
                }
                break;
            case R.id.iv_beauty:
                //TODO 美颜
                showBeautyDialog();
                break;
            case R.id.ll_audienceChooser:
            case R.id.tv_audienceNickname:
            case R.id.iv_audienceIndicator:
                //切换观众昵称列表的选择状态
                boolean hasAudienceListShowed = View.VISIBLE == lv_audienceList.getVisibility();
                lv_audienceList.setVisibility(hasAudienceListShowed ? View.GONE : View.VISIBLE);
                iv_audienceIndicator.setSelected(hasAudienceListShowed);
                break;
//            case R.id.fl_imMsgContainer:
//            case R.id.ll_bulletScreen:
//            case R.id.fl_msglist:
//                hideInputArea();
//                if(View.VISIBLE == lv_audienceList.getVisibility()){
//                    lv_audienceList.setVisibility(View.GONE);
//                    iv_audienceIndicator.setSelected(true);
//                }
//                break;
            case R.id.iv_gift:
//                if(View.VISIBLE == lv_audienceList.getVisibility()){
//                    lv_audienceList.setVisibility(View.GONE);
//                    iv_audienceIndicator.setSelected(true);
//                }else{
//                    showLiveGiftDialog();
//                }

                hideAudienceList();
                showLiveGiftDialog();
                break;
            case R.id.iv_recommend:
                showRecommendDialog();
                break;
            case R.id.btn_to_mobile:
                doSwitchToMobileCamera();
                break;
        }
    }

    @Override
    protected void updatePublicOnLinePic(AudienceInfoItem[] audienceList) {
        super.updatePublicOnLinePic(audienceList);
        List<CircleImageHorizontScrollView.CircleImageObj> datas = new ArrayList<>();
        if(null != audienceList){
            for (AudienceInfoItem item : audienceList){
                //edit by Jagger 2018-5-4
                CircleImageHorizontScrollView.CircleImageObj circleImageObj = cihsv_onlineVIPPublic.new CircleImageObj(item.photoUrl,item);
                circleImageObj.setHasTicket(item.isHasTicket);
                datas.add(circleImageObj);
//                datas.add(cihsv_onlineVIPPublic.new CircleImageObj(item.photoUrl,item));
            }
        }
        updatePublicOnLineNum(datas.size());
        for(int temp = onLineDataReqStep - datas.size(); temp>0; temp--){
            //edit by Jagger 2018-5-4
            CircleImageHorizontScrollView.CircleImageObj circleImageObj = cihsv_onlineVIPPublic.new CircleImageObj(defaultAudienceInfoItem.photoUrl,defaultAudienceInfoItem);
            circleImageObj.setHasTicket(defaultAudienceInfoItem.isHasTicket);
            datas.add(circleImageObj);
//            datas.add(cihsv_onlineVIPPublic.new CircleImageObj(defaultAudienceInfoItem.photoUrl,defaultAudienceInfoItem));
        }
        //更新头像列表
        cihsv_onlineVIPPublic.setList(datas);
        synchronized (currAudienceInfoItems){
            currAudienceInfoItems.clear();
            currAudienceInfoItems.add(defaultAudienceInfoItem);
            if(null != audienceList){
                currAudienceInfoItems.addAll(Arrays.asList(audienceList));
            }
        }
        audienceSelectorAdapter.setList(currAudienceInfoItems);

    }

    @Override
    protected void onDisconnectRoomIn() {
        super.onDisconnectRoomIn();
        if(mRoomType == RoomType.Private){
            //私密直播间 断线重连 重置男士互动视频模块 推流地址
            if(isStreamPulling && null != lastManPullUrls && lastManPullUrls.length>0 && mLiveStreamPullManager != null){
                mLiveStreamPullManager.setOrChangeVideoUrls(lastManPullUrls, "", "",null);
            }else{
                mLiveStreamPullManager.stopPlayInternal();
            }
        }else {
            //公开直播间 断线重连 查询直播间在线头像列表数据
            updatePublicRoomOnlineData();
        }
    }


    protected void updatePublicOnLineNum(int fansNum) {
        super.updatePublicOnLineNum(fansNum);
        //公开直播间界面更新房间人数信息后刷新头像列表
        String fansStr = getResources().getString(R.string.liveroom_header_vipguestdata,
                String.valueOf(fansNum),String.valueOf(onLineDataReqStep));
        int blankFirstIndex = fansStr.indexOf("/");
        Log.d(TAG,"updatePublicOnLineNum-fansStr:"+fansStr+" blankFirstIndex:"+blankFirstIndex);
        SpannableString spannableString = new SpannableString(fansStr);
        spannableString.setSpan(
                new ForegroundColorSpan(getResources().getColor(R.color.public_liveroom_audience_current)),
                0,blankFirstIndex, Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
        spannableString.setSpan(
                new ForegroundColorSpan(getResources().getColor(R.color.public_tran_txt_color)),
                blankFirstIndex,fansStr.length(), Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
        tv_vipGuestData.setText(spannableString);

    }

    //------------------------ 直播转换 start ------------------------
    /**
     * 提示可转换为手机直播操作按钮
     */
    private void showToMobileCameraTips(){
        ll_pc_to_mobile.setVisibility(View.VISIBLE);
        iv_vedioLoading.setVisibility(View.GONE);
        // 显示服务器的返回提示
        if(mIMRoomInItem != null && mIMRoomInItem.currentPush != null && !TextUtils.isEmpty(mIMRoomInItem.currentPush.message)){
            tv_pc_to_mobile.setText(mIMRoomInItem.currentPush.message);
        }
    }

    /**
     * 隐藏可转换为手机直播操作按钮
     */
    private void hideMobileCameraTips(){
        ll_pc_to_mobile.setVisibility(View.GONE);
    }

    /**
     * 转换为手机直播
     */
    private void doSwitchToMobileCamera(){
        //发送指令,侍回调(OnAnchorSwitchFlow)处理
        mIMManager.AnchorSwitchFlow(mIMRoomInItem.roomId);
    }

    @Override
    public void OnAnchorSwitchFlow(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, String[] pushUrl, IMClientListener.IMDeviceType deviceType) {
        if(success && deviceType == IMClientListener.IMDeviceType.App){
            Message msg = new Message();
            msg.what = EVENT_SWITHFLOW_APP_OPEN;
            msg.obj = pushUrl;
            sendUiMessage(msg);
        }else{
            Message msg = new Message();
            msg.what = EVENT_SWITHFLOW_APP_CLOSE;
            msg.obj = errMsg;
            sendUiMessage(msg);
        }
    }

    @Override
    public void onPcToApp(String manId, String manName, String manPhotoUrl) {
        //不作处理
//        super.onPcToApp(manId, manName, manPhotoUrl);
    }

    //------------------------ 直播转换 end ------------------------

    //------------------------ 私密直播男士视频 start ------------------------
    /**
     * 初始化视频互动界面
     */
    private void initPublishView(){
        Log.d(TAG,"initPublishView");
        mLiveStreamPullManager = new LiveStreamPullManager(this);
        //old
        //视频上传预览
//        includePull = findViewById(R.id.includePull);
//        fl_man_video = findViewById(R.id.fl_man_video);
//        sv_pull = (GLSurfaceView)findViewById(R.id.sv_pull);
//        //初始化必须在界面显示前调用，否则会出现由于未设置render导致 oncreate空指针异常
//        mLiveStreamPullManager.init(sv_pull);
//        //add by Jagger 2017-11-29 解决小窗口能浮在大窗口上的问题
//        sv_pull.setZOrderOnTop(true);
//        sv_pull.setZOrderMediaOverlay(true);
//        sv_pull.getHolder().setFormat(PixelFormat.TRANSPARENT);
//        sv_pull.getHolder().setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);

//        ViewDragTouchListener listener = new ViewDragTouchListener(100l);
//        listener.setOnViewDragListener(new ViewDragTouchListener.OnViewDragStatusChangedListener() {
//            @Override
//            public void onViewDragged(int l, int t, int r, int b) {
//                //避免父布局重绘后includePublish回到原来的位置
//                RelativeLayout.LayoutParams flIPublish = (RelativeLayout.LayoutParams) includePull.getLayoutParams();
////                flIPublish.gravity = Gravity.TOP|Gravity.LEFT;
//                flIPublish.leftMargin = includePull.getLeft();
//                flIPublish.topMargin = includePull.getTop();
//                includePull.setLayoutParams(flIPublish);
//            }
//        });
//        includePull.setOnTouchListener(listener);

        //new
        fl_man_video = findViewById(R.id.fl_man_video);
        sv_pull = createPullSurfaceView();
        mLiveStreamPullManager.init(sv_pull);

        //高斯模糊头像部分
//        view_gaussian_blur_me = findViewById(R.id.view_gaussian_blur_me);
        v_gaussianBlurFloat = findViewById(R.id.v_gaussianBlurFloat);
        iv_gaussianBlur = (SimpleDraweeView)findViewById(R.id.iv_gaussianBlur);
    }

    /**
     * 建立一个临时GLSurfaceView,用于拉流视频
     */
    private GLSurfaceView createPullSurfaceView(){
        GLSurfaceView tempSurfaceView = new GLSurfaceView(mContext);

//        ConstraintLayout.LayoutParams layoutParams = (ConstraintLayout.LayoutParams)fl_man_video.getLayoutParams();
//        layoutParams.width = getResources().getDimensionPixelSize(R.dimen.live_room_pri_man_video_width); //DisplayUtil.getScreenWidth(mContext) *3/4;
//        layoutParams.height = getResources().getDimensionPixelSize(R.dimen.live_room_pri_man_video_height); //DisplayUtil.getScreenWidth(mContext) *3/4;
////        layoutParams.gravity = gravity;
//
//        tempSurfaceView.setZOrderMediaOverlay(true);
//        fl_man_video.addView(tempSurfaceView, layoutParams);

        tempSurfaceView.setZOrderMediaOverlay(true);
        fl_man_video.addView(tempSurfaceView);
        return tempSurfaceView;
    }

    /**
     * 显示男士视频
     */
    private void showManVideo(){
        fl_man_video.setVisibility(View.VISIBLE);
        if(sv_pull == null){
            sv_pull = createPullSurfaceView();
            mLiveStreamPullManager.changePlayer(sv_pull);
        }
    }

    /**
     * 收起男士视频
     */
    private void hideManVideo(){
        fl_man_video.removeAllViews();  //一定要把SurfaceView清掉，不然会残留一个影像
        fl_man_video.setVisibility(View.GONE);
        sv_pull.destroyDrawingCache();
        sv_pull = null;
    }

    /**
     * add by Jagger 2017-12-1
     * 回收拉流播放器
     */
    private void destroyPullManager(){
        //回收拉流播放器
        if(mLiveStreamPullManager != null){
            mLiveStreamPullManager.release();
            mLiveStreamPullManager = null;
        }
    }

    /**
     * add by Jagger 2017-12-6
     * 因为在P6中,当看不见浮动的视频窗体时,小窗体的内容会显示在主播视频区中,
     * 所以,弹出键盘时,把它移到输入框下面
     */
//    private void doMovePullViewUnderEditView(){
//        Log.d(TAG,"doMovePullViewUnderEditView");
//        //应用程序App区域宽高等尺寸获取
//        Rect rect = new Rect();
//        getWindow().getDecorView().getWindowVisibleDisplayFrame(rect);
//        int edBottomY = rect.height() - 1;
//
//        ConstraintLayout.LayoutParams flIPublish = (ConstraintLayout.LayoutParams) includePull.getLayoutParams();
//        //移动
//        if(flIPublish.topMargin > edBottomY){
//            //记录移动前的TOP
//            mIPublishTempTop = flIPublish.topMargin;
//            //
//            flIPublish.topMargin = edBottomY;
//            includePull.setLayoutParams(flIPublish);
//            //
//            mIsMovePullViewUnderEditView = true;
//        }
//    }
//
//    /**
//     * add by Jagger 2017-12-6
//     * 还原浮动的视频窗体位置,对应doMovePublishViewUnderEditView()
//     */
//    private void doReMovePullView(){
//        Log.d(TAG,"doReMovePullView");
//        if(mIsMovePullViewUnderEditView && mIPublishTempTop != -1){
//            ConstraintLayout.LayoutParams flIPublish = (ConstraintLayout.LayoutParams) includePull.getLayoutParams();
//            flIPublish.topMargin = mIPublishTempTop;
//            includePull.setLayoutParams(flIPublish);
//            mIsMovePullViewUnderEditView = false;
//        }
//    }

    /**
     * 权限检查
     * TODO:这里看下是否需要权限检查才可以推流主播拉流互动视频的视频流数据?
     */
    private void checkPermissions(){
        PermissionManager permissionManager = new PermissionManager(mContext, new PermissionManager.PermissionCallback() {
            @Override
            public void onSuccessful() {
                //开启主播视频流push
            }

            @Override
            public void onFailure() {

            }
        });

        permissionManager.requestVideo();
    }

    /**
     * 推荐主播列表对话框
     */
    protected void showRecommendDialog(){
        FragmentManager fragmentManager = getSupportFragmentManager();
        RecommendDialogFragment.showDialog(fragmentManager , mIMRoomInItem.roomId , manNickName);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        //系统<设置>界面权限返回处理
        switch (requestCode) {
            case PermissionManager.REQUEST_CODE_SYSSETTING: {
                //开启主播视频流push/互动视频流pull
            }break;
        }
    }

    /**
     * 互动视频断线相关处理
     */
    @Override
    public void onPullStreamDisconnect() {
        super.onPullStreamDisconnect();
        //通知推流和拉流管理器，IM 断开链接
        if(mLiveStreamPullManager != null){
            mLiveStreamPullManager.onLogout();
        }
    }


    @Override
    public void onManVedioPushStatusChanged(String roomId, String userId, String nickname, String avatarImg,
                                            IMClientListener.IMVideoInteractiveOperateType operateType,
                                            String[] pushUrls) {
        super.onManVedioPushStatusChanged(roomId, userId, nickname, avatarImg, operateType, pushUrls);
        isStreamPulling = operateType == IMClientListener.IMVideoInteractiveOperateType.Start;
//        view_gaussian_blur_me.setVisibility(isStreamPulling ? View.GONE : View.VISIBLE);
        lastManPullUrls = isStreamPulling ? pushUrls : new String[]{};
        Log.d(TAG,"onManVedioPushStatusChanged-isStreamPulling:"+isStreamPulling);
        if(isStreamPulling && mLiveStreamPullManager != null){
            mLiveStreamPullManager.setOrChangeVideoUrls(lastManPullUrls,  "", "",null);
        }else{
            mLiveStreamPullManager.stopPlayInternal();
        }
        //聊天列表插入普通公告
        String message = getResources().getString(isStreamPulling ? R.string.private_live_interactive_vedio_open
                : R.string.private_live_interactive_vedio_close,nickname);
        IMSysNoticeMessageContent msgContent = new IMSysNoticeMessageContent(message,null,
                IMSysNoticeMessageContent.SysNoticeType.Normal);
        IMMessageItem msgItem = new IMMessageItem(roomId,mIMManager.mMsgIdIndex.getAndIncrement(),"",
                IMMessageItem.MessageType.SysNotice,msgContent);
        sendMessageUpdateEvent(msgItem);

        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if(isStreamPulling){
                    showManVideo();
                }else{
                    hideManVideo();
                }
            }
        });
    }

    //------------------------ 私密直播男士视频 end ------------------------



    //------------------------ 私密直播才艺点播 start ------------------------
    private DialogNormal mTalentDialog;
    private static final int TALENT_REQUEST_VALID_DURATION = 60 * 1000;     //弹出才艺点播后，1分钟后自动关闭dialog

    @Override
    public void OnRecvTalentRequestNotice(final String talentInvitationId, final String name,
                                          final String userId, final String nickName){
        super.OnRecvTalentRequestNotice(talentInvitationId,name,userId,nickName);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                showTalentDialog(talentInvitationId, name, userId, nickName);
            }
        });
    }

    /**
     * 显示才艺dialog
     * @param talentInvitationId
     * @param name
     * @param userId
     * @param nickName
     */
    private void showTalentDialog(final String talentInvitationId, final String name, String userId, final String nickName){
        String desHtml = getString(R.string.live_talent_request_des , nickName , name);

        DialogNormal.Builder builder = new DialogNormal.Builder().setContext(mContext)
                .setTitleImgResId(R.drawable.live_talent_icon)
                .setTitle(getString(R.string.live_talent_request_title))
                .setCancleable(false)
                .setOutsideTouchable(false)
                .setDesHtml(desHtml)
                .setBtnLeft(new DialogNormal.Button(
                        getString(R.string.common_button_decline),
                        true,
                        new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                //点击拒绝
                                DeclineTalentRequest(talentInvitationId, name, nickName);
                            }
                        }
                ))
                .setBtnRight(new DialogNormal.Button(
                        getString(R.string.common_button_accept),
                        false,
                        true,
                        new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                //请求接口
                                acceptTalentRequest(talentInvitationId, name, nickName);
                            }
                        }
                ));

        //dialogNormal设置为全局
        if(mTalentDialog != null){
            mTalentDialog.dismiss();
        }

        //关闭旧定时器，启动新定时器
        removeUiMessages(EVENT_TALENT_OVER_TIME_CLOSE);
        sendUiMessageDelayed(EVENT_TALENT_OVER_TIME_CLOSE, TALENT_REQUEST_VALID_DURATION);

        mTalentDialog = DialogNormal.setBuilder(builder);
        if(isActivityVisible()) {
            mTalentDialog.show();
        }
    }

    /**
     * 拒绝才艺邀请
     * @param talentInviteId
     * @param name
     * @param nickName
     */
    private void DeclineTalentRequest(String talentInviteId, String name, String nickName){
        //通知聊天区插入消息
        onTalentResp(false, nickName, name);

        LiveRequestOperator.getInstance().DealTalentRequest(talentInviteId, TalentReplyType.REJECT, new OnRequestCallback() {
            @Override
            public void onRequest(boolean isSuccess, int errCode, String errMsg) {

            }
        });
    }

    /**
     * 接受才艺邀请
     * @param talentInviteId
     * @param name
     * @param nickName
     */
    private void acceptTalentRequest(String talentInviteId, final String name, final String nickName){
        Log.d(TAG,"acceptTalentRequest-talentInviteId:"+talentInviteId+" name:"+name+" nickName:"+nickName);
        showLoadingDialog();
        LiveRequestOperator.getInstance().DealTalentRequest(talentInviteId, TalentReplyType.AGREE, new OnRequestCallback() {
            @Override
            public void onRequest(final boolean isSuccess, final int errCode, final String errMsg) {
                Log.d(TAG,"acceptTalentRequest-onRequest-isSuccess:"+isSuccess+" errCode:"+errCode+" errMsg:"+errMsg);
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        hideLoadingDialog();
                        if(isSuccess){
                            onTalentResp(true, nickName, name);
                            if(mTalentDialog != null){
                                mTalentDialog.dismiss();
                            }
                        }else{
                            HttpLccErrType errType = IntToEnumUtils.intToHttpErrorType(errCode);
                            if(errType != HttpLccErrType.HTTP_LCC_ERR_CONNECTFAIL){
                                if(mTalentDialog != null){
                                    mTalentDialog.dismiss();
                                }
                            }
                            showToast(errMsg);
                        }
                    }
                });
            }
        });
    }

    /**
     * 主播处理用户才艺点播结果的界面展示回调
     * @param isAccepted true-接受，false-拒绝
     * @param manNickname 男士昵称
     * @param talentName 才艺名称
     */
    public void onTalentResp(boolean isAccepted,String manNickname,String talentName){
        Log.d(TAG,"onTalentResp-isAccepted:"+isAccepted +" manNickname:"+manNickname+" talentName:"+talentName);
        String talentResMessage = getResources().getString(isAccepted?
                        R.string.private_live_anchor_accepted_talent : R.string.private_live_anchor_declined_talent,
                manNickname,talentName);
        Log.d(TAG,"onTalentResp-talentResMessage:"+talentResMessage);
        IMSysNoticeMessageContent msgContent = new IMSysNoticeMessageContent(talentResMessage,null,
                IMSysNoticeMessageContent.SysNoticeType.Normal);
        IMMessageItem msgItem = new IMMessageItem(mIMRoomInItem.roomId,mIMManager.mMsgIdIndex.getAndIncrement(),"",
                IMMessageItem.MessageType.SysNotice,msgContent);
        sendMessageUpdateEvent(msgItem);
    }

    //------------------------ 私密直播才艺点播 end ------------------------



    //------------------------ 私密直播接收推荐好友通知 start ------------------------
    /**
     * 10.4.接收推荐好友通知
     * add by Jagger 2018-5-17
     * @param item
     */
    @Override
    public void OnRecvAnchorRecommendHangoutNotice(IMHangoutRecommendItem item) {
        Log.d(TAG,"OnRecvAnchorRecommendHangoutNotice-item:"+item);

        //男士昵称 强行插入
        item.manNickeName = manNickName;
        //插入信息列表
        IMMessageItem msgItem = new IMMessageItem(item.roomId ,
                mIMManager.mMsgIdIndex.getAndIncrement(),
                IMMessageItem.MessageType.HangOut,
                item);
        sendMessageUpdateEvent(msgItem);
    }
    //------------------------ 私密直播接收推荐好友通知 end ------------------------

    @Override
    public void onRecvLeavingRoomNotice(int leftSeconds) {
        if(mRoomType == RoomType.Private){
            //私密直播间
            fl_vedioTips.setVisibility(View.VISIBLE);
            if(privateLiveInvitedByAnchor && lastSwitchUserBaseInfoItem != null){
                //%1$s has accepted. Broadcast will end in 30s
                iv_vedioTips.setVisibility(View.VISIBLE);
                //私密邀请男士接受，直播间倒计时
                Drawable tempDrawable = iv_vedioTips.getDrawable();
                if((tempDrawable != null) && (tempDrawable instanceof AnimationDrawable)){
                    ((AnimationDrawable)tempDrawable).stop();
                }
                iv_vedioTips.setImageResource(R.drawable.ic_anchor_private_invite_accepted);
                if(null != lastSwitchUserBaseInfoItem && !TextUtils.isEmpty(lastSwitchUserBaseInfoItem.nickName)){
                    tv_vedioTip0.setVisibility(View.VISIBLE);
                    tv_vedioTip0.setText(lastSwitchUserBaseInfoItem.nickName);
                }
                tv_vedioTip1.setVisibility(View.VISIBLE);
                tv_vedioTip1.setText(getResources().getString(R.string.liveroom_leaving_room_time_count_tips2));
            }else{
                tv_vedioTip0.setVisibility(View.GONE);
                tv_vedioTip1.setVisibility(View.VISIBLE);
                tv_vedioTip1.setText(getResources().getString(R.string.liveroom_leaving_room_time_count_tips1));
                //Broadcast will end in 30s
                iv_vedioTips.setVisibility(View.GONE);
            }
            tv_vedioTip2.setVisibility(View.GONE);
            tv_vedioTip3.setVisibility(View.VISIBLE);
            tv_vedioTip3.setText(String.valueOf(30));
            tv_vedioTip4.setVisibility(View.VISIBLE);
            tv_vedioTip4.setText(getResources().getString(R.string.liveroom_leaving_room_time_count_s));
        }else{
            //公开直播间
            fl_vedioTips.setVisibility(View.VISIBLE);
            if(privateLiveInvitedByAnchor && lastSwitchUserBaseInfoItem != null){
                //所有直播间的倒计时逻辑都只是显示Broadcast will end in 30s
            }/*else{*/
            tv_vedioTip0.setVisibility(View.GONE);
            tv_vedioTip1.setVisibility(View.VISIBLE);
            tv_vedioTip1.setText(getResources().getString(R.string.liveroom_leaving_room_time_count_tips1));
            //Broadcast will end in 30s
            iv_vedioTips.setVisibility(View.GONE);
//        }
            tv_vedioTip2.setVisibility(View.GONE);
            tv_vedioTip3.setVisibility(View.VISIBLE);
            tv_vedioTip3.setText(String.valueOf(leftSeconds));
            tv_vedioTip4.setVisibility(View.VISIBLE);
            tv_vedioTip4.setText(getResources().getString(R.string.liveroom_leaving_room_time_count_s));
        }

        super.onRecvLeavingRoomNotice(leftSeconds);
    }

    @Override
    public void updateRoomCloseTimeCount(int timeCount) {
        super.updateRoomCloseTimeCount(timeCount);
        tv_vedioTip3.setText(String.valueOf(timeCount));
    }

    /**
     * 向男士发送立即私密邀请
     * @param manUserId
     */
    public void sendPrivLiveInvite2Man(String manUserId, String manUsername, String manPhotoUrl){
        Log.d(TAG,"sendPrivLiveInvite2Man-manUserId:"+manUserId
                +" manUsername:"+manUsername+" manPhotoUrl:"+manPhotoUrl);
        //:1.增加不可发送场景的判断逻辑:客户端只需判断是否已有一次私密邀请发送且处于超时时间内
        lastInviteManNickname = manUsername;
        lastInviteManPhotoUrl = manPhotoUrl;
        lastInviteManUserId = manUserId;
        if(null != mIMManager && !TextUtils.isEmpty(manUserId)){
            mIMManager.sendImmediatePrivateInvite(manUserId);
        }
    }

    @Override
    public void OnRecvAnchorLeaveRoomNotice(String roomId, String anchorId) {
        //新增逻辑:如果有处于超时时间内等待回应的主播私密男士邀请，则取消该邀请
        if(!TextUtils.isEmpty(lastPrivateLiveInvitationId)){
            LiveRequestOperator.getInstance().CancelInstantInvite(lastPrivateLiveInvitationId, new OnRequestCallback() {
                @Override
                public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                    Log.d(TAG,"OnRecvAnchorLeaveRoomNotice-onRequest-isSuccess:"+isSuccess+" errCode:"+errCode+" errMsg:"+errMsg);
                }
            });
            lastPrivateLiveInvitationId = null;
        }
        super.OnRecvAnchorLeaveRoomNotice(roomId, anchorId);
    }

    @Override
    public void OnRecvRoomCloseNotice(String roomId, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
        //新增逻辑:如果有处于超时时间内等待回应的主播私密男士邀请，则取消该邀请
        if(!TextUtils.isEmpty(lastPrivateLiveInvitationId)){
            LiveRequestOperator.getInstance().CancelInstantInvite(lastPrivateLiveInvitationId, new OnRequestCallback() {
                @Override
                public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                    Log.d(TAG,"OnRecvRoomCloseNotice-onRequest-isSuccess:"+isSuccess+" errCode:"+errCode+" errMsg:"+errMsg);
                }
            });
            lastPrivateLiveInvitationId = null;
        }
        super.OnRecvRoomCloseNotice(roomId, errType, errMsg);
    }

    @Override
    public void OnSendImmediatePrivateInvite(int reqId, final boolean success,
                                             IMClientListener.LCC_ERR_TYPE errType, final String errMsg,final IMSendInviteInfoItem inviteInfoItem) {
        super.OnSendImmediatePrivateInvite(reqId, success, errType, errMsg, inviteInfoItem);

        //成功则 1.显示私密邀请发送提示动画;2.增加超时定时器，处理邀请超时逻辑；失败则toast提示
        if(success){
            //9.1.主播发送立即私密邀请 可作为 男士私密邀请的应邀处理（服务器处理）,因此需要判断下roomId是否有值返回，有则直接调用roomOut，
            // 并记录lastSwitchUserBaseInfoItem和lastSwitchLiveRoomId
            if(!TextUtils.isEmpty(inviteInfoItem.roomId)){
                lastSwitchUserBaseInfoItem = new IMUserBaseInfoItem(lastInviteManUserId,lastInviteManNickname,lastInviteManPhotoUrl);
                lastSwitchLiveRoomId = inviteInfoItem.roomId;
                privateLiveInvitedByAnchor = true;
                lastSwitchLiveRoomType = LiveRoomType.AdvancedPrivateRoom;
            }else{
                sendEmptyUiMessageDelayed(EVENT_PRIVINVITE_RESP_TIMEOUT,inviteInfoItem.timeOut*1000l);
            }
            lastInviteSendSucManNickName = lastInviteManNickname;
            lastPrivateLiveInvitationId = inviteInfoItem.inviteId;
        }
        lastInviteManNickname = null;
        lastInviteManPhotoUrl = null;
        lastInviteManUserId = null;
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if(success){
                    removeUiMessages(EVENT_PRIVINVITE_RESP_TIPS_HINT);
                    if(!TextUtils.isEmpty(inviteInfoItem.roomId)){
                        switchLiveRoom();
                    }else{fl_vedioTips.setVisibility(View.VISIBLE);
                        if(privateLiveInvitedByAnchor && lastSwitchUserBaseInfoItem != null){
                            //%1$s has accepted. Broadcast will end in 30s
                            iv_vedioTips.setVisibility(View.VISIBLE);
                            //私密邀请男士接受，直播间倒计时
                            Drawable tempDrawable = iv_vedioTips.getDrawable();
                            if((tempDrawable != null) && (tempDrawable instanceof AnimationDrawable)){
                                ((AnimationDrawable)tempDrawable).stop();
                            }
                            iv_vedioTips.setImageResource(R.drawable.ic_anchor_private_invite_accepted);
                            if(null != lastSwitchUserBaseInfoItem && !TextUtils.isEmpty(lastSwitchUserBaseInfoItem.nickName)){
                                tv_vedioTip0.setVisibility(View.VISIBLE);
                                tv_vedioTip0.setText(lastSwitchUserBaseInfoItem.nickName);
                            }
                            tv_vedioTip1.setVisibility(View.VISIBLE);
                            tv_vedioTip1.setText(getResources().getString(R.string.liveroom_leaving_room_time_count_tips2));
                        }else{
                            tv_vedioTip0.setVisibility(View.GONE);
                            tv_vedioTip1.setVisibility(View.VISIBLE);
                            tv_vedioTip1.setText(getResources().getString(R.string.liveroom_leaving_room_time_count_tips1));
                            //Broadcast will end in 30s
                            iv_vedioTips.setVisibility(View.GONE);
                        }
                        tv_vedioTip2.setVisibility(View.GONE);
                        tv_vedioTip3.setVisibility(View.VISIBLE);
                        tv_vedioTip3.setText(String.valueOf(30));
                        tv_vedioTip4.setVisibility(View.VISIBLE);
                        tv_vedioTip4.setText(getResources().getString(R.string.liveroom_leaving_room_time_count_s));
                        showPrivInvitingAnimTips();
                    }
                }else{
                    showToast(errMsg);
                }
            }
        });
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        switch (msg.what){
            case EVENT_PRIVINVITE_RESP_TIMEOUT:
                //停止动画、更改提示为超时，三秒后消失
                showPrivInviteTimeOutTips();
                sendEmptyUiMessageDelayed(EVENT_PRIVINVITE_RESP_TIPS_HINT,3000l);
                break;
            case EVENT_PRIVINVITE_RESP_TIPS_HINT:
                fl_vedioTips.setVisibility(View.GONE);
                break;
            case EVENT_TALENT_OVER_TIME_CLOSE:{
                    if(mTalentDialog != null){
                        mTalentDialog.dismiss();
                    }
                }break;
            case EVENT_SWITHFLOW_APP_OPEN:
                //选择APP推流
                hideMobileCameraTips();
                String[] urls = (String[])msg.obj;
                if(urls != null && urls.length > 0){
                    startAnchorLivePusher(urls);
                }
                break;
            case EVENT_SWITHFLOW_APP_CLOSE:
                //关闭APP推流
                stopAnchorLivePusher();
                showToMobileCameraTips();
                showToast(String.valueOf(msg.obj));
                break;
        }
    }

    /**
     * 主播私密邀请过期/被拒绝提示
     */
    private void showPrivInviteTimeOutTips(){
        lastPrivateLiveInvitationId = null;
        Log.d(TAG,"showPrivInviteTimeOutTips-lastInviteSendSucManNickName:"+lastInviteSendSucManNickName
                +" lastPrivateLiveInvitationId:"+lastPrivateLiveInvitationId);
        //1.停止动画，变更文案,三秒定时器
        fl_vedioTips.setVisibility(View.VISIBLE);
        iv_vedioTips.setVisibility(View.VISIBLE);
        Drawable tempDrawable = iv_vedioTips.getDrawable();
        if((tempDrawable != null) && (tempDrawable instanceof AnimationDrawable)){
            ((AnimationDrawable)tempDrawable).stop();
        }
        iv_vedioTips.setImageResource(R.drawable.ic_anchor_private_invite_refused);
        //lastSwitchLiveManUserName
        tv_vedioTip0.setVisibility(View.GONE);
        tv_vedioTip1.setVisibility(View.VISIBLE);
        //No response from %1$s, please try again later
        tv_vedioTip1.setText(getResources().getString(R.string.public_live_invite_privlive_timeout1));
        if(!TextUtils.isEmpty(lastInviteSendSucManNickName)){
            tv_vedioTip2.setVisibility(View.VISIBLE);
            tv_vedioTip2.setText(lastInviteSendSucManNickName);
        }
        tv_vedioTip3.setVisibility(View.GONE);
        tv_vedioTip4.setText(getResources().getString(R.string.public_live_invite_privlive_timeout2));
        tv_vedioTip4.setVisibility(View.VISIBLE);
    }

    /**
     * 展示私密邀请中提示
     */
    private void showPrivInvitingAnimTips(){
        Log.d(TAG,"showPrivInvitingAnimTips-lastInviteSendSucManNickName:"+lastInviteSendSucManNickName);
        fl_vedioTips.setVisibility(View.VISIBLE);
        iv_vedioTips.setVisibility(View.VISIBLE);
        iv_vedioTips.setImageResource(R.drawable.anim_public_inviting_tips);
        Drawable tempDrawable = iv_vedioTips.getDrawable();
        if((tempDrawable != null) && (tempDrawable instanceof AnimationDrawable)){
            ((AnimationDrawable)tempDrawable).start();
        }
        //Inviting %1$s to One-on-One...
        tv_vedioTip0.setVisibility(View.GONE);
        tv_vedioTip1.setVisibility(View.VISIBLE);
        tv_vedioTip1.setText(getResources().getString(R.string.public_live_inviting_privlive1));
        if(!TextUtils.isEmpty(lastInviteSendSucManNickName)){
            tv_vedioTip2.setVisibility(View.VISIBLE);
            tv_vedioTip2.setText(lastInviteSendSucManNickName);
        }
        tv_vedioTip4.setVisibility(View.VISIBLE);
        tv_vedioTip4.setText(getResources().getString(R.string.public_live_inviting_privlive2));
        tv_vedioTip3.setVisibility(View.GONE);
    }

    @Override
    public void OnRecvInviteReply(String inviteId, final IMClientListener.InviteReplyType replyType,
                                  final String roomId, final LiveRoomType roomType, final String userId,
                                  final String nickName, final String avatarImg) {
        super.OnRecvInviteReply(inviteId, replyType, roomId, roomType, userId, nickName, avatarImg);
        //1.修改私密邀请结果提示，隐藏并停止动画;2.超时时间内停止超时定时器;3.如果男士确认，则调用roomout并完善后续私密直播间跳转逻辑;
        //1.本地记录必要信息
        lastSwitchUserBaseInfoItem = new IMUserBaseInfoItem(userId,nickName,avatarImg);

        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                removeUiMessages(EVENT_PRIVINVITE_RESP_TIMEOUT);
                //接受，那么调用roomout
                if(replyType == IMClientListener.InviteReplyType.Accepted){
                    lastSwitchLiveRoomId = roomId;
                    privateLiveInvitedByAnchor = true;
                    lastSwitchLiveRoomType = roomType;
                    //列表区域插入一条公告
                    if(null != mIMRoomInItem && !TextUtils.isEmpty(mIMRoomInItem.roomId) && null != mIMManager && null != mIMManager.mMsgIdIndex){
                        String message = getResources().getString(R.string.liveroom_invite_accepted_sysnotice,lastSwitchUserBaseInfoItem.nickName);
                        IMSysNoticeMessageContent msgContent = new IMSysNoticeMessageContent(message,null,
                                IMSysNoticeMessageContent.SysNoticeType.Normal);
                        IMMessageItem msgItem = new IMMessageItem(mIMRoomInItem.roomId,mIMManager.mMsgIdIndex.getAndIncrement(),"",
                                IMMessageItem.MessageType.SysNotice,msgContent);
                        sendMessageUpdateEvent(msgItem);
                    }
                    switchLiveRoom();
                }else{
                    showPrivInviteTimeOutTips();
                    sendEmptyUiMessageDelayed(EVENT_PRIVINVITE_RESP_TIPS_HINT,3000l);
                }
            }
        });
    }

    @Override
    protected void preStopLive() {
        super.preStopLive();
        if(isActivityFinishByUser){
            if(null != sv_pull){
                sv_pull.setVisibility(View.INVISIBLE);
            }
            if(null != sv_push){
                sv_push.setVisibility(View.INVISIBLE);
            }
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        removeUiMessages(EVENT_PRIVINVITE_RESP_TIMEOUT);
        removeUiMessages(EVENT_PRIVINVITE_RESP_TIPS_HINT);
        //add by Jagger 2019-10-31
        destroyPullManager();
        //add by Jagger 2018-6-20
        if(null != liveRoomChatManager){
            liveRoomChatManager.destroy();
        }

        //解绑监听器，防止泄漏
        if (flContentBody != null) {
            flContentBody.removeOnResizeListener(this);
        }
    }

    @Override
    protected void preEndLiveRoom(String description) {
        super.preEndLiveRoom(description);
        if(mRoomType == RoomType.Private){
            //私密直播间结束页面传男士头像地址
            LiveRoomEndActivity.show(this, manPhotoUrl, description);
        }else{
            //公开直播间传自己头像
            if(null != mIMRoomInItem){
                if(null != loginItem && !TextUtils.isEmpty(loginItem.photoUrl)){
                    LiveRoomEndActivity.show(this,loginItem.photoUrl, description);
                }
            }
        }
    }

    @Override
    public void OnRecvEnterRoomNotice(String roomId, String userId, String nickName, String photoUrl, String riderId, String riderName, String riderUrl, int fansNum, boolean isHasTicket) {
        super.OnRecvEnterRoomNotice(roomId, userId, nickName, photoUrl, riderId, riderName, riderUrl, fansNum, isHasTicket);

        mBeepAndVibrateUtil.playBeep();
        mBeepAndVibrateUtil.playVibrate();
    }

    // ---------- keyboard FS start ---------
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
     * 显示输入法
     */
    private void showKeyBoard() {
        if (mInputAreaStatus == InputAreaStatus.KEYBOARD) return;
//        Log.i("Jagger", "showKeyBoard");

        //与其它控件显示关系的约束，最好不要乱改
        // ***start***
        showInputArea();
        showSoftInput(et_liveMsg);
//        if (mInputAreaStatus == InputAreaStatus.EMOJI) {
//            hideEmojiBoard();
//        }
        mInputAreaStatus = InputAreaStatus.KEYBOARD;
        // ***end***
    }

    /**
     * 显示输入区
     */
    private void showInputArea() {
        int inputAreaHeight = 0;
        if (mInputAreaStatus == InputAreaStatus.KEYBOARD) {
            //输入区, 使用键盘高度真实
            inputAreaHeight = mKeyBoardHeight;
        } else {
//            //因为黑霉手机有物理键盘,当虚拟键盘很小时,mKeyBoardHeight只有100+PX,表情区会显示不全,使用最小高度.
            inputAreaHeight = mKeyBoardHeight < getResources().getDimensionPixelSize(R.dimen.min_keyboard_height) ? getResources().getDimensionPixelSize(R.dimen.min_keyboard_height) : mKeyBoardHeight;
        }

        //消息区大小
        setMsgAreaMinHeight();

        //输入区大小
        ViewGroup.LayoutParams layoutParams = fl_inputArea.getLayoutParams();
        if (layoutParams.height < 1) {
            layoutParams.height = inputAreaHeight;
            fl_inputArea.setLayoutParams(layoutParams);
        }

    }

    /**
     * 隐藏输入区
     */
    private void hideInputArea(){
        if(mInputAreaStatus == InputAreaStatus.HIDE) return;

        mInputAreaStatus = InputAreaStatus.HIDE;
//        Log.i("Jagger", "hideInputArea---");

        hideSoftInput(et_liveMsg, true);

        //输入区大小
        ViewGroup.LayoutParams layoutParams = fl_inputArea.getLayoutParams();
        if (layoutParams.height > 0) {
            layoutParams.height = 0;
            fl_inputArea.setLayoutParams(layoutParams);
        }

        //消息区大小
        setMsgAreaMaxHeight();
    }

    @Override
    public void OnSoftPop(int height) {
        if (mKeyBoardHeight != height) {
            mKeyBoardHeight = height;
            KeyBoardManager.saveKeyboardHeight(mContext, height);
        }
        lrsv_roomBody.setScrollFuncEnable(false);
        iv_gift.setVisibility(View.GONE);

//        if(mRoomType == RoomType.Private){
//            //add by Jagger
//            doMovePullViewUnderEditView();
//        }
    }

    @Override
    public void OnSoftClose() {
        //点击输入法收起按钮
        if(mInputAreaStatus == InputAreaStatus.KEYBOARD){
            hideInputArea();
        }
        lrsv_roomBody.setScrollFuncEnable(true);

//        if(lv_audienceList.getVisibility() == View.VISIBLE){
//            lv_audienceList.setVisibility(View.GONE);
//            iv_audienceIndicator.setSelected(true);
//        }
        hideAudienceList();
        iv_gift.setVisibility(View.VISIBLE);

//        if(mRoomType == RoomType.Private){
//            //add by Jagger
//            doReMovePullView();
//        }
    }

    // ---------- keyboard FS end ---------
}
