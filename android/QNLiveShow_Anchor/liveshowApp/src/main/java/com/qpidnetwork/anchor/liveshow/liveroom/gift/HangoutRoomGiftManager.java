package com.qpidnetwork.anchor.liveshow.liveroom.gift;

import android.os.Handler;
import android.os.Message;

import com.qpidnetwork.anchor.httprequest.LiveRequestOperator;
import com.qpidnetwork.anchor.httprequest.OnGetGiftListCallback;
import com.qpidnetwork.anchor.httprequest.OnHangoutGiftListCallback;
import com.qpidnetwork.anchor.httprequest.item.AnchorHangoutGiftListItem;
import com.qpidnetwork.anchor.httprequest.item.GiftItem;
import com.qpidnetwork.anchor.httprequest.item.GiftLimitNumItem;
import com.qpidnetwork.anchor.liveshow.model.http.HttpReqStatus;
import com.qpidnetwork.anchor.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.anchor.utils.Log;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * 管理直播间礼物列表（非单例模式）
 * Created by Hunter Mun on 2018/6/14.
 */

public class HangoutRoomGiftManager {

    private static final int GET_ALL_GIFT_CONFIG_CALLBACK = 1;
    private static final int GET_HANGOUT_ROOM_GIFT_CONFIG_CALLBACK = 2;

    private final String TAG = RoomGiftManager.class.getSimpleName();
    private boolean mIsGetRoomGiftList = false;
    private List<OnHangoutGiftListCallback> mCallbackList;     //回调列表
    private AnchorHangoutGiftListItem mAnchorHangoutGiftListItem;            //本地缓存房间礼物信息
    private Handler mHandler;

    //数据
    private String mRoomId;                                     //当前房间Id

    public HangoutRoomGiftManager(String roomId){
        mRoomId = roomId;
        mCallbackList = new ArrayList<OnHangoutGiftListCallback>();
        mHandler = new Handler(){
            @Override
            public void handleMessage(Message msg) {
                super.handleMessage(msg);
                HttpRespObject response = (HttpRespObject)msg.obj;
                switch (msg.arg1){
                    case GET_ALL_GIFT_CONFIG_CALLBACK:{
                        if(response.isSuccess){
                            getHangOutRoomGiftList(mRoomId);
                        }else{
                            distributeCallbackEvent(response.isSuccess, response.errCode, response.errMsg, mAnchorHangoutGiftListItem);
                        }
                    }break;
                    case GET_HANGOUT_ROOM_GIFT_CONFIG_CALLBACK:{
                        AnchorHangoutGiftListItem giftListItem = (AnchorHangoutGiftListItem)response.data;
                        if(response.isSuccess){
                            mAnchorHangoutGiftListItem = giftListItem;
                            //同步完善礼物详情，由于可能调用详情接口，故需要主线程操作
                            checkGiftDetail(giftListItem);
                        }
                        distributeCallbackEvent(response.isSuccess, response.errCode, response.errMsg, giftListItem);
                    }break;
                }
            }
        };
    }

    /**
     * 刷新获取直播间礼物列表
     * @param callback
     */
    public void getRoomGiftList(OnHangoutGiftListCallback callback){
        //本地缓存callback
        if(callback != null) {
            addCallbackToList(callback);
        }
        if(!mIsGetRoomGiftList){
            mIsGetRoomGiftList = true;
            //非请求中，先获取所有礼物配置
            NormalGiftManager.getInstance().getAllGiftItems(new OnGetGiftListCallback() {
                @Override
                public void onGetGiftList(boolean isSuccess, int errCode, String errMsg, GiftItem[] giftList) {
                    Message msg = Message.obtain();
                    msg.arg1 = GET_ALL_GIFT_CONFIG_CALLBACK;
                    msg.obj = new HttpRespObject(isSuccess, errCode, errMsg, giftList);
                    mHandler.sendMessage(msg);
                }
            });
        }
    }

