package com.qpidnetwork.anchor.liveshow.liveroom;


import android.annotation.SuppressLint;
import android.graphics.drawable.AnimationDrawable;
import android.graphics.drawable.Drawable;
import android.opengl.GLSurfaceView;
import android.os.Bundle;
import android.os.Message;
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
import android.view.WindowManager;
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
import com.qpidnetwork.anchor.httprequest.item.LiveRoomType;
import com.qpidnetwork.anchor.im.listener.IMClientListener;
import com.qpidnetwork.anchor.im.listener.IMMessageItem;
import com.qpidnetwork.anchor.im.listener.IMRoomInItem;
import com.qpidnetwork.anchor.im.listener.IMSysNoticeMessageContent;
import com.qpidnetwork.anchor.im.listener.IMUserBaseInfoItem;
import com.qpidnetwork.anchor.liveshow.liveroom.audience.AudienceInfoDialog;
import com.qpidnetwork.anchor.liveshow.liveroom.audience.AudienceSelectorAdapter;
import com.qpidnetwork.anchor.utils.DisplayUtil;
import com.qpidnetwork.anchor.utils.Log;
import com.qpidnetwork.anchor.utils.StringUtil;
import com.qpidnetwork.anchor.view.CircleImageHorizontScrollView;
import com.qpidnetwork.anchor.view.LiveRoomScrollView;
import com.qpidnetwork.anchor.view.SoftKeyboradListenFrameLayout;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;


/**
 * 免费公开直播间
 * Created by Hunter Mun on 2017/6/15.
 */

public class PublicLiveRoomActivity extends BaseAnchorLiveRoomActivity {

    //整个view的父，用于解决软键盘等监听
    private SoftKeyboradListenFrameLayout flContentBody;
    private LiveRoomScrollView lrsv_roomBody;
    private View imBody;
    private View include_audience_area;
    //观众列表
    private TextView tv_vipGuestData;
    private CircleImageHorizontScrollView cihsv_onlineVIPPublic;
    private View rl_vipPublic;

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
//    private EmojiTabScrollLayout etsl_emojiContainer;
    private EmotionItem chooseEmotionItem = null;
    private ImageView iv_emojiSwitch;

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

    private ImageView iv_gift;

    /**
     * 直播间关闭倒计时
     */
    private static final int EVENT_PRIVINVITE_RESP_TIMEOUT = 2001;
    private static final int EVENT_PRIVINVITE_RESP_TIPS_HINT= 2002;

    private String lastPrivateLiveInvitationId = null;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        TAG = PublicLiveRoomActivity.class.getSimpleName();
        //直播中保持屏幕点亮不熄屏
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON,
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        setContentView(R.layout.activity_live_room_public);
        initData();
        initViews();

