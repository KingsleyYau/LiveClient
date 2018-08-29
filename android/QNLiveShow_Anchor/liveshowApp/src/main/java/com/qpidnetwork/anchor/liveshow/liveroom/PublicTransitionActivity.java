package com.qpidnetwork.anchor.liveshow.liveroom;

import android.content.Intent;
import android.opengl.GLSurfaceView;
import android.os.Bundle;
import android.os.Message;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.RelativeLayout;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.anchor.httprequest.LiveRequestOperator;
import com.qpidnetwork.anchor.httprequest.OnCheckPublicRoomTypeCallback;
import com.qpidnetwork.anchor.httprequest.OnRequestCallback;
import com.qpidnetwork.anchor.httprequest.item.IntToEnumUtils;
import com.qpidnetwork.anchor.httprequest.item.LiveRoomType;
import com.qpidnetwork.anchor.httprequest.item.PublicRoomType;
import com.qpidnetwork.anchor.httprequest.item.SetAutoPushType;
import com.qpidnetwork.anchor.im.IMInviteLaunchEventListener;
import com.qpidnetwork.anchor.im.IMManager;
import com.qpidnetwork.anchor.im.listener.IMClientListener;
import com.qpidnetwork.anchor.im.listener.IMInviteListItem;
import com.qpidnetwork.anchor.im.listener.IMRoomInItem;
import com.qpidnetwork.anchor.utils.DisplayUtil;
import com.qpidnetwork.anchor.utils.Log;

import static com.qpidnetwork.anchor.liveshow.liveroom.LiveRoomTransitionActivity.LIVEROOM_ROOMINFO_ITEM;

/**
 * Description:公开直播间过度界面
 * 0.首页点击中间的开播按钮即跳转该界面
 * 1.对接max的camera时，初始化完成前界面需要loading，不得点击Start Broadcast Now
 * 2.Start Broadcast Now接口调用成功之后就需要释放掉camera，而不要等到onDestory才去释放
 * 3.界面整体可以上下滚动
 * <p>
 * Created by Harry on 2018/3/6.
 */

public class PublicTransitionActivity extends BaseActionBarFragmentActivity implements IMInviteLaunchEventListener {

    private ImageView iv_vedioBg;
    private GLSurfaceView sv_push;
    private ImageView iv_autoinvit;
    private Button btn_startPublicLive;
    private ImageView iv_close;
    private boolean hasReq2StartPublicLive = false;
    private boolean autoInvite = true;

    private boolean openCameraResult = false;
    private final int EVENT_OPENCAMERAPREVIEW = 10001;

