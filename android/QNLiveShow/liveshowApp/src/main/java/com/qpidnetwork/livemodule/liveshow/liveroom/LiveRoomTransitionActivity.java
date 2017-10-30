package com.qpidnetwork.livemodule.liveshow.liveroom;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.os.Message;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.framework.services.LiveService;
import com.qpidnetwork.livemodule.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnAcceptInstanceInviteCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetPromoAnchorListCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniLiveShow;
import com.qpidnetwork.livemodule.httprequest.item.HotListItem;
import com.qpidnetwork.livemodule.httprequest.item.LiveRoomType;
import com.qpidnetwork.livemodule.im.IMInviteLaunchEventListener;
import com.qpidnetwork.livemodule.im.IMManager;
import com.qpidnetwork.livemodule.im.IMOtherEventListener;
import com.qpidnetwork.livemodule.im.listener.IMClientListener;
import com.qpidnetwork.livemodule.im.listener.IMInviteListItem;
import com.qpidnetwork.livemodule.im.listener.IMPackageUpdateItem;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.livemodule.liveshow.WebViewActivity;
import com.qpidnetwork.livemodule.liveshow.home.MainFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.personal.book.BookPrivateActivity;
import com.qpidnetwork.livemodule.utils.SystemUtils;
import com.squareup.picasso.Picasso;
import com.squareup.picasso.Target;

import java.util.Timer;
import java.util.TimerTask;


/**
 * 邀请及进入直播间过渡页，主要处理邀请及进入直播间过程中的异常
 * @author Hunter
 */
public class LiveRoomTransitionActivity extends BaseFragmentActivity implements IMOtherEventListener, IMInviteLaunchEventListener{

    private static final int CLOSABLE_TIMESTAMP = 10 * 1000;      //进入界面1o秒后可取消
    private static final int DEFAULT_MAX_TIMEOUT = 3 * 60 * 1000;   //进入过渡页后3分钟未处理完成，当成超时处理
    private static final int INVITE_CANCELABLE_TIMESTAMP = 10 * 1000;      //进入界面1o秒后可取消
    private static final int BACKGROUD_LIVE_OVERTIME_TIMESTAMP = 60 * 1000;     //直播中，切换到后台自动结束事件间隔

    private static final int TEN_SENCONDS_EVNET = 1;
    private static final int OVERTIME_EVNET = 2;
    private static final int IMMEDIATE_INVITE_CANCELABLE = 3;
    private static final int BACKGROUD_ROOMOUT_NOTIFY = 4;

    public static final String LIVEROOM_ROOMINFO_ITEM = "roomInfo";
    private static final String TRANSITION_OPERATETYPE = "operateType";
    private static final String TRANSITION_ERRTYPE = "errType";
    private static final String TRANSITION_ANCHOR_ID = "anchorId";
    private static final String TRANSITION_ANCHOR_NAME = "anchorName";
    private static final String TRANSITION_ANCHOR_PHOTOURL = "anchorPhotoUrl";
    private static final String TRANSITION_ROOMID = "roomId";
    public static final String LIVEROOM_ROOMINFO_ROOMPHOTOURL = "mRoomPhotoUrl";
    private static final String TRANSITION_INVITATIONID = "invitationId";

    //view
    private ImageView btnClose;
    private CircleImageView civPhoto;
    private TextView tvAnchorName;
    private TextView tvDesc;
    //倒计时
    private LinearLayout llCountDown;
    private TextView tvCountDown;
    //按钮
    private Button btnCancel;
    private Button btnRetry;
    private Button btnYes;
    private Button btnStartPrivate;
    private Button btnBook;
    private Button btnViewHot;
    private Button btnAddCredit;
    private Button btnViewProfile;
    //推荐
    private LinearLayout llRecommand;
    private TextView tvRecommandName1;
    private CircleImageView civRecommand1;
    private TextView tvRecommandName2;
    private CircleImageView civRecommand2;
    //进度条
    private ProgressBar pb_waiting;
    //高斯模糊背景
    private ImageView iv_gaussianBlur;
    private View v_gaussianBlurFloat;


    //data
    private CategoryType mCategoryType;       //用于区分不同场景进入
    private String mAnchorId = "";
    private String mAnchorName = "";
    private String mAnchorPhotoUrl = "";
    private String mRoomId = "";

