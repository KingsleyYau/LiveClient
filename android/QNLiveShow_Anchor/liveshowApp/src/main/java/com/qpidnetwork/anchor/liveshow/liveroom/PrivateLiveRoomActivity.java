package com.qpidnetwork.anchor.liveshow.liveroom;


import android.annotation.SuppressLint;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.graphics.Rect;
import android.graphics.drawable.AnimationDrawable;
import android.graphics.drawable.Drawable;
import android.opengl.GLSurfaceView;
import android.os.Bundle;
import android.os.Message;
import android.support.v4.app.FragmentManager;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.SurfaceHolder;
import android.view.View;
import android.view.WindowManager;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.httprequest.LiveRequestOperator;
import com.qpidnetwork.anchor.httprequest.OnRequestCallback;
import com.qpidnetwork.anchor.httprequest.item.HttpLccErrType;
import com.qpidnetwork.anchor.httprequest.item.IntToEnumUtils;
import com.qpidnetwork.anchor.httprequest.item.LiveRoomType;
import com.qpidnetwork.anchor.httprequest.item.TalentReplyType;
import com.qpidnetwork.anchor.im.listener.IMClientListener;
import com.qpidnetwork.anchor.im.listener.IMHangoutRecommendItem;
import com.qpidnetwork.anchor.im.listener.IMMessageItem;
import com.qpidnetwork.anchor.im.listener.IMRoomInItem;
import com.qpidnetwork.anchor.im.listener.IMSysNoticeMessageContent;
import com.qpidnetwork.anchor.liveshow.liveroom.car.CarInfo;
import com.qpidnetwork.anchor.liveshow.liveroom.recommend.RecommendDialogFragment;
import com.qpidnetwork.anchor.utils.DisplayUtil;
import com.qpidnetwork.anchor.utils.Log;
import com.qpidnetwork.anchor.view.Dialogs.DialogNormal;
import com.qpidnetwork.anchor.view.LiveRoomScrollView;
import com.qpidnetwork.anchor.view.SoftKeyboradListenFrameLayout;
import com.qpidnetwork.anchor.view.listener.ViewDragTouchListener;
import com.qpidnetwork.qnbridgemodule.sysPermissions.manager.PermissionManager;

import java.util.ArrayList;
import java.util.List;


/**
 * 私密直播间
 * Created by Harry Wei on 2017/6/15.
 */

public class PrivateLiveRoomActivity extends BaseAnchorLiveRoomActivity{

    //整个view的父，用于解决软键盘等监听
    private SoftKeyboradListenFrameLayout flContentBody;
    private LiveRoomScrollView lrsv_roomBody;
    private View imBody;
    private View include_audience_area;

    //视频推拉流
    private View rl_media;
    public GLSurfaceView sv_push;
    private ImageView iv_vedioBg;
    private ImageView iv_vedioLoading;
    //视频操作区域
    private View fl_vedioOpear;
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
    private LinearLayout ll_entranceCar;
    //弹幕
    private View ll_bulletScreen;
    //大礼物
    private SimpleDraweeView advanceGift;

    //---------------------消息编辑区域--------------------------------------
    private EditText et_liveMsg;
    protected ImageView iv_emojiSwitch;
    private static int liveMsgMaxLength = 10;
    private int lastTxtChangedStart = 0;
    private int lastTxtChangedNumb = 0;
    //--------------------男士互动视频--------------------
    private SimpleDraweeView iv_gaussianBlur;
    private View includePull;
    private GLSurfaceView sv_pull;
    private View view_gaussian_blur_me;
    private View v_gaussianBlurFloat;
    private boolean isStreamPulling = false;       //是否正在视频互动中
    private String[] lastManPullUrls = new String[]{};
    private LiveStreamPullManager mLiveStreamPullManager; //推流管理器

    private int mIPublishTempTop = -1;
    private boolean mIsMovePullViewUnderEditView = false;

