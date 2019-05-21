package com.qpidnetwork.livemodule.liveshow.liveroom;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Message;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetHangoutStatusCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetUserInfoCallback;
import com.qpidnetwork.livemodule.httprequest.item.HangoutAnchorInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.HangoutRoomStatusItem;
import com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType;
import com.qpidnetwork.livemodule.httprequest.item.IntToEnumUtils;
import com.qpidnetwork.livemodule.httprequest.item.UserInfoItem;
import com.qpidnetwork.livemodule.im.IMHangoutEventListener;
import com.qpidnetwork.livemodule.im.IMManager;
import com.qpidnetwork.livemodule.im.listener.IMClientListener;
import com.qpidnetwork.livemodule.im.listener.IMDealInviteItem;
import com.qpidnetwork.livemodule.im.listener.IMHangoutCountDownItem;
import com.qpidnetwork.livemodule.im.listener.IMHangoutInviteItem;
import com.qpidnetwork.livemodule.im.listener.IMHangoutRecommendItem;
import com.qpidnetwork.livemodule.im.listener.IMHangoutRoomItem;
import com.qpidnetwork.livemodule.im.listener.IMMessageItem;
import com.qpidnetwork.livemodule.im.listener.IMRecvEnterRoomItem;
import com.qpidnetwork.livemodule.im.listener.IMRecvKnockRequestItem;
import com.qpidnetwork.livemodule.im.listener.IMRecvLeaveRoomItem;
import com.qpidnetwork.livemodule.im.listener.IMUserBaseInfoItem;
import com.qpidnetwork.livemodule.liveshow.LiveModule;
import com.qpidnetwork.livemodule.liveshow.model.NoMoneyParamsBean;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.PicassoLoadUtil;
import com.qpidnetwork.livemodule.utils.StringUtil;
import com.qpidnetwork.livemodule.utils.SystemUtils;
import com.qpidnetwork.qnbridgemodule.sysPermissions.manager.PermissionManager;
import com.qpidnetwork.qnbridgemodule.util.Log;
import com.qpidnetwork.qnbridgemodule.util.ToastUtil;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType.HTTP_LCC_ERR_EXIST_HANGOUT;

public class HangoutTransitionActivity extends BaseActionBarFragmentActivity implements IMHangoutEventListener, HangoutInvitationManager.OnHangoutInvitationEventListener {

    private static final int EVENT_OVERTIME_EVNET = 1;
    private static final int EVENT_BACKGROUD_TIMEOUT = 2;

    // 2019/4/16 Hardy
    // https://www.qoogifts.com.cn/zentaopms2/www/index.php?m=bug&f=view&bugID=17642
    private static final int ANCHOR_NAME_MAX_LEN = 8;

    private static final int PAGE_REQUEST_MAX_TIMEOUT = 3 * 60 * 1000;   //进入过渡页后3分钟未处理完成，当成超时处理
    private static final int BACKGROUD_LIVE_OVERTIME_TIMESTAMP = 60 * 1000;     //直播中，切换到后台自动结束事件间隔

    private static final String TRANSITION_ANCHOR_INFO = "anchorInfo";
    private static final String TRANSITION_ROOMID = "roomId";
    private static final String LIVEROOM_ROOMINFO_ROOMPHOTOURL = "roomPhotoUrl";
    private static final String TRANSITION_RECOMMAND_ID = "recommendId";

    public static final String TRANSITION_EXTRA_ANCHOR_ID = "extraAnchorID";

    //Manager
    private IMManager mIMManager;

    //views
    //高斯模糊背景
//    private SimpleDraweeView iv_gaussianBlur;
//    private View v_gaussianBlurFloat;
    private ImageView btnClose;
    //主播资料区域
    private LinearLayout llAnchorInfo;
    private CircleImageView civAnchorPhoto;
    private TextView tvAnchorName;
    private LinearLayout llAnchorFriendInfo;
    private CircleImageView civAnchorFriendPhoto;
    private TextView tvAnchorFriendName;
    //描述及进度
    private TextView tvDesc;
    private ProgressBar pb_waiting;
    //按钮操作区域
    private Button btnRetry;
    private Button btnAddCredit;
    private LinearLayout llExistHangout;
    private LinearLayout llNewHangout;

