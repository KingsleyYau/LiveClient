package com.qpidnetwork.anchor.liveshow.liveroom;


import android.annotation.SuppressLint;
import android.os.Build;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.Display;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewParent;
import android.view.WindowManager;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.framework.canadapter.CanOnItemListener;
import com.qpidnetwork.anchor.httprequest.item.AudienceInfoItem;
import com.qpidnetwork.anchor.httprequest.item.EmotionItem;
import com.qpidnetwork.anchor.httprequest.item.GiftItem;
import com.qpidnetwork.anchor.httprequest.item.LiveRoomType;
import com.qpidnetwork.anchor.im.listener.IMClientListener;
import com.qpidnetwork.anchor.im.listener.IMDealInviteItem;
import com.qpidnetwork.anchor.im.listener.IMHangoutRoomItem;
import com.qpidnetwork.anchor.im.listener.IMKnockRequestItem;
import com.qpidnetwork.anchor.im.listener.IMMessageItem;
import com.qpidnetwork.anchor.im.listener.IMOtherAnchorItem;
import com.qpidnetwork.anchor.im.listener.IMOtherInviteItem;
import com.qpidnetwork.anchor.im.listener.IMRecvEnterRoomItem;
import com.qpidnetwork.anchor.im.listener.IMRecvLeaveRoomItem;
import com.qpidnetwork.anchor.im.listener.IMRoomInItem;
import com.qpidnetwork.anchor.im.listener.IMSysNoticeMessageContent;
import com.qpidnetwork.anchor.im.listener.IMUserBaseInfoItem;
import com.qpidnetwork.anchor.liveshow.datacache.file.FileCacheManager;
import com.qpidnetwork.anchor.liveshow.liveroom.audience.AudienceInfoDialog;
import com.qpidnetwork.anchor.liveshow.liveroom.audience.ChatterSelectorAdapter;
import com.qpidnetwork.anchor.liveshow.liveroom.gift.GiftImageType;
import com.qpidnetwork.anchor.liveshow.liveroom.gift.NormalGiftManager;
import com.qpidnetwork.anchor.liveshow.liveroom.gift.advance.BigGiftAnimItem;
import com.qpidnetwork.anchor.liveshow.liveroom.gift.advance.BigGiftAnimManager;
import com.qpidnetwork.anchor.liveshow.liveroom.vedio.HangOutVedioController;
import com.qpidnetwork.anchor.liveshow.liveroom.vedio.HangOutVedioWindow;
import com.qpidnetwork.anchor.liveshow.liveroom.vedio.HangoutVedioWindowObj;
import com.qpidnetwork.anchor.utils.DisplayUtil;
import com.qpidnetwork.anchor.utils.Log;
import com.qpidnetwork.anchor.utils.StringUtil;
import com.qpidnetwork.anchor.utils.SystemUtils;
import com.qpidnetwork.anchor.view.LiveRoomScrollView;
import com.qpidnetwork.anchor.view.SoftKeyboradListenFrameLayout;

import java.util.ArrayList;
import java.util.List;

/**
 * Hang Out直播间
 * Created by Harry Wei on 2018/4/18.
 */

