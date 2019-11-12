package com.qpidnetwork.livemodule.liveshow.liveroom;


import android.annotation.SuppressLint;
import android.content.ComponentCallbacks2;
import android.opengl.GLSurfaceView;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.FragmentManager;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewParent;
import android.view.Window;
import android.view.WindowManager;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.facebook.imagepipeline.core.ImagePipelineFactory;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.canadapter.CanOnItemListener;
import com.qpidnetwork.livemodule.httprequest.item.AudienceInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.EmotionItem;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.httprequest.item.HangoutAnchorInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType;
import com.qpidnetwork.livemodule.httprequest.item.IntToEnumUtils;
import com.qpidnetwork.livemodule.httprequest.item.LiveRoomType;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.im.listener.IMClientListener;
import com.qpidnetwork.livemodule.im.listener.IMDealInviteItem;
import com.qpidnetwork.livemodule.im.listener.IMHangoutAnchorItem;
import com.qpidnetwork.livemodule.im.listener.IMHangoutCountDownItem;
import com.qpidnetwork.livemodule.im.listener.IMHangoutRoomItem;
import com.qpidnetwork.livemodule.im.listener.IMMessageItem;
import com.qpidnetwork.livemodule.im.listener.IMRecvEnterRoomItem;
import com.qpidnetwork.livemodule.im.listener.IMRecvLeaveRoomItem;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.livemodule.im.listener.IMSysNoticeMessageContent;
import com.qpidnetwork.livemodule.im.listener.IMUserBaseInfoItem;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.audience.ChatterSelectorAdapter;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.GiftImageType;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.NormalGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.advance.AdvanceGiftItem;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.advance.AdvanceGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.hangout.HangOutVedioWindowManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.hangout.obj.HangoutVedioWindowObj;
import com.qpidnetwork.livemodule.liveshow.liveroom.hangout.view.HangOutVedioWindow;
import com.qpidnetwork.livemodule.liveshow.liveroom.hangout.view.HangOutVideoCtrlDialogFragment;
import com.qpidnetwork.livemodule.liveshow.liveroom.hangout.view.HangoutInviteFriendsDialogFragment;
import com.qpidnetwork.livemodule.utils.ButtonUtils;
import com.qpidnetwork.livemodule.utils.StringUtil;
import com.qpidnetwork.livemodule.view.LiveRoomScrollView;
import com.qpidnetwork.livemodule.view.SimpleDoubleBtnTipsDialog;
import com.qpidnetwork.livemodule.view.SoftKeyboradListenFrameLayout;
import com.qpidnetwork.qnbridgemodule.datacache.FileCacheManager;
import com.qpidnetwork.qnbridgemodule.sysPermissions.manager.PermissionManager;
import com.qpidnetwork.qnbridgemodule.util.DisplayUtil;
import com.qpidnetwork.qnbridgemodule.util.Log;
import com.qpidnetwork.qnbridgemodule.util.SystemUtils;
import com.qpidnetwork.qnbridgemodule.util.ToastUtil;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;

import io.reactivex.Flowable;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import io.reactivex.functions.Consumer;

/**
 * Hang Out直播间（处理UI响应）
 * Created by Harry Wei on 2018/4/18.
 * copy by Jagger 2019-3-14
 */