    //data区域
    private List<IMUserBaseInfoItem> mAnchorList;

    private String mRoomId = "";            //房间ID
    private String mRoomPhotoUrl = "";
    private String mRecommendId = "";       //推荐ID
    private HangoutRoomStatusItem mExitRunningHangoutRoom;  //已存在进行中的hangout直播间
    private IMHangoutRoomItem mCreatedHangoutRoom;          //存储创建的直播间信息

    private boolean mIsBackgroudInRoomOut = false;       //纪录是否后台进入直播间后
    private boolean mBackgroudEnterRoomSuccess = false;  //后台进入直播间成功

    private HangoutInvitationManager mHangoutInvitationManager;     //邀请管理器

    private enum PageType{
        PAGE_LAUNCH_INVITING,
        PAGE_EXIST_HANGOUT_ROOM,
        PAGE_ADD_CREDIT,
        PAGE_CONNECTFAIL_RETRY,
        PAAGE_NORMAL_ERROR
    }

    /**
     * 外部入口
     * @param context
     * @param anchorInfo
     * @param roomId
     * @param roomPhotoUrl
     * @return
     */
    public static Intent getIntent(Context context, ArrayList<IMUserBaseInfoItem> anchorInfo, String roomId,
                                   String roomPhotoUrl, String recommendId){
        Intent intent = new Intent(context, HangoutTransitionActivity.class);
        intent.putParcelableArrayListExtra(TRANSITION_ANCHOR_INFO, anchorInfo);
        intent.putExtra(TRANSITION_ROOMID, roomId);
        intent.putExtra(LIVEROOM_ROOMINFO_ROOMPHOTOURL, roomPhotoUrl);
        intent.putExtra(TRANSITION_RECOMMAND_ID, recommendId);
        return intent;
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        TAG = HangoutTransitionActivity.class.getSimpleName();

        //直播间中不熄灭屏幕
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON,
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

        super.onCreate(savedInstanceState);
        setCustomContentView(R.layout.activity_hangout_transition);

        mIMManager = IMManager.getInstance();
        mHangoutInvitationManager = HangoutInvitationManager.createInvitationClient(this);
        mHangoutInvitationManager.setClientEventListener(this);
        registerListener();

        initViews();
        initData();
    }


    /**
     * 绑定监听器
     */
    private void registerListener(){
        mIMManager.registerIMHangoutEventListener(this);
    }

    /**
     * 解绑监听器
     */
    private void unRegisterListener(){
        mIMManager.unregisterIMHangoutEventListener(this);
    }

    private void initViews(){
        //状态栏颜色(透明,用系统的)
//        StatusBarUtil.setColor(this, Color.parseColor("#5d0e86"),255);
        //不需要导航栏
        setTitleVisible(View.GONE);

        //高斯模糊背景
//        iv_gaussianBlur = (SimpleDraweeView) findViewById(R.id.iv_gaussianBlur);
//        v_gaussianBlurFloat = findViewById(R.id.v_gaussianBlurFloat);
//        v_gaussianBlurFloat.setBackgroundDrawable(new ColorDrawable(Color.parseColor("#cc000000")));
        btnClose = (ImageView)findViewById(R.id.btnClose);

        //主播资料区域
        llAnchorInfo = (LinearLayout) findViewById(R.id.llAnchorInfo);
        civAnchorPhoto = (CircleImageView)findViewById(R.id.civAnchorPhoto);
        tvAnchorName = (TextView)findViewById(R.id.tvAnchorName);
        llAnchorFriendInfo = (LinearLayout)findViewById(R.id.llAnchorFriendInfo);
        civAnchorFriendPhoto = (CircleImageView)findViewById(R.id.civAnchorFriendPhoto);
        tvAnchorFriendName = (TextView)findViewById(R.id.tvAnchorFriendName);

        //描述及进度
        tvDesc = (TextView)findViewById(R.id.tvDesc);
        pb_waiting = (ProgressBar) findViewById(R.id.pb_waiting);

        //按钮区域
        btnRetry = (Button) findViewById(R.id.btnRetry);
        btnAddCredit = (Button) findViewById(R.id.btnAddCredit);
        llExistHangout = (LinearLayout) findViewById(R.id.llExistHangout);
        llNewHangout = (LinearLayout) findViewById(R.id.llNewHangout);

        btnClose.setOnClickListener(this);
        btnRetry.setOnClickListener(this);
        btnAddCredit.setOnClickListener(this);
        llExistHangout.setOnClickListener(this);
        llNewHangout.setOnClickListener(this);
    }

