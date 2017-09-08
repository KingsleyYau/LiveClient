package com.qpidnetwork.livemodule.liveshow.liveroom;

import android.graphics.Color;
import android.os.Bundle;
import android.os.Message;
import android.support.annotation.Nullable;
import android.support.v4.view.ViewCompat;
import android.text.Editable;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.text.style.AbsoluteSizeSpan;
import android.text.style.ForegroundColorSpan;
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
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.im.listener.IMClientListener;
import com.qpidnetwork.livemodule.im.listener.IMMessageItem;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.barrage.BarrageManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.barrage.IBarrageViewFiller;
import com.qpidnetwork.livemodule.liveshow.liveroom.car.CarInfo;
import com.qpidnetwork.livemodule.liveshow.liveroom.car.CarManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.GiftSendReqManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.ModuleGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.tariffprompt.TariffPromptManager;
import com.qpidnetwork.livemodule.liveshow.personal.chatemoji.ChatEmoji;
import com.qpidnetwork.livemodule.liveshow.personal.chatemoji.ChatEmojiManager;
import com.qpidnetwork.livemodule.liveshow.personal.chatemoji.EmojiTabScrollLayout;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.Log;
import com.qpidnetwork.livemodule.utils.TestDataUtil;
import com.qpidnetwork.livemodule.view.CircleImageHorizontScrollView;
import com.qpidnetwork.livemodule.view.LiveRoomHeaderBezierView;
import com.qpidnetwork.livemodule.view.SoftKeyboradListenFrameLayout;
import com.squareup.picasso.Picasso;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

/**
 * 直播间公共处理界面类
 * Created by Hunter Mun on 2017/6/16.
 */

public class BaseCommonLiveRoomActivity extends BaseImplLiveRoomActivity{

    protected final String TAG = BaseCommonLiveRoomActivity.class.getName();
    /**
     * 房间ID
     */
    public static final String LIVEROOM_ROOM_ID = "liveRoomId";
    /**
     * 主播ID
     */
    public static final String LIVEROOM_HOST_ID="liveRoomHostId";

    private final int EVENT_MESSAGE_UPDATE = 1001;
    private final int EVENT_MESSAGE_HIDE_TARIFFPROMPT = 1004;

    //整个view的父，用于解决软键盘等监听
    private SoftKeyboradListenFrameLayout flContentBody;

    //顶部主播个人信息模块
    protected View view_roomHeader;
    private View ll_liveRoomHeader;
    private ImageView iv_roomHeaderBg;
    protected CircleImageHorizontScrollView cihsv_online;
    private ImageView iv_follow;
    private LiveRoomHeaderBezierView lrhbv_flag;
    //资费提示
    private View view_tariff_prompt;
    private ImageView iv_roomFlag;
    private Button btn_OK;
    private TextView tv_triffMsg;
    protected TariffPromptManager tpManager;
    //返点
    private TextView tv_creditTips;

    //消息编辑区域
    private View rl_inputMsg;
    private LinearLayout ll_input_edit_body;
    private ImageView iv_msgType;
    private EditText et_liveMsg;
    private Button btn_sendMsg;
    private EmojiTabScrollLayout etsl_emojiContainer;
    private ChatEmoji choosedChatEmoji = null;
    public boolean isEmojiOpera = false;//标识表情列表状态切换

    //聊天展示区域
    private LiveRoomChatManager liveRoomChatManager;

    //弹幕
    private boolean isBarrage = false;
    private View ll_bulletScreen;

    //礼物模块
    protected ModuleGiftManager mModuleGiftManager;
    //大礼物
    private SimpleDraweeView advanceGift;

    //数据及管理
    protected String mRoomId;
    protected String hostId;

    //视频播放
    protected ImageView iv_vedioBg;
    public SurfaceView sv_player;
    private View rl_media;
    private View imBody;

    //座驾
    protected LinearLayout ll_entranceCar;


    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_live_room);