    protected LiveStreamPushManager mLiveStreamPushManager;
    private IMManager mIMManager;
    private IMRoomInItem mIMRoomInItem;    //房间信息

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        TAG = PublicTransitionActivity.class.getName();
        setContentView(R.layout.activity_public_transition);
        initLoadingDialog();
        loadingDialog.setCancelable(false);
        loadingDialog.setCanceledOnTouchOutside(false);
        mIMManager = IMManager.getInstance();
        showLoadingDialog();
        initView();
        initLSPManager();
        hideLoadingDialog();
    }

    @Override
    protected void onResume() {
        super.onResume();
        initIMListener();
        if(btn_startPublicLive != null) {
            btn_startPublicLive.setClickable(true);
        }
        if(mLiveStreamPushManager != null && !mLiveStreamPushManager.isCameraPreviewOpen()){
            openCameraPreview();
        }
    }

    /**
     * 初始化IM底层相关
     */
    private void initIMListener(){
        mIMManager.registerIMInviteLaunchEventListener(this);
    }

    private void initView(){
        iv_close = (ImageView) findViewById(R.id.iv_close);
        iv_close.setOnClickListener(this);
        iv_vedioBg = (ImageView) findViewById(R.id.iv_vedioBg);
        iv_vedioBg.setVisibility(View.GONE);
        sv_push = (GLSurfaceView) findViewById(R.id.sv_push);
        //视频预览界面宽度高度比例为1:1
        int width = DisplayUtil.getScreenWidth(this);
        RelativeLayout.LayoutParams vedioBgLP = (RelativeLayout.LayoutParams) iv_vedioBg.getLayoutParams();
        vedioBgLP.width = width;
        vedioBgLP.height = width;
        RelativeLayout.LayoutParams vedioPlayerLP = (RelativeLayout.LayoutParams) sv_push.getLayoutParams();
        vedioPlayerLP.width = width;
        vedioPlayerLP.height = width;

        iv_autoinvit = (ImageView) findViewById(R.id.iv_autoinvit);
        iv_autoinvit.setOnClickListener(this);
        //默认选中
        changeAutoInviSwitchStatus(autoInvite);

        btn_startPublicLive = (Button) findViewById(R.id.btn_startPublicLive);
        btn_startPublicLive.setOnClickListener(this);
    }

    /**
     * 初始化推流器并开启预览
     */
    private void initLSPManager(){
        mLiveStreamPushManager = new LiveStreamPushManager(this);
        mLiveStreamPushManager.init(sv_push);
        openCameraPreview();
    }

    private void openCameraPreview(){
        //先清除旧的，再开启新的
        removeUiMessages(EVENT_OPENCAMERAPREVIEW);
        openCameraResult = mLiveStreamPushManager.openCameraPreview();
        Log.d(TAG,"openCameraPreview-openCameraResult:"+openCameraResult);
        if(!openCameraResult){
            sendEmptyUiMessageDelayed(EVENT_OPENCAMERAPREVIEW,1000l);
        }
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK && event.getAction() == KeyEvent.ACTION_DOWN) {
            Log.d(TAG,"onKeyDown-返回键触发界面销毁");
            closeCameraPreviewAndFinish();
            return false;
        }
        return super.onKeyDown(keyCode, event);
    }

    private void closeCameraPreviewAndFinish(){
        Log.d(TAG,"closeCameraPreviewAndFinish");
        removeUiMessages(EVENT_OPENCAMERAPREVIEW);
        //用户主播关闭时设置surfaceview为不可见，避免huawei nexus 6p手机上会闪一下黑框
        sv_push.setVisibility(View.INVISIBLE);
        if (mLiveStreamPushManager != null) {
            mLiveStreamPushManager.closeCameraPreview();
        }
        finish();
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        switch (msg.what){
            case EVENT_OPENCAMERAPREVIEW:
                openCameraPreview();
                break;
            default:
                break;
        }

    }

    @Override
    public void onClick(View v) {
        super.onClick(v);
        switch (v.getId()){
            case R.id.iv_close:
                closeCameraPreviewAndFinish();
                break;
            case R.id.iv_autoinvit:
                changeAutoInviSwitchStatus(!autoInvite);
                break;
            case R.id.btn_startPublicLive:
                if(!hasReq2StartPublicLive){
                    hasReq2StartPublicLive = true;
                    showLoadingDialog();
//                    startPublicLive();
                    checkProgarmStatus();
                }
                break;
        }
    }

    private void changeAutoInviSwitchStatus(boolean isAutoInvite){
        Log.d(TAG,"changeAutoInviSwitchStatus-isAutoInvite:"+isAutoInvite);
        iv_autoinvit.setSelected(isAutoInvite);
        autoInvite = isAutoInvite;
    }

    private void startPublicLive(){
        Log.d(TAG,"startPublicLive-hasReq2StartPublicLive:"+hasReq2StartPublicLive);
        LiveRequestOperator.getInstance().SetAutoPush(autoInvite ? SetAutoPushType.START : SetAutoPushType.CLOSE, new OnRequestCallback() {
            @Override
            public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                Log.d(TAG,"startPublicLive-onRequest isSuccess:"+isSuccess+" errCode:"+errCode+" errMsg:"+errMsg);
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        mIMManager.PublicRoomIn();
                    }
                });
            }
        });
    }

    @Override
    public void OnRoomIn(int reqId, final boolean success, final IMClientListener.LCC_ERR_TYPE errType,
                         final String errMsg, final IMRoomInItem roomInfo) {
        Log.d(TAG,"OnRoomIn-reqId:"+reqId+" success:"+success+" errType:"+errType+" errMsg:"+errMsg+" roomInfo:"+roomInfo);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                hasReq2StartPublicLive = false;
                hideLoadingDialog();
                if(success){
                    btn_startPublicLive.setClickable(false);
                    mIMRoomInItem = roomInfo;
                    if (mLiveStreamPushManager != null) {
                        mLiveStreamPushManager.closeCameraPreview();
                    }
                    Intent intent = new Intent(PublicTransitionActivity.this, PublicLiveRoomActivity.class);
                    intent.putExtra(LIVEROOM_ROOMINFO_ITEM, mIMRoomInItem);
                    startActivity(intent);
                    finish();
                }else{
                    if(!TextUtils.isEmpty(errMsg)){
                        showToast(errMsg);
                    }else if(errType == IMClientListener.LCC_ERR_TYPE.LCC_ERR_CONNECTFAIL){
                        showToast(R.string.liveroom_transition_audience_invite_network_error);
                    }

                }
            }
        });
    }

    private void clearIMListener(){
        if(null != mIMManager){
            mIMManager.unregisterIMInviteLaunchEventListener(this);
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        clearIMListener();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        removeUiMessages(EVENT_OPENCAMERAPREVIEW);
        //回收拉流播放器-保证资源被完全释放
        releaseLSPManager();
    }

    /**
     * 释放推流器
     */
    private void releaseLSPManager() {
        if (mLiveStreamPushManager != null) {
            mLiveStreamPushManager.closeCameraPreview();
            mLiveStreamPushManager.release();
            mLiveStreamPushManager = null;
        }
    }

    /**************************** 检测是否有节目即将开播 ****************************************/
    /**
     * 检测主播是否有节目即将开播
     */
    private void checkProgarmStatus(){
        LiveRequestOperator.getInstance().CheckPublicRoomType(new OnCheckPublicRoomTypeCallback() {
            @Override
            public void onCheckPublicRoomType(final boolean isSuccess, final int errCode, final String errMsg, final int liveShowType, final String liveShowId) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if(isSuccess){
                            if(IntToEnumUtils.intToPublicRoomType(liveShowType) == PublicRoomType.Program){
                                //节目，跳转节目过渡页
                                hasReq2StartPublicLive = false;
                                hideLoadingDialog();
//                              //禁用点击事件，防止跳转过程中可点击
                                btn_startPublicLive.setClickable(false);
                                //关闭预览解决Camera检测异常
                                if (mLiveStreamPushManager != null) {
                                    mLiveStreamPushManager.closeCameraPreview();
                                }
                                mContext.startActivity(ProgramLiveTransitionActivity.getProgramIntent(
                                        mContext, liveShowId));
                            }else{
                                //打开公开直播间
                                startPublicLive();
                            }
                        }else{
                            hasReq2StartPublicLive = false;
                            hideLoadingDialog();
                            showToast(errMsg);
                        }
                    }
                });
            }
        });
    }

    //----------------------------------多余的-----------------------
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
