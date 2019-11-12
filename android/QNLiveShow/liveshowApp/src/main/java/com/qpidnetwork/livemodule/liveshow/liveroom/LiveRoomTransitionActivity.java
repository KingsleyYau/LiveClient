package com.qpidnetwork.livemodule.liveshow.liveroom;

import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.AnimationDrawable;
import android.os.Bundle;
import android.os.Message;
import android.support.annotation.Nullable;
import android.text.Html;
import android.text.Spanned;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnAcceptInstanceInviteCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetPromoAnchorListCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetShowRoomInfoCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetUserInfoCallback;
import com.qpidnetwork.livemodule.httprequest.OnRequestCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniLiveShow;
import com.qpidnetwork.livemodule.httprequest.RequestJniOther;
import com.qpidnetwork.livemodule.httprequest.item.HotListItem;
import com.qpidnetwork.livemodule.httprequest.item.HttpAuthorityItem;
import com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType;
import com.qpidnetwork.livemodule.httprequest.item.IntToEnumUtils;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.httprequest.item.ProgramInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.UserInfoItem;
import com.qpidnetwork.livemodule.im.IMInviteLaunchEventListener;
import com.qpidnetwork.livemodule.im.IMLiveRoomEventListener;
import com.qpidnetwork.livemodule.im.IMManager;
import com.qpidnetwork.livemodule.im.IMOtherEventListener;
import com.qpidnetwork.livemodule.im.listener.IMAuthorityItem;
import com.qpidnetwork.livemodule.im.listener.IMClientListener;
import com.qpidnetwork.livemodule.im.listener.IMInviteErrItem;
import com.qpidnetwork.livemodule.im.listener.IMInviteListItem;
import com.qpidnetwork.livemodule.im.listener.IMInviteReplyItem;
import com.qpidnetwork.livemodule.im.listener.IMLoveLeveItem;
import com.qpidnetwork.livemodule.im.listener.IMMessageItem;
import com.qpidnetwork.livemodule.im.listener.IMPackageUpdateItem;
import com.qpidnetwork.livemodule.im.listener.IMRebateItem;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.livemodule.liveshow.LiveModule;
import com.qpidnetwork.livemodule.liveshow.anchor.AnchorProfileActivity;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.home.MainFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.liveroom.rebate.LiveRoomCreditRebateManager;
import com.qpidnetwork.livemodule.liveshow.manager.URL2ActivityManager;
import com.qpidnetwork.livemodule.liveshow.model.NoMoneyParamsBean;
import com.qpidnetwork.livemodule.liveshow.personal.book.BookPrivateActivity;
import com.qpidnetwork.livemodule.utils.PicassoLoadUtil;
import com.qpidnetwork.livemodule.utils.SystemUtils;
import com.qpidnetwork.livemodule.view.ButtonRaised;
import com.qpidnetwork.qnbridgemodule.sysPermissions.manager.PermissionManager;
import com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder;
import com.qpidnetwork.qnbridgemodule.util.Log;
import com.qpidnetwork.qnbridgemodule.view.camera.CameraUtil;

import java.util.Timer;
import java.util.TimerTask;

import static com.qpidnetwork.livemodule.liveshow.liveroom.LiveRoomNormalErrorActivity.PageErrorType.PAGE_ERROR_LIEV_EDN;


/**
 * 邀请及进入直播间过渡页，主要处理邀请及进入直播间过程中的异常
 * @author Hunter
 */
public class  LiveRoomTransitionActivity extends BaseActionBarFragmentActivity implements IMOtherEventListener, IMInviteLaunchEventListener, IMLiveRoomEventListener{

    private static final int CLOSABLE_TIMESTAMP = 10 * 1000;      //进入界面1o秒后可取消
    private static final int DEFAULT_MAX_TIMEOUT = 3 * 60 * 1000;   //进入过渡页后3分钟未处理完成，当成超时处理
    private static final int INVITE_CANCELABLE_TIMESTAMP = 10 * 1000;      //进入界面1o秒后可取消
    private static final int BACKGROUD_LIVE_OVERTIME_TIMESTAMP = 60 * 1000;     //直播中，切换到后台自动结束事件间隔

    private static final int TEN_SENCONDS_EVNET = 1;
    private static final int OVERTIME_EVNET = 2;
    private static final int IMMEDIATE_INVITE_CANCELABLE = 3;
    private static final int BACKGROUD_ROOMOUT_NOTIFY = 4;

    /**
     * 是否有系统权限上传视频
     */
    public static final String KEY_HAS_PERMISSION = "KEY_HAS_PERMISSION";
    public static final String LIVEROOM_ROOMINFO_ID = "roomId";
    public static final String LIVEROOM_InviterErr_ITEM = "imInviteErrItem";
    private static final String TRANSITION_OPERATETYPE = "operateType";
    private static final String TRANSITION_ERRTYPE = "errType";
    private static final String TRANSITION_ANCHOR_ID = "anchorId";
    private static final String TRANSITION_ANCHOR_NAME = "anchorName";
    private static final String TRANSITION_ANCHOR_PHOTOURL = "anchorPhotoUrl";
    private static final String TRANSITION_ROOMID = "roomId";
    public static final String LIVEROOM_ROOMINFO_ROOMPHOTOURL = "mRoomPhotoUrl";
    private static final String TRANSITION_INVITATIONID = "invitationId";
    private static final String TRANSITION_LIVESHOWID = "liveshowid";
    private static final String TRANSITION_ISBUBBLE = "isBubble";

    //view
    private ImageView btnClose;
    private CircleImageView civPhoto;
    private TextView tvAnchorName;
    private TextView tvDesc;

    //按钮
    private Button btnCancel;
    private ButtonRaised btnRetry;
    private Button btnYes;
    private ButtonRaised btnStartPrivate;
    private ButtonRaised btnBook;
    private ButtonRaised btnViewHot;
    private ButtonRaised btnAddCredit;
    private ButtonRaised btnChat;
    private ButtonRaised btnSendMail;
    //推荐
    private LinearLayout llRecommand;
    private TextView tvRecommandName1;
    private CircleImageView civRecommand1;
    private LinearLayout llRecommand2;
    private TextView tvRecommandName2;
    private CircleImageView civRecommand2;
    //进度条
    private ImageView pb_waiting;
    //高斯模糊背景
    private SimpleDraweeView iv_gaussianBlur;
    private View v_gaussianBlurFloat;
    //才艺动图
    private LinearLayout mLlTalent;
    private ImageView mImageViewTalent;
    private AnimationDrawable animationDrawableTalent;

    //data
    private CategoryType mCategoryType;       //用于区分不同场景进入
    private String mAnchorId = "";
    private String mAnchorName = "";
    private String mAnchorPhotoUrl = "";
    private String mRoomId = "";
    private String mInvatationId = "";          //邀请Id
    private String mProgramShowID = "";         //节目id

    //处理过程中，中间存储数据
    private UserInfoItem mAnchorInfo = null;    //主播信息，用于处理主播是黄金／白银会员
    private IMRoomInItem mIMRoomInItem = null;  //进入房间成功返回房间信息，本地缓存
    private int mLeftSeconds = 0;               //记录开播倒计时时间
    private boolean isClosable = false;         //是否可关闭
    private boolean isOverTime = false;         //是否已超时，如果超时，重置所有状态，停止所有事务处理
    private boolean isCanShowRecommand = false; //用于解决获取推荐列表异步与用户操作冲突问题
    private boolean isBackgroudInRoomOut = false;       //记录是否后台进入直播间超时退出直播间错误
    private boolean isHasPermission = true;     //是否有上传视频权限（一般直播间不用上传视频，默认为true。私密直播询问权限后，再改变这个值）
    private IMInviteErrItem mInviteErrItem;     //主播权限

    //Manager
    private IMManager mIMManager;
    private Timer mReciprocalTimer;

    //直播间跳转过来所对应的事件类型
    private String mRoomPhotoUrl = null;

    //是否点击买点返回，用于自动retry操作
    private boolean mEnterAddCredit = false;

    //是否正在进入直播间
    private boolean mIsEntering = false;

    //纪录是否冒泡进入
    private boolean mIsBubble = false;

    public enum CategoryType{
        Enter_Public_Room,
        Audience_Invite_Enter_Room,
        Anchor_Invite_Enter_Room,
        Schedule_Invite_Enter_Room,
        Enter_Program_Public_Room
    }

    /**
     * 普通邀请进入
     * @param context
     * @param type
     * @param anchorId
     * @param anchorName
     * @param anchorPhotoUrl
     * @param roomId
     * @param roomPhotoUrl
     * @return
     */
    public static Intent getIntent(Context context, CategoryType type, String anchorId,
                                   String anchorName, String anchorPhotoUrl, String roomId,
                                   String roomPhotoUrl){
        Intent intent = new Intent(context, LiveRoomTransitionActivity.class);
        if(null != type){
            intent.putExtra(TRANSITION_OPERATETYPE, type.ordinal());
        }
        intent.putExtra(TRANSITION_ANCHOR_ID, anchorId);
        intent.putExtra(TRANSITION_ANCHOR_NAME, anchorName);
        intent.putExtra(TRANSITION_ANCHOR_PHOTOURL, anchorPhotoUrl);
        intent.putExtra(TRANSITION_ROOMID, roomId);
        intent.putExtra(LIVEROOM_ROOMINFO_ROOMPHOTOURL, roomPhotoUrl);

        return intent;
    }