    //处理过程中，中间存储数据
    private IMRoomInItem mIMRoomInItem = null;  //进入房间成功返回房间信息，本地缓存
    private int mLeftSeconds = 0;               //记录开播倒计时时间
    private String mInvatationId = "";          //邀请Id
    private boolean isClosable = false;         //是否可关闭
    private boolean isOverTime = false;         //是否已超时，如果超时，重置所有状态，停止所有事务处理
    private boolean isCanShowRecommand = false; //用于解决获取推荐列表异步与用户操作冲突问题
    private boolean isBackgroudInRoomOut = false;       //记录是否后台进入直播间超时退出直播间错误

    //Manager
    private IMManager mIMManager;
    private Timer mReciprocalTimer;

    //直播间跳转过来所对应的事件类型
    private String mRoomPhotoUrl = null;

    public enum CategoryType{
        Enter_Public_Room,
        Audience_Invite_Enter_Room,
        Anchor_Invite_Enter_Room,
        Schedule_Invite_Enter_Room
    }

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

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        TAG = LiveRoomTransitionActivity.class.getSimpleName();
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_liveroom_transition);

        mIMManager = IMManager.getInstance();
        mReciprocalTimer = new Timer();
        registerListener();

        initViews();
        initData();

        //同步模块直播进行中
        LiveService.getInstance().setServiceActive(true, mAnchorId);
    }

    private void initViews(){
        btnClose = (ImageView)findViewById(R.id.btnClose);
        civPhoto = (CircleImageView)findViewById(R.id.civPhoto);
        tvAnchorName = (TextView)findViewById(R.id.tvAnchorName);
        tvDesc = (TextView)findViewById(R.id.tvDesc);

        //倒计时
        llCountDown = (LinearLayout) findViewById(R.id.llCountDown);
        tvCountDown = (TextView) findViewById(R.id.tvCountDown);

        //按钮区域
        btnCancel = (Button) findViewById(R.id.btnCancel);
        btnRetry = (Button) findViewById(R.id.btnRetry);
        btnYes = (Button) findViewById(R.id.btnYes);
        btnStartPrivate = (Button) findViewById(R.id.btnStartPrivate);
        btnBook = (Button) findViewById(R.id.btnBook);
        btnViewHot = (Button) findViewById(R.id.btnViewHot);
        btnAddCredit = (Button) findViewById(R.id.btnAddCredit);
        btnViewProfile = (Button) findViewById(R.id.btnViewProfile);

        //推荐
        llRecommand = (LinearLayout) findViewById(R.id.llRecommand);
        tvRecommandName1 = (TextView) findViewById(R.id.tvRecommandName1);
        civRecommand1 = (CircleImageView) findViewById(R.id.civRecommand1);
        tvRecommandName2 = (TextView) findViewById(R.id.tvRecommandName2);
        civRecommand2 = (CircleImageView) findViewById(R.id.civRecommand2);

        //进度
        pb_waiting = (ProgressBar) findViewById(R.id.pb_waiting);

        //高斯模糊背景
        iv_gaussianBlur = (ImageView) findViewById(R.id.iv_gaussianBlur);
        v_gaussianBlurFloat = findViewById(R.id.v_gaussianBlurFloat);
        v_gaussianBlurFloat.setBackgroundDrawable(new ColorDrawable(Color.parseColor("#de000000")));
        v_gaussianBlurFloat.setVisibility(View.GONE);

        btnClose.setOnClickListener(this);
        btnCancel.setOnClickListener(this);
        btnRetry.setOnClickListener(this);
        btnYes.setOnClickListener(this);
        btnStartPrivate.setOnClickListener(this);
        btnBook.setOnClickListener(this);
        btnViewHot.setOnClickListener(this);
        btnAddCredit.setOnClickListener(this);
        btnViewProfile.setOnClickListener(this);
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

            if(bundle.containsKey(LIVEROOM_ROOMINFO_ROOMPHOTOURL)){
                mRoomPhotoUrl = bundle.getString(LIVEROOM_ROOMINFO_ROOMPHOTOURL);
                Log.d(TAG,"initData-mRoomPhotoUrl:"+mRoomPhotoUrl);
            }
        }

        if(!TextUtils.isEmpty(mAnchorPhotoUrl)) {
            Picasso.with(getApplicationContext()).load(mAnchorPhotoUrl)
                    .placeholder(R.drawable.ic_default_photo_woman)
                    .error(R.drawable.ic_default_photo_woman)
                    .into(civPhoto);
        }

        if(!TextUtils.isEmpty(mRoomPhotoUrl)){
            //为空 则直接显示默认的原型图背景
            Picasso.with(getApplicationContext()).load(mRoomPhotoUrl)
                    .into(new Target() {
                        @Override
                        public void onBitmapLoaded(Bitmap bitmap, Picasso.LoadedFrom loadedFrom) {
                            Log.d(TAG,"initData-onBitmapLoaded");
                            iv_gaussianBlur.setImageBitmap(bitmap);
                            v_gaussianBlurFloat.setVisibility(View.VISIBLE);
                        }

                        @Override
                        public void onBitmapFailed(Drawable drawable) {
                            Log.d(TAG,"initData-onBitmapFailed");
                            iv_gaussianBlur.setImageDrawable(getResources().getDrawable(R.drawable.bg_liveroom_transition));
                        }

                        @Override
                        public void onPrepareLoad(Drawable drawable) {
                            Log.d(TAG,"initData-onPrepareLoad");
                            iv_gaussianBlur.setImageDrawable(getResources().getDrawable(R.drawable.bg_liveroom_transition));
                        }
                    });
        }

        tvAnchorName.setText(mAnchorName);

        //绑定当前主播Id
        btnViewProfile.setTag(mAnchorId);

        if(mCategoryType != null && !TextUtils.isEmpty(mAnchorId)) {
            //启动本地超时逻辑
           start();
        }else{
            finish();
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        //处理切换到后台返回
        if(isBackgroudInRoomOut){
            startActivity(LiveRoomNormalErrorActivity.getIntent(this,
                    LiveRoomNormalErrorActivity.PageErrorType.PAGE_ERROR_BACKGROUD_OVERTIME,
                    mAnchorId, mAnchorName, mAnchorPhotoUrl,mRoomPhotoUrl));
            finish();
        }else{
            if(mIMRoomInItem != null && !mIMRoomInItem.needWait && mIMRoomInItem.leftSeconds == 0){
                enterLiveRoom();
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
            showWaitForAnchorStartLive();
            startInvite(true);
        } else if (i == R.id.btnStartPrivate) {
            startActivity(LiveRoomTransitionActivity.getIntent(this,
                    CategoryType.Audience_Invite_Enter_Room, mAnchorId,
                    mAnchorName, mAnchorPhotoUrl, "", null));
            finish();
        } else if (i == R.id.btnBook) {
            startActivity(new Intent(mContext, BookPrivateActivity.class));
            finish();
        } else if (i == R.id.btnViewHot) {
            Intent intent = new Intent(this, MainFragmentActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(intent);
            finish();
        } else if (i == R.id.btnAddCredit) {
            startActivity(WebViewActivity.getIntent(this, "Add Credit", "http://www.baidu.com"));
        } else if (i == R.id.btnViewProfile || i == R.id.civRecommand1 || i == R.id.civRecommand2) {
            String anchorId = (String) v.getTag();
            if (!TextUtils.isEmpty(anchorId)) {

            }
        } else if (i == R.id.btnRetry) {
            resetAll();
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

        showInviteOrRoomInRequesting();
        switch (mCategoryType){
            case Enter_Public_Room:{
                //进入公开直播间
                mIMManager.PublicRoomIn(mAnchorId);
            }break;
            case Audience_Invite_Enter_Room:{
                //用户发起立即私密邀请
                if(TextUtils.isEmpty(mRoomId)){
                    startInvite(false);
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
        llCountDown.setVisibility(View.GONE);

        btnCancel.setVisibility(View.GONE);
        btnRetry.setVisibility(View.GONE);
        btnYes.setVisibility(View.GONE);
        btnStartPrivate.setVisibility(View.GONE);
        btnBook.setVisibility(View.GONE);
        btnViewHot.setVisibility(View.GONE);
        btnAddCredit.setVisibility(View.GONE);
        btnViewProfile.setVisibility(View.GONE);

        llRecommand.setVisibility(View.GONE);

        pb_waiting.setVisibility(View.GONE);

        //数据
        mIMRoomInItem = null;
        mLeftSeconds = 0;
        mInvatationId = "";
        isOverTime = false;
        isCanShowRecommand = false;
        if(mReciprocalTimer != null){
            mReciprocalTimer.cancel();
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
    }

    /**
     * 解绑监听器
     */
    private void unRegisterListener(){
        mIMManager.unregisterIMOtherEventListener(this);
        mIMManager.unregisterIMInviteLaunchEventListener(this);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        //同步模块直播已结束
        LiveService.getInstance().setServiceActive(true, mAnchorId);

        unRegisterListener();
        if(mReciprocalTimer != null){
            mReciprocalTimer.cancel();
        }
        //删除定时消息
        removeUiMessages(TEN_SENCONDS_EVNET);
        removeUiMessages(OVERTIME_EVNET);
        removeUiMessages(IMMEDIATE_INVITE_CANCELABLE);
        removeUiMessages(BACKGROUD_ROOMOUT_NOTIFY);
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if ( keyCode == KeyEvent.KEYCODE_BACK && event.getAction() == KeyEvent.ACTION_UP ){
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
        showInviteOrRoomInRequesting();
        mIMManager.sendImmediatePrivateInvite(mAnchorId, "", force);
    }

    /**
     * 收到立即私密邀请应答处理
     * @param replyType
     * @param roomId
     */
    private void onInviteReplyHandler(IMClientListener.InviteReplyType replyType, String roomId){
        //重置邀请ID，清除邀请状态
        mInvatationId = "";
        //取消定时显示按钮
        removeUiMessages(IMMEDIATE_INVITE_CANCELABLE);

        switch (replyType){
            case Defined: {
                showAudienceInviteInvalidError();
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
    public void OnSendImmediatePrivateInvite(int reqId, final boolean success, final IMClientListener.LCC_ERR_TYPE errType, String errMsg, final String invitationId, int timeout, final String roomId) {
        if(!isOverTime){
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
                            //启动显示可取消按钮
                            sendEmptyUiMessageDelayed(IMMEDIATE_INVITE_CANCELABLE, INVITE_CANCELABLE_TIMESTAMP);
                        }
                    }else{
                        onIMRequestFaiHandler(errType);
                    }
                }
            });
        }
    }

    @Override
    public void OnCancelImmediatePrivateInvite(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, String roomId) {

    }

    @Override
    public void OnRecvInviteReply(String inviteId, final IMClientListener.InviteReplyType replyType, final String roomId, LiveRoomType roomType, String anchorId, String nickName, String avatarImg, String message) {
        if(!isOverTime && !TextUtils.isEmpty(inviteId) && inviteId.equals(mInvatationId)) {
            //添加防守，一个邀请仅处理一次通知（多次通知后面通知无效）
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    onInviteReplyHandler(replyType, roomId);
                }
            });
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
                                 final IMClientListener.LCC_ERR_TYPE errType, String errMsg, final IMRoomInItem roomInfo){
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
                        //是否需要等待开播通知
                        if(!roomInfo.needWait){
                            //不需要等待，进入开播倒数进入逻辑
                            startEnterReciprocal(roomInfo.leftSeconds);
                        }else{
                            showWaitForAnchorStartLive();
                        }
                    }else{
                        //进入房间失败，统一处理
                        onIMRequestFaiHandler(errType);
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
        if(leftSeconds > 0){
            showCountDownToEnterRoom();
            mLeftSeconds = leftSeconds;
            mReciprocalTimer.schedule(new TimerTask() {
                @Override
                public void run() {
                    onWaitEnterTimerRefresh(mLeftSeconds);
                    if(mLeftSeconds <= 0){
                        //开播倒数结束
                        mReciprocalTimer.cancel();
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
                tvCountDown.setText(String.valueOf(mLeftSeconds));
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
        tvDesc.setText(R.string.liveroom_transition_waiting_anchor_start_tips);
        pb_waiting.setVisibility(View.VISIBLE);
    }

    /**
     * 倒计时进入直播间
     */
    private void showCountDownToEnterRoom(){
        tvDesc.setText(R.string.liveroom_transition_enterroom_countdown_tips);
        //倒计时可见
        llCountDown.setVisibility(View.VISIBLE);
        pb_waiting.setVisibility(View.GONE);
    }

    /**
     * 进入直播间界面跳转
     */
    private void enterLiveRoom(){
        unRegisterListener();

        //判断当前是否后台，后台时统一不跳转（解决5.0以下startActivity会在后台打开页面，但是5.0以上会将应用带到前台），在resume处理超出1分钟停止，否则进入直播间
        if(SystemUtils.isBackground(this)){
            //修改进入直播间返回参数，不用等待，不用倒计时
            mIMRoomInItem.needWait = false;
            mIMRoomInItem.leftSeconds = 0;

            //启动后台定时停止计时
            sendEmptyUiMessageDelayed(BACKGROUD_ROOMOUT_NOTIFY, BACKGROUD_LIVE_OVERTIME_TIMESTAMP);
        }else {
            //进入直播间
            Intent intent = null;
            if (mIMRoomInItem.roomType == IMRoomInItem.IMLiveRoomType.FreePublicRoom) {
                intent = new Intent(this, FreePublicLiveRoomActivity.class);
            } else if (mIMRoomInItem.roomType == IMRoomInItem.IMLiveRoomType.PaidPublicRoom) {
                intent = new Intent(this, PayPublicLiveRoomActivity.class);
            }else if(mIMRoomInItem.roomType == IMRoomInItem.IMLiveRoomType.AdvancedPrivateRoom){
                intent = new Intent(this, AdvancePrivateLiveRoomActivity.class);
            }else if(mIMRoomInItem.roomType == IMRoomInItem.IMLiveRoomType.NormalPrivateRoom){
                intent = new Intent(this, NormalPrivateLiveRoomActivity.class);
            }
            if (null != intent) {
                intent.putExtra(LIVEROOM_ROOMINFO_ITEM, mIMRoomInItem);
                intent.putExtra(LIVEROOM_ROOMINFO_ROOMPHOTOURL, mRoomPhotoUrl);
                startActivity(intent);
            }
            finish();
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
            public void onAcceptInstanceInvite(final boolean isSuccess, int errCode, final String errMsg, final String roomId, int roomType) {
                if(!isOverTime){
                    //未超时停止响应其他
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            if(isSuccess){
                                startRoomIn(roomId);
                            }else{
                                showAcceptAnchorInvitationError(errMsg);
                            }
                        }
                    });
                }
            }
        });
    }

    /**
     * 应邀失败错误页
     */
    private void showAcceptAnchorInvitationError(String description){
        if(!TextUtils.isEmpty(description)){
            tvDesc.setText(description);
        }else{
            tvDesc.setText(getResources().getString(R.string.liveroom_transition_anchor_invite_error));
        }
        btnRetry.setVisibility(View.VISIBLE);
        pb_waiting.setVisibility(View.GONE);
    }

    /*********************************  应邀进入直播间逻辑start  ***********************************************/


    /*********************************  特殊界面切换逻辑  ***********************************************/
    /**
     * 邀请或进入房间请求过程中
     */
    private void showInviteOrRoomInRequesting(){
        tvDesc.setText("");
        pb_waiting.setVisibility(View.VISIBLE);
    }

    /**
     * 显示180秒超时错误页
     */
    private void showOverTimeEvent(){
        if(isInviting() || isWaitingEnterRoom()){
            //邀请中或者登入进入直播间中
            if(isInviting()){
                //取消邀请
                cancelInvite(mInvatationId);
                //清除无效invitationId
                mInvatationId = "";
            }else if(isWaitingEnterRoom()){
                //退出直播间
                mIMManager.RoomOut(mIMRoomInItem.roomId);
            }

            //显示错误也
            pb_waiting.setVisibility(View.GONE);
            btnRetry.setVisibility(View.VISIBLE);
            btnBook.setVisibility(View.VISIBLE);
            tvDesc.setText(getResources().getString(R.string.liveroom_transition_network_normal_error));

            //是否停止业务处理
            isOverTime = true;
        }
    }

    /*********************************  特殊界面切换逻辑  ***********************************************/

    /*********************************** 公共错误处理  ***********************************************/
    /**
     * IM错误统一处理
     * @param errType
     */
    private void onIMRequestFaiHandler(IMClientListener.LCC_ERR_TYPE errType){
        //异常处理
        pb_waiting.setVisibility(View.GONE);
        String decription = "";
        switch (errType){
            case LCC_ERR_ANCHOR_OFFLINE:{
                //立即私密邀请，主播不在线
                decription = getResources().getString(R.string.liveroom_transition_anchor_offline);
                btnBook.setVisibility(View.VISIBLE);
            }break;
            case LCC_ERR_NO_CREDIT:{
                //信用点不足
                if(mCategoryType == CategoryType.Enter_Public_Room){
                    //进入付费公开直播间信用点不足
                    decription = getResources().getString(R.string.liveroom_transition_public_roomin_noenough_money);
                }else{
                    //私密邀请信用点不足
                    decription = getResources().getString(R.string.liveroom_transition_invite_noenough_money);
                }
                btnAddCredit.setVisibility(View.VISIBLE);
            }break;
            case LCC_ERR_ANCHOR_PLAYING:{
                //主播正在私密直播中
                decription = getResources().getString(R.string.liveroom_transition_anchor_private_broadcast_exception);
                btnYes.setVisibility(View.VISIBLE);

                //获取推荐列表刷新
                getRecommandList();
            }break;
            case LCC_ERR_ANCHOR_BUSY:{
                //邀请失败（主播拒绝、无回复、缺席）
                decription = getResources().getString(R.string.liveroom_transition_invite_error_busy);
                btnBook.setVisibility(View.VISIBLE);
            }break;

            case LCC_ERR_AUDIENCE_LIMIT:{
                //进入直播间，人数过多错误
                decription = getResources().getString(R.string.liveroom_transition_enterroom_full);
                btnStartPrivate.setVisibility(View.VISIBLE);
                btnBook.setVisibility(View.VISIBLE);
            }break;

            case LCC_ERR_ROOM_CLOSE:
            case LCC_ERR_NOT_FOUND_ROOM:
            case LCC_ERR_LIVEROOM_NO_EXIST:
            case LCC_ERR_ANCHOR_NO_ON_LIVEROOM:
            case LCC_ERR_LIVEROOM_CLOSED:{
                //房间已关闭，直播间无效等
                decription = getResources().getString(R.string.liveroom_transition_broadcast_ended);
                btnBook.setVisibility(View.VISIBLE);
                //推荐列表
                getRecommandList();
            }break;

            default:{
                //统一定义为普通错误，统一处理
                decription = getResources().getString(R.string.liveroom_transition_network_normal_error);
                btnRetry.setVisibility(View.VISIBLE);
                btnBook.setVisibility(View.VISIBLE);
            }break;
        }
        tvDesc.setText(decription);
    }

    /**
     * 邀请已决绝／已超时／已完成等邀请处于无效状态错误页
     */
    private void showAudienceInviteInvalidError(){
        pb_waiting.setVisibility(View.GONE);
        btnRetry.setVisibility(View.VISIBLE);
        btnBook.setVisibility(View.VISIBLE);
        tvDesc.setText(getResources().getString(R.string.liveroom_transition_invite_deny));
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
                                Picasso.with(getApplicationContext()).load(anchorList[0].photoUrl)
                                        .placeholder(R.drawable.ic_default_photo_woman)
                                        .error(R.drawable.ic_default_photo_woman)
                                        .into(civRecommand1);
                            }
                            civRecommand1.setTag(anchorList[0].userId);
                            tvRecommandName1.setText(anchorList[0].nickName);
                            if(anchorList.length >= 2){
                                civRecommand2.setTag(anchorList[1].userId);
                                civRecommand2.setVisibility(View.VISIBLE);
                                tvRecommandName2.setVisibility(View.VISIBLE);
                                if(!TextUtils.isEmpty(anchorList[1].photoUrl)){
                                    Picasso.with(getApplicationContext()).load(anchorList[1].photoUrl)
                                            .placeholder(R.drawable.ic_default_photo_woman)
                                            .error(R.drawable.ic_default_photo_woman)
                                            .into(civRecommand2);
                                }
                                tvRecommandName2.setText(anchorList[1].nickName);
                            }else{
                                civRecommand2.setVisibility(View.GONE);
                                tvRecommandName2.setVisibility(View.GONE);
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
    public void OnRecvLackOfCreditNotice(String roomId, String message, double credit) {

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
    public void OnRecvLoveLevelUpNotice(int lovelevel) {

    }

    @Override
    public void OnRecvBackpackUpdateNotice(IMPackageUpdateItem item) {

    }

    @Override
    public void OnRoomIn(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMRoomInItem roomInfo) {
        Log.d(TAG,"OnRoomIn-reqId:"+reqId+" success:"+success+" errType:"+errType+" errMsg:"+errMsg+" roomInfo:"+roomInfo);
        onRoomInCallback(reqId, success, errType, errMsg, roomInfo);
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
    public void OnGetInviteInfo(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, final IMInviteListItem inviteItem) {
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
                            showAudienceInviteInvalidError();
                        }break;
                    }
                }
            });
        }
    }

}