    private ImageView iv_gift;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        TAG = PrivateLiveRoomActivity.class.getSimpleName();
        super.onCreate(savedInstanceState);
        //直播中保持屏幕点亮不熄屏
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON,
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

        setContentView(R.layout.activity_live_room_private);
        initData();
        initViews();
        initVedioPlayerStatus();
    }

    private void initViews(){
        Log.d(TAG,"initViews");
        //解决软键盘关闭的监听问题
        flContentBody = (SoftKeyboradListenFrameLayout)findViewById(R.id.flContentBody);
        flContentBody.setInputWindowListener(this);
        lrsv_roomBody = (LiveRoomScrollView) findViewById(R.id.lrsv_roomBody);
        initRoomViewDataAndStyle();
        initRoomVedioHeader();
        initAnchorVideoPusher();
        imBody = findViewById(R.id.include_im_body);
        include_audience_area = findViewById(R.id.include_audience_area);
        include_audience_area.setOnClickListener(this);
        initLiveRoomCar();
        initMultiGift();
        initMessageList();
        initBarrage();
        initEditAreaView();
        //互动模块初始化
        initPublishView();
        setSizeUnChanageViewParams();
    }

    /**
     * 初始化头部视频操作区域
     */
    private void initRoomVedioHeader(){
        fl_vedioOpear = findViewById(R.id.fl_vedioOpear);
        iv_close = (ImageView) findViewById(R.id.iv_close);
        iv_close.setOnClickListener(this);
        //add by Jagger 2018-10
        if(null != mIMRoomInItem && mIMRoomInItem.liveShowType == IMRoomInItem.IMPublicRoomType.Program){
            iv_close.setVisibility(View.GONE);
        }
        iv_switchCamera = (ImageView) findViewById(R.id.iv_switchCamera);
        iv_switchCamera.setOnClickListener(this);
        iv_switchCamera.setVisibility(View.VISIBLE);
        fl_vedioOpear.setVisibility(View.GONE);

        fl_vedioTips = findViewById(R.id.fl_vedioTips);
        fl_vedioTips.setVisibility(View.GONE);
        tv_vedioTip0 = (TextView) findViewById(R.id.tv_vedioTip0);
        tv_vedioTip1 = (TextView) findViewById(R.id.tv_vedioTip1);
        tv_vedioTip2 = (TextView) findViewById(R.id.tv_vedioTip2);
        tv_vedioTip3 = (TextView) findViewById(R.id.tv_vedioTip3);
        tv_vedioTip4 = (TextView) findViewById(R.id.tv_vedioTip4);
        iv_vedioTips = (ImageView) findViewById(R.id.iv_vedioTips);
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
        if(mLiveStreamPushManager != null) {
            mLiveStreamPushManager.init(sv_push);
        }
        iv_vedioLoading = (ImageView) findViewById(R.id.iv_vedioLoading);
        iv_vedioLoading.setVisibility(View.GONE);
        iv_vedioLoading.setOnClickListener(this);

        int screenWidth = DisplayUtil.getScreenWidth(this);
        int scaleHeight= screenWidth/**3/4*/;
        //具体的宽高比例，其实也可以根据服务器动态返回来控制
        RelativeLayout.LayoutParams svPlayerLp = (RelativeLayout.LayoutParams) sv_push.getLayoutParams();
        RelativeLayout.LayoutParams ivVedioBgLp = (RelativeLayout.LayoutParams)iv_vedioBg.getLayoutParams();
        LinearLayout.LayoutParams rlMediaLp = (LinearLayout.LayoutParams)rl_media.getLayoutParams();
        svPlayerLp.height = scaleHeight;
        rlMediaLp.height = scaleHeight;
        ivVedioBgLp.height = scaleHeight;
        sv_push.setLayoutParams(svPlayerLp);
        rl_media.setLayoutParams(rlMediaLp);
        iv_vedioBg.setLayoutParams(ivVedioBgLp);

        initVedioLoadingAnimManager(iv_vedioLoading);
    }

    /**
     * 初始化座驾入场动画
     */
    private void initLiveRoomCar(){
        ll_entranceCar = (LinearLayout) findViewById(R.id.ll_entranceCar);
        ll_entranceCar.setOnClickListener(this);
        super.initLiveRoomCar(ll_entranceCar);
    }

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
                    if (isSoftInputOpen) {
                        hideSoftInput(et_liveMsg, true);
                    }
                }
            });
        }
        //incliude view id 必须通过setOnClickListener方式设置onclick监听,
        // xml中include标签下没有onclick和clickable属性
        findViewById(R.id.fl_imMsgContainer).setOnClickListener(this);
    }

    /**
     * 弹幕初始化
     */
    private void initBarrage(){
        List<View> mViews = new ArrayList<View>();
        mViews.add(findViewById(R.id.rl_bullet1));
        initBarrage(mViews,ll_bulletScreen);
    }

    //******************************** 弹幕消息编辑区域处理 ********************************************
    /**
     * 处理编辑框区域view初始化
     */
    @SuppressWarnings("WrongConstant")
    private void initEditAreaView(){
        liveMsgMaxLength = getResources().getInteger(R.integer.liveMsgMaxLength);
        //共用的软键盘弹起输入部分
        et_liveMsg = (EditText)findViewById(R.id.et_liveMsg);
        et_liveMsg.addTextChangedListener(tw_msgEt);
        et_liveMsg.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                Log.d(TAG,"onEditorAction-s:"+v.getText());
                //清空消息
                if(enterKey2SendMsg(et_liveMsg.getText().toString(),"0",null)){
                    //清空消息
                    et_liveMsg.setText("");
                }
                return true;
            }
        });
        iv_emojiSwitch = (ImageView)findViewById(R.id.iv_emojiSwitch);
        //底部输入+礼物btn
        iv_gift = (ImageView) findViewById(R.id.iv_gift);
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
                int outStart = 0;
                et_liveMsg.removeTextChangedListener(tw_msgEt);
                int outNumb = s.toString().length() -liveMsgMaxLength;
                outStart = lastTxtChangedStart+lastTxtChangedNumb-outNumb;
                s.delete(outStart,lastTxtChangedStart+lastTxtChangedNumb);
                Log.logD(TAG,"afterTextChanged-outNumb:"+outNumb+" outStart:"+outStart+" s:"+s);
                et_liveMsg.setText(s.toString());
                et_liveMsg.setSelection(outStart);
                et_liveMsg.addTextChangedListener(tw_msgEt);
            }
        }
    };

    @Override
    public void onClick(View v) {
        super.onClick(v);
        switch (v.getId()){
            case R.id.include_audience_area:
            case R.id.rl_media:
            case R.id.flMultiGift:
            case R.id.iv_vedioLoading:
            case R.id.ll_entranceCar:
                if (isSoftInputOpen) {
                    hideSoftInput(et_liveMsg, true);
                }else{
                    boolean hasOpearViewShow = fl_vedioOpear.getVisibility() == View.VISIBLE;
                    fl_vedioOpear.setVisibility(hasOpearViewShow ? View.GONE : View.VISIBLE);
                }
                break;
            case R.id.iv_switchCamera:
                switchCamera();
                fl_vedioOpear.setVisibility(View.GONE);
                break;
            case R.id.iv_close:
                if(!hasRoomInClosingStatus){
                    lastSwitchLiveRoomId = null;
                    lastSwitchUserBaseInfoItem = null;
                    lastSwitchLiveRoomType = LiveRoomType.Unknown;
                    userCloseRoom();
                }
                fl_vedioOpear.setVisibility(View.GONE);
                break;
            case R.id.fl_imMsgContainer:
            case R.id.ll_bulletScreen:
            case R.id.fl_msglist:
                if (isSoftInputOpen) {
                    hideSoftInput(et_liveMsg, true);
                }
                break;
            case R.id.fl_vedioOpear:
                if (isSoftInputOpen) {
                    hideSoftInput(et_liveMsg, true);
                }
                break;
            case R.id.iv_gift:
                showLiveGiftDialog();
                break;
            case R.id.iv_recommend:
                showRecommendDialog();
                break;
        }
    }

    /**
     * 调整view高度, 解决背景在AdjustSize时会被推上去问题
     */
    @SuppressLint("WrongViewCast")
    private void setSizeUnChanageViewParams(){
        Log.d(TAG,"setSizeUnChanageViewParams");
        int statusBarHeight = DisplayUtil.getStatusBarHeight(mContext);
        if(statusBarHeight > 0){
            int activityHeight = DisplayUtil.getScreenHeight(mContext) - statusBarHeight;
            Log.d(TAG,"setSizeUnChanageViewParams-statusBarHeight:"+statusBarHeight+" activityHeight:"+activityHeight);
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

    //--------------------------------视频互动----------------------------------
    /**
     * 初始化视频互动界面
     */
    private void initPublishView(){
        Log.d(TAG,"initPublishView");
        mLiveStreamPullManager = new LiveStreamPullManager(this);
        //视频上传预览
        includePull = findViewById(R.id.includePull);
        sv_pull = (GLSurfaceView)findViewById(R.id.sv_pull);
        //初始化必须在界面显示前调用，否则会出现由于未设置render导致 oncreate空指针异常
        mLiveStreamPullManager.init(sv_pull);
        //add by Jagger 2017-11-29 解决小窗口能浮在大窗口上的问题
        sv_pull.setZOrderOnTop(true);
        sv_pull.setZOrderMediaOverlay(true);
        sv_pull.getHolder().setFormat(PixelFormat.TRANSPARENT);
        sv_pull.getHolder().setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);

        ViewDragTouchListener listener = new ViewDragTouchListener(100l);
        listener.setOnViewDragListener(new ViewDragTouchListener.OnViewDragStatusChangedListener() {
            @Override
            public void onViewDragged(int l, int t, int r, int b) {
                //避免父布局重绘后includePublish回到原来的位置
                FrameLayout.LayoutParams flIPublish = (FrameLayout.LayoutParams) includePull.getLayoutParams();
                flIPublish.gravity = Gravity.TOP|Gravity.LEFT;
                flIPublish.leftMargin = includePull.getLeft();
                flIPublish.topMargin = includePull.getTop();
                includePull.setLayoutParams(flIPublish);
            }
        });
        includePull.setOnTouchListener(listener);
        //高斯模糊头像部分
        view_gaussian_blur_me = findViewById(R.id.view_gaussian_blur_me);
        v_gaussianBlurFloat = findViewById(R.id.v_gaussianBlurFloat);
        iv_gaussianBlur = (SimpleDraweeView)findViewById(R.id.iv_gaussianBlur);
        includePull.setVisibility(View.VISIBLE);
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
    private void doMovePullViewUnderEditView(){
        Log.d(TAG,"doMovePullViewUnderEditView");
        //应用程序App区域宽高等尺寸获取
        Rect rect = new Rect();
        getWindow().getDecorView().getWindowVisibleDisplayFrame(rect);
        int edBottomY = rect.height() - 1;

        FrameLayout.LayoutParams flIPublish = (FrameLayout.LayoutParams) includePull.getLayoutParams();
        //移动
        if(flIPublish.topMargin > edBottomY){
            //记录移动前的TOP
            mIPublishTempTop = flIPublish.topMargin;
            //
            flIPublish.topMargin = edBottomY;
            includePull.setLayoutParams(flIPublish);
            //
            mIsMovePullViewUnderEditView = true;
        }
    }

    /**
     * add by Jagger 2017-12-6
     * 还原浮动的视频窗体位置,对应doMovePublishViewUnderEditView()
     */
    private void doReMovePullView(){
        Log.d(TAG,"doReMovePullView");
        if(mIsMovePullViewUnderEditView && mIPublishTempTop != -1){
            FrameLayout.LayoutParams flIPublish = (FrameLayout.LayoutParams) includePull.getLayoutParams();
            flIPublish.topMargin = mIPublishTempTop;
            includePull.setLayoutParams(flIPublish);
            mIsMovePullViewUnderEditView = false;
        }
    }

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
    protected void onDisconnectRoomIn() {
        super.onDisconnectRoomIn();
        //私密直播间 断线重连 重置男士互动视频模块 推流地址
        if(isStreamPulling && null != lastManPullUrls && lastManPullUrls.length>0 && mLiveStreamPullManager != null){
            mLiveStreamPullManager.setOrChangeVideoUrls(lastManPullUrls, "", "",null);
        }else{
            mLiveStreamPullManager.stopPlayInternal();
        }
    }

    @Override
    public void onManVedioPushStatusChanged(String roomId, String userId, String nickname, String avatarImg,
                                            IMClientListener.IMVideoInteractiveOperateType operateType,
                                            String[] pushUrls) {
        super.onManVedioPushStatusChanged(roomId, userId, nickname, avatarImg, operateType, pushUrls);
        isStreamPulling = operateType == IMClientListener.IMVideoInteractiveOperateType.Start;
        view_gaussian_blur_me.setVisibility(isStreamPulling ? View.GONE : View.VISIBLE);
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
        //清除定时器
        removeUiMessages(EVENT_TALENT_OVER_TIME_CLOSE);
        //add by Jagger 2017-12-1
        destroyPullManager();
        //add by Jagger 2018-6-20
        if(null != liveRoomChatManager){
            liveRoomChatManager.destroy();
        }
    }


    @Override
    public void onSoftKeyboardShow() {
        Log.d(TAG, "onSoftKeyboardShow");
        super.onSoftKeyboardShow();
        //add by Jagger
        doMovePullViewUnderEditView();
        iv_gift.setVisibility(View.GONE);
        lrsv_roomBody.setScrollFuncEnable(false);
    }

    @Override
    public void onSoftKeyboardHide() {
        super.onSoftKeyboardHide();
        //add by Jagger
        doReMovePullView();
        lrsv_roomBody.setScrollFuncEnable(true);
        iv_gift.setVisibility(View.VISIBLE);
    }

    @Override
    public void onRecvLeavingRoomNotice(int leftSeconds) {
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
        tv_vedioTip3.setText(String.valueOf(leftSeconds));
        tv_vedioTip4.setVisibility(View.VISIBLE);
        tv_vedioTip4.setText(getResources().getString(R.string.liveroom_leaving_room_time_count_s));
        super.onRecvLeavingRoomNotice(leftSeconds);
    }

    @Override
    public void updateRoomCloseTimeCount(int timeCount) {
        super.updateRoomCloseTimeCount(timeCount);
        tv_vedioTip3.setText(String.valueOf(timeCount));
    }

    /***************************************** Talent相关 **************************************/

    private DialogNormal mTalentDialog;
    private static final int TALENT_REQUEST_VALID_DURATION = 60 * 1000;     //弹出才艺点播后，1分钟后自动关闭dialog

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        switch (msg.what){
            case EVENT_TALENT_OVER_TIME_CLOSE:{
                if(mTalentDialog != null){
                    mTalentDialog.dismiss();
                }
            }break;
        }
    }

    @Override
    protected void playEnterCarAnim(CarInfo carInfo) {

    }

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

    @Override
    protected void preEndLiveRoom(String description) {
        super.preEndLiveRoom(description);
        //私密直播间结束页面传男士头像地址
        LiveRoomEndActivity.show(this, manPhotoUrl, description);
    }

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
}
