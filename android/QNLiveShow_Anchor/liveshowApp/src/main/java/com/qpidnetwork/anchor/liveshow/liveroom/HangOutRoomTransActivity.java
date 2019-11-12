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
import com.qpidnetwork.anchor.httprequest.OnDealInvitationHangoutCallback;
import com.qpidnetwork.anchor.httprequest.OnGetHangoutKnockStatusCallback;
import com.qpidnetwork.anchor.httprequest.OnRequestCallback;
import com.qpidnetwork.anchor.httprequest.OnSendKnockRequestCallback;
import com.qpidnetwork.anchor.httprequest.item.AnchorKnockType;
import com.qpidnetwork.anchor.httprequest.item.HangoutInviteReplyType;
import com.qpidnetwork.anchor.httprequest.item.HttpLccErrType;
import com.qpidnetwork.anchor.httprequest.item.IntToEnumUtils;
import com.qpidnetwork.anchor.im.IMHangOutRoomEventListener;
import com.qpidnetwork.anchor.im.IMManager;
import com.qpidnetwork.anchor.im.IMOtherEventListener;
import com.qpidnetwork.anchor.im.listener.IMClientListener;
import com.qpidnetwork.anchor.im.listener.IMDealInviteItem;
import com.qpidnetwork.anchor.im.listener.IMHangoutRecommendItem;
import com.qpidnetwork.anchor.im.listener.IMHangoutRoomItem;
import com.qpidnetwork.anchor.im.listener.IMKnockRequestItem;
import com.qpidnetwork.anchor.im.listener.IMMessageItem;
import com.qpidnetwork.anchor.im.listener.IMOtherInviteItem;
import com.qpidnetwork.anchor.im.listener.IMRecvEnterRoomItem;
import com.qpidnetwork.anchor.im.listener.IMRecvHangoutGiftItem;
import com.qpidnetwork.anchor.im.listener.IMRecvLeaveRoomItem;
import com.qpidnetwork.anchor.liveshow.home.MainFragmentActivity;
import com.qpidnetwork.anchor.liveshow.manager.CameraMicroPhoneCheckManager;
import com.qpidnetwork.anchor.utils.Log;
import com.qpidnetwork.anchor.utils.SystemUtils;
import com.squareup.picasso.MemoryPolicy;
import com.squareup.picasso.Picasso;

import static com.qpidnetwork.anchor.liveshow.liveroom.BaseImplLiveRoomActivity.HANGOUT_ROOMINFO_ITEM;

/**
 * Description: HangOut直播间过渡页面
 * <p>
 * Created by Harry on 2018/5/2.
 */
