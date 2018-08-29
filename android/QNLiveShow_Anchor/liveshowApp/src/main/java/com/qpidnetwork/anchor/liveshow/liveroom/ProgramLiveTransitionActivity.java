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
import android.widget.ProgressBar;
import android.widget.TextView;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.framework.base.BaseFragmentActivity;
import com.qpidnetwork.anchor.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.anchor.httprequest.LiveRequestOperator;
import com.qpidnetwork.anchor.httprequest.OnGetShowRoomInfoCallback;
import com.qpidnetwork.anchor.httprequest.item.IntToEnumUtils;
import com.qpidnetwork.anchor.httprequest.item.LiveRoomType;
import com.qpidnetwork.anchor.httprequest.item.LoginItem;
import com.qpidnetwork.anchor.httprequest.item.ProgramInfoItem;
import com.qpidnetwork.anchor.im.IMInviteLaunchEventListener;
import com.qpidnetwork.anchor.im.IMManager;
import com.qpidnetwork.anchor.im.IMOtherEventListener;
import com.qpidnetwork.anchor.im.listener.IMClientListener;
import com.qpidnetwork.anchor.im.listener.IMInviteListItem;
import com.qpidnetwork.anchor.im.listener.IMRoomInItem;
import com.qpidnetwork.anchor.liveshow.authorization.LoginManager;
import com.qpidnetwork.anchor.liveshow.home.MainFragmentActivity;
import com.qpidnetwork.anchor.liveshow.manager.CameraMicroPhoneCheckManager;
import com.qpidnetwork.anchor.utils.SystemUtils;
import com.qpidnetwork.qnbridgemodule.bean.CommonConstant;
import com.squareup.picasso.MemoryPolicy;
import com.squareup.picasso.Picasso;

import java.util.Timer;
import java.util.TimerTask;

import static com.qpidnetwork.anchor.httprequest.item.HttpLccErrType.HTTP_LCC_ERR_CONNECTFAIL;

/**
 * Created by Hunter Mun on 2018/5/5.
 */