//        initData();
        initViews();
    }

    /**
     * 数据初始化
     */
    private void initData(){
        Bundle bundle = getIntent().getExtras();
        if(bundle != null){
            if(bundle.containsKey(LIVEROOM_ROOM_ID)){
                mRoomId = bundle.getString(LIVEROOM_ROOM_ID);
            }
            if(bundle.containsKey(LIVEROOM_HOST_ID)){
                hostId = bundle.getString(LIVEROOM_HOST_ID);
            }
        }
        if(TextUtils.isEmpty(mRoomId)){
            Log.e(TAG, "roomId cannot null");
            finish();
        }
    }

    private void initViews(){
        Log.d(TAG,"initViews");
        //解决软键盘关闭的监听问题
        flContentBody = (SoftKeyboradListenFrameLayout)findViewById(R.id.flContentBody);
        flContentBody.setInputWindowListener(this);
        initRoomHeader();
        imBody = findViewById(R.id.include_im_body);
        initVedioPlayer();
        initLiveRoomCar();
        initMultiGift();
        initMessageList();
        initBarrage();
        initEditAreaView();
        setSizeUnChanageViewParams();
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
            case R.id.ll_input_edit_body:{
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
            default:
                break;
        }
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        switch(msg.what){
            case EVENT_MESSAGE_HIDE_TARIFFPROMPT:
                if(view_tariff_prompt.getVisibility() == View.VISIBLE){
                    showRoomTariffPrompt(null,false,null);
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
            default:
                break;
        }
    }

    /**
     * 消息切换主线程
     * @param msgItem
     */
    public void sendMessageUpdateEvent(IMMessageItem msgItem){
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
    }

    //******************************** 顶部房间信息模块 ****************************************************************

    @Override
    public void onGetRoomTariffInfo(final String tariffPrompt,final boolean isNeedUserConfirm,final String regex) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if(isNeedUserConfirm || isUserWantSeeTariffPrompt){
                    showRoomTariffPrompt(tariffPrompt,isNeedUserConfirm,regex);
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
        ll_liveRoomHeader.measure(0,0);
        //TODO:头部可以公用一个xml，抽取一个方法来设置image src和image height
        FrameLayout.LayoutParams lp1 = (FrameLayout.LayoutParams)iv_roomHeaderBg.getLayoutParams();
        lp1.height = ll_liveRoomHeader.getMeasuredHeight();
        iv_roomHeaderBg.setLayoutParams(lp1);
        cihsv_online = (CircleImageHorizontScrollView) findViewById(R.id.cihsv_online);
        iv_follow = (ImageView) findViewById(R.id.iv_follow);
        iv_follow.setOnClickListener(this);
        lrhbv_flag = (LiveRoomHeaderBezierView) findViewById(R.id.lrhbv_flag);
        findViewById(R.id.tv_hostName).setOnClickListener(this);
        iv_roomFlag = (ImageView) findViewById(R.id.iv_roomFlag);
        iv_roomFlag.measure(0,0);
        RelativeLayout.LayoutParams roomFlagLp = (RelativeLayout.LayoutParams) iv_roomFlag.getLayoutParams();
        view_tariff_prompt = findViewById(R.id.view_tariff_prompt);
        FrameLayout.LayoutParams tpLp = (FrameLayout.LayoutParams) view_tariff_prompt.getLayoutParams();
        tpLp.topMargin = iv_roomFlag.getMeasuredHeight()+roomFlagLp.topMargin+tpLp.topMargin;
        tpLp.width = iv_roomFlag.getMeasuredWidth();
        view_tariff_prompt.setLayoutParams(tpLp);
        btn_OK = (Button) findViewById(R.id.btn_OK);
        btn_OK.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showRoomTariffPrompt(null,false,null);
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
    }

    protected void setLiveRoomHeaderRightFlagBgColor(int color){
        lrhbv_flag.setRoomHeaderBgColor(color);
    }

    protected void setLiveRoomBaseBgColor(int color){
        if(null != flContentBody){
            flContentBody.setBackgroundColor(color);
        }
    }

    protected void showRoomTariffPrompt(String tariffprompt, boolean isShowOkBtn, String regex){
        if(!TextUtils.isEmpty(tariffprompt)){
            SpannableString spannableString = new SpannableString(tariffprompt);
            int startIndex = tariffprompt.indexOf(regex);
            if(!TextUtils.isEmpty(regex) && startIndex>=0 && startIndex<tariffprompt.length()){
                spannableString.setSpan(new ForegroundColorSpan(Color.parseColor("#ffd205")),
                        startIndex, startIndex+regex.length(), Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
                spannableString.setSpan(new AbsoluteSizeSpan(DisplayUtil.dip2px(this,9f)),
                        0, startIndex, Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
                spannableString.setSpan(new AbsoluteSizeSpan(DisplayUtil.dip2px(this,10f)),
                        startIndex, startIndex+regex.length(), Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
                spannableString.setSpan(new AbsoluteSizeSpan(DisplayUtil.dip2px(this,9f)),
                        startIndex+regex.length(), tariffprompt.length(), Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
            }else{
                spannableString.setSpan(new AbsoluteSizeSpan(DisplayUtil.dip2px(this,9f)),
                        0, tariffprompt.length(), Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
            }
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
    protected void sendFollowHostReq(){}

    /**
     * 已经关注
     */
    protected void onRecvFollowHostResp(boolean isSuccess, String errMsg){
        if(isSuccess){
            showToast(getResources().getString(R.string.tip_focused));
            iv_follow.setVisibility(View.GONE);
            //TODO:DELETE
            TestDataUtil.changeViewVisityStatus(iv_follow,this,View.VISIBLE);
            //以下关注消息应由后台推送给客户端
            Random random = new Random();
            IMMessageItem imMessageItem = new IMMessageItem("0",random.nextInt(Integer.MAX_VALUE),
                    "1","Shana", random.nextInt(100), IMMessageItem.MessageType.FollowHost,
                    null,null);
            sendMessageUpdateEvent(imMessageItem);
        }else{
            showToast(errMsg);
        }
    }


    public void setOnLineList(List<String> datas){
        cihsv_online.setList(datas);
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
    public void OnRoomIn(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, final IMRoomInItem roomInfo) {
        Log.d(TAG,"OnRoomIn-reqId:"+reqId+" success:"+success+" errType:"+errType+" errMsg:"+roomInfo+" roomInfo:"+roomInfo);
        //1.进入直播间，判断是否首次进入，
        tpManager.init(this,roomInfo).getRoomTariffInfo(this);
    }

    //******************************** 视频播放组件 ****************************************************************
    private void initVedioPlayer(){
        iv_vedioBg = (ImageView) findViewById(R.id.iv_vedioBg);
        //视频播放组件
        sv_player = (SurfaceView)findViewById(R.id.sv_player);
        rl_media = findViewById(R.id.rl_media);
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
        rl_media.setOnClickListener(this);
    }

    //******************************** 礼物模块 ****************************************************************
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
    public void OnSendGift(boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg,
                           IMMessageItem msgItem, double credit, double rebateCredit) {
        onSendMessage(errType, errMsg, msgItem);
    }

    @Override
    public void OnRecvRoomGiftNotice(IMMessageItem msgItem) {
        sendMessageUpdateEvent(msgItem);
    }

    //******************************** 入场座驾 ******************************************************
    protected CarManager carManager = new CarManager();

    private void initLiveRoomCar(){
        tv_creditTips = (TextView) findViewById(R.id.tv_creditTips);
        ll_entranceCar = (LinearLayout) findViewById(R.id.ll_entranceCar);
        FrameLayout.LayoutParams lp = (FrameLayout.LayoutParams) tv_creditTips.getLayoutParams();
        tv_creditTips.measure(0,0);
        int mH = tv_creditTips.getMeasuredHeight();
        carManager.init(this,ll_entranceCar,mH+lp.topMargin);
    }

    @Override
    public void OnRecvEnterRoomNotice(String roomId, String userId, String nickName,
                                      String photoUrl, String riderId, String riderName,
                                      String riderUrl, int fansNum) {
        Log.d(TAG,"OnRecvEnterRoomNotice-roomId:"+roomId+" userId:"+userId
                +" nickName:"+nickName+" photoUrl:"+photoUrl+" riderId:"+riderId
                +" riderName:"+riderName+" riderUrl:"+riderUrl+" fansNum:"+fansNum);
        CarInfo carInfo = new CarInfo(nickName,userId,riderId,riderName,riderUrl);
        if(null != carManager){
            carManager.putLiveRoomCarInfo(carInfo);
        }

    }

    //******************************** 弹幕消息编辑区域处理 ********************************************
    /**
     * 处理编辑框区域view初始化
     */
    private void initEditAreaView(){
        rl_inputMsg = findViewById(R.id.rl_inputMsg);
        ll_input_edit_body = (LinearLayout)findViewById(R.id.ll_input_edit_body);
        iv_msgType = (ImageView)findViewById(R.id.iv_msgType);
        et_liveMsg = (EditText)findViewById(R.id.et_liveMsg);
        et_liveMsg.setOnClickListener(this);
        btn_sendMsg = (Button)findViewById(R.id.btn_sendMsg);
        et_liveMsg.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {}

            @Override
            public void afterTextChanged(Editable s) {
                if(null != btn_sendMsg){
                    btn_sendMsg.setSelected(!TextUtils.isEmpty(s.toString()));
                }
            }
        });
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
    }

    /**
     * 切换当前编辑状态（弹幕/普通消息）
     */
    private void switchEditType(){
        isBarrage = !isBarrage;
        iv_msgType.setSelected(isBarrage);
        ll_input_edit_body.setSelected(isBarrage);
        et_liveMsg.setHint(isBarrage ? R.string.txt_hint_input_barrage : R.string.txt_hint_input_general);
    }

    /**
     * 发送文本或弹幕消息
     * @param isBarrage
     */
    public boolean sendTextMessage(boolean isBarrage){
        sendTextMessagePreProcess(isBarrage);
        String message = et_liveMsg.getText().toString();
        Log.d(TAG,"sendTextMessage-isBarrage:"+isBarrage+" message:"+message);
        IMMessageItem msgItem = null;
        if(!TextUtils.isEmpty(message)) {
            if (isBarrage) {
                msgItem = mIMManager.sendBarrage(mRoomId, message);
            } else {
                msgItem = mIMManager.sendRoomMsg(mRoomId, message, new String[]{});
            }
        }
        if(msgItem != null){
            liveRoomChatManager.addMessageToList(msgItem);
            //添加弹幕动画
            if(msgItem.msgType == IMMessageItem.MessageType.Barrage){
                addBarrageItem(msgItem);
            }
        }
        return msgItem != null;
    }

    /**
     * 发送文本或弹幕前消息预处理逻辑
     * @param isBarrage
     */
    public void sendTextMessagePreProcess(boolean isBarrage){}

    /**
     * 接收多种消息同一处理
     * @param msgItem
     */
    private void onSendMessage(IMClientListener.LCC_ERR_TYPE errType, String errMsg,IMMessageItem msgItem){
        Log.d(TAG,"onSendMessage-errType:"+ errType+" errMsg:"+errMsg+" msgItem:"+msgItem);
        if(null != msgItem && IMMessageItem.MessageType.Gift == msgItem.msgType){
            if(errType == IMClientListener.LCC_ERR_TYPE.LCC_ERR_SUCCESS){
                Log.d(TAG,"OnSendMsg-一次送礼请求发送成功，执行下一个送礼请求");
                //因为在新的业务逻辑中，需要在OnRecvMsg中对Gift消息执行了动画播放和更新聊天列表的处理，故此处仅处理请求队列
                //但是目前的业务逻辑是发送用户仅回调OnSendMsg，其他房间用户及主播才接受OnRecvMsg回调
                //因此需要在下面增加插入聊天列表和显示送礼动画的测试逻辑
                GiftSendReqManager.getInstance().executeNextReqTask();
                //临时加入的插入聊天列表记录/展示连送动画逻辑
                Message msg = Message.obtain();
                msg.what = EVENT_MESSAGE_UPDATE;
                msg.obj = msgItem;
                sendUiMessage(msg);
            }else{
                Log.d(TAG,"OnSendMsg-一次送礼请求发送失败，清空送礼请求队列");
                GiftSendReqManager.getInstance().clearGiftSendReqQueue();
            }
        }
    }

    @Override
    public void OnSendRoomMsg(boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMMessageItem msgItem) {
        onSendMessage(errType, errMsg, msgItem);
    }

    @Override
    public void OnRecvRoomMsg(IMMessageItem msgItem) {
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
                    //TODO:DELETE测试demo
                    String photoUrl = TestDataUtil.roomBgs[new Random().nextInt(TestDataUtil.roomBgs.length)];
//                    String photoUrl = null;
//                    IMUserBaseInfoItem baseInfo = mIMManager.getUserInfo(item.userId);
//                    if(baseInfo != null){
//                        photoUrl = baseInfo.photoUrl;
//                    }
                    if(!TextUtils.isEmpty(photoUrl)){
                        Picasso.with(BaseCommonLiveRoomActivity.this.getApplicationContext())
                                .load(photoUrl)
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
        onSendMessage(errType, errMsg, msgItem);
    }


    /********************************* IMManager事件监听回调  *******************************************/

    @Override
    public void OnRoomOut(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
        Log.d(TAG,"OnFansRoomOut-reqId:"+reqId+" success:"+success+" errType:"+errType+" errMsg:"+errMsg);
        if(success){
            //退出房间成功，就清空送礼队列，并停止服务
            GiftSendReqManager.getInstance().shutDownReqQueueServNow();
        }
    }

    @Override
    public void OnRecvRoomToastNotice(IMMessageItem msgItem) {
        sendMessageUpdateEvent(msgItem);
    }
}
