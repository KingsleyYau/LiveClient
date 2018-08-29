package com.qpidnetwork.livemodule.liveshow.message;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.FragmentTransaction;
import android.support.v7.widget.LinearLayoutManager;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.framework.services.LiveService;
import com.qpidnetwork.livemodule.httprequest.item.EmotionItem;
import com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType;
import com.qpidnetwork.livemodule.im.listener.IMClientListener;
import com.qpidnetwork.livemodule.livemessage.LMLiveRoomEventListener;
import com.qpidnetwork.livemodule.livemessage.LMManager;
import com.qpidnetwork.livemodule.livemessage.OnSetPrivatemsgReadedCallback;
import com.qpidnetwork.livemodule.livemessage.item.LMSystemNoticeItem;
import com.qpidnetwork.livemodule.livemessage.item.LiveMessageItem;
import com.qpidnetwork.livemodule.liveshow.anchor.AnchorProfileActivity;
import com.qpidnetwork.livemodule.liveshow.bean.NoMoneyParamsBean;
import com.qpidnetwork.livemodule.liveshow.personal.chatemoji.ChatEmojiManager;
import com.qpidnetwork.livemodule.view.ButtonRaised;
import com.qpidnetwork.livemodule.view.RefreshRecyclerView;
import com.qpidnetwork.qnbridgemodule.view.keyboardLayout.KeyBoardManager;
import com.qpidnetwork.qnbridgemodule.view.keyboardLayout.SoftKeyboardSizeWatchLayout;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static com.qpidnetwork.livemodule.im.listener.IMClientListener.LCC_ERR_TYPE.LCC_ERR_CONNECTFAIL;

/**
 * 私信聊天记录界面
 * 注：manifest中android:windowSoftInputMode="stateHidden|adjustPan"只能这样设置
 *
 * @author Jagger 2018-6-14
 *
 */
public class ChatTextActivity extends BaseActionBarFragmentActivity implements RefreshRecyclerView.OnPullRefreshListener, LMLiveRoomEventListener, LiveEmojiListFragment.OnEmojiSelectListener, SoftKeyboardSizeWatchLayout.OnResizeListener {

    private static final String PARAMS_KEY_USERID = "userId";
    private static final String PARAMS_KEY_USERNAME = "userName";
    private static final String PARAMS_KEY_USERAVASTER = "userAvaster";
    private static final String PARAMS_KEY_TITLE2PROFILE = "title2profile";

    //输入框旁边的，表情/键盘切换按钮 的状态
    private enum InputChangeBtnStaus{
        EMOJI,      //表情
        KEYBOARD    //键盘
    }

    //输入键盘类型
    private enum InputAreaStatus {
        HIDE,       //隐藏
        EMOJI,      //表情
        KEYBOARD    //键盘
    }

    /**
     * 列表滚动的位置
     */
    private enum ListScrollPosition{
        TOP,
        MIDDLE,
        BOTTOM
    }

    //控件
    private SoftKeyboardSizeWatchLayout sl_root;
    private RefreshRecyclerView mRecyclerViewMsg;
    private LinearLayoutManager mLinearLayoutManager;
    private FrameLayout mFrameLayoutInputArea , mFrameLayoutEmoji;
    private ImageView mImageViewEmoji;
    private EditText mEditText;
    private LinearLayout listLoadingHeader;
    private ButtonRaised mBtnSend;

    //变量
    private int mKeyBoardHeight = 0;    //键盘高度
    private InputAreaStatus mInputAreaStatus = InputAreaStatus.HIDE;
    private InputChangeBtnStaus mInputChangeBtnStaus = InputChangeBtnStaus.KEYBOARD;
    private ListScrollPosition mListScrollPosition = ListScrollPosition.BOTTOM;
    private int mTempPositonBeforeMore = 0;
    private boolean mIsTitleClicked2Profile = true;    //点击标题是否跳转到资料

    //列表数据
    private String mUserId = "";                //当前用户的用户ID
    private String mUserName = "";              //当前用户的用户名
    private String mUserAvaster = "";           //当前用户的头像信息
    private ChatTextAdapter mAdapter;
    private List<LiveMessageItem> mDataList = new ArrayList<LiveMessageItem>();
    private LMManager mLMManager;               //私信管理器