public class ProgramLiveTransitionActivity extends BaseFragmentActivity implements IMOtherEventListener,
        IMInviteLaunchEventListener, CameraMicroPhoneCheckManager.OnCameraAndRecordAudioCheckListener{

    private static final int MSG_CHECK_PERMISSION_CALLBACK = 1;
    private static final String TRANSITION_SHOWLIVEID = "showLiveId";

    public static final String LIVEROOM_ROOMINFO_ITEM = "roomInItem";


    //Manager
    private IMManager mIMManager;
    private CameraMicroPhoneCheckManager mCameraMicroPhoneCheckManager;
    private Timer mReciprocalTimer;

    //view
    private CircleImageView civPhoto;
    private TextView tvDesc;
    //按钮
    private Button btnRetry;
    //进度条
    private ProgressBar pb_waiting;

    //数据信息
    private String mShowLiveId = "";
    private String mRoomId = "";
    private int mLeftSeconds = 0;               //记录开播倒计时时间

    private boolean mIsStartShowError = false;      //标记逻辑是否已经出错，处理点击返回按钮不同操作

    //RoomIn 请求reqID
    private int mRoomInRequestID = IMManager.IM_INVALID_REQID;

    public static Intent getProgramIntent(Context context, String showLiveId){
        Intent intent = new Intent(context, ProgramLiveTransitionActivity.class);
        intent.putExtra(TRANSITION_SHOWLIVEID, showLiveId);
        return intent;
    }

    @Override
    protected void onCreate(Bundle arg0) {
        super.onCreate(arg0);
        TAG = ProgramLiveTransitionActivity.class.getSimpleName();
        setContentView(R.layout.activity_program_transition);

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

        civPhoto = (CircleImageView)findViewById(R.id.civPhoto);
        tvDesc = (TextView)findViewById(R.id.tvDesc);
        //按钮区域
        btnRetry = (Button) findViewById(R.id.btnRetry);
        //进度
        pb_waiting = (ProgressBar) findViewById(R.id.pb_waiting);

        findViewById(R.id.btnClose).setOnClickListener(this);
        btnRetry.setOnClickListener(this);
    }

    public void initData(){
        Bundle bundle = getIntent().getExtras();

        if(bundle != null){
            if(bundle.containsKey(TRANSITION_SHOWLIVEID)){
                mShowLiveId = bundle.getString(TRANSITION_SHOWLIVEID);
            }

        }

        LoginItem item = LoginManager.getInstance().getLoginItem();
        if(item != null && !TextUtils.isEmpty(item.photoUrl)) {
            Picasso.with(getApplicationContext()).load(item.photoUrl)
                    .placeholder(R.drawable.ic_default_photo_woman)
                    .error(R.drawable.ic_default_photo_woman)
                    .memoryPolicy(MemoryPolicy.NO_CACHE)
                    .into(civPhoto);
        }


        if(!TextUtils.isEmpty(mShowLiveId)) {
            //先进行权限检测，通过后才可以走进入流程
            checkPermission();
        }else{
            finish();
        }
    }

    /**
     * 启动节目逻辑
     * @param showLiveId
     */
    private void startProgram(String showLiveId){
        //重置解决重连时错误
        mIsStartShowError = false;
        //获取节目信息
        LiveRequestOperator.getInstance().GetShowRoomInfo(showLiveId, new OnGetShowRoomInfoCallback() {
            @Override
            public void onGetShowRoomInfo(final boolean isSuccess, final int errCode, final String errMsg, final ProgramInfoItem item, final String roomId) {
                if(isActivityVisible() || SystemUtils.isBackground(mContext)) {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            if (isSuccess) {
                                mRoomId = roomId;
                                pb_waiting.setVisibility(View.GONE);
                                tvDesc.setVisibility(View.VISIBLE);
                                if (item != null && item.leftSecToStart > 0) {
                                    startProgramEnterReciprocal(item);
                                } else {
                                    //写死1分钟
//                                tvDesc.setText(String.format(getResources().getString(R.string.livemsg_program_transition_reciprocal_tips), item.showTitle, String.valueOf(1)));
                                    startRoomIn(roomId);
                                }
                            } else {
                                if (IntToEnumUtils.intToHttpErrorType(errCode) == HTTP_LCC_ERR_CONNECTFAIL) {
                                    btnRetry.setVisibility(View.VISIBLE);
                                }
                                onErrorHandle(errMsg);
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
        if(item.leftSecToStart > 0){
            mLeftSeconds = item.leftSecToStart;
            int leftMinutes = item.leftSecToStart/60 + ((item.leftSecToStart%60)>0?1:0);
            tvDesc.setText(String.format(getResources().getString(R.string.livemsg_program_transition_reciprocal_tips), item.showTitle, String.valueOf(leftMinutes)));

            //解决过度页面弹充值提示-跳转充值界面-完成充值回来-走onResume逻辑时后重新RoomIn，
            // 调用mReciprocalTimer.schedule抛java.lang.IllegalStateException: Timer was canceled
            if(null == mReciprocalTimer){
                mReciprocalTimer = new Timer();
            }
            //1分钟定时器
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
                if(leftSeconds > 0) {
                    int leftMinutes = leftSeconds/60 + ((leftSeconds%60)>0?1:0);
                    //剩余时间少于1分钟时，界面保留1分钟等待进入状态
                    tvDesc.setText(String.format(getResources().getString(R.string.livemsg_program_transition_reciprocal_tips), programTitle, String.valueOf(leftMinutes)));
                }else{
                    //倒计时结束，调用进入直播间逻辑
                    startRoomIn(mRoomId);
                }
            }
        });
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        switch (msg.what){
            case MSG_CHECK_PERMISSION_CALLBACK:{
                if(msg.arg1 == 1){
                    //检测成功
                    startProgram(mShowLiveId);
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
                if(mIsStartShowError){
                    exitLiveroomTransition();
                }else {
                    showExitDialog();
                }
            }break;
            case R.id.btnRetry:{
                //点击retry操作（应邀操作或进入直播间操作）
                pb_waiting.setVisibility(View.VISIBLE);
                tvDesc.setVisibility(View.GONE);
                btnRetry.setVisibility(View.GONE);

                //检测成功
                startProgram(mShowLiveId);
            }break;
        }
    }

    /**
     * 执行进入直播间逻辑
     */
    private void startRoomIn(String roomId){
        mRoomInRequestID = mIMManager.RoomIn(mRoomId);
    }

    /**
     * 主动退出逻辑
     */
    private void exitLiveroomTransition(){
        if(!TextUtils.isEmpty(mRoomId)){
            mIMManager.roomOutAndClearFlag(mRoomId);
        }
        //注销冲突接收器
        unRegisterConfictReceiver();
        finish();
    }

    /**
     * 出错处理
     * @param errMsg
     */
    private void onErrorHandle(String errMsg){
        mIsStartShowError = true;
        pb_waiting.setVisibility(View.GONE);
        tvDesc.setVisibility(View.VISIBLE);
        tvDesc.setText(errMsg);
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
        exitLiveroomTransition();
        unRegisterListener();
        //注销冲突广播接收器
        unRegisterConfictReceiver();
        //清除定时器
        if(mReciprocalTimer != null){
            mReciprocalTimer.cancel();
            mReciprocalTimer.purge();
            mReciprocalTimer = null;
        }

        //删除定时消息
        removeUiMessages(MSG_CHECK_PERMISSION_CALLBACK);
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if ( keyCode == KeyEvent.KEYCODE_BACK && event.getAction() == KeyEvent.ACTION_DOWN ){
            //拦截返回键
            exitLiveroomTransition();
            return false;
        }
        return super.onKeyDown(keyCode, event);
    }

    /***************************** 服务冲突广播接收器 *****************************************/
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

    /********************************* 退出Dialog弹窗 ************************************/
    private AlertDialog mExitDialog = null;

    /**
     * 显示退出提示
     */
    private void showExitDialog(){
        if(mExitDialog == null){
            AlertDialog.Builder builder = new AlertDialog.Builder(this)
                    .setMessage(getResources().getString(R.string.live_programme_transition_close_desc))
                    .setNegativeButton(getResources().getString(R.string.common_btn_cancel), new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {

                        }
                    })
                    .setPositiveButton(getResources().getString(R.string.common_btn_close), new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            exitLiveroomTransition();
                        }
                    });
            mExitDialog = builder.create();
        }
        if(!mExitDialog.isShowing()){
            mExitDialog.show();
        }
    }

    /**
     * 隐藏dilog
     */
    private void hideExitDialog(){
        if(mExitDialog != null && mExitDialog.isShowing()){
            mExitDialog.dismiss();
        }
    }


    /********************************* 权限检测处理 ************************************/
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

    /********************************* IM事件回调  **************************************/
    @Override
    public void OnLogin(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

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

    @Override
    public void OnRoomIn(int reqId, final boolean success, final IMClientListener.LCC_ERR_TYPE errType, final String errMsg, final IMRoomInItem roomInfo) {
        //进入私密直播间成功返回
        if(mRoomInRequestID == reqId) {
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    //后台或者可见时才跳转，解决由于clear top导致push点击，后台会进入直播间
                    if (isActivityVisible() || SystemUtils.isBackground(mContext)) {
                        //是否统一请求不可用房间Id判断，否则会出现其他直播间通知导致消息错误
                        if (success) {
                            //跳转前关闭显示dialog
                            hideExitDialog();
                            //进入成功直接调用进入直播间
                            Intent intent = new Intent(ProgramLiveTransitionActivity.this, PublicLiveRoomActivity.class);
                            intent.putExtra(LIVEROOM_ROOMINFO_ITEM, roomInfo);
                            startActivity(intent);
                            mRoomId = "";
                            //注销事件监听器
                            unRegisterConfictReceiver();
                            finish();
                        } else {
                            if (errType == IMClientListener.LCC_ERR_TYPE.LCC_ERR_CONNECTFAIL) {
                                btnRetry.setVisibility(View.VISIBLE);
                            }
                            onErrorHandle(errMsg);
                        }
                    }
                }
            });
        }
    }

    @Override
    public void OnRoomOut(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnSendImmediatePrivateInvite(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, String invitationId, int timeout, String roomId) {

    }

    @Override
    public void OnRecvInviteReply(String inviteId, IMClientListener.InviteReplyType replyType, String roomId, LiveRoomType roomType, String anchorId, String nickName, String avatarImg) {

    }

    @Override
    public void OnGetInviteInfo(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMInviteListItem inviteItem) {

    }
}