    /**
     * 获取直播间礼物Item
     * @return
     */
    public AnchorHangoutGiftListItem getLoaclHangoutGiftItem(){
        return mAnchorHangoutGiftListItem;
    }

    /**
     * 获取放假礼物接口状态
     */
    public HttpReqStatus getRoomGiftRequestStatus(){
        HttpReqStatus httpReqStatus = HttpReqStatus.NoReq;
        if(mIsGetRoomGiftList){
            httpReqStatus = HttpReqStatus.Reqing;
        }else{
            if(mAnchorHangoutGiftListItem == null){
                httpReqStatus = HttpReqStatus.ResFailed;
            }else{
                httpReqStatus = HttpReqStatus.ReqSuccess;
            }
        }
        return httpReqStatus;
    }

    /**
     * 同步礼物配置成功，获取房间礼物列表
     * @param roomid
     */
    private void getHangOutRoomGiftList(String roomid){
        Log.d(TAG,"getHangOutRoomGiftList-roomId:"+roomid);
        LiveRequestOperator.getInstance().GetHangoutGiftList(roomid, new OnHangoutGiftListCallback() {
            @Override
            public void onHangoutGiftList(boolean isSuccess, int errCode, String errMsg,
                                          AnchorHangoutGiftListItem anchorHangoutGiftListItem) {
                Message msg = Message.obtain();
                msg.arg1 = GET_HANGOUT_ROOM_GIFT_CONFIG_CALLBACK;
                msg.obj = new HttpRespObject(isSuccess, errCode, errMsg, anchorHangoutGiftListItem);
                mHandler.sendMessage(msg);
            }
        });
    }

    /**
     * 添加回调到回调列表
     * @param callback
     */
    private void addCallbackToList(OnHangoutGiftListCallback callback){
        synchronized (mCallbackList){
            if(mCallbackList != null){
                mCallbackList.add(callback);
            }
        }
    }

    /**
     * 同步服务器房间礼物列表成功，分发结果
     * @param isSuccess
     * @param errCode
     * @param errMsg
     * @param giftItem
     */
    private void distributeCallbackEvent(boolean isSuccess, int errCode, String errMsg, AnchorHangoutGiftListItem giftItem){
        //重置请求状态
        mIsGetRoomGiftList = false;
        synchronized (mCallbackList){
            if(mCallbackList != null){
                for(OnHangoutGiftListCallback callback : mCallbackList){
                    if(callback != null){
                        callback.onHangoutGiftList(isSuccess, errCode, errMsg, giftItem);
                    }
                }
            }
        }
    }

    /**
     * 整理hangout直播间礼物列表
     * @param giftListItem
     */
    private void checkGiftDetail(AnchorHangoutGiftListItem giftListItem){
        if(giftListItem != null){
            List<GiftLimitNumItem> giftList = new ArrayList<GiftLimitNumItem>();
            if(giftListItem.buyforList != null){
                giftList.addAll(Arrays.asList(giftListItem.buyforList));
            }
            if(giftListItem.normalList != null){
                giftList.addAll(Arrays.asList(giftListItem.normalList));
            }
            if(giftListItem.celebrationList != null){
                giftList.addAll(Arrays.asList(giftListItem.celebrationList));
            }
            checkGiftDetailInternal(giftList);
        }
    }

    /**
     * 检测本地是否包含礼物详情，无则通过获取详情同步
     * @param giftList
     */
    private void checkGiftDetailInternal(List<GiftLimitNumItem> giftList){
        if(giftList != null){
            for (GiftLimitNumItem item : giftList){
                if(item != null){
                    NormalGiftManager normalGiftManager = NormalGiftManager.getInstance();
                    GiftItem giftItem = normalGiftManager.getLocalGiftDetail(item.giftId);
                    if(giftItem == null){
                        //本地不存在，则同步获取详情
                        normalGiftManager.getGiftDetail(item.giftId, null);
                    }
                }
            }
        }
    }
}