    //是否可更多标志位
    private boolean mCanPullDownLoadMore = true;        //是否可下拉获取更多

    /**
     * 外部启动入口
     * @param context
     * @param userId
     * @param userName
     */
    public static void launchChatTextActivity(Context context, String userId, String userName){
        launchChatTextActivity(context , userId , userName , true);
    }

    /**
     * 外部启动入口
     * @param context
     * @param userId
     * @param userName
     */
    public static void launchChatTextActivity(Context context, String userId, String userName , boolean isTitleClicked2Profile){
        Intent intent = new Intent(context, ChatTextActivity.class);
        intent.putExtra(PARAMS_KEY_USERID, userId);
        intent.putExtra(PARAMS_KEY_USERNAME, userName);
        intent.putExtra(PARAMS_KEY_TITLE2PROFILE, isTitleClicked2Profile);
        context.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setCustomContentView(R.layout.activity_chat_text);

        //初始化私信管理器并绑定事件监听器
        mLMManager = LMManager.getInstance();
        mLMManager.registerLMLiveRoomEventListener(this);

        initViews();

        initData();
    }

    @Override
    protected void onTitleClicked() {
        super.onTitleClicked();
        if(mIsTitleClicked2Profile && !TextUtils.isEmpty(mUserId)){
            AnchorProfileActivity.launchAnchorInfoActivty(this, getResources().getString(R.string.live_webview_anchor_profile_title),
                    mUserId, false, AnchorProfileActivity.TagType.Album);
        }
    }

