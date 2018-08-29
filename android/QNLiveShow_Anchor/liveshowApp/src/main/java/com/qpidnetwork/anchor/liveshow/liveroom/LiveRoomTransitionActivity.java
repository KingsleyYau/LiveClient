package com.qpidnetwork.anchor.liveshow.liveroom;

import android.app.AlertDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.os.Message;
import android.provider.Settings;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.bean.CommonConstant;
import com.qpidnetwork.anchor.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.anchor.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.anchor.httprequest.LiveRequestOperator;
import com.qpidnetwork.anchor.httprequest.OnAcceptInstanceInviteCallback;
import com.qpidnetwork.anchor.httprequest.OnRequestCallback;
import com.qpidnetwork.anchor.httprequest.item.HttpLccErrType;
import com.qpidnetwork.anchor.httprequest.item.IntToEnumUtils;
import com.qpidnetwork.anchor.httprequest.item.LiveRoomType;
import com.qpidnetwork.anchor.im.IMInviteLaunchEventListener;
import com.qpidnetwork.anchor.im.IMManager;
import com.qpidnetwork.anchor.im.IMOtherEventListener;
import com.qpidnetwork.anchor.im.listener.IMClientListener;
import com.qpidnetwork.anchor.im.listener.IMInviteListItem;
import com.qpidnetwork.anchor.im.listener.IMRoomInItem;
import com.qpidnetwork.anchor.liveshow.home.MainFragmentActivity;
import com.qpidnetwork.anchor.liveshow.manager.CameraMicroPhoneCheckManager;
import com.qpidnetwork.anchor.utils.Log;
import com.qpidnetwork.anchor.utils.SystemUtils;
import com.squareup.picasso.MemoryPolicy;
import com.squareup.picasso.Picasso;

/**
 * Created by Hunter Mun on 2018/3/8.
 */