public class HangOutRoomTransActivity extends BaseActionBarFragmentActivity
        implements CameraMicroPhoneCheckManager.OnCameraAndRecordAudioCheckListener,
        IMHangOutRoomEventListener,IMOtherEventListener {

    private CategoryType mCategoryType;       //用于指定是什么类型过渡页
    private IMKnockRequestItem.IMAnchorKnockType imAnchorKnockType = IMKnockRequestItem.IMAnchorKnockType.Unknown;

    /**
     * 过渡页类型
     */
    public enum CategoryType{
        Accept_Invite_HangOut_Room,
        Enter_HangOut_Room,
        Knock_HangOut_Room
    }

    public enum CheckPermissionStatus{
        Default,
        Checking,
        CheckSuccess
    }

    private static final int ROOM_CLOSE_BUTTON_DELAY_TIMESTAMP = 10 * 1000;      //进入界面1o秒后显示可关闭按钮
    private static final int EVENT_SHOW_CLOSE_BUTTON = 1;       //显示可关闭按钮
    private static final int MSG_CHECK_PERMISSION_CALLBACK = 2;
    private static final int EVENT_ENTER_HANGOUT_ROOM_TIMECOUNT = 3;
    private static final int EVENT_KNOCK_HANGOUT_ROOM_TIMECOUNT = 4;

    private static final String TRANSITION_USER_ID = "anchorId";
    private static final String TRANSITION_USER_NAME = "anchorName";
    private static final String TRANSITION_USER_PHOTOURL = "anchorPhotoUrl";
    private static final String TRANSITION_ROOMID = "roomId";
    private static final String TRANSITION_CATOGERY_TYPE = "categoryType";
    private static final String TRANSITION_INVITATION_ID = "invitationId";

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

    //data
    private String mUserId = "";
    private String mUserName = "";
    private String mUserPhotoUrl = "";
    private String mInvitationId = "";
    private String mRoomId = "";
    private int mEnterRoomReqId = -100;
    private String mKnockId="";
    private int anchorKnockExpires = 0;

    private boolean hasActivityDestory = false;

    //是否正在check permission中
    private CheckPermissionStatus mCheckPermissionStatus = CheckPermissionStatus.Default;

    @Override
    protected void onCreate(Bundle arg0) {
        super.onCreate(arg0);
        TAG = HangOutRoomTransActivity.class.getSimpleName();
        setCustomContentView(R.layout.activity_liveroom_transition);
        mIMManager = IMManager.getInstance();
        registerListener();
        //注册服务冲突广播接收器
        initServiceConflicReceiver();
        initViews();
        initData();
        Log.d(TAG,"onCreate-mInvitationId:"+mInvitationId);
    }

    @Override
    protected void onResume() {
        super.onResume();
        Log.d(TAG,"onResume-mInvitationId:"+mInvitationId);
        if(mCheckPermissionStatus == CheckPermissionStatus.Default){
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
            if(bundle.containsKey(TRANSITION_CATOGERY_TYPE)){
                mCategoryType = CategoryType.values()[bundle.getInt(TRANSITION_CATOGERY_TYPE)];
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
        }else{
            finish();
        }
    }

    /**
     * 启动邀请或进入直播间逻辑
     */
    private void start() {
        Log.d(TAG,"start-mCategoryType:"+mCategoryType+" mInvitationId:"+mInvitationId);
        switch (mCategoryType) {
            case Knock_HangOut_Room:{
                knockHangOutRoom();
            }
            break;
            case Enter_HangOut_Room: {
                //进入hangout直播间
                enterHangOutRoom();
            }
            break;
            case Accept_Invite_HangOut_Room: {
                //主播接受hangout直播间邀请
                acceptHangOutInvite();
            }
            break;
        }
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        Log.d(TAG,"handleUiMessage-what:"+msg.what+" mInvitationId:"+mInvitationId);
        switch (msg.what){
            case EVENT_KNOCK_HANGOUT_ROOM_TIMECOUNT:
                //敲门请求超时
                mKnockId = null;
                imAnchorKnockType = IMKnockRequestItem.IMAnchorKnockType.OutTime;
                onProcessEventUpdate(ProcessEventType.KnockHangOutRoomCommonError,getResources().getString(R.string.hangout_anchor_knock_failed));
                break;
            case EVENT_ENTER_HANGOUT_ROOM_TIMECOUNT:
                enterHangOutRoom();
                break;
            case EVENT_SHOW_CLOSE_BUTTON:{
                btnClose.setVisibility(View.VISIBLE);
            }break;

            case MSG_CHECK_PERMISSION_CALLBACK:{
                if(msg.arg1 == 1){
                    //检测成功
                    mCheckPermissionStatus = CheckPermissionStatus.CheckSuccess;
                    start();
                }else{
                    mCheckPermissionStatus = CheckPermissionStatus.Default;
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
                closeHangOutOpera();
            }break;
            case R.id.btnRetry:{
                //点击retry操作（应邀操作或进入直播间操作）
                pb_waiting.setVisibility(View.VISIBLE);
                tvDesc.setVisibility(View.GONE);

                btnRetry.setVisibility(View.GONE);
                if(!TextUtils.isEmpty(mRoomId)){
                    if(mCategoryType == CategoryType.Knock_HangOut_Room){
                        //请求中
                        if(imAnchorKnockType == IMKnockRequestItem.IMAnchorKnockType.Unknown){
                            knockHangOutRoom();
                        }else if(imAnchorKnockType == IMKnockRequestItem.IMAnchorKnockType.Agree){
                            enterHangOutRoom();
                        }
                    }else if(mCategoryType == CategoryType.Enter_HangOut_Room){
                        //重新进入直播间
                        enterHangOutRoom();
                    }
                }else if(mCategoryType == CategoryType.Accept_Invite_HangOut_Room && !TextUtils.isEmpty(mInvitationId)){
                    acceptHangOutInvite();
                }
            }break;
        }
    }

    private void closeHangOutOpera() {
        Log.d(TAG,"closeHangOutOpera-mInvitationId:"+mInvitationId);
        if(mCategoryType == CategoryType.Knock_HangOut_Room){
            if(imAnchorKnockType == IMKnockRequestItem.IMAnchorKnockType.Unknown){
                //请求中状态 取消请求 并退出
                cancelKnockHangOutRoomRequest();
            }else if(imAnchorKnockType == IMKnockRequestItem.IMAnchorKnockType.Agree){
                //点击关闭退出处理
                exitHangOutTransition();
            }else{
                //Reject-拒绝 OutTime-邀请超时 Cancel-主播取消邀请
                finish();
            }
        }else{
            //点击关闭退出处理
            exitHangOutTransition();
        }
    }

    /**
     * 接受hangout邀请
     */
    private void acceptHangOutInvite(){
        Log.d(TAG,"acceptHangOutInvite-mInvitationId:"+mInvitationId);
        LiveRequestOperator.getInstance().DealInvitationHangout(mInvitationId, HangoutInviteReplyType.AGREE, new OnDealInvitationHangoutCallback() {

            @Override
            public void onDealInvitationHangout(final boolean isSuccess, final int errCode, final String errMsg, final String roomId) {
                Log.d(TAG,"acceptHangOutInvite-onDealInvitationHangout isSuccess:"+isSuccess
                        +" errCode:"+errCode+" errMsg:"+errMsg+" roomId:"+roomId
                        +" mInvitationId:"+mInvitationId+" hasActivityDestory:"+hasActivityDestory);
                if(hasActivityDestory){
                    return;
                }
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if(isSuccess){
                            mRoomId = roomId;
                            enterHangOutRoom();
                        }else{
                            Log.d(TAG,"acceptHangOutInvite-onDealInvitationHangout errCode:"+errCode+" mInvitationId:"+mInvitationId);
                            HttpLccErrType errType = IntToEnumUtils.intToHttpErrorType(errCode);
                            if(errType == HttpLccErrType.HTTP_LCC_ERR_CONNECTFAIL){
                                //普通网络错误
                                onProcessEventUpdate(ProcessEventType.EnterRoomNetworkException, errMsg);
                            }else{
                                onProcessEventUpdate(ProcessEventType.AcceptCommonError, errMsg);
                            }
                        }
                    }
                });
            }
        });
    }

    /**
     * 过渡页需处理事件类型
     */
    private enum ProcessEventType{
        EnterRoomNetworkException,  //进入直播间网络错误
        AcceptCommonError,          //接受邀请处理
        EnterRoomCommonError,        //进入直播间普通错误
        KnockHangOutRoomCommonError, //敲门请求普通错误
        AnchorCancelKnockRequest,     //主播取消敲门请求
        AnchorKnockHangOutRoom,     //主播敲门请求进入
        AnchorEnterHangOutRoom     //主播进入多人互动直播间
    }

    /***
     * 邀请开播/应邀开播/预约到期开播过程事件处理
     * @param eventType
     * @param eventMsg
     */
    private void onProcessEventUpdate(ProcessEventType eventType, String eventMsg){
        Log.d(TAG,"onProcessEventUpdate-eventType:"+eventType+" eventMsg:"+eventMsg+" mInvitationId:"+mInvitationId);
        pb_waiting.setVisibility(View.GONE);
        tvDesc.setVisibility(View.VISIBLE);
        switch (eventType){
            case AnchorEnterHangOutRoom:{
                pb_waiting.setVisibility(View.VISIBLE);
                tvDesc.setVisibility(View.GONE);
            }break;
            case AnchorCancelKnockRequest:
            case AnchorKnockHangOutRoom:{
                pb_waiting.setVisibility(View.VISIBLE);
                tvDesc.setText(eventMsg);
            }break;
            case KnockHangOutRoomCommonError:
            case EnterRoomCommonError:
            case AcceptCommonError:{
                btnClose.setVisibility(View.VISIBLE);
                tvDesc.setText(eventMsg);
            }break;
            case EnterRoomNetworkException:{
                btnClose.setVisibility(View.VISIBLE);
                btnRetry.setVisibility(View.VISIBLE);
                tvDesc.setText(eventMsg);
            }break;
        }
    }

    /**
     * 绑定监听器
     */
    private void registerListener(){
        mIMManager.registerIMHangOutRoomEventListener(this);
        mIMManager.registerIMOtherEventListener(this);
    }

    /**
     * 解绑监听器
     */
    private void unRegisterListener(){
        Log.d(TAG,"unRegisterListener-mInvitationId:"+mInvitationId);
        mIMManager.unregisterIMHangOutRoomEventListener(this);
        mIMManager.unregisterIMOtherEventListener(this);
    }


    /**
     * 主播取消敲门
     */
    private void cancelKnockHangOutRoomRequest(){
        Log.d(TAG,"cancelKnockHangOutRoomRequest");
        if(!TextUtils.isEmpty(mKnockId)){
            //界面提示
            onProcessEventUpdate(ProcessEventType.AnchorCancelKnockRequest,
                    getResources().getString(R.string.hangout_anchor_cancel_knocking));
            LiveRequestOperator.getInstance().CancelHangoutKnock(mKnockId, new OnRequestCallback() {
                @Override
                public void onRequest(final boolean isSuccess, final int errCode, final String errMsg) {
                    mKnockId = null;
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            if(isSuccess){
                                imAnchorKnockType = IMKnockRequestItem.IMAnchorKnockType.Cancel;
                                finish();
                            }else{
                                if(IntToEnumUtils.intToHttpErrorType(errCode) == HttpLccErrType.HTTP_LCC_ERR_VIEWER_OPEN_KNOCK){
                                    removeUiMessages(EVENT_KNOCK_HANGOUT_ROOM_TIMECOUNT);
                                    imAnchorKnockType = IMKnockRequestItem.IMAnchorKnockType.Agree;
                                    if(!TextUtils.isEmpty(errMsg)){
                                        showToast(errMsg);
                                    }
                                    onProcessEventUpdate(ProcessEventType.AnchorKnockHangOutRoom,
                                            getResources().getString(R.string.hangout_anchor_knocking));
                                }else{
                                    //取消敲门失败
                                    finish();
                                }
                            }
                        }
                    });
                }
            });
        }else{
            finish();
        }
    }

    /**
     * 敲门
     */
    private void knockHangOutRoom(){
        Log.d(TAG,"knockHangOutRoom");
        if(!TextUtils.isEmpty(mRoomId)){
            //界面提示
            onProcessEventUpdate(ProcessEventType.AnchorEnterHangOutRoom, null);
            LiveRequestOperator.getInstance().SendKnockRequest(mRoomId, new OnSendKnockRequestCallback() {
                @Override
                public void onSendKnockRequest(final boolean isSuccess, final int errCode, final String errMsg,
                                               final String knockId, final int expire) {
                    Log.d(TAG,"knockHangOutRoom-onSendKnockRequest-isSuccess:"+isSuccess
                            +" errCode:"+errCode+" errMsg:"+errMsg+" knockId:"+knockId+" expire:"+expire);
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            if(isSuccess){
                                if(0 == expire){
                                    //为0则直接进入直播间
                                    enterHangOutRoom();
                                    return;
                                }
                                mKnockId = knockId;
                                anchorKnockExpires = expire;
                                //界面提示
                                onProcessEventUpdate(ProcessEventType.AnchorKnockHangOutRoom,
                                        getResources().getString(R.string.hangout_anchor_knocking));
                                sendEmptyUiMessageDelayed(EVENT_KNOCK_HANGOUT_ROOM_TIMECOUNT,anchorKnockExpires*1000l);
                            }else{
                                HttpLccErrType errType = IntToEnumUtils.intToHttpErrorType(errCode);
                                if(errType == HttpLccErrType.HTTP_LCC_ERR_CONNECTFAIL){
                                    //普通网络错误
                                    onProcessEventUpdate(ProcessEventType.EnterRoomNetworkException, errMsg);
                                }else{
                                    onProcessEventUpdate(ProcessEventType.KnockHangOutRoomCommonError, errMsg);
                                }
                            }
                        }
                    });
                }
            });
        }
    }

    @Override
    public void OnLogin(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
        Log.d(TAG,"OnLogin-errType:"+errType+" errMsg:"+errMsg);
        if(errType == IMClientListener.LCC_ERR_TYPE.LCC_ERR_SUCCESS
                && mCategoryType == CategoryType.Knock_HangOut_Room
                && imAnchorKnockType == IMKnockRequestItem.IMAnchorKnockType.Unknown
                && !TextUtils.isEmpty(mKnockId)) {
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    getHangOutRoomKnockStatus();
                }
            });
        }
    }

    /**
     * 获取敲门状态
     */
    private void getHangOutRoomKnockStatus(){
        Log.d(TAG,"getHangOutRoomKnockStatus");
        LiveRequestOperator.getInstance().GetHangoutKnockStatus(mKnockId, new OnGetHangoutKnockStatusCallback() {
            @Override
            public void onGetHangoutKnockStatus(final boolean isSuccess, int errCode, final String errMsg, final String roomId, final int status, final int expire) {
                Log.d(TAG,"onGetHangoutKnockStatus-isSuccess:"+isSuccess
                        +" errCode:"+errCode+" errMsg:"+errMsg+" roomId:"+roomId
                        +" status:"+status+" expire:"+expire);
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if(isSuccess){
                            AnchorKnockType anchorKnockType = IntToEnumUtils.intToAnchorKnockType(status);
                            if(anchorKnockType == AnchorKnockType.Unknown || anchorKnockType == AnchorKnockType.Pending){
                                if(0 == expire){
                                    //2018年6月8日 09:23:28 Samson:待确认且有效秒数为零按照超时逻辑处理
                                    imAnchorKnockType = IMKnockRequestItem.IMAnchorKnockType.OutTime;
                                    removeUiMessages(EVENT_KNOCK_HANGOUT_ROOM_TIMECOUNT);
                                    onProcessEventUpdate(ProcessEventType.KnockHangOutRoomCommonError,errMsg);
                                }else{
                                    //2018年6月8日 09:26:10 Samson:正常情况下服务器保证expire不为0
                                    imAnchorKnockType = IMKnockRequestItem.IMAnchorKnockType.Unknown;
                                    anchorKnockExpires = expire;
                                }
                            }else if(anchorKnockType == AnchorKnockType.Confirmed){
                                imAnchorKnockType = IMKnockRequestItem.IMAnchorKnockType.Agree;
                                removeUiMessages(EVENT_KNOCK_HANGOUT_ROOM_TIMECOUNT);
                                enterHangOutRoom();
                            }else if(anchorKnockType == AnchorKnockType.Missed){
                                imAnchorKnockType = IMKnockRequestItem.IMAnchorKnockType.OutTime;
                                removeUiMessages(EVENT_KNOCK_HANGOUT_ROOM_TIMECOUNT);
                                onProcessEventUpdate(ProcessEventType.KnockHangOutRoomCommonError,errMsg);
                            }else if(anchorKnockType == AnchorKnockType.Defined){
                                imAnchorKnockType = IMKnockRequestItem.IMAnchorKnockType.Reject;
                                removeUiMessages(EVENT_KNOCK_HANGOUT_ROOM_TIMECOUNT);
                                onProcessEventUpdate(ProcessEventType.KnockHangOutRoomCommonError,errMsg);
                            }
                        }else{
                            //断线重登陆 接口调用失败如何处理
                        }
                    }
                });
            }
        });
    }

    @Override
    public void OnRecvAnchorDealKnockRequestNotice(final IMKnockRequestItem item) {
        Log.d(TAG,"OnRecvAnchorDealKnockRequestNotice-item:"+item);
        if(TextUtils.isEmpty(mKnockId) || !mKnockId.equals(item.knockId)){
            return;
        }
        imAnchorKnockType = item.type;
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                //男士接受则直接进入直播间
                removeUiMessages(EVENT_KNOCK_HANGOUT_ROOM_TIMECOUNT);
                if(item.type == IMKnockRequestItem.IMAnchorKnockType.Agree){
                    enterHangOutRoom();
                }else if(item.type == IMKnockRequestItem.IMAnchorKnockType.OutTime
                        || item.type == IMKnockRequestItem.IMAnchorKnockType.Reject){
                    onProcessEventUpdate(ProcessEventType.KnockHangOutRoomCommonError,getResources().getString(R.string.hangout_anchor_knock_failed));
                }
            }
        });
    }

    /**
     * 执行进入直播间逻辑
     */
    private void enterHangOutRoom(){
        Log.d(TAG,"enterHangOutRoom-mInvitationId:"+mInvitationId+" mRoomId:"+mRoomId);
        onProcessEventUpdate(ProcessEventType.AnchorEnterHangOutRoom,null);
        if(!TextUtils.isEmpty(mRoomId)){
            mEnterRoomReqId = mIMManager.enterHangOutRoom(mRoomId);
        }
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
            if(intent.getAction().equals(CommonConstant.ACTION_NOTIFICATION_SERVICE_CONFLICT_ACTION)){
                String jumpUrl = "";
                Bundle bundle = intent.getExtras();
                if(bundle != null && bundle.containsKey(CommonConstant.ACTION_NOTIFICATION_SERVICE_CONFLICT_JUMPURL)){
                    jumpUrl = bundle.getString(CommonConstant.ACTION_NOTIFICATION_SERVICE_CONFLICT_JUMPURL);
                }
                Log.logD(TAG,"mServiceConfictReceiver-jumpUrl:"+jumpUrl);
                //收到服务通知确认通知，退出直播间，跳转到主页
                //注销冲突接收器
                unRegisterConfictReceiver();
                if(!TextUtils.isEmpty(mRoomId)){
                    mIMManager.outHangOutRoomAndClearFlag(mRoomId);
                }
                MainFragmentActivity.launchActivityWIthUrl(mContext, jumpUrl);
                finish();
            }
        }

    };

    /**
     * 主动退出逻辑
     */
    private void exitHangOutTransition(){
        Log.d(TAG,"exitHangOutTransition-mRoomId:"+mRoomId);
        if(!TextUtils.isEmpty(mRoomId)){
            mIMManager.outHangOutRoomAndClearFlag(mRoomId);
        }
        //注销冲突接收器
        unRegisterConfictReceiver();
        finish();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        hasActivityDestory = true;
        Log.d(TAG,"onDestroy-mInvitationId:"+mInvitationId+" hasActivityDestory:"+hasActivityDestory);
        closeHangOutOpera();
        unRegisterListener();
        //注销冲突广播接收器
        unRegisterConfictReceiver();
        //删除定时消息
        removeUiMessages(EVENT_SHOW_CLOSE_BUTTON);
        removeUiMessages(MSG_CHECK_PERMISSION_CALLBACK);
        removeUiMessages(EVENT_ENTER_HANGOUT_ROOM_TIMECOUNT);
        removeUiMessages(EVENT_KNOCK_HANGOUT_ROOM_TIMECOUNT);
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if ( keyCode == KeyEvent.KEYCODE_BACK && event.getAction() == KeyEvent.ACTION_DOWN ){
            //拦截返回键
            if(btnClose.getVisibility() == View.VISIBLE){
                closeHangOutOpera();
            }
            return false;
        }
        return super.onKeyDown(keyCode, event);
    }

    /**
     * 主播应邀进入HangOut直播间
     * @param context
     * @param userId
     * @param userName
     * @param userPhotoUrl
     * @param invitationId
     * @return
     */
    public static Intent getAcceptInviteIntent(Context context, String userId, String userName, String userPhotoUrl, String invitationId){
        Intent intent = new Intent(context, HangOutRoomTransActivity.class);
        intent.putExtra(TRANSITION_USER_ID, userId);
        intent.putExtra(TRANSITION_USER_NAME, userName);
        intent.putExtra(TRANSITION_USER_PHOTOURL, userPhotoUrl);
        intent.putExtra(TRANSITION_CATOGERY_TYPE, CategoryType.Accept_Invite_HangOut_Room.ordinal());
        intent.putExtra(TRANSITION_INVITATION_ID, invitationId);
        return intent;
    }

    /**
     * 敲门进入HangOut直播间
     * @param context
     * @param userId
     * @param userName
     * @param userPhotoUrl
     * @param roomId
     * @return
     */
    public static Intent getKnowHangOutRoomIntent(Context context, String userId, String userName, String userPhotoUrl, String roomId){
        Intent intent = new Intent(context, HangOutRoomTransActivity.class);
        intent.putExtra(TRANSITION_USER_ID, userId);
        intent.putExtra(TRANSITION_USER_NAME, userName);
        intent.putExtra(TRANSITION_USER_PHOTOURL, userPhotoUrl);
        intent.putExtra(TRANSITION_ROOMID, roomId);
        intent.putExtra(TRANSITION_CATOGERY_TYPE, CategoryType.Knock_HangOut_Room.ordinal());
        return intent;
    }

    /**
     * 切换进入HangOut直播间
     * @param context
     * @param userId
     * @param userName
     * @param userPhotoUrl
     * @param roomId
     * @return
     */
    public static Intent getEnterRoomIntent(Context context, String userId, String userName, String userPhotoUrl, String roomId){
        Intent intent = new Intent(context, HangOutRoomTransActivity.class);
        intent.putExtra(TRANSITION_USER_ID, userId);
        intent.putExtra(TRANSITION_USER_NAME, userName);
        intent.putExtra(TRANSITION_USER_PHOTOURL, userPhotoUrl);
        intent.putExtra(TRANSITION_ROOMID, roomId);
        intent.putExtra(TRANSITION_CATOGERY_TYPE, CategoryType.Enter_HangOut_Room.ordinal());
        return intent;
    }

    /****************************** Camera和RecordAudio权限检测  ************************************/

    /**
     * 启动权限检测
     */
    private void checkPermission(){
        mCheckPermissionStatus = CheckPermissionStatus.Checking;
        CameraMicroPhoneCheckManager manager = new CameraMicroPhoneCheckManager();
        manager.setOnCameraAndRecordAudioCheckListener(this);
        manager.checkStart();
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


    //------------------------------------------直播间事件监听回调---------------------------------

    @Override
    public void OnEnterHangoutRoom(int reqId, final boolean success, final IMClientListener.LCC_ERR_TYPE errType,
                                   final String errMsg, final IMHangoutRoomItem hangoutRoomItem, final int expire) {
        Log.d(TAG, "OnEnterHangoutRoom-reqId"+reqId+" success:"+success+" errType:"
                +errType+" errMsg:"+errMsg+" hangoutRoomItem:"+hangoutRoomItem+" expire:"+expire
                +" mInvitationId:"+mInvitationId+" mEnterRoomReqId:"+mEnterRoomReqId+" hasActivityDestory:"+hasActivityDestory);
        if(hasActivityDestory || mEnterRoomReqId!=reqId){
            return;
        }
        //进入私密直播间成功返回
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                //后台或者可见时才跳转，解决由于clear top导致push点击，后台会进入直播间
                if(isActivityVisible() || SystemUtils.isBackground(mContext)) {
                    if (success) {
                        if (expire > 0) {
                            sendEmptyUiMessageDelayed(EVENT_ENTER_HANGOUT_ROOM_TIMECOUNT, expire * 1000l);
                            return;
                        }
                        //进入成功直接调用进入直播间
                        Intent intent = new Intent(HangOutRoomTransActivity.this, HangOutLiveRoomActivity.class);
                        intent.putExtra(HANGOUT_ROOMINFO_ITEM, hangoutRoomItem);
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

    @Override
    public void OnLeaveHangoutRoom(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
        Log.d(TAG, "OnLeaveHangoutRoom-reqId"+reqId+" success:"+success+" errType:"+errType+" errMsg:"+errMsg);
    }

    @Override
    public void OnRecvAnchorRecommendHangoutNotice(IMHangoutRecommendItem item) {
        Log.d(TAG,"OnRecvAnchorRecommendHangoutNotice-item:"+item);
    }

    @Override
    public void OnRecvAnchorOtherInviteNotice(IMOtherInviteItem item) {
        Log.d(TAG,"OnRecvAnchorOtherInviteNotice-item:"+item);
    }

    @Override
    public void OnRecvAnchorDealInviteNotice(IMDealInviteItem item) {
        Log.d(TAG,"OnRecvAnchorDealInviteNotice-item:"+item);
    }

    @Override
    public void OnRecvAnchorEnterRoomNotice(IMRecvEnterRoomItem item) {
        Log.d(TAG,"OnRecvAnchorEnterRoomNotice-item:"+item);
    }

    @Override
    public void OnRecvAnchorLeaveRoomNotice(IMRecvLeaveRoomItem item) {
        Log.d(TAG,"OnRecvAnchorLeaveRoomNotice-item:"+item);
    }

    @Override
    public void OnRecvAnchorChangeVideoUrl(String roomId, boolean isAnchor, String userId, String[] playUrl) {
        Log.d(TAG,"OnRecvAnchorChangeVideoUrl-roomId:"+roomId+" isAnchor:"+isAnchor+" userId:"+userId);
    }

    @Override
    public void OnSendHangoutGift(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
        Log.d(TAG,"OnSendHangoutGift-reqId:"+reqId+" success:"+success+" errType:"+errType+" errMsg:"+errMsg);
    }

    @Override
    public void OnRecvAnchorGiftNotice(IMRecvHangoutGiftItem item) {
        Log.d(TAG,"OnRecvAnchorGiftNotice-item:"+item);
    }

    @Override
    public void OnRecvHangoutInteractiveVideoNotice(String roomId, String userId, String nickname, String avatarImg, IMClientListener.IMVideoInteractiveOperateType operateType, String[] pushUrls) {

    }

    @Override
    public void OnSendHangoutMsg(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnRecvHangoutMsg(IMMessageItem imMessageItem) {

    }

    @Override
    public void OnRecvAnchorCountDownEnterRoomNotice(String roomId, String anchorId, int leftSecond) {

    }

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
}