    public void initData(){
        Bundle bundle = getIntent().getExtras();
        if(bundle != null){
            if(bundle.containsKey(TRANSITION_ANCHOR_INFO)){
                mAnchorList = bundle.getParcelableArrayList(TRANSITION_ANCHOR_INFO);
            }
            if(bundle.containsKey(TRANSITION_ROOMID)){
                mRoomId = bundle.getString(TRANSITION_ROOMID);
            }
            if(bundle.containsKey(LIVEROOM_ROOMINFO_ROOMPHOTOURL)){
                mRoomPhotoUrl = bundle.getString(LIVEROOM_ROOMINFO_ROOMPHOTOURL);
                Log.d(TAG,"initData-mRoomPhotoUrl:"+mRoomPhotoUrl);
            }
            if(bundle.containsKey(TRANSITION_RECOMMAND_ID)){
                mRecommendId = bundle.getString(TRANSITION_RECOMMAND_ID);
                Log.d(TAG,"initData-TRANSITION_RECOMMAND_ID:" + mRecommendId);
            }
        }

        if (mAnchorList == null || mAnchorList.size() <= 0) {
            //无有效主播信息，无效请求
            finish();
        } else {
            //初始化背景信息
            initAnchorInfos(mAnchorList);
            //启动进入逻辑

            //720分辨率和系统版本大于5.0检测
            if(DisplayUtil.checkWhetherDpiHigh720(this) && android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP) {
                launchAndEnterHangoutRoom();
            }else{
                if(!DisplayUtil.checkWhetherDpiHigh720(this)){
                    onPageChange(PageType.PAAGE_NORMAL_ERROR, getResources().getString(R.string.hangout_system_low_dpi));
                }else{
                    onPageChange(PageType.PAAGE_NORMAL_ERROR, getResources().getString(R.string.hangout_system_low_lollipop));
                }
            }
        }
    }

    /**
     *  初始化主播信息
     */
    private void initAnchorInfos(List<IMUserBaseInfoItem> anchorList){
        if(anchorList != null && anchorList.size() > 0){
            if(anchorList.size() > 1){
                llAnchorFriendInfo.setVisibility(View.VISIBLE);
            }else{
                llAnchorFriendInfo.setVisibility(View.GONE);
            }

            IMUserBaseInfoItem anchorInfo = anchorList.get(0);
            if(anchorInfo != null ) {
                setAnchorInfo(tvAnchorName, civAnchorPhoto, anchorInfo.nickName,
                        anchorInfo.photoUrl, anchorInfo.userId);
            }

            if(anchorList.size() > 1){
                IMUserBaseInfoItem anchorFriendInfo = anchorList.get(1);
                if(anchorFriendInfo != null ) {
                    setAnchorInfo(tvAnchorFriendName, civAnchorFriendPhoto, anchorFriendInfo.nickName,
                            anchorFriendInfo.photoUrl, anchorFriendInfo.userId);
                }
            }
        }
    }

