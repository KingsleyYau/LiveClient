package com.qpidnetwork.livemodule.liveshow.livechat;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.os.Message;
import android.support.v4.app.FragmentTransaction;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.PopupMenu;
import android.text.Editable;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.text.style.ImageSpan;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.view.inputmethod.EditorInfo;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetUserInfoCallback;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.httprequest.item.UserInfoItem;
import com.qpidnetwork.livemodule.livechat.LCEmotionItem;
import com.qpidnetwork.livemodule.livechat.LCMagicIconItem;
import com.qpidnetwork.livemodule.livechat.LCMessageItem;
import com.qpidnetwork.livemodule.livechat.LCNotifyItem;
import com.qpidnetwork.livemodule.livechat.LCSystemItem;
import com.qpidnetwork.livemodule.livechat.LCUserItem;
import com.qpidnetwork.livemodule.livechat.LiveChatManager;
import com.qpidnetwork.livemodule.livechat.LiveChatManagerEmotionListener;
import com.qpidnetwork.livemodule.livechat.LiveChatManagerMagicIconListener;
import com.qpidnetwork.livemodule.livechat.LiveChatManagerMessageListener;
import com.qpidnetwork.livemodule.livechat.LiveChatManagerOtherListener;
import com.qpidnetwork.livemodule.livechat.LiveChatManagerTryTicketListener;
import com.qpidnetwork.livemodule.livechat.LiveChatManagerVoiceListener;
import com.qpidnetwork.livemodule.livechat.contact.ContactManager;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatSessionInfoItem;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatTalkUserListItem;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatUserCamStatus;
import com.qpidnetwork.livemodule.livechathttprequest.item.Coupon;
import com.qpidnetwork.livemodule.livechathttprequest.item.MagicIconConfig;
import com.qpidnetwork.livemodule.livechathttprequest.item.OtherEmotionConfigItem;
import com.qpidnetwork.livemodule.livemessage.item.LiveMessageItem;
import com.qpidnetwork.livemodule.liveshow.LiveModule;
import com.qpidnetwork.livemodule.liveshow.anchor.AnchorProfileActivity;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.livechat.normalexp.NormalExprssionFragment;
import com.qpidnetwork.livemodule.liveshow.livechat.voice.VoicePlayerManager;
import com.qpidnetwork.livemodule.liveshow.livechat.voice.VoiceRecordFragment;
import com.qpidnetwork.livemodule.liveshow.manager.PushManager;
import com.qpidnetwork.livemodule.liveshow.manager.URL2ActivityManager;
import com.qpidnetwork.livemodule.liveshow.model.NoMoneyParamsBean;
import com.qpidnetwork.livemodule.view.CustomEditText;
import com.qpidnetwork.livemodule.view.MaterialDialogAlert;
import com.qpidnetwork.livemodule.view.RefreshRecyclerView;
import com.qpidnetwork.qnbridgemodule.bean.NotificationTypeEnum;
import com.qpidnetwork.qnbridgemodule.util.BroadcastManager;
import com.qpidnetwork.qnbridgemodule.util.Log;
import com.qpidnetwork.qnbridgemodule.view.keyboardLayout.KeyBoardManager;
import com.qpidnetwork.qnbridgemodule.view.keyboardLayout.SoftKeyboardSizeWatchLayout;

import java.util.ArrayList;
import java.util.List;

/**
 * 直播LiveChat聊天界面
 * 注：manifest中android:windowSoftInputMode="stateHidden|adjustResize"只能这样设置
 *
 * @author Jagger 2018-11-17
 */