    /**
     * 点击冒泡进入
     * @param context
     * @param type
     * @param anchorId
     * @param anchorName
     * @param anchorPhotoUrl
     * @param roomId
     * @param roomPhotoUrl
     * @return
     */
    public static Intent getIntentFromBubble(Context context, CategoryType type, String anchorId,
                                   String anchorName, String anchorPhotoUrl, String roomId,
                                   String roomPhotoUrl){
        Intent intent = new Intent(context, LiveRoomTransitionActivity.class);
        if(null != type){
            intent.putExtra(TRANSITION_OPERATETYPE, type.ordinal());
        }
        intent.putExtra(TRANSITION_ANCHOR_ID, anchorId);
        intent.putExtra(TRANSITION_ANCHOR_NAME, anchorName);
        intent.putExtra(TRANSITION_ANCHOR_PHOTOURL, anchorPhotoUrl);
        intent.putExtra(TRANSITION_ROOMID, roomId);
        intent.putExtra(LIVEROOM_ROOMINFO_ROOMPHOTOURL, roomPhotoUrl);
        intent.putExtra(TRANSITION_ISBUBBLE, true);

        return intent;
    }

    /**
     * 应邀启动进入过渡页
     * @param context
     * @param type
     * @param anchorId
     * @param anchorName
     * @param anchorPhotoUrl
     * @param invitationId
     * @return
     */
    public static final Intent getAcceptInviteIntent(Context context, CategoryType type,
                                                     String anchorId, String anchorName,
                                                     String anchorPhotoUrl, String invitationId){
        Intent intent = new Intent(context, LiveRoomTransitionActivity.class);
        intent.putExtra(TRANSITION_OPERATETYPE, type.ordinal());
        intent.putExtra(TRANSITION_ANCHOR_ID, anchorId);
        intent.putExtra(TRANSITION_ANCHOR_NAME, anchorName);
        intent.putExtra(TRANSITION_ANCHOR_PHOTOURL, anchorPhotoUrl);
        intent.putExtra(TRANSITION_INVITATIONID, invitationId);
        return intent;
    }

    /**
     * 节目开始进入过度页
     * @param context
     * @param type
     * @param anchorId
     * @param anchorName
     * @param anchorPhotoUrl
     * @param liveshowid
     * @return
     */
    public static final Intent getProgramShowIntent(Context context, CategoryType type,
                                                    String anchorId, String anchorName,
                                                    String anchorPhotoUrl, String liveshowid){
        Intent intent = new Intent(context, LiveRoomTransitionActivity.class);
        intent.putExtra(TRANSITION_OPERATETYPE, type.ordinal());
        intent.putExtra(TRANSITION_ANCHOR_ID, anchorId);
        intent.putExtra(TRANSITION_ANCHOR_NAME, anchorName);
        intent.putExtra(TRANSITION_ANCHOR_PHOTOURL, anchorPhotoUrl);
        intent.putExtra(TRANSITION_LIVESHOWID, liveshowid);
        return intent;
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        TAG = LiveRoomTransitionActivity.class.getSimpleName();

        //直播间中不熄灭屏幕
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON,
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

        super.onCreate(savedInstanceState);
        setCustomContentView(R.layout.activity_liveroom_transition);

        mIMManager = IMManager.getInstance();
        mReciprocalTimer = new Timer();
        registerListener();

        initViews();
        initData();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
//		super.onActivityResult(requestCode, resultCode, data);
        //系统<设置>界面权限返回处理
        switch (requestCode) {
            case PermissionManager.REQUEST_CODE_SYSSETTING: {

            }break;
        }
    }

    private void initViews(){
        //状态栏颜色(透明,用系统的)
//        StatusBarUtil.setColor(this, Color.parseColor("#5d0e86"),255);
        //不需要导航栏
        setTitleVisible(View.GONE);

        btnClose = (ImageView)findViewById(R.id.btnClose);
        civPhoto = (CircleImageView)findViewById(R.id.civPhoto);
        tvAnchorName = (TextView)findViewById(R.id.tvAnchorName);
        tvDesc = (TextView)findViewById(R.id.tvDesc);

        //按钮区域
        btnCancel = (Button) findViewById(R.id.btnCancel);
        btnRetry = (ButtonRaised) findViewById(R.id.btnRetry);
        btnYes = (Button) findViewById(R.id.btnYes);
        btnStartPrivate = (ButtonRaised) findViewById(R.id.btnStartPrivate);
        btnBook = (ButtonRaised) findViewById(R.id.btnBook);
        btnViewHot = (ButtonRaised) findViewById(R.id.btnViewHot);
        btnAddCredit = (ButtonRaised) findViewById(R.id.btnAddCredit);
        btnChat = (ButtonRaised) findViewById(R.id.btnChat);
        btnSendMail = (ButtonRaised) findViewById(R.id.btnSendMail);

        //推荐
        llRecommand = (LinearLayout) findViewById(R.id.llRecommand);
        tvRecommandName1 = (TextView) findViewById(R.id.tvRecommandName1);
        tvRecommandName1.setOnClickListener(this);
        civRecommand1 = (CircleImageView) findViewById(R.id.civRecommand1);
        civRecommand1.setOnClickListener(this);

        llRecommand2 = (LinearLayout)findViewById(R.id.llRecommand2);
        tvRecommandName2 = (TextView) findViewById(R.id.tvRecommandName2);
        tvRecommandName2.setOnClickListener(this);
        civRecommand2 = (CircleImageView) findViewById(R.id.civRecommand2);
        civRecommand2.setOnClickListener(this);

        //进度
        pb_waiting = (ImageView) findViewById(R.id.pb_waiting);

        //高斯模糊背景
//        iv_gaussianBlur = (SimpleDraweeView) findViewById(R.id.iv_gaussianBlur);
//        v_gaussianBlurFloat = findViewById(R.id.v_gaussianBlurFloat);
//        v_gaussianBlurFloat.setBackgroundDrawable(new ColorDrawable(Color.parseColor("#cc000000")));

        //才艺
        //私密直播才有动画
        mLlTalent = (LinearLayout) findViewById(R.id.llTalent);
        mImageViewTalent = (ImageView) findViewById(R.id.img_talent);
        animationDrawableTalent = ((AnimationDrawable) mImageViewTalent.getBackground());

        btnClose.setOnClickListener(this);
        btnCancel.setOnClickListener(this);
        btnRetry.setOnClickListener(this);
        btnYes.setOnClickListener(this);
        btnStartPrivate.setOnClickListener(this);
        btnBook.setOnClickListener(this);
        btnViewHot.setOnClickListener(this);
        btnAddCredit.setOnClickListener(this);
        btnChat.setOnClickListener(this);
        btnSendMail.setOnClickListener(this);
        civRecommand1.setOnClickListener(this);
        civRecommand2.setOnClickListener(this);
    }