public class HangOutLiveRoomActivity extends BaseHangOutLiveRoomActivity implements HangOutVedioWindow.OnAddInviteClickListener,
        HangOutVedioWindow.VedioClickListener, HangOutVedioWindow.VedioDisconnectListener, HangOutVedioWindowManager.InviteEventListener {

    private String TAG;
    private final int MAIN_ANCHOR_INDEX = 1; //主主播位置
    private final int STEP_ENTERTIME_COUNTDOWN = 60 * 1000;  //后台结束直播间倒计时
    private final int MSG_MAX_LENGTH = 140;     //输入框最大字符数

    private LiveRoomScrollView lrsv_roomBody;

    //四个视频窗格
    private View view_vedioWindows;
    private HangOutVedioWindowManager vedioWindowManager;
    //0就代表没有窗格放大，否则标识当前有放大的窗格
    private int lastScaleVedioWindowIndex = 0;
    private FrameLayout v_float, fl_video;
    //视频控制面板
    private ImageView iv_vedioControll;
//    private HangOutVedioController hovc_container;
    private boolean isMuteOn = false;
    private boolean isSilentOn = false;
    //庆祝礼物
//    private View fl_celebGiftAnim;
    private SimpleDraweeView sdv_celebGift;
    protected AdvanceGiftManager celebGiftManager;

    //聊天展示区域
    private View fl_imMsgContainer;
    private View fl_msglist;
    //底部消息输入区域
    private View ll_audienceChooser;
    private TextView tv_audienceNickname;
    private ImageView iv_audienceIndicator;
    private ListView lv_chatters;
    private ChatterSelectorAdapter chatterSelectorAdapter;
    private List<AudienceInfoItem> chatterInfoItems;
    public AudienceInfoItem lastSelectedAudienceInfoItem = null;
    private AudienceInfoItem defaultAudienceInfoItem = null;
    private EditText et_liveMsg;
//    private EmojiTabScrollLayout etsl_emojiContainer;
    private EmotionItem chooseEmotionItem = null;
    private int lastTxtChangedStart = 0;
    private int lastTxtChangedNumb = 0;
    private ImageView iv_emojiSwitch;
    private View iv_gift;
//    private boolean mManPushDisconnect = false; //男士推流是否断线, 标记IM重连后是否需要请求推流接口

    //本地APP进入后台倒计时
    private Disposable mDisposable;
    private boolean mIsBackgroundOvertime = false;//是否转到后台超过1分钟

    @Override
    public void onCreate(Bundle savedInstanceState) {
        this.requestWindowFeature(Window.FEATURE_NO_TITLE);
        //不能加,全屏和AndroidBug5497Workaround有冲突
//        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,  WindowManager.LayoutParams.FLAG_FULLSCREEN);
        //直播中保持屏幕点亮不熄屏
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON, WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

        super.onCreate(savedInstanceState);
        TAG = HangOutLiveRoomActivity.class.getSimpleName();

        setContentView(R.layout.activity_live_room_hangout);
        //不能加
//        AndroidBug5497Workaround.assistActivity(this, true);
//        setImmersionBarArtts(R.color.transparent_full);

        initViews();
        initHangOutVeidoStatus();
    }

    public void initData(){
        super.initData();
        //聊天@谁
        chatterInfoItems = new ArrayList<>();
        //构建一个@All
        defaultAudienceInfoItem = new AudienceInfoItem(
                "0",
                "All",
                "",
                null,null,0,false);
        lastSelectedAudienceInfoItem = defaultAudienceInfoItem;
        chatterInfoItems.add(lastSelectedAudienceInfoItem);
        //添加男士资料到本地缓存manager
        if(null != mIMManager && null != loginItem){
            mIMManager.updateOrAddUserBaseInfo(new IMUserBaseInfoItem(loginItem.userId,
                    loginItem.nickName,loginItem.photoUrl));
        }
    }

    private void initViews(){
        int screenWidth = DisplayUtil.getScreenWidth(this);
        Log.d(TAG,"initViews-screenWidth:"+screenWidth);
        SoftKeyboradListenFrameLayout flContentBody = (SoftKeyboradListenFrameLayout)findViewById(R.id.flContentBody);
        flContentBody.setInputWindowListener(this);
        lrsv_roomBody = (LiveRoomScrollView) findViewById(R.id.lrsv_roomBody);
        //四个视频窗格区域
        initVedioWindowViews(screenWidth);
        //消息列表区域
        initRoomMsgList();
        //视频控制面板
        initVedioControllView(screenWidth);
        //底部消息输入区域
        initMsgInputView();
        //软键盘弹起视图兼容设置
        setSizeUnChanageViewParams();
    }

    /**
     * 初始化直播间男士/主播状态
     */
    private void initHangOutVeidoStatus() {
        if(null != mIMHangoutRoomInItem && null != loginItem && null != vedioWindowManager){
            //初始化男士
            if(!vedioWindowManager.checkIsOnLine(loginItem.userId)){
                //如果男士没坐在位置上,才初始化，以免重复初始化。
                vedioWindowManager.switchInvitedStatus(loginItem.userId,loginItem.photoUrl,
                        loginItem.nickName, null, null);

                //男士自己就展示切换摄像头按钮
//                vedioWindowManager.setCameraCanSwitch(loginItem.userId, true);

                //如果重新进入直播间时，男士之前是在推流状态下，重新推流
                doCheckManPushReconnect();
            }else{
                //如果男士坐在位置上且推流被断开，则重连
                doCheckManPushReconnect();
            }

            //初始化其他主播
            if(null != mIMHangoutRoomInItem.livingAnchorList){
                for(IMHangoutAnchorItem imOtherAnchorItem : mIMHangoutRoomInItem.livingAnchorList){
                    //对应的格子位置
                    int cellIndex = 0;

                    //本地缓存各主播信息
                    if(null != mIMManager){
                        mIMManager.updateOrAddUserBaseInfo(new IMUserBaseInfoItem(imOtherAnchorItem.anchorId,
                                imOtherAnchorItem.nickName,imOtherAnchorItem.photoUrl));
                    }

                    if(imOtherAnchorItem.anchorStatus == IMHangoutAnchorItem.IMAnchorStatus.Online){
                        Log.d(TAG, "initHangOutVeidoStatus 主播已经进入直播间" );
                        //主播已经进入直播间
                        cellIndex = vedioWindowManager.switchInvitedStatus(imOtherAnchorItem.anchorId,imOtherAnchorItem.photoUrl,
                                imOtherAnchorItem.nickName, imOtherAnchorItem, imOtherAnchorItem.videoUrl);
                        //加入@列表
                        doAddToTargetList(cellIndex, imOtherAnchorItem);
                    }else if(imOtherAnchorItem.anchorStatus == IMHangoutAnchorItem.IMAnchorStatus.Invitation){
                        Log.d(TAG, "initHangOutVeidoStatus 男士邀请中:" + imOtherAnchorItem.anchorStatus.name());
                        //男士邀请中
                        cellIndex = vedioWindowManager.switchAnchorComingStatus(imOtherAnchorItem.anchorId,imOtherAnchorItem.photoUrl,
                                imOtherAnchorItem.nickName,
                                HangOutVedioWindow.AnchorComingType.Man_Inviting,0, imOtherAnchorItem);
                    }else if(imOtherAnchorItem.anchorStatus == IMHangoutAnchorItem.IMAnchorStatus.InviteConfirm){
                        Log.d(TAG, "initHangOutVeidoStatus 女士已经接受男士邀请:" + imOtherAnchorItem.anchorStatus.name());
                        //或女士已经接受男士邀请
                        cellIndex = vedioWindowManager.switchAnchorComingStatus(imOtherAnchorItem.anchorId,imOtherAnchorItem.photoUrl,
                                imOtherAnchorItem.nickName,
                                HangOutVedioWindow.AnchorComingType.Anchor_Invite_Confirm,0, imOtherAnchorItem);
                        //加入@列表
                        doAddToTargetList(cellIndex, imOtherAnchorItem);
                    }else if(imOtherAnchorItem.anchorStatus == IMHangoutAnchorItem.IMAnchorStatus.KnockConfirm){
                        Log.d(TAG, "initHangOutVeidoStatus 女士敲门男士已经确认" );
                        //女士敲门男士已经确认
                        cellIndex = vedioWindowManager.switchAnchorComingStatus(imOtherAnchorItem.anchorId,imOtherAnchorItem.photoUrl,
                                imOtherAnchorItem.nickName,
                                HangOutVedioWindow.AnchorComingType.Man_Accepted_Anchor_Knock,0, imOtherAnchorItem);
                        //加入@列表
                        doAddToTargetList(cellIndex, imOtherAnchorItem);
                    }else if(imOtherAnchorItem.anchorStatus == IMHangoutAnchorItem.IMAnchorStatus.ReciprocalEnter){
                        Log.d(TAG, "initHangOutVeidoStatus 女士同意男士邀请倒计时进入中:"  + imOtherAnchorItem.anchorStatus.name());
                        //女士同意男士邀请倒计时进入中
                        cellIndex = vedioWindowManager.switchAnchorComingStatus(imOtherAnchorItem.anchorId,imOtherAnchorItem.photoUrl,
                                imOtherAnchorItem.nickName,
                                HangOutVedioWindow.AnchorComingType.Anchor_Coming_After_Expires,
                                imOtherAnchorItem.leftSeconds,
                                imOtherAnchorItem);
                    }
                }
            }

            //邀请 从私密邀请的主播
            if(mExtraAnchorInfo != null){
                vedioWindowManager.sendInvitation(mIMHangoutRoomInItem.roomId, mExtraAnchorInfo.anchorId, mExtraAnchorInfo.photoUrl, mExtraAnchorInfo.nickName, null, 0);
                mExtraAnchorInfo = null;
            }

            //初始化各窗格吧台礼物数据列表
            initHangOutRecvBarGiftData();
        }
    }

    /**
     * 初始化四宫格已经接收到的bar礼物列表
     */
    private void initHangOutRecvBarGiftData(){
        if(null != vedioWindowManager){
            vedioWindowManager.initRecvBarGiftData(mIMHangoutRoomInItem.buyforList);
        }
    }

    @SuppressLint("ClickableViewAccessibility")
    private void initMsgInputView(){
        ll_audienceChooser = findViewById(R.id.ll_audienceChooser);
        ll_audienceChooser.setOnClickListener(this);
        tv_audienceNickname = (TextView) findViewById(R.id.tv_audienceNickname);
        tv_audienceNickname.setOnClickListener(this);
        tv_audienceNickname.setText(StringUtil.addAtFirst(lastSelectedAudienceInfoItem.nickName));
        //设置初始@all
        iv_audienceIndicator = (ImageView) findViewById(R.id.iv_audienceIndicator);
        iv_audienceIndicator.setOnClickListener(this);
        iv_audienceIndicator.setSelected(true);
        chatterSelectorAdapter = new ChatterSelectorAdapter(this,R.layout.item_simple_list_chatter);
        chatterSelectorAdapter.setList(chatterInfoItems);
        chatterSelectorAdapter.setOnItemListener(new CanOnItemListener(){
            @Override
            public void onItemChildClick(View view, int position) {
                lv_chatters.setVisibility(View.GONE);
                iv_audienceIndicator.setSelected(true);
                chatterSelectorAdapter.notifyDataSetChanged();
                lastSelectedAudienceInfoItem = chatterSelectorAdapter.getList().get(position);
                Log.d(TAG,"onItemChildClick-position:"+position+" lastSelectedAudienceInfoItem:"+lastSelectedAudienceInfoItem);
                tv_audienceNickname.setText(StringUtil.addAtFirst(lastSelectedAudienceInfoItem.nickName));
            }
        });
        lv_chatters = (ListView) findViewById(R.id.lv_chatters);
        lv_chatters.setAdapter(chatterSelectorAdapter);
        lv_chatters.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                chatterSelectorAdapter.notifyDataSetChanged();
                return false;
            }
        });
        lv_chatters.setVisibility(View.GONE);

        et_liveMsg = (EditText) findViewById(R.id.et_liveMsg);
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
//                if(null != lastSelectedAudienceInfoItem
//                        && !lastSelectedAudienceInfoItem.equals(defaultAudienceInfoItem)){
//                    synchronized (chatterInfoItems){
//                        boolean isManStillInRoom = false;
//                        AudienceInfoItem audienceInfoItem = null;
//                        for(int index=0; index<chatterInfoItems.size(); index++){
//                            audienceInfoItem = chatterInfoItems.get(index);
//                            if(audienceInfoItem.userId.equals(defaultAudienceInfoItem.userId)){
//                                continue;
//                            }
//                            if(audienceInfoItem.userId.equals(lastSelectedAudienceInfoItem.userId)){
//                                isManStillInRoom = true;
//                                break;
//                            }
//                        }
//                        if(!isManStillInRoom){
//                            showToast(R.string.public_live_sendmsg_manleave_tips);
//                            return true;
//                        }
//                    }
//                }

                boolean isAnchorStillInRoom = false;
                //判断@的主播是否还在直播间
                if(!lastSelectedAudienceInfoItem.userId.equals("0")){
                    //不是@All
                    for(IMHangoutAnchorItem imOtherAnchorItem : mIMHangoutRoomInItem.livingAnchorList){
                        if(imOtherAnchorItem.anchorId.equals(lastSelectedAudienceInfoItem.userId)){
                            isAnchorStillInRoom = true;
                            break;
                        }
                    }
                }else {
                    //是@All
                    isAnchorStillInRoom = true;
                }

                if(!isAnchorStillInRoom){
                    showToast(R.string.public_live_sendmsg_manleave_tips);
                    return true;
                }

                //清空消息
                if(enterKey2SendMsg(et_liveMsg.getText().toString(), lastSelectedAudienceInfoItem.userId,
                        lastSelectedAudienceInfoItem.nickName)){
                    //清空消息
                    et_liveMsg.setText("");
                }

                return true;
            }
        });
        iv_emojiSwitch = (ImageView) findViewById(R.id.iv_emojiSwitch);
        iv_emojiSwitch.setVisibility(View.GONE);
        iv_emojiSwitch.setOnClickListener(this);
        iv_gift = findViewById(R.id.iv_gift);
        iv_gift.setVisibility(View.VISIBLE);
        iv_gift.setOnClickListener(this);
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
            if(s.toString().length()> MSG_MAX_LENGTH){
                int outStart = 0;
                //s.delete会瞬间触发TextChangedListener流程，导致lastTxtChangedNumb=0时多走一遍流程
                et_liveMsg.removeTextChangedListener(tw_msgEt);
                //多人视频直播间多了表情选择面板
//                if(etsl_emojiContainer.getVisibility() == View.VISIBLE && !TextUtils.isEmpty(lastInputEmoSign)){
//                    outStart = lastTxtChangedStart;
//                    s.delete(outStart,outStart+lastTxtChangedNumb);
//                    Log.logD(TAG,"afterTextChanged-outNumb:"+lastTxtChangedNumb
//                            +" outStart:"+outStart+" s:"+s.toString());
//                    lastInputEmoSign = null;
//                }else{
                int outNumb = s.toString().length() - MSG_MAX_LENGTH;
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

    /**
     * 四个视频窗格区域
     * @param screenWidth
     */
    private void initVedioWindowViews(int screenWidth) {
        LinearLayout.LayoutParams flBgContentLP = (LinearLayout.LayoutParams) findViewById(R.id.fl_bgContent).getLayoutParams();
        flBgContentLP.height = screenWidth;
        view_vedioWindows = findViewById(R.id.view_vedioWindows);
        view_vedioWindows.setOnClickListener(this);
        FrameLayout.LayoutParams vedioWindowsLP = (FrameLayout.LayoutParams)view_vedioWindows.getLayoutParams();
        vedioWindowsLP.height = screenWidth;
        v_float = findViewById(R.id.v_float);
        v_float.setOnClickListener(this);
        fl_video = findViewById(R.id.fl_video);
        vedioWindowManager = new HangOutVedioWindowManager.Builder()
                .setImHangOutRoomItem(mIMHangoutRoomInItem)
                .setLoginItem(loginItem)
                .setInviteEventListener(this)
                .setmActivity(this)
                .build();
        vedioWindowManager.add(1,R.id.view_vedioWindow1);
        vedioWindowManager.add(2,R.id.view_vedioWindow2);
        vedioWindowManager.add(3,R.id.view_vedioWindow3);
        vedioWindowManager.add(4,R.id.view_vedioWindow4);
        //庆祝礼物界面
        sdv_celebGift = (SimpleDraweeView) findViewById(R.id.sdv_celebGift);
        sdv_celebGift.setVisibility(View.GONE);
        celebGiftManager = new AdvanceGiftManager(sdv_celebGift);
    }

    private void initRoomMsgList() {
        fl_imMsgContainer = findViewById(R.id.fl_imMsgContainer);
        fl_imMsgContainer.setOnClickListener(this);
        // 2019/3/19 Hardy
        String manId = "";
        LoginItem loginItem = LoginManager.getInstance().getLoginItem();
        if (loginItem != null) {
            manId = loginItem.userId;
        }
        //消息列表
        liveRoomChatManager = new LiveRoomChatManager(this, IMRoomInItem.IMLiveRoomType.HangoutRoom,
                manId,manId,new RoomThemeManager());    // currAnchorId在hangout直播间指定为男士ID
//                mIMHangoutRoomInItem.manId,new RoomThemeManager());
        fl_msglist = findViewById(R.id.fl_msglist);
        fl_msglist.setClickable(true);
        liveRoomChatManager.init(this, fl_msglist);
        fl_msglist.setOnClickListener(this);
        liveRoomChatManager.setLiveMessageListItemClickListener(new LiveRoomChatManager.LiveMessageListItemClickListener() {
            @Override
            public void onItemClick(IMMessageItem item) {
            if(item != null){
                switch (item.msgType){
                    case AnchorRecommand:{
                        //主播推荐邀请
//                        HangoutAnchorInfoItem hangoutAnchorInfoItem = new HangoutAnchorInfoItem();
//                        hangoutAnchorInfoItem.anchorId = item.hangoutRecommendItem.firendId;
//                        hangoutAnchorInfoItem.nickName = item.hangoutRecommendItem.friendNickName;
//                        hangoutAnchorInfoItem.photoUrl = item.hangoutRecommendItem.friendPhotoUrl;
//                        Log.i(TAG, "liveRoomChatManager AnchorRecommand click:" + hangoutAnchorInfoItem.anchorId );
//                        vedioWindowManager.sendInvitation(mIMHangoutRoomInItem.roomId, hangoutAnchorInfoItem.anchorId,hangoutAnchorInfoItem.photoUrl, hangoutAnchorInfoItem.nickName, 0);
                        onAnchorRecommand(item.hangoutRecommendItem.firendId, item.hangoutRecommendItem.friendNickName, item.hangoutRecommendItem.friendPhotoUrl);
                    }break;
                    case AnchorKnock:{
                        //主播敲门事件(观众开门)
                        Log.i(TAG, "liveRoomChatManager AnchorKnock click");
//                        sendDealKnock(item.hangoutKnockRequestItem.knockId, new Consumer<HttpRespObject>() {
//                            @Override
//                            public void accept(HttpRespObject httpRespObject) throws Exception {
//                                Log.i(TAG, "liveRoomChatManager AnchorKnock sendDealKnock:" + httpRespObject.isSuccess);
//                                if(!httpRespObject.isSuccess){
//                                    ToastUtil.showToast(mContext, httpRespObject.errMsg);
//                                }
//                            }
//                        });
                        if(item.hangoutKnockRequestItem != null){
                            onAnchorKnock(item.hangoutKnockRequestItem.anchorId, item.hangoutKnockRequestItem.nickName, item.hangoutKnockRequestItem.photoUrl, item.hangoutKnockRequestItem.knockId);
                        }else{
                            Log.i("xxxx" , "AnchorKnock item.hangoutKnockRequestItem == null");
                        }

                    }break;
                }
            }
            }
        });

        // 2019/3/18 Hardy  设置消息列表的 view 作为高斯模糊的蒙层
        setDialogBlurView(findViewById(R.id.ll_msglist));
    }

    private void initVedioControllView(int screenWidth) {
        iv_vedioControll = (ImageView) findViewById(R.id.iv_vedioControll);
        iv_vedioControll.setOnClickListener(this);
        iv_vedioControll.setVisibility(View.VISIBLE);
//        hovc_container = (HangOutVedioController) findViewById(R.id.hovc_container);
//        hovc_container.setVisibility(View.GONE);
//        hovc_container.setListener(this);
//        FrameLayout.LayoutParams containerLP = (FrameLayout.LayoutParams)hovc_container.getLayoutParams();
//        containerLP.height = DisplayUtil.getScreenHeight(this)-screenWidth-DisplayUtil.getStatusBarHeight(this);
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);
        int i = v.getId();
        if (i == R.id.ll_audienceChooser || i == R.id.tv_audienceNickname || i == R.id.iv_audienceIndicator) {//切换观众昵称列表的选择状态
            boolean hasAudienceListShowed = View.VISIBLE == lv_chatters.getVisibility();
            lv_chatters.setVisibility(hasAudienceListShowed ? View.GONE : View.VISIBLE);
            iv_audienceIndicator.setSelected(hasAudienceListShowed);

        } else if (i == R.id.iv_gift) {
            // 2019/4/18 Hardy 快速点击拦截，避免显示了 Add Credits 弹窗.
            if (ButtonUtils.isFastDoubleClick(i)) {
                return;
            }

            if (View.VISIBLE == lv_chatters.getVisibility()) {
                lv_chatters.setVisibility(View.GONE);
                iv_audienceIndicator.setSelected(true);
            } else {
                showHangoutGiftDialog();
                iv_vedioControll.setVisibility(View.VISIBLE);
//                hovc_container.setVisibility(View.GONE);
            }

        } else if (i == R.id.view_vedioWindows || i == R.id.fl_imMsgContainer || i == R.id.fl_msglist) {
            hideInputSoftView();

        } else if (i == R.id.iv_vedioControll) {
            iv_vedioControll.setVisibility(View.GONE);
//            hovc_container.setVisibility(View.VISIBLE);
            FragmentManager fragmentManager = getSupportFragmentManager();
            HangOutVideoCtrlDialogFragment.showDialog(fragmentManager, isMuteOn, isSilentOn, new HangOutVideoCtrlDialogFragment.OnControllerEventListener() {
                @Override
                public void onCloseClicked() {
                    Log.d(TAG,"onCloseClicked");
                    iv_vedioControll.setVisibility(View.VISIBLE);
                }

                @Override
                public void onMuteStatusChanged(boolean onOrOff) {
                    Log.d(TAG,"onMuteStatusChanged-onOrOff:"+onOrOff);
                    iv_vedioControll.setVisibility(View.VISIBLE);
                    if(null != vedioWindowManager){
                        vedioWindowManager.mute(onOrOff);
                    }
                    isMuteOn = onOrOff;
                }

                @Override
                public void onSilentStatusChanged(boolean onOrOff) {
                    Log.d(TAG,"onSilentStatusChanged-onOrOff:"+onOrOff);
                    iv_vedioControll.setVisibility(View.VISIBLE);
                    if(null != vedioWindowManager){
                        vedioWindowManager.slient(onOrOff);
                    }
                    isSilentOn = onOrOff;
                }

                @Override
                public void onExitHangOutClicked() {
                    Log.d(TAG,"onExitHangOutClicked");
                    iv_vedioControll.setVisibility(View.VISIBLE);
                    lastSwitchLiveRoomType = LiveRoomType.Unknown;
                    lastSwitchLiveRoomId = null;
                    lastSwitchUserBaseInfoItem = null;
                    showUserCloseRoomDialog();
                }
            });

        } else if (i == R.id.v_float) {
            if (!hideInputSoftView() && 0 != lastScaleVedioWindowIndex) {
                //有则缩小之并重置lastScaleVedioWindowIndex
                //先不考虑放大缩小动画，先直接放大和缩小来,后面在将动画加入
//                if (null != vedioWindowManager && vedioWindowManager.change2Normal(lastScaleVedioWindowIndex)) {
//                    v_float.setVisibility(View.GONE);
//                    lastScaleVedioWindowIndex = 0;
//                }
                showNormalSurfaceView();
            }

        } else {
        }
    }

    private boolean hideInputSoftView() {
        boolean result = false;
//        if(null != audienceInfoDialog && audienceInfoDialog.isShowing()){
//            audienceInfoDialog.dismiss();
//            result = true;
//        }else if(null != otherAnchorInfoDialog && otherAnchorInfoDialog.isShowing()){
//            otherAnchorInfoDialog.dismiss();
//            result = true;
//        }else if(null != liveGiftDialog && liveGiftDialog.isShowing()){
//            liveGiftDialog.dismiss();
//            result = true;
//        }else
            if(View.VISIBLE == lv_chatters.getVisibility()){
            lv_chatters.setVisibility(View.GONE);
            iv_audienceIndicator.setSelected(true);
            result = true;
        } else if(isSoftInputOpen){
            hideSoftInput(et_liveMsg, true);
            result = true;
        }
        Log.d(TAG,"hideInputSoftView-result:"+result);
        return result;
    }

    @Override
    protected void preStopLive() {
        super.preStopLive();
        if(isActivityFinishByUser && null != vedioWindowManager){
            vedioWindowManager.onPause();
        }
    }

    @Override
    protected void onStop() {
        super.onStop();
        Log.d(TAG,"onStop");
        if(null != celebGiftManager){
            celebGiftManager.onDestroy();
        }
        //四个窗格的大礼物动画也顺便结束一下
        if(null != vedioWindowManager){
            vedioWindowManager.onActivityStop();
        }

        //开始最小化后台1分钟倒计时
        doUpdateBackGroundTime();
    }

    @Override
    protected void onResume() {
        super.onResume();

        //取消最小化后台1分钟倒计时
        doCancelUpdateBackGroundTime();

        //取消最小化后台1分钟退出
        if(mIsBackgroundOvertime){
            endLiveRoom(HangoutEndActivity.HangoutEndType.OVER_ONE_MINUTE, true, true);
        }
    }

    //===================== 2019/04/26 Hardy 低内存时，清理 Fresco 占用的图片内存缓存，优化播放礼物动画或者加载其他图片时可能导致的 OOM ===============================
    // https://blog.csdn.net/u014614038/article/details/79737712

    @Override
    public void onTrimMemory(int level) {
        super.onTrimMemory(level);

        // 大于当前的阀值
        if (level >= ComponentCallbacks2.TRIM_MEMORY_MODERATE) { // 60
            clearFrescoMemoryCache();
        }
    }

    @Override
    public void onLowMemory() {
        super.onLowMemory();

        clearFrescoMemoryCache();
    }

    private void clearFrescoMemoryCache(){
        try {
            ImagePipelineFactory.getInstance().getImagePipeline().clearMemoryCaches();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    //===================== 2019/04/26 Hardy 低内存时，清理 Fresco 占用的图片内存缓存，优化播放礼物动画或者加载其他图片时可能导致的 OOM ===============================

    /**
     * 启动消息动画
     * @param toUids
     * @param msgItem fromId
     */
    public void launchGiftAnimByMessage(final String[] toUids, final IMMessageItem msgItem){
        super.launchGiftAnimByMessage(toUids,msgItem);

        if(null == msgItem || msgItem.giftMsgContent == null || msgItem.msgType!= IMMessageItem.MessageType.Gift){
            return;
        }
        //首先查询giftItem 判断是否为庆祝
        final GiftItem giftItem = NormalGiftManager.getInstance().getLocalGiftDetail(msgItem.giftMsgContent.giftId);
        Log.d(TAG,"launchGiftAnimByMessage-giftItem:"+giftItem);
        if(null == giftItem){
            NormalGiftManager.getInstance().getGiftDetail(msgItem.giftMsgContent.giftId, null);
            return;
        }
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if(giftItem.giftType == GiftItem.GiftType.Celebrate){
                    String localPath = FileCacheManager.getInstance().getGiftLocalPath(giftItem.id, giftItem.srcWebpUrl);
                    if(SystemUtils.fileExists(localPath)){
                        AdvanceGiftItem bigGiftAnimItem = new AdvanceGiftItem(localPath,
                                msgItem.giftMsgContent.giftNum, AdvanceGiftItem.AdvanceGiftType.CelebGift);
                        if(null != celebGiftManager){
                            celebGiftManager.addAdvanceGiftItem(bigGiftAnimItem);
                        }
                    }else{
                        Log.d(TAG,"launchAnimationByMessage-giftId:"+giftItem.id+" 对应的庆祝礼物webp文件本地未缓存!");
                        //不存在就下载
                        NormalGiftManager.getInstance().getGiftImage(giftItem.id, GiftImageType.BigAnimSrc, null);
                    }
                }else if(null != vedioWindowManager){
                    if (toUids == null || toUids.length == 0) {
                        // toUids为空，则发给所有人
                        vedioWindowManager.updateVedioWindowGiftAnimDataForAll(msgItem, giftItem);
                    }else {
                        //有目标
                        for(String toUid:toUids){
                            vedioWindowManager.updateVedioWindowGiftAnimData(toUid, msgItem, giftItem);
                        }
                    }
                }
            }
        });
    }

    /**
     * 本地自动倒计时
     */
    private void doUpdateBackGroundTime(){
        if(mDisposable != null && !mDisposable.isDisposed()){
            return;
        }

        mDisposable = Flowable.interval(STEP_ENTERTIME_COUNTDOWN, TimeUnit.MILLISECONDS)
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new Consumer<Long>() {
                    @Override
                    public void accept(@NonNull Long aLong) throws Exception {
                        Log.i("xxxx" , "doUpdateBackGroundTime accept aLong:" + aLong);
                        mIsBackgroundOvertime = true;
                        //只停业务，界面不跳转。在onResume()处理
                        endLiveRoom(HangoutEndActivity.HangoutEndType.OVER_ONE_MINUTE, false, false);
                        //取消倒计时
                        doCancelUpdateBackGroundTime();
                    }
                });
    }

    /**
     * 中止本地倒计时
     */
    private void doCancelUpdateBackGroundTime(){
        if(mDisposable!=null&&!mDisposable.isDisposed()){
            mDisposable.dispose();
        }
    }

    /**
     * 加入送礼物对话框 和 聊天@谁列表
     * @param cellIndex
     * @param imHangoutAnchorItem
     */
    private void doAddToTargetList(int cellIndex, IMHangoutAnchorItem imHangoutAnchorItem){
        //不是男士自己才加
        if(!imHangoutAnchorItem.anchorId.equals(loginItem.userId)) {
            //加入送礼物对话框
            Log.i("Jagger", "initHangOutVeidoStatus cellIndex:" + cellIndex + ",name:" + imHangoutAnchorItem.nickName);
            addAnchor2GiftDialog(cellIndex == MAIN_ANCHOR_INDEX ? true : false, imHangoutAnchorItem);

            //添加到聊天@谁列表
            chatterSelectorAdapter.addLastItem(new AudienceInfoItem(imHangoutAnchorItem.anchorId, imHangoutAnchorItem.nickName,
                    imHangoutAnchorItem.photoUrl, "", "", 0, false));
        }
    }

    /**
     * 加入送礼物对话框 和 聊天@谁列表
     * @param cellIndex
     * @param imRecvEnterRoomItem
     */
    private void doAddToTargetList(int cellIndex, IMRecvEnterRoomItem imRecvEnterRoomItem){
        //不是男士自己才加
        if(!imRecvEnterRoomItem.userId.equals(loginItem.userId)){
            Log.i("Jagger" , "OnRecvEnterHangoutRoomNotice cellIndex:" + cellIndex + ",name:" + imRecvEnterRoomItem.nickName );
            //信息加入礼物弹出框中
            addAnchor2GiftDialog(cellIndex == MAIN_ANCHOR_INDEX? true:false, imRecvEnterRoomItem);
            //添加到聊天@谁列表
            chatterSelectorAdapter.addLastItem(new AudienceInfoItem(imRecvEnterRoomItem.userId,imRecvEnterRoomItem.nickName,
                    imRecvEnterRoomItem.photoUrl,"","",0,false));
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        Log.d(TAG,"onDestroy");
        //释放四个窗格礼物动画资源+庆祝礼物动画资源
        if(null != vedioWindowManager){
            vedioWindowManager.release();
        }
        if(null != celebGiftManager){
            celebGiftManager.onDestroy();
        }
        if(null != liveRoomChatManager){
            liveRoomChatManager.destroy();
        }

        if(mIMHangoutRoomInItem != null && mIMManager != null){
            mIMManager.outHangOutRoomAndClearFlag(mIMHangoutRoomInItem.roomId);
        }

        //取消倒计时
        doCancelUpdateBackGroundTime();
    }

    //------------------------------推荐/邀请主播 start--------------------------------------

    /**
     * 格子里的邀请按钮
     * @param index
     */
    @Override
    public void onAddInviteClick(int index) {
        Log.d(TAG,"onAddInviteClick-index:"+index);
        if(!hideInputSoftView()){
            showInviteFriendsDialog(index);
            iv_vedioControll.setVisibility(View.VISIBLE);
//            hovc_container.setVisibility(View.GONE);
        }
    }

    @Override
    public void onClickInviteResponse(boolean isSuccess, HangoutInvitationManager.HangoutInvationErrorType errorType, String errorMsg, String roomId) {
        if(!isSuccess){
            //信用点不足
            if(errorType == HangoutInvitationManager.HangoutInvationErrorType.NoCredit){
                showCreditNoEnoughDialog(R.string.hangout_no_credits_send_invitation_tip);
            }
            else if (errorType == HangoutInvitationManager.HangoutInvationErrorType.ConnectFail) {
                ToastUtil.showToast(mContext, errorMsg);
            }
            else if (errorType == HangoutInvitationManager.HangoutInvationErrorType.InviteDeny) {
                // 2019/4/1 Hardy  系统提示：邀请被拒绝或主播180s后未响应 {主播昵称} is not responding. Please try again later.
                IMSysNoticeMessageContent msgContent = new IMSysNoticeMessageContent(errorMsg, "", IMSysNoticeMessageContent.SysNoticeType.Normal);
                IMMessageItem msgItem = new IMMessageItem(roomId, mIMManager.mMsgIdIndex.getAndIncrement(),"",
                        IMMessageItem.MessageType.SysNotice,msgContent);
                sendMessageUpdateEvent(msgItem);
            }else{
                ToastUtil.showToast(mContext, errorMsg);
            }
        }
    }

    /**
     * 取消邀请结果回调
     * @param isSuccess
     * @param httpErrCode
     * @param errMsg
     */
    @Override
    public void onInvitationCancel(boolean isSuccess, int httpErrCode, String errMsg, String anchorId) {
        if(isSuccess ){
            //还原窗口
            vedioWindowManager.switchWait2InviteStatus(anchorId);
        }else {
            ToastUtil.showToast(mContext, errMsg);
        }
    }

    /**
     * 显示主播好友列表
     */
    protected void showInviteFriendsDialog(final int cellIndex){
        Log.d(TAG,"showInviteFriendsDialog");
        FragmentManager fragmentManager = getSupportFragmentManager();
        if(null != mIMHangoutRoomInItem && mIMHangoutRoomInItem.livingAnchorList != null && mIMHangoutRoomInItem.livingAnchorList.size() > 0){
            IMHangoutAnchorItem item = mIMHangoutRoomInItem.livingAnchorList.get(0);
            HangoutInviteFriendsDialogFragment.showDialog(fragmentManager, item.anchorId, item.nickName, new HangoutInviteFriendsDialogFragment.OnHangoutInviteFriendsDialogClickListener() {
                @Override
                public void onInviteClick(HangoutAnchorInfoItem item) {
                    //点击邀请处理
                    Log.d(TAG,"showInviteFriendsDialog onInviteClick item anchorId: " + item.anchorId);
                    vedioWindowManager.sendInvitation(mIMHangoutRoomInItem.roomId, item.anchorId, item.photoUrl, item.nickName, null, cellIndex);
                }
            });
        }
    }

    @Override
    public void OnRecvDealInvitationHangoutNotice(final IMDealInviteItem item) {
        super.OnRecvDealInvitationHangoutNotice(item);
        Log.i(TAG,"OnRecvDealInvitationHangoutNotice:" + item.anchorId + ",type:" +item.type);
        if(item.type == IMDealInviteItem.IMAnchorReplyInviteType.Reject
            || item.type == IMDealInviteItem.IMAnchorReplyInviteType.OutTime
            ||item.type == IMDealInviteItem.IMAnchorReplyInviteType.Cancel
            ||item.type == IMDealInviteItem.IMAnchorReplyInviteType.NoCredit
            ||item.type == IMDealInviteItem.IMAnchorReplyInviteType.Busy){
            //主播进不来，还原待邀请界面
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    vedioWindowManager.switchWait2InviteStatus(item.anchorId);
                }
            });
        }
    }

    @Override
    public void OnRecvAnchorCountDownEnterHangoutRoomNotice(final IMHangoutCountDownItem item) {
        super.OnRecvAnchorCountDownEnterHangoutRoomNotice(item);
        Log.i(TAG,"OnRecvAnchorCountDownEnterHangoutRoomNotice:" + item.leftSecond);

        if(!isCurrentRoom(item.roomId)){
            return;
        }
        //接受到主播即将从公开或者私密直播间倒计时进入hangout直播间，界面展示倒计时提示
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                IMUserBaseInfoItem imUserBaseInfoItem = null;
                if(null != mIMManager){
                    imUserBaseInfoItem = mIMManager.getUserInfo(item.anchorId);
                }
                if(null != imUserBaseInfoItem && null != vedioWindowManager ){// && !vedioWindowManager.checkIsOnLine(item.anchorId)){
                    Log.d(TAG,"OnRecvAnchorCountDownEnterRoomNotice-更新倒计时状态");
                    vedioWindowManager.switchAnchorComingStatus(item.anchorId,imUserBaseInfoItem.photoUrl,
                            imUserBaseInfoItem.nickName,HangOutVedioWindow.AnchorComingType.Anchor_Coming_After_Expires,item.leftSecond, null);
                }
            }
        });
    }

    /**
     * 主播推荐好友
     * @param friendId
     * @param friendNickName
     * @param friendPhotoUrl
     */
    private void onAnchorRecommand(String friendId, String friendNickName, String friendPhotoUrl){
        vedioWindowManager.sendInvitation(mIMHangoutRoomInItem.roomId, friendId, friendPhotoUrl, friendNickName, null, 0);
    }

    /**
     * 主播敲门事件
     * @param knockId
     */
    private void onAnchorKnock(String friendId, String friendNickName, String friendPhotoUrl, String knockId){
        //女士敲门男士已经确认
        vedioWindowManager.sendOpenDoor(knockId, friendId, friendNickName, friendPhotoUrl, new HangOutVedioWindowManager.KnockEventListener() {
            @Override
            public void onOpenDoor(boolean isSuccess, int httpErrorCode, String errorMsg) {
                if(!isSuccess){
                    if(IntToEnumUtils.intToHttpErrorType(httpErrorCode) == HttpLccErrType.HTTP_LCC_ERR_NO_CREDIT){
                        //点数不足，充值
                        showCreditNoEnoughDialog(R.string.hangout_open_door_no_credits_tip);
                    }else{
                        //请求返回失败，弹出提示
                        ToastUtil.showToast(mContext, errorMsg);
                    }
                }
            }
        });
    }

    //------------------------------推荐/邀请主播 end--------------------------------------

    @Override
    public void onVedioWindowClick(int index, HangoutVedioWindowObj obj, boolean isStreaming) {
        Log.d(TAG,"onVedioWindowClick-index:"+index+" obj:"+obj+" isStreaming:"+isStreaming
                +" lastScaleVedioWindowIndex0:"+lastScaleVedioWindowIndex);
//        if(!hideInputSoftView() && null != obj && isStreaming){
//            if(obj.isUserSelf){
//                //主播自己就展示切换摄像头按钮
//                if(null != vedioWindowManager){
//                    vedioWindowManager.setCameraCanSwitch(obj.targetUserId, true);
//                }
//            }
////            else{
////                if(obj.isManUser){
////                    showManInfoDialog();
////                }else{
////                    showOtherAnchorInfoDialog(obj.targetUserId);
////                }
////            }
//        }
    }

    @Override
    public void onOpenVideoClicked() {
        //第一次开启推流，需要确认
        if(doCheckIsManPushFirstTime()){
            //ios风格弹窗
//            DialogUIUtils.showAlert(mContext, "",
//                    getString(R.string.hangout_pust_video_tips),
//                    getString(R.string.common_btn_cancel),
//                    getString(R.string.common_btn_ok),
//                    R.color.live_dialog_default_btn_txt,
//                    R.color.live_dialog_high_light_btn_txt,
//                    true,
//                    true,
//                    new DialogUIListener() {
//                        @Override
//                        public void onPositive() {
//
//                        }
//
//                        @Override
//                        public void onNegative() {
//                            //观众开始推流--先检测权限
//                            checkPermissions();
//                        }
//                    }
//            ).show();

            //直播风格弹窗
            showSimpleTipsDialog(R.string.hangout_pust_video_tips, R.string.common_btn_cancel, R.string.common_btn_ok, new SimpleDoubleBtnTipsDialog.OnTipsDialogBtnClickListener() {
                @Override
                public void onCancelBtnClick() {

                }

                @Override
                public void onConfirmBtnClick() {
                    //观众开始推流--先检测权限
                    checkPermissions();
                }
            });
        }else{
            //观众开始推流--先检测权限
            checkPermissions();
        }
    }

    @Override
    public void onCloseVideoClicked() {
        //观众停止推流
        stopVideoPush();
    }

    /**
     * 私密直播权限检查
     */
    private void checkPermissions(){
        PermissionManager permissionManager = new PermissionManager(mContext, new PermissionManager.PermissionCallback() {
            @Override
            public void onSuccessful() {
//                mManPushDisconnect = false;
                //观众开始推流
                //调接口取地址
                startVideoPush();

            }

            @Override
            public void onFailure() {
                //TODO 无权限提示
            }
        });

        permissionManager.requestVideo();
    }

    @Override
    protected void onStartVideoPushSuccess(final String[] manPushUrl) {
        Log.i(TAG, "onStartVideoPushSuccess");

        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                vedioWindowManager.startLive(loginItem.userId, manPushUrl);
            }
        });
    }

    @Override
    protected void onStartVideoPushFail(final IMClientListener.LCC_ERR_TYPE errType,final String errMsg) {
        Log.i(TAG, "onStartVideoPushFail");
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (errType == IMClientListener.LCC_ERR_TYPE.LCC_ERR_NO_CREDIT
                    || errType == IMClientListener.LCC_ERR_TYPE.LCC_ERR_NO_CREDIT_HANGOUT_DOUBLE_VIDEO){
                    showCreditNoEnoughDialog(R.string.hangout_pust_no_credit_tips);
                }else {
                    ToastUtil.showToast(mContext, errMsg);
                }
            }
        });
    }

    @Override
    protected void onStopVideoPushSuccess() {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                vedioWindowManager.stopLive(loginItem.userId);
            }
        });
    }

    //    private AudienceInfoDialog audienceInfoDialog;?

    private void showManInfoDialog(){
//        Log.d(TAG,"showManInfoDialog");
//        if(null == audienceInfoDialog){
//            audienceInfoDialog = new AudienceInfoDialog(this);
//            audienceInfoDialog.setOutSizeTouchHasChecked(true);
//        }
//
//        audienceInfoDialog.setInvitePriLiveBtnVisible(false);
//        audienceInfoDialog.show(new AudienceInfoItem(mIMHangoutRoomInItem.manId,mIMHangoutRoomInItem.manNickName,
//                mIMHangoutRoomInItem.manPhotoUrl,null,null,mIMHangoutRoomInItem.manLevel,
//                null,false));
//
//        /**在show之后,加上如下这段代码就能解决宽被压缩的bug*/
//        WindowManager windowManager = getWindowManager();
//        Display defaultDisplay = windowManager.getDefaultDisplay();
//        WindowManager.LayoutParams attributes = audienceInfoDialog.getWindow().getAttributes();
//        attributes.width = defaultDisplay.getWidth();
//        attributes.gravity = Gravity.BOTTOM;
//        audienceInfoDialog.getWindow().setAttributes(attributes);
    }

    @Override
    public void onVedioWindowLongClick(int index) {
        Log.d(TAG,"onVedioWindowLongClick-index:"+index+" lastScaleVedioWindowIndex0:"+lastScaleVedioWindowIndex);
//        //如果lastScaleVedioWindowIndex!=0，则是有格子被放大了，要进行缩小
//        if(0 != lastScaleVedioWindowIndex && null != vedioWindowManager){
//            //有则缩小之并重置lastScaleVedioWindowIndex
//            //先不考虑放大缩小动画，先直接放大和缩小来,后面在将动画加入
//            v_float.removeAllViews();
//            v_float.setVisibility(View.GONE);
//
//            if(null != vedioWindowManager && vedioWindowManager.getManIndex() == lastScaleVedioWindowIndex) {
//                //如果点的是男士推流格子
//                vedioWindowManager.change2Normal(lastScaleVedioWindowIndex);
//            }else {
//                //如果是女士拉流格子
//                //替换视频渲染器
//                vedioWindowManager.changeRender2Small(lastScaleVedioWindowIndex);
//            }
//            lastScaleVedioWindowIndex = 0;
//        }else{
//            //否则放大index对应的窗格
//            //放大蒙层
//            v_float.bringToFront();
//            v_float.setVisibility(View.VISIBLE);
//            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) {
//                ViewParent viewParent = v_float.getParent();
//                if(null != viewParent && viewParent instanceof  View){
//                    View parentView = (View)viewParent;
//                    parentView.requestLayout();
//                    parentView.invalidate();
//                }
//            }
//            //放大视频格子
//            if(null != vedioWindowManager && vedioWindowManager.getManIndex() == index){
//                //如果点的是男士推流格子
//                //直接放大
//                vedioWindowManager.change2Large(index);
//            }else{
//                //如果是女士拉流格子
//                //替换视频渲染器
//                vedioWindowManager.changeRender2Large(index, showExpandSurfaceView());
//            }
//            lastScaleVedioWindowIndex = index;
//        }

        if(index == lastScaleVedioWindowIndex){
            //长按的是刚才放大的， 就缩小
            showNormalSurfaceView();
        }else {
            //放大
            showLargeSurfaceView(index);
        }


        Log.d(TAG,"onVedioWindowLongClick-lastScaleVedioWindowIndex1:"+lastScaleVedioWindowIndex);
    }

    /**
     * 放大某个格子
     * @param index
     */
    private void showLargeSurfaceView(int index){
        lastScaleVedioWindowIndex = index;
        //放大蒙层
        v_float.bringToFront();
        v_float.setVisibility(View.VISIBLE);
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) {
            ViewParent viewParent = v_float.getParent();
            if(null != viewParent && viewParent instanceof  View){
                View parentView = (View)viewParent;
                parentView.requestLayout();
                parentView.invalidate();
            }
        }
        //放大视频格子
        if(null != vedioWindowManager && vedioWindowManager.getManIndex() == index){
            //如果点的是男士推流格子
            //直接放大
            vedioWindowManager.change2Large(index);
        }else{
            //如果是女士拉流格子
            //替换视频渲染器
            int gravity;
            switch (index){
                case 1:
                    gravity = Gravity.TOP | Gravity.LEFT;
                    break;
                case 2:
                    gravity = Gravity.TOP | Gravity.RIGHT;
                    break;
                case 3:
                    gravity = Gravity.BOTTOM | Gravity.LEFT;
                    break;
                default:
                    gravity = Gravity.TOP | Gravity.LEFT;
                    break;
            }
            vedioWindowManager.changeRender2Large(index, showExpandSurfaceView(gravity), fl_video);
        }
    }

    /**
     * 还原某个格子
     */
    private void showNormalSurfaceView(){
        fl_video.removeAllViews();
        v_float.setVisibility(View.GONE);

        if(null != vedioWindowManager && vedioWindowManager.getManIndex() == lastScaleVedioWindowIndex) {
            //如果点的是男士推流格子
            vedioWindowManager.change2Normal(lastScaleVedioWindowIndex);
        }else {
            //如果是女士拉流格子
            //替换视频渲染器
            vedioWindowManager.changeRender2Small(lastScaleVedioWindowIndex);
        }
        lastScaleVedioWindowIndex = 0;
    }

    /**
     * 建立一个临时GLSurfaceView,用于放大显示某个拉流视频
     */
    private GLSurfaceView showExpandSurfaceView(int gravity){
        GLSurfaceView tempSurfaceView = new GLSurfaceView(mContext);

//        FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(DisplayUtil.getScreenWidth(mContext) *3/4, DisplayUtil.getScreenWidth(mContext)*3/4);
//        layoutParams.gravity = gravity;
        FrameLayout.LayoutParams layoutParams = (FrameLayout.LayoutParams)fl_video.getLayoutParams();
        layoutParams.width = DisplayUtil.getScreenWidth(mContext) *3/4;
        layoutParams.height = DisplayUtil.getScreenWidth(mContext) *3/4;
        layoutParams.gravity = gravity;

        tempSurfaceView.setZOrderMediaOverlay(true);

        fl_video.addView(tempSurfaceView, layoutParams);

        return tempSurfaceView;
    }

    /**
     * 调整view高度, 解决背景在AdjustSize时会被推上去问题
     */
    @SuppressLint("WrongViewCast")
    private void setSizeUnChanageViewParams(){
        int statusBarHeight = DisplayUtil.getStatusBarHeight(mContext);
        if(statusBarHeight > 0){
//            int activityHeight = DisplayUtil.getActivityHeight(mContext) - statusBarHeight;
            // 2019/5/25 Hardy  兼容带虚拟导航栏的全面屏手机，需要减去导航栏高度
            int activityHeight = DisplayUtil.getScreenHeight(mContext) - statusBarHeight - DisplayUtil.getNavigationBarHeight(mContext);

            LinearLayout.LayoutParams params = (LinearLayout.LayoutParams)findViewById(R.id.include_im_body).getLayoutParams();
            params.height = activityHeight;
            FrameLayout.LayoutParams params1 = (FrameLayout.LayoutParams)findViewById(R.id.fl_imMsgContainer).getLayoutParams();
            params1.height = activityHeight-DisplayUtil.getScreenWidth(mContext);
            //设置固定宽高，解决键盘弹出挤压问题
            FrameLayout.LayoutParams celebGiftParams = (FrameLayout.LayoutParams)sdv_celebGift.getLayoutParams();
            celebGiftParams.height = activityHeight;
            Log.d(TAG,"setSizeUnChanageViewParams-activityHeight:"+activityHeight+" imMsgConHeight:"+params1.height);
        }
    }

    @Override
    public void onSoftKeyboardShow() {
        super.onSoftKeyboardShow();
        //软件盘弹起的时候 显示表情按钮 隐藏礼物按钮
        iv_emojiSwitch.setVisibility(View.GONE);
        iv_gift.setVisibility(View.GONE);
        iv_vedioControll.setVisibility(View.GONE);
        lrsv_roomBody.setScrollFuncEnable(false);
    }

    @Override
    public void onSoftKeyboardHide() {
        super.onSoftKeyboardHide();
        //软件盘隐藏的时候 显示礼物按钮隐藏表情按钮
        iv_gift.setVisibility(View.VISIBLE);
        iv_vedioControll.setVisibility(View.VISIBLE);
        iv_emojiSwitch.setVisibility(View.GONE);
        if(lv_chatters.getVisibility() == View.VISIBLE){
            lv_chatters.setVisibility(View.GONE);
            iv_audienceIndicator.setSelected(true);
        }
        lrsv_roomBody.setScrollFuncEnable(true);
    }

    @Override
    public void OnEnterHangoutRoom(int reqId, final boolean success,final IMClientListener.LCC_ERR_TYPE errType,
                                   final String errMsg, final IMHangoutRoomItem hangoutRoomItem) {
        super.OnEnterHangoutRoom(reqId, success, errType, errMsg, hangoutRoomItem);
        Log.i(TAG,"OnEnterHangoutRoom:" + success + ",errType:" + errType.name() + ",errMsg:" + errMsg);
        if (success && null != hangoutRoomItem && !isCurrentRoom(hangoutRoomItem.roomId)) {
            return;
        }
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
            if(!success){
                //Samson:断线重连，重新调用RoomIn命令接口返回失败，视作退出直播间
                //直接跳转到直播间结束页面
                endLiveRoom(errType, errMsg);
                return;
            }
            refreshHangOutVedioStatus();
            onDisconnectRoomIn();
            }
        });
    }

    /**
     * 刷新直播间四宫格状态
     */
    private void refreshHangOutVedioStatus(){
        if(null != vedioWindowManager.getUserIdIndexMap() && null != loginItem){
            //1.本地缓存list中的userid不存在于服务器的list中,剔除
            List<String> toDelUserIds = new ArrayList<>();
            for (String userId : vedioWindowManager.getUserIdIndexMap().keySet()){
//                //不是男士也不是主播自己
//                if(!mIMHangoutRoomInItem.manId.equals(userId) && !loginItem.userId.equals(userId)){
                //不是自己
                if(!loginItem.userId.equals(userId)){
                    if(null != mIMHangoutRoomInItem.livingAnchorList && mIMHangoutRoomInItem.livingAnchorList.size() > 0){
                        //不在otherAnchorList列表中则剔除
                        boolean isToDel = true;
                        for(IMHangoutAnchorItem anchorItem : mIMHangoutRoomInItem.livingAnchorList){
                            if(anchorItem.anchorId.equals(userId)){
                                isToDel = false;
                                break;
                            }
                        }
                        if(isToDel){
                            //避免出现java.util.ConcurrentModificationException
                            toDelUserIds.add(userId);
                        }
                    }
                }
            }
            for(String userId: toDelUserIds){
                vedioWindowManager.switchWait2InviteStatus(userId);
            }
            //2.服务器list中的userid不存在与本地缓存，那么添加到本地,一并插入并更新状态
            //3.更新窗格礼物数据
            initHangOutVeidoStatus();
        }
    }

    @Override
    protected void onDisconnectRoomIn() {
        super.onDisconnectRoomIn();
        hasToastDisconnected = false;
    }

    @Override
    protected void preEndLiveRoom(String description) {
        super.preEndLiveRoom(description);
        hasToastDisconnected = true;
//        if(null != mIMHangoutRoomInItem && !TextUtils.isEmpty(mIMHangoutRoomInItem.manPhotoUrl)){
//            HangOutRoomEndActivity.show(this,mIMHangoutRoomInItem.manPhotoUrl,mIMHangoutRoomInItem.manNickName, description);
//        }
    }

    @Override
    public void stopLSPubilsher() {
        super.stopLSPubilsher();
        if(null != vedioWindowManager){
            vedioWindowManager.stopLSPubilsher();
        }
    }