public class LiveChatTalkActivity extends BaseActionBarFragmentActivity implements
        RefreshRecyclerView.OnPullRefreshListener, SoftKeyboardSizeWatchLayout.OnResizeListener,
        LiveChatManagerMessageListener, LiveChatManagerEmotionListener,
        LiveChatManagerTryTicketListener,LiveChatManagerMagicIconListener,
        LiveChatManagerVoiceListener, LiveChatManagerOtherListener {
    //启动参数
    private static final String CHAT_TARGET_ID = "targetId";
    private static final String CHAT_TARGET_NAME = "targetName";
    private static final String CHAT_TARGET_PHOTO_URL = "targetPhotoUrl";
    //广播
    public static final String SEND_VOICE_ACTION = "livechat.sendvoice";
    public static final String SEND_EMTOTION_ACTION = "livechat.sendemotion";
    public static final String SEND_MAGICICON_ACTION = "livechat.sendmagicicon";
    public static final String WOMAN_ID = "woman_id";// 女士id
    public static final String EMOTION_ID = "emotion_id";
    public static final String MAGICICON_ID = "magicicon_id";
    //常量
    private final int MAX_EDITTEXT_LENGTH = 200;
    private boolean TITLE_IMAGE_IS_CIRCLE = true;
    //Handler
    private static final int RECEIVE_CHAT_MESSAGE = 0;
    private static final int PHOTO_FEE_SUCCESS = 1;
    private static final int PRIVATE_SHOW_PHOTO_DOWNLOADED = 2;
    private static final int RECEIVE_CHECK_SEND_MESSAGE_ERROR = 3;
    private static final int GET_HISTORY_MESSAGE_UPDATE = 5;
    private static final int CHECK_COUPON_UPDATE = 6;
    private static final int SEND_MESSAGE_CALLBACK = 7;
    private static final int TARGET_PHOTO_UPDATE = 8;
    private static final int END_CHAT = 9;
    private static final int REQUEST_ADD_FAVOUR_SUCCESS = 10;
    private static final int REQUEST_ADD_FAVOUR_FAIL = 11;
    private static final int GET_TARGET_STATUS_CALLBACK = 15;
    private static final int GET_MAGIC_ICON_SUCCESS = 16;

    //输入框旁边的，表情/键盘切换按钮 的状态
    private enum InputChangeBtnStaus{
        EMOJI,      //表情
        KEYBOARD    //键盘
    }

    //输入键盘类型
    private enum InputAreaStatus {
        HIDE,       //隐藏
        FUNCTIONS,  //功能区
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

    /**
     * 右上角菜单,结束聊天按钮状态
     */
    private enum EndTalkMenuStatus {
        END_CHAT,
        MAN_INVITE,
        LADY_INVITE
    }

    //控件
    private SoftKeyboardSizeWatchLayout sl_root;
    private RefreshRecyclerView mRecyclerViewMsg;
    private LinearLayoutManager mLinearLayoutManager;
    private FrameLayout mFrameLayoutInputArea , mFrameLayoutFunctions;
    private ImageView mImageViewEmoji, mImageViewVoice;
    private CustomEditText mEditText;
    private LinearLayout listLoadingHeader;
    private ImageButton mBtnSend;
    private PopupMenu mTitlePopupMenu;
    private NormalExprssionFragment mNormalExprssionFragment;
    private VoiceRecordFragment mVoiceRecordFragment;

    //变量
    private int mKeyBoardHeight = 0;    //键盘高度
    private InputAreaStatus mInputAreaStatus = InputAreaStatus.HIDE;
    private InputChangeBtnStaus mInputChangeBtnStaus = InputChangeBtnStaus.EMOJI;
    private ListScrollPosition mListScrollPosition = ListScrollPosition.BOTTOM;
    private int mTempPositonBeforeMore = 0;
    private boolean mIsTitleClicked2Profile = true;     //点击标题是否跳转到资料
    private boolean mCanPullDownLoadMore = false;       //是否可下拉获取更多
    private EndTalkMenuStatus endTalkMenuStatus = EndTalkMenuStatus.END_CHAT;    //区分下拉菜单显示的时取消还是endchat
    private boolean onlineChecked = false;              //防止联系人获取状态回调影响不停弹出检测

    // 当前聊天对象信息
    private String targetId;
    private String targetName;
    private String targetUrl;

    //数据
    private LiveChatTalkAdapter mAdapter;
    private List<LCMessageItem> mDataList = new ArrayList<LCMessageItem>();
    private LCUserItem chatTarget; // 存储当前聊天对象
    private LiveChatManager mLiveChatManager;
    private ContactManager mContactManager;         // 联系人列表管理类，此处主要用于在聊设置，及未读条数显示
    private int unreadCount = 0;                    // 未读消息条数
    private BroadcastReceiver mBroadcastReceiver;   //广播用于activity间数据传递
    private VoicePlayerManager mVoicePlayerManager;

    /**
     *
     */
    class LiveChatCallBackItem {

        public int errType;
        public String errNo;
        public String errMsg;
        public Object body;

        public LiveChatCallBackItem(int errType, String errNo, String errMsg, Object body){
            this.errType = errType;
            this.errNo = errNo;
            this.errMsg = errMsg;
            this.body = body;
        }
    }

    /**
     * 启动
     * @param context
     * @param targetId
     * @param targetName
     * @param photoUrl
     */
    public static void launchChatActivity(final Context context, final String targetId, final String targetName, final String photoUrl) {
        Intent intent = new Intent();
        /* 未登录成功跳转登陆界面 */
        if (LoginManager.getInstance().getLoginStatus() == LoginManager.LoginStatus.Logined) {
            LoginItem loginItem = LoginManager.getInstance().getLoginItem();
            if (loginItem != null && loginItem.premit && !loginItem.livechat) {
//                /* 账号未被冻结且livechat未被风控，可直接进入聊天界面 */
                if(!LiveChatManager.getInstance().isInCamshareService(targetId)){
                    intent.setClass(context, LiveChatTalkActivity.class);
                    intent.putExtra(CHAT_TARGET_ID, targetId);
                    intent.putExtra(CHAT_TARGET_NAME, targetName);
                    intent.putExtra(CHAT_TARGET_PHOTO_URL, photoUrl);
                    context.startActivity(intent);
                }else{
//                    //Camshare中，提示切换
                    if(context instanceof Activity){
//                        DialogUIUtils.showAlert(
//                                (Activity) context,
//                                "",
//                                context.getString(R.string.live_chat_camshare_switch_to_livechat_tips),
//                                context.getString(R.string.common_btn_ok),
//                                true,
//                                true,
//                                new DialogUIListener() {
//                                    @Override
//                                    public void onPositive() {
//                                        LiveChatManager.getInstance().EndCamshareChat(targetId);
//                                        LiveChatTalkActivity.launchChatActivity(context, targetId, targetName, photoUrl);
//                                    }
//
//                                    @Override
//                                    public void onNegative() {
//
//                                    }
//                                }
//                        ).show();
                        MaterialDialogAlert dialog = new MaterialDialogAlert(context);
                        dialog.setMessageCenter(context.getString(R.string.live_chat_camshare_switch_to_livechat_tips));
                        dialog.addButton(dialog.createButton(
                                context.getString(R.string.common_btn_ok),
                                new View.OnClickListener() {
                                    @Override
                                    public void onClick(View v) {
                                        LiveChatManager.getInstance().EndCamshareChat(targetId);
                                        LiveChatTalkActivity.launchChatActivity(context, targetId, targetName, photoUrl);
                                    }
                                }));
                        dialog.addButton(dialog.createButton(context.getString(R.string.common_btn_cancel), null));
                        dialog.show();
                    }
                }
            } else {
//                /* 账号被冻结或者livechat被风控则不可聊天,弹框提示 */
                if(context instanceof Activity){
//                    DialogUIUtils.showAlert(
//                            (Activity) context,
//                            "",
//                            context.getString(R.string.live_chat_common_risk_control_notify),
//                            context.getString(R.string.common_btn_ok),
//                            true,
//                            true,
//                            new DialogUIListener() {
//                                @Override
//                                public void onPositive() {
//                                    LiveChatManager.getInstance().EndCamshareChat(targetId);
//                                    LiveChatTalkActivity.launchChatActivity(context, targetId, targetName, photoUrl);
//                                }
//
//                                @Override
//                                public void onNegative() {
//
//                                }
//                            }
//                    ).show();
                    MaterialDialogAlert dialog = new MaterialDialogAlert(context);
                    dialog.setMessageCenter(context
                            .getString(R.string.live_chat_common_risk_control_notify));
                    dialog.addButton(dialog.createButton(
                            context.getString(R.string.common_btn_ok), null));
                    dialog.show();
                }
            }
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setCustomContentView(R.layout.activity_live_chat_talk);

        //初始化私信管理器并绑定事件监听器
        //TODO
        mLiveChatManager = LiveChatManager.getInstance();
        mContactManager = ContactManager.getInstance();
        mVoicePlayerManager = VoicePlayerManager.getInstance(mContext);

        initViews();
        initData();
        initReceive();
        initLivechatConfig();
    }

    @Override
    protected void onResume() {
        super.onResume();
        mContactManager.mWomanId = targetId;
        PushManager.getInstance().Cancel(NotificationTypeEnum.LIVE_LIVECHAT_NOTIFICATION);
    }

    @Override
    protected void onPause() {
        super.onPause();
        stopAllVoicePlaying();
    }

    @Override
    protected void onDestroy() {
        // TODO Auto-generated method stub
        super.onDestroy();
//        msgList.onDestroy();

//        unregisterReceiver(mBroadcastReceiver);
        BroadcastManager.unregisterReceiver(mContext,mBroadcastReceiver);

//        mLiveChatManager.UnregisterEmotionListener(this);
        mLiveChatManager.UnregisterMessageListener(this);
        mLiveChatManager.UnregisterOtherListener(this);
//        mLiveChatManager.UnregisterPhotoListener(this);
        mLiveChatManager.UnregisterTryTicketListener(this);
        mLiveChatManager.UnregisterVoiceListener(this);
//        mLiveChatManager.UnregisterVideoListener(this);
        mLiveChatManager.UnregisterMagicIconListener(this);
//        mLiveChatManager.UnregisterThemeListener(this);

        /* 清除正在聊天对象 */
        mContactManager.mWomanId = "";
    }

    /**
     * 初始化配置LivechatManager，监听消息请求及推送事件
     */
    private void initLivechatConfig() {
        /* 绑定监听回调事件 */
        mLiveChatManager.RegisterMessageListener(this);
        mLiveChatManager.RegisterTryTicketListener(this);
        mLiveChatManager.RegisterVoiceListener(this);
        mLiveChatManager.RegisterOtherListener(this);
        mLiveChatManager.RegisterMagicIconListener(this);

    }

    private void initReceive() {
        mBroadcastReceiver = new BroadcastReceiver() {

            @Override
            public void onReceive(Context context, Intent intent) {
                // TODO Auto-generated method stub
                String action = intent.getAction();
                if (action.equals(SEND_EMTOTION_ACTION)) {
//                    String emotionId = intent.getExtras().getString(EMOTION_ID);
//                    sendEmotionItem(emotionId);
                }else if(action.equals(SEND_MAGICICON_ACTION)){
                    String magicIconId = intent.getExtras().getString(MAGICICON_ID);
                    sendMagicIcon(magicIconId);
                }
            }
        };
        IntentFilter filter = new IntentFilter();
        filter.addAction(SEND_VOICE_ACTION);
        filter.addAction(SEND_EMTOTION_ACTION);
        filter.addAction(SEND_MAGICICON_ACTION);
//        registerReceiver(mBroadcastReceiver, filter);
        BroadcastManager.registerReceiver(mContext,mBroadcastReceiver, filter);
    }

    @Override
    protected void onTitleClicked() {
        super.onTitleClicked();
        if(mIsTitleClicked2Profile && !TextUtils.isEmpty(targetId)){
            AnchorProfileActivity.launchAnchorInfoActivty(this, getResources().getString(R.string.live_webview_anchor_profile_title),
                    targetId, false, AnchorProfileActivity.TagType.Album);
        }
    }

    /**
     * 初始化UI
     */
    @SuppressLint("ClickableViewAccessibility")
    private void initViews() {

        setTitleBodyGravity(Gravity.LEFT | Gravity.CENTER_VERTICAL);

        mAdapter = new LiveChatTalkAdapter(mContext , mDataList);
        mAdapter.setOnItemClickListener(new LiveChatTalkAdapter.OnItemClickListener() {
            @Override
            public void onResendClick(LiveMessageItem messageItem) {
                //重发
                showErrorSendNotify(messageItem);
            }

            @Override
            public void onAddCreditClick() {
                //充值
                LiveModule.getInstance().onAddCreditClick(mContext, new NoMoneyParamsBean());
            }

            @Override
            public void onErrorClicked(LCMessageItem lcMessageItem) {
                LiveChatTalkActivity.this.onErrorClicked(lcMessageItem);
            }

            @Override
            public void onVoiceItemClick(View v, LCMessageItem lcMessageItem) {
                if(mVoicePlayerManager.startPlayVoice(v, lcMessageItem.msgId,
                        lcMessageItem.getVoiceItem().filePath)){
                    lcMessageItem.getVoiceItem().setRead(mContext, true);
                }
            }

//            @Override
//            public void onResend(LCMessageItem lcMessageItem) {
//                onErrorClicked(lcMessageItem);
//            }
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
                if(mCanPullDownLoadMore) {
                    //本地根据第一条消息检测是否可以loadmore
//                    if(checkWhetherCanLoadMore()) {
//                        listLoadingHeader.setVisibility(View.VISIBLE);
//                        listLoadingHeader.setPadding(0, 0, 0, 0);
//                        //
//                        mTempPositonBeforeMore = mLinearLayoutManager.findLastVisibleItemPosition();
//                        //异步加载更多
//                        loadMorePrivateMessage();
//                    }else{
//                        mCanPullDownLoadMore = false;
//                    }
                }
                //更新列表位置状态
                mListScrollPosition = ListScrollPosition.TOP;
            }

            @Override
            public void onScrollToBottom() {
                //更新列表位置状态
                mListScrollPosition = ListScrollPosition.BOTTOM;
            }

            @Override
            public void onScrollStateChanged(int state) {
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
                hideInputArea(true);
                return false;
            }
        });

        //增加loading头
        listLoadingHeader = (LinearLayout) LayoutInflater.from(this).inflate(
                R.layout.item_list_view_header_loading, mRecyclerViewMsg.getRecyclerView().getFooterContainer(), false);
        listLoadingHeader.setVisibility(View.GONE);
        mRecyclerViewMsg.getRecyclerView().addHeaderView(listLoadingHeader);

        mEditText = (CustomEditText) findViewById(R.id.edt_msg);
        mEditText.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View view, MotionEvent motionEvent) {
                Log.i("jagger","onTouch-------> : "+motionEvent.getAction());
                //使用自己的方法弹出键盘
                if (motionEvent.getAction() == MotionEvent.ACTION_DOWN) {
                    Log.i("jagger","onTouch------->ACTION_DOWN : "+motionEvent.getAction());
                    showKeyBoard();
                }

//                showKeyBoard();
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
//                    mBtnSend.setButtonBackground(getResources().getColor(R.color.theme_sky_blue));
                    mBtnSend.setEnabled(true);
                }else{
//                    mBtnSend.setButtonBackground(getResources().getColor(R.color.black3));
                    mBtnSend.setEnabled(false);
                }
            }
        });
        mEditText.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView textView, int actionId, KeyEvent keyEvent) {
                boolean isCatch = false;
                switch (actionId) {
                    case EditorInfo.IME_ACTION_SEND:
                    case EditorInfo.IME_ACTION_UNSPECIFIED:{
                        sendTextMsg(mEditText.getText().toString());
                        mEditText.setText("");
                        isCatch = true;
                    }break;

                    default:
                        break;
                }

                return isCatch;
            }
        });

        mFrameLayoutInputArea = (FrameLayout)findViewById(R.id.fl_inputArea);
        mFrameLayoutFunctions = (FrameLayout)findViewById(R.id.fl_functions);

        mImageViewEmoji = (ImageView) findViewById(R.id.img_emoji);
        mImageViewEmoji.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