    public void initData(){
        Bundle bundle = getIntent().getExtras();
        if(bundle != null){
            if(bundle.containsKey(TRANSITION_OPERATETYPE)){
                mCategoryType = CategoryType.values()[bundle.getInt(TRANSITION_OPERATETYPE)];
            }
            if(bundle.containsKey(TRANSITION_ANCHOR_ID)){
                mAnchorId = bundle.getString(TRANSITION_ANCHOR_ID);
            }
            if(bundle.containsKey(TRANSITION_ANCHOR_NAME)){
                mAnchorName = bundle.getString(TRANSITION_ANCHOR_NAME);
            }
            if(bundle.containsKey(TRANSITION_ANCHOR_PHOTOURL)){
                mAnchorPhotoUrl = bundle.getString(TRANSITION_ANCHOR_PHOTOURL);
            }
            if(bundle.containsKey(TRANSITION_ROOMID)){
                mRoomId = bundle.getString(TRANSITION_ROOMID);
            }

            if(bundle.containsKey(TRANSITION_INVITATIONID)){
                mInvatationId = bundle.getString(TRANSITION_INVITATIONID);
            }

            if(bundle.containsKey(TRANSITION_LIVESHOWID)){
                mProgramShowID = bundle.getString(TRANSITION_LIVESHOWID);
            }

            if(bundle.containsKey(LIVEROOM_ROOMINFO_ROOMPHOTOURL)){
                mRoomPhotoUrl = bundle.getString(LIVEROOM_ROOMINFO_ROOMPHOTOURL);
                Log.d(TAG,"initData-mRoomPhotoUrl:"+mRoomPhotoUrl);
            }

            if(bundle.containsKey(TRANSITION_ISBUBBLE)){
                mIsBubble = bundle.getBoolean(TRANSITION_ISBUBBLE);
            }
        }

        if(!TextUtils.isEmpty(mAnchorPhotoUrl)) {
//            Picasso.with(getApplicationContext()).load(mAnchorPhotoUrl)
//                    .placeholder(R.drawable.ic_default_photo_woman)
//                    .error(R.drawable.ic_default_photo_woman)
//                    .memoryPolicy(MemoryPolicy.NO_CACHE)
//                    .into(civPhoto);
            PicassoLoadUtil.loadUrlNoMCache(civPhoto,mAnchorPhotoUrl,R.drawable.ic_default_photo_woman);
        }

        if(!TextUtils.isEmpty(mRoomPhotoUrl)){
//            try {
//                Uri uri = Uri.parse(mRoomPhotoUrl);
//                ImageRequest request = ImageRequestBuilder.newBuilderWithSource(uri)
//                        .setPostprocessor(new IterativeBoxBlurPostProcessor(
//                                getResources().getInteger(R.integer.gaussian_blur_iterations),
//                                getResources().getInteger(R.integer.gaussian_blur_tran)))
//                        .build();
//                AbstractDraweeController controller = Fresco.newDraweeControllerBuilder()
//                        .setOldController(iv_gaussianBlur.getController())
//                        .setImageRequest(request)
//                        .build();
//                iv_gaussianBlur.setController(controller);
//            } catch (Exception e) {
//                e.printStackTrace();
//            }
        }

        tvAnchorName.setText(Html.fromHtml(getResources().getString(R.string.liveroom_transition_anchor_name_and_id, mAnchorName, mAnchorId)));

        //获取主播详情
        getAnchorInfo(mAnchorId);

        if(mCategoryType != null) {
            //启动本地超时逻辑
            start();
        }else{
            finish();
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        if(mEnterAddCredit){
            //充点返回执行自动retry操作
            resetAll();
            //无网络获取主播信息失败，retry重新获取
            if(mAnchorInfo == null){
                getAnchorInfo(mAnchorId);
            }
            start();
        }else{
            //处理切换到后台返回
            if(isBackgroudInRoomOut){
                startActivity(LiveRoomNormalErrorActivity.getIntent(this,
                        LiveRoomNormalErrorActivity.PageErrorType.PAGE_ERROR_BACKGROUD_OVERTIME, "",
                        mAnchorId, mAnchorName, mAnchorPhotoUrl, getRoomPhotoUrl(), false, null)
                );
                finish();
            }else{
                if(mIMRoomInItem != null && !mIMRoomInItem.needWait && mIMRoomInItem.leftSeconds == 0){
                    enterLiveRoom();
                }
            }
        }
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);
        int i = v.getId();
        if (i == R.id.btnClose) {
            exitLiveroomTransition();
        } else if (i == R.id.btnCancel) {
            cancelInvite(mInvatationId);
            finish();
        } else if (i == R.id.btnYes) {
            isCanShowRecommand = false;
            btnYes.setVisibility(View.GONE);
            llRecommand.setVisibility(View.GONE);
            //重新启动本地超时计时
            startOrResetCancelEvent();
            startOrResetLocalOverTime();
            showWaitForAnchorStartLive();

            //开始显示才艺推荐
            showAndStartAnimation();

            startInvite(true);
            //GA统计私密直播中，继续发送邀请
            onAnalyticsEvent(getResources().getString(R.string.Live_Transition_Category),
                    getResources().getString(R.string.Live_Transition_Action_SendInvitation),
                    getResources().getString(R.string.Live_Transition_Label_SendInvitation));
        } else if (i == R.id.btnStartPrivate) {
            startActivity(LiveRoomTransitionActivity.getIntent(this,
                    CategoryType.Audience_Invite_Enter_Room, mAnchorId,
                    mAnchorName, mAnchorPhotoUrl, "", null));
            //GA统计
//            if(mAnchorInfo != null && mAnchorInfo.anchorInfo != null && mAnchorInfo.anchorInfo.anchorType != AnchorLevelType.Unknown){
//                AnchorLevelType levelType = mAnchorInfo.anchorInfo.anchorType;
//                if(levelType == AnchorLevelType.gold){
                    //进入高级私密直播间
                    onAnalyticsEvent(getResources().getString(R.string.Live_Transition_Category),
                            getResources().getString(R.string.Live_Transition_Action_StartPrivateBroadcast),
                            getResources().getString(R.string.Live_Transition_Label_StartPrivateBroadcast));
//                }else{
//                    onAnalyticsEvent(getResources().getString(R.string.Live_Transition_Category),
//                            getResources().getString(R.string.Live_Transition_Action_StartPrivateBroadcast),
//                            getResources().getString(R.string.Live_Transition_Label_StartPrivateBroadcast));
//                }
//            }
            finish();
        } else if (i == R.id.btnBook) {
            startActivity(BookPrivateActivity.getIntent(mContext, mAnchorId, mAnchorName));
            finish();
        } else if (i == R.id.btnViewHot) {
            Intent intent = new Intent(this, MainFragmentActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(intent);
            finish();
        } else if (i == R.id.btnAddCredit) {
            mEnterAddCredit = true;
            LiveModule.getInstance().onAddCreditClick(mContext, new NoMoneyParamsBean());
            //GA统计点击充值
            onAnalyticsEvent(getResources().getString(R.string.Live_Global_Category),
                    getResources().getString(R.string.Live_Global_Action_AddCredit),
                    getResources().getString(R.string.Live_Global_Label_AddCredit));
        } else if (i == R.id.btnChat) {
            String chatUrl = LiveUrlBuilder.createLiveChatActivityUrl(mAnchorId, mAnchorName, mAnchorPhotoUrl);
            URL2ActivityManager.getInstance().URL2Activity(mContext, chatUrl);
        } else if (i == R.id.btnSendMail) {
            String sendMailUrl = LiveUrlBuilder.createSendMailActivityUrl(mAnchorId);
            URL2ActivityManager.getInstance().URL2Activity(mContext, sendMailUrl);
        }else if(i == R.id.civRecommand1 || i == R.id.civRecommand2
                || i == R.id.tvRecommandName1 || i == R.id.tvRecommandName2){
            String anchorId = (String) v.getTag();
            if (!TextUtils.isEmpty(anchorId)) {
                AnchorProfileActivity.launchAnchorInfoActivty(this,
                        getResources().getString(R.string.live_webview_anchor_profile_title),
                        anchorId,
                        false,
                        AnchorProfileActivity.TagType.Album);
            }
            //GA统计点击推荐
            onAnalyticsEvent(getResources().getString(R.string.Live_Transition_Category),
                    getResources().getString(R.string.Live_Transition_Action_Recommend),
                    getResources().getString(R.string.Live_Transition_Label_Recommend));
        }else if (i == R.id.btnRetry) {
            resetAll();
            //无网络获取主播信息失败，retry重新获取
            if(mAnchorInfo == null){
                getAnchorInfo(mAnchorId);
            }
            start();
        }
    }



    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        if(isOverTime){
            //拦截所有事件
            return;
        }
        switch (msg.what){
            case TEN_SENCONDS_EVNET:{
                if(!isWaitingEnterRoom()){
                    //未完成进入直播间逻辑
                    setClosable(true);
                }
            }break;

            case OVERTIME_EVNET:{
                //超时处理，超时停止一切操作
                showOverTimeEvent();
            }break;

            case IMMEDIATE_INVITE_CANCELABLE:{
                //立即私密邀请过程中，发送邀请成功后，10秒可显示取消按钮
//                if(isInviting()){
//                    btnCancel.setVisibility(View.VISIBLE);
//                }
            }break;

            case BACKGROUD_ROOMOUT_NOTIFY:{
                //后台直播超过1分钟，退出直播间
                isBackgroudInRoomOut = true;
                if(mIMRoomInItem != null){
                    mIMManager.RoomOut(mIMRoomInItem.roomId);
                }
            }break;
        }
    }

    /**
     * 启动邀请或进入直播间逻辑
     */
    private void start(){
        //启动重置默认超时及可取消逻辑
        startOrResetCancelEvent();
        startOrResetLocalOverTime();

        //隐藏才艺动画
        hideAndStopAnimation();

        showInviteOrRoomInRequesting(true);
        switch (mCategoryType){
            case Enter_Public_Room:{
                //进入公开直播间
                mIMManager.PublicRoomIn(mAnchorId);
            }break;
            case Audience_Invite_Enter_Room:{
                //开始显示才艺推荐
                showAndStartAnimation();

                //用户发起立即私密邀请
                if(TextUtils.isEmpty(mRoomId)){
                    startInvite(true);
                }else{
                    //邀请成功进入房间失败，retry重新走进入直播间逻辑
                    startRoomIn(mRoomId);
                }
            }break;
            case Anchor_Invite_Enter_Room:{
                //主播发起立即私密邀请，用户应邀
                if(TextUtils.isEmpty(mRoomId)){
                    processAnchorInvite(mInvatationId, true);
                }else{
                    //应邀成功进入房间失败，retry重新走进入直播间逻辑
                    startRoomIn(mRoomId);
                }
            }break;
            case Schedule_Invite_Enter_Room:{
                //预约邀请直接到时间通知，直接进入直播间
                startRoomIn(mRoomId);
            }break;
            case Enter_Program_Public_Room:{
                //预约邀请直接到时间通知，直接进入直播间
                startProgramRoomIn(mProgramShowID);
            }break;
        }
    }

    /**
     * 启动重置本地超时逻辑
     */
    private void startOrResetLocalOverTime(){
        removeUiMessages(OVERTIME_EVNET);
        //启动180秒超时逻辑
        sendEmptyUiMessageDelayed(OVERTIME_EVNET, DEFAULT_MAX_TIMEOUT);
    }

    /**
     * 启动或重置可取消逻辑
     */
    private void startOrResetCancelEvent(){
        setClosable(false);
        removeUiMessages(TEN_SENCONDS_EVNET);
        //启动10秒显示右上角取消按钮
        sendEmptyUiMessageDelayed(TEN_SENCONDS_EVNET, CLOSABLE_TIMESTAMP);
    }

    /**
     * 设置是否可关闭
     * @param canClose
     */
    private void setClosable(boolean canClose){
        isClosable = canClose;
        btnClose.setVisibility(canClose ? View.VISIBLE : View.GONE);
    }

    /**
     * 重置所有view状态，
     */
    private void resetAll(){

        btnCancel.setVisibility(View.GONE);
        btnRetry.setVisibility(View.GONE);
        btnYes.setVisibility(View.GONE);
        btnStartPrivate.setVisibility(View.GONE);
        btnBook.setVisibility(View.GONE);
        btnViewHot.setVisibility(View.GONE);
        btnAddCredit.setVisibility(View.GONE);

        llRecommand.setVisibility(View.GONE);

        hideLoadingProgress();

        //数据
        mIMRoomInItem = null;
        mLeftSeconds = 0;
        if(mCategoryType != CategoryType.Anchor_Invite_Enter_Room) {
            mInvatationId = "";
        }
        isOverTime = false;
        isCanShowRecommand = false;
        if(mReciprocalTimer != null){
            mReciprocalTimer.cancel();
            mReciprocalTimer.purge();
            mReciprocalTimer = null;
        }
        removeUiMessages(TEN_SENCONDS_EVNET);
        removeUiMessages(OVERTIME_EVNET);
        removeUiMessages(IMMEDIATE_INVITE_CANCELABLE);
        removeUiMessages(BACKGROUD_ROOMOUT_NOTIFY);
    }

