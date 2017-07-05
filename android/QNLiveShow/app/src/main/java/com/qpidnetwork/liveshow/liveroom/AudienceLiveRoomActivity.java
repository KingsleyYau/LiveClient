package com.qpidnetwork.liveshow.liveroom;


import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Message;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.SurfaceView;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.Toast;

import com.qpidnetwork.httprequest.OnGetAllGiftCallback;
import com.qpidnetwork.httprequest.item.GiftItem;
import com.qpidnetwork.im.IMManager;
import com.qpidnetwork.im.listener.IMClientListener;
import com.qpidnetwork.im.listener.IMMessageItem;
import com.qpidnetwork.im.listener.IMRoomInfoItem;
import com.qpidnetwork.liveshow.R;
import com.qpidnetwork.liveshow.liveroom.gift.dialog.LiveGiftDialog;
import com.qpidnetwork.liveshow.liveroom.gift.dialog.OnLiveGiftSentListener;
import com.qpidnetwork.liveshow.liveroom.gift.downloader.FileDownloadManager;
import com.qpidnetwork.liveshow.liveroom.gift.downloader.IFileDownloadedListener;
import com.qpidnetwork.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.liveshow.model.http.IMRespObject;
import com.qpidnetwork.utils.Log;
import com.qpidnetwork.view.SimpleDoubleBtnTipsDialog;

import net.qdating.LSPlayer;


/**
 * 用户直播间
 * Created by Hunter Mun on 2017/6/15.
 */

public class AudienceLiveRoomActivity extends BaseCommonLiveRoomActivity  {

    //避免和基类冲突，Audience 以 2*** 格式
    private static final int EVENT_AUDIENCE_ROOMIN = 2001;
    private static final int EVENT_GET_GIFT_CONFIG = 2002;
    private static final int EVENT_AUDIENCE_ROOMOUT = 2003;
    private static final int EVENT_AUDIENCE_ROOMEND = 2004;
    private static final int EVNET_CONINS_UPDATE = 2005;

    //View
    private FrameLayout fl_buttom_audience;

    //礼物列表
    private LiveGiftDialog liveGiftDialog;

    //data
    private IMRoomInfoItem mIMRoomInfoItem;         //观众端直播间信息

    //播放器
    private SurfaceView sv_player;
    private LSPlayer player = null;

    public static Intent getIntent(Context context, String roomId){
        Intent intent = new Intent(context, AudienceLiveRoomActivity.class);
        intent.putExtra(BaseCommonLiveRoomActivity.LIVEROOM_ROOM_ID, roomId);
        return intent;
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initAudienceViews();
        initAudienceData();
    }

    private void initAudienceViews(){
        findViewById(R.id.include_audience_area).setVisibility(View.VISIBLE);
        fl_buttom_audience = (FrameLayout) findViewById(R.id.fl_buttom_audience);
        fl_buttom_audience.setVisibility(View.VISIBLE);

        //视频播放
        sv_player = (SurfaceView)findViewById(R.id.sv_player);
        player = new LSPlayer();
        player.init(sv_player);
        player.PlayUrl("rtmp://172.25.32.17:1936/aac/hunter", "", "", "");
    }

    private void initAudienceData(){
        audienceRoomIn();
        initLiveGiftDialog();

        //临时逻辑，获取礼物配置
        mIMManager.getAllGiftConfig(new OnGetAllGiftCallback() {
            @Override
            public void onGetAllGift(boolean isSuccess, int errCode, String errMsg, GiftItem[] giftList) {
                Message msg = Message.obtain();
                msg.what = EVENT_GET_GIFT_CONFIG;
                msg.obj = new HttpRespObject(isSuccess, errCode, errMsg, giftList);
                sendUiMessage(msg);
            }
        });
    }

    /**
     * 预下载大礼物文件
     * @param giftList
     */
    private void preDownAdvanceGiftImage(GiftItem[] giftList){

        FileDownloadManager fdmanager = FileDownloadManager.getInstance();
        for(GiftItem giftItem : giftList){
            if(giftItem.giftType == GiftItem.GiftType.AdvancedAnimation){
                Log.d(TAG, "preDownAdvanceGiftImage-giftItem.srcUrl:"+giftItem.srcUrl);
                fdmanager.start(giftItem.id, giftItem.srcUrl , iFileDownloadedListener);
            }
        }
    }

