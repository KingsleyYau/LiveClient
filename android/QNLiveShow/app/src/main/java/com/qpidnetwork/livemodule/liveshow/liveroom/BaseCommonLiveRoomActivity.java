package com.qpidnetwork.livemodule.liveshow.liveroom;

import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.os.Bundle;
import android.os.Message;
import android.support.annotation.Nullable;
import android.text.Editable;
import android.text.Html;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.text.style.ForegroundColorSpan;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationSet;
import android.view.animation.AnimationUtils;
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.framework.livemsglist.LiveMessageListAdapter;
import com.qpidnetwork.livemodule.framework.livemsglist.LiveMessageListView;
import com.qpidnetwork.livemodule.framework.livemsglist.MessageRecyclerView;
import com.qpidnetwork.livemodule.framework.livemsglist.ViewHolder;
import com.qpidnetwork.livemodule.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.im.IMGiftManager;
import com.qpidnetwork.livemodule.im.IMInviteLaunchEventListener;
import com.qpidnetwork.livemodule.im.IMLiveRoomEventListener;
import com.qpidnetwork.livemodule.im.IMManager;
import com.qpidnetwork.livemodule.im.IMOtherEventListener;
import com.qpidnetwork.livemodule.im.listener.IMClientListener;
import com.qpidnetwork.livemodule.im.listener.IMMessageItem;
import com.qpidnetwork.livemodule.im.listener.IMRebateItem;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.livemodule.im.listener.IMUserBaseInfoItem;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.datacache.preference.LocalPreferenceManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.barrage.BarrageManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.barrage.IBarrageViewFiller;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.GiftSendReqManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.ModuleGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.downloader.IFileDownloadedListener;
import com.qpidnetwork.livemodule.liveshow.personal.chatemoji.ChatEmoji;
import com.qpidnetwork.livemodule.liveshow.personal.chatemoji.ChatEmojiManager;
import com.qpidnetwork.livemodule.liveshow.personal.chatemoji.EmojiTabScrollLayout;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.HtmlImageGetter;
import com.qpidnetwork.livemodule.utils.Log;
import com.qpidnetwork.livemodule.view.CircleImageHorizontScrollView;
import com.qpidnetwork.livemodule.view.SoftKeyboradListenFrameLayout;
import com.squareup.picasso.Picasso;

import java.util.ArrayList;
import java.util.List;

/**
 * 直播间公共处理界面类
 * Created by Hunter Mun on 2017/6/16.
 */

