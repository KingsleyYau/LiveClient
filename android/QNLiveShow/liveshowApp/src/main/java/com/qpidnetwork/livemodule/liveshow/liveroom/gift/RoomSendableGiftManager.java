package com.qpidnetwork.livemodule.liveshow.liveroom.gift;

import android.annotation.SuppressLint;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;

import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetGiftListCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetSendableGiftListCallback;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType;
import com.qpidnetwork.livemodule.httprequest.item.SendableGiftItem;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/**
 * Created by Hunter on 18/6/20.
 */

public class RoomSendableGiftManager{

    private final String TAG = RoomSendableGiftManager.class.getSimpleName();
    private static final int EVENT_GET_ALL_GIFT_CONFIG = 0;
    private static final int EVENT_GET_SENDABLE_GIFT = 1;

    //礼物列表管理
    private boolean mIsGetRoomGiftList = false;                                             //标记请求中，解决单个请求请求多次
    private List<OnGetSendableGiftListCallback> mOnGetSendableGiftListCallbackList;         //保存获取可发送礼物列表的listener列表
    private SendableGiftItem[] mSendableGiftItemArray;                                      //本地保存可发送列表
    private HashMap<String, SendableGiftItem> mSendabelMap;                                 //构建可发列表map，优化查找速度
    //data
    private IMRoomInItem mIMRoomInItem;                         //可发送列表所属房间Id
    private Handler mHandler;                       //线程转换

    @SuppressLint("HandlerLeak")
    public RoomSendableGiftManager(IMRoomInItem imRoomInItem){
        this.mIMRoomInItem = imRoomInItem;
        mOnGetSendableGiftListCallbackList = new ArrayList<OnGetSendableGiftListCallback>();
        mSendabelMap = new HashMap<String, SendableGiftItem>();
        mHandler =  new Handler(){
            @Override
            public void handleMessage(Message msg) {
                super.handleMessage(msg);
                HttpRespObject response = (HttpRespObject)msg.obj;
                switch (msg.what){
                    case EVENT_GET_ALL_GIFT_CONFIG:{
                        if(response.isSuccess){
                            //获取可发送列表
                            getSendableListInternal();
                        }else{
                            distributeGetAllGiftCallback(response.isSuccess, response.errCode, response.errMsg, null);
                        }
                    }break;
                    case EVENT_GET_SENDABLE_GIFT:{
                        SendableGiftItem[] sendableGiftItems = (SendableGiftItem[])response.data;
                        if(response.isSuccess){
                            mSendableGiftItemArray = sendableGiftItems;
                            //构建可发送列表map，优化查找速度
                            mSendabelMap.clear();
                            if(mSendableGiftItemArray != null) {
                                for (SendableGiftItem item : mSendableGiftItemArray) {
                                    if(item != null) {
                                        mSendabelMap.put(item.giftId, item);
                                    }
                                }
                            }
                            //获取可发送列表成功，检测是否在配置中包含详情，否则同步详情
                            checkGiftDetail(sendableGiftItems);
                        }
                        distributeGetAllGiftCallback(response.isSuccess, response.errCode, response.errMsg, sendableGiftItems);
                    }break;
                }
            }
        };
    }

    //-------------------------------可发送列表列表本地数据处理-------------------

    /**
     * 获取本地可发送列表(过滤本地详情必须存在，否则过滤掉并同步礼物详情)
     * @return
     */
    public List<GiftItem>  getLocalSendableList(){
        List<GiftItem> sendableGiftItems = new ArrayList<GiftItem>();
        if(mSendableGiftItemArray != null && mSendableGiftItemArray.length > 0){
            NormalGiftManager normalGiftManager = NormalGiftManager.getInstance();
            for(SendableGiftItem item : mSendableGiftItemArray){
                //礼物列表需过滤不可见礼物
                if(item != null && item.isVisible) {
                    GiftItem giftDetail = normalGiftManager.getLocalGiftDetail(item.giftId);
                    if (giftDetail != null) {
                        sendableGiftItems.add(giftDetail);
                    } else {
                        normalGiftManager.getGiftDetail(item.giftId, null);
                    }
                }
            }
        }
        return sendableGiftItems;
    }

    public List<GiftItem> getLocalRecommandGiftList(){
        List<GiftItem> giftList = new ArrayList<GiftItem>();
        NormalGiftManager normalGiftManager = NormalGiftManager.getInstance();
        if(mSendableGiftItemArray != null && mIMRoomInItem != null && mSendableGiftItemArray.length > 0){
            for(SendableGiftItem item : mSendableGiftItemArray){
                if(item != null) {
                    GiftItem giftItemDetail = normalGiftManager.getLocalGiftDetail(item.giftId);
                    if (giftItemDetail != null && item.isVisible && item.isPromo && giftItemDetail.lovelevelLimit <= mIMRoomInItem.loveLevel
                            && giftItemDetail.levelLimit <= mIMRoomInItem.manLevel) {
                        giftList.add(giftItemDetail);
                    }
                }
                if(giftList.size() >= 5){
                    //最多只要5个
                    break;
                }
            }
        }
        return giftList;
    }