        initVedioPlayerStatus();
        updatePublicRoomOnlineData();
        updatePublicOnLinePic(new AudienceInfoItem[]{});
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
        initOnLinePicView();
        initMessageList();
        initBarrage();
        initEditAreaView();
        initEditAreaViewStyle();
        //互动模块初始化
        setSizeUnChanageViewParams();

    }

    @Override
    public void initData() {
        super.initData();
        defaultAudienceInfoItem = new AudienceInfoItem("0","All","",null,null,0,"",false);
        lastSelectedAudienceInfoItem = defaultAudienceInfoItem;
        currAudienceInfoItems = new ArrayList<>();
        currAudienceInfoItems.add(lastSelectedAudienceInfoItem);
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
        changeRoomTimeCountEndStatus();
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
        ll_entranceCar.setClickable(true);
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
        mModuleGiftManager.initMultiGift(viewContent);
        ll_bulletScreen = findViewById(R.id.ll_bulletScreen);
        ll_bulletScreen.setOnClickListener(this);
        mModuleGiftManager.showMultiGiftAs(ll_bulletScreen);
        //大礼物
        advanceGift = (SimpleDraweeView)findViewById(R.id.advanceGift);
        mModuleGiftManager.initAdvanceGift(advanceGift);
    }

    /**
     * 初始化在线头像列表
     */
    private void initOnLinePicView(){
        audienceInfoDialog = new AudienceInfoDialog(this);
        cihsv_onlineVIPPublic = (CircleImageHorizontScrollView) findViewById(R.id.cihsv_onlineVIPPublic);
        cihsv_onlineVIPPublic.setCircleImageClickListener(new CircleImageHorizontScrollView.OnCircleImageClickListener() {
            @Override
            public void onCircleImageClicked(CircleImageHorizontScrollView.CircleImageObj obj) {
                AudienceInfoItem item = (AudienceInfoItem) obj.obj;
                if(!item.userId.equals(defaultAudienceInfoItem.userId)){
                    audienceInfoDialog.show(item);
                    //add by Jagger 2018-5-9
                    //节目隐藏ONE-ON-ONE
                    if(mIMRoomInItem.liveShowType == IMRoomInItem.IMPublicRoomType.Program){
                        audienceInfoDialog.setInvitePriLiveBtnVisible(View.INVISIBLE);
                    }
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
        rl_vipPublic = findViewById(R.id.rl_vipPublic);
    }

    /**
     * 初始化消息展示列表
     */
    private void initMessageList(){
        if(loginItem != null) {
            liveRoomChatManager = new LiveRoomChatManager(this, mIMRoomInItem.roomType,
                    mIMRoomInItem.anchorId, roomThemeManager);
            View fl_msglist = findViewById(R.id.fl_msglist);
            fl_msglist.setClickable(true);
            liveRoomChatManager.init(this, fl_msglist);
            fl_msglist.setOnClickListener(this);
            liveRoomChatManager.setOnRoomMsgListClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    Log.d(TAG, "OnRoomMsgListClickListener-isSoftInputOpen:" + isSoftInputOpen);
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

                //清空消息
                if(enterKey2SendMsg(et_liveMsg.getText().toString(),
                        lastSelectedAudienceInfoItem.userId,
                        lastSelectedAudienceInfoItem.nickName)){
                    //清空消息
                    et_liveMsg.setText("");
                }

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
        iv_emojiSwitch = (ImageView)findViewById(R.id.iv_emojiSwitch);
        iv_emojiSwitch.setImageDrawable(getResources().getDrawable(R.drawable.ic_liveroom_emojiswitch));
        //底部输入+礼物btn
        iv_gift = (ImageView) findViewById(R.id.iv_gift);
        if(null != mIMRoomInItem){
            iv_emojiSwitch.setVisibility(roomThemeManager.getRoomInputEmojiSwitchVisiable(this,mIMRoomInItem.roomType));
        }

        ll_audienceChooser = findViewById(R.id.ll_audienceChooser);
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
        if(null != mIMRoomInItem && mIMRoomInItem.roomType == IMRoomInItem.IMLiveRoomType.FreePublicRoom){
            iv_emojiSwitch.setVisibility(View.GONE);
        }
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);
        switch (v.getId()){
            case R.id.rl_media:
            case R.id.include_audience_area:
            case R.id.flMultiGift:
            case R.id.iv_vedioLoading:
            case R.id.ll_entranceCar:
            case R.id.fl_vedioOpear:
                if (isSoftInputOpen) {
                    hideSoftInput(et_liveMsg, true);
                }else if(View.VISIBLE == lv_audienceList.getVisibility()){
                    lv_audienceList.setVisibility(View.GONE);
                    iv_audienceIndicator.setSelected(true);
                }else {
                    boolean hasOpearViewShow = fl_vedioOpear.getVisibility() == View.VISIBLE;
                    fl_vedioOpear.setVisibility(hasOpearViewShow ? View.GONE : View.VISIBLE);
                }
                break;
            case R.id.iv_switchCamera:
                if (isSoftInputOpen) {
                    hideSoftInput(et_liveMsg, true);
                }else if(View.VISIBLE == lv_audienceList.getVisibility()){
                    lv_audienceList.setVisibility(View.GONE);
                    iv_audienceIndicator.setSelected(true);
                }else {
                    switchCamera();
                    fl_vedioOpear.setVisibility(View.GONE);
                }
                break;
            case R.id.iv_close:
                if (isSoftInputOpen) {
                    hideSoftInput(et_liveMsg, true);
                }else if(View.VISIBLE == lv_audienceList.getVisibility()){
                    lv_audienceList.setVisibility(View.GONE);
                    iv_audienceIndicator.setSelected(true);
                }else {
                    if(!hasRoomInClosingStatus){
                        lastSwitchLiveRoomId = null;
                        lastSwitchLiveRoomType = LiveRoomType.Unknown;
                        lastSwitchUserBaseInfoItem = null;
                        userCloseRoom();
                    }
                    fl_vedioOpear.setVisibility(View.GONE);
                }
                break;
            case R.id.ll_audienceChooser:
            case R.id.tv_audienceNickname:
            case R.id.iv_audienceIndicator:
                //切换观众昵称列表的选择状态
                boolean hasAudienceListShowed = View.VISIBLE == lv_audienceList.getVisibility();
                lv_audienceList.setVisibility(hasAudienceListShowed ? View.GONE : View.VISIBLE);
                iv_audienceIndicator.setSelected(hasAudienceListShowed);
                break;
            case R.id.fl_imMsgContainer:
            case R.id.ll_bulletScreen:
            case R.id.fl_msglist:
                if (isSoftInputOpen) {
                    hideSoftInput(et_liveMsg, true);
                }else if(View.VISIBLE == lv_audienceList.getVisibility()){
                    lv_audienceList.setVisibility(View.GONE);
                    iv_audienceIndicator.setSelected(true);
                }
                break;
            case R.id.iv_gift:
                if(View.VISIBLE == lv_audienceList.getVisibility()){
                    lv_audienceList.setVisibility(View.GONE);
                    iv_audienceIndicator.setSelected(true);
                }else{
                    showLiveGiftDialog();
                }
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
        super.onSoftKeyboardShow();
        lrsv_roomBody.setScrollFuncEnable(false);
        iv_gift.setVisibility(View.GONE);
    }

    @Override
    public void onSoftKeyboardHide() {
        super.onSoftKeyboardHide();
        lrsv_roomBody.setScrollFuncEnable(true);
        if(lv_audienceList.getVisibility() == View.VISIBLE){
            lv_audienceList.setVisibility(View.GONE);
            iv_audienceIndicator.setSelected(true);
        }
        iv_gift.setVisibility(View.VISIBLE);
    }

    @Override
    protected void onDisconnectRoomIn() {
        super.onDisconnectRoomIn();
        //公开直播间 断线重连 查询直播间在线头像列表数据
        updatePublicRoomOnlineData();
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

    @Override
    public void onRecvLeavingRoomNotice() {
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
        tv_vedioTip3.setText(String.valueOf(leavingRoomTimeCount));
        tv_vedioTip4.setVisibility(View.VISIBLE);
        tv_vedioTip4.setText(getResources().getString(R.string.liveroom_leaving_room_time_count_s));
        super.onRecvLeavingRoomNotice();
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
                                             IMClientListener.LCC_ERR_TYPE errType, final String errMsg,
                                             String invitationId, int timeout, final String roomId) {
        super.OnSendImmediatePrivateInvite(reqId, success, errType, errMsg, invitationId, timeout, roomId);
        //成功则 1.显示私密邀请发送提示动画;2.增加超时定时器，处理邀请超时逻辑；失败则toast提示
        if(success){
            //9.1.主播发送立即私密邀请 可作为 男士私密邀请的应邀处理（服务器处理）,因此需要判断下roomId是否有值返回，有则直接调用roomOut，
            // 并记录lastSwitchUserBaseInfoItem和lastSwitchLiveRoomId
            if(!TextUtils.isEmpty(roomId)){
                lastSwitchUserBaseInfoItem = new IMUserBaseInfoItem(lastInviteManUserId,lastInviteManNickname,lastInviteManPhotoUrl);
                lastSwitchLiveRoomId = roomId;
                privateLiveInvitedByAnchor = true;
                lastSwitchLiveRoomType = LiveRoomType.AdvancedPrivateRoom;
            }else{
                sendEmptyUiMessageDelayed(EVENT_PRIVINVITE_RESP_TIMEOUT,timeout*1000l);
            }
            lastInviteSendSucManNickName = lastInviteManNickname;
            lastPrivateLiveInvitationId = invitationId;
        }
        lastInviteManNickname = null;
        lastInviteManPhotoUrl = null;
        lastInviteManUserId = null;
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if(success){
                    removeUiMessages(EVENT_PRIVINVITE_RESP_TIPS_HINT);
                    if(!TextUtils.isEmpty(roomId)){
                        switchLiveRoom();
                    }else{
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
        //add by Jagger 2018-6-20
        if(null != liveRoomChatManager){
            liveRoomChatManager.destroy();
        }
    }

    @Override
    protected void preEndLiveRoom(String description) {
        super.preEndLiveRoom(description);
        //公开直播间传自己头像
        if(null != mIMRoomInItem){
            if(null != loginItem && !TextUtils.isEmpty(loginItem.photoUrl)){
                LiveRoomEndActivity.show(this,loginItem.photoUrl, description);
            }
        }
    }
}