    private void setAnchorInfo(TextView textView, ImageView imageView,String nickName, String photoUrl, String userId){
        setAnchorIcon(imageView, photoUrl, userId);
        textView.setText(StringUtil.truncateSpecifiedLenString(nickName, ANCHOR_NAME_MAX_LEN));
    }

    private void setAnchorIcon(ImageView imageView,String photoUrl, String userId){
        if(!TextUtils.isEmpty(photoUrl)) {
            PicassoLoadUtil.loadUrl(imageView, photoUrl, R.drawable.ic_default_photo_woman);
        }else {
            imageView.setImageResource(R.drawable.ic_default_photo_woman);
            // 请求接口获取主播信息
            loadAnchorInfo(imageView, userId);
        }
    }

    /**
     * 获取主播详细信息
     * @param targetId
     */
    private void loadAnchorInfo(final ImageView imageView, final String targetId) {
        if (TextUtils.isEmpty(targetId)) {
            return;
        }

        LiveRequestOperator.getInstance().GetUserInfo(targetId, new OnGetUserInfoCallback() {
            @Override
            public void onGetUserInfo(boolean isSuccess, int errCode, String errMsg, final UserInfoItem userItem) {
                if (isSuccess && userItem != null && targetId.equals(userItem.userId)) {
                    imageView.post(new Runnable() {
                        @Override
                        public void run() {
                            setAnchorIcon(imageView, userItem.photoUrl,userItem.userId);
                        }
                    });
                }
            }
        });
    }

    /**
     *  启动过度页逻辑
     */
    private void launchAndEnterHangoutRoom(){
        if(!TextUtils.isEmpty(mRoomId)){
            //已有房间，走直接进入逻辑
            enterHangoutRoom(mRoomId, mAnchorList.get(0).nickName);
        }else{
            //更新状态，防止retry页面点击多次
            String message = String.format(getResources().getString(R.string.hangout_transition_inviting), mAnchorList.get(0).nickName);
            onPageChange(PageType.PAGE_LAUNCH_INVITING, message);
            //走邀请进入流程
            getUserHangoutStatus();
        }
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);
        int i = v.getId();
        if (i == R.id.btnClose) {
            exitLiveroomTransition();
        }  else if (i == R.id.btnAddCredit) {
            LiveModule.getInstance().onAddCreditClick(mContext, new NoMoneyParamsBean());
            //GA统计点击充值
            onAnalyticsEvent(getResources().getString(R.string.Live_Global_Category),
                    getResources().getString(R.string.Live_Global_Action_AddCredit),
                    getResources().getString(R.string.Live_Global_Label_AddCredit));
        }else if (i == R.id.btnRetry) {
            launchAndEnterHangoutRoom();
        }else if(i == R.id.llExistHangout){
            // 2019/4/16 Hardy  修改加载已有直播间的主播信息
            if (mExitRunningHangoutRoom == null || mExitRunningHangoutRoom.liveRoomAnchor == null
                    || mExitRunningHangoutRoom.liveRoomAnchor[0] == null) {
                ToastUtil.showToast(mContext,R.string.common_normal_newwork_error_tips);
                return;
            }

            HangoutAnchorInfoItem item = mExitRunningHangoutRoom.liveRoomAnchor[0];
            //重置，重启
            List<IMUserBaseInfoItem> anchorList = new ArrayList<IMUserBaseInfoItem>();
            anchorList.add(new IMUserBaseInfoItem(item.anchorId, item.nickName, item.photoUrl));

            //进入存在的直播间
            initAnchorInfos(anchorList);
            enterHangoutRoom(mExitRunningHangoutRoom.liveRoomId, item.nickName);
        }else if(i == R.id.llNewHangout){
            //开启新直播间，邀请进入
            createHangoutRoom();
        }
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