    /**
     * 初始化UI
     */
    private void initViews() {

        mAdapter = new ChatTextAdapter(mContext , mDataList);
        mAdapter.setOnItemClickListener(new ChatTextAdapter.OnItemClickListener() {
            @Override
            public void onResendClick(LiveMessageItem messageItem) {
                //重发
                showErrorSendNotify(messageItem);
            }

            @Override
            public void onAddCreditClick() {
                //充值
                LiveService.getInstance().onAddCreditClick(new NoMoneyParamsBean());
            }
        });

        sl_root = (SoftKeyboardSizeWatchLayout)findViewById(R.id.sl_root);
        sl_root.addOnResizeListener(this);

        mLinearLayoutManager = new LinearLayoutManager(this);
        mRecyclerViewMsg = (RefreshRecyclerView)findViewById(R.id.rcv_chat_msg);
        mRecyclerViewMsg.setCanPullUp(false);   // 关闭上拉更多
        mRecyclerViewMsg.setCanPullDown(false); //关闭下拉刷新
        mRecyclerViewMsg.setOnPullRefreshListener(this);
        mRecyclerViewMsg.getRecyclerView().setLayoutManager(mLinearLayoutManager);
        mRecyclerViewMsg.setAdapter(mAdapter);
        mRecyclerViewMsg.setRScrollLister(new RefreshRecyclerView.RScrollLister() {
            @Override
            public void onScrollToTop() {
                Log.i("Jagger" , "onScrollToTop mCanPullDownLoadMore: " + mCanPullDownLoadMore);

                if(mCanPullDownLoadMore) {
                    //本地根据第一条消息检测是否可以loadmore
                    if(checkWhetherCanLoadMore()) {
                        listLoadingHeader.setVisibility(View.VISIBLE);
                        listLoadingHeader.setPadding(0, 0, 0, 0);
                        //
                        mTempPositonBeforeMore = mLinearLayoutManager.findLastVisibleItemPosition();
                        //异步加载更多
                        loadMorePrivateMessage();
                    }else{
                        mCanPullDownLoadMore = false;
                    }
                }
                //更新列表位置状态
                mListScrollPosition = ListScrollPosition.TOP;
            }

            @Override
            public void onScrollToBottom() {
                Log.i("Jagger" , "onScrollToBottom");
                //更新列表位置状态
                mListScrollPosition = ListScrollPosition.BOTTOM;
            }

            @Override
            public void onScrollStateChanged(int state) {
                Log.i("Jagger" , "onScrollStateChanged");
                //更新列表位置状态
                mListScrollPosition = ListScrollPosition.MIDDLE;
            }
        });
        mRecyclerViewMsg.getRecyclerView().setFocusable(true);
        mRecyclerViewMsg.getRecyclerView().setFocusableInTouchMode(true);
        mRecyclerViewMsg.getRecyclerView().setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View view, MotionEvent motionEvent) {
                //点击列表时，收起输入区域
                hideInputArea();
                return false;
            }
        });

        //增加loading头
        listLoadingHeader = (LinearLayout) LayoutInflater.from(this).inflate(
                R.layout.item_list_view_header_loading, mRecyclerViewMsg.getRecyclerView().getFooterContainer(), false);
        listLoadingHeader.setVisibility(View.GONE);
        mRecyclerViewMsg.getRecyclerView().addHeaderView(listLoadingHeader);

        mEditText = (EditText) findViewById(R.id.edt_msg);
        mEditText.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View view, MotionEvent motionEvent) {
                //使用自己的方法弹出键盘
                showKeyBoard();
                return false;
            }
        });
        mEditText.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            @Override
            public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            @Override
            public void afterTextChanged(Editable editable) {
                //改变发送按钮状态
                if(editable.toString().length() > 0){
                    mBtnSend.setButtonBackground(getResources().getColor(R.color.theme_sky_blue));
                    mBtnSend.setEnabled(true);
                }else{
                    mBtnSend.setButtonBackground(getResources().getColor(R.color.black3));
                    mBtnSend.setEnabled(false);
                }
            }
        });
        mEditText.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView textView, int actionId, KeyEvent keyEvent) {
                switch (actionId) {
                    case EditorInfo.IME_ACTION_SEND: {
                        sendPrivateMesssage(mEditText.getText().toString());
                        mEditText.setText("");
                    }break;

                    default:
                        break;
                }

                return true;
            }
        });

        mFrameLayoutInputArea = (FrameLayout)findViewById(R.id.fl_inputArea);
        mFrameLayoutEmoji = (FrameLayout)findViewById(R.id.fl_emoji);

        mImageViewEmoji = (ImageView) findViewById(R.id.img_emoji);
        mImageViewEmoji.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                doOnShowKeyboardClicked();
            }
        });

        mBtnSend = (ButtonRaised)findViewById(R.id.btn_send);
        mBtnSend.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                sendPrivateMesssage(mEditText.getText().toString());
                mEditText.setText("");
            }
        });
    }

    /**
     * 初始化数据
     */
    private void initData() {
        //解析外部传入数据
        Bundle bundle = getIntent().getExtras();
        if(bundle != null){
            if(bundle.containsKey(PARAMS_KEY_USERID)){
                mUserId = bundle.getString(PARAMS_KEY_USERID);
            }
            if(bundle.containsKey(PARAMS_KEY_USERNAME)){
                mUserName = bundle.getString(PARAMS_KEY_USERNAME);
                setTitle(mUserName);
                Log.i("Jagger" , "PARAMS_KEY_USERNAME:"+mUserName);
            }
            if(bundle.containsKey(PARAMS_KEY_USERAVASTER)){
                mUserAvaster = bundle.getString(PARAMS_KEY_USERAVASTER);
            }
            if(bundle.containsKey(PARAMS_KEY_TITLE2PROFILE)){
                mIsTitleClicked2Profile = bundle.getBoolean(PARAMS_KEY_TITLE2PROFILE);
            }
        }
        if(!TextUtils.isEmpty(mUserId)){
            //title处理
            if(!TextUtils.isEmpty(mUserName)){
                setTitle(mUserName, R.color.theme_default_black);
            }else{
                setTitle(getString(R.string.my_message_title), R.color.theme_default_black);
            }
            setTitleImage(mUserAvaster , true);

            //
            mKeyBoardHeight = KeyBoardManager.getKeyboardHeight(this);
            Log.i("Jagger", "mKeyBoardHeight: " + mKeyBoardHeight);
            if(mKeyBoardHeight < 0){
                mKeyBoardHeight = getResources().getDimensionPixelSize(R.dimen.keyboard_height);
            }
            initEmojiView();
            //读取本地显示并刷新与当前联系人的私信列表
            refreshAllMessageList(mLMManager.GetLocalPrivateMsgWithUserId(mUserId));
            mLMManager.RefreshPrivateMsgWithUserId(mUserId);

            //设置当前正在私信聊天的对象id
            mLMManager.AddPrivateMsgLiveChatList(mUserId);
        }else{
            //用户id为空，页面无效
            finish();
        }
    }

    /**
     *　初始化表情列表
     */
    private void initEmojiView(){
        final FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();
        LiveEmojiListFragment liveEmojiListFragment = new LiveEmojiListFragment();
        Bundle bundle = new Bundle();
        bundle.putInt(LiveEmojiListFragment.EMOJIPANELHEIGHT,mKeyBoardHeight);
        liveEmojiListFragment.setArguments(bundle);
        transaction.replace(R.id.fl_emoji, liveEmojiListFragment);
        transaction.commitAllowingStateLoss();
        mFrameLayoutEmoji.setVisibility(View.INVISIBLE);
    }


    /**
     * 输入框旁边的，表情/键盘切换按钮的点击事件
     */
    private void doOnShowKeyboardClicked(){
        if(mInputChangeBtnStaus == InputChangeBtnStaus.EMOJI ){
            showEmojiBoard();
        }else if(mInputChangeBtnStaus == InputChangeBtnStaus.KEYBOARD){
            showKeyBoard();
        }
    }

    /**
     * 更改输入法、表情按钮状态
     * @param inputChangeBtnStaus
     */
    private void doChangeBtnStatus(InputChangeBtnStaus inputChangeBtnStaus){
        //更改图标
        if(inputChangeBtnStaus == InputChangeBtnStaus.EMOJI){
            mImageViewEmoji.setBackgroundResource(R.drawable.live_msg_keyboard_emoji);
            mInputChangeBtnStaus = InputChangeBtnStaus.EMOJI;
        }else {
            mImageViewEmoji.setBackgroundResource(R.drawable.live_msg_keyboard_sys);
            mInputChangeBtnStaus = InputChangeBtnStaus.KEYBOARD;
        }
    }

    /**
     * 消息列表滚动到底部
     */
    private void doScrollToBottom(){
        doScrollToPosition(mAdapter.getItemCount());
        //更新列表位置状态
        mListScrollPosition = ListScrollPosition.BOTTOM;
    }

    /**
     * 消息列表滚动到某个位置
     */
    private void doScrollToPosition(int itemIndex){
        mRecyclerViewMsg.getRecyclerView().scrollToPosition(itemIndex);
        //更新列表位置状态
        mListScrollPosition = ListScrollPosition.MIDDLE;
        mTempPositonBeforeMore = itemIndex;
    }

    /**
     * 显示输入区
     */
    private void showInputArea(){
        ViewGroup.LayoutParams layoutParams = mFrameLayoutInputArea.getLayoutParams();
        if(layoutParams.height < 1){
            layoutParams.height = mKeyBoardHeight;
            mFrameLayoutInputArea.setLayoutParams(layoutParams);
        }
    }

    /**
     * 隐藏输入区
     */
    private void hideInputArea(){
        hideKeyBoard();
        mInputAreaStatus = InputAreaStatus.HIDE;
        //延迟一些，以免界面跳动
        postUiRunnableDelayed(new Runnable() {
            @Override
            public void run() {
                //
                ViewGroup.LayoutParams layoutParams = mFrameLayoutInputArea.getLayoutParams();
                if(layoutParams.height > 0){
                    layoutParams.height = 0;
                    mFrameLayoutInputArea.setLayoutParams(layoutParams);
                }

                //更改图标
                doChangeBtnStatus(InputChangeBtnStaus.EMOJI);
            }
        } , 200);
    }

    /**
     * 显示输入法
     */
    private void showKeyBoard(){
        if(mInputAreaStatus == InputAreaStatus.KEYBOARD) return;
        Log.i("Jagger" ,"showKeyBoard" );

        //与其它控件显示关系的约束，最好不要乱改
        // ***start***
        showInputArea();
        showSoftInput(mEditText);
        hideEmojiBoard();
        // ***end***
    }

    /**
     * 隐藏输入法
     */
    private void hideKeyBoard(){
        if(mInputAreaStatus == InputAreaStatus.KEYBOARD){
            Log.i("Jagger" ,"hideKeyBoard" );

            //与其它控件显示关系的约束，最好不要乱改
            // ***start***
            hideSoftInput(mEditText , true);
            // ***end***
        }
    }

    /**
     * 显示表情选择器
     */
    private void showEmojiBoard(){
        Log.i("Jagger" ,"showEmojiBoard" );

        //与其它控件显示关系的约束，最好不要乱改
        // ***start***
        hideKeyBoard();
        showInputArea();
        //更改图标
        doChangeBtnStatus(InputChangeBtnStaus.KEYBOARD);
        //更改为另一种状态
        mInputAreaStatus = InputAreaStatus.EMOJI;
        //显示
        mFrameLayoutEmoji.setVisibility(View.VISIBLE);
        //回调
        onEmojiBoardShow();
        // ***end***
    }

    /**
     * 隐藏表情选择器
     */
    private void hideEmojiBoard(){
        Log.i("Jagger" ,"hideEmojiBoard" );

        //与其它控件显示关系的约束，最好不要乱改
        // ***start***
        mFrameLayoutEmoji.setVisibility(View.INVISIBLE);
        //回调
        onEmojiBoardHide();
        // ***end***
    }

    /**
     * 键盘弹出响应
     * @param height
     */
    @Override
    public void OnSoftPop(int height) {
        Log.i("Jagger" , "OnSoftPop:" + height);

        //与其它控件显示关系的约束，最好不要乱改
        // ***start***
        if(mKeyBoardHeight != height){
            mKeyBoardHeight = height;
            KeyBoardManager.saveKeyboardHeight(mContext , height);
        }

        doScrollToBottom();
        //更改图标
        doChangeBtnStatus(InputChangeBtnStaus.EMOJI);
        //更改为另一种状态
        mInputAreaStatus = InputAreaStatus.KEYBOARD;
        // ***end***
    }

    /**
     * 键盘收起响应
     */
    @Override
    public void OnSoftClose() {
        Log.i("Jagger" , "OnSoftClose");

        //与其它控件显示关系的约束，最好不要乱改
        // ***start***
        doScrollToBottom();
        if(mInputAreaStatus == InputAreaStatus.KEYBOARD){
            hideInputArea();
        }
        // ***end***
    }

    /**
     * 表情选择器弹出响应
     */
    private void onEmojiBoardShow(){
        Log.i("Jagger" , "onEmojiBoardShow");

        //与其它控件显示关系的约束，最好不要乱改
        // ***start***
        doScrollToBottom();
        // ***end***
    }

    /**
     * 表情选择器收起响应
     */
    private void onEmojiBoardHide(){

    }

    @Override
    public void onPullDownToRefresh() {
        //加载更多私信
        loadMorePrivateMessage();
    }

    @Override
    public void onPullUpToRefresh() {

    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if(mLMManager != null){
            //注销当前正在聊天的主播id
            mLMManager.RemovePrivateMsgLiveChatList(mUserId);

            mLMManager.unregisterLMLiveRoomEventListener(this);
        }
    }

    /**
     * 设置不能下拉刷新更多
     * @param enable
     */
    private void setCanPullDownMoreEnable(boolean enable){
        mCanPullDownLoadMore = enable;
    }

    /**********************************************  emji小表情选中  ***********************************************/
    @Override
    public void onEmojiSelect(EmotionItem emotionItem) {
        if (getResources().getInteger(R.integer.message_edit_max_length) - mEditText.getText().toString().length() < 6){
            return;
        }

        mEditText.getEditableText().insert(mEditText.getSelectionStart(),
                ChatEmojiManager.getInstance().parseEmoji2SpannableString(this,
                        TextUtils.htmlEncode(emotionItem.emoSign),
                        getResources().getDimensionPixelSize(R.dimen.live_size_16sp),
                        getResources().getDimensionPixelSize(R.dimen.live_size_16sp)));
    }

    /**********************************************  私信manager相关listener回调  ***********************************************/

    /**
     * 点击发送出错按钮，弹出提示
     * @param messageItem
     */
    private void showErrorSendNotify(final LiveMessageItem messageItem){
        String messageTips = "";
        if(messageItem != null && messageItem.sendErr != null
                && messageItem.sendErr == LCC_ERR_CONNECTFAIL){
            messageTips = getResources().getString(R.string.message_senderror_connect_fail_tips);
        }else{
            messageTips = getResources().getString(R.string.message_senderror_other_fail_tips);
        }
        AlertDialog.Builder builder = new AlertDialog.Builder(this)
                .setMessage(messageTips)
                .setNegativeButton(getResources().getString(R.string.live_common_btn_close), new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int i) {

                    }
                })
                .setPositiveButton(getResources().getString(R.string.live_common_btn_retry), new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int i) {
                        resendPrivateMessage(messageItem);
                    }
                });
        if(isActivityVisible()){
            builder.create().show();
        }
    }

    /**
     * 判断当前recycle是否停留在底部
     * @return
     */
    public boolean isRecycleViewBottom() {
        Log.i("Jagger" , "isRecycleViewBottom:" + mListScrollPosition.name());

        boolean result=false;
        if(mListScrollPosition == ListScrollPosition.BOTTOM){
            result = true;
        }
        return  result;
    }

    /**
     * 发送私信
     * @param message
     */
    private void sendPrivateMesssage(String message){
        //纯空格，按钮可点击，但不发送，且清空已键入空格
        if(TextUtils.isEmpty(message.replaceAll(" ","").replaceAll("\r" , "").replaceAll("\n",""))){
            return;
        }

        mLMManager.SendPrivateMessage(mUserId, message);

        //GA统计点击发送私信
        onAnalyticsEvent(getResources().getString(R.string.Live_Message_Category),
                getResources().getString(R.string.Live_Message_Action_Send),
                getResources().getString(R.string.Live_Message_Label_Send));

    }

    /**
     * 加载更多私信信息
     */
    private void loadMorePrivateMessage(){
        mLMManager.GetMorePrivateMsgWithUserId(mUserId);
    }

    /**
     * 重发私信
     * @param messageItem
     */
    private void resendPrivateMessage(LiveMessageItem messageItem){
        if(messageItem != null){
            mLMManager.RepeatSendPrivateMsg(mUserId, messageItem.sendMsgId);
        }
    }

    /**
     * 刷新整个列表，并自动滚动到底部（刷新私信列表返回或界面第一次初始化）
     * @param messageList
     */
    private void refreshAllMessageList(LiveMessageItem[] messageList){
        mDataList.clear();
        if(messageList != null){
            mDataList.addAll(Arrays.asList(messageList));
        }
        notifyListDataChange();
        doScrollToBottom();
    }

    /**
     * 收到消息或发送消息插入底部
     * @param messageList
     */
    private void insertNewMessagesBottom(LiveMessageItem[] messageList){
        //加入数据前判断，如果加入数据后再判断，肯定不是在底部的
        boolean isOnListBottom = isRecycleViewBottom();

        if(messageList != null){
            mDataList.addAll(Arrays.asList(messageList));
        }
        notifyListDataChange();

        //处理是否底部，底部时滚动到底部否则直接刷新,并处理第一次刷新数据默认滚到底部
        if(isOnListBottom || mDataList.size() == 0){
            doScrollToBottom();
        }
    }

    /**
     * 获取更多插入头部
     * @param messageList
     */
    private void insertMoreMessageTop(LiveMessageItem[] messageList){
        //加入数据前判断，如果加入数据后再判断，肯定不是在底部的
        boolean isOnListBottom = isRecycleViewBottom();

        if(messageList != null){
            mDataList.addAll(0,Arrays.asList(messageList));
        }
        notifyListDataChange();

        if(isOnListBottom){
            doScrollToBottom();
        }else{
            if(messageList != null && messageList.length > 0) {
                doScrollToPosition(mTempPositonBeforeMore + messageList.length - 1);
            }
        }
    }

    /**
     * 更新已发送消息状态
     * @param messageItem
     */
    private void updateSendedMessageStatus(LiveMessageItem messageItem){
        if(messageItem != null){
            for(int i = 0; i < mDataList.size(); i++){
                if(mDataList.get(i).sendMsgId == messageItem.sendMsgId){
                    mDataList.set(i, messageItem);
                    break;
                }
            }
        }
        notifyListDataChange();
    }

    /**
     * 通知界面刷新数据
     */
    private void notifyListDataChange(){
        if(mAdapter != null){
            mAdapter.notifyDataSetChanged();
            //通知底层刷新未读状态
            mLMManager.SetPrivateMsgReaded(mUserId, new OnSetPrivatemsgReadedCallback() {
                @Override
                public void onSetPrivateMsgReaded(boolean isSuccess, int errCode, String errMsg, boolean isModify, String userId) {

                }
            });
        }
    }

    /**
     * 检测是否可以刷新更多（规则根据第一条消息类型）
     */
    private boolean checkWhetherCanLoadMore(){
        boolean canLoadMore = true;
        if(mDataList != null && mDataList.size() > 0){
            LiveMessageItem msgItem = mDataList.get(0);
            if(msgItem.msgType == LiveMessageItem.LMMessageType.System
                    && msgItem.systemItem != null
                    && msgItem.systemItem.systemType == LMSystemNoticeItem.LMSystemType.NoMuchMore){
                canLoadMore = false;
            }
        }
        return canLoadMore;
    }


    @Override
    public void OnUpdateFriendListNotice(boolean success, HttpLccErrType errType, String errMsg) {

    }

    @Override
    public void OnRefreshPrivateMsgWithUserId(boolean success, HttpLccErrType errType, String errMsg, String userId, final LiveMessageItem[] messageList, int reqId) {
        //通知刷新整个私信列表
        if(success && !TextUtils.isEmpty(userId)
                && userId.equals(mUserId)){
            //请求成功且时当前用户
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    insertNewMessagesBottom(messageList);
                }
            });
        }
    }

    @Override
    public void OnGetMorePrivateMsgWithUserId(final boolean success, HttpLccErrType errType, String errMsg, String userId, final LiveMessageItem[] messageList, int reqId, final boolean canMore) {
        //通知more返回私信聊天列表
        if(!TextUtils.isEmpty(userId) && userId.equals(mUserId)) {
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    //获取更多返回
                    if(success && messageList != null) {
                        insertMoreMessageTop(messageList);
                    }
                    listLoadingHeader.setVisibility(View.GONE);
                    mRecyclerViewMsg.onRefreshComplete();
                    //设置是否支持更多
                    setCanPullDownMoreEnable(canMore);
                }
            });
        }
    }

    @Override
    public void OnUpdatePrivateMsgWithUserId(String userId, final LiveMessageItem[] messageList) {
        //通知收到消息插入
        if(!TextUtils.isEmpty(userId)
                && userId.equals(mUserId)){
            //请求成功且时当前用户
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    insertNewMessagesBottom(messageList);
                }
            });
        }
    }

    @Override
    public void OnSendPrivateMessage(boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, String userId, final LiveMessageItem messageItem) {
        //通知发送消息状态改变
        if(!TextUtils.isEmpty(userId)
                && userId.equals(mUserId)) {
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    //更新私信状态
                    updateSendedMessageStatus(messageItem);
                }
            });
        }
    }

    @Override
    public void OnRecvUnReadPrivateMsg(LiveMessageItem messageItem) {

    }

    @Override
    public void OnRepeatSendPrivateMsgNotice(String userId, final LiveMessageItem[] messageList) {
        //重新发送成功，需刷新所有消息
        if(!TextUtils.isEmpty(userId)
                && userId.equals(mUserId)){
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    refreshAllMessageList(messageList);
                }
            });
        }
    }
}
