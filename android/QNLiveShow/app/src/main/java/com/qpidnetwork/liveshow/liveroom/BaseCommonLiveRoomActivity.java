package com.qpidnetwork.liveshow.liveroom;

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
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.framework.base.BaseFragmentActivity;
import com.qpidnetwork.framework.livemsglist.LiveMessageListAdapter;
import com.qpidnetwork.framework.livemsglist.LiveMessageListView;
import com.qpidnetwork.framework.livemsglist.MessageRecyclerView;
import com.qpidnetwork.framework.livemsglist.ViewHolder;
import com.qpidnetwork.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.framework.widget.magicfly.FlyElement;
import com.qpidnetwork.framework.widget.magicfly.FlyLinearLayout;
import com.qpidnetwork.httprequest.item.GiftItem;
import com.qpidnetwork.httprequest.item.LoginItem;
import com.qpidnetwork.im.IIMEventListener;
import com.qpidnetwork.im.IMManager;
import com.qpidnetwork.im.listener.IMClientListener;
import com.qpidnetwork.im.listener.IMMessageItem;
import com.qpidnetwork.im.listener.IMRoomInfoItem;
import com.qpidnetwork.im.listener.IMUserBaseInfoItem;
import com.qpidnetwork.liveshow.R;
import com.qpidnetwork.liveshow.authorization.LoginManager;
import com.qpidnetwork.liveshow.datacache.preference.LocalPreferenceManager;
import com.qpidnetwork.liveshow.liveroom.barrage.BarrageManager;
import com.qpidnetwork.liveshow.liveroom.barrage.IBarrageViewFiller;
import com.qpidnetwork.liveshow.liveroom.gift.ModuleGiftManager;
import com.qpidnetwork.utils.DisplayUtil;
import com.qpidnetwork.utils.Log;
import com.qpidnetwork.view.SoftKeyboradListenFrameLayout;
import com.squareup.picasso.Picasso;
import java.util.ArrayList;
import java.util.List;

import static android.R.attr.name;

/**
 * 直播间公共处理界面类
 * Created by Hunter Mun on 2017/6/16.
 */