    @Override
    protected void onResume() {
        super.onResume();
        //清除后台超时事件
        removeUiMessages(EVENT_BACKGROUD_TIMEOUT);
        //处理切换到后台返回
        if(mIsBackgroudInRoomOut){
            //进入结束页
            finish();
        }else{
            //后台进入直播间成功
            if(mBackgroudEnterRoomSuccess){
                String roomId = mRoomId;
                if(TextUtils.isEmpty(roomId) && mCreatedHangoutRoom != null){
                    roomId = mCreatedHangoutRoom.roomId;
                }
                startEnterRoom(roomId);
            }
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        unRegisterListener();
        if(mHangoutInvitationManager != null){
            mHangoutInvitationManager.release();
        }
        //删除定时消息
        removeUiMessages(EVENT_OVERTIME_EVNET);
        removeUiMessages(EVENT_BACKGROUD_TIMEOUT);
    }

    /**
     * 主动退出逻辑
     */
    private void exitLiveroomTransition(){
//        //邀请中，尝试取消邀请
//        if(!TextUtils.isEmpty(mInvitationId)){
//            cancelHangoutInvitation(mInvitationId);
//        }
        //已有直播间，退出关闭直播间
        if(!TextUtils.isEmpty(mRoomId)){
            mIMManager.outHangOutRoomAndClearFlag(mRoomId);
        }
        //关闭创建的直播间
        if(mCreatedHangoutRoom != null && !TextUtils.isEmpty(mCreatedHangoutRoom.roomId)){
            mIMManager.outHangOutRoomAndClearFlag(mCreatedHangoutRoom.roomId);
        }

        finish();
    }

    /**
     * 获取会员hangout直播状态
     */
    private void getUserHangoutStatus(){
        LiveRequestOperator.getInstance().GetHangoutStatus(new OnGetHangoutStatusCallback() {
            @Override
            public void onGetHangoutStatus(final boolean isSuccess, final int errCode, String errMsg, final HangoutRoomStatusItem[] list) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        HttpLccErrType errType = IntToEnumUtils.intToHttpErrorType(errCode);
                        if(errType == HTTP_LCC_ERR_EXIST_HANGOUT){
                            if(list != null && list.length > 0){
                                HangoutRoomStatusItem item = list[0];
                                if(item != null && item.liveRoomAnchor != null && item.liveRoomAnchor.length > 0){
                                    mExitRunningHangoutRoom = item;
                                    //转到已存在进行中的hangout直播间错误页
                                    String message = String.format(getResources().getString(R.string.hangout_transition_exist_room), item.liveRoomAnchor[0].nickName);
                                    onPageChange(PageType.PAGE_EXIST_HANGOUT_ROOM, message);
                                }else{
                                    //无正在进行的hangout直播间或直播间内无主播（用户创建直播间成功邀请失败）
                                    createHangoutRoom();
                                }
                            }else{
                                //无正在进行的hangout直播间
                                createHangoutRoom();
                            }
                        }else{
                            //直接走创建直播间，邀请逻辑
                            createHangoutRoom();
                        }
                    }
                });
            }
        });
    }

    /**
     * 创建hangout直播间
     */
    private void createHangoutRoom(){
        String message = String.format(getResources().getString(R.string.hangout_transition_inviting), mAnchorList.get(0).nickName);
        onPageChange(PageType.PAGE_LAUNCH_INVITING, message);
        mIMManager.createHangoutRoom();
    }

    /**
     * 进入hangout直播间
     * @param roomId
     * @param anchorName
     */
    private void  enterHangoutRoom(String roomId, String anchorName){
        String message = String.format(getResources().getString(R.string.hangout_transition_inviting), anchorName);
        onPageChange(PageType.PAGE_LAUNCH_INVITING, message);
        mIMManager.enterHangoutRoom(roomId);
    }

