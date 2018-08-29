package com.qpidnetwork.anchor.liveshow.liveroom.gift;

import android.annotation.SuppressLint;
import android.os.Handler;
import android.os.Message;

import com.qpidnetwork.anchor.httprequest.LiveRequestOperator;
import com.qpidnetwork.anchor.httprequest.OnGetGiftListCallback;
import com.qpidnetwork.anchor.httprequest.OnGiftLimitNumListCallback;
import com.qpidnetwork.anchor.httprequest.item.GiftItem;
import com.qpidnetwork.anchor.httprequest.item.GiftLimitNumItem;
import com.qpidnetwork.anchor.liveshow.model.http.HttpReqStatus;
import com.qpidnetwork.anchor.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.anchor.utils.Log;

import java.util.ArrayList;
import java.util.List;

/**
 * 房间礼物管理器
 *  1.可发送礼物列表管理；
 *  2.房间背包礼物管理；
 * 注意：此类使用必须在主线程初始化，内部handler未绑定自己looper
 * Created by harry52 on 2018/8/21.
 */

public class RoomGiftManager {
    //获取所有礼物配置数据接口回调
    private static final int GET_ALL_GIFT_CONFIG_CALLBACK = 1;
    //获取房间礼物列表数据接口回调
    private static final int GET_ROOM_GIFT_CONFIG_CALLBACK = 2;
    private final String TAG = RoomGiftManager.class.getSimpleName();
    //标记请求中，解决单个请求请求多次
    private boolean mIsGetRoomGiftList = false;
    //回调列表
    private List<OnGiftLimitNumListCallback> mCallbackList;
    //本地缓存房间礼物信息
    private GiftLimitNumItem[] mRoomGiftList;
    private Handler mHandler;
    //数据
    private String mRoomId;                                     //当前房间Id

    @SuppressLint("HandlerLeak")
    public RoomGiftManager(String roomId){
        mRoomId = roomId;
        mCallbackList = new ArrayList<OnGiftLimitNumListCallback>();
        mHandler = new Handler(){
            @Override
            public void handleMessage(Message msg) {
                super.handleMessage(msg);
                HttpRespObject response = (HttpRespObject)msg.obj;
                switch (msg.arg1){
                    case GET_ALL_GIFT_CONFIG_CALLBACK:{
                        if(response.isSuccess){
                            getGiftLimitNumItems(mRoomId);
                        }else{
                            distributeCallbackEvent(response.isSuccess, response.errCode, response.errMsg, mRoomGiftList);
                        }
                    }break;
                    case GET_ROOM_GIFT_CONFIG_CALLBACK:{
                        GiftLimitNumItem[] giftLimitNumItems = (GiftLimitNumItem[])response.data;
                        if(response.isSuccess){
                            mRoomGiftList = giftLimitNumItems;
                            //同步完善礼物详情，由于可能调用详情接口，故需要主线程操作
                            checkGiftDetail(mRoomGiftList);
                        }
                        distributeCallbackEvent(response.isSuccess, response.errCode, response.errMsg, giftLimitNumItems);
                    }break;
                }
            }
        };
    }

    /**
     * 刷新获取直播间礼物列表
     * @param callback
     */
    public void getRoomGiftList(OnGiftLimitNumListCallback callback){
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
     * 读取可发送列表（需要排除缺少礼物详情且在房间礼物列表中的礼物并调用详情同步礼物）
     * @return
     */
    public List<GiftLimitNumItem> getLocalRoomGiftList(){
        ArrayList<GiftLimitNumItem> giftList = new ArrayList<GiftLimitNumItem>();
        NormalGiftManager normalGiftManager = NormalGiftManager.getInstance();
        if(mRoomGiftList != null && mRoomGiftList.length > 0){
            for(GiftLimitNumItem item : mRoomGiftList){
                if(item != null){
                    GiftItem giftItem = normalGiftManager.getLocalGiftDetail(item.giftId);
                    if(giftItem == null){
                        //本地无详情，需同步礼物详情
                        normalGiftManager.getGiftDetail(item.giftId, null);
                    }else{
                        giftList.add(item);
                    }
                }
            }
        }
        return giftList;
    }

    /**
     * 获取当前房间礼物列表接口调用状态
     */
    public HttpReqStatus getRoomGiftRequestStatus(){
        HttpReqStatus httpReqStatus = HttpReqStatus.NoReq;
        if(mIsGetRoomGiftList){
            httpReqStatus = HttpReqStatus.Reqing;
        }else{
            if(mRoomGiftList == null){
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
    private void getGiftLimitNumItems(String roomid){
        Log.d(TAG,"getGiftLimitNumItems-roomId:"+roomid);
        LiveRequestOperator.getInstance().GiftLimitNumList(roomid, new OnGiftLimitNumListCallback() {
            @Override
            public void onGiftLimitNumList(boolean isSuccess, int errCode,
                                           String errMsg, GiftLimitNumItem[] giftList) {
                Message msg = Message.obtain();
                msg.arg1 = GET_ROOM_GIFT_CONFIG_CALLBACK;
                msg.obj = new HttpRespObject(isSuccess, errCode, errMsg, giftList);
                mHandler.sendMessage(msg);
            }
        });
    }

    /**
     * 添加回调到回调列表
     * @param callback
     */
    private void addCallbackToList(OnGiftLimitNumListCallback callback){
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
     * @param giftList
     */
    private void distributeCallbackEvent(boolean isSuccess, int errCode, String errMsg, GiftLimitNumItem[] giftList){
        //重置请求状态
        mIsGetRoomGiftList = false;
        synchronized (mCallbackList){
            if(mCallbackList != null){
                for(OnGiftLimitNumListCallback callback : mCallbackList){
                    if(callback != null){
                        callback.onGiftLimitNumList(isSuccess, errCode, errMsg, giftList);
                    }
                }
            }
        }
    }

    /**
     * 检测本地是否有礼物详情，无则通过获取详情同步
     * @param giftList
     */
    private void checkGiftDetail(GiftLimitNumItem[] giftList){
        if(giftList != null){
            NormalGiftManager normalGiftManager = NormalGiftManager.getInstance();
            for (GiftLimitNumItem item : giftList){
                if(item != null){
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
