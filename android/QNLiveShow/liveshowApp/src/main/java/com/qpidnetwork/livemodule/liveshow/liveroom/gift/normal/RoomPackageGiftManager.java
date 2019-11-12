package com.qpidnetwork.livemodule.liveshow.liveroom.gift.normal;

import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;

import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetPackageGiftListCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetSendableGiftListCallback;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.httprequest.item.PackageGiftItem;
import com.qpidnetwork.livemodule.httprequest.item.SendableGiftItem;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.NormalGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.RoomSendableGiftManager;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;

/**
 * 直播间背包礼物管理类（仅限直播间礼物逻辑封装使用）
 * Created by Hunter on 18/6/28.
 */

public class RoomPackageGiftManager {

    //------------------------------私有变量定义-------------------
    private final String TAG = RoomPackageGiftManager.class.getSimpleName();
    private static final int EVENT_SENDABLE_GIFT_LSIT_CALLBACK = 0;
    private static final int EVENT_GET_PACKAGE_GIFT_LIST_CALLBACK = 1;

    //背包礼物列表管理
    private boolean mIsGetPackageGiftItems = false;                                         //标记请求中，解决单个请求请求多次
    private List<OnGetPackageGiftListCallback> mOnGetPackageGiftListCallback;               //保存获取背包列表的listener列表
    private List<PackageGiftItem> mPackageGiftItemArray;                                        //本地缓存背包礼物列表

    private RoomSendableGiftManager mRoomSendableGiftManager;                               //直播间可发送礼物列表管理类
    private Handler mHandler;                                                               //线程转换

    public RoomPackageGiftManager(RoomSendableGiftManager roomSendableGiftManager){
        this.mRoomSendableGiftManager = roomSendableGiftManager;
        mOnGetPackageGiftListCallback = new ArrayList<OnGetPackageGiftListCallback>();
        mHandler =  new Handler(){
            @Override
            public void handleMessage(Message msg) {
                super.handleMessage(msg);
                HttpRespObject response = (HttpRespObject)msg.obj;
                switch (msg.what){
                    case EVENT_SENDABLE_GIFT_LSIT_CALLBACK:{
                        if(response.isSuccess){
                            //可发送列表及礼物配置本地已存在，获取背包列表即可
                            getPackageGiftItemsInternal();
                        }else{
                            //可发送列表同步失败即房间背包列表错误
                            distributeGetPackageListCallback(response.isSuccess, response.errCode, response.errMsg, null, 0);
                        }
                    }break;
                    case EVENT_GET_PACKAGE_GIFT_LIST_CALLBACK:{
                        PackageGiftItem[] packageGiftItems = (PackageGiftItem[])response.data;
                        int totalCount = msg.arg1;
                        if(response.isSuccess && packageGiftItems != null){
                            mPackageGiftItemArray = filterAndMergeRoomPackageArray(packageGiftItems);
                        }
                        distributeGetPackageListCallback(response.isSuccess, response.errCode, response.errMsg, packageGiftItems, totalCount);
                    }break;
                }
            }
        };
    }

    //------------------------------背包列表本地处理-------------------

    /**
     * 获取房间可发送列表（检测本地已经有礼物详情）
     * @return
     */
    public List<PackageGiftItem> getLoaclRoomPackageGiftList(){
        List<PackageGiftItem> packageGiftItems = new ArrayList<PackageGiftItem>();
        if(mPackageGiftItemArray != null && mPackageGiftItemArray.size() > 0){
            for(PackageGiftItem packageGiftItem :mPackageGiftItemArray){
                if(packageGiftItem != null ){
                    GiftItem giftDetail = NormalGiftManager.getInstance().getLocalGiftDetail(packageGiftItem.giftId);
                    if (giftDetail != null) {
                        packageGiftItems.add(packageGiftItem);
                    } else {
                        NormalGiftManager.getInstance().getGiftDetail(packageGiftItem.giftId, null);
                    }

                }
            }
        }
        return packageGiftItems;
    }

    /**
     * 根据礼物id获取背包详情
     * @param giftId
     * @return
     */
    public PackageGiftItem getLocalPackageItem(String giftId){
        PackageGiftItem packageItem = null;
        if(!TextUtils.isEmpty(giftId) && mPackageGiftItemArray != null){
            for(PackageGiftItem item : mPackageGiftItemArray){
                if(item != null && item.giftId.equals(giftId)){
                    packageItem = item;
                    break;
                }
            }
        }
        return packageItem;
    }

    /**
     * 从本地移除已发送完礼物
     * @param giftId
     * @return
     */
    public PackageGiftItem removeLocalPackageItem(String giftId){
        PackageGiftItem packageItem = null;
        if(!TextUtils.isEmpty(giftId)){
            for(PackageGiftItem item : mPackageGiftItemArray){
                if(item != null && item.giftId.equals(giftId)){
                    mPackageGiftItemArray.remove(item);
                    packageItem = item;
                    break;
                }
            }
        }
        return packageItem;
    }