//    @Override
//    public void OnControlManPushHangout(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg,final String[] manPushUrl) {
//        super.OnControlManPushHangout( reqId,  success,  errType,  errMsg,  manPushUrl);
//        Log.i(TAG,"OnControlManPushHangout");
//
//        if(success){
//            //男士开始推流
//            runOnUiThread(new Runnable() {
//                @Override
//                public void run() {
//                    vedioWindowManager.startLive(loginItem.userId, manPushUrl);
//                }
//            });
//        }
//    }

    @Override
    public void OnRecvChangeVideoUrl(String roomId, boolean isAnchor,final String[] playUrls,final String userId) {
        super.OnRecvChangeVideoUrl(roomId,  isAnchor,  playUrls,  userId);
        Log.d(TAG,"OnRecvChangeVideoUrl-roomId:"+roomId+" isAnchor:"+isAnchor+" playUrl:"+playUrls+" userId:"+userId);
        //主播端开始拉流
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                vedioWindowManager.startLive(userId, playUrls);
            }
        });
    }
//
//    @Override
//    public void OnRecvAnchorOtherInviteNotice(final IMOtherInviteItem item) {
//        super.OnRecvAnchorOtherInviteNotice(item);
//        if(!isCurrentRoom(item.roomId)){
//            return;
//        }
//        runOnUiThread(new Runnable() {
//            @Override
//            public void run() {
//                //如果主播已经在线，则不处理，否则照常处理
//                if(null != vedioWindowManager && !vedioWindowManager.checkIsOnLine(item.anchorId)){
//                    vedioWindowManager.switchAnchorComingStatus(item.anchorId,item.photoUrl,
//                            item.nickName,HangOutVedioWindow.AnchorComingType.Man_Inviting, item.expire);
//                }
//
//            }
//        });
//    }
//
//    @Override
//    public void OnRecvAnchorDealKnockRequestNotice(final IMKnockRequestItem item) {
//        super.OnRecvAnchorDealKnockRequestNotice(item);
//        if(!isCurrentRoom(item.roomId)){
//            return;
//        }
//        runOnUiThread(new Runnable() {
//            @Override
//            public void run() {
//                //item.userId主播不在线且男士开门,切换状态
//                if(null != vedioWindowManager && !vedioWindowManager.checkIsOnLine(item.userId)
//                        && item.type == IMKnockRequestItem.IMAnchorKnockType.Agree){
//                    vedioWindowManager.switchAnchorComingStatus(item.userId,item.photoUrl,item.nickName,
//                            HangOutVedioWindow.AnchorComingType.Man_Accepted_Anchor_Knock,0);
//                }
//            }
//        });
//    }
//
//    @Override
//    public void OnRecvHangoutInteractiveVideoNotice(String roomId, String userId, String nickname,
//                                                    String avatarImg,
//                                                    IMClientListener.IMVideoInteractiveOperateType operateType,
//                                                    String[] pushUrls) {
//        super.OnRecvHangoutInteractiveVideoNotice(roomId, userId, nickname, avatarImg, operateType, pushUrls);
//        if(!isCurrentRoom(roomId)){
//            return;
//        }
//        onManInterVedioStatusChanged(roomId, userId, nickname, operateType, pushUrls);
//    }
//
//    /**
//     * 男士互动视频状态发生更改 打开or关闭
//     * @param roomId
//     * @param userId
//     * @param nickname
//     * @param operateType
//     * @param pushUrls
//     */
//    private void onManInterVedioStatusChanged(String roomId, final String userId, String nickname,
//                                              final IMClientListener.IMVideoInteractiveOperateType operateType,
//                                              final String[] pushUrls) {
//        final boolean isOpen = operateType==IMClientListener.IMVideoInteractiveOperateType.Start;
//        runOnUiThread(new Runnable() {
//            @Override
//            public void run() {
//                if(null != vedioWindowManager){
//                    if(null != pushUrls && pushUrls.length>0 && isOpen){
//                        //1.打开 则将男士cell切换到视频流传输状态
//                        vedioWindowManager.startLive(userId,pushUrls);
//                    }else if(operateType==IMClientListener.IMVideoInteractiveOperateType.Close){
//                        //2.关闭，则将男士cell切换到封面头像状态
//                        vedioWindowManager.stopLive(userId);
//                    }
//                }
//            }
//        });
//
//        //聊天列表插入普通公告
//        String message = getResources().getString(isOpen ? R.string.private_live_interactive_vedio_open
//                : R.string.private_live_interactive_vedio_close,nickname);
//        IMSysNoticeMessageContent msgContent = new IMSysNoticeMessageContent(message,null,
//                IMSysNoticeMessageContent.SysNoticeType.Normal);
//        IMMessageItem msgItem = new IMMessageItem(roomId,mIMManager.mMsgIdIndex.getAndIncrement(),"",
//                IMMessageItem.MessageType.SysNotice,msgContent);
//        sendMessageUpdateEvent(msgItem);
//    }

    /**
     * 视频格子回调事件
     * @param index
     * @param hasConnected
     */
    @Override
    public void onPullVedioConnect(int index, boolean hasConnected) {
        Log.d(TAG,"onPullVedioConnect-index:"+index+" hasConnected:"+hasConnected);

    }

    /**
     * 视频格子回调事件
     */
    @Override
    public void onPushVedioConnect(int index, boolean hasConnected) {
        Log.d(TAG,"onPushVedioConnect-index:"+index+" hasConnected:"+hasConnected);
        if(!hasConnected) {
            onPushStreamDisconnect();
        }else{
            hasToastDisconnected = false;
        }
    }

    private boolean hasToastDisconnected = false;

    @Override
    public void onPushStreamDisconnect() {
        super.onPushStreamDisconnect();
//        mManPushDisconnect = true;
        if(!hasToastDisconnected){
            //仅仅是IM断线，Toast提示
            if(isActivityVisible()) {
                showToast(getResources().getString(R.string.live_push_stream_network_poor));
            }
            hasToastDisconnected = true;
        }
    }

    @Override
    public void OnRecvEnterHangoutRoomNotice(final IMRecvEnterRoomItem item) {
        super.OnRecvEnterHangoutRoomNotice(item);
        Log.i(TAG,"OnRecvEnterHangoutRoomNotice:" + item.nickName);
        // 主播进入
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
            if(null != item && null != vedioWindowManager){
                int cellIndex = vedioWindowManager.switchInvitedStatus(item.userId,item.photoUrl,item.nickName, null , item.pullUrl);
                if(null != item.bugForList && item.bugForList.length>0){
                    vedioWindowManager.initRecvBarGiftData(item);
                }

                //加入@列表
                doAddToTargetList(cellIndex, item);

            }
            }
        });
    }

    @Override
    public void OnRecvLeaveHangoutRoomNotice(final IMRecvLeaveRoomItem item) {
        super.OnRecvLeaveHangoutRoomNotice(item);
        Log.i(TAG,"OnRecvLeaveHangoutRoomNotice:" + item.nickName);
        // 主播离开
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if(null != vedioWindowManager) {
                    vedioWindowManager.switchWait2InviteStatus(item.userId);
                    //从礼物弹出框中去掉人头
                    removeAnchorInGiftDialog(item);
                    //从聊天@谁列表中去掉
                    List<AudienceInfoItem> audienceInfoItems = chatterSelectorAdapter.getList();
                    for(AudienceInfoItem infoItem: audienceInfoItems){
                        if(infoItem.userId.equals(item.userId)){
                            chatterSelectorAdapter.removeItem(infoItem);
                            break;
                        }
                    }
                }
            }
        });
    }
}