    /**
     * 本地获取所有可发送礼物列表
     * @return
     */
    public List<GiftItem> getFilterRecommandGiftList(){
        List<GiftItem> giftList = new ArrayList<GiftItem>();
        NormalGiftManager normalGiftManager = NormalGiftManager.getInstance();
        if(mSendableGiftItemArray != null && mIMRoomInItem != null && mSendableGiftItemArray.length > 0){
            for(SendableGiftItem item : mSendableGiftItemArray){
                if(item != null) {
                    GiftItem giftItemDetail = normalGiftManager.getLocalGiftDetail(item.giftId);
                    if (giftItemDetail != null && item.isVisible && item.isPromo && giftItemDetail.lovelevelLimit <= mIMRoomInItem.loveLevel
                            && giftItemDetail.levelLimit <= mIMRoomInItem.manLevel) {
                        giftList.add(giftItemDetail);
                    }
                }
            }
            //极端情况，默认推荐第一页第一个gift
            if(0 == giftList.size()){
                for(SendableGiftItem sendableGiftItem : mSendableGiftItemArray){
                    GiftItem giftItemDetail = normalGiftManager.getLocalGiftDetail(sendableGiftItem.giftId);
                    if(giftItemDetail != null){
                        giftList.add(giftItemDetail);
                        break;
                    }
                }
            }
        }
        return giftList;
    }

    /**
     * 检测礼物是否在可发送列表
     * @param giftId
     * @return
     */
    public boolean checkGiftSendable(String giftId){
        boolean canSendable = false;
        if(!TextUtils.isEmpty(giftId)
                && mSendabelMap.containsKey(giftId)){
            canSendable = true;
        }
        return canSendable;
    }

    //-------------------------------获取可发送礼物列表-------------------

    /**
     * 获取直播间礼物可发送列表（1.先获取礼物配置； 2.获取可发送列表）
     * @param callback
     */
    public void getSendableGiftList(final OnGetSendableGiftListCallback callback){
        if(mSendableGiftItemArray != null){
            //本地存在即使用本地缓存
            checkGiftDetail(mSendableGiftItemArray);
            if(callback != null){
                callback.onGetSendableGiftList(true, HttpLccErrType.HTTP_LCC_ERR_SUCCESS.ordinal(), "", mSendableGiftItemArray);
            }
        }else {
            if (callback != null) {
                addToGetAllGiftCallbackList(callback);
            }
            if (!mIsGetRoomGiftList) {
                mIsGetRoomGiftList = true;
                NormalGiftManager.getInstance().getAllGiftItems(new OnGetGiftListCallback() {
                    @Override
                    public void onGetGiftList(boolean isSuccess, int errCode, String errMsg, GiftItem[] giftList) {
                        HttpRespObject respObject = new HttpRespObject(isSuccess, errCode, errMsg, giftList);
                        Message msg = Message.obtain();
                        msg.what = EVENT_GET_ALL_GIFT_CONFIG;
                        msg.obj = respObject;
                        mHandler.sendMessage(msg);
                    }
                });
            }
        }
    }

    /**
     * 调用获取可发送列表获取可发送列表
     */
    private void getSendableListInternal(){
        LiveRequestOperator.getInstance().GetSendableGiftList(mIMRoomInItem.roomId, new OnGetSendableGiftListCallback() {
            @Override
            public void onGetSendableGiftList(boolean isSuccess, int errCode,
                                              String errMsg, SendableGiftItem[] sendableGiftItems) {
                HttpRespObject respObject = new HttpRespObject(isSuccess, errCode, errMsg, sendableGiftItems);
                Message msg = Message.obtain();
                msg.what = EVENT_GET_SENDABLE_GIFT;
                msg.obj = respObject;
                mHandler.sendMessage(msg);
            }
        });
    }



    /**
     * 获取所有礼物列表callback存储
     * @param callback
     */
    private void addToGetAllGiftCallbackList(OnGetSendableGiftListCallback callback){
        synchronized (mOnGetSendableGiftListCallbackList){
            if(callback != null && mOnGetSendableGiftListCallbackList != null){
                mOnGetSendableGiftListCallbackList.add(callback);
            }
        }
    }

    /**
     * 获取所有礼物返回分发器
     * @param isSuccess
     * @param errCode
     * @param errMsg
     * @param giftIds
     */
    private void distributeGetAllGiftCallback(boolean isSuccess, int errCode, String errMsg, SendableGiftItem[] giftIds){
        //重置请求中状态
        mIsGetRoomGiftList = false;
        synchronized (mOnGetSendableGiftListCallbackList){
            if(mOnGetSendableGiftListCallbackList != null){
                for (OnGetSendableGiftListCallback callback : mOnGetSendableGiftListCallbackList){
                    if(callback != null){
                        callback.onGetSendableGiftList(isSuccess, errCode, errMsg, giftIds);
                    }
                }
                mOnGetSendableGiftListCallbackList.clear();
            }
        }
    }

    /**
     * 检测可发送列表礼物详情是否已在本地配置，如果检测不存在调用获取详情接口同步
     * @param sendableGiftArray
     */
    private void checkGiftDetail(SendableGiftItem[] sendableGiftArray){
        if(sendableGiftArray != null && sendableGiftArray.length > 0){
            NormalGiftManager normalGiftManager = NormalGiftManager.getInstance();
            for(SendableGiftItem item : sendableGiftArray){
                if(item != null){
                    GiftItem giftDetailItem = normalGiftManager.getLocalGiftDetail(item.giftId);
                    if(giftDetailItem == null){
                        //本地不存在，调用详情接口同步
                        normalGiftManager.getGiftDetail(item.giftId, null);
                    }
                }
            }
        }
    }

    //回收定时器等数据
    public void onDestroy(){

    }

    //***************************** 2019/9/3    Hardy   ************************************

    public SendableGiftItem getSendableGiftItem(String giftId){
        if(!TextUtils.isEmpty(giftId) && mSendabelMap.containsKey(giftId)){
            return mSendabelMap.get(giftId);
        }
        return null;
    }
}