    /**
     * 直播间礼物列表过滤并合并同一个id的背包礼物
     * @param packageGiftItems
     */
    private ArrayList<PackageGiftItem> filterAndMergeRoomPackageArray(PackageGiftItem[] packageGiftItems){
        ArrayList<PackageGiftItem> tempPackageArray = new ArrayList<PackageGiftItem>();
        HashMap<String, PackageGiftItem> tempPackage = new HashMap<String, PackageGiftItem>();
        ArrayList<String> packageGiftSort = new ArrayList<String>();
        //排重和合并数目
        if(packageGiftItems != null && packageGiftItems.length > 0){
            for(PackageGiftItem item : packageGiftItems){
                //增加礼物有效性判断
                if(isPackageValid(item)) {
                    if (tempPackage.containsKey(item.giftId)) {
                        //合并数目
                        PackageGiftItem tempItem = tempPackage.get(item.giftId);
                        tempItem.num = tempItem.num + item.num;
                    } else {
                        tempPackage.put(item.giftId, item);
                        //解决排序与原排序一致问题
                        packageGiftSort.add(item.giftId);
                    }
                }
            }
        }

        if(tempPackage.size() > 0 ){
            for(String giftId : packageGiftSort){
                tempPackageArray.add(tempPackage.get(giftId));
            }
        }
        return tempPackageArray;
    }

    //------------------------------同步刷新背包礼物列表-------------------

    /**
     * 刷新背包列表(每次都要与服务器同步)
     * @param callback
     */
    public void getPackageGiftItems(final OnGetPackageGiftListCallback callback){
        if(callback != null){
            addToGetPackageListCallbackList(callback);
        }
        if(!mIsGetPackageGiftItems) {
            mIsGetPackageGiftItems = true;
            mRoomSendableGiftManager.getSendableGiftList(new OnGetSendableGiftListCallback() {
                @Override
                public void onGetSendableGiftList(boolean isSuccess, int errCode, String errMsg, SendableGiftItem[] giftIds) {
                    HttpRespObject respObject = new HttpRespObject(isSuccess, errCode, errMsg, giftIds);
                    Message msg = Message.obtain();
                    msg.what = EVENT_SENDABLE_GIFT_LSIT_CALLBACK;
                    msg.obj = respObject;
                    mHandler.sendMessage(msg);
                }
            });
        }
    }

    /**
     * 刷新背包列表
     */
    private void getPackageGiftItemsInternal(){
        LiveRequestOperator.getInstance().GetPackageGiftList(new OnGetPackageGiftListCallback() {
            @Override
            public void onGetPackageGiftList(boolean isSuccess, int errCode, String errMsg, PackageGiftItem[] packageGiftList, int totalCount) {
                HttpRespObject respObject = new HttpRespObject(isSuccess, errCode, errMsg, packageGiftList);
                Message msg = Message.obtain();
                msg.what = EVENT_GET_PACKAGE_GIFT_LIST_CALLBACK;
                msg.arg1 = totalCount;
                msg.obj = respObject;
                mHandler.sendMessage(msg);
            }
        });
    }

    /**
     * 获取所有礼物列表callback存储
     * @param callback
     */
    private void addToGetPackageListCallbackList(OnGetPackageGiftListCallback callback){
        synchronized (mOnGetPackageGiftListCallback){
            if(callback != null && mOnGetPackageGiftListCallback != null){
                mOnGetPackageGiftListCallback.add(callback);
            }
        }
    }

    /**
     * 获取背包礼物返回分发器
     * @param isSuccess
     * @param errCode
     * @param errMsg
     * @param packageGiftList
     * @param totalCount
     */
    private void distributeGetPackageListCallback(boolean isSuccess, int errCode, String errMsg, PackageGiftItem[] packageGiftList, int totalCount){
        //重置请求中状态
        mIsGetPackageGiftItems = false;
        synchronized (mOnGetPackageGiftListCallback){
            if(mOnGetPackageGiftListCallback != null){
                for (OnGetPackageGiftListCallback callback : mOnGetPackageGiftListCallback){
                    if(callback != null){
                        callback.onGetPackageGiftList(isSuccess, errCode, errMsg, packageGiftList, totalCount);
                    }
                }
                mOnGetPackageGiftListCallback.clear();
            }
        }
    }

    /**
     * 判断当前礼物是否可以发送
     * @param item
     * @return
     */
    private boolean isPackageValid(PackageGiftItem item){
        boolean isValid = false;
        long currentTime = System.currentTimeMillis();
        if(item != null){
            long startValid = ((long)item.startValidDate) * 1000;
            long expireValid = ((long)item.expiredDate) * 1000;
            if(startValid <= currentTime && currentTime <= expireValid ){
                isValid = true;
            }
        }
        return isValid;
    }
}