//                doOnShowKeyboardClicked();
                showEmojiBoard();
            }
        });

        mImageViewVoice = (ImageView) findViewById(R.id.img_voice);
        mImageViewVoice.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                showVoiceBoard();
            }
        });

        mBtnSend = findViewById(R.id.btn_send);
        mBtnSend.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                sendTextMsg(mEditText.getText().toString());
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
        if (bundle != null) {
            if (bundle.containsKey(CHAT_TARGET_ID)) {
                targetId = bundle.getString(CHAT_TARGET_ID);
            }
            if (bundle.containsKey(CHAT_TARGET_NAME)) {
                targetName = bundle.getString(CHAT_TARGET_NAME);
            }
            if (bundle.containsKey(CHAT_TARGET_PHOTO_URL)) {
                targetUrl = bundle.getString(CHAT_TARGET_PHOTO_URL);
            }
        }


        //QN liveChat逻辑
        if ((TextUtils.isEmpty(targetId))) {
            finish();
            return;
        } else {
            //title处理
            initTitle();

            //
            mKeyBoardHeight = KeyBoardManager.getKeyboardHeight(this);
//            Log.i("Jagger", "mKeyBoardHeight: " + mKeyBoardHeight);
            //edit by Jagger 2018-9-6
            //黑莓手机，有物理键盘，取出键盘高度只有 100＋PX，效果不好。如果取出键盘高度，小于min_keyboard_height，就用默认的吧
            if (mKeyBoardHeight < getResources().getDimensionPixelSize(R.dimen.min_keyboard_height)) {
                mKeyBoardHeight = getResources().getDimensionPixelSize(R.dimen.min_keyboard_height);
            }

            /* 初始化正在聊天对象，方便统计未读 */
            mContactManager.mWomanId = targetId;
            mContactManager.clearContactUnreadCount(targetId);

            /* 初始化未读条数 */
            unreadCount = mContactManager.getAllUnreadCount();
            //TODO
//                if (unreadCount > 0) {
//                    tvUnread.setText("" + unreadCount);
//                    tvUnread.setVisibility(View.VISIBLE);
//                } else {
//                    tvUnread.setVisibility(View.GONE);
//                }

            /* 是否在聊天列表（即有消息来往） */
            chatTarget = mLiveChatManager.GetUserWithId(targetId);

            if (chatTarget != null) {
                /* 未开始聊天获取试聊状态 */
                if (!chatTarget.isInSession()) {
                    checkTrychat(chatTarget.userId);
                } else if (chatTarget.isPaused()) {
                    //检测会话是否暂停，暂停添加"暂停提示"
                    LCMessageItem msg = chatTarget.getLastMessage();
                    //最后一条消息
                    if (msg != null) {
                        //如果它是通知
                        if (msg.msgType == LCMessageItem.MessageType.Notify) {
                            //且 不是暂停通知
                            if (msg.getNotifyItem() != null && msg.getNotifyItem().notifyType != LCNotifyItem.NotifyType.Session_Pause) {
                                mLiveChatManager.BuildAndInsertNotifyMsg(targetId, LCNotifyItem.NotifyType.Session_Pause, null);
                            }
                        } else {
                            //它是非通知类型时 要显示
                            mLiveChatManager.BuildAndInsertNotifyMsg(targetId, LCNotifyItem.NotifyType.Session_Pause, null);
                        }
                    }
                }

                /*
                 * 加载历史消息
                 * 一定要放在"添加暂停提示"之后,以免出现添加暂停提示却没看到,要下一次进入才能看到  的情况
                 * edit by Jagger 2017-5-17
                 * */
                List<LCMessageItem> tempMsgList = chatTarget.getCurrentSessionMsgList();
                if (!tempMsgList.isEmpty()) {
                    showMsgBeans(tempMsgList, true);
                } else if (chatTarget.isInSession()) {
                    mLiveChatManager.GetHistoryMessage(chatTarget.userId);
                }
            }

            /*检测聊天女士是否在线*/
            mLiveChatManager.GetUserStatus(new String[]{targetId});

            /*检测聊天女士Cam状态*/
//            mLiveChatManager.GetLadyCamStatus(targetId);
        }
    }

    /**
     * 初始化Title
     */
    private void initTitle(){
        //title处理
        if (!TextUtils.isEmpty(targetName)) {
            setTitle(targetName, R.color.theme_default_black);
        } else {
            setTitle(getString(R.string.my_message_title), R.color.theme_default_black);
        }
        setTitleImage(targetUrl, TITLE_IMAGE_IS_CIRCLE, R.drawable.ic_default_photo_woman);
        addTitleRightMenu(R.drawable.ic_live_title_menu_pop, new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                showTitleMoreMenu(ll_title_right);
            }
        });

        //取个人信息
        if(TextUtils.isEmpty(targetUrl)){
            doGetUserInfo();
        }
    }

    /**
     * title右则弹出菜单
     * @param view
     */
    private void showTitleMoreMenu(View view){
        // 这里的view代表popupMenu需要依附的view
        mTitlePopupMenu = new PopupMenu(this, view);
        // 获取布局文件
        mTitlePopupMenu.inflate(R.menu.live_chat_title_menu);

        LCUserItem userItem = LiveChatManager.getInstance().GetUserWithId(targetId);
        //重置状态
        endTalkMenuStatus = EndTalkMenuStatus.END_CHAT;
        Log.i("Jagger" , "showTitleMoreMenu userItem:" + (userItem == null));
        if(userItem != null){
            Log.i("Jagger" , "showTitleMoreMenu isInSession:" + userItem.isInSession() );
            if(userItem.isInSession()){
                endTalkMenuStatus = EndTalkMenuStatus.END_CHAT;

                mTitlePopupMenu.getMenu().clear();
                mTitlePopupMenu.inflate(R.menu.live_chat_title_menu_inchat);
            }else if(userItem.isInManInvite()){
                endTalkMenuStatus = EndTalkMenuStatus.MAN_INVITE;

                mTitlePopupMenu.getMenu().clear();
                mTitlePopupMenu.inflate(R.menu.live_chat_title_menu);
            }else if(userItem.isInLadyInvite()){
                endTalkMenuStatus = EndTalkMenuStatus.LADY_INVITE;

                mTitlePopupMenu.getMenu().clear();
                mTitlePopupMenu.inflate(R.menu.live_chat_title_menu_inchat);
            }
        }

        // 通过上面这几行代码，就可以把控件显示出来了
        mTitlePopupMenu.setOnMenuItemClickListener(new PopupMenu.OnMenuItemClickListener() {
            @Override
            public boolean onMenuItemClick(MenuItem item) {
                // 控件每一个item的点击事件
                if(item.getItemId() == R.id.chat_menu_end_chat || item.getItemId() == R.id.chat_menu_cancel_invitation){
                    doEndChat();
                }
                return true;
            }
        });

        mTitlePopupMenu.show();
    }

    /**
     *　初始化表情列表
     */
    private void initEmojiView(){
        //TODO
        final FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();
        if(mNormalExprssionFragment == null){
            mNormalExprssionFragment = new NormalExprssionFragment();
        }
        transaction.replace(R.id.fl_functions, mNormalExprssionFragment);
        transaction.commitAllowingStateLoss();
        mFrameLayoutFunctions.setVisibility(View.INVISIBLE);
    }

    /**
     *　初始语音
     */
    private void initVoiceView(){
        //TODO
        final FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();
        if(mVoiceRecordFragment == null){
            mVoiceRecordFragment = new VoiceRecordFragment();
        }
        transaction.replace(R.id.fl_functions, mVoiceRecordFragment);
        transaction.commitAllowingStateLoss();
        mFrameLayoutFunctions.setVisibility(View.INVISIBLE);
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
     * 判断当前recycle是否停留在底部
     * @return
     */
    public boolean isRecycleViewBottom() {
//        Log.i("Jagger" , "isRecycleViewBottom:" + mListScrollPosition.name());

        boolean result=false;
        if(mListScrollPosition == ListScrollPosition.BOTTOM){
            result = true;
        }
        return  result;
    }

    /**
     * 显示输入区
     */
    private void showInputArea(){
        int inputAreaHeight = 0;
        if(mInputAreaStatus == InputAreaStatus.KEYBOARD){
            //输入区, 使用键盘高度真实
            inputAreaHeight = mKeyBoardHeight;
        }else{
            //因为黑霉手机有物理键盘,当虚拟键盘很小时,mKeyBoardHeight只有100+PX,表情区会显示不全,使用最小高度.
            inputAreaHeight = mKeyBoardHeight < getResources().getDimensionPixelSize(R.dimen.min_keyboard_height)?getResources().getDimensionPixelSize(R.dimen.min_keyboard_height):mKeyBoardHeight;
        }

        //
        ViewGroup.LayoutParams layoutParams = mFrameLayoutInputArea.getLayoutParams();
        if(layoutParams.height < 1){
            layoutParams.height = inputAreaHeight;
            mFrameLayoutInputArea.setLayoutParams(layoutParams);
            mFrameLayoutInputArea.invalidate();
        }

        //更改界面InputMode, 已弹出输入区,则可以用ADJUST_PAN,当弹出输入法时不会跳动
        getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_PAN| WindowManager.LayoutParams.SOFT_INPUT_STATE_HIDDEN);
    }

    /**
     * 隐藏输入区
     */
    private void hideInputArea(boolean isHideKeyBoard){
        if (mInputAreaStatus == InputAreaStatus.HIDE) {
              return;
        }

        Log.i("Jagger" ,"hideInputArea---: "+ mInputAreaStatus);
        if (isHideKeyBoard) {
            hideKeyBoard();
        }

        mInputAreaStatus = InputAreaStatus.HIDE;
        //延迟一些，以免界面跳动
//        postUiRunnableDelayed(new Runnable() {
//            @Override
//            public void run() {
                //
                ViewGroup.LayoutParams layoutParams = mFrameLayoutInputArea.getLayoutParams();
                if(layoutParams.height > 0){
                    layoutParams.height = 0;
                    mFrameLayoutInputArea.setLayoutParams(layoutParams);
                }

                //更改图标
//                doChangeBtnStatus(InputChangeBtnStaus.FUNCTIONS);

                //更改界面InputMode, 隐藏输入区,则可以用ADJUST_RESIZE,使系统自动适配输入法弹出时窗口缩放
                getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE);