    /**
     * 主动退出逻辑
     */
    private void exitLiveroomTransition(){
        if(isInviting()){
            //邀请中取消邀请
            mIMManager.cancelImmediatePrivateInvite(mInvatationId);
        }else if(isWaitingEnterRoom()){
            //进入房间中，退出房间
            mIMManager.RoomOut(mIMRoomInItem.roomId);
        }
        finish();
    }

    /**
     * 绑定监听器
     */
    private void registerListener(){
        mIMManager.registerIMOtherEventListener(this);
        mIMManager.registerIMInviteLaunchEventListener(this);
        mIMManager.registerIMLiveRoomEventListener(this);
    }

    /**
     * 解绑监听器
     */
    private void unRegisterListener(){
        mIMManager.unregisterIMOtherEventListener(this);
        mIMManager.unregisterIMInviteLaunchEventListener(this);
        mIMManager.unregisterIMLiveRoomEventListener(this);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        //停止动画
//        Drawable tempDrawable = btnStartPrivate.getDrawable();
//        if((tempDrawable != null)
//                && (tempDrawable instanceof AnimationDrawable)){
//            ((AnimationDrawable)tempDrawable).stop();
//        }
        if(animationDrawableTalent != null && animationDrawableTalent.isRunning()){
            animationDrawableTalent.stop();
        }

        //停掉进度动画
        hideLoadingProgress();

        unRegisterListener();
        if(mReciprocalTimer != null){
            mReciprocalTimer.cancel();
            mReciprocalTimer.purge();
            mReciprocalTimer = null;
        }
        //删除定时消息
        removeUiMessages(TEN_SENCONDS_EVNET);
        removeUiMessages(OVERTIME_EVNET);
        removeUiMessages(IMMEDIATE_INVITE_CANCELABLE);
        removeUiMessages(BACKGROUD_ROOMOUT_NOTIFY);
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if ( keyCode == KeyEvent.KEYCODE_BACK && event.getAction() == KeyEvent.ACTION_DOWN ){
            //拦截返回键
            if(isClosable){
                exitLiveroomTransition();
            }
            return false;
        }
        return super.onKeyDown(keyCode, event);
    }

    /************************************  处理过程中状态,鉴于不复杂不做枚举处理  ******************************************/
    /**
     * 标记当前是否邀请中
     * @return
     */
    private boolean isInviting(){
        boolean isInviting = false;
        if(mCategoryType == CategoryType.Audience_Invite_Enter_Room && !TextUtils.isEmpty(mInvatationId)){
            isInviting = true;
        }
        return  isInviting;
    }

    /**
     * 判断是否进入房间成功等待中
     * @return
     */
    private boolean isWaitingEnterRoom(){
        boolean isWaiting = false;
        if(mIMRoomInItem != null){
            isWaiting = true;
        }
        return isWaiting;
    }


    /*********************************  进入直播间邀请逻辑start  ***********************************************/
    /**
     * 发起立即私密邀请
     * @param force
     */
    private void startInvite(boolean force){
        showInviteOrRoomInRequesting(!force);
        mIMManager.sendImmediatePrivateInvite(mAnchorId, "", force);
    }

    /**
     * 收到立即私密邀请应答处理
     * @param replyType
     * @param roomId
     */
    private void onInviteReplyHandler(IMClientListener.InviteReplyType replyType, String roomId, String message, IMInviteErrItem inviteErrItem){
        Log.i("Jagger" , "直播过渡页 onInviteReplyHandler:" + replyType.name() + ",message:" + message + ",book:" + (inviteErrItem != null?"null":inviteErrItem.priv.isHasBookingAuth));
        //重置邀请ID，清除邀请状态
        mInvatationId = "";
        //取消定时显示按钮
        removeUiMessages(IMMEDIATE_INVITE_CANCELABLE);

        switch (replyType){
            case Defined: {
                showAudienceInviteInvalidError(message, inviteErrItem);
            }break;
            case Accepted: {
                startRoomIn(roomId);
            }break;
            default: {

            }break;
        }
    }

    /**
     * 取消直播邀请
     * @param invitationId
     */
    private void cancelInvite(String invitationId){
        if(!TextUtils.isEmpty(invitationId)) {
            mIMManager.cancelImmediatePrivateInvite(invitationId);
        }
    }

    @Override
    public void OnCancelImmediatePrivateInvite(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, String roomId) {

    }