//    /**
//     * 发起hangout直播间邀请
//     * @param roomId
//     * @param anchorId
//     * @param recommendId
//     */
//    private void startHangoutInvitation(String roomId, String anchorId, String recommendId){
//        LiveRequestOperator.getInstance().SendInvitationHangout(roomId, anchorId, recommendId, false, new OnSendInvitationHangoutCallback() {
//            @Override
//            public void onSendInvitationHangout(boolean isSuccess, int errCode, String errMsg, String roomId, String inviteId, int expire) {
//                if(isSuccess){
//                    mInvitationId = inviteId;
//                }else{
//                    onHttpError(errCode, errMsg);
//                }
//            }
//        });
//    }

//    /**
//     *  取消hangout邀请
//     */
//    private void cancelHangoutInvitation(String invitationId){
//        LiveRequestOperator.getInstance().CancelHangoutInvit(invitationId, new OnRequestCallback() {
//            @Override
//            public void onRequest(boolean isSuccess, int errCode, String errMsg) {
//
//            }
//        });
//    }

    /**
     * 统一处理IM错误
     * @param errType
     * @param errMsg
     */
    private void onIMError(IMClientListener.LCC_ERR_TYPE errType, String errMsg){
        switch (errType){
            case LCC_ERR_CONNECTFAIL:{
                //断网，可重新尝试
                onPageChange(PageType.PAGE_CONNECTFAIL_RETRY, errMsg);
            }break;
            case LCC_ERR_NO_CREDIT:{
                //信用点不足
                String message = String.format(getResources().getString(R.string.hangout_transition_add_credit), tvAnchorName.getText().toString());
                onPageChange(PageType.PAGE_ADD_CREDIT, message);
            }break;
            default:{
                onPageChange(PageType.PAAGE_NORMAL_ERROR, errMsg);
            }break;
        }
    }

    private void onHttpError(int errCode, String errMsg){
        HttpLccErrType httpLccErrType = IntToEnumUtils.intToHttpErrorType(errCode);
        switch (httpLccErrType){
            case HTTP_LCC_ERR_CONNECTFAIL:{
                //断网，可重新尝试
                onPageChange(PageType.PAGE_CONNECTFAIL_RETRY, errMsg);
            }break;
            case HTTP_LCC_ERR_NO_CREDIT:{
                //信用点不足
                String message = String.format(getResources().getString(R.string.hangout_transition_add_credit), tvAnchorName.getText().toString());
                onPageChange(PageType.PAGE_ADD_CREDIT, message);
            }break;
            default:{
                onPageChange(PageType.PAAGE_NORMAL_ERROR, errMsg);
            }break;
        }
    }

    /**
     * 根据指定page类型改变界面显示状态
     * @param pageType
     * @param message
     */
    private void onPageChange(final PageType pageType,final String message){
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                tvDesc.setText(message);
                resetButtonStatus();
                switch (pageType){
                    case PAAGE_NORMAL_ERROR:{
                        //普通错误，无法操作，停掉所有监听事件
                        unRegisterListener();
                    }break;
                    case PAGE_ADD_CREDIT:{
                        btnAddCredit.setVisibility(View.VISIBLE);
                    }break;
                    case PAGE_LAUNCH_INVITING:{
                        pb_waiting.setVisibility(View.VISIBLE);
                    }break;
                    case PAGE_CONNECTFAIL_RETRY:{
                        btnRetry.setVisibility(View.VISIBLE);
                    }break;
                    case PAGE_EXIST_HANGOUT_ROOM:{
                        llExistHangout.setVisibility(View.VISIBLE);
                        llNewHangout.setVisibility(View.VISIBLE);
                    }break;
                }
                /**
                 * 处理界面180秒逻辑
                 */
                removeUiMessages(EVENT_OVERTIME_EVNET);
                if(pageType == PageType.PAGE_LAUNCH_INVITING) {
                    //启动180秒超时逻辑
                    sendEmptyUiMessageDelayed(EVENT_OVERTIME_EVNET, PAGE_REQUEST_MAX_TIMEOUT);
                }else{
                    if(mHangoutInvitationManager != null) {
                        mHangoutInvitationManager.stopInvite();
                    }
                }
            }
        });
    }

    /**
     * 重置界面错误按钮及进度区域
     */
    private void resetButtonStatus(){
        pb_waiting.setVisibility(View.GONE);
        btnRetry.setVisibility(View.GONE);
        btnAddCredit.setVisibility(View.GONE);
        llExistHangout.setVisibility(View.GONE);
        llNewHangout.setVisibility(View.GONE);
    }

    /**
     * 启动多人互动直播间
     * @param roomId
     */
    private void startEnterRoom(String roomId){
        //判断当前是否后台，后台时统一不跳转（解决5.0以下startActivity会在后台打开页面，但是5.0以上会将应用带到前台），在resume处理超出1分钟停止，否则进入直播间
        if(SystemUtils.isBackground(this)){
            mBackgroudEnterRoomSuccess = true;
            //启动后台定时停止计时
            sendEmptyUiMessageDelayed(EVENT_BACKGROUD_TIMEOUT, BACKGROUD_LIVE_OVERTIME_TIMESTAMP);
        }else {
            checkPrivateRoomPermissions(roomId);
        }
    }

    /**
     * hangout直播权限检查
     */
    private void checkPrivateRoomPermissions(final String roomId){
        PermissionManager permissionManager = new PermissionManager(mContext, new PermissionManager.PermissionCallback() {
            @Override
            public void onSuccessful() {
                doStartActivity(roomId);
            }

            @Override
            public void onFailure() {
                doStartActivity(roomId);
            }
        });

        permissionManager.requestVideo();
    }

    /**
     * 启动直播间
     * @param roomId
     */
    private void doStartActivity(String roomId){
        Intent intent = new Intent(mContext, HangOutLiveRoomActivity.class);
        HangoutAnchorInfoItem extraAnchor = null;
        if(mAnchorList != null && mAnchorList.size() > 1){
            IMUserBaseInfoItem userItem = mAnchorList.get(1);
            extraAnchor = new HangoutAnchorInfoItem();
            extraAnchor.anchorId = userItem.userId;
            extraAnchor.nickName = userItem.nickName;
            extraAnchor.photoUrl = userItem.photoUrl;
        }
        if (null != intent) {
            intent.putExtra(LiveRoomTransitionActivity.LIVEROOM_ROOMINFO_ID, roomId);    //只传入房间ID为了解决:BUG#14463 add by Jagger 2019-1-17
            intent.putExtra(LiveRoomTransitionActivity.LIVEROOM_ROOMINFO_ROOMPHOTOURL, mRoomPhotoUrl);
            if(extraAnchor != null){
                intent.putExtra(TRANSITION_EXTRA_ANCHOR_ID, extraAnchor);
            }
            startActivity(intent);
        }
        finish();
    }

    /*************************************************  主逻辑外的分之逻辑   *******************************************************/

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        switch (msg.what){
            case EVENT_OVERTIME_EVNET:{
                String message = String.format(getResources().getString(R.string.hangout_transition_reject_or_timeout), tvAnchorName.getText().toString());
                onPageChange(PageType.PAAGE_NORMAL_ERROR, message);
            }break;
            case EVENT_BACKGROUD_TIMEOUT:{
                mIsBackgroudInRoomOut = true;
                //后台退出直播间
                exitLiveroomTransition();
            }break;
        }
    }

    /**************************************************  IM相关回调   *******************************************************/
    @Override
    public void OnRecvRecommendHangoutNotice(IMHangoutRecommendItem item) {

    }

    @Override
    public void OnRecvDealInvitationHangoutNotice(final IMDealInviteItem item) {
//        runOnUiThread(new Runnable() {
//            @Override
//            public void run() {
//                switch (item.type){
//                    case Agree:{
//                        //接受，进入直播间
//                        startEnterRoom(item.roomId);
//                    }break;
//                    case Reject:
//                    case OutTime:{
//                        String message = String.format(getResources().getString(R.string.hangout_transition_reject_or_timeout), tvAnchorName.getText().toString());
//                        onPageChange(PageType.PAAGE_NORMAL_ERROR, message);
//                    }break;
//                    case NoCredit:{
//                        String message = String.format(getResources().getString(R.string.hangout_transition_add_credit), tvAnchorName.getText().toString());
//                        onPageChange(PageType.PAGE_ADD_CREDIT, message);
//                    }break;
//                    case Busy:{
//                        onPageChange(PageType.PAAGE_NORMAL_ERROR, getResources().getString(R.string.hangout_anchor_busy));
//                    }break;
//                }
//            }
//        });
    }

    @Override
    public void OnEnterHangoutRoom(int reqId, final boolean success, final IMClientListener.LCC_ERR_TYPE errType, final String errMsg, final IMHangoutRoomItem item) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if(success){
                    if(item != null && item.livingAnchorList != null && item.livingAnchorList.size() >0){
                        //直接进入直播间
                        startEnterRoom(item.roomId);
                    }else{
                        mCreatedHangoutRoom = item;
                        //发起邀请，等待应邀进入直播间
//                        startHangoutInvitation(item.roomId, mAnchorList.get(0).userId, mRecommendId);
                        mHangoutInvitationManager.startInvitationSession(mAnchorList.get(0), item.roomId, mRecommendId, false);
                    }
                }else{
                    onIMError(errType, errMsg);
                }
            }
        });
    }

    @Override
    public void OnLeaveHangoutRoom(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnRecvEnterHangoutRoomNotice(IMRecvEnterRoomItem item) {

    }

    @Override
    public void OnRecvLeaveHangoutRoomNotice(IMRecvLeaveRoomItem item) {

    }

    @Override
    public void OnSendHangoutGift(boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMMessageItem item, double credit) {

    }

    @Override
    public void OnRecvHangoutGiftNotice(IMMessageItem item) {

    }

    @Override
    public void OnRecvKnockRequestNotice(IMRecvKnockRequestItem item) {

    }

    @Override
    public void OnRecvLackCreditHangoutNotice(IMRecvLeaveRoomItem item) {

    }

    @Override
    public void OnControlManPushHangout(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, String[] manPushUrl) {

    }

    @Override
    public void OnSendHangoutRoomMsg(boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMMessageItem item) {

    }

    @Override
    public void OnRecvHangoutRoomMsg(IMMessageItem item) {

    }

    @Override
    public void OnRecvAnchorCountDownEnterHangoutRoomNotice(IMHangoutCountDownItem item) {

    }

    @Override
    public void OnRecvHandoutInviteNotice(IMHangoutInviteItem item) {

    }

    @Override
    public void OnRecvHangoutCreditRunningOutNotice(String roomId, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    /***************************************************  邀请管理器通知  *****************************************************/
    @Override
    public void onHangoutInvitationStart(IMUserBaseInfoItem userBaseInfoItem) {

    }

    @Override
    public void onHangoutInvitationFinish(boolean isSuccess, HangoutInvitationManager.HangoutInvationErrorType errorType, String errMsg, IMUserBaseInfoItem userBaseInfoItem, String roomId) {
        if(isSuccess){
            mRoomId = roomId;
            startEnterRoom(roomId);
        }else{
            switch (errorType){
                case ConnectFail:{
                    onPageChange(PageType.PAGE_CONNECTFAIL_RETRY, errMsg);
                }break;
                case NoCredit:{
                    onPageChange(PageType.PAGE_ADD_CREDIT, errMsg);
                }break;
                case NormalError:{
                    onPageChange(PageType.PAAGE_NORMAL_ERROR, errMsg);
                }break;
            }
        }
    }

    @Override
    public void onHangoutCancel(boolean isSuccess, int httpErrCode, String errMsg) {

    }
}