    private IFileDownloadedListener iFileDownloadedListener = new IFileDownloadedListener() {
        @Override
        public void onCompleted(String localFilePath, String fileId, String fileUrl) {
            Log.d(TAG,"onCompleted-localFilePath:"+localFilePath+" fileId:"+fileId+" fileUrl:"+fileUrl);
        }
    };

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if(player != null){
            player.Stop();
        }
    }

    /**
     * 进入直播间
     */
    private void audienceRoomIn(){
        if(mIMManager.audienceRoomIn(mRoomId) != IMManager.IM_INVALID_REQID){
            showCustomDialog(0,0,R.string.liveroom_audience_roomin_processing,false,false,null);
        }else{
            showToast("IM roomin failed");
        }
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        switch (msg.what){
            case EVENT_AUDIENCE_ROOMIN:{
                //观众进入直播间
                dismissCustomDialog();
                IMRespObject response = (IMRespObject)msg.obj;
                if(response.isSuccess){
                    //进入直播间成功
                    mIMRoomInfoItem = (IMRoomInfoItem)response.data;
                }else{
                    showToast(response.errMsg);
                }
            }break;
            case EVENT_GET_GIFT_CONFIG:{
                HttpRespObject response = (HttpRespObject)msg.obj;
                if(response.isSuccess){
                    GiftItem[] giftItems = (GiftItem[])response.data;
                    if(giftItems != null){
                        showToast("Get Gift config success");
                        liveGiftDialog.setGiftItems(giftItems);
                        //预下载
                        preDownAdvanceGiftImage(giftItems);
                    }
                }else{
                    showToast("Get Gift config failed: " + response.errMsg);
                }
            }break;
            case EVENT_AUDIENCE_ROOMOUT:{
                dismissCustomDialog();
                IMRespObject response = (IMRespObject)msg.obj;
                if(response.isSuccess){
                    //关闭当前界面
                    finish();
                }else{
                    showToast("EVENT_AUDIENCE_ROOMOUT: " + response.errMsg);
                }
            }break;
            case EVENT_AUDIENCE_ROOMEND:{
                //Olsen：用户端接收到主播结束直播的通知后，直接跳转到统计界面
//                showLiveEndDialog();
                Intent intent = new Intent(AudienceLiveRoomActivity.this, AudienceEndActivity.class);
                intent.putExtra("fansNum",msg.arg1);
                startActivity(intent);
                finish();
            }break;
            case EVNET_CONINS_UPDATE:{
                double coins = (Double)msg.obj;
                if(liveGiftDialog != null){
                    liveGiftDialog.setUserCoins(coins);
                }
            }break;
            default:
                break;
        }
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()){
            case R.id.btn_inputMsg: {
                fl_buttom_audience.setVisibility(View.GONE);
            }break;
            case R.id.iv_gift:{
                liveGiftDialog.show();
            }break;
            case R.id.iv_userShare: {
                userShare();
            }break;
            case R.id.civ_focus: {
                //关注主播
                focusHost();
            }break;
            case R.id.iv_closeLiveRoom:
                closeLiveRoom();
                break;
            default:
                break;
        }
        super.onClick(v);
    }

    @Override
    public void onSoftKeyboardHide() {
        super.onSoftKeyboardHide();
        fl_buttom_audience.setVisibility(View.VISIBLE);
    }

    /**
     * 用户端分享
     */
    private void userShare(){
        Toast.makeText(this, "userShare", Toast.LENGTH_SHORT).show();
    }

    /**
     * 关注主播，用户端的实现类，
     * 需要在调用关注接口成功后，通过super.focusHost()实现界面的交互响应
     */
    public void focusHost(){
//        v_bankFocus.setVisibility(View.VISIBLE);
//        civ_focus.setVisibility(View.GONE);
        Toast.makeText(this, getResources().getString(R.string.tip_focused), Toast.LENGTH_SHORT).show();
    }

    /**
     * 关闭直播间
     */
    public void closeLiveRoom(){
        if(mIMManager.audienceRoomOut(mRoomId) != IMManager.IM_INVALID_REQID){
            showCustomDialog(0,0,R.string.liveroom_anchor_roomout_processing,true,true,null);
        }else{
            Toast.makeText(this, "closeLiveRoom failed", Toast.LENGTH_SHORT).show();
        }
    }

    //用于端需发送点赞
    @Override
    public void sendLike() {
        //礼物列表在时，拦截点赞点击
        if(!liveGiftDialog.isShowing()) {
            //调用点赞接口点赞
            IMMessageItem msgItem = mIMManager.sendLikeEvent(mRoomId);
            //由底层判断是否第一次点赞，第一次点赞提示
            if(msgItem != null){
                updateMsgList(msgItem);
            }
            //通知界面播放动画
            sendLikeEvent();
        }
    }

    //部分事件分开主播和观众端分开处理
    @Override
    public void OnFansRoomIn(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMRoomInfoItem roomInfo) {
        super.OnFansRoomIn(reqId, success, errType, errMsg, roomInfo);
        Message msg = Message.obtain();
        msg.what = EVENT_AUDIENCE_ROOMIN;
        msg.obj = new IMRespObject(reqId, success, errType, errMsg, roomInfo);
        sendUiMessage(msg);

    }

    @Override
    public void OnFansRoomOut(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
        super.OnFansRoomOut(reqId, success, errType, errMsg);
        Message msg = Message.obtain();
        msg.what = EVENT_AUDIENCE_ROOMOUT;
        msg.obj = new IMRespObject(reqId, success, errType, errMsg, null);
        sendUiMessage(msg);
    }

    /**
     * 用户收到房间关闭通知
     * @param roomId
     * @param userId
     * @param nickName
     * @param fansNum
     */
    @Override
    public void OnRecvRoomCloseFans(String roomId, String userId, String nickName, int fansNum) {
        super.OnRecvRoomCloseFans(roomId, userId, nickName, fansNum);
        if(!TextUtils.isEmpty(roomId) && roomId.equals(mRoomId)) {
            Message msg = Message.obtain();
            msg.what = EVENT_AUDIENCE_ROOMEND;
            msg.arg1 = fansNum;
            sendUiMessage(msg);
        }
    }

    @Override
    public void OnCoinsUpdate(double coins) {
        super.OnCoinsUpdate(coins);
        Message msg = Message.obtain();
        msg.what = EVNET_CONINS_UPDATE;
        msg.obj = Double.valueOf(coins);
        sendUiMessage(msg);
    }

    /*********************************** 底部礼物列表展示  ******************************/
    /**
     * 初始化底部礼物选择界面
     */
    private void initLiveGiftDialog(){
        liveGiftDialog = new LiveGiftDialog(this);
        liveGiftDialog.setOnOutSideTouchEventListener(new LiveGiftDialog.OnOutSideTouchEventListener() {
            @Override
            public void onOutSideTouchEvent() {
            }
        });
        liveGiftDialog.setLiveGiftSentListener(new OnLiveGiftSentListener() {
            @Override
            public void onGiftSent(GiftItem giftItem, boolean isMultiClick, int multi_click_start, int multi_click_end, int multiClickId) {
                //点击发送回调
                sendGift(giftItem, isMultiClick, multi_click_start, multi_click_end, multiClickId);
            }
        });
        Window window = liveGiftDialog.getWindow();
        window.setGravity(Gravity.BOTTOM);
        //获得window窗口的属性
        android.view.WindowManager.LayoutParams lp = window.getAttributes();
        //设置窗口宽度为充满全屏
        lp.width = WindowManager.LayoutParams.MATCH_PARENT;
        //设置窗口高度为包裹内容
        lp.height = WindowManager.LayoutParams.WRAP_CONTENT;
        window.setAttributes(lp);
    }

    /**
     * 发送礼物
     * @param giftItem
     * @param start
     * @param end
     */
    private void sendGift(GiftItem giftItem, boolean isMultiClick, int start, int end, int multiClickId){
        if(end >= start && giftItem != null && !TextUtils.isEmpty(giftItem.id)){
            //有效发送
            int count = end - start + 1;
            IMMessageItem msgItem = mIMManager.sendGift(mRoomId, giftItem, count,
                    isMultiClick, start, end, multiClickId);
            if(mModuleGiftManager != null){
                mModuleGiftManager.dispatchIMMessage(msgItem);
            }

        }else{
            Log.i(TAG, "sendGift valid start:%d, end:%d", start, end);
        }
    }

    private void showLiveEndDialog(){
        showCustomDialog(0, R.string.txt_ok, R.string.tip_sureToCloseRoom,
                true, true, android.R.color.white, android.R.color.white,
                R.drawable.bg_custom_dialog_confirm, R.drawable.bg_custom_dialog_cancel,
                new SimpleDoubleBtnTipsDialog.OnTipsDialogBtnClickListener() {
                    @Override
                    public void onCancelBtnClick() {
                        dismissCustomDialog();
                    }

                    @Override
                    public void onConfirmBtnClick() {
                        dismissCustomDialog();
                        Intent intent = new Intent(AudienceLiveRoomActivity.this, AudienceEndActivity.class);
                        startActivity(intent);
                        finish();
                    }
                });
    }
}