public class HangOutLiveRoomActivity extends BaseHangOutLiveRoomActivity implements HangOutVedioWindow.OnAddInviteClickListener,
        HangOutVedioWindow.VedioClickListener, HangOutVedioController.OnControllerEventListener, HangOutVedioWindow.VedioDisconnectListener {

    private LiveRoomScrollView lrsv_roomBody;

    //四个视频窗格
    private View view_vedioWindows;
    private HangOutVedioWindowManager vedioWindowManager;
    //0就代表没有窗格放大，否则标识当前有放大的窗格
    private int lastScaleVedioWindowIndex = 0;
    private View v_float;
    //视频控制面板
    private ImageView iv_vedioControll;
    private HangOutVedioController hovc_container;
    //庆祝礼物
    private View fl_celebGiftAnim;
    private SimpleDraweeView sdv_celebGift;
    protected BigGiftAnimManager celebGiftManager;

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
    private static int liveMsgMaxLength = 10;
    private int lastTxtChangedStart = 0;
    private int lastTxtChangedNumb = 0;
    private ImageView iv_emojiSwitch;
    private View iv_gift;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        TAG = HangOutLiveRoomActivity.class.getSimpleName();
        setContentView(R.layout.activity_live_room_hangout);
        initData();
        initViews();
        initHangOutVeidoStatus();
        //直播中保持屏幕点亮不熄屏
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON, WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
    }

    /**
     * 初始化四宫格已经接收到的bar礼物列表
     */
    private void initHangOutRecvBarGiftData(){
        if(null != vedioWindowManager){
            vedioWindowManager.initRecvBarGiftData(mIMHangOutRoomItem.buyforList);
        }
    }

    /**
     * 初始化直播间男士/主播状态
     */
    private void initHangOutVeidoStatus() {
        if(null != mIMHangOutRoomItem && null != loginItem && null != vedioWindowManager){
            //初始化男士
            vedioWindowManager.switchInvitedStatus(mIMHangOutRoomItem.manId,mIMHangOutRoomItem.manPhotoUrl,
                    mIMHangOutRoomItem.manNickName,mIMHangOutRoomItem.manVideoUrl);

            //初始化主播
            vedioWindowManager.switchInvitedStatus(loginItem.userId,loginItem.photoUrl,
                    loginItem.nickName,mIMHangOutRoomItem.pushUrl);
            //初始化其他主播
            if(null != mIMHangOutRoomItem.otherAnchorList){
                for(IMOtherAnchorItem imOtherAnchorItem : mIMHangOutRoomItem.otherAnchorList){
                    //本地缓存各主播信息
                    if(null != mIMManager){
                        mIMManager.updateOrAddUserBaseInfo(new IMUserBaseInfoItem(imOtherAnchorItem.anchorId,
                                imOtherAnchorItem.nickName,imOtherAnchorItem.photoUrl));
                    }

                    if(imOtherAnchorItem.anchorStatus == IMOtherAnchorItem.IMAnchorStatus.Online){
                        //主播已经进入直播间
                        vedioWindowManager.switchInvitedStatus(imOtherAnchorItem.anchorId,imOtherAnchorItem.photoUrl,
                                imOtherAnchorItem.nickName,imOtherAnchorItem.videoUrl);
                    }else if(imOtherAnchorItem.anchorStatus == IMOtherAnchorItem.IMAnchorStatus.Invitation
                            || imOtherAnchorItem.anchorStatus == IMOtherAnchorItem.IMAnchorStatus.InviteConfirm){
                        //男士邀请中或女士已经接受男士邀请
                        vedioWindowManager.switchAnchorComingStatus(imOtherAnchorItem.anchorId,imOtherAnchorItem.photoUrl,
                                imOtherAnchorItem.nickName,
                                HangOutVedioWindow.AnchorComingType.Man_Inviting,0);
                    }else if(imOtherAnchorItem.anchorStatus == IMOtherAnchorItem.IMAnchorStatus.KnockConfirm){
                        //女士敲门男士已经确认
                        vedioWindowManager.switchAnchorComingStatus(imOtherAnchorItem.anchorId,imOtherAnchorItem.photoUrl,
                                imOtherAnchorItem.nickName,
                                HangOutVedioWindow.AnchorComingType.Man_Accepted_Anchor_Knock,0);
                    }else if(imOtherAnchorItem.anchorStatus == IMOtherAnchorItem.IMAnchorStatus.ReciprocalEnter){
                        //女士同意男士邀请倒计时进入中
                        vedioWindowManager.switchAnchorComingStatus(imOtherAnchorItem.anchorId,imOtherAnchorItem.photoUrl,
                                imOtherAnchorItem.nickName,
                                HangOutVedioWindow.AnchorComingType.Anchor_Coming_After_Expires,
                                imOtherAnchorItem.leftSeconds);
                    }
                }
            }
            //初始化各窗格吧台礼物数据列表
            initHangOutRecvBarGiftData();
        }
    }

    public void initData(){
        super.initData();
        chatterInfoItems = new ArrayList<>();
        defaultAudienceInfoItem = new AudienceInfoItem("0","All","",
                null,null,0,"",false);
        lastSelectedAudienceInfoItem = defaultAudienceInfoItem;
        chatterInfoItems.add(lastSelectedAudienceInfoItem);
        //添加男士信息
        chatterInfoItems.add(new AudienceInfoItem(mIMHangOutRoomItem.manId,mIMHangOutRoomItem.manNickName,
                mIMHangOutRoomItem.manPhotoUrl,null,null,mIMHangOutRoomItem.manLevel,null,false));
        //添加男士资料到本地缓存manager
        if(null != mIMManager){
            mIMManager.updateOrAddUserBaseInfo(new IMUserBaseInfoItem(mIMHangOutRoomItem.manId,
                    mIMHangOutRoomItem.manNickName,mIMHangOutRoomItem.manPhotoUrl));
        }
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
        lv_chatters = (ListView) findViewById(R.id.lv_chatters);
        chatterSelectorAdapter = new ChatterSelectorAdapter(this,R.layout.item_simple_list_chatter);
        lv_chatters.setAdapter(chatterSelectorAdapter);
        lv_chatters.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                chatterSelectorAdapter.notifyDataSetChanged();
                return false;
            }
        });
        lv_chatters.setVisibility(View.GONE);
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
        chatterSelectorAdapter.setList(chatterInfoItems);

        liveMsgMaxLength = getResources().getInteger(R.integer.liveMsgMaxLength);
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
                if(null != lastSelectedAudienceInfoItem
                        && !lastSelectedAudienceInfoItem.equals(defaultAudienceInfoItem)){
                    synchronized (chatterInfoItems){
                        boolean isManStillInRoom = false;
                        AudienceInfoItem audienceInfoItem = null;
                        for(int index=0; index<chatterInfoItems.size(); index++){
                            audienceInfoItem = chatterInfoItems.get(index);
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
            if(s.toString().length()>liveMsgMaxLength){
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
        vedioWindowManager = new HangOutVedioWindowManager(this,mIMHangOutRoomItem);
        vedioWindowManager.add(1,R.id.view_vedioWindow1);
        vedioWindowManager.add(2,R.id.view_vedioWindow2);
        vedioWindowManager.add(3,R.id.view_vedioWindow3);
        vedioWindowManager.add(4,R.id.view_vedioWindow4);
        //庆祝礼物界面
        sdv_celebGift = (SimpleDraweeView) findViewById(R.id.sdv_celebGift);
        sdv_celebGift.setVisibility(View.GONE);
        celebGiftManager = new BigGiftAnimManager(sdv_celebGift);
    }

    private void initRoomMsgList() {
        fl_imMsgContainer = findViewById(R.id.fl_imMsgContainer);
        fl_imMsgContainer.setOnClickListener(this);
        //消息列表
        liveRoomChatManager = new LiveRoomChatManager(this, IMRoomInItem.IMLiveRoomType.HangoutRoom,
                mIMHangOutRoomItem.manId,new RoomThemeManager());
        fl_msglist = findViewById(R.id.fl_msglist);
        fl_msglist.setClickable(true);
        liveRoomChatManager.init(this, fl_msglist);
        fl_msglist.setOnClickListener(this);
        liveRoomChatManager.setOnRoomMsgListClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Log.d(TAG, "OnRoomMsgListClickListener-isSoftInputOpen:" + isSoftInputOpen);
                hideInputSoftView();
            }
        });
    }

    private void initVedioControllView(int screenWidth) {
        iv_vedioControll = (ImageView) findViewById(R.id.iv_vedioControll);
        iv_vedioControll.setOnClickListener(this);
        iv_vedioControll.setVisibility(View.VISIBLE);
        hovc_container = (HangOutVedioController) findViewById(R.id.hovc_container);
        hovc_container.setVisibility(View.GONE);
        hovc_container.setListener(this);
        FrameLayout.LayoutParams containerLP = (FrameLayout.LayoutParams)hovc_container.getLayoutParams();
        containerLP.height = DisplayUtil.getScreenHeight(this)-screenWidth-DisplayUtil.getStatusBarHeight(this);
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);
        switch (v.getId()){
            case R.id.ll_audienceChooser:
            case R.id.tv_audienceNickname:
            case R.id.iv_audienceIndicator:
                //切换观众昵称列表的选择状态
                boolean hasAudienceListShowed = View.VISIBLE == lv_chatters.getVisibility();
                lv_chatters.setVisibility(hasAudienceListShowed ? View.GONE : View.VISIBLE);
                iv_audienceIndicator.setSelected(hasAudienceListShowed);
                break;
            case R.id.iv_gift:
                if(View.VISIBLE == lv_chatters.getVisibility()){
                    lv_chatters.setVisibility(View.GONE);
                    iv_audienceIndicator.setSelected(true);
                }else{
                    showHangoutGiftDialog();
                    iv_vedioControll.setVisibility(View.VISIBLE);
                    hovc_container.setVisibility(View.GONE);
                }
                break;
            case R.id.view_vedioWindows:
            case R.id.fl_imMsgContainer:
            case R.id.fl_msglist:
                hideInputSoftView();
                break;
            case R.id.iv_vedioControll:
                iv_vedioControll.setVisibility(View.GONE);
                hovc_container.setVisibility(View.VISIBLE);
                break;
            case R.id.v_float:
                if(!hideInputSoftView() && 0 != lastScaleVedioWindowIndex){
                    //有则缩小之并重置lastScaleVedioWindowIndex
                    //先不考虑放大缩小动画，先直接放大和缩小来,后面在将动画加入
                    if(null != vedioWindowManager && vedioWindowManager.change2Normal(lastScaleVedioWindowIndex)){
                        v_float.setVisibility(View.GONE);
                        lastScaleVedioWindowIndex = 0;
                    }
                }
                break;
            default:
                break;
        }
    }

    private boolean hideInputSoftView() {
        boolean result = false;
        if(null != audienceInfoDialog && audienceInfoDialog.isShowing()){
            audienceInfoDialog.dismiss();
            result = true;
        }else if(null != otherAnchorInfoDialog && otherAnchorInfoDialog.isShowing()){
            otherAnchorInfoDialog.dismiss();
            result = true;
        }else if(null != liveGiftDialog && liveGiftDialog.isShowing()){
            liveGiftDialog.dismiss();
            result = true;
        }else if(View.VISIBLE == lv_chatters.getVisibility()){
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
    }

    /**
     * 启动消息动画
     * @param toUid
     * @param msgItem fromId
     */
    public void launchGiftAnimByMessage(final String toUid, final IMMessageItem msgItem){
        super.launchGiftAnimByMessage(toUid,msgItem);
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
                        BigGiftAnimItem bigGiftAnimItem = new BigGiftAnimItem(localPath,
                                msgItem.giftMsgContent.giftNum, BigGiftAnimItem.BigGiftAnimType.CelebGift);
                        if(null != celebGiftManager){
                            celebGiftManager.addBigGiftAnimItem(bigGiftAnimItem);
                        }
                    }else{
                        Log.d(TAG,"launchAnimationByMessage-giftId:"+giftItem.id+" 对应的庆祝礼物webp文件本地未缓存!");
                        //不存在就下载
                        NormalGiftManager.getInstance().getGiftImage(giftItem.id, GiftImageType.BigAnimSrc, null);
                    }
                }else if(null != vedioWindowManager){
                        vedioWindowManager.updateVedioWindowGiftAnimData(toUid,msgItem,giftItem);
                }
            }
        });
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

        if(mIMHangOutRoomItem != null && mIMManager != null){
            mIMManager.outHangOutRoomAndClearFlag(mIMHangOutRoomItem.roomId);
        }
    }

    @Override
    public void onAddInviteClick(int index) {
        Log.d(TAG,"onAddInviteClick-index:"+index);
        if(!hideInputSoftView()){
            showRecommendDialog();
            iv_vedioControll.setVisibility(View.VISIBLE);
            hovc_container.setVisibility(View.GONE);
        }
    }

    @Override
    public void onVedioWindowClick(int index, HangoutVedioWindowObj obj, boolean isStreaming) {
        Log.d(TAG,"onVedioWindowClick-index:"+index+" obj:"+obj+" isStreaming:"+isStreaming
                +" lastScaleVedioWindowIndex0:"+lastScaleVedioWindowIndex);
        if(!hideInputSoftView() && null != obj && isStreaming){
            if(obj.isUserSelf){
                //主播自己就展示切换摄像头按钮
                if(null != vedioWindowManager){
                    vedioWindowManager.changeCameraSwitchVisibility(obj.targetUserId);
                }
            }else{
                if(obj.isManUser){
                    showManInfoDialog();
                }else{
                    showOtherAnchorInfoDialog(obj.targetUserId);
                }
            }
        }
    }

    private AudienceInfoDialog audienceInfoDialog;

    private void showManInfoDialog(){
        Log.d(TAG,"showManInfoDialog");
        if(null == audienceInfoDialog){
            audienceInfoDialog = new AudienceInfoDialog(this);
            audienceInfoDialog.setOutSizeTouchHasChecked(true);
        }

        audienceInfoDialog.show(new AudienceInfoItem(mIMHangOutRoomItem.manId,mIMHangOutRoomItem.manNickName,
                mIMHangOutRoomItem.manPhotoUrl,null,null,mIMHangOutRoomItem.manLevel,
                null,false));
        audienceInfoDialog.setInvitePriLiveBtnVisible(View.INVISIBLE);
        /**在show之后,加上如下这段代码就能解决宽被压缩的bug*/
        WindowManager windowManager = getWindowManager();
        Display defaultDisplay = windowManager.getDefaultDisplay();
        WindowManager.LayoutParams attributes = audienceInfoDialog.getWindow().getAttributes();
        attributes.width = defaultDisplay.getWidth();
        attributes.gravity = Gravity.BOTTOM;
        audienceInfoDialog.getWindow().setAttributes(attributes);
    }

    @Override
    public void onVedioWindowLongClick(int index) {
        Log.d(TAG,"onVedioWindowLongClick-index:"+index+" lastScaleVedioWindowIndex0:"+lastScaleVedioWindowIndex);
        //1.判断当前是否有其他窗格处于放大状态
        if(0 != lastScaleVedioWindowIndex && null != vedioWindowManager && vedioWindowManager.change2Normal(lastScaleVedioWindowIndex)){
            //有则缩小之并重置lastScaleVedioWindowIndex
            //先不考虑放大缩小动画，先直接放大和缩小来,后面在将动画加入
            v_float.setVisibility(View.GONE);
            lastScaleVedioWindowIndex = 0;
        }else{
            //否则放大index对应的窗格
            v_float.bringToFront();
            v_float.setVisibility(View.VISIBLE);
            if (Build.VERSION.SDK_INT < android.os.Build.VERSION_CODES.KITKAT) {
                ViewParent viewParent = v_float.getParent();
                if(null != viewParent && viewParent instanceof  View){
                    View parentView = (View)viewParent;
                    parentView.requestLayout();
                    parentView.invalidate();
                }
            }
            if(null != vedioWindowManager && vedioWindowManager.change2Large(index)){
                lastScaleVedioWindowIndex = index;
            }
        }
        Log.d(TAG,"onVedioWindowLongClick-lastScaleVedioWindowIndex1:"+lastScaleVedioWindowIndex);
    }

    /**
     * 调整view高度, 解决背景在AdjustSize时会被推上去问题
     */
    @SuppressLint("WrongViewCast")
    private void setSizeUnChanageViewParams(){
        int statusBarHeight = DisplayUtil.getStatusBarHeight(mContext);
        if(statusBarHeight > 0){
            int activityHeight = DisplayUtil.getScreenHeight(mContext) - statusBarHeight;
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
    public void OnEnterHangoutRoom(int reqId, final boolean success, IMClientListener.LCC_ERR_TYPE errType,
                                   final String errMsg, final IMHangoutRoomItem hangoutRoomItem, int expire) {
        super.OnEnterHangoutRoom(reqId, success, errType, errMsg, hangoutRoomItem, expire);
        if (success && null != hangoutRoomItem && !isCurrentRoom(hangoutRoomItem.roomId)) {
            return;
        }
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if(!success){
                    //Samson:断线重连，重新调用RoomIn命令接口返回失败，视作退出直播间
                    //直接跳转到直播间结束页面
                    endLiveRoom(errMsg);
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
                //不是男士也不是主播自己
                if(!mIMHangOutRoomItem.manId.equals(userId) && !loginItem.userId.equals(userId)){
                    if(null != mIMHangOutRoomItem.otherAnchorList && mIMHangOutRoomItem.otherAnchorList.length > 0){
                        //不在otherAnchorList列表中则剔除
                        boolean isToDel = true;
                        for(IMOtherAnchorItem anchorItem : mIMHangOutRoomItem.otherAnchorList){
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
        if(null != mIMHangOutRoomItem && !TextUtils.isEmpty(mIMHangOutRoomItem.manPhotoUrl)){
            HangOutRoomEndActivity.show(this,mIMHangOutRoomItem.manPhotoUrl,mIMHangOutRoomItem.manNickName, description);
        }
    }

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
    }

    @Override
    public void onSilentStatusChanged(boolean onOrOff) {
        Log.d(TAG,"onSilentStatusChanged-onOrOff:"+onOrOff);
        iv_vedioControll.setVisibility(View.VISIBLE);
        if(null != vedioWindowManager){
            vedioWindowManager.slient(onOrOff);
        }
    }

    @Override
    public void onExitHangOutClicked() {
        Log.d(TAG,"onExitHangOutClicked");
        iv_vedioControll.setVisibility(View.VISIBLE);
        lastSwitchLiveRoomType = LiveRoomType.Unknown;
        lastSwitchLiveRoomId = null;
        lastSwitchUserBaseInfoItem = null;
        userCloseRoom();
    }

    @Override
    public void stopLSPubilsher() {
        super.stopLSPubilsher();
        if(null != vedioWindowManager){
            vedioWindowManager.stopLSPubilsher();
        }
    }

    @Override
    public void OnRecvAnchorLeaveRoomNotice(final IMRecvLeaveRoomItem item) {
        super.OnRecvAnchorLeaveRoomNotice(item);
        if(!isCurrentRoom(item.roomId)){
            return;
        }
        //主播用户离开直播间通知时不删除本地缓存
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if(null != mIMHangOutRoomItem && null != item && item.userId.equals(mIMHangOutRoomItem.manId)){
                    //为了发消息的时候判断男士是否仍在hangout直播间，增加男士离开时清理infoitem的逻辑
                    //这里方便起见固定remove调index=1的man--userinfoitem，具体顺序在initData里面可见
                    synchronized (chatterInfoItems){
                        if(null != chatterInfoItems && chatterInfoItems.size() == 2){
                            chatterInfoItems.remove(0);
                            chatterSelectorAdapter.setList(chatterInfoItems);
                        }
                    }
                }

                if(null != vedioWindowManager) {
                    vedioWindowManager.switchWait2InviteStatus(item.userId);
                }
            }
        });
    }

    @Override
    public void OnRecvAnchorDealInviteNotice(final IMDealInviteItem item) {
        super.OnRecvAnchorDealInviteNotice(item);
        if(!isCurrentRoom(item.roomId)){
            return;
        }
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if(item.type != IMDealInviteItem.IMAnchorReplyInviteType.Agree){
                    //主播接受邀请并进入直播间，状态切换处理放到接受主播进入直播间接口
                    //如果主播已经在线，则不处理，否则照常处理
                    if(null != vedioWindowManager && !vedioWindowManager.checkIsOnLine(item.anchorId)){
                        //其他情况则一律清理map
                        vedioWindowManager.switchWait2InviteStatus(item.anchorId);
                    }
                }
            }
        });
    }

    @Override
    public void OnRecvAnchorOtherInviteNotice(final IMOtherInviteItem item) {
        super.OnRecvAnchorOtherInviteNotice(item);
        if(!isCurrentRoom(item.roomId)){
            return;
        }
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                //如果主播已经在线，则不处理，否则照常处理
                if(null != vedioWindowManager && !vedioWindowManager.checkIsOnLine(item.anchorId)){
                    vedioWindowManager.switchAnchorComingStatus(item.anchorId,item.photoUrl,
                            item.nickName,HangOutVedioWindow.AnchorComingType.Man_Inviting, item.expire);
                }

            }
        });
    }

    @Override
    public void OnRecvAnchorEnterRoomNotice(final IMRecvEnterRoomItem item) {
        super.OnRecvAnchorEnterRoomNotice(item);
        if(!isCurrentRoom(item.roomId)){
            return;
        }
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if(null != item && null != vedioWindowManager){
                    vedioWindowManager.switchInvitedStatus(item.userId,item.photoUrl,item.nickName,item.pullUrl);
                    if(null != item.bugForList && item.bugForList.length>0){
                        vedioWindowManager.initRecvBarGiftData(item);
                    }
                }
            }
        });
    }

    @Override
    public void OnRecvAnchorDealKnockRequestNotice(final IMKnockRequestItem item) {
        super.OnRecvAnchorDealKnockRequestNotice(item);
        if(!isCurrentRoom(item.roomId)){
            return;
        }
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                //item.userId主播不在线且男士开门,切换状态
                if(null != vedioWindowManager && !vedioWindowManager.checkIsOnLine(item.userId)
                        && item.type == IMKnockRequestItem.IMAnchorKnockType.Agree){
                    vedioWindowManager.switchAnchorComingStatus(item.userId,item.photoUrl,item.nickName,
                            HangOutVedioWindow.AnchorComingType.Man_Accepted_Anchor_Knock,0);
                }
            }
        });
    }

    @Override
    public void OnRecvHangoutInteractiveVideoNotice(String roomId, String userId, String nickname,
                                                    String avatarImg,
                                                    IMClientListener.IMVideoInteractiveOperateType operateType,
                                                    String[] pushUrls) {
        super.OnRecvHangoutInteractiveVideoNotice(roomId, userId, nickname, avatarImg, operateType, pushUrls);
        if(!isCurrentRoom(roomId)){
            return;
        }
        onManInterVedioStatusChanged(roomId, userId, nickname, operateType, pushUrls);
    }

    /**
     * 男士互动视频状态发生更改 打开or关闭
     * @param roomId
     * @param userId
     * @param nickname
     * @param operateType
     * @param pushUrls
     */
    private void onManInterVedioStatusChanged(String roomId, final String userId, String nickname,
                                              final IMClientListener.IMVideoInteractiveOperateType operateType,
                                              final String[] pushUrls) {
        final boolean isOpen = operateType==IMClientListener.IMVideoInteractiveOperateType.Start;
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if(null != vedioWindowManager){
                    if(null != pushUrls && pushUrls.length>0 && isOpen){
                        //1.打开 则将男士cell切换到视频流传输状态
                        vedioWindowManager.startLive(userId,pushUrls);
                    }else if(operateType==IMClientListener.IMVideoInteractiveOperateType.Close){
                        //2.关闭，则将男士cell切换到封面头像状态
                        vedioWindowManager.stopLive(userId);
                    }
                }
            }
        });

        //聊天列表插入普通公告
        String message = getResources().getString(isOpen ? R.string.private_live_interactive_vedio_open
                : R.string.private_live_interactive_vedio_close,nickname);
        IMSysNoticeMessageContent msgContent = new IMSysNoticeMessageContent(message,null,
                IMSysNoticeMessageContent.SysNoticeType.Normal);
        IMMessageItem msgItem = new IMMessageItem(roomId,mIMManager.mMsgIdIndex.getAndIncrement(),"",
                IMMessageItem.MessageType.SysNotice,msgContent);
        sendMessageUpdateEvent(msgItem);
    }

    @Override
    public void OnRecvAnchorChangeVideoUrl(String roomId, boolean isAnchor, final String userId, final String[] playUrl) {
        super.OnRecvAnchorChangeVideoUrl(roomId, isAnchor, userId, playUrl);
        if(!isCurrentRoom(roomId)){
            return;
        }
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if(null != vedioWindowManager){
                    //1.将userid对应的cell切换到视频流传输状态
                    vedioWindowManager.startLive(userId,playUrl);
                }
            }
        });
    }

    @Override
    public void onVedioDisconnect(int index, boolean hasConnected) {
        Log.d(TAG,"onVedioDisconnect-index:"+index+" hasConnected:"+hasConnected);
        if(!hasConnected) {
            onPullStreamDisconnect();
        }else{
            hasToastDisconnected = false;
        }
    }

    private boolean hasToastDisconnected = false;

    @Override
    public void onPullStreamDisconnect() {
        super.onPullStreamDisconnect();
        if(!hasToastDisconnected){
            //仅仅是IM断线，Toast提示
            if(isActivityVisible()) {
                showToast(getResources().getString(R.string.live_push_stream_network_poor));
            }
            hasToastDisconnected = true;
        }
    }

    @Override
    public void OnRecvAnchorCountDownEnterRoomNotice(String roomId, final String anchorId, final int leftSecond) {
        super.OnRecvAnchorCountDownEnterRoomNotice(roomId, anchorId, leftSecond);
        if(!isCurrentRoom(roomId)){
            return;
        }
        //接受到主播即将从公开或者私密直播间倒计时进入hangout直播间，界面展示倒计时提示
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                IMUserBaseInfoItem imUserBaseInfoItem = null;
                if(null != mIMManager){
                    imUserBaseInfoItem = mIMManager.getUserInfo(anchorId);
                }
                Log.d(TAG,"OnRecvAnchorCountDownEnterRoomNotice-更新倒计时状态");
                if(null != imUserBaseInfoItem && null != vedioWindowManager && !vedioWindowManager.checkIsOnLine(anchorId)){
                    vedioWindowManager.switchAnchorComingStatus(anchorId,imUserBaseInfoItem.photoUrl,
                            imUserBaseInfoItem.nickName,HangOutVedioWindow.AnchorComingType.Anchor_Coming_After_Expires,leftSecond);
                }
            }
        });
    }
}