//            }
//        } , 50);
    }

    /**
     * 显示输入法
     */
    private void showKeyBoard(){
        if(mInputAreaStatus == InputAreaStatus.KEYBOARD) return;
        Log.i("Jagger" ,"showKeyBoard" );

        //与其它控件显示关系的约束，最好不要乱改
        // ***start***
        if(mInputAreaStatus != InputAreaStatus.FUNCTIONS){
            hideInputArea(false);
            hideFunctionsBoard();
        }
        showSoftInput(mEditText);
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
        initEmojiView();
        //隐藏键盘
        hideKeyBoard();
        //更改图标
//        doChangeBtnStatus(InputChangeBtnStaus.KEYBOARD);
        //更改为另一种状态
        mInputAreaStatus = InputAreaStatus.FUNCTIONS;
        showInputArea();
        //显示
        mFrameLayoutFunctions.setVisibility(View.VISIBLE);
        //回调
        onEmojiBoardShow();
        // ***end***
    }

    /**
     * 显示录音器
     */
    private void showVoiceBoard(){
        Log.i("Jagger" ,"showVoiceBoard" );

        //与其它控件显示关系的约束，最好不要乱改
        // ***start***
        initVoiceView();
        //隐藏键盘
        hideKeyBoard();
        //更改图标
//        doChangeBtnStatus(InputChangeBtnStaus.KEYBOARD);
        //更改为另一种状态
        mInputAreaStatus = InputAreaStatus.FUNCTIONS;
        showInputArea();
        //显示
        mFrameLayoutFunctions.setVisibility(View.VISIBLE);
        //回调
        onEmojiBoardShow();
        // ***end***
    }

    /**
     * 隐藏功能区
     */
    private void hideFunctionsBoard(){
        Log.i("Jagger" ,"hideFunctionsBoard" );

        //与其它控件显示关系的约束，最好不要乱改
        // ***start***
        mFrameLayoutFunctions.setVisibility(View.INVISIBLE);
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
        Log.i("Jagger" , "OnSoftPop----mInputAreaStatus:" + height+"----> "+mInputAreaStatus);

        //与其它控件显示关系的约束，最好不要乱改
        // ***start***
        if(mKeyBoardHeight != height){
            mKeyBoardHeight = height;
            KeyBoardManager.saveKeyboardHeight(mContext , height);
        }

        /*
            2019/1/14 Hardy
            问题：https://www.qoogifts.com.cn/zentaopms2/www/index.php?m=bug&f=view&bugID=15955
            原因：
            黑莓手机的软键盘中文输入法，有一般输入法和快捷输入法（高度比较小）。当调用中文软键盘时，先弹出一般输入法，再弹出快捷输入法，这个过程间隔 0.5s 左右
            所以在 SoftKeyboardSizeWatchLayout 监听布局变化时，会回调 2 次 OnSoftPop
            第一次 OnSoftPop，mInputAreaStatus 设置为 InputAreaStatus.KEYBOARD
            第二次 OnSoftPop，hideInputArea() 方法里检测 mInputAreaStatus == InputAreaStatus.KEYBOARD ? 若是，则调用 hideSoftInput(mEditText , true);
            故导致软键盘弹出后会被马上隐藏。
         */
        if (mInputAreaStatus == InputAreaStatus.KEYBOARD){
            return;
        }

        hideInputArea(false);
        doScrollToBottom();
        //更改图标
//        doChangeBtnStatus(InputChangeBtnStaus.FUNCTIONS);
        //更改为另一种状态
        mInputAreaStatus = InputAreaStatus.KEYBOARD;
        // ***end***
    }

    /**
     * 键盘收起响应
     */
    @Override
    public void OnSoftClose() {
        Log.i("Jagger" , "OnSoftClose----mInputAreaStatus: "+mInputAreaStatus);

        //与其它控件显示关系的约束，最好不要乱改
        // ***start***
        doScrollToBottom();
        if(mInputAreaStatus == InputAreaStatus.KEYBOARD){
            hideInputArea(true);
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

    /**
     * 设置不能下拉刷新更多
     * @param enable
     */
//    private void setCanPullDownMoreEnable(boolean enable){
//        mCanPullDownLoadMore = enable;
//    }

    /**********************************************  emji小表情选中 start ***********************************************/

    /**
     * 选择表情
     *
     * @param val
     */
    @SuppressWarnings("deprecation")
    public void selectEmotion(int val) {

        if(MAX_EDITTEXT_LENGTH - mEditText.getText().toString().length() < 8){
            //小表情占用字符串长度最大为8，字符串长度不够，拦截输入
            return;
        }

        int imgId = 0;
        try {
            imgId = R.drawable.class.getDeclaredField("e" + val).getInt(null);
        } catch (Exception e) {
            e.printStackTrace();
        }
        if (imgId != 0) {
            int textSize = getResources().getDimensionPixelSize(
                    R.dimen.expre_drawable_size);
            Drawable drawable = getResources().getDrawable(imgId);
            drawable.setBounds(0, 0, textSize, textSize);
            ImageSpan imgSpan = new ImageSpan(drawable, ImageSpan.ALIGN_BOTTOM);
            String code = "[img:" + val + "]";
            SpannableString ss = new SpannableString(code);
            ss.setSpan(imgSpan, 0, code.length(),
                    Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
            mEditText.getEditableText().insert(mEditText.getSelectionStart(),
                    ss);
        }
    }


    /**********************************************  emji小表情选中 end ***********************************************/

    /**********************************************  liveChatManager相关业务start  ***********************************************/

    @SuppressWarnings("unchecked")
    @Override
    protected void handleUiMessage(Message msg) {
        // TODO Auto-generated method stub
        super.handleUiMessage(msg);
        switch (msg.what) {
            case RECEIVE_CHAT_MESSAGE:
                LCMessageItem item = (LCMessageItem) msg.obj;
                /* 不是发给当前聊天且在联系人列表，更新未读条数 */
                if (!item.fromId.equals(targetId)
                        && (mContactManager.isMyContact(item.fromId))) {
                    unreadCount++;
//                    tvUnread.setVisibility(View.VISIBLE);
//                    tvUnread.setText("" + unreadCount);
                }
                appendMsg(item);
                break;
            case RECEIVE_CHECK_SEND_MESSAGE_ERROR:
                /* 底层判断无试聊券，无钱发送邀请失败处理 */
                LiveChatClientListener.LiveChatErrType errType = LiveChatClientListener.LiveChatErrType.values()[msg.arg1];
                List<LCMessageItem> msgCallbackList = (List<LCMessageItem>) msg.obj;
                if ((errType == LiveChatClientListener.LiveChatErrType.NoMoney)&&(containSelf(msgCallbackList, targetId))) {
                    /* 无信用点提示充值 */
                    showCreditNoEnoughDialog(R.string.live_programme_get_ticket_not_enough_money_tips);
                }
                for (LCMessageItem msgItem : msgCallbackList) {
                    msgItem.setLiveChatErrType(errType);
                }
                doUpdateSendMessageCallback(msgCallbackList);
                break;
            case SEND_MESSAGE_CALLBACK:
                /* 发送消息成功与否回调更新界面处理 */
                LiveChatCallBackItem callBack = (LiveChatCallBackItem) msg.obj;

                LCMessageItem itemCallBack = (LCMessageItem) callBack.body;
                itemCallBack.setLiveChatErrType(LiveChatClientListener.LiveChatErrType.values()[callBack.errType]);
                Log.i("Jagger" , "SEND_MESSAGE_CALLBACK callBack.errType:" + LiveChatClientListener.LiveChatErrType.values()[callBack.errType].name());
                doUpdateSendMessageCallback(itemCallBack);
                break;
            case GET_HISTORY_MESSAGE_UPDATE:
                List<LCMessageItem> tempMsgList = chatTarget.getCurrentSessionMsgList();
                Log.i("Jagger" , "GET_HISTORY_MESSAGE_UPDATE:" + tempMsgList.size());
                showMsgBeans(tempMsgList, true);
                break;
            case CHECK_COUPON_UPDATE:
                /* 检测试聊券成功返回处理 */
                chatChargeNofity((Coupon) msg.obj);
                break;
            case END_CHAT:
                finish();
                break;
            case REQUEST_ADD_FAVOUR_SUCCESS: {
                showToastDone("Added!");
                }
                break;
            case REQUEST_ADD_FAVOUR_FAIL: {
                // 收藏失败
                LiveChatCallBackItem obj = (LiveChatCallBackItem) msg.obj;
                Toast.makeText(this, obj.errMsg, Toast.LENGTH_LONG).show();
                }
                break;
            case TARGET_PHOTO_UPDATE:
                //更新广播信息 和 头像
                LiveChatCallBackItem obj = (LiveChatCallBackItem) msg.obj;
                UserInfoItem userInfoItem = (UserInfoItem)obj.body;
                targetUrl = userInfoItem.photoUrl;
                setTitleImage(userInfoItem.photoUrl, TITLE_IMAGE_IS_CIRCLE, R.drawable.ic_default_photo_woman);
                break;
            case GET_TARGET_STATUS_CALLBACK:
                // 态改变界面更新
                LCUserItem userItem = (LCUserItem) msg.obj;
                if((userItem != null) && (userItem.statusType != LiveChatClient.UserStatusType.USTATUS_ONLINE)){
                    showOffLineDialog();
                }
                break;
            case GET_MAGIC_ICON_SUCCESS:
                mAdapter.notifyDataSetChanged();
                break;
        }
    }

    /**
     * 发送消息回调处理
     * TODO:测试是否会有边刷新,边滑动会死.因为同时操作mDataList
     * @param lcMessageItemsCallBack
     */
    private void doUpdateSendMessageCallback(List<LCMessageItem> lcMessageItemsCallBack){
        for (LCMessageItem msgItemCallBack : lcMessageItemsCallBack) {
            doUpdateSendMessageCallback(msgItemCallBack);
        }
    }

    /**
     * 发送消息回调处理
     * TODO:测试是否会有边刷新,边滑动会死.因为同时操作mDataList
     * @param msgItemCallBack
     */
    private void doUpdateSendMessageCallback(LCMessageItem msgItemCallBack){

        for(int i = 0 ; i < mDataList.size(); i++){
            if (msgItemCallBack != null && (msgItemCallBack.sendType == LCMessageItem.SendType.Send)) {
                if(mDataList.get(i).msgId == msgItemCallBack.msgId){
                    mDataList.get(i).setLiveChatErrType(msgItemCallBack.getLiveChatErrType());
                    mDataList.get(i).statusType = msgItemCallBack.statusType;
                    mAdapter.notifyItemChanged(i);
                }
            }
        }
    }

    /**
     * 发送
     * @param message
     */
    private void sendTextMsg(String message){
        //纯空格，按钮可点击，但不发送，且清空已键入空格
        if(TextUtils.isEmpty(message.replaceAll(" ","").replaceAll("\r" , "").replaceAll("\n",""))){
            return;
        }

        //TODO
        LCMessageItem item = mLiveChatManager.SendMessage(chatTarget.userId, message, LiveChatClient.InviteStatusType.INVITE_TYPE_CHAT);

        //GA统计
        onAnalyticsEvent(getString(R.string.Live_LiveChat_Category)
                , getString(R.string.Live_LiveChat_Action_SendMessage)
                , getString(R.string.Live_LiveChat_Label_SendMessage));

        appendMsg(item);

        if (item != null) {
            ContactManager.getInstance().updateOrAddContactBySendMessage(targetId, targetName, targetUrl);
        }

    }

    /**
     * 发送语音
     */
    public void sendVoiceItem(String savePath, long recordTime) {
        Log.i("Jagger" , "LiveChatTalkActivity sendVoiceItem recordTime:" + recordTime);

        if (!hasLadyInvited()) {
            // 判断是否有女士发来消息，否则不让发语音
//            DialogUIUtils.showAlert(mContext, "",
//                    getString(R.string.livechat_can_not_send_voice_message_before_the_conversation_has_started),
//                    getString(R.string.common_btn_ok),
//                    true, true,
//                    new DialogUIListener() {
//                        @Override
//                        public void onPositive() {
//
//                        }
//
//                        @Override
//                        public void onNegative() {
//
//                        }
//                    }).show();
            MaterialDialogAlert dialog = new MaterialDialogAlert(this);
            dialog.setMessageCenter(getString(R.string.livechat_can_not_send_voice_message_before_the_conversation_has_started));
            dialog.addButton(dialog.createButton(
                    getString(R.string.common_btn_ok), null));
            dialog.show();
            return;
        }

        if(recordTime < 1){
            //录音时长小于1秒，提示不发送
            Toast.makeText(this, getString(R.string.livechat_record_voice_too_short), Toast.LENGTH_SHORT).show();
            return;
        }

        LCMessageItem item = mLiveChatManager.SendVoice(chatTarget.userId,
                savePath, "aac", (int) recordTime);

        //GA统计
        onAnalyticsEvent(getString(R.string.Live_LiveChat_Category)
                , getString(R.string.Live_LiveChat_Action_SendVoice)
                , getString(R.string.Live_LiveChat_Label_SendVoice));

        appendMsg(item);
        if (item != null) {
            ContactManager.getInstance().updateOrAddContactBySendMessage(targetId, targetName, targetUrl);
        }
    }

    /**
     * 发送小高级表情
     * @param magicIconId
     */
    public void sendMagicIcon(String magicIconId) {
        // Log.i("hunter", "sendPrivatePhoto photoPath: " + photoPath);
        if (!chatTarget.isInSession()) {
            /* 发送图片必须建立会话才能发送 */
            MaterialDialogAlert dialog = new MaterialDialogAlert(this);
            dialog.setMessageCenter(getString(R.string.livechat_can_not_send_premium_sticker_before_the_conversation_has_started));
            dialog.addButton(dialog.createButton(
                    getString(R.string.common_btn_ok), null));
            dialog.show();
            return;
        }

        LCMessageItem item = mLiveChatManager.SendMagicIcon(chatTarget.userId,
                magicIconId);
        //GA统计
        onAnalyticsEvent(getString(R.string.Live_LiveChat_Category)
                , getString(R.string.Live_LiveChat_Action_SendSticker)
                , getString(R.string.Live_LiveChat_Label_SendSticker));

        appendMsg(item);
        if (item != null) {
            ContactManager.getInstance().updateOrAddContactBySendMessage(targetId, targetName, targetUrl);
        }
    }

    /**
     * 点击发送出错按钮，弹出提示
     * @param messageItem
     */
    private void showErrorSendNotify(final LiveMessageItem messageItem){
        //TODO
    }

    /**
     * 加载更多
     */
    private void loadMorePrivateMessage(){
        //TODO
//        mLMManager.GetMorePrivateMsgWithUserId(mUserId);
    }

    /**
     * 点击重发
     */
    private void onErrorClicked(final LCMessageItem item){
        LiveChatClientListener.LiveChatErrType errType = item.getLiveChatErrType();
        Log.i("Jagger" , "LiveChatTalkActivity onErrorClicked:" + errType.name());

        if (errType == LiveChatClientListener.LiveChatErrType.SideOffile
                || errType == LiveChatClientListener.LiveChatErrType.UnbindInterpreter
                || errType == LiveChatClientListener.LiveChatErrType.BlockUser) {
            showOffLineDialog();
        }else if (errType == LiveChatClientListener.LiveChatErrType.NoMoney) {
            showNoMoney(item);
        }else if (errType == LiveChatClientListener.LiveChatErrType.InvalidUser
                || errType == LiveChatClientListener.LiveChatErrType.InvalidPassword
                || errType == LiveChatClientListener.LiveChatErrType.CheckVerFail
                || errType == LiveChatClientListener.LiveChatErrType.LoginFail
                || errType == LiveChatClientListener.LiveChatErrType.CanNotSetOffline) {
            doReLogin();
        }else{
            showResendDialog(item);
        }
    }

    /**
     * 重发
     * @param item
     */
    private void resendMsgItem(LCMessageItem item){
        if(item != null){
            //TODO
//            if (mPositionMap.containsKey(item.msgId)) {
//                int position = mPositionMap.get(item.msgId);
//                View row = getContainer().getChildAt(position);
//                row.setVisibility(GONE);
//                /* 消息重发，删除列表中旧消息 */
//                mLiveChatManager.RemoveHistoryMessage(item);
//            }
//            LCMessageItem newItem = null;
//            switch (item.msgType) {
//                case Text:
//                    newItem = mLiveChatManager.SendMessage(item.toId,
//                            item.getTextItem().message, LiveChatClient.InviteStatusType.INVITE_TYPE_CHAT);
//                    break;
//                case Emotion:
//                    newItem = mLiveChatManager.SendEmotion(item.toId,
//                            item.getEmotionItem().emotionId);
//                    break;
//                case Photo:
//                    newItem = mLiveChatManager.SendPhoto(item.toId,
//                            item.getPhotoItem().srcFilePath);
//                    break;
//                case Voice:
//                    newItem = mLiveChatManager.SendVoice(item.toId,
//                            item.getVoiceItem().filePath, ".aac",
//                            item.getVoiceItem().timeLength);
//                    break;
//                case MagicIcon:
//                    newItem = mLiveChatManager.SendMagicIcon(item.toId,
//                            item.getMagicIconItem().getMagicIconId());
//                    break;
//                default:
//                    break;
//            }
//
//            addRow(newItem);
//            scrollToBottom(true);

            if(mDataList.contains(item)){
                mDataList.remove(item);
                mLiveChatManager.RemoveHistoryMessage(item);
            }

            LCMessageItem newItem = null;
            switch (item.msgType) {
                case Text:
                    newItem = mLiveChatManager.SendMessage(item.toId,
                            item.getTextItem().message, LiveChatClient.InviteStatusType.INVITE_TYPE_CHAT);
                    break;
                case Emotion:
                    newItem = mLiveChatManager.SendEmotion(item.toId,
                            item.getEmotionItem().emotionId);
                    break;
                case Photo:
                    newItem = mLiveChatManager.SendPhoto(item.toId,
                            item.getPhotoItem().srcFilePath);
                    break;
                case Voice:
                    newItem = mLiveChatManager.SendVoice(item.toId,
                            item.getVoiceItem().filePath, ".aac",
                            item.getVoiceItem().timeLength);
                    break;
                case MagicIcon:
                    newItem = mLiveChatManager.SendMagicIcon(item.toId,
                            item.getMagicIconItem().getMagicIconId());
                    break;
                default:
                    break;
            }
//            mDataList.add(newItem);
//            mAdapter.notifyDataSetChanged();
//            doScrollToBottom();
            appendMsg(newItem);
        }
    }

    /**
     * 是否女士发来了消息
     *
     * @return
     */
    public boolean hasLadyInvited() {
        int index = 0;
        while (mDataList.size() > index) {
            LCMessageItem bean = mDataList.get(index);
            if (bean.sendType == LCMessageItem.SendType.Recv) {
                return true;
            }
            index++;
        }
        return false;
    }

    /**
     * 检测是否可以使用试聊券
     *
     * @param userId
     */
    private void checkTrychat(String userId) {
        boolean success = mLiveChatManager.CheckCoupon(userId);
        if (!success) {
            /* 调用接口失败 */
            chatChargeNofity(null);
        }
    }

    /**
     * 判断是否需要显示会话暂停提示
     */
    private boolean isChatPause(){
        boolean isPause = true;
        if(chatTarget.isPaused()){
            LCMessageItem msg = chatTarget.getTheSendLastMessage();
            //找到自己发出的消息 并 消息没发送失败 并 消息时间超过10分钟
            if(msg != null && msg.statusType != LCMessageItem.StatusType.Fail && (LCMessageItem.GetCreateTime() - msg.createTime < 5 * 60)){
                isPause = false;
            }
        }else{
            isPause = false;
        }

        return isPause;
    }

    /**
     * 邀请或者other状态时，提示资费情况或使用试聊券
     *
     * @param coupon
     */
    private void chatChargeNofity(Coupon coupon) {
        LCMessageItem message = new LCMessageItem();
        message.sendType = LCMessageItem.SendType.Send;
        if (coupon == null) {
            /* 获取试聊券失败，提示资费信息 */
            LCSystemItem systemItem = new LCSystemItem();
            systemItem.message = getString(R.string.livechat_charge_terms);
            message.setSystemItem(systemItem);
        } else {
            if (coupon.status == Coupon.CouponStatus.Yes
                    || coupon.status == Coupon.CouponStatus.Started) {
                message.msgType = LCMessageItem.MessageType.Custom;
            } else {
                /* 获取试聊券成功，但无试聊券，提示资费信息 */
                LCSystemItem systemItem = new LCSystemItem();
                systemItem.message = getString(R.string.livechat_charge_terms);
                message.setSystemItem(systemItem);
            }
        }
        appendMsg(message);
    }

    /**
     * 是否包括当前用户
     * @param msgList
     * @param id
     * @return
     */
    private boolean containSelf(List<LCMessageItem> msgList, String id){
        boolean containSelf = false;
        if((msgList != null) && (msgList.size() > 0)){
            for(LCMessageItem item : msgList){
                if((item != null)&&(item.getUserItem() != null)){
                    String usrId = item.getUserItem().userId;
                    if(usrId.equals(id)){
                        containSelf = true;
                        break;
                    }
                }
            }
        }
        return containSelf;
    }

    /**
     * 发送消息成功与否回调
     *
     * @param item
     */
    private void onSendMessageUpdate(LiveChatCallBackItem item) {
        Message msg = Message.obtain();
        msg.what = SEND_MESSAGE_CALLBACK;
        msg.obj = item;
        sendUiMessage(msg);
    }

    /**
     * 收到聊天信息回调主界面处理
     *
     * @param item
     */
    private void onReceiveMsgUpdate(LCMessageItem item) {
        Message msg = Message.obtain();
        msg.what = RECEIVE_CHAT_MESSAGE;
        msg.obj = item;
        sendUiMessage(msg);
    }

    /**
     * 获取聊天历史返回，更新消息列表
     *
     * @param userItem
     */
    private void onGetHistoryMessageCallback(LCUserItem userItem) {
        if ((userItem != null) && (userItem.userId != null)
                && (userItem.userId.equals(targetId))) {
            /* 当前用户的消息历史返回才处理 */
            Message msg = Message.obtain();
            msg.what = GET_HISTORY_MESSAGE_UPDATE;
            msg.obj = userItem;
            sendUiMessage(msg);
        }
    }

    /**
     * 试聊券查询
     *
     * @param item
     */
    private void onCheckCouponCallback(Coupon item) {
        Message msg = Message.obtain();
        msg.what = CHECK_COUPON_UPDATE;
        msg.obj = item;
        sendUiMessage(msg);
    }

    /**
     * 底层检测试聊有钱与否，返回出错信息列表处理
     *
     * @param errType
     * @param msgList
     */
    private void onReceiveMsgList(LiveChatClientListener.LiveChatErrType errType,
                                  ArrayList<LCMessageItem> msgList) {
        Message msg = Message.obtain();
        msg.what = RECEIVE_CHECK_SEND_MESSAGE_ERROR;
        msg.arg1 = errType.ordinal();
        msg.obj = msgList;
        sendUiMessage(msg);
    }

    public void appendMsg(LCMessageItem msgBean) {
        // 更新视图
        if (msgBean != null) {
            mDataList.add(msgBean);
            mAdapter.notifyDataSetChanged();
            doScrollToBottom();
        } else {
//            DialogUIUtils.showAlert(mContext, "",
//                    getString(R.string.live_chat_kickoff_by_sever_update),
//                    getString(R.string.txt_login),
//                    getString(R.string.common_btn_cancel),
//                    0, 0,
//                    false, false,
//                    new DialogUIListener() {
//                        @Override
//                        public void onPositive() {
//            /* 由于未登录成功等原因，底层认为异常返回空，跳去登陆处理,首先注销php登陆 */
//            LoginManager.getInstance().logout(true);
//            String liveChatUrl = URL2ActivityManager.createLiveChatActivityUrl(targetName, targetId, targetUrl);
//            URL2ActivityManager.getInstance().URL2Activity(mContext , liveChatUrl);
//                        }
//
//                        @Override
//                        public void onNegative() {
//
//                        }
//                    }
//            ).show();

            MaterialDialogAlert dialog = new MaterialDialogAlert(this);
            dialog.setMessageCenter(getString(R.string.live_chat_kickoff_by_sever_update));
            dialog.addButton(dialog.createButton(getString(R.string.login),
                    new View.OnClickListener() {

                        @Override
                        public void onClick(View v) {
                            /* 由于未登录成功等原因，底层认为异常返回空，跳去登陆处理,首先注销php登陆 */
//                            LoginManager.newInstance(ChatActivity.this).LogoutAndClean(false, true);
//
//                            Intent intent = new Intent(ChatActivity.this,
//                                    HomeActivity.class);
//                            intent.putExtra(HomeActivity.NEED_RELOGIN_OPERATE,
//                                    true);
//                            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
//                            startActivity(intent);

                            /* 由于未登录成功等原因，底层认为异常返回空，跳去登陆处理,首先注销php登陆 */
                            doReLogin();
                        }
                    }));
            dialog.addButton(dialog.createButton(
                    getString(R.string.common_btn_cancel), null));

            dialog.show();

        }
    }

    /**
     * 显示消息列表
     *
     * @param msgBeans
     * @param smooth
     */
    private void showMsgBeans(List<LCMessageItem> msgBeans, boolean smooth) {
        synchronized (msgBeans)
        {
//            msgList.replaceAllRow(msgBeans);
            mDataList.clear();
            mDataList.addAll(msgBeans);
            mAdapter.notifyDataSetChanged();
        }
//        msgList.scrollToBottom(smooth);
        doScrollToBottom();
    }

    /**
     * 发送消息失败（男士余额不足），点击重发按钮提示
     */
    private void showNoMoney(final LCMessageItem item){
        MaterialDialogAlert dialog = new MaterialDialogAlert(mContext);
        dialog.setMessage(mContext
                .getString(R.string.send_error_not_enough_money));
        dialog.addButton(dialog.createButton(
                mContext.getString(R.string.common_btn_retry),
                new View.OnClickListener() {

                    @Override
                    public void onClick(View v) {
                        resendMsgItem(item);
                    }
                }));
        dialog.addButton(dialog.createButton(
                mContext.getString(R.string.common_btn_cancel),
                new View.OnClickListener() {

                    @Override
                    public void onClick(View v) {

                    }

                }));

        dialog.show();
    }

    /**
     * 主播离线对话框
     */
    private void showOffLineDialog(){
        MaterialDialogAlert dialog = new MaterialDialogAlert(this);
        dialog.setMessage(mContext.getString(R.string.send_error_lady_offline));
        dialog.addButton(dialog.createButton("ok", null));
        dialog.show();
    }

    /**
     * 重发对话框
     */
    private void showResendDialog(final LCMessageItem item){
//        DialogUIUtils.showAlert(mContext, "",
//                getString(R.string.send_error_text_normal),
//                getString(R.string.common_btn_retry),
//                getString(R.string.common_btn_cancel),
//                0, 0,
//                true,
//                true,
//                new DialogUIListener() {
//                    @Override
//                    public void onPositive() {
//                        resendMsgItem(item);
//                    }
//
//                    @Override
//                    public void onNegative() {
//
//                    }
//                }
//        ).show();

        MaterialDialogAlert dialog = new MaterialDialogAlert(mContext);
        dialog.setMessageCenter(mContext
                .getString(R.string.send_error_text_normal));
        dialog.addButton(dialog.createButton(
                mContext.getString(R.string.common_btn_retry),
                new View.OnClickListener() {

                    @Override
                    public void onClick(View v) {
                        resendMsgItem(item);
                    }
                }));
        dialog.addButton(dialog.createButton(
                mContext.getString(R.string.common_btn_cancel),
                new View.OnClickListener() {

                    @Override
                    public void onClick(View v) {

                    }

                }));

        dialog.show();
    }

    /**
     * 当开始录音或回收时，关掉所有录音
     */
    public void stopAllVoicePlaying() {
        if (mVoicePlayerManager != null) {
            mVoicePlayerManager.stopPlaying();
        }
    }

    /**
     * 取消邀请/结束会话
     */
    private void doEndChat(){
        LCUserItem userItem = mLiveChatManager.GetUserWithId(targetId);
        //如果是男士邀请
        if (endTalkMenuStatus == EndTalkMenuStatus.MAN_INVITE) {
            if (userItem != null) {
                if (userItem.isInSession()) {
                    //点击cancel按钮时，实际状态为会话中，则通知用户无法取消
                    mLiveChatManager.BuildAndInsertSystemMsg(targetId, getResources().getString(R.string.livechat_cancel_invite_cannnot_in_chat));
                } else {
                    if (userItem.isInManInviteCanCancel()) {
                        mLiveChatManager.EndTalkNeedWait(targetId);
                    } else {
                        //男士发送邀请1分钟以内不可取消
                        mLiveChatManager.BuildAndInsertSystemMsg(targetId, getResources().getString(R.string.livechat_cancel_invite_cannnot_in_1minute));
                    }
                }
            }
        } else if (endTalkMenuStatus == EndTalkMenuStatus.LADY_INVITE) {
            //不结束会话
            finish();
        } else {
            //结束会话
            mLiveChatManager.EndTalkNeedWait(targetId);
        }
    }

    /**
     * 由于未登录成功等原因，底层认为异常返回空，跳去登陆处理,首先注销php登陆
     */
    private void doReLogin(){
        LoginManager.getInstance().logout(true);
        String liveChatUrl = URL2ActivityManager.createLiveChatActivityUrl(targetName, targetId, targetUrl);
        URL2ActivityManager.getInstance().URL2Activity(mContext , liveChatUrl);
    }

    /**
     * 取主播信息
     */
    private void doGetUserInfo(){
        LiveRequestOperator.getInstance().GetUserInfo(targetId, new OnGetUserInfoCallback() {
            @Override
            public void onGetUserInfo(boolean isSuccess, int errCode, String errMsg, UserInfoItem userItem) {
                if(isSuccess && userItem != null){
                    LiveChatCallBackItem liveChatCallBackItem = new LiveChatCallBackItem(errCode, String.valueOf(errCode), errMsg, userItem);

                    Message msg = Message.obtain();
                    msg.what = TARGET_PHOTO_UPDATE;
                    msg.obj = liveChatCallBackItem;
                    sendUiMessage(msg);
                }

            }
        });
    }

    /**********************************************  liveChatManager相关业务 end  ***********************************************/

    /**********************************************  liveChatManager相关listener回调 start  ***********************************************/

    @Override
    public void OnGetEmotionConfig(boolean success, String errno, String errmsg, OtherEmotionConfigItem item) {

    }

    @Override
    public void OnSendEmotion(LiveChatClientListener.LiveChatErrType errType, String errmsg, LCMessageItem item) {
        if(item != null){
//            LCUserItem userItem = item.getUserItem();
//            if(userItem != null &&
//                    userItem.userId != null
//                    && userItem.userId.equals(targetId)){
//                LiveChatCallBackItem callBack = new LiveChatCallBackItem(
//                        errType.ordinal(), null, errmsg, item);
//                onSendMessageUpdate(callBack);
//            }
        }
    }

    @Override
    public void OnRecvEmotion(LCMessageItem item) {
//        if (item.fromId.equals(chatTarget.userId)) {
//            onReceiveMsgUpdate(item);
//        }
    }

    @Override
    public void OnGetEmotionImage(boolean success, LCEmotionItem emotionItem) {

    }

    @Override
    public void OnGetEmotionPlayImage(boolean success, LCEmotionItem emotionItem) {

    }

    @Override
    public void OnGetEmotion3gp(boolean success, LCEmotionItem emotionItem) {

    }

    @Override
    public void OnGetMagicIconConfig(boolean success, String errno, String errmsg, MagicIconConfig item) {

    }

    @Override
    public void OnSendMagicIcon(LiveChatClientListener.LiveChatErrType errType, String errmsg, LCMessageItem item) {
        if(item != null){
            LCUserItem userItem = item.getUserItem();
            if(userItem != null &&
                    userItem.userId != null
                    && userItem.userId.equals(targetId)){
                LiveChatCallBackItem callBack = new LiveChatCallBackItem(
                        errType.ordinal(), null, errmsg, item);
                onSendMessageUpdate(callBack);
            }
        }
    }

    @Override
    public void OnRecvMagicIcon(LCMessageItem item) {
        if (item.fromId.equals(chatTarget.userId)) {
            onReceiveMsgUpdate(item);
        }
    }

    @Override
    public void OnGetMagicIconSrcImage(boolean success, LCMagicIconItem magicIconItem) {
        Log.i("Jagger" , "OnGetMagicIconSrcImage:" + success);
        if(success){
            Message msg = Message.obtain();
            msg.what = GET_MAGIC_ICON_SUCCESS;
            sendUiMessage(msg);
        }
    }

    @Override
    public void OnGetMagicIconThumbImage(boolean success, LCMagicIconItem magicIconItem) {
        Log.i("Jagger" , "OnGetMagicIconThumbImage:" + success);
        if(success){
            Message msg = Message.obtain();
            msg.what = GET_MAGIC_ICON_SUCCESS;
            sendUiMessage(msg);
        }
    }

    @Override
    public void OnSendMessage(LiveChatClientListener.LiveChatErrType errType, String errmsg, LCMessageItem item) {
        Log.i("Jagger" , "OnSendMessage:" + errType.name());
        if(item != null){
            LCUserItem userItem = item.getUserItem();
            if(userItem != null &&
                    userItem.userId != null
                    && userItem.userId.equals(targetId)){
                LiveChatCallBackItem callBack = new LiveChatCallBackItem(
                        errType.ordinal(), null, errmsg, item);
                onSendMessageUpdate(callBack);
            }
        }
    }

    @Override
    public void OnRecvMessage(LCMessageItem item) {
        if (chatTarget != null && item != null) {
            if (item.fromId.equals(chatTarget.userId)) {
                onReceiveMsgUpdate(item);
            }
        }
    }

    @Override
    public void OnRecvWarning(LCMessageItem item) {
        /* 普通warning及以下错误（余额不足等） */
        if (item.getUserItem().userId.equals(chatTarget.userId)) {
            onReceiveMsgUpdate(item);
        }
    }

    @Override
    public void OnRecvEditMsg(String fromId) {

    }

    @Override
    public void OnRecvSystemMsg(LCMessageItem item) {
        /* 系统通知，以消息的形式（试聊结束等） */
        if (item.fromId.equals(chatTarget.userId)) {
            onReceiveMsgUpdate(item);
        }
    }

    @Override
    public void OnSendMessageListFail(LiveChatClientListener.LiveChatErrType errType, ArrayList<LCMessageItem> msgList) {
        /* 底层检测是否有试聊券，是否有钱聊天，如果没有直接此处返回错误 */
        Log.i("Jagger" , "OnSendMessageListFail:" + errType.name());
        onReceiveMsgList(errType, msgList);
    }

    @Override
    public void OnLogin(LiveChatClientListener.LiveChatErrType errType, String errmsg, boolean isAutoLogin) {

    }

    @Override
    public void OnLogout(LiveChatClientListener.LiveChatErrType errType, String errmsg, boolean isAutoLogin) {

    }

    @Override
    public void OnGetTalkList(LiveChatClientListener.LiveChatErrType errType, String errmsg) {

    }

    @Override
    public void OnGetHistoryMessage(boolean success, String errno, String errmsg, LCUserItem userItem) {
        /* 拿历史消息返回，需更新消息列表 */
        Log.i("Jagger" , "OnGetHistoryMessage success:" + success + ",userItem:" + userItem.userId);
        if (success && userItem != null) {
            onGetHistoryMessageCallback(userItem);
        }
    }

    @Override
    public void OnGetUsersHistoryMessage(boolean success, String errno, String errmsg, LCUserItem[] userItems) {
        Log.i("Jagger" , "OnGetUsersHistoryMessage success:" + success);
        if (success && userItems != null) {
            for (LCUserItem userItem : userItems) {
                onGetHistoryMessageCallback(userItem);
            }
        }
    }

    @Override
    public void OnSetStatus(LiveChatClientListener.LiveChatErrType errType, String errmsg) {

    }

    @Override
    public void OnGetUserStatus(LiveChatClientListener.LiveChatErrType errType, String errmsg, LCUserItem[] userList) {
        if(errType == LiveChatClientListener.LiveChatErrType.Success && userList != null && !onlineChecked){
            for(LCUserItem item : userList){
                if(item.userId.equals(targetId)){
                    onlineChecked = true;
                    Message msg = Message.obtain();
                    msg.what = GET_TARGET_STATUS_CALLBACK;
                    msg.obj = item;
                    sendUiMessage(msg);
                    break;
                }
            }
        }
    }

    @Override
    public void OnGetUserInfo(LiveChatClientListener.LiveChatErrType errType, String errmsg, String userId, LiveChatTalkUserListItem item) {

    }

    @Override
    public void OnGetUsersInfo(LiveChatClientListener.LiveChatErrType errType, String errmsg, String[] userIds, LiveChatTalkUserListItem[] itemList) {

    }

    @Override
    public void OnGetContactList(LiveChatClientListener.LiveChatErrType errType, String errmsg, LiveChatTalkUserListItem[] list) {

    }

    @Override
    public void OnUpdateStatus(LCUserItem userItem) {

    }

    @Override
    public void OnChangeOnlineStatus(LCUserItem userItem) {

    }

    @Override
    public void OnRecvKickOffline(LiveChatClientListener.KickOfflineType kickType) {

    }

    @Override
    public void OnRecvEMFNotice(String fromId, LiveChatClientListener.TalkEmfNoticeType noticeType) {

    }

    @Override
    public void OnGetLadyCamStatus(LiveChatClientListener.LiveChatErrType errType, String errmsg, String womanId, boolean isCam) {
//        if(errType == LiveChatClientListener.LiveChatErrType.Success
//                && !TextUtils.isEmpty(womanId)
//                && womanId.equals(targetId)){
//            //获取当前用户CamShare状态成功更新CamShare按钮
//            Message msg = Message.obtain();
//            msg.what = CAMSHARE_STATUS_CALLBACK;
//            msg.arg1 = isCam ? 1:0;
//            sendUiMessage(msg);
//        }
    }

    @Override
    public void OnGetUsersCamStatus(LiveChatClientListener.LiveChatErrType errType, String errmsg, LiveChatUserCamStatus[] userIds) {

    }

    @Override
    public void OnRecvLadyCamStatus(String userId, LiveChatClient.UserStatusProtocol statuType) {
//        if(!TextUtils.isEmpty(userId)
//                && userId.equals(targetId)){
//            //获取当前用户CamShare状态成功更新CamShare按钮
//            Message msg = Message.obtain();
//            msg.what = CAMSHARE_STATUS_CALLBACK;
//            msg.arg1 = statuType == LiveChatClient.UserStatusProtocol.USTATUSPRO_CAMOPEN ? 1:0;
//            sendUiMessage(msg);
//        }
    }

    @Override
    public void OnGetSessionInfo(LiveChatClientListener.LiveChatErrType errType, String errmsg, String userId, LiveChatSessionInfoItem item) {

    }

    @Override
    public void OnUseTryTicket(LiveChatClientListener.LiveChatErrType errType, String errno, String errmsg, String userId, LiveChatClientListener.TryTicketEventType eventType) {

    }

    @Override
    public void OnRecvTryTalkBegin(LCUserItem userItem, int time) {

    }

    @Override
    public void OnRecvTryTalkEnd(LCUserItem userItem) {

    }

    @Override
    public void OnCheckCoupon(boolean success, String errno, String errmsg, Coupon item) {
        if (item != null && item.userId.equals(targetId)) {
            onCheckCouponCallback(item);
        }
    }

    @Override
    public void OnEndTalk(LiveChatClientListener.LiveChatErrType errType, String errmsg, LCUserItem userItem) {
        if ((userItem != null) && (userItem.userId != null)
                && (userItem.userId.equals(targetId))) {
            if(errType == LiveChatClientListener.LiveChatErrType.ConnectFail){
                //网络异常不退出，生成系统提示
//				LiveChatManager.getInstance().BuildAndInsertSystemMsg(targetId, errmsg);
                //edit by Jagger 2018-5-2
                //按<节目功能点_20180417>新需求, 结束会话遇网络错误用Toast显示
                Toast.makeText(mContext, errmsg, Toast.LENGTH_LONG) .show();
            }else {
                Message msg = Message.obtain();
                msg.what = END_CHAT;
                sendUiMessage(msg);
            }
        }
    }

    @Override
    public void OnRecvTalkEvent(LCUserItem item) {

    }

    @Override
    public void OnSendVoice(LiveChatClientListener.LiveChatErrType errType, String errno, String errmsg, LCMessageItem item) {
        Log.i("Jagger", "OnSendVoice errno:" + errno + ",errmsg:" + errmsg );
        if(item != null){
			LCUserItem userItem = item.getUserItem();
			if(userItem != null &&
					userItem.userId != null
					&& userItem.userId.equals(targetId)){
				LiveChatCallBackItem callBack = new LiveChatCallBackItem(
						errType.ordinal(), errno, errmsg, item);
				onSendMessageUpdate(callBack);
			}
		}
    }

    @Override
    public void OnGetVoice(LiveChatClientListener.LiveChatErrType errType, String errmsg, LCMessageItem item) {

    }

    @Override
    public void OnRecvVoice(LCMessageItem item) {
        if (item.fromId.equals(chatTarget.userId)) {
            onReceiveMsgUpdate(item);
        }
    }


    /**********************************************  liveChatManager相关listener回调 end  ***********************************************/
}
