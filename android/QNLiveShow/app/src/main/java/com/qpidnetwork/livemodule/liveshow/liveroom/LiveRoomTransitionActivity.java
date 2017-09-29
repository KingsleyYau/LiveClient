package com.qpidnetwork.livemodule.liveshow.liveroom;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Message;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.livemodule.httprequest.item.LiveRoomType;
import com.qpidnetwork.livemodule.im.IMInviteLaunchEventListener;
import com.qpidnetwork.livemodule.im.IMManager;
import com.qpidnetwork.livemodule.im.IMOtherEventListener;
import com.qpidnetwork.livemodule.im.listener.IMClientListener;
import com.qpidnetwork.livemodule.im.listener.IMInviteListItem;
import com.qpidnetwork.livemodule.im.listener.IMPackageUpdateItem;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.livemodule.liveshow.LiveApplication;
import com.qpidnetwork.livemodule.liveshow.WebViewActivity;
import com.qpidnetwork.livemodule.liveshow.home.MainFragmentActivity;
import com.qpidnetwork.livemodule.view.MaterialDialogAlert;
import com.squareup.picasso.Picasso;

import java.util.Timer;
import java.util.TimerTask;


/**
 * 邀请及进入直播间过渡页，主要处理邀请及进入直播间过程中的异常
 * @author Hunter
 */
public class LiveRoomTransitionActivity extends BaseFragmentActivity implements IMOtherEventListener, IMInviteLaunchEventListener{

    private static final int TEN_SENCONDS_EVNET = 1;
    private static final int OVERTIME_EVNET = 2;

    public static final String LIVEROOM_ROOMINFO_ITEM = "roomInfo";
    public static final String LIVEROOM_ROOMINFO_ROOMPHOTOURL = "roomPhotoUrl";

    private static final String TRANSITION_OPERATETYPE = "operateType";
    private static final String TRANSITION_ANCHOR_ID = "anchorId";
    private static final String TRANSITION_ANCHOR_NAME = "anchorName";
    private static final String TRANSITION_ANCHOR_PHOTOURL = "anchorPhotoUrl";

    private static final String TRANSITION_ROOMID = "roomId";
    private static final String TRANSITION_INVITE_LOGID = "logid";

    //view
    private LinearLayout llOperateAera;
    private Button btnCancel;
    private CircleImageView civPhoto;
    private TextView tvAnchorName;
    private TextView tvDesc;
    //倒计时
    private LinearLayout llCountDown;
    private TextView tvCountDown;
    //按钮
    private LinearLayout llButtonContent;
    private Button btn_double;
    private Button btn_single;
    //推荐
    private LinearLayout llRecommand;
    private CircleImageView civRecommand1;
    private CircleImageView civRecommand2;
    //进度条
//    private MaterialProgressBar pbLoading;
    private ProgressBar pb_waiting;

    //data
    private boolean mIsInvite = false;       //用于区分 进入直播间逻辑与邀请进入直播间
    private String mAnchorId = "";
    private String mAnchorName = "";
    private String mAnchorPhotoUrl = "";
    private String mRoomId = "";
    private String mRoomPhotoUrl = "";
    private String mLogId = "";

    private IMRoomInItem mIMRoomInItem = null;  //进入房间成功返回房间信息，本地缓存
    private int mLeftSeconds = 0;          //记录开播倒计时时间
    private String mInvatationId = "";

    //Manager
    private IMManager mIMManager;
    private Timer mReciprocalTimer;

    //定义按钮点击事件类型
    private enum ButtonEventType{
        Unknown,
        Start_Private_Broadcast,
        Book_Private_Broadcast,
        View_Hot_Broadcasts,
        Add_Credit,
        Force_Start_Private_Broadcast,
        Common_Retry,
        View_Broadcast_Profile,
    }