    @Override
    public void OnRecvInviteReply(final IMInviteReplyItem replyItem) {
        if(replyItem != null){
            final IMInviteErrItem inviteErrItem = new IMInviteErrItem();
            inviteErrItem.status = replyItem.status;
            inviteErrItem.priv = replyItem.priv;

            if(!isOverTime && !TextUtils.isEmpty(replyItem.inviteId) && replyItem.inviteId.equals(mInvatationId)) {
                //添加防守，一个邀请仅处理一次通知（多次通知后面通知无效）
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        onInviteReplyHandler(replyItem.replyType, replyItem.roomId, replyItem.message, inviteErrItem);
                    }
                });
            }
        }
    }

    /*********************************  进入直播间邀请逻辑end  ***********************************************/


    /*********************************  进入直播间逻辑  ***********************************************/

    /**
     * 应邀／立即私密邀请成功及预约邀请到期进入直播间
     * @param roomId
     */
    private void startRoomIn(String roomId){
        mRoomId = roomId;
        mIMManager.RoomIn(roomId);
    }


    /**
     * 进入房间统一处理
     * @param reqId
     * @param success
     * @param errType
     * @param errMsg
     * @param roomInfo
     */
    public void onRoomInCallback(int reqId, final boolean success,
                                 final IMClientListener.LCC_ERR_TYPE errType, final String errMsg, final IMRoomInItem roomInfo,final IMInviteErrItem inviteErrItem){
        Log.d(TAG,"onRoomInCallback-reqId:"+reqId+" success:"+success+" errType:"+errType
                +" errMsg:"+errMsg+" roomInfo:"+roomInfo+" isOverTime:"+isOverTime);
        if(!isOverTime){
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    if(success){
                        //此时不能退出房间
                        setClosable(false);
                        //进入房间成功
                        mIMRoomInItem = roomInfo;
                        mInviteErrItem = inviteErrItem;
                        //是否需要等待开播通知
                        if(!roomInfo.needWait){
                            //不需要等待，进入开播倒数进入逻辑
                            startEnterReciprocal(roomInfo.leftSeconds);
                        }else{
                            //增加超时逻辑
                            startOrResetLocalOverTime();
                            showWaitForAnchorStartLive();
                        }
                    }else{
                        Log.i("Jagger" , "直播过渡页 onRoomInCallback:"
                                + (inviteErrItem == null?"inviteErrItem null":("priv:"
                                + (inviteErrItem.priv == null?"inviteErrItem.priv null":("Book:"
                                + inviteErrItem.priv.isHasBookingAuth
                                + ",OneOnOne:"
                                + inviteErrItem.priv.isHasOneOnOneAuth
//                                + ",chat:"
//                                + inviteErrItem.status.name()
                        )))));
                        //进入房间失败，统一处理
                        onIMRequestFaiHandler(errType, errMsg, inviteErrItem);
                    }
                }
            });
        }
    }

    /**
     * 开播倒数逻辑
     * @param leftSeconds
     */
    private void startEnterReciprocal(int leftSeconds){
        //清除页面180秒倒计时，此时已确认可进入直播间
        removeUiMessages(OVERTIME_EVNET);

        if(leftSeconds > 0){
            showCountDownToEnterRoom(leftSeconds);
            mLeftSeconds = leftSeconds;
            //解决过度页面弹充值提示-跳转充值界面-完成充值回来-走onResume逻辑时后重新RoomIn，
            // 调用mReciprocalTimer.schedule抛java.lang.IllegalStateException: Timer was canceled
            if(null == mReciprocalTimer){
                mReciprocalTimer = new Timer();
            }
            mReciprocalTimer.schedule(new TimerTask() {
                @Override
                public void run() {
                    onWaitEnterTimerRefresh(mLeftSeconds);
                    if(mLeftSeconds <= 0){
                        //开播倒数结束
                        mReciprocalTimer.cancel();
                        //从定时器队列中移除所有已取消的任务(任务虽然已取消，但仍在队列中)
                        mReciprocalTimer.purge();
                        mReciprocalTimer = null;
                    }else {
                        mLeftSeconds--;
                    }
                }
            }, 0 , 1000);
        }else{
            enterLiveRoom();
        }
    }

    /**
     * 定时器回调，主线程刷新界面
     * @param leftSeconds
     */
    private void onWaitEnterTimerRefresh(final int leftSeconds){
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                setDescText(Html.fromHtml(getResources().getString(R.string.liveroom_transition_enterroom_countdown_tips, String.valueOf(leftSeconds))));
                if(leftSeconds <= 0){
                    enterLiveRoom();
                }
            }
        });
    }

    /**
     * 邀请成功或进入直播间被告知要等待（等待主播开启直播间）
     */
    private void showWaitForAnchorStartLive(){
        setDescText(getResources().getString(R.string.liveroom_transition_waiting_anchor_start_tips));
    }

    /**
     * 倒计时进入直播间
     */
    private void showCountDownToEnterRoom(int leftSeconds){
        String desc = "";
//        if(mCategoryType == CategoryType.Anchor_Invite_Enter_Room){
//            desc = getResources().getString(R.string.liveroom_transition_anchorinvite_enterroom_countdown_tips);
//        }else if(mCategoryType == CategoryType.Audience_Invite_Enter_Room){
//            desc = getResources().getString(R.string.liveroom_transition_invite_enterroom_countdown_tips);
//        }else{
//        desc = getResources().getString(R.string.liveroom_transition_enterroom_countdown_tips);
//        }
        setDescText(Html.fromHtml(getResources().getString(R.string.liveroom_transition_enterroom_countdown_tips, String.valueOf(leftSeconds))));
        hideLoadingProgress();
    }


    /**
     * 私密直播权限检查
     */
    private void checkPrivateRoomPermissions(){
        PermissionManager permissionManager = new PermissionManager(mContext, new PermissionManager.PermissionCallback() {
            @Override
            public void onSuccessful() {
                if(CameraUtil.isAllCameraCanUse()){
                    isHasPermission = true;
                }else{
                    isHasPermission = false;
                }
                Intent intent = new Intent(mContext, AdvancePrivateLiveRoomActivity.class);
                doStartActivity(intent);
            }

            @Override
            public void onFailure() {
                isHasPermission = false;
                Intent intent = new Intent(mContext, AdvancePrivateLiveRoomActivity.class);
                doStartActivity(intent);
            }
        });

        permissionManager.requestVideo();
    }

    /**
     * 打开Activity
     * @param intent
     */
    private void doStartActivity(Intent intent){
        if (null != intent) {
            intent.putExtra(LIVEROOM_ROOMINFO_ID, mIMRoomInItem.roomId);    //只传入房间ID为了解决:BUG#14463 add by Jagger 2019-1-17
            intent.putExtra(LIVEROOM_InviterErr_ITEM, mInviteErrItem);
            intent.putExtra(LIVEROOM_ROOMINFO_ROOMPHOTOURL, getRoomPhotoUrl());
            intent.putExtra(KEY_HAS_PERMISSION, isHasPermission);
            startActivity(intent);
        }
        finish();
    }

    /**
     * 进入直播间界面跳转
     */
    private void enterLiveRoom(){
//        unRegisterListener();     //后台自动进入时，还需要收通知OnRecvChangeVideoUrl，防止主播开始推流拿不到播放流
        //判断当前是否后台，后台时统一不跳转（解决5.0以下startActivity会在后台打开页面，但是5.0以上会将应用带到前台），在resume处理超出1分钟停止，否则进入直播间
        if(SystemUtils.isBackground(this)){
            //修改进入直播间返回参数，不用等待，不用倒计时
            mIMRoomInItem.needWait = false;
            mIMRoomInItem.leftSeconds = 0;

            //启动后台定时停止计时
            sendEmptyUiMessageDelayed(BACKGROUD_ROOMOUT_NOTIFY, BACKGROUD_LIVE_OVERTIME_TIMESTAMP);
        }else {
            if(mIsEntering){
                return;
            }
            mIsEntering = true;

            //进入直播间
            Intent intent = null;
            if (mIMRoomInItem.roomType == IMRoomInItem.IMLiveRoomType.FreePublicRoom) {
                intent = new Intent(this, FreePublicLiveRoomActivity.class);
            } else if (mIMRoomInItem.roomType == IMRoomInItem.IMLiveRoomType.PaidPublicRoom) {
                if(mIMRoomInItem.liveShowType == IMRoomInItem.IMPublicRoomType.Program){
                    intent = new Intent(this, ProgramPayPublicLiveRoomActivity.class);
                }else {
                    intent = new Intent(this, PayPublicLiveRoomActivity.class);
                }
            }else if(mIMRoomInItem.roomType == IMRoomInItem.IMLiveRoomType.AdvancedPrivateRoom
                    || mIMRoomInItem.roomType == IMRoomInItem.IMLiveRoomType.NormalPrivateRoom){
//                intent = new Intent(this, AdvancePrivateLiveRoomActivity.class);
//                Log.i("Jagger" , "LiveRoom enterLiveRoom checkPrivateRoomPermissions");
                checkPrivateRoomPermissions();
                return;
            }
//            else if(mIMRoomInItem.roomType == IMRoomInItem.IMLiveRoomType.NormalPrivateRoom){
//                intent = new Intent(this, NormalPrivateLiveRoomActivity.class);
//            }
            doStartActivity(intent);
        }
    }

    /*********************************  进入直播间逻辑  ***********************************************/

    /*********************************  应邀进入直播间逻辑start  ***********************************************/

    /**
     * 应邀
     * @param invitationId
     * @param isComfirmed
     */
    private void processAnchorInvite(String invitationId, boolean isComfirmed){
        LiveRequestOperator.getInstance().AcceptInstanceInvite(invitationId, isComfirmed, new OnAcceptInstanceInviteCallback() {
            @Override
            public void onAcceptInstanceInvite(final boolean isSuccess,final int errCode,final String errMsg,final String roomId, int roomType,final HttpAuthorityItem priv) {
                if(!isOverTime){
                    //未超时停止响应其他
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            if(isSuccess){
                                startRoomIn(roomId);
                            }else{
                                IMAuthorityItem imAuthorityItem = new IMAuthorityItem();
                                imAuthorityItem.HttpAuthorityItem2IMAuthorityItem(priv);

                                IMInviteErrItem inviteErrItem = new IMInviteErrItem();
                                inviteErrItem.priv = imAuthorityItem;

                                showAcceptAnchorInvitationError(errCode, errMsg, inviteErrItem);
                            }
                        }
                    });
                }
            }
        });
    }

    /**
     * 应邀失败错误页
     * @param errCode
     * @param description
     */
    private void showAcceptAnchorInvitationError(int errCode, String description, IMInviteErrItem inviteErrItem){
        //清除页面180秒超时设置
        removeUiMessages(OVERTIME_EVNET);

        hideLoadingProgress();
        setClosable(true);
        HttpLccErrType httpError = IntToEnumUtils.intToHttpErrorType(errCode);

        Log.i("Jagger" , "直播过渡页 showAcceptAnchorInvitationError:" + httpError.name() + ",inviteErrItem OneOnOne:" + inviteErrItem.priv.isHasOneOnOneAuth + ",book:" + inviteErrItem.priv.isHasBookingAuth);

        switch (httpError){
            case HTTP_LCC_ERR_NO_CREDIT:{
                //信用点不足
                onIMRequestFaiHandler(IMClientListener.LCC_ERR_TYPE.LCC_ERR_NO_CREDIT, description, inviteErrItem);
            }break;
            case HTTP_LCC_ERR_ANCHOR_OFFLIVE:{
                //主播不在线
                onIMRequestFaiHandler(IMClientListener.LCC_ERR_TYPE.LCC_ERR_ANCHOR_OFFLINE, description, inviteErrItem);
            }break;
            case HTTP_LCC_ERR_CONNECTFAIL:{
                //网络异常
                setDescText(description);
                btnRetry.setVisibility(View.VISIBLE);

                //出错公共逻辑
                onAllErrorCatch();
            }break;
            case HTTP_LCC_ERR_PRIVTE_INVITE_AUTHORITY:
                //没有私密权限 -- 无按钮
                setDescText(description);
                break;
            default:{
                //其他异常
                if(!TextUtils.isEmpty(description)){
                    setDescText(description);
                }else{
                    setDescText(getResources().getString(R.string.liveroom_transition_unknown_error_default_tips));
                }

                setAndShowStartPrivateInviteButton(btnStartPrivate, inviteErrItem);

                showBookButton(inviteErrItem);

                //出错公共逻辑
                onAllErrorCatch();
            }break;
        }

    }

    /*********************************  应邀进入直播间逻辑end  ***********************************************/

    /*********************************  节目进入直播间start  ***********************************************/

    /**
     * 节目进入直播间
     * @param liveShowId
     */
    private void startProgramRoomIn(String liveShowId){
        LiveRequestOperator.getInstance().GetShowRoomInfo(liveShowId, new OnGetShowRoomInfoCallback() {
            @Override
            public void onGetShowRoomInfo(final boolean isSuccess, final int errCode, final String errMsg, final ProgramInfoItem item, final String roomId,final HttpAuthorityItem privItem) {
                if(!isOverTime){
                    //未超时停止响应其他
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            Log.i("Jagger" , "过渡页 startProgramRoomIn isSuccess:" + isSuccess + ", privItem book:" + (privItem == null?"null":privItem.isHasBookingAuth));
                            if(isSuccess && (item != null) && !TextUtils.isEmpty(roomId)){
                                mRoomId = roomId;
                                if(item.leftSecToStart > 0){
                                    startProgramEnterReciprocal(item);
                                }else{
                                    //直接进入直播间
                                    startRoomIn(roomId);
                                }
                            }else{
                                IMAuthorityItem imAuthorityItem = new IMAuthorityItem();
                                imAuthorityItem.HttpAuthorityItem2IMAuthorityItem(privItem);

                                IMInviteErrItem inviteErrItem = new IMInviteErrItem();
                                inviteErrItem.priv = imAuthorityItem;

                                showProgramEnterFailed(errCode, errMsg, inviteErrItem);
                            }
                        }
                    });
                }
            }
        });
    }

    /**
     * 开播倒数逻辑
     * @param item
     */
    private void startProgramEnterReciprocal(final ProgramInfoItem item){
        //清除页面180秒超时设置
        removeUiMessages(OVERTIME_EVNET);

        final int leftSeconds = item.leftSecToStart;
        if(leftSeconds > 0){
            setDescText(Html.fromHtml(getResources().getString(R.string.livemsg_program_transition_reciprocal_tips, item.showTitle, String.valueOf(leftSeconds))));
            mLeftSeconds = leftSeconds;
            //解决过度页面弹充值提示-跳转充值界面-完成充值回来-走onResume逻辑时后重新RoomIn，
            // 调用mReciprocalTimer.schedule抛java.lang.IllegalStateException: Timer was canceled
            if(null == mReciprocalTimer){
                mReciprocalTimer = new Timer();
            }
            mReciprocalTimer.schedule(new TimerTask() {
                @Override
                public void run() {
                    onProgramTimerRefresh(item.showTitle, mLeftSeconds);
                    if(mLeftSeconds <= 0){
                        //开播倒数结束
                        mReciprocalTimer.cancel();
                        //从定时器队列中移除所有已取消的任务(任务虽然已取消，但仍在队列中)
                        mReciprocalTimer.purge();
                        mReciprocalTimer = null;
                    }else {
                        mLeftSeconds--;
                    }
                }
            }, 0 , 1000);
        }else{
            startRoomIn(mRoomId);
        }
    }

    /**
     * 节目倒计时界面刷新
     * @param programTitle
     * @param leftSeconds
     */
    private void onProgramTimerRefresh(final String programTitle, final int leftSeconds){
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                setDescText(Html.fromHtml(getResources().getString(R.string.livemsg_program_transition_reciprocal_tips, programTitle, String.valueOf(leftSeconds))));
                if(leftSeconds <= 0){
                    //倒计时结束，调用进入直播间逻辑
                    startRoomIn(mRoomId);
                }
            }
        });
    }

    /**
     * 应邀失败错误页
     * @param errCode
     * @param description
     */
    private void showProgramEnterFailed(int errCode, String description, IMInviteErrItem inviteErrItem){
        //清除页面180秒超时设置
        removeUiMessages(OVERTIME_EVNET);

        hideLoadingProgress();
        setClosable(true);
        HttpLccErrType httpError = IntToEnumUtils.intToHttpErrorType(errCode);
        switch (httpError){
            case HTTP_LCC_ERR_NO_CREDIT:{
                //信用点不足
                onIMRequestFaiHandler(IMClientListener.LCC_ERR_TYPE.LCC_ERR_NO_CREDIT, description, inviteErrItem);
            }break;
            case HTTP_LCC_ERR_ANCHOR_OFFLIVE:{
                //主播不在线
                onIMRequestFaiHandler(IMClientListener.LCC_ERR_TYPE.LCC_ERR_ANCHOR_OFFLINE, description, inviteErrItem);
            }break;
            case HTTP_LCC_ERR_CONNECTFAIL:{
                //网络异常
                setDescText(description);
                btnRetry.setVisibility(View.VISIBLE);

                //出错公共处理
                onAllErrorCatch();
            }break;
            default:{
                //其他异常
                if(!TextUtils.isEmpty(description)){
                    setDescText(description);
                }else{
                    setDescText(getResources().getString(R.string.liveroom_transition_unknown_error_default_tips));
                }
//                setAndShowStartPrivateInviteButton(btnStartPrivate);
                showBookButton(inviteErrItem);

                //出错公共处理
                onAllErrorCatch();
            }break;
        }

    }

    /*********************************  节目进入直播间end  ***********************************************/


    /*********************************  特殊界面切换逻辑  ***********************************************/
    /**
     * 邀请或进入房间请求过程中
     */
    private void showInviteOrRoomInRequesting(boolean descEmpty){
        if(descEmpty){
            setDescText("");
        }
        showLoadingProgress();
    }

    /**
     * 显示180秒超时错误页
     */
    private void showOverTimeEvent(){
        if(isInviting() || isWaitingEnterRoom()){
            String errDesc = getResources().getString(R.string.liveroom_transition_enterroom_overtime_default_tips);
            //邀请中或者登入进入直播间中
            if(isInviting()){
                errDesc = getResources().getString(R.string.liveroom_transition_invite_deny_without_message);
                //取消邀请
                cancelInvite(mInvatationId);
                //清除无效invitationId
                mInvatationId = "";
                //del by Jagger 2018-12-5 本地180秒超时, 无按钮
//                showBookButton();
            }else if(isWaitingEnterRoom()){
                //退出直播间
                mIMManager.RoomOut(mIMRoomInItem.roomId);
                btnBook.setVisibility(View.GONE);
            }

            //显示错误也
            hideLoadingProgress();
            btnRetry.setVisibility(View.GONE);
            setClosable(true);

            setDescText(errDesc);

            //是否停止业务处理
            isOverTime = true;

            //调用出错公共处理
            onAllErrorCatch();
        }
    }

    /*********************************  特殊界面切换逻辑  ***********************************************/

    /*********************************** 公共错误处理  ***********************************************/

    /**
     * 出错时公共逻辑
     */
    private void onAllErrorCatch(){
        hideAndStopAnimation();
    }

    /**
     * IM错误统一处理
     * @param errType
     * @param errMsg 服务器返回错误信息
     */
    private void onIMRequestFaiHandler(IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMInviteErrItem inviteErrItem){
        Log.i("Jagger" , "直播过渡页 onIMRequestFaiHandler:" + errType.name() + ":" + errMsg);

        //清除页面180秒超时设置
        removeUiMessages(OVERTIME_EVNET);
        //异常处理
        hideLoadingProgress();
        setClosable(true);
        String description = errMsg;
        switch (errType){
            case LCC_ERR_ANCHOR_OFFLINE:{
                //立即私密邀请，主播不在线
                showBookButton(inviteErrItem);

            }break;
            case LCC_ERR_NO_CREDIT:{
                //信用点不足
                btnAddCredit.setVisibility(View.VISIBLE);
            }break;
            case LCC_ERR_ANCHOR_PLAYING:{
                //主播正在私密直播中
                //Yes按钮
                if(inviteErrItem != null && inviteErrItem.priv.isHasOneOnOneAuth){
                    btnYes.setVisibility(View.VISIBLE);
                }else {
                    btnYes.setVisibility(View.GONE);
                }

                //获取推荐列表刷新
                getRecommandList();
            }break;

            case LCC_ERR_CONNECTFAIL:{
                //网络异常
                btnRetry.setVisibility(View.VISIBLE);
            }break;

            case LCC_ERR_AUDIENCE_LIMIT:{
                //进入直播间，人数过多错误
//                setAndShowStartPrivateInviteButton(btnStartPrivate);
                showBookButton(inviteErrItem);
            }break;

//            case LCC_ERR_ROOM_CLOSE:
//            case LCC_ERR_NOT_FOUND_ROOM:
//            case LCC_ERR_LIVEROOM_NO_EXIST:
//            case LCC_ERR_ANCHOR_NO_ON_LIVEROOM:
//            case LCC_ERR_LIVEROOM_CLOSED:{
//                //房间已关闭，直播间无效等
//                decription = getResources().getString(R.string.liveroom_transition_broadcast_ended);
//                btnBook.setVisibility(View.VISIBLE);
//                //推荐列表
//                getRecommandList();
//            }break;

            case LCC_ERR_PRIVTE_INVITE_AUTHORITY:
                // 主播无立即私密邀请权限(17002)

                if(inviteErrItem.status != null && inviteErrItem.status == IMClientListener.IMChatOnlineStatus.online){
                    showChatButton();
                }else {
                    showSendMailButton();
                }
                break;

            default:{
                //同一普通错误处理，依赖服务器返回错误提示
                if(TextUtils.isEmpty(errMsg)) {
                    description = getResources().getString(R.string.liveroom_transition_unknown_error_default_tips);
                }
//                if(!isInviting()){
//                    setAndShowStartPrivateInviteButton(btnStartPrivate);
//                }
                showBookButton(inviteErrItem);

            }break;
        }
        setDescText(description);
        //调用出错公共处理
        onAllErrorCatch();
    }

    /**
     * 邀请已决绝／已超时／已完成等邀请处于无效状态错误页
     * @param message 主播留言
     */
    private void showAudienceInviteInvalidError(String message,IMInviteErrItem inviteErrItem){
        Log.i("Jagger" , "直播过渡页 showAudienceInviteInvalidError:" + message + ",book:" + (inviteErrItem != null?"null":inviteErrItem.priv.isHasBookingAuth));

        hideLoadingProgress();
        showBookButton(inviteErrItem);
        setClosable(true);
        if(TextUtils.isEmpty(message)) {
            //无留言
            setDescText(getResources().getString(R.string.liveroom_transition_invite_deny_without_message));
        }else{
            //有留言
            setDescText(Html.fromHtml(getResources().getString(R.string.liveroom_transition_invite_deny_with_message, message)));
        }

        //出错公共处理
        onAllErrorCatch();
    }

    /**
     * 兼容主播id为空时错误显示
     */
