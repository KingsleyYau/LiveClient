package com.qpidnetwork.livemodule.liveshow.liveroom;


import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Message;
import android.text.TextUtils;
import android.view.SurfaceView;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.RelativeLayout;
import android.widget.Toast;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.OnGetSendableGiftListCallback;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.httprequest.item.SendableGiftItem;
import com.qpidnetwork.livemodule.im.IMGiftManager;
import com.qpidnetwork.livemodule.im.IMManager;
import com.qpidnetwork.livemodule.im.listener.IMClientListener;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.Gift;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.GiftSendReqManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.GiftSender;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.Pack;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.dialog.LiveGiftDialog;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.downloader.IFileDownloadedListener;
import com.qpidnetwork.livemodule.liveshow.model.http.IMRespObject;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.Log;
import com.qpidnetwork.livemodule.utils.TestDataUtil;
import com.qpidnetwork.livemodule.view.SimpleDoubleBtnTipsDialog;

import net.qdating.LSPlayer;

import java.util.ArrayList;
import java.util.List;


/**
 * 用户直播间
 * Created by Hunter Mun on 2017/6/15.
 */

public class AudienceLiveRoomActivity extends BaseCommonLiveRoomActivity
        implements OnGetSendableGiftListCallback,
        IMGiftManager.OnGetAllBackpackGiftListener {

    //避免和基类冲突，Audience 以 2*** 格式
    private static final int EVENT_AUDIENCE_ROOMIN = 2001;
    private static final int EVENT_AUDIENCE_ROOMOUT = 2003;
    private static final int EVENT_AUDIENCE_ROOMEND = 2004;
    private static final int EVNET_CONINS_UPDATE = 2005;
    private static final int EVENT_GET_STOREGIFT_SUCCESS=2017;
    private static final int EVENT_GET_BACKPACKGIFT_SUCCESS =2018;

    //View
    private FrameLayout fl_buttom_audience;

    //礼物列表
    private LiveGiftDialog liveGiftDialog;

    //data
    private IMRoomInItem mIMRoomInfoItem;         //观众端直播间信息

    //播放器
    private SurfaceView sv_player;
    private LSPlayer player = null;

    public static Intent getIntent(Context context, String roomId){
        Intent intent = new Intent(context, AudienceLiveRoomActivity.class);
        intent.putExtra(BaseCommonLiveRoomActivity.LIVEROOM_ROOM_ID, roomId);
        return intent;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initAudienceViews();
        initAudienceData();
        GiftSendReqManager.getInstance().executeNextReqTask();
    }

    private void initAudienceViews(){
        findViewById(R.id.include_audience_area).setVisibility(View.VISIBLE);
        fl_buttom_audience = (FrameLayout) findViewById(R.id.fl_buttom_audience);
        fl_buttom_audience.setVisibility(View.VISIBLE);

        //视频播放组件
        sv_player = (SurfaceView)findViewById(R.id.sv_player);
        int screenWidth = DisplayUtil.getScreenWidth(AudienceLiveRoomActivity.this);
        //具体的宽高比例，其实也可以根据服务器动态返回来控制
        RelativeLayout.LayoutParams svPlayerLp = new RelativeLayout.LayoutParams(
                screenWidth, screenWidth * 9/16);
        view_roomHeader.measure(0,0);
        int roomHeaderMeasuredHeight = view_roomHeader.getMeasuredHeight();
        Log.d(TAG,"initAudienceViews-roomHeaderMeasuredHeight:"+roomHeaderMeasuredHeight);
        svPlayerLp.topMargin = roomHeaderMeasuredHeight;
        sv_player.setLayoutParams(svPlayerLp);

        player = new LSPlayer();
        player.init(sv_player, null);
        player.playUrl("rtmp://172.25.32.17:1936/aac/hunter", "", "", "");
    }

    private void initAudienceData(){
        audienceRoomIn();
        initLiveGiftDialog();

        //获取房间可用礼物配置
        IMGiftManager.getInstance().getSendableGiftList(mRoomId,this);
        //获取背包配置
        IMGiftManager.getInstance().getAllBackpackGifts(this);
        GiftSender.getInstance().currRoomId = mRoomId;
        TestDataUtil.localCoins = 99.99d;
    }

    /**
     * 预下载大礼物文件-store
     */
    private void preDownGiftImage(Gift[] gifts){
        for(Gift gift : gifts){
            if(gift.giftItem.giftType == GiftItem.GiftType.Advanced){
                Log.d(TAG, "preDownGiftImage-giftItem.srcUrl:"+gift.giftItem.srcWebpUrl);
                IMGiftManager.getInstance()
                        .getGiftImage(gift.giftItem.id,
                                IMGiftManager.GiftImageType.Source, iFileDownloadedListener);
            }
        }
    }

    /**
     * 预下载大礼物文件-pack
     */
    private void preDownGiftImage(Pack[] packs){
        for(Pack pack : packs){
            if(pack.giftItem.giftType == GiftItem.GiftType.Advanced){
                Log.d(TAG, "preDownGiftImage-giftItem.srcUrl:"+pack.giftItem.srcWebpUrl);
                IMGiftManager.getInstance()
                        .getGiftImage(pack.giftItem.id,
                                IMGiftManager.GiftImageType.Source, iFileDownloadedListener);
            }
        }
    }

    private IFileDownloadedListener iFileDownloadedListener = new IFileDownloadedListener() {
        @Override
        public void onCompleted(boolean isSuccess, String localFilePath, String fileUrl) {
            Log.d(TAG,"onCompleted-localFilePath:"+localFilePath+" fileUrl:"+fileUrl);
        }
    };

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if(player != null){
            player.stop();
            player.uninit(); //防止内存泄漏
        }
        GiftSendReqManager.getInstance().shutDownReqQueueServNow();
    }

    /**
     * 进入直播间
     */
    private void audienceRoomIn(){
        if(mIMManager.RoomIn(mRoomId) != IMManager.IM_INVALID_REQID){
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
                    mIMRoomInfoItem = (IMRoomInItem)response.data;
                }else{
                    showToast(response.errMsg);
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
            case EVENT_GET_STOREGIFT_SUCCESS:
                Gift[] storeGifts = (Gift[])msg.obj;
                if(liveGiftDialog != null){
                    liveGiftDialog.setStoreGifts(storeGifts);
                }

                testHeadImageScrollView(storeGifts);
                break;
            case EVENT_GET_BACKPACKGIFT_SUCCESS:
                Pack[] packs = (Pack[])msg.obj;
                if(liveGiftDialog != null){
                    liveGiftDialog.setBackpackGifts(packs);
                }
                break;
            default:
                break;
        }
    }

    private void testHeadImageScrollView(Gift[] storeGifts){
        Log.d(TAG,"testHeadImageScrollView-storeGifts.length:"+storeGifts.length);
        final List<String> imageUrls = new ArrayList<>();
        for(Gift gift : storeGifts){
            imageUrls.add(gift.giftItem.middleImgUrl);
        }
//        cihsv_online.setList(ChatEmojiManager.getInstance().allChatEmojisResId);
        cihsv_online.setList(imageUrls);
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()){
            case R.id.btn_inputMsg:
                fl_buttom_audience.setVisibility(View.GONE);
                break;
            case R.id.iv_gift:
                liveGiftDialog.show();
                break;
            case R.id.iv_userShare:
                userShare();
                break;
            case R.id.civ_focus:
                //关注主播
                focusHost();
                break;
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
        if(!isEmojiOpera){
            fl_buttom_audience.setVisibility(View.VISIBLE);
        }
        super.onSoftKeyboardHide();
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
        if(mIMManager.RoomIn(mRoomId) != IMManager.IM_INVALID_REQID){
            showCustomDialog(0,0,R.string.liveroom_anchor_roomout_processing,true,true,null);
        }else{
            Toast.makeText(this, "closeLiveRoom failed", Toast.LENGTH_SHORT).show();
        }
    }

    //----------------------------业务Callback---------------------------------------
    //部分事件分开主播和观众端分开处理
    @Override
    public void OnRoomIn(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMRoomInItem roomInfo)  {
        super.OnRoomIn(reqId, success, errType, errMsg, roomInfo);
        Message msg = Message.obtain();
        msg.what = EVENT_AUDIENCE_ROOMIN;
        msg.obj = new IMRespObject(reqId, success, errType, errMsg, roomInfo);
        sendUiMessage(msg);

    }

    @Override
    public void OnRoomOut(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
        super.OnRoomOut(reqId, success, errType, errMsg);
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
     */
    @Override
    public void OnRecvRoomCloseNotice(String roomId, String userId, String nickName) {
        super.OnRecvRoomCloseNotice(roomId, userId, nickName);
        if(!TextUtils.isEmpty(roomId) && roomId.equals(mRoomId)) {
            Message msg = Message.obtain();
            msg.what = EVENT_AUDIENCE_ROOMEND;
            sendUiMessage(msg);
        }
    }

    @Override
    public void onGetSendableGiftList(boolean isSuccess, int errCode, String errMsg, SendableGiftItem[] sendableGiftItems) {
//        if(isSuccess && giftIds.length>0){
//            Gift[] storeGifts = new Gift[giftIds.length];
//            for(int i=0; i<giftIds.length; i++){
//                storeGifts[i] = IMGiftManager.getInstance().getLocalGiftById(giftIds[i]);
//            }
//            //预下载
//            preDownGiftImage(storeGifts);
//
//            Message msg = Message.obtain();
//            msg.what = EVENT_GET_STOREGIFT_SUCCESS;
//            msg.obj = storeGifts;
//            sendUiMessage(msg);
//        }
    }

    @Override
    public void onGetAllBackpackGift(boolean isSuccess, int errCode, String errMsg, Pack[] packs) {
        if(isSuccess && packs.length>0){
            preDownGiftImage(packs);
            Message msg = Message.obtain();
            msg.what = EVENT_GET_BACKPACKGIFT_SUCCESS;
            msg.obj = packs;
            sendUiMessage(msg);
        }
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
        liveGiftDialog.setUserCoins(TestDataUtil.localCoins);
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