    public static Intent getRoomInIntent(Context context, String anchorId, String anchorName,
                                         String anchorPhotoUrl, String roomId ,String roomPhotoUrl){
        Intent intent = new Intent(context, LiveRoomTransitionActivity.class);
        intent.putExtra(TRANSITION_OPERATETYPE, false);
        intent.putExtra(TRANSITION_ANCHOR_ID, anchorId);
        intent.putExtra(TRANSITION_ANCHOR_NAME, anchorName);
        intent.putExtra(TRANSITION_ANCHOR_PHOTOURL, anchorPhotoUrl);
        intent.putExtra(LIVEROOM_ROOMINFO_ROOMPHOTOURL, roomPhotoUrl);
        intent.putExtra(TRANSITION_ROOMID, roomId);
        return intent;
    }

    public static Intent getInviteIntent(Context context, String anchorId, String anchorName,
                                         String anchorPhotoUrl, String logId,String roomPhotoUrl){
        Intent intent = new Intent(context, LiveRoomTransitionActivity.class);
        intent.putExtra(TRANSITION_OPERATETYPE, true);
        intent.putExtra(TRANSITION_ANCHOR_ID, anchorId);
        intent.putExtra(TRANSITION_ANCHOR_NAME, anchorName);
        intent.putExtra(TRANSITION_ANCHOR_PHOTOURL, anchorPhotoUrl);
        intent.putExtra(LIVEROOM_ROOMINFO_ROOMPHOTOURL, roomPhotoUrl);
        intent.putExtra(TRANSITION_INVITE_LOGID, logId);
        return intent;
    }