//    private void showBookButton(){
//        //有BOOK权限
////        if(mIMRoomInItem!= null && mIMRoomInItem.priv != null && mIMRoomInItem.priv.isHasBookingAuth){
////            //ID不为空
////            if(!TextUtils.isEmpty(mAnchorId)){
////                btnBook.setVisibility(View.VISIBLE);
////            }
////        }
//
//        //是否有BOOK权限
//        boolean isBookShowAuth = true;
//
//        if(mIMRoomInItem == null){
//            //无直播间信息
//            isBookShowAuth = true;
//        }else{
//            if(mAuthorityItem == null){
//                //无直播间权限信息
//                isBookShowAuth = true;
//            }else{
//                if(!mAuthorityItem.isHasBookingAuth){
//                    //无Book权限
//                    isBookShowAuth = false;
//                }
//            }
//        }
//
//        //ID不为空
//        if(!TextUtils.isEmpty(mAnchorId) && isBookShowAuth){
//            btnBook.setVisibility(View.VISIBLE);
//        }
//    }

    /**
     * 兼容主播id为空时错误显示
     */
    private void showBookButton(IMInviteErrItem inviteErrItem){
        //有BOOK权限
//        if(mIMRoomInItem!= null && mIMRoomInItem.priv != null && mIMRoomInItem.priv.isHasBookingAuth){
//            //ID不为空
//            if(!TextUtils.isEmpty(mAnchorId)){
//                btnBook.setVisibility(View.VISIBLE);
//            }
//        }

        //是否有BOOK权限
        boolean isBookShowAuth = true;
        if(inviteErrItem.priv != null && !inviteErrItem.priv.isHasBookingAuth){
            //无Book权限
            isBookShowAuth = false;
        }

        //ID不为空
        if(!TextUtils.isEmpty(mAnchorId) && isBookShowAuth){
            btnBook.setVisibility(View.VISIBLE);
        }
    }

    /**
     * 显示Chat按钮
     */
    private void showChatButton(){
        btnChat.setVisibility(View.VISIBLE);
    }

    /**
     * 显示SendMail按钮
     */
    private void showSendMailButton(){
        btnSendMail.setVisibility(View.VISIBLE);
    }

    /*********************************** 公共错误处理  ***********************************************/

    /*********************************  推荐业务逻辑start  ***********************************************/

    /**
     * 获取推荐列表
     */
    private void getRecommandList(){
        isCanShowRecommand = true;
        LiveRequestOperator.getInstance().GetPromoAnchorList(2, RequestJniLiveShow.PromotionCategoryType.LiveRoom, mAnchorId, new OnGetPromoAnchorListCallback() {
            @Override
            public void onGetPromoAnchorList(boolean isSuccess, int errCode, String errMsg, final HotListItem[] anchorList) {
                if(!isOverTime && isSuccess && isCanShowRecommand && anchorList != null && anchorList.length > 0) {
                    //显示推荐模块
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            civRecommand1.setImageResource(R.drawable.ic_default_photo_woman);
                            civRecommand2.setImageResource(R.drawable.ic_default_photo_woman);
                            if(!TextUtils.isEmpty(anchorList[0].photoUrl)){
//                                Picasso.with(getApplicationContext()).load(anchorList[0].photoUrl)
//                                        .placeholder(R.drawable.ic_default_photo_woman)
//                                        .error(R.drawable.ic_default_photo_woman)
//                                        .memoryPolicy(MemoryPolicy.NO_CACHE)
//                                        .into(civRecommand1);
                                PicassoLoadUtil.loadUrlNoMCache(civRecommand1,anchorList[0].photoUrl,R.drawable.ic_default_photo_woman);
                            }
                            civRecommand1.setTag(anchorList[0].userId);
                            tvRecommandName1.setTag(anchorList[0].userId);
                            tvRecommandName1.setText(anchorList[0].nickName);
                            if(anchorList.length >= 2){
                                civRecommand2.setTag(anchorList[1].userId);
                                tvRecommandName2.setTag(anchorList[1].userId);
                                llRecommand2.setVisibility(View.VISIBLE);
                                if(!TextUtils.isEmpty(anchorList[1].photoUrl)){
//                                    Picasso.with(getApplicationContext()).load(anchorList[1].photoUrl)
//                                            .placeholder(R.drawable.ic_default_photo_woman)
//                                            .error(R.drawable.ic_default_photo_woman)
//                                            .memoryPolicy(MemoryPolicy.NO_CACHE)
//                                            .into(civRecommand2);
                                    PicassoLoadUtil.loadUrlNoMCache(civRecommand2,anchorList[1].photoUrl,R.drawable.ic_default_photo_woman);
                                }
                                tvRecommandName2.setText(anchorList[1].nickName);
                            }else{
                                llRecommand2.setVisibility(View.GONE);
                            }
                            llRecommand.setVisibility(View.VISIBLE);
                        }
                    });
                }
            }
        });
    }

    /*********************************  推荐业务逻辑end  ***********************************************/

    /********************************************* IM回调事件处理  *****************************************************/
    @Override
    public void OnLogin(final IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
        //断线重连通知
        if(!isOverTime) {
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    if (errType == IMClientListener.LCC_ERR_TYPE.LCC_ERR_SUCCESS) {
                        //重连成功，获取指定私密邀请状态
                        if (isInviting()) {
                            //邀请中，获取邀请状态
                            mIMManager.GetInviteInfo(mInvatationId);
                        }
                    }
                }
            });
        }
    }

    @Override
    public void OnLogout(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnKickOff(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnRecvLackOfCreditNotice(String roomId, String message, double credit, IMClientListener.LCC_ERR_TYPE err) {

    }

    @Override
    public void OnRecvCreditNotice(String roomId, double credit) {

    }

    @Override
    public void OnRecvAnchoeInviteNotify(String logId, String anchorId, String anchorName, String anchorPhotoUrl, String message) {

    }

    @Override
    public void OnRecvScheduledInviteNotify(String inviteId, String anchorId, String anchorName, String anchorPhotoUrl, String message) {

    }

    @Override
    public void OnRecvSendBookingReplyNotice(String inviteId, IMClientListener.BookInviteReplyType replyType) {

    }

    @Override
    public void OnRecvBookingNotice(String roomId, String userId, String nickName, String photoUrl, int leftSeconds) {

    }

    @Override
    public void OnRecvLevelUpNotice(int level) {

    }

    @Override
    public void OnRecvLoveLevelUpNotice(IMLoveLeveItem lovelevelItem) {

    }

    @Override
    public void OnRecvBackpackUpdateNotice(IMPackageUpdateItem item) {

    }

    @Override
    public void OnRoomIn(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMRoomInItem roomInfo, IMAuthorityItem authorityItem) {
        Log.d(TAG,"OnRoomIn-reqId:"+reqId+" success:"+success+" errType:"+errType+" errMsg:"+errMsg+" roomInfo:"+roomInfo);

        IMInviteErrItem inviteErrItem = new IMInviteErrItem();
        inviteErrItem.priv = authorityItem;

        onRoomInCallback(reqId, success, errType, errMsg, roomInfo, inviteErrItem);
    }

    @Override
    public void OnRoomOut(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnRecvLiveStart(String roomId, final int leftSeconds, String[] playUrls) {
        Log.d(TAG,"OnRecvLiveStart-roomId:"+roomId+" leftSeconds:"+leftSeconds);
        //通知进入直播间
        if(!isOverTime && mIMRoomInItem != null
                && mIMRoomInItem.roomId.equals(roomId)){
            //当start_wait时，IMRoomItem 中的videoUrls为NULL,需此处重新赋值
            mIMRoomInItem.videoUrls = playUrls;
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    startEnterReciprocal(leftSeconds);
                }
            });
        }
    }

    @Override
    public void OnGetInviteInfo(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, final IMInviteListItem inviteItem,final IMAuthorityItem priv) {
        Log.i("Jagger" , "直播过渡页 OnGetInviteInfo:" + errType.name() + ",errMsg:" + errMsg + ",book:" + (priv != null?"null":priv.isHasBookingAuth));
        if(!isOverTime && success){
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    //获取邀请信息成功
                    switch (inviteItem.inviteType){
                        case Pending:{
                            //邀请中,无需处理
                        }break;
                        case Accepted:{
                            //已接受，进入直播间
                            startRoomIn(inviteItem.roomId);
                        }break;

                        case Canceled:
                        case OverTime:
                        case AnchorAbsent:
                        case AudienceAbsent:
                        case Rejected:
                        case Unknown:
                        case Confirmed:{
                            //清除无效邀请id
                            mInvatationId = "";
                            //邀请无效，主播拒绝等统一无回复错误
                            IMInviteErrItem inviteErrItem = new IMInviteErrItem();
                            inviteErrItem.priv = priv;

                            showAudienceInviteInvalidError("", inviteErrItem);
                        }break;
                    }
                }
            });
        }
    }

    /**
     *
     * @param reqId
     * @param success
     * @param errType
     * @param errMsg
     * @param invitationId
     * @param timeout
     * @param roomId
     * @param errItem 2018-12-10 add by Jagger
     */
    @Override
    public void OnSendImmediatePrivateInvite(int reqId,final boolean success,final IMClientListener.LCC_ERR_TYPE errType,final String errMsg,
                                             final String invitationId, int timeout,final  String roomId,final IMInviteErrItem errItem) {
        if(!isOverTime && mCategoryType == CategoryType.Audience_Invite_Enter_Room){
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    if(success){
                        //进入直播间
                        if(!TextUtils.isEmpty(roomId)) {
                            //表示观众已在主播直播间，不需要等邀请返回
                            startRoomIn(roomId);
                        }else{
                            //发送邀请成功，需要等待主播响应
                            mInvatationId = invitationId;
                            //显示waiting界面,等待主播通知
                            showWaitForAnchorStartLive();
                            //启动显示可取消按钮
                            sendEmptyUiMessageDelayed(IMMEDIATE_INVITE_CANCELABLE, INVITE_CANCELABLE_TIMESTAMP);
                        }

                        if(mIsBubble){
                            LoginItem loginItem = LoginManager.getInstance().getLoginItem();
                            //冒泡进入，统计事件
                            String manId = "";
                            if(loginItem != null){
                                manId = loginItem.userId;
                            }
                            RequestJniOther.UpQnInviteId(manId, mAnchorId, invitationId, roomId, LSRequestEnum.LSBubblingInviteType.OneOnOne, new OnRequestCallback() {
                                @Override
                                public void onRequest(boolean isSuccess, int errCode, String errMsg) {

                                }
                            });
                        }

                    }else{
                        onIMRequestFaiHandler(errType, errMsg, errItem);
                    }
                }
            });
        }
    }

    /*********************************  刷新主播信息start  ***********************************************/

    /**
     * 获取主播信息
     * @param anchorId
     */
    private void getAnchorInfo(String anchorId){
        LiveRequestOperator.getInstance().GetUserInfo(anchorId, new OnGetUserInfoCallback() {
            @Override
            public void onGetUserInfo(boolean isSuccess, int errCode, String errMsg, final UserInfoItem userItem) {
                if(isSuccess){
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            mAnchorInfo = userItem;
                            if(mAnchorInfo != null){
                                if(!TextUtils.isEmpty(mAnchorInfo.photoUrl) && TextUtils.isEmpty(mAnchorPhotoUrl)){
                                    //重新加载头像
                                    mAnchorPhotoUrl = mAnchorInfo.photoUrl;
                                    if(civPhoto != null) {
//                                        Picasso.with(getApplicationContext()).load(mAnchorPhotoUrl)
//                                                .placeholder(R.drawable.ic_default_photo_woman)
//                                                .error(R.drawable.ic_default_photo_woman)
//                                                .memoryPolicy(MemoryPolicy.NO_CACHE)
//                                                .into(civPhoto);
                                        PicassoLoadUtil.loadUrlNoMCache(civPhoto,mAnchorPhotoUrl,R.drawable.ic_default_photo_woman);
                                    }
                                }
                                if(!TextUtils.isEmpty(mAnchorInfo.nickName) && TextUtils.isEmpty(mAnchorName)){
                                    mAnchorName = mAnchorInfo.nickName;
                                    if(tvAnchorName != null){
                                        tvAnchorName.setText(Html.fromHtml(getResources().getString(R.string.liveroom_transition_anchor_name_and_id, mAnchorName, mAnchorId)));
                                    }
                                }
                            }
                        }
                    });
                }
            }
        });
    }

    /**
     * 根据主播状态设置进入私密直播邀请按钮设置
     * @param btnStart
     */
    private void setAndShowStartPrivateInviteButton(ButtonRaised btnStart, IMInviteErrItem inviteErrItem){
        if(inviteErrItem != null && inviteErrItem.priv.isHasOneOnOneAuth){
            btnStart.setVisibility(View.VISIBLE);
//            if(type == AnchorLevelType.gold){
            //黄金会员
//            btnStart.setImageResource(R.drawable.button_start_private_broadcast);
//                Drawable tempDrawable = btnStart.getDrawable();
//                if((tempDrawable != null)
//                        && (tempDrawable instanceof AnimationDrawable)){
//                    ((AnimationDrawable)tempDrawable).start();
//                }
//            }else{
//                btnStart.setImageResource(R.drawable.list_button_start_normal_private_broadcast);
//            }
        }
    }

    /*********************************  才艺推荐  ***********************************************/
    /**
     * 隐藏才艺推荐
     */
    private void hideAndStopAnimation(){
        if(animationDrawableTalent != null && animationDrawableTalent.isRunning()){
            animationDrawableTalent.stop();
        }
        mLlTalent.setVisibility(View.GONE);
    }

    /**
     * 显示才艺推荐
     */
    private void showAndStartAnimation(){
        //处理隐藏才艺相关
//        mLlTalent.setVisibility(View.VISIBLE);
//        if(animationDrawableTalent != null && !animationDrawableTalent.isRunning()){
//            animationDrawableTalent.start();
//        }
    }

    /*********************************  直播间信息回调  ***********************************************/
    /**
     *
     * @param roomId
     * @param errType
     * @param errMsg
     * @param privItem  2018-12-5 add by Jagger
     */
    @Override
    public void OnRecvRoomCloseNotice(String roomId,final IMClientListener.LCC_ERR_TYPE errType,final String errMsg,final IMAuthorityItem privItem) {
        Log.i("Jagger" , "OnRecvRoomCloseNotice:" + (privItem == null? "":privItem.isHasBookingAuth));

        //直播间未超时
        if(!isOverTime && mIMRoomInItem != null && !TextUtils.isEmpty(mIMRoomInItem.roomId) && roomId.equals(mIMRoomInItem.roomId)){
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    if(null != mIMRoomInItem ){
                        boolean isShowRecommand = false;
                        if(errType == IMClientListener.LCC_ERR_TYPE.LCC_ERR_RECV_REGULAR_CLOSE_ROOM){
                            //正常关闭才推荐
                            isShowRecommand = true;
                        }
                        startActivity(LiveRoomNormalErrorActivity.getIntent(mContext, PAGE_ERROR_LIEV_EDN, errMsg,
                                mIMRoomInItem.userId, mIMRoomInItem.nickName, mIMRoomInItem.photoUrl, getRoomPhotoUrl(), isShowRecommand, privItem)
                        );
                        finish();
                    }
                }
            });
        }
    }

    @Override
    public void OnRecvEnterRoomNotice(String roomId, String userId, String nickName, String photoUrl, String riderId, String riderName, String riderUrl, int fansNum, String honorImg, boolean isHasTicket) {

    }

    @Override
    public void OnRecvLeaveRoomNotice(String roomId, String userId, String nickName, String photoUrl, int fansNum) {

    }

    @Override
    public void OnRecvRebateInfoNotice(String roomId, IMRebateItem item) {

    }

    /**
     *
     * @param roomId
     * @param leftSeconds
     * @param err
     * @param errMsg
     * @param privItem 2018-12-5 add by Jagger
     */
    @Override
    public void OnRecvLeavingPublicRoomNotice(String roomId, int leftSeconds, IMClientListener.LCC_ERR_TYPE err, String errMsg, IMAuthorityItem privItem) {
        Log.i("Jagger" , "OnRecvLeavingPublicRoomNotice:" + (privItem == null? "":privItem.isHasBookingAuth));
//        if(mIMRoomInItem!= null ){
//            mAuthorityItem = privItem;
//        }
    }

    /**
     *
     * @param roomId
     * @param err
     * @param errMsg
     * @param credit
     * @param privItem  2018-12-5 add by Jagger
     */
    @Override
    public void OnRecvRoomKickoffNotice(String roomId, IMClientListener.LCC_ERR_TYPE err, String errMsg, double credit, IMAuthorityItem privItem) {
        Log.i("Jagger" , "OnRecvRoomKickoffNotice:" + (privItem == null? "":privItem.isHasBookingAuth));
//        if(mIMRoomInItem!= null ){
//            mAuthorityItem = privItem;
//        }
    }

    @Override
    public void OnRecvChangeVideoUrl(String roomId, boolean isAnchor, String[] playUrls, String userId) {
        if(mIMRoomInItem != null && !TextUtils.isEmpty(mIMRoomInItem.roomId)
                && mIMRoomInItem.roomId.equals(roomId)){
            if((mIMRoomInItem.videoUrls == null) || (mIMRoomInItem.videoUrls.length == 0)){
                //更新返点时间
                LiveRoomCreditRebateManager.getInstance().refreshRebateLastUpdate();
            }
            mIMRoomInItem.videoUrls = playUrls;
        }
    }

    @Override
    public void OnControlManPush(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, String[] manPushUrl) {

    }

    @Override
    public void OnSendRoomMsg(boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMMessageItem msgItem) {

    }

    @Override
    public void OnRecvRoomMsg(IMMessageItem msgItem) {

    }

    @Override
    public void OnRecvSendSystemNotice(IMMessageItem msgItem) {

    }

    @Override
    public void OnSendGift(boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMMessageItem msgItem, double credit, double rebateCredit) {

    }

    @Override
    public void OnRecvRoomGiftNotice(IMMessageItem msgItem) {

    }

    @Override
    public void OnSendBarrage(boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMMessageItem msgItem, double credit, double rebateCredit) {

    }

    @Override
    public void OnRecvRoomToastNotice(IMMessageItem msgItem) {

    }

    @Override
    public void OnSendTalent(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, String talentInviteId, String talentId) {

    }

    @Override
    public void OnRecvSendTalentNotice(String roomId, String talentInviteId, String talentId, String name, double credit, IMClientListener.TalentInviteStatus status, double rebateCredit, String giftId, String giftName, int giftNum) {

    }

    @Override
    public void OnRecvTalentPromptNotice(String roomId, String introduction) {

    }

    @Override
    public void OnRecvHonorNotice(String honorId, String honorUrl) {

    }

    /*********************************  抽取公共业务逻辑，解决处理中和描述冲突  ***********************************************/
    /**
     * 统一处理更新描述文字，解决与处理中状态冲突
     * @param desc
     */
    private void setDescText(String desc){
        if(tvDesc != null){
            tvDesc.setText(desc);
        }
        if(!TextUtils.isEmpty(desc)){
            hideLoadingProgress();
        }
    }

    /**
     * 设置描述
     * @param desc
     */
    private void setDescText(Spanned desc){
        if(!TextUtils.isEmpty(desc)){
            if(tvDesc != null){
                tvDesc.setText(desc);
            }

            hideLoadingProgress();
        }
    }

    /**
     * 显示进度动画
     */
    private void showLoadingProgress(){
         if(pb_waiting != null){
             pb_waiting.setVisibility(View.VISIBLE);
             AnimationDrawable progressDrawable = (AnimationDrawable) pb_waiting.getDrawable();
             if(!progressDrawable.isRunning()){
                 progressDrawable.start();
             }
         }
    }

    /**
     * 隐藏进度动画
     */
    private void hideLoadingProgress(){
        if(pb_waiting != null){
            AnimationDrawable progressDrawable = (AnimationDrawable) pb_waiting.getDrawable();
            if(progressDrawable.isRunning()){
                progressDrawable.stop();
            }
            pb_waiting.setVisibility(View.GONE);
        }
    }

    /**
     * 兼容获取roomPhotoUrl（外部链接及push点击进入）
     * @return
     */
    private String getRoomPhotoUrl(){
        String roomPhotoUrl = mRoomPhotoUrl;
        if (TextUtils.isEmpty(roomPhotoUrl)) {
            if(mAnchorInfo != null && mAnchorInfo.anchorInfo != null){
                roomPhotoUrl = mAnchorInfo.anchorInfo.roomPhotoUrl;
            }
        }
        return roomPhotoUrl;
    }

}
