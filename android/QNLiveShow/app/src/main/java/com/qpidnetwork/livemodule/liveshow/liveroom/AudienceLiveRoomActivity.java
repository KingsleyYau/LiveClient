package com.qpidnetwork.livemodule.liveshow.liveroom;


import android.content.Intent;
import android.os.Bundle;
import android.os.Message;
import android.text.TextUtils;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.Toast;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.OnGetGiftListCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetPackageGiftListCallback;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.httprequest.item.PackageGiftItem;
import com.qpidnetwork.livemodule.im.IMManager;
import com.qpidnetwork.livemodule.im.listener.IMClientListener;
import com.qpidnetwork.livemodule.im.listener.IMMessageItem;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.livemodule.liveshow.liveroom.car.CarInfo;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.GiftSendReqManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.GiftSender;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.NormalGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.PackageGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.dialog.LiveGiftDialog;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.liveshow.model.http.IMRespObject;
import com.qpidnetwork.livemodule.utils.TestDataUtil;

import net.qdating.LSPlayer;

import java.util.List;


/**
 * 用户直播间
 * Created by Hunter Mun on 2017/6/15.
 */

public class AudienceLiveRoomActivity extends BaseCommonLiveRoomActivity
        implements NormalGiftManager.OnGetRoomShowSendableGiftListCallback, OnGetPackageGiftListCallback {

    //避免和基类冲突，Audience 以 2*** 格式
    /**
     * 进入房间
     */
    private static final int EVENT_AUDIENCE_ROOMIN = 2001;
    /**
     * 退出房间
     */
    private static final int EVENT_AUDIENCE_ROOMOUT = 2003;
    /**
     * 直播已结束
     */
    private static final int EVENT_AUDIENCE_ROOMEND = 2004;
    /**
     * 金币更新
     */
    private static final int EVNET_CONINS_UPDATE = 2005;
    /**
     * 成功获取所有礼物配置信息
     */
    private static final int EVENT_GET_ALLGIFTS_SUCCESS=2006;
    /**
     * 成功获取房间可发送礼物配置信息
     */
    private static final int EVENT_GET_SENDABLEGIFT_SUCCESS =2007;
    /**
     * 成功获取所有背包礼物配置信息
     */
    private static final int EVENT_GET_BACKPACKGIFT_SUCCESS =2008;
    /**
     * 收藏/取消收藏主播
     */
    private static final int EVENT_FAVORITE_RESULT =2009;

    //View
    private LinearLayout ll_buttom_audience_freepublic;

    //礼物列表
    private LiveGiftDialog liveGiftDialog;

    //data
    private IMRoomInItem mIMRoomInfoItem;         //观众端直播间信息

    private LSPlayer player = null;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initAudienceViews();
        //TODO:反注释
//        initAudienceData();
        GiftSendReqManager.getInstance().executeNextReqTask();
        //TODO:DELETE测试demo
        testAllMoudle();
    }

    private void testAllMoudle(){
        TestDataUtil.isContinueTestTask = true;
        TestDataUtil.OnIMMessageItemProducedListener listener = new TestDataUtil.OnIMMessageItemProducedListener() {
            @Override
            public void onIMMessageItemProduced(final IMMessageItem imMessageItem) {
                sendMessageUpdateEvent(imMessageItem);
            }
        };
        TestDataUtil.testBarrage(listener);
        TestDataUtil.testMulitGift(listener);
        TestDataUtil.testFollow(listener);
        TestDataUtil.testRoomIn(listener);
        TestDataUtil.testOnLineHeader(this,cihsv_online);
        TestDataUtil.testLiveRoomCarAnim(new TestDataUtil.OnAudienceInfoItemProducedListener() {
            @Override
            public void onAudienceInfoItemProduced(final CarInfo item) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if(null != carManager){
                            carManager.putLiveRoomCarInfo(item);
                        }
                    }
                });
            }
        });
        TestDataUtil.testTariffPrompt(this,this);
    }

    private void initAudienceViews(){
        findViewById(R.id.include_audience_area).setVisibility(View.VISIBLE);
        ll_buttom_audience_freepublic = (LinearLayout) findViewById(R.id.ll_buttom_audience_freepublic);
        ll_buttom_audience_freepublic.setVisibility(View.VISIBLE);
        player = new LSPlayer();
        player.init(sv_player, null);
        player.playUrl("rtmp://172.25.32.17:1936/aac/hunter", "", "", "");

        setLiveRoomBaseBgColor(getResources().getColor(R.color.room_base_color_free_public));
    }

    private void initAudienceData(){
        audienceRoomIn();
        initLiveGiftDialog();
        initRoomGiftItems();
        //获取背包配置

        GiftSender.getInstance().currRoomId = mRoomId;
        TestDataUtil.localCoins = 99.99d;
    }

    /**
     * 初始化礼物配置
     */
    private void initRoomGiftItems() {
        if(!NormalGiftManager.getInstance().isLocalAllGiftItemsExisted()){
            NormalGiftManager.getInstance().getAllGiftItems(new OnGetGiftListCallback() {
                @Override
                public void onGetGiftList(boolean isSuccess, int errCode, String errMsg, GiftItem[] giftItems) {
                    if(isSuccess && null != giftItems){
                        Message msg = Message.obtain();
                        msg.what = EVENT_GET_ALLGIFTS_SUCCESS;
                        sendUiMessage(msg);
                    }
                }
            });
        }

        //获取房间可用礼物配置
        initRoomSendableGiftItems();
        //获取背包配置
        initRoomPackageGiftItems();

    }

    /**
     * 获取背包配置
     */
    private void initRoomPackageGiftItems(){
        List<GiftItem> packageGiftItemList = PackageGiftManager.getInstance()
                                                        .getLocalRoomPackageGiftItems();
        if(null == packageGiftItemList || packageGiftItemList.size() == 0){
            PackageGiftManager.getInstance().getAllPackageGiftItems(this);
        }else{
            liveGiftDialog.setData(packageGiftItemList);
        }
    }

    /**
     * 获取房间可用礼物配置
     */
    private void initRoomSendableGiftItems() {
        //获取房间可用礼物配置
        List<GiftItem> roomSendableGiftList = NormalGiftManager.getInstance()
                .getLocalRoomShowSendableGiftList(mRoomId);
        if(null == roomSendableGiftList || roomSendableGiftList.size() == 0){
            NormalGiftManager.getInstance().getSendableGiftList(mRoomId,AudienceLiveRoomActivity.this);
        }else{
            liveGiftDialog.setData(roomSendableGiftList);
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if(player != null){
            player.stop();
            player.uninit(); //防止内存泄漏
        }
        GiftSendReqManager.getInstance().shutDownReqQueueServNow();
        //Test demo
        TestDataUtil.isContinueTestTask = false;
    }

    /**
     * 进入直播间
     */
    private void audienceRoomIn(){
        if(mIMManager.RoomIn(mRoomId) != IMManager.IM_INVALID_REQID){
            showProgressDialog(getResources().getString(R.string.liveroom_audience_roomin_processing));
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
                hideProgressDialog();
                IMRespObject response = (IMRespObject)msg.obj;
                if(response.isSuccess){
                    //进入直播间成功
                    mIMRoomInfoItem = (IMRoomInItem)response.data;
                }else{
                    showToast(response.errMsg);
                }
            }break;

            case EVENT_AUDIENCE_ROOMOUT:{
                hideProgressDialog();
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
            case EVENT_GET_ALLGIFTS_SUCCESS:
                initRoomSendableGiftItems();
                break;

            case EVENT_GET_SENDABLEGIFT_SUCCESS:
                List<GiftItem> giftItems = (List<GiftItem>)msg.obj;
                if(liveGiftDialog != null){
                    liveGiftDialog.setData(giftItems);
                }

                break;
            case EVENT_GET_BACKPACKGIFT_SUCCESS:
                if(liveGiftDialog != null){
                    liveGiftDialog.setData(PackageGiftManager.getInstance().getLocalRoomPackageGiftItems());
                }
                break;

            case EVENT_FAVORITE_RESULT:
                HttpRespObject hrObject = (HttpRespObject)msg.obj;
                super.onRecvFollowHostResp(hrObject.isSuccess,hrObject.errMsg);
                break;
            default:
                break;
        }
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()){
            case R.id.iv_inputMsg:
                ll_buttom_audience_freepublic.setVisibility(View.GONE);
                break;
            case R.id.iv_gift:
                initRoomGiftItems();
                liveGiftDialog.show();
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
            ll_buttom_audience_freepublic.setVisibility(View.VISIBLE);
        }
        super.onSoftKeyboardHide();
    }


    public void sendFollowHostReq(){
        showToast(getResources().getString(R.string.liveroom_favorite_sending));
//        //接口调用
//        RequestJniOther.AddOrCancelFavorite(hostId, true, new OnRequestCallback() {
//            @Override
//            public void onRequest(boolean isSuccess, int errCode, String errMsg) {
//                Log.d(TAG,"sendFollowHostReq-isSuccess:"+isSuccess+" errCode:"+errCode+" errMsg:"+errMsg);
//                Message msg = Message.obtain();
//                msg.what = EVENT_FAVORITE_RESULT;
//                msg.obj = new HttpRespObject(isSuccess, errCode, errMsg, null);
//                sendUiMessage(msg);
//            }
//        });
        super.onRecvFollowHostResp(true,"");
    }

    /**
     * 关闭直播间
     */
    public void closeLiveRoom(){
        if(null != mIMManager && mIMManager.RoomIn(mRoomId) != IMManager.IM_INVALID_REQID){
            showProgressDialog(getResources().getString(R.string.liveroom_anchor_roomout_processing));
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
    public void OnRecvRoomCloseNotice(String roomId, String userId, String nickName, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
        super.OnRecvRoomCloseNotice(roomId, userId, nickName, errType, errMsg);
        if(!TextUtils.isEmpty(roomId) && roomId.equals(mRoomId)) {
            Message msg = Message.obtain();
            msg.what = EVENT_AUDIENCE_ROOMEND;
            sendUiMessage(msg);
        }
    }

    @Override
    public void onGetRoomShowSendableGiftList(boolean isSuccess, int errCode, String errMsg, List<GiftItem> giftItems) {
        if(isSuccess && null != giftItems){
            Message msg = Message.obtain();
            msg.what = EVENT_GET_SENDABLEGIFT_SUCCESS;
            msg.obj = giftItems;
            sendUiMessage(msg);
        }
    }

    @Override
    public void onGetPackageGiftList(boolean isSuccess, int errCode, String errMsg, PackageGiftItem[] packageGiftList) {
        if(isSuccess && null != packageGiftList){
            Message msg = Message.obtain();
            msg.what = EVENT_GET_BACKPACKGIFT_SUCCESS;
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
//        showCustomDialog(0, R.string.txt_ok, R.string.tip_sureToCloseRoom,
//                true, true, android.R.color.white, android.R.color.white,
//                R.drawable.bg_custom_dialog_confirm, R.drawable.bg_custom_dialog_cancel,
//                new SimpleDoubleBtnTipsDialog.OnTipsDialogBtnClickListener() {
//                    @Override
//                    public void onCancelBtnClick() {
//                        dismissCustomDialog();
//                    }
//
//                    @Override
//                    public void onConfirmBtnClick() {
//                        dismissCustomDialog();
//                        Intent intent = new Intent(AudienceLiveRoomActivity.this, AudienceEndActivity.class);
//                        startActivity(intent);
//                        finish();
//                    }
//                });
    }
}