    /**
     * url 跳转使用
     * @param context
     * @param isInvite
     * @param roomId
     * @param anchorId
     * @return
     */
    public static Intent getURLIntent(Context context, boolean isInvite, String roomId, String anchorId){
        Intent intent = new Intent(context, LiveRoomTransitionActivity.class);
        intent.putExtra(TRANSITION_OPERATETYPE, isInvite);
        intent.putExtra(TRANSITION_ROOMID, roomId);
        intent.putExtra(TRANSITION_ANCHOR_ID, anchorId);
        return intent;
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        TAG = LiveRoomTransitionActivity.class.getSimpleName();
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_liveroom_transition);
        initViews();
        initData();
        registerListener();
        startInviteOrRoomIn();
    }

    private void initViews(){
        llOperateAera = (LinearLayout)findViewById(R.id.llOperateAera);
        btnCancel = (Button)findViewById(R.id.btnCancel);
        civPhoto = (CircleImageView)findViewById(R.id.civPhoto);
        tvAnchorName = (TextView)findViewById(R.id.tvAnchorName);
        tvDesc = (TextView)findViewById(R.id.tvDesc);

        //倒计时
        llCountDown = (LinearLayout) findViewById(R.id.llCountDown);
        tvCountDown = (TextView) findViewById(R.id.tvCountDown);

        //按钮区域
        llButtonContent = (LinearLayout)findViewById(R.id.llButtonContent);
        btn_double = (Button) findViewById(R.id.btn_double);
        btn_single = (Button) findViewById(R.id.btn_single);

        //推荐
        llRecommand = (LinearLayout) findViewById(R.id.llRecommand);
        civRecommand1 = (CircleImageView) findViewById(R.id.civRecommand1);
        civRecommand2 = (CircleImageView) findViewById(R.id.civRecommand2);

        //进度
//        pbLoading = (MaterialProgressBar)findViewById(R.id.pbLoading);
        pb_waiting = (ProgressBar) findViewById(R.id.pb_waiting);

        btnCancel.setOnClickListener(this);
        btnCancel.setVisibility(View.GONE);
        btn_double.setOnClickListener(this);
        btn_single.setOnClickListener(this);
        civRecommand1.setOnClickListener(this);
        civRecommand2.setOnClickListener(this);

        if(!TextUtils.isEmpty(mAnchorPhotoUrl)) {
            Picasso.with(LiveApplication.getContext()).load(mAnchorPhotoUrl).into(civPhoto);
        }
        tvAnchorName.setText(mAnchorName);
    }

    public void initData(){
        Bundle bundle = getIntent().getExtras();
        if(bundle != null){
            if(bundle.containsKey(TRANSITION_OPERATETYPE)){
                mIsInvite = bundle.getBoolean(TRANSITION_OPERATETYPE);
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
            if(bundle.containsKey(LIVEROOM_ROOMINFO_ROOMPHOTOURL)){
                mRoomPhotoUrl = bundle.getString(LIVEROOM_ROOMINFO_ROOMPHOTOURL);
            }
            if(bundle.containsKey(TRANSITION_INVITE_LOGID)){
                mLogId = bundle.getString(TRANSITION_INVITE_LOGID);
            }
        }
        mIMManager = IMManager.getInstance();
        mReciprocalTimer = new Timer();

        //启动10秒显示右上角取消按钮
        sendEmptyUiMessageDelayed(TEN_SENCONDS_EVNET, 10*1000);
        //启动本地超时逻辑
        startOrResetLocalOverTime();
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);
        switch (v.getId()){
            case R.id.btnCancel:{
                exitLiveroomTransition();
            }break;
            case R.id.btn_double:
            case R.id.btn_single:{
                onFunctionButtonClick(v);
            }break;
        }
    }

    /**
     * 启动重置本地超时逻辑
     */
    private void startOrResetLocalOverTime(){
        removeUiMessages(OVERTIME_EVNET);
        //启动180秒超时逻辑
        sendEmptyUiMessageDelayed(OVERTIME_EVNET, 180*1000);
    }

    /**
     * 错误页等页面功能按钮处理
     * @param v
     */
    private void onFunctionButtonClick(View v){
        ButtonEventType eventType = ButtonEventType.Unknown;
        if(v.getTag() instanceof Integer){
            int type = (Integer)v.getTag();
            if(type >= 0 && type <ButtonEventType.values().length){
                eventType = ButtonEventType.values()[type];
            }else{
                eventType = ButtonEventType.Unknown;
            }
        }
        switch (eventType){
            case Start_Private_Broadcast:{
                //发送私密邀请
                startActivity(LiveRoomTransitionActivity.getInviteIntent(this, mAnchorId,
                        mAnchorName, mAnchorPhotoUrl, "", mRoomPhotoUrl));
                finish();
            }break;
            case Book_Private_Broadcast:{
                //跳转到预约邀请编辑界面
                finish();
            }break;
            case View_Hot_Broadcasts:{
                //跳转热播列表
                Intent intent = new Intent(this, MainFragmentActivity.class);
                intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent);
            }break;
            case Add_Credit:{
                //跳转买点模块
                startActivity(WebViewActivity.getIntent(this, "Add Credit", "http://www.baidu.com"));
            }break;
            case Force_Start_Private_Broadcast:{
                //强制私密直播
                startInvite(true);
            }break;
            case Common_Retry:{
                startInviteOrRoomIn();
            }break;
            case View_Broadcast_Profile:{
                startActivity(WebViewActivity.getIntent(this, "Profile", "http://www.baidu.com"));
            }break;
        }
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        switch (msg.what){
            case TEN_SENCONDS_EVNET:{
                if(mIMRoomInItem == null){
                    //未完成进入直播间逻辑
                    btnCancel.setVisibility(View.VISIBLE);
                }
            }break;
            case OVERTIME_EVNET:{
                showCommonError();
            }
        }
    }

    /**
     * 主动退出逻辑
     */
    private void exitLiveroomTransition(){
        if(mIMRoomInItem != null){
            //完成进入房间逻辑
        }else if(!TextUtils.isEmpty(mInvatationId)){
            //完成邀请逻辑
        }
        finish();
    }

    private void startInviteOrRoomIn(){
        if(mIsInvite){
            startInvite(false);
        }else{
            startRoomIn(mRoomId);
        }
    }

    /*********************************  界面切换start  ***********************************************/
    /**
     * 邀请或进入房间请求过程中
     */
    private void showInviteOrRoomInRequesting(){
        llOperateAera.setVisibility(View.GONE);

//        //调整ProgressBar位置
//        RelativeLayout.LayoutParams params = (RelativeLayout.LayoutParams)pbLoading.getLayoutParams();
//        params.width = DisplayUtil.dip2px(this, 64);
//        params.height = DisplayUtil.dip2px(this, 64);
//        params.bottomMargin = DisplayUtil.dip2px(this, 320);
//        pbLoading.setLayoutParams(params);
//        pbLoading.setVisibility(View.VISIBLE);

        pb_waiting.setVisibility(View.VISIBLE);
    }

    /**
     * 邀请时提示主播正在私密直播中异常
     */
    private void showInviteAnchorInPrivateBroadcastException(){
        llOperateAera.setVisibility(View.VISIBLE);

        tvAnchorName.setVisibility(View.GONE);
        tvDesc.setText(String.format(getResources().getString(R.string.liveroom_transition_anchor_private_broadcast_exception), mAnchorName));

        llCountDown.setVisibility(View.GONE);

        llButtonContent.setVisibility(View.VISIBLE);
        btn_double.setVisibility(View.VISIBLE);
        btn_double.setBackgroundResource(R.drawable.button_yes);
        btn_double.setTag(Integer.valueOf(ButtonEventType.Force_Start_Private_Broadcast.ordinal()));
        btn_single.setVisibility(View.GONE);

        //推荐区域，需等待请求返回刷新
        llRecommand.setVisibility(View.GONE);

//        pbLoading.setVisibility(View.GONE);
        pb_waiting.setVisibility(View.GONE);
    }

    /**
     * 邀请发送成功，等待主播确认
     */
    private void showWaitForAnchorConfirm(){
        llOperateAera.setVisibility(View.VISIBLE);

        tvAnchorName.setVisibility(View.GONE);
        tvDesc.setText(String.format(getResources().getString(R.string.liveroom_transition_invite_novoucher_tips), mAnchorName));
        llCountDown.setVisibility(View.GONE);
        llButtonContent.setVisibility(View.GONE);
        llRecommand.setVisibility(View.GONE);

//        //调整ProgressBar位置
//        RelativeLayout.LayoutParams params = (RelativeLayout.LayoutParams)pbLoading.getLayoutParams();
//        params.width = DisplayUtil.dip2px(this, 32);
//        params.height = DisplayUtil.dip2px(this, 32);
//        params.bottomMargin = DisplayUtil.dip2px(this, 56);
//        pbLoading.setLayoutParams(params);
//        pbLoading.setVisibility(View.VISIBLE);
        pb_waiting.setVisibility(View.VISIBLE);
    }

    /**
     * 显示等待进入直播间
     */
    private void showWaitEnterLiveroom(){
        llOperateAera.setVisibility(View.VISIBLE);

        tvAnchorName.setVisibility(View.GONE);
        tvDesc.setText(String.format(getResources().getString(R.string.liveroom_transition_enterroom_wait), mAnchorName));
        llCountDown.setVisibility(View.VISIBLE);
        llButtonContent.setVisibility(View.GONE);
        llRecommand.setVisibility(View.GONE);

//        pbLoading.setVisibility(View.GONE);
        pb_waiting.setVisibility(View.GONE);
    }

    /**
     * 邀请发送失败
     */
    private void showInviteRequestException(){
        llOperateAera.setVisibility(View.VISIBLE);

        tvAnchorName.setVisibility(View.VISIBLE);
        tvDesc.setText(getResources().getString(R.string.liveroom_transition_invite_failed));
        llCountDown.setVisibility(View.GONE);

        //按钮区域
        llButtonContent.setVisibility(View.VISIBLE);
        btn_double.setVisibility(View.VISIBLE);
        btn_double.setBackgroundResource(R.drawable.button_retry);
        btn_double.setTag(Integer.valueOf(ButtonEventType.Common_Retry.ordinal()));
        btn_single.setVisibility(View.VISIBLE);
        btn_single.setBackgroundResource(R.drawable.button_book_broadcast);
        btn_single.setTag(Integer.valueOf(ButtonEventType.Book_Private_Broadcast.ordinal()));

        llRecommand.setVisibility(View.GONE);
//        pbLoading.setVisibility(View.GONE);
        pb_waiting.setVisibility(View.GONE);
    }

    /**
     * 主播拒绝
     */
    private void showInviteAnchorDeny(){
        llOperateAera.setVisibility(View.VISIBLE);

        tvAnchorName.setVisibility(View.GONE);
        tvDesc.setText(String.format(getResources().getString(R.string.liveroom_transition_invite_deny), mAnchorName));
        llCountDown.setVisibility(View.GONE);

        //按钮区域
        llButtonContent.setVisibility(View.VISIBLE);
        btn_double.setVisibility(View.VISIBLE);
        btn_double.setBackgroundResource(R.drawable.button_retry);
        btn_double.setTag(Integer.valueOf(ButtonEventType.Common_Retry.ordinal()));
        btn_single.setVisibility(View.VISIBLE);
        btn_single.setBackgroundResource(R.drawable.button_book_broadcast);
        btn_single.setTag(Integer.valueOf(ButtonEventType.Book_Private_Broadcast.ordinal()));

        llRecommand.setVisibility(View.GONE);
//        pbLoading.setVisibility(View.GONE);
        pb_waiting.setVisibility(View.GONE);
    }

    /**
     * 邀请超时
     */
    private void  showInviteOverTimeException(){
        llOperateAera.setVisibility(View.VISIBLE);

        tvAnchorName.setVisibility(View.VISIBLE);
        tvDesc.setText(getResources().getString(R.string.liveroom_transition_invite_overtime));
        llCountDown.setVisibility(View.GONE);

        //按钮区域
        llButtonContent.setVisibility(View.VISIBLE);
        btn_double.setVisibility(View.VISIBLE);
        btn_double.setBackgroundResource(R.drawable.button_view_anchor_profile);
        btn_double.setTag(Integer.valueOf(ButtonEventType.View_Broadcast_Profile.ordinal()));
        btn_single.setVisibility(View.VISIBLE);
        btn_single.setBackgroundResource(R.drawable.button_view_hotlist);
        btn_single.setTag(Integer.valueOf(ButtonEventType.View_Hot_Broadcasts.ordinal()));

        llRecommand.setVisibility(View.GONE);
//        pbLoading.setVisibility(View.GONE);
        pb_waiting.setVisibility(View.GONE);
    }

    /**
     * 断线重连后，获取邀请状态为主播取消状态（此状态为用户断线时，主播点击接受邀请，此时邀请标记为主播取消）
     */
    private void showInviteCanceledException(){
        llOperateAera.setVisibility(View.VISIBLE);

        tvAnchorName.setVisibility(View.VISIBLE);
        tvDesc.setText(getResources().getString(R.string.liveroom_transition_invite_anchor_cancel));
        llCountDown.setVisibility(View.GONE);

        //按钮区域
        llButtonContent.setVisibility(View.VISIBLE);
        btn_double.setVisibility(View.VISIBLE);
        btn_double.setBackgroundResource(R.drawable.button_view_anchor_profile);
        btn_double.setTag(Integer.valueOf(ButtonEventType.View_Broadcast_Profile.ordinal()));
        btn_single.setVisibility(View.VISIBLE);
        btn_single.setBackgroundResource(R.drawable.button_view_hotlist);
        btn_single.setTag(Integer.valueOf(ButtonEventType.View_Hot_Broadcasts.ordinal()));

        llRecommand.setVisibility(View.GONE);
//        pbLoading.setVisibility(View.GONE);
        pb_waiting.setVisibility(View.GONE);
    }

    /*********************************  界面切换End  ***********************************************/


    /*********************************  进入直播间邀请逻辑start  ***********************************************/
    /**
     * 发起立即私密邀请
     * @param force
     */
    private void startInvite(boolean force){
        showInviteOrRoomInRequesting();
        mIMManager.sendImmediatePrivateInvite(mAnchorId, mLogId, force);
    }

    /**
     * 收到立即私密邀请应答处理
     * @param replyType
     * @param roomId
     */
    private void onInviteReplyHandler(IMClientListener.InviteReplyType replyType, String roomId){
        //重置邀请ID，清除邀请状态
        mInvatationId = "";
        switch (replyType){
            case Defined: {
                showInviteAnchorDeny();
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
        mIMManager.cancelImmediatePrivateInvite(invitationId);
    }

    /*********************************  进入直播间邀请逻辑end  ***********************************************/


    /*********************************  进入直播间逻辑start  ***********************************************/
    /**
     * 进入直播间入口
     */
    private void startRoomIn(String roomId){
        showInviteOrRoomInRequesting();
        if(!TextUtils.isEmpty(roomId)){
            //收到预约邀请通知或立即邀请成功等已有RoomId，直接进入直播间
            mIMManager.RoomIn(roomId);
        }else{
            //如RoomId为空,进入公开直播间
            mIMManager.PublicRoomIn(mAnchorId);
        }
    }

    /**
     * 开播倒数逻辑
     * @param leftSeconds
     */
    private void startEnterReciprocal(int leftSeconds){
        if(leftSeconds > 0){
            showWaitEnterLiveroom();
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
     * 进入直播间界面跳转
     */
    private void enterLiveRoom(){
        unRegisterListener();
        Intent intent = null;
        if(mIMRoomInItem.roomType == IMRoomInItem.IMLiveRoomType.FreePublicRoom){
            intent = new Intent(this, FreePublicLiveRoomActivity.class);
        }else if(mIMRoomInItem.roomType == IMRoomInItem.IMLiveRoomType.PaidPublicRoom){
            intent = new Intent(this, PayPublicLiveRoomActivity.class);
        }
        if(null != intent){
            intent.putExtra(LIVEROOM_ROOMINFO_ITEM, mIMRoomInItem);
            intent.putExtra(LIVEROOM_ROOMINFO_ROOMPHOTOURL, mRoomPhotoUrl);
            startActivity(intent);
        }
        finish();
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
                +" errMsg:"+errMsg+" roomInfo:"+roomInfo);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if(success){
                    //此时不能退出房间
                    btnCancel.setVisibility(View.GONE);
                    //进入房间成功
                    mIMRoomInItem = roomInfo;
                    //是否需要等待开播通知
                    if(!roomInfo.needWait){
                        //不需要等待，进入开播倒数进入逻辑
                        startEnterReciprocal(roomInfo.leftSeconds);
                    }
                }else{
                    //进入房间失败，统一处理
                    onIMRequestFaiHandler(errType);
                }
            }
        });
    }

    /**
     * IM错误统一处理
     * @param errType
     */
    private void onIMRequestFaiHandler(IMClientListener.LCC_ERR_TYPE errType){
        //异常处理
//        pbLoading.setVisibility(View.GONE);
        pb_waiting.setVisibility(View.GONE);
        switch (errType){
            case LCC_ERR_AUDIENCE_LIMIT:{
                //直播间人数过多
                showAudienceLimitError();
            }break;
            case LCC_ERR_NO_CREDIT:{
                //信用点不足
                showNoMoneyError();
            }break;
            case LCC_ERR_ANCHOR_PLAYING:{
                //主播正在私密直播中
                showInviteAnchorInPrivateBroadcastException();
            }break;
            default:{
                //统一定义为普通错误，统一处理
                showCommonError();
            }break;
        }
    }

    /**
     * 房间人数过多处理
     */
    private void showAudienceLimitError(){
        MaterialDialogAlert dialog = new MaterialDialogAlert(this);
        dialog.setCancelable(false);
        dialog.setMessage("房间人数过多");
        dialog.addButton(dialog.createButton(getString(R.string.common_btn_ok), new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        }));
        dialog.show();
    }

    /**
     * 没点错误
     */
    private void showNoMoneyError(){
        MaterialDialogAlert dialog = new MaterialDialogAlert(this);
        dialog.setCancelable(false);
        dialog.setMessage("信用点不足");
        dialog.addButton(dialog.createButton(getString(R.string.common_btn_add_credit), new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                //跳去买点
            }
        }));
        dialog.addButton(dialog.createButton(getString(R.string.common_btn_cancel), new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        }));
        dialog.show();
    }

    /**
     * 房间人数过多处理
     */
    private void showCommonError(){
        MaterialDialogAlert dialog = new MaterialDialogAlert(this);
        dialog.setCancelable(false);
        dialog.setMessage("出错了，请退出房间重试");
        dialog.addButton(dialog.createButton(getString(R.string.common_btn_ok), new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        }));
        dialog.show();
    }

    /*********************************  进入直播间逻辑end  ***********************************************/

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
        unRegisterListener();
        if(mReciprocalTimer != null){
            mReciprocalTimer.cancel();
        }
        //删除定时消息
        removeUiMessages(TEN_SENCONDS_EVNET);
        removeUiMessages(OVERTIME_EVNET);
    }

    /********************************************* IM回调事件处理  *****************************************************/
    @Override
    public void OnLogin(final IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
        //断线重连通知
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if(errType == IMClientListener.LCC_ERR_TYPE.LCC_ERR_SUCCESS){
                    //重连成功，获取指定私密邀请状态
                    if(!TextUtils.isEmpty(mInvatationId)){
                        //邀请中，获取邀请状态
                        mIMManager.GetInviteInfo(mInvatationId);
                    }
                }
            }
        });
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
        Log.d(TAG,"OnRoomIn-reqId:"+reqId+" success:"+success+" errType:"+errType+" roomInfo:"+roomInfo);
        onRoomInCallback(reqId, success, errType, errMsg, roomInfo);
    }

    @Override
    public void OnRoomOut(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnRecvLiveStart(String roomId, final int leftSeconds) {
        //通知进入直播间
        if(mIMRoomInItem != null && mIMRoomInItem.equals(roomId)){
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
        if(success){
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    //获取邀请信息成功
                    switch (inviteItem.inviteType){
                        case Pending:{
                            //邀请中
                            showWaitForAnchorConfirm();
                        }break;
                        case Accepted:{
                            //已接受，进入直播间
                            if(!TextUtils.isEmpty(inviteItem.roomId)){
                                startRoomIn(inviteItem.roomId);
                            }else{
                                //提示邀请出错
                                showInviteAnchorDeny();
                            }
                        }break;

                        case Canceled:{
                            showInviteCanceledException();
                        }break;

                        case OverTime:{
                            showInviteOverTimeException();
                        }break;

                        case AnchorAbsent:
                        case AudienceAbsent:
                        case Rejected:
                        case Unknown:
                        case Confirmed:{
                            showInviteAnchorDeny();
                        }break;
                    }
                }
            });
        }
    }

    @Override
    public void OnSendImmediatePrivateInvite(int reqId, final boolean success, final IMClientListener.LCC_ERR_TYPE errType, String errMsg, final String invitationId, int timeout, final String roomId) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if(success){
                    if(!TextUtils.isEmpty(roomId)){
                        //邀请之前已在房间中
                        startRoomIn(roomId);
                    }else{
                        //成功
                        mInvatationId = invitationId;
                        //等待主播确认或超时
                        showWaitForAnchorConfirm();
                    }
                }else{
                    onIMRequestFaiHandler(errType);
                }
            }
        });
    }

    @Override
    public void OnCancelImmediatePrivateInvite(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, String roomId) {

    }

    @Override
    public void OnRecvInviteReply(String inviteId, final IMClientListener.InviteReplyType replyType, final String roomId, LiveRoomType roomType, String anchorId, String nickName, String avatarImg, String message) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                onInviteReplyHandler(replyType, roomId);
            }
        });
    }
}