public class LiveRoomTransitionActivity extends BaseActionBarFragmentActivity implements IMOtherEventListener,
        IMInviteLaunchEventListener, CameraMicroPhoneCheckManager.OnCameraAndRecordAudioCheckListener {

    private static final int ROOM_CLOSE_BUTTON_DELAY_TIMESTAMP = 10 * 1000;      //进入界面1o秒后显示可关闭按钮

    private static final String TRANSITION_CATOGERY_TYPE = "categoryType";
    public static final String TRANSITION_USER_ID = "anchorId";
    private static final String TRANSITION_USER_NAME = "anchorName";
    private static final String TRANSITION_USER_PHOTOURL = "anchorPhotoUrl";
    private static final String TRANSITION_ROOMID = "roomId";
    private static final String TRANSITION_INVITATION_ID = "invitationId";

    public static final String LIVEROOM_ROOMINFO_ITEM = "roomInItem";

    public static final String LIVEROOM_MAN_PHOTOURL = "manPhotoUrl";

    public static final String LIVEROOM_MAN_NICKNAME = "manNickname";

    private static final int EVENT_SHOW_CLOSE_BUTTON = 1;       //显示可关闭按钮
    private static final int EVENT_INVITE_TIMEOUT = 2;          //主播邀请过期通知
    private static final int MSG_CHECK_PERMISSION_CALLBACK = 3;

    //RoomIn 请求reqID
    private int mRoomInRequestID = IMManager.IM_INVALID_REQID;

    /**
     * 过渡页类型
     */
    public enum CategoryType{
        Anchor_Invite_Enter_Room,
        Accept_Invite_Enter_Room,
        Schedule_Invite_Enter_Room
    }

    /**
     * 当前进程状态
     */
    private enum ProcessStatus{
        Default,
        Inviting,       //邀请中
        Accepting,      //应邀中
        Roomin          //进入直播间中
    }

    //view
    private ImageView btnClose;
    private CircleImageView civPhoto;
    private TextView tvAnchorName;
    private TextView tvDesc;
    //按钮
    private Button btnRetry;
    //进度条
    private ProgressBar pb_waiting;

    //Manager
    private IMManager mIMManager;
    private CameraMicroPhoneCheckManager mCameraMicroPhoneCheckManager;

    //data
    private CategoryType mCategoryType;       //用于指定是什么类型过渡页
    private String mUserId = "";
    private String mUserName = "";
    private String mUserPhotoUrl = "";
    private String mInvitationId = "";
    private String mRoomId = "";

    /**
     * 主播邀请用户进入直播间
     * @param context
     * @param userId
     * @param userName
     * @param userPhotoUrl
     * @return
     */
    public static Intent getInviteIntent(Context context, String userId, String userName, String userPhotoUrl){
        Intent intent = new Intent(context, LiveRoomTransitionActivity.class);
        intent.putExtra(TRANSITION_CATOGERY_TYPE, CategoryType.Anchor_Invite_Enter_Room.ordinal());
        intent.putExtra(TRANSITION_USER_ID, userId);
        intent.putExtra(TRANSITION_USER_NAME, userName);
        intent.putExtra(TRANSITION_USER_PHOTOURL, userPhotoUrl);
        return intent;
    }

    /**
     * 主播应邀进入直播间
     * @param context
     * @param userId
     * @param userName
     * @param userPhotoUrl
     * @param invitationId
     * @return
     */
    public static Intent getAcceptInviteIntent(Context context, String userId, String userName, String userPhotoUrl, String invitationId){
        Intent intent = new Intent(context, LiveRoomTransitionActivity.class);
        intent.putExtra(TRANSITION_CATOGERY_TYPE, CategoryType.Accept_Invite_Enter_Room.ordinal());
        intent.putExtra(TRANSITION_USER_ID, userId);
        intent.putExtra(TRANSITION_USER_NAME, userName);
        intent.putExtra(TRANSITION_USER_PHOTOURL, userPhotoUrl);
        intent.putExtra(TRANSITION_INVITATION_ID, invitationId);
        return intent;
    }

    /**
     * 预约到期进入直播间
     * @param context
     * @param userId
     * @param userName
     * @param userPhotoUrl
     * @param roomId
     * @return
     */
    public static Intent getEnterRoomIntent(Context context, String userId, String userName, String userPhotoUrl, String roomId){
        Intent intent = new Intent(context, LiveRoomTransitionActivity.class);
        intent.putExtra(TRANSITION_CATOGERY_TYPE, CategoryType.Schedule_Invite_Enter_Room.ordinal());
        intent.putExtra(TRANSITION_USER_ID, userId);
        intent.putExtra(TRANSITION_USER_NAME, userName);
        intent.putExtra(TRANSITION_USER_PHOTOURL, userPhotoUrl);
        intent.putExtra(TRANSITION_ROOMID, roomId);
        return intent;
    }

    @Override
    protected void onCreate(Bundle arg0) {
        super.onCreate(arg0);
        TAG = LiveRoomTransitionActivity.class.getSimpleName();
        setCustomContentView(R.layout.activity_liveroom_transition);

        mIMManager = IMManager.getInstance();
        mCameraMicroPhoneCheckManager = new CameraMicroPhoneCheckManager();
        mCameraMicroPhoneCheckManager.setOnCameraAndRecordAudioCheckListener(this);

        registerListener();

        //注册服务冲突广播接收器
        initServiceConflicReceiver();

        initViews();
        initData();
    }

    @Override
    protected void onResume() {
        super.onResume();
        if(mCameraMicroPhoneCheckManager.getCheckPermissionStatus() == CameraMicroPhoneCheckManager.CheckPermissionStatus.Default){
            checkPermission();
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
        btnRetry = (Button) findViewById(R.id.btnRetry);

        //进度
        pb_waiting = (ProgressBar) findViewById(R.id.pb_waiting);

        btnClose.setOnClickListener(this);
        btnRetry.setOnClickListener(this);
    }
    public void initData(){
        Bundle bundle = getIntent().getExtras();
        if(bundle != null){
            if(bundle.containsKey(TRANSITION_CATOGERY_TYPE)){
                mCategoryType = CategoryType.values()[bundle.getInt(TRANSITION_CATOGERY_TYPE)];
            }
            if(bundle.containsKey(TRANSITION_USER_ID)){
                mUserId = bundle.getString(TRANSITION_USER_ID);
            }
            if(bundle.containsKey(TRANSITION_USER_NAME)){
                mUserName = bundle.getString(TRANSITION_USER_NAME);
            }
            if(bundle.containsKey(TRANSITION_USER_PHOTOURL)){
                mUserPhotoUrl = bundle.getString(TRANSITION_USER_PHOTOURL);
            }
            if(bundle.containsKey(TRANSITION_ROOMID)){
                mRoomId = bundle.getString(TRANSITION_ROOMID);
            }

            if(bundle.containsKey(TRANSITION_INVITATION_ID)){
                mInvitationId = bundle.getString(TRANSITION_INVITATION_ID);
            }
        }

        if(!TextUtils.isEmpty(mUserPhotoUrl)) {
            Picasso.with(getApplicationContext()).load(mUserPhotoUrl)
                    .placeholder(R.drawable.ic_default_photo_man)
                    .error(R.drawable.ic_default_photo_man)
                    .memoryPolicy(MemoryPolicy.NO_CACHE)
                    .into(civPhoto);
        }

        tvAnchorName.setText(mUserName);

        if(mCategoryType != null) {
            //启动本地超时逻辑
            sendEmptyUiMessageDelayed(EVENT_SHOW_CLOSE_BUTTON, ROOM_CLOSE_BUTTON_DELAY_TIMESTAMP);
            //先进行权限检测，通过后才可以走进入流程
            checkPermission();
//            start();
        }else{
            finish();
        }
    }


    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        switch (msg.what){
            case EVENT_SHOW_CLOSE_BUTTON:{
                btnClose.setVisibility(View.VISIBLE);
            }break;
            case EVENT_INVITE_TIMEOUT:{
                String errMsg = getResources().getString(R.string.liveroom_transition_invite_overtime_tips);
                onProcessEventUpdate(ProcessEventType.InviteTimeOut, errMsg);
            }break;
            case MSG_CHECK_PERMISSION_CALLBACK:{
                if(msg.arg1 == 1){
                    //检测成功
                    start();
                }else{
                    String message = (String)msg.obj;
                    showPermissionNeedDialog(message);
                }
            }break;
            default:
                break;
        }
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);
        switch (v.getId()){
            case R.id.btnClose:{
                //点击关闭退出处理
                exitLiveroomTransition();
            }break;
            case R.id.btnRetry:{
                //点击retry操作（应邀操作或进入直播间操作）
                pb_waiting.setVisibility(View.VISIBLE);
                tvDesc.setVisibility(View.GONE);

                btnRetry.setVisibility(View.GONE);
                if(!TextUtils.isEmpty(mRoomId)){
                    //重新进入直播间
                    enterRoom();
                }else{
                    if(mCategoryType == CategoryType.Accept_Invite_Enter_Room){
                        acceptViewerInvite();
                    }
                }
            }break;
        }
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

    /**
     * 注册服务冲突接收器
     */
    private void initServiceConflicReceiver(){
        //注册广播
        IntentFilter filter = new IntentFilter();
        filter.addAction(CommonConstant.ACTION_NOTIFICATION_SERVICE_CONFLICT_ACTION);
        registerReceiver(mServiceConfictReceiver, filter);
    }

    /**
     * 注销服务冲突接收器
     */
    private void unRegisterConfictReceiver(){
        //反注册被踢下线广播接收器
        if(mServiceConfictReceiver != null){
            unregisterReceiver(mServiceConfictReceiver);
            mServiceConfictReceiver = null;
        }
    }

    /**
     * 广播接收器
     */
    private BroadcastReceiver mServiceConfictReceiver = new BroadcastReceiver(){

        @Override
        public void onReceive(Context context, Intent intent) {
            // TODO Auto-generated method stub
            if(intent.getAction().equals(CommonConstant.ACTION_NOTIFICATION_SERVICE_CONFLICT_ACTION)){
                String jumpUrl = "";
                Bundle bundle = intent.getExtras();
                if(bundle != null && bundle.containsKey(CommonConstant.ACTION_NOTIFICATION_SERVICE_CONFLICT_JUMPURL)){
                    jumpUrl = bundle.getString(CommonConstant.ACTION_NOTIFICATION_SERVICE_CONFLICT_JUMPURL);
                }

                //收到服务通知确认通知，退出直播间，跳转到主页
                //注销冲突接收器
                unRegisterConfictReceiver();
                if(!TextUtils.isEmpty(mRoomId)){
                    mIMManager.roomOutAndClearFlag(mRoomId);
                }
                MainFragmentActivity.launchActivityWIthUrl(mContext, jumpUrl);
                finish();
            }
        }

    };

    /**
     * 启动邀请或进入直播间逻辑
     */
    private void start() {
        switch (mCategoryType) {
            case Anchor_Invite_Enter_Room: {
                //主播发起立即私密邀请
                startInvite();
            }
            break;
            case Accept_Invite_Enter_Room: {
                //主播发起立即私密邀请，用户应邀
                acceptViewerInvite();
            }
            break;
            case Schedule_Invite_Enter_Room: {
                //预约邀请直接到时间通知，直接进入直播间
                enterRoom();
            }
            break;
        }
    }

    /**
     * 获取当前所对应的处理状态
     * @return
     */
    private ProcessStatus getProcessStatus(){
        ProcessStatus status = ProcessStatus.Default;
        if(!TextUtils.isEmpty(mRoomId)){
            status = ProcessStatus.Roomin;
        }else {
            if(!TextUtils.isEmpty(mInvitationId)){
                if(mCategoryType == CategoryType.Anchor_Invite_Enter_Room){
                    status = ProcessStatus.Inviting;
                }else if(mCategoryType == CategoryType.Accept_Invite_Enter_Room){
                    status = ProcessStatus.Accepting;
                }
            }
        }
        return status;
    }

    /**
     * 主动退出逻辑
     */
    private void exitLiveroomTransition(){
        ProcessStatus status = getProcessStatus();
        Log.d(TAG,"exitLiveroomTransition-status:"+status+" mRoomId:"+mRoomId);
        if(status == ProcessStatus.Inviting){
            onProcessEventUpdate(ProcessEventType.NormalEvent, getResources().getString(R.string.liveroom_transition_cancel_invite_tips));
            mIMManager.cancelImmediatePrivateInvite(mInvitationId, new OnRequestCallback() {
                @Override
                public void onRequest(final boolean isSuccess, final int errCode, String errMsg) {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            HttpLccErrType errType = IntToEnumUtils.intToHttpErrorType(errCode);
                            if(!isSuccess && (errType == HttpLccErrType.HTTP_LCC_ERR_CANCEL_FAIL_INVITE)){
                                //等待接收应邀通知
                                showToast(getResources().getString(R.string.liveroom_transition_cancel_invite_failed_tips));
//                                onProcessEventUpdate(ProcessEventType.NormalEvent, getResources().getString(R.string.liveroom_transition_cancel_invite_failed_tips));
                            }else{
                                //注销冲突接收器
                                unRegisterConfictReceiver();
                                finish();
                            }
                        }
                    });
                }
            });
        }else{
            if(!TextUtils.isEmpty(mRoomId)){
                mIMManager.roomOutAndClearFlag(mRoomId);
            }
            //注销冲突接收器
            unRegisterConfictReceiver();
            finish();
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        Log.d(TAG,"onDestroy");
        //关闭退出处理(TODO:这里的处理，PC端还是显示主播进入私密直播间的状态，需要再测试)
        exitLiveroomTransition();
        unRegisterListener();
        //注销冲突广播接收器
        unRegisterConfictReceiver();

        //删除定时消息
        removeUiMessages(EVENT_SHOW_CLOSE_BUTTON);
        removeUiMessages(EVENT_INVITE_TIMEOUT);
        removeUiMessages(MSG_CHECK_PERMISSION_CALLBACK);
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if ( keyCode == KeyEvent.KEYCODE_BACK && event.getAction() == KeyEvent.ACTION_DOWN ){
            //拦截返回键
            if(btnClose.getVisibility() == View.VISIBLE){
                exitLiveroomTransition();
            }
            return false;
        }
        return super.onKeyDown(keyCode, event);
    }

    /*************************************** 主播端邀请逻辑 ********************************************/
    /**
     * 主播发起邀请接口
     */
    private void startInvite(){
        onProcessEventUpdate(ProcessEventType.NormalEvent, getResources().getString(R.string.liveroom_transition_invite_start_tips));
        mIMManager.sendImmediatePrivateInvite(mUserId);
    }

    /**
     * 邀请命令回调（处理是否成功）
     * @param reqId
     * @param success
     * @param errType
     * @param errMsg
     * @param invitationId
     * @param timeout
     * @param roomId
     */
    @Override
    public void OnSendImmediatePrivateInvite(int reqId, final boolean success, IMClientListener.LCC_ERR_TYPE errType, final String errMsg, final String invitationId, final int timeout, final String roomId) {
        //发送立即私密邀请回调
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if(success){
                    //邀请发送成功
                    mInvitationId = invitationId;
                    if(!TextUtils.isEmpty(roomId)){
                        //转到进入直播间逻辑
                        mRoomId = roomId;
                        enterRoom();
                    }else{
                        //邀请中启动超时控制
                        sendEmptyUiMessageDelayed(EVENT_INVITE_TIMEOUT, timeout * 1000);
                    }
                }else{
                    //邀请发送失败
                    onProcessEventUpdate(ProcessEventType.NormalInviteError, errMsg);
                }
            }
        });
    }

    @Override
    public void OnRecvInviteReply(final String inviteId, final IMClientListener.InviteReplyType replyType, final String roomId, LiveRoomType roomType, String anchorId, String nickName, String avatarImg) {
        //收到用户针对主播请求的响应
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if(!TextUtils.isEmpty(mInvitationId)
                        && mInvitationId.equals(inviteId)){
                    //邀请返回成功，清除本地超时倒计时
                    removeUiMessages(EVENT_INVITE_TIMEOUT);
                    if(replyType == IMClientListener.InviteReplyType.Accepted){
                        //接收邀请
                        mRoomId = roomId;
                        enterRoom();
                    }else{
                        //拒绝邀请
                        onProcessEventUpdate(ProcessEventType.InviteRejected, getResources().getString(R.string.liveroom_transition_invite_define_tips));
                    }
                }
            }
        });
    }

    /***************************************  主播应邀逻辑   ******************************************/
    /**
     * 应邀
     */
    private void acceptViewerInvite(){
//        onProcessEventUpdate(ProcessEventType.NormalEvent, getResources().getString(R.string.liveroom_transition_accepting_invite_tips));
        LiveRequestOperator.getInstance().AcceptInstanceInvite(mInvitationId, new OnAcceptInstanceInviteCallback() {
            @Override
            public void onAcceptInstanceInvite(final boolean isSuccess, final int errCode, final String errMsg, final String roomId, int roomType) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if(isSuccess){
                            mRoomId = roomId;
                            enterRoom();
                        }else{
                            HttpLccErrType errType = IntToEnumUtils.intToHttpErrorType(errCode);
                            if(errType == HttpLccErrType.HTTP_LCC_ERR_CONNECTFAIL){
                                //普通网络错误
                                onProcessEventUpdate(ProcessEventType.NormalNetworkException, errMsg);
                            }else{
                                onProcessEventUpdate(ProcessEventType.AcceptCommonError, errMsg);
                            }
                        }
                    }
                });
            }
        });
    }

    /**************************************  进入直播间逻辑   ******************************************/
    /**
     * 执行进入直播间逻辑
     */
    private void enterRoom(){
//        onProcessEventUpdate(ProcessEventType.NormalEvent, getResources().getString(R.string.liveroom_transition_enter_room_tips));
        mRoomInRequestID = mIMManager.RoomIn(mRoomId);
    }

    /**
     * 进入直播间回调
     * @param reqId
     * @param success
     * @param errType
     * @param errMsg
     * @param roomInfo
     */
    @Override
    public void OnRoomIn(int reqId, final boolean success, final IMClientListener.LCC_ERR_TYPE errType,
                         final String errMsg, final IMRoomInItem roomInfo) {
        Log.d(TAG,"OnRoomIn-success:"+success+" errType:"+errType+" errMsg:"+errMsg+" roomInfo:"+roomInfo);
        //进入私密直播间成功返回
        if(mRoomInRequestID == reqId) {
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    //后台或者可见时才跳转，解决由于clear top导致push点击，后台会进入直播间
                    if (isActivityVisible() || SystemUtils.isBackground(mContext)) {
                        //此处判断错误，成功且受到非当前直播间错误处理异常
                        if (success ) {
                            //进入成功直接调用进入直播间
                            Intent intent = new Intent(LiveRoomTransitionActivity.this, PrivateLiveRoomActivity.class);
                            intent.putExtra(LIVEROOM_ROOMINFO_ITEM, roomInfo);
                            intent.putExtra(LIVEROOM_MAN_PHOTOURL, mUserPhotoUrl);
                            intent.putExtra(TRANSITION_USER_ID, mUserId);
                            intent.putExtra(LIVEROOM_MAN_NICKNAME, mUserName);
                            startActivity(intent);
                            mRoomId = "";
                            //注销事件监听器
                            unRegisterConfictReceiver();
                            finish();
                        } else {
                            if (errType == IMClientListener.LCC_ERR_TYPE.LCC_ERR_CONNECTFAIL) {
                                onProcessEventUpdate(ProcessEventType.EnterRoomNetworkException, errMsg);
                            } else {
                                onProcessEventUpdate(ProcessEventType.EnterRoomCommonError, errMsg);
                            }
                        }
                    }
                }
            });
        }
    }

    /************************************* 业务过程界面提示处理 *****************************************/
    /**
     * 过渡页需处理事件类型
     */
    private enum ProcessEventType{
        NormalEvent,                //普通事件，更新文字即可
        NormalInviteError,          //邀请出错
        InviteRejected,             //邀请已拒绝
        InviteTimeOut,              //邀请已超时
        NormalNetworkException,     //普通网络错误异常
        AcceptCommonError,          //接受邀请处理
        EnterRoomNetworkException,  //进入直播间网络错误
        EnterRoomCommonError        //进入直播间普通错误
    }

    /***
     * 邀请开播/应邀开播/预约到期开播过程事件处理
     * @param eventType
     * @param eventMsg
     */
    private void onProcessEventUpdate(ProcessEventType eventType, String eventMsg){

        pb_waiting.setVisibility(View.GONE);
        tvDesc.setVisibility(View.VISIBLE);

        switch (eventType){
            case NormalEvent:{
                tvDesc.setText(eventMsg);
            }break;

            case InviteRejected:
            case InviteTimeOut:
            case NormalInviteError:{
                //还原状态
                mInvitationId = "";
                btnClose.setVisibility(View.VISIBLE);
                tvDesc.setText(eventMsg);
            }break;
            case NormalNetworkException:{
                btnRetry.setVisibility(View.VISIBLE);
                btnClose.setVisibility(View.VISIBLE);
                tvDesc.setText(eventMsg);
            }break;
            case AcceptCommonError:{
                btnClose.setVisibility(View.VISIBLE);
                tvDesc.setText(eventMsg);
            }break;
            case EnterRoomNetworkException:{
                btnClose.setVisibility(View.VISIBLE);
                btnRetry.setVisibility(View.VISIBLE);
                tvDesc.setText(eventMsg);
            }break;
            case EnterRoomCommonError:{
                btnClose.setVisibility(View.VISIBLE);
                tvDesc.setText(eventMsg);
            }break;
        }
    }

    /***************************************** 断线重连 **********************************************/
    @Override
    public void OnLogin(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
        //断线重连成功，邀请状态时需要获取已发邀请信息
        if(errType == IMClientListener.LCC_ERR_TYPE.LCC_ERR_SUCCESS){
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    if(getProcessStatus() == ProcessStatus.Inviting){
                        refreshInviting();
                    }
                }
            });
        }
    }

    /**
     * 刷新当前邀请状态
     */
    private void refreshInviting(){
        mIMManager.GetInviteInfo(mInvitationId);
    }

    @Override
    public void OnGetInviteInfo(int reqId, final boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, final IMInviteListItem inviteItem) {
        //获取已发送指定邀请的具体信息
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if(success && inviteItem != null
                        && (!TextUtils.isEmpty(inviteItem.inviteId))
                        && (inviteItem.inviteId.equals(mInvitationId))){
                    removeUiMessages(EVENT_INVITE_TIMEOUT);
                    if(!TextUtils.isEmpty(inviteItem.roomId)){
                        mRoomId = inviteItem.roomId;
                        enterRoom();
                    }else{
                        //根据邀请状态处理
                        if(inviteItem.inviteType == IMInviteListItem.IMInviteReplyType.Pending){
                            //继续等待
                            sendEmptyUiMessageDelayed(EVENT_INVITE_TIMEOUT, inviteItem.validTime * 1000);
                        }else if (inviteItem.inviteType == IMInviteListItem.IMInviteReplyType.Rejected){
                            //已拒绝
                            onProcessEventUpdate(ProcessEventType.InviteRejected, getResources().getString(R.string.liveroom_transition_invite_define_tips));
                        }else if (inviteItem.inviteType == IMInviteListItem.IMInviteReplyType.OverTime){
                            //已超时
                            onProcessEventUpdate(ProcessEventType.InviteTimeOut, getResources().getString(R.string.liveroom_transition_invite_overtime_tips));
                        }else{
                            //当超时处理
                            onProcessEventUpdate(ProcessEventType.InviteTimeOut, getResources().getString(R.string.liveroom_transition_invite_overtime_tips));
                        }
                    }
                }
            }
        });
    }

    /*************************************** Listener回调 ********************************************/


    @Override
    public void OnLogout(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnKickOff(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnRecvAnchoeInviteNotify(String userId, String nickname, String photoUrl, String invitationId) {

    }

    @Override
    public void OnRecvBookingNotice(String roomId, String userId, String nickName, String avatarImg, int leftSeconds) {

    }

    @Override
    public void OnRoomOut(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    /****************************** Camera和RecordAudio权限检测  ************************************/

    /**
     * 启动权限检测
     */
    private void checkPermission(){
        mCameraMicroPhoneCheckManager.checkStart();
    }

    /**
     * 显示权限设置提示dialog
     * @param messgae
     */
    public void showPermissionNeedDialog(String messgae){
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setMessage(messgae);
        builder.setCancelable(false);
        builder.setNegativeButton(R.string.permission_check_dialog_button_cancel, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                finish();
            }
        });
        builder.setPositiveButton(R.string.permission_check_dialog_button_setttings, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                Intent intent = new Intent(Settings.ACTION_APPLICATION_SETTINGS);
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent);
            }
        });

        AlertDialog dialog = builder.create();
        dialog.setCanceledOnTouchOutside(false);
        if(isActivityVisible()) {
            dialog.show();
        }
    }

    @Override
    public void onCheckPermissionSuccess() {
        Message msg = Message.obtain();
        msg.what = MSG_CHECK_PERMISSION_CALLBACK;
        msg.arg1 = 1;
        sendUiMessage(msg);
    }

    @Override
    public void onCheckCameraPermissionDeny() {
        String errMsg = getResources().getString(R.string.permission_check_exception_camera);
        Message msg = Message.obtain();
        msg.what = MSG_CHECK_PERMISSION_CALLBACK;
        msg.arg1 = 0;
        msg.obj = errMsg;
        sendUiMessage(msg);
    }

    @Override
    public void onCheckRecordAudioPermissionDeny() {
        String errMsg = getResources().getString(R.string.permission_check_exception_record_audio);
        Message msg = Message.obtain();
        msg.what = MSG_CHECK_PERMISSION_CALLBACK;
        msg.arg1 = 0;
        msg.obj = errMsg;
        sendUiMessage(msg);
    }
}