public class BaseCommonLiveRoomActivity extends BaseFragmentActivity implements View.OnClickListener,
        SoftKeyboradListenFrameLayout.InputWindowListener, IFileDownloadedListener, IMInviteLaunchEventListener,
        IMLiveRoomEventListener, IMOtherEventListener{

    protected final String TAG = BaseCommonLiveRoomActivity.class.getName();

    public static final String LIVEROOM_ROOM_ID = "liveRoomId";

    private final int EVENT_MESSAGE_UPDATE = 1001;
    private final int EVENT_LIKE_UPDATE = 1002;
    private final int EVENT_MESSAGE_IMAGE_UPDATE = 1003;

    //整个view的父，用于解决软键盘等监听
    private SoftKeyboradListenFrameLayout flContentBody;

    //顶部主播个人信息模块
    protected View view_roomHeader;
    protected CircleImageHorizontScrollView cihsv_online;

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
    private LiveMessageListView lvlv_roomMsgList;
    private LiveMessageListAdapter lmlAdapter;
    private TextView tv_unReadTip;

    //礼物模块
    protected ModuleGiftManager mModuleGiftManager;
    //大礼物
    private SimpleDraweeView advanceGift;

    //数据及管理
    protected String mRoomId;
    protected IMManager mIMManager;


    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setTitleBarVisibility(View.GONE);
        initIMListener();
        initData();
        initViews();
        initModules();
    }

    /**
     * 初始化IM底层相关
     */
    private void initIMListener(){
        mIMManager = IMManager.getInstance();
        mIMManager.registerIMInviteLaunchEventListener(this);
        mIMManager.registerIMLiveRoomEventListener(this);
        mIMManager.registerIMOtherEventListener(this);
    }

    /**
     * 初始化模块
     */
    private void initModules(){

        FrameLayout viewContent = (FrameLayout)findViewById(R.id.flMultiGift);
        /*礼物模块*/
        mModuleGiftManager = new ModuleGiftManager(this);
        mModuleGiftManager.initMultiGift(viewContent);
        mModuleGiftManager.showMultiGiftAs(findViewById(R.id.ll_bulletScreen));

        /*大礼物*/
        mModuleGiftManager.initAdvanceGift(advanceGift);
    }

    /**
     * 清除IM底层类相关监听事件
     */
    private void clearIMListener(){
        mIMManager.unregisterIMInviteLaunchEventListener(this);
        mIMManager.unregisterIMLiveRoomEventListener(this);
        mIMManager.unregisterIMOtherEventListener(this);
    }

    /**
     * 出事化数据相关
     */
    private void initData(){
        Bundle bundle = getIntent().getExtras();
        if(bundle != null){
            if(bundle.containsKey(LIVEROOM_ROOM_ID)){
                mRoomId = bundle.getString(LIVEROOM_ROOM_ID);
            }
        }
        if(TextUtils.isEmpty(mRoomId)){
            Log.e(TAG, "roomId cannot null");
            finish();
        }

    }

    private void initViews(){
        Log.d(TAG,"initViews");
        initRoomHeader();

        //大礼物
        advanceGift = (SimpleDraweeView)findViewById(R.id.advanceGift);

        //调整背景高度, 解决背景在AdjustSize时会被推上去问题
        int statusBarHeight = new LocalPreferenceManager(mContext).getStatusBarHeight();
        if(statusBarHeight > 0){
            LinearLayout.LayoutParams params = (LinearLayout.LayoutParams)findViewById(R.id.fl_bgContent).getLayoutParams();
            params.height = DisplayUtil.getScreenHeight(mContext) - statusBarHeight;

            //设置固定宽高，解决键盘弹出挤压问题
            FrameLayout.LayoutParams advanceGiftParams = (FrameLayout.LayoutParams)advanceGift.getLayoutParams();
            advanceGiftParams.height = DisplayUtil.getScreenHeight(mContext) - statusBarHeight;
            //设置IM区域高度，处理弹出效果
            FrameLayout.LayoutParams imParams = (FrameLayout.LayoutParams)findViewById(R.id.include_im_body).getLayoutParams();
            imParams.height = DisplayUtil.getScreenHeight(mContext) - statusBarHeight;
        }else{
            postUiRunnableDelayed(new Runnable() {
                @Override
                public void run() {
                    Rect outRect = new Rect();
                    getWindow().getDecorView().getWindowVisibleDisplayFrame(outRect);
                    LinearLayout.LayoutParams params = (LinearLayout.LayoutParams)findViewById(R.id.fl_bgContent).getLayoutParams();
                    params.height = outRect.bottom - outRect.top;
                    //设置固定宽高，解决键盘弹出挤压问题
                    FrameLayout.LayoutParams advanceGiftParams = (FrameLayout.LayoutParams)advanceGift.getLayoutParams();
                    advanceGiftParams.height = outRect.bottom - outRect.top;
                    //设置IM区域高度，处理弹出效果
                    FrameLayout.LayoutParams imParams = (FrameLayout.LayoutParams)findViewById(R.id.include_im_body).getLayoutParams();
                    imParams.height = outRect.bottom - outRect.top;

                    new LocalPreferenceManager(mContext).saveStatusBarHeight(outRect.bottom - outRect.top);
                }
            }, 200);

        }

        //解决软键盘关闭的监听问题
        flContentBody = (SoftKeyboradListenFrameLayout)findViewById(R.id.flContentBody);
        flContentBody.setInputWindowListener(this);

        initEditAreaView();
        initMessageList();
        initBarrage();
    }

    @Override
    public int getActivityViewId() {
        return R.layout.activity_live_room;
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);
        switch (v.getId()){
            case R.id.btn_inputMsg:
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
            case R.id.tv_unReadTip:{
                //点击消息列表未读条数，滚动到底部刷新列表

            }break;
            case R.id.include_im_body:{
                //点击界面区域关闭键盘或者点赞处理
                if(isSoftInputOpen){
                    hideSoftInput(et_liveMsg,true);
                }else if(etsl_emojiContainer.getVisibility() == View.VISIBLE){
                    etsl_emojiContainer.setVisibility(View.GONE);
                    hideSoftInput(et_liveMsg,true);
                    //由于在iv_emojiSwitch点击事件触发表情列表显示时，已经hideSoftInput了et_liveMsg,
                    // 因此这里并未有软键盘状态切换的产生，也就不会自动回调
                    // com.qpidnetwork.view.SoftKeyboradListenFrameLayout.onSizeChanged()
                    //需要手动触发
                    onSoftKeyboardHide();
                }
                playRoomHeaderInAnim();
            }break;
            case R.id.et_liveMsg:
                if(etsl_emojiContainer.getVisibility() == View.VISIBLE){
                    etsl_emojiContainer.setVisibility(View.GONE);
                }
                break;
            default:
                break;
        }
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        switch(msg.what){
            case EVENT_MESSAGE_UPDATE:
                IMMessageItem msgItem = (IMMessageItem)msg.obj;
                if(msgItem != null && msgItem.msgId > 0){
                    //更新消息列表
                    updateMsgList(msgItem);
                    //启动消息特殊处理
                    launchAnimationByMessage(msgItem);
                }
                break;
            case EVENT_LIKE_UPDATE:
                break;
            case EVENT_MESSAGE_IMAGE_UPDATE:{
                //图片下载更新列表
                if(lmlAdapter != null) {
                    lmlAdapter.notifyDataSetChanged();
                }
            }break;
            default:
                break;
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
    protected void onDestroy() {
        super.onDestroy();
        clearIMListener();
        mModuleGiftManager.onMultiGiftDetroy();
        //清除资源及动画
        if(mBarrageManager != null) {
            mBarrageManager.onDestroy();
        }
    }

    /********************************  软键盘打开关闭的监听  ***********************************/
    private boolean isSoftInputOpen = false;

    @Override
    public void onSoftKeyboardShow() {
        Log.d(TAG, "onSoftKeyboardShow");
        isSoftInputOpen = true;
        playRoomHeaderOutAnim();
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

    //----------------------------------顶部房间信息模块-----------------------------------------
    private void initRoomHeader(){
        view_roomHeader = findViewById(R.id.view_roomHeader);
        cihsv_online = (CircleImageHorizontScrollView) findViewById(R.id.cihsv_online);
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
    private void playRoomHeaderOutAnim(){
        if(view_roomHeader.getVisibility() == View.VISIBLE){
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

    /********************************  弹出编辑区域处理  *****************************************/
    private boolean isBarrage = false;

    /**
     * 处理编辑框区域view初始化
     */
    private void initEditAreaView(){
        //消息及弹幕编辑区
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
            updateMsgList(msgItem);
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
    public void sendTextMessagePreProcess(boolean isBarrage){

    }

    /********************************  公共消息管理模块   ***************************************/

    private int[] levelBgDrawableIds = {
            R.drawable.bg_live_buttom_livemsg_icon_0cedf5,
            R.drawable.bg_live_buttom_livemsg_icon_f5e20c,
            R.drawable.bg_live_buttom_livemsg_icon_ec8f26,
            R.drawable.bg_live_buttom_livemsg_icon_fb5a34,
    };

    private int[] levelIconDrawableIds = {
            R.drawable.ic_live_buttom_livemsg_level_2,
            R.drawable.ic_live_buttom_livemsg_level_3,
            R.drawable.ic_live_buttom_livemsg_level_1,
            R.drawable.ic_live_buttom_livemsg_level_4
    };

    private HtmlImageGetter mImageGetter;

    /**
     * 初始化消息展示列表
     */
    private void initMessageList(){
        //初始化Html图片解析器
        mImageGetter = new HtmlImageGetter(this, (int)getResources().getDimension(R.dimen.liveroom_messagelist_gift_width),
                (int)getResources().getDimension(R.dimen.liveroom_messagelist_gift_height));

        lvlv_roomMsgList = (LiveMessageListView) findViewById(R.id.lvlv_roomMsgList);
        tv_unReadTip = (TextView) findViewById(R.id.tv_unReadTip);
        lvlv_roomMsgList.setOnMsgUnreadListener(new MessageRecyclerView.onMsgUnreadListener() {
            @Override
            public void onMsgUnreadSum(int unreadSum) {
                updateUnreadLiveMsgTipVew(unreadSum);
            }

            @Override
            public void onReadAll() {
                updateUnreadLiveMsgTipVew(0);
            }
        });

        lmlAdapter = new LiveMessageListAdapter<IMMessageItem>(this,R.layout.item_live_room_msglist) {
            @Override
            public void convert(ViewHolder holder, IMMessageItem liveMsgItem) {
                refreshViewByMessageItem(holder, liveMsgItem);
            }
        };

        lvlv_roomMsgList.setAdapter(lmlAdapter);
        lvlv_roomMsgList.setMaxMsgSum(getResources().getInteger(R.integer.liveMsgListMaxNum));
        lvlv_roomMsgList.setHoldingTime(getResources().getInteger(R.integer.liveMsgListItemHoldTime));
        lvlv_roomMsgList.setVerticalSpace(Float.valueOf(getResources().getDimension(R.dimen.listmsgview_item_decoration)).intValue());
        //incliude view id 必须通过setOnClickListener方式设置onclick监听,
        // xml中include标签下没有onclick和clickable属性
        findViewById(R.id.include_im_body).setOnClickListener(this);
    }

    /**
     * 更新显示MessageList指定行
     * @param holder
     * @param liveMsgItem
     */
    private void refreshViewByMessageItem(ViewHolder holder,
                                          IMMessageItem liveMsgItem){

        TextView ll_userLevel = holder.getView(R.id.tvMsgDescription);
        Spanned span = null;
        switch (liveMsgItem.msgType){
            case Normal:
            case Barrage:{
                //弹幕或者普通文本消息
                span = ChatEmojiManager.getInstance().parseEmoji(
                        BaseCommonLiveRoomActivity.this,
                        getResources().getString(
                                R.string.liveroom_message_template_normal,
                                liveMsgItem.nickName,
                                liveMsgItem.textMsgContent.message),
                        ChatEmojiManager.CHATEMOJI_MODEL_EMOJIDES);
            }break;
            case Gift:{
                //检测礼物小图片存在与否，不存在自动下载，更新列表
                if(!IMGiftManager.getInstance()
                        .isGiftLocalPictureExist(liveMsgItem.giftMsgContent.giftId,
                            IMGiftManager.GiftImageType.Thumb)){
                    IMGiftManager.getInstance()
                            .getGiftImage(liveMsgItem.giftMsgContent.giftId,
                            IMGiftManager.GiftImageType.Thumb, this);
                }

                //礼物消息列表展示
                String giftNum = "";
                if(liveMsgItem.giftMsgContent.giftNum > 1){
                    giftNum += getResources().getString(R.string.liveroom_message_gift_x)
                            + String.valueOf(liveMsgItem.giftMsgContent.giftNum);
                }
                span = mImageGetter.getExpressMsgHTML(getResources().getString(
                        R.string.liveroom_message_template_gift, liveMsgItem.nickName,
                        liveMsgItem.giftMsgContent.giftName,
                        liveMsgItem.giftMsgContent.giftId, giftNum));
            }break;
            case Like:{
                span = Html.fromHtml(getResources().getString(
                        R.string.liveroom_message_template_favorite, liveMsgItem.nickName));
            }break;
            case RoomIn:{
                span = Html.fromHtml(getResources().getString(
                        R.string.liveroom_message_template_roomin, liveMsgItem.nickName));
            }break;
            default:
                break;
        }
        ll_userLevel.setText(span);
    }

    /**
     * 自动换行(messsage被拆成两段显示，第一段在tv_line1，剩下在tv_line2)
     * @param message
     * @param tv_line1
     * @param tv_line2
     */
    private void calculateTextViewAutoWrap(String message, View rootView, TextView tv_line1, TextView tv_line2){
        tv_line1.setVisibility(View.INVISIBLE);
        tv_line2.setVisibility(View.GONE);
        tv_line1.setText(message);
        rootView.measure(0,0);
        int rootViewMeasuredWidth = rootView.getMeasuredWidth();
        tv_line1.measure(0,0);
        int line1MeasuredWidth = tv_line1.getMeasuredWidth();
        android.util.Log.d(TAG,"initLiveMsgView-line1MeasuredWidth:"+line1MeasuredWidth+" rootViewMeasuredWidth:"+rootViewMeasuredWidth);
        Paint paint = new Paint();
        paint.setTextSize(tv_line1.getTextSize());
        int txtWidth = 0;
        int index = 0;
        for(; index < message.length(); index++){
            char indexChar = message.charAt(index);
            int charWidth = Float.valueOf(paint.measureText(String.valueOf(indexChar))).intValue();
//                        Log.d(TAG,"initLiveMsgView-charWidth:"+charWidth);
            txtWidth+=charWidth;
            if(txtWidth>line1MeasuredWidth){
                tv_line1.setText(message.substring(0, index));
                tv_line2.setText(message.substring(index, message.length()));
                tv_line2.setVisibility(View.VISIBLE);
                break;
            }
        }
        tv_line1.setVisibility(View.VISIBLE);
        //下面可以开个for循环计算line2的宽度，避免每行char个数参差不齐，但是考虑到字数有限制，可以不做
        //String line2Txt = liveMsgItem.liveMsg.substring(index,liveMsgItem.liveMsg.length());
    }

    protected void updateMsgList(IMMessageItem msgItem){
        boolean isUpdate = false;

        //最后一条消息是RoomIn时，更新
        if(msgItem.msgType == IMMessageItem.MessageType.RoomIn){
            Object dataItem = lvlv_roomMsgList.getLastData();
            if(dataItem != null && dataItem instanceof IMMessageItem){
                IMMessageItem lastMsgitem = (IMMessageItem)dataItem;
                if(lastMsgitem.msgType == IMMessageItem.MessageType.RoomIn){
                    isUpdate = true;
                    lastMsgitem.copy(msgItem);
                }
            }
        }

        if(lvlv_roomMsgList != null && !isUpdate){
            lvlv_roomMsgList.addNewLiveMsg(msgItem);
        }else{
            lmlAdapter.notifyDataSetChanged();
        }
    }

    /**
     * 更新未读消息提示界面
     * @param unReadNum
     */
    private void updateUnreadLiveMsgTipVew(int unReadNum){
        tv_unReadTip.setVisibility(0 == unReadNum ? View.INVISIBLE : View.VISIBLE);
        String unReadTip = getString(R.string.tip_unReadLiveMsg,unReadNum);
        SpannableString styledText = new SpannableString(unReadTip);
        styledText.setSpan(new ForegroundColorSpan(Color.parseColor("#ffd205")), 0, unReadTip.indexOf(" "), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        tv_unReadTip.setText(styledText);
    }

    /**
     * 消息切换主线程
     * @param msgItem
     */
    private void sendMessageUpdateEvent(IMMessageItem msgItem){
        Message msg = Message.obtain();
        msg.what = EVENT_MESSAGE_UPDATE;
        msg.obj = msgItem;
        sendUiMessage(msg);
    }

    /**
     * 接收多种消息同一处理
     * @param msgItem
     */
    private void onSendMessage(IMClientListener.LCC_ERR_TYPE errType, String errMsg,IMMessageItem msgItem){
        Log.d(TAG,"OnSendMsg-errType:"+ errType+" errMsg:"+errMsg+" msgItem:"+msgItem);
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

    /********************************* 弹幕动画  *******************************************/
    private BarrageManager<IMMessageItem> mBarrageManager;

    /**
     * 初始化弹幕
     */
    private void initBarrage(){
        List<View> mViews = new ArrayList<View>();
        mViews.add(findViewById(R.id.rl_bullet1));
        View rl_bullet2 = findViewById(R.id.rl_bullet2);
        //如果rl_bullet2初始配置的可见状态为GONE则代表弹幕只有一个通道
        if(View.GONE != rl_bullet2.getVisibility()){
            mViews.add(rl_bullet2);
        }

        mBarrageManager = new BarrageManager<IMMessageItem>(this, mViews);
        mBarrageManager.setBarrageFiller(new IBarrageViewFiller<IMMessageItem>() {
            @Override
            public void onBarrageViewFill(View view, IMMessageItem item) {
                CircleImageView civ_bullletIcon = (CircleImageView) view.findViewById(R.id.civ_bullletIcon);
                TextView tv_bulletName = (TextView) view.findViewById(R.id.tv_bulletName);
                TextView tv_bulletContent = (TextView) view.findViewById(R.id.tv_bulletContent);
                if(item != null){
                    tv_bulletName.setText(item.nickName);
                    tv_bulletContent.setText(ChatEmojiManager.getInstance()
                            .parseEmoji(BaseCommonLiveRoomActivity.this,
                                    item.textMsgContent.message,ChatEmojiManager.CHATEMOJI_MODEL_EMOJIDES));

                    String photoUrl = "";
                    IMUserBaseInfoItem baseInfo = mIMManager.getUserInfo(item.userId);
                    if(baseInfo != null){
                        photoUrl = baseInfo.photoUrl;
                    }
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
//            if(item != null && !TextUtils.isEmpty(item.userId)
//                    && item.userId.equals(msgItem.userId)){
//                //本人发送，优先显示
//                mBarrageManager.addBarrageItemFirst(msgItem);
//            }else{
                mBarrageManager.addBarrageItem(msgItem);
//            }
        }
    }

    /***************************  礼物/level等图片下载回调  ********************************/
    @Override
    public void onCompleted(boolean isSuccess, String localFilePath, String fileUrl) {
        Log.i("hunter", "BaseCommonLiveRoomActivity onCompleted isSuccess：" + isSuccess);
        if(isSuccess){
            sendEmptyUiMessage(EVENT_MESSAGE_IMAGE_UPDATE);
        }
    }

    /********************************* IMManager事件监听回调  *******************************************/
    @Override
    public void OnLogin(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnLogout(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnKickOff() {

    }

    @Override
    public void OnRecvLackOfCreditNotice(String roomId, String message, double credit) {

    }

    @Override
    public void OnRecvCreditNotice(String roomId, double credit) {

    }

    @Override
    public void OnRoomOut(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
        Log.d(TAG,"OnFansRoomOut-reqId:"+reqId+" success:"+success+" errType:"+errType+" errMsg;");
        if(success){
            //退出房间成功，就清空送礼队列，并停止服务
            GiftSendReqManager.getInstance().shutDownReqQueueServNow();
        }
    }

    @Override
    public void OnSendRoomMsg(IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMMessageItem msgItem) {
        onSendMessage(errType, errMsg, msgItem);
    }

    @Override
    public void OnSendGift(boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMMessageItem msgItem, double credit, double rebateCredit) {
        onSendMessage(errType, errMsg, msgItem);
    }

    @Override
    public void OnSendBarrage(boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMMessageItem msgItem, double credit, double rebateCredit) {
        onSendMessage(errType, errMsg, msgItem);
    }

    @Override
    public void OnRecvRoomCloseNotice(String roomId, String userId, String nickName) {

    }

    @Override
    public void OnRecvEnterRoomNotice(String roomId, String userId, String nickName, String photoUrl, String riderId, String riderName, String riderUrl, int fansNum) {

    }

    @Override
    public void OnRecvLeaveRoomNotice(String roomId, String userId, String nickName, String photoUrl, int fansNum) {

    }

    @Override
    public void OnRecvRebateInfoNotice(String roomId, IMRebateItem item) {

    }

    @Override
    public void OnRecvLeavingPublicRoomNotice(String roomId, IMClientListener.LCC_ERR_TYPE err, String errMsg) {

    }

    @Override
    public void OnRecvRoomKickoffNotice(String roomId, IMClientListener.LCC_ERR_TYPE err, String errMsg, double credit) {

    }

    @Override
    public void OnRecvRoomMsg(IMMessageItem msgItem) {
        sendMessageUpdateEvent(msgItem);
    }

    @Override
    public void OnRecvRoomGiftNotice(IMMessageItem msgItem) {
        sendMessageUpdateEvent(msgItem);
    }

    @Override
    public void OnRecvRoomToastNotice(IMMessageItem msgItem) {
        sendMessageUpdateEvent(msgItem);
    }

    @Override
    public void OnRoomIn(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMRoomInItem roomInfo) {

    }

    @Override
    public void OnRecvLiveStart(String roomId, int leftSeconds) {

    }

    @Override
    public void OnSendImmediatePrivateInvite(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, String inviteId) {

    }

    @Override
    public void OnCancelImmediatePrivateInvite(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, String roomId) {

    }

    @Override
    public void OnRecvInviteReply(String inviteId, IMClientListener.InviteReplyType replyType, String roomId) {

    }

    @Override
    public void OnRecvAnchoeInviteNotify(String anchorId, String anchorName, String anchorPhotoUrl) {

    }

    @Override
    public void OnRecvScheduledInviteNotify(String anchorId, String anchorName, String anchorPhotoUrl, int bookTime, String inviteId) {

    }

}