public class BaseCommonLiveRoomActivity extends BaseFragmentActivity implements View.OnClickListener,
        SoftKeyboradListenFrameLayout.InputWindowListener, IIMEventListener{

    protected static final String TAG = BaseCommonLiveRoomActivity.class.getName();

    public static final String LIVEROOM_ROOM_ID = "liveRoomId";

    private static final int EVENT_MESSAGE_UPDATE = 1001;
    private static final int EVENT_LIKE_UPDATE = 1002;

    //整个view的父，用于解决软键盘等监听
    private SoftKeyboradListenFrameLayout flContentBody;

    //消息编辑区域
    private View rl_inputMsg;
    private LinearLayout ll_input_edit_body;
    private ImageView iv_msgType;
    private EditText et_liveMsg;
    private Button btn_sendMsg;

    //聊天展示区域
    private LiveMessageListView lvlv_roomMsgList;
    private LiveMessageListAdapter lmlAdapter;
    private TextView tv_unReadTip;

    //礼物模块
    protected ModuleGiftManager mModuleGiftManager;

    //点赞
    private FlyLinearLayout fll_love;

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
        mIMManager.registerIMListener(this);
    }

    /**
     * 初始化模块
     */
    private void initModules(){

        /*礼物模块*/
        mModuleGiftManager = new ModuleGiftManager(this);
        mModuleGiftManager.initMultiGift();
        mModuleGiftManager.showMultiGiftAs(findViewById(R.id.ll_bulletScreen));

        /*大礼物*/
        mModuleGiftManager.initAdvanceGift(advanceGift);
    }

    /**
     * 清除IM底层类相关监听事件
     */
    private void clearIMListener(){
        mIMManager.unregisterIMListener(this);
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

        //调整背景高度, 解决背景在AdjustSize时会被推上去问题
        int statusBarHeight = new LocalPreferenceManager(mContext).getStatusBarHeight();
        if(statusBarHeight > 0){
            LinearLayout.LayoutParams params = (LinearLayout.LayoutParams)findViewById(R.id.fl_bgContent).getLayoutParams();
            params.height = DisplayUtil.getScreenHeight(mContext) - statusBarHeight;
        }else{
            postUiRunnableDelayed(new Runnable() {
                @Override
                public void run() {
                    Rect outRect = new Rect();
                    getWindow().getDecorView().getWindowVisibleDisplayFrame(outRect);
                    LinearLayout.LayoutParams params = (LinearLayout.LayoutParams)findViewById(R.id.fl_bgContent).getLayoutParams();
                    params.height = outRect.bottom - outRect.top;
                    new LocalPreferenceManager(mContext).saveStatusBarHeight(outRect.bottom - outRect.top);
                }
            }, 200);
        }

        //解决软键盘关闭的监听问题
        flContentBody = (SoftKeyboradListenFrameLayout)findViewById(R.id.flContentBody);
        flContentBody.setInputWindowListener(this);

        //大礼物
        advanceGift = (SimpleDraweeView)findViewById(R.id.advanceGift);

        initEditAreaView();
        initMessageList();
        initFlyLoveView();
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
            case R.id.rlViewBodyExcludeEdit:{
                //点击界面区域关闭键盘或者点赞处理
                if(isSoftInputOpen){
                    hideSoftInput(et_liveMsg);
                }else{
                    sendLike();
                }
            }break;
            default:
                break;
        }
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        switch(msg.what){
            case EVENT_MESSAGE_UPDATE:{
                IMMessageItem msgItem = (IMMessageItem)msg.obj;
                if(msgItem != null && msgItem.msgId > 0){
                    //更新消息列表
                    updateMsgList(msgItem);
                    //启动消息特殊处理
                    launchAnimationByMessage(msgItem);
                }
            }break;
            case EVENT_LIKE_UPDATE:{
                //点赞更新
                onLikeEventUpdate();
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
    }

    /********************************  软键盘打开关闭的监听  ***********************************/
    private boolean isSoftInputOpen = false;

    @Override
    public void onSoftKeyboardShow() {
        Log.i(TAG, "onSoftKeyboardShow");
        isSoftInputOpen = true;
    }

    @Override
    public void onSoftKeyboardHide() {
        android.util.Log.i(TAG, "onSoftKeyboardHide");
        isSoftInputOpen = false;
        if(rl_inputMsg != null){
            rl_inputMsg.setVisibility(View.INVISIBLE);
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
        IMMessageItem msgItem = null;
        if(!TextUtils.isEmpty(message)) {
            if (isBarrage) {
                msgItem = mIMManager.sendBarrage(mRoomId, message);
            } else {
                msgItem = mIMManager.sendRoomMsg(mRoomId, message);
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

    /**
     * 初始化消息展示列表
     */
    private void initMessageList(){
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
    }

    /**
     * 更新显示MessageList指定行
     * @param holder
     * @param liveMsgItem
     */
    private void refreshViewByMessageItem(ViewHolder holder, IMMessageItem liveMsgItem){

        TextView ll_userLevel = holder.getView(R.id.tvMsgDescription);
        Spanned span = null;
        switch (liveMsgItem.msgType){
            case Normal:
            case Barrage:{
                //弹幕或者普通文本消息
                span = Html.fromHtml(getResources().getString(R.string.liveroom_message_template_normal, liveMsgItem.nickName, liveMsgItem.textMsgContent.message));
            }break;
            case Gift:{
//                span = Html.fromHtml(getResources().getString(R.string.liveroom_message_template_normal, li));
            }break;
            case Like:{
                span = Html.fromHtml(getResources().getString(R.string.liveroom_message_template_favorite, liveMsgItem.nickName));
            }break;
            case RoomIn:{
                span = Html.fromHtml(getResources().getString(R.string.liveroom_message_template_roomin, liveMsgItem.nickName));
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

        //最后一条消息时RoomIn时，更新
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

    /********************************* 弹幕动画  *******************************************/
    private BarrageManager<IMMessageItem> mBarrageManager;

    /**
     * 初始化弹幕
     */
    private void initBarrage(){
        List<View> mViews = new ArrayList<View>();
        mViews.add(findViewById(R.id.rl_bullet1));
        mViews.add(findViewById(R.id.rl_bullet2));

        mBarrageManager = new BarrageManager<IMMessageItem>(this, mViews);
        mBarrageManager.setBarrageFiller(new IBarrageViewFiller<IMMessageItem>() {
            @Override
            public void onBarrageViewFill(View view, IMMessageItem item) {
                CircleImageView civ_bullletIcon = (CircleImageView) view.findViewById(R.id.civ_bullletIcon);
                TextView tv_bulletName = (TextView) view.findViewById(R.id.tv_bulletName);
                TextView tv_bulletContent = (TextView) view.findViewById(R.id.tv_bulletContent);
                if(item != null){
                    tv_bulletName.setText(item.nickName);
                    tv_bulletContent.setText(item.textMsgContent.message);

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

    /********************************* 点赞  *******************************************/
    /**
     * 初始化点赞组件
     */
    private void initFlyLoveView(){
        fll_love = (FlyLinearLayout)findViewById(R.id.fll_love);
        //设置点赞范围（高度）
        FrameLayout.LayoutParams params = (FrameLayout.LayoutParams)fll_love.getLayoutParams();
        int statusBarHeight = new LocalPreferenceManager(mContext).getStatusBarHeight();
        params.height = ((DisplayUtil.getScreenHeight(mContext) - statusBarHeight)*3)/5;

        fll_love.addFlyElement(R.drawable.ic_live_buttom_flylove_1 , FlyElement.Type.Shake);
        fll_love.addFlyElement(R.drawable.ic_live_buttom_flylove_2 , FlyElement.Type.Shake);
        fll_love.addFlyElement(R.drawable.ic_live_buttom_flylove_3 , FlyElement.Type.Shake);
        fll_love.addFlyElement(R.drawable.ic_live_buttom_flylove_4 , FlyElement.Type.Shake);
        fll_love.addFlyElement(R.drawable.ic_live_buttom_flylove_5 , FlyElement.Type.Shake);
    }

    /**
     * 点赞事件更新
     */
    public void onLikeEventUpdate(){
        fll_love.flying();
    }

    /**
     * 由子实现，决定是否发送点赞
     */
    public void sendLike(){

    }

    /**
     * 发送或接收点赞时发送消息
     */
    public void sendLikeEvent(){
        Message msg = Message.obtain();
        msg.what = EVENT_LIKE_UPDATE;
        sendUiMessage(msg);
    }

    /********************************* IMManager事件监听回调  *******************************************/
    @Override
    public void OnLogin(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnLogout(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnFansRoomIn(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMRoomInfoItem roomInfo) {

    }

    @Override
    public void OnFansRoomOut(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnSendMsg(IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMMessageItem msgItem) {

    }

    @Override
    public void OnGetRoomInfo(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, int fansNum, int contribute) {

    }

    @Override
    public void OnAnchorForbidMessage(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnAnchorKickOffAudience(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnKickOff(String reason) {

    }

    @Override
    public void OnRecvRoomCloseFans(String roomId, String userId, String nickName, int fansNum) {

    }

    @Override
    public void OnRecvRoomCloseBroad(String roomId, int fansNum, int inCome, int newFans, int shares, int duration) {

    }

    @Override
    public void OnRecvFansRoomIn(String roomId, String userId, String nickName, String photoUrl) {

    }

    @Override
    public void OnRecvShutUpNotice(String roomId, String userId, String nickName, int timeOut) {

    }

    @Override
    public void OnRecvKickOffRoomNotice(String roomId, String userId, String nickName) {

    }

    @Override
    public void OnRecvMsg(IMMessageItem msgItem) {
        sendMessageUpdateEvent(msgItem);
    }

    @Override
    public void OnRecvPushRoomFav(String roomId, String fromId, String nickName) {
        sendLikeEvent();
    }

    @Override
    public void OnCoinsUpdate(double coins) {

    }
}
