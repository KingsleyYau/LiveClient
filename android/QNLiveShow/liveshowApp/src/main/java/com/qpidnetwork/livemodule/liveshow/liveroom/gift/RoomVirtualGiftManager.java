package com.qpidnetwork.livemodule.liveshow.liveroom.gift;

import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.text.TextUtils;

import com.qpidnetwork.livemodule.httprequest.OnGetGiftTypeListCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetPackageGiftListCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniLiveShow;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.httprequest.item.GiftTypeItem;
import com.qpidnetwork.livemodule.httprequest.item.PackageGiftItem;
import com.qpidnetwork.livemodule.httprequest.item.SendableGiftItem;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.qnbridgemodule.util.ListUtils;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by Hardy on 2019/9/4.
 * 私密直播间礼物列表新版数据源管理器
 */
public class RoomVirtualGiftManager {

    private static final int EVENT_PACKAGE_GIFT_LSIT_CALLBACK = 0;
    private static final int EVENT_GET_GIFT_TYPE_LIST_CALLBACK = 1;

    private boolean mIsGetVirtualGiftItems = false;                // 标记请求中，解决单个请求请求多次

    private RequestJniLiveShow.GiftRoomType mGiftRoomType;
    private IMRoomInItem mIMRoomInItem;                            //当前房间Id
    private RoomGiftManager mRoomGiftManager;
    private RoomGiftTypeListManager mRoomGiftTypeListManager;

    private Map<String, List<GiftItem>> mGiftTypeItemMap;               // 根据礼物分类 id，获取对应礼物列表
    private List<OnVirtualGiftListCallback> mOnVirtualGiftListCallbacks;        //保存获取背包列表的listener列表
    private Handler mHandler;

    // 展示的 tab 标签位置
    private int tabCurPosition;

    public RoomVirtualGiftManager(RoomGiftManager roomGiftManager) {
        this.mRoomGiftManager = roomGiftManager;
        this.mIMRoomInItem = mRoomGiftManager.getIMRoomInItem();

        this.mRoomGiftTypeListManager = RoomGiftTypeListManager.getInstance();
        this.mGiftRoomType = mRoomGiftTypeListManager.getGiftRoomType(mIMRoomInItem);

        this.mGiftTypeItemMap = new HashMap<>();
        this.mOnVirtualGiftListCallbacks = new ArrayList<>();

        mHandler = new Handler(Looper.getMainLooper()) {
            @Override
            public void handleMessage(Message msg) {
                super.handleMessage(msg);

                HttpRespObject response = (HttpRespObject) msg.obj;
                switch (msg.what) {
                    case EVENT_GET_GIFT_TYPE_LIST_CALLBACK: {
                        // 本地已缓存
//                        List<GiftTypeItem> list = getLocalGiftTypeServerList();

                        getGiftItemsInternal();
                    }
                    break;

                    case EVENT_PACKAGE_GIFT_LSIT_CALLBACK: {
                        // 本地已缓存
                        List<PackageGiftItem> packList = mRoomGiftManager.getLoaclRoomPackageGiftList();

                        boolean hasPackageItems = false;

                        if (response.isSuccess && ListUtils.isList(packList)) {
                            hasPackageItems = true;
                        }

                        // 过滤分类
                        List<GiftTypeItem> localGiftTypeList = filterGiftTypeList(hasPackageItems);

                        // 过滤分类下的礼物列表
                        filterGiftList(localGiftTypeList);

                        // 分发 callback
                        distributeGetListCallback(response.isSuccess, localGiftTypeList,
                                hasPackageItems, tabCurPosition);
                    }
                    break;
                }
            }
        };
    }

    /**
     * 获取指定标签分类下的礼物列表数据
     * Free 背包除外，单独获取
     */
    public List<GiftItem> getGiftList(GiftTypeItem item){
        if (item != null && !TextUtils.isEmpty(item.typeId)){
            return mGiftTypeItemMap.get(item.typeId);
        }

        return null;
    }

    /**
     * 获取服务器返回的礼物分类数据，本地缓存
     */
    public List<GiftTypeItem> getLocalGiftTypeServerList(){
        return mRoomGiftTypeListManager.getLocalGiftTypeItemList(mGiftRoomType);
    }

    public void loadGiftTypeList(OnVirtualGiftListCallback callback) {
        if (callback != null) {
            addToGetListCallbackList(callback);
        }

        if (!mIsGetVirtualGiftItems) {
            mIsGetVirtualGiftItems = true;

            List<GiftTypeItem> typeList = getLocalGiftTypeServerList();
            if (ListUtils.isList(typeList)) {
                // 本地已有分类数据
                HttpRespObject respObject = new HttpRespObject(true, 0, "", typeList);
                sendGiftTypeListObj(respObject);
            } else {
                // 获取服务器分类
                mRoomGiftTypeListManager.getGiftTypeItemList(mGiftRoomType, new OnGetGiftTypeListCallback() {
                    @Override
                    public void onGetGiftTypeList(boolean isSuccess, int errCode, String errMsg, GiftTypeItem[] giftTypeList) {
                        List<GiftTypeItem> list = new ArrayList<>();
                        if (giftTypeList != null && giftTypeList.length > 0) {
                            list.addAll(Arrays.asList(giftTypeList));
                        }

                        HttpRespObject respObject = new HttpRespObject(isSuccess, errCode, errMsg, list);

                        sendGiftTypeListObj(respObject);
                    }
                });
            }
        }
    }

    private void sendGiftTypeListObj(HttpRespObject respObject) {
        Message msg = Message.obtain();
        msg.what = EVENT_GET_GIFT_TYPE_LIST_CALLBACK;
        msg.obj = respObject;
        mHandler.sendMessage(msg);
    }

    /**
     * 组装礼物列表数据
     */
    private void filterGiftList(List<GiftTypeItem> giftTypeItemListt) {
        for (GiftTypeItem giftTypeItem : giftTypeItemListt) {
            List<GiftItem> giftItemList = mGiftTypeItemMap.get(giftTypeItem.typeId);
            if (giftItemList == null) {
                giftItemList = new ArrayList<>();
            }
            giftItemList.clear();

            if (GiftTypeItem.isFreeGiftType(giftTypeItem)) {
                // free 背包礼物，这里暂时不处理，在背包管理器里自己获取本地缓存数据(PackageGiftItem)

            } else if (GiftTypeItem.isAllGiftType(giftTypeItem)) {
                // all 礼物
                giftItemList.addAll(mRoomGiftManager.getLocalSendableList());

            } else {
                // 一般过滤礼物
                // 可发送礼物
                List<GiftItem> normalGiftList = mRoomGiftManager.getLocalSendableList();
                if (ListUtils.isList(normalGiftList)) {
                    for (GiftItem giftItem : normalGiftList) {
                        SendableGiftItem sendableGiftItem = mRoomGiftManager.getSendableGiftItem(giftItem.id);
                        if (sendableGiftItem != null &&
                                mRoomGiftTypeListManager.isGiftTypeValid(giftTypeItem.typeId,
                                        sendableGiftItem.typeIdList)) {
                            // 分类 id 匹配添加记录
                            giftItemList.add(giftItem);
                        }
                    }
                }
            }

            mGiftTypeItemMap.put(giftTypeItem.typeId, giftItemList);
        }
    }

    /**
     * 组装礼物分类列表
     */
    private List<GiftTypeItem> filterGiftTypeList(boolean hasPackageItems) {
        List<GiftTypeItem> tempList = new ArrayList<>();

        // Free
        if (hasPackageItems) {
            tempList.add(GiftTypeItem.getFreeGiftTypeItem());
        }

        // All
        tempList.add(GiftTypeItem.getAllGiftTypeItem());

        tabCurPosition = hasPackageItems ? 1 : 0;

        // 服务器返回的分类列表
        List<GiftTypeItem> localGiftTypeList = getLocalGiftTypeServerList();
        if (ListUtils.isList(localGiftTypeList)) {
            tempList.addAll(localGiftTypeList);

            tabCurPosition++;
        }

        return tempList;
    }


    /**
     * 刷新背包礼物列表，里面已做可发送礼物的检测流程
     */
    private void getGiftItemsInternal() {
        mRoomGiftManager.getPackageGiftItems(new OnGetPackageGiftListCallback() {
            @Override
            public void onGetPackageGiftList(boolean isSuccess, int errCode, String errMsg, PackageGiftItem[] packageGiftList, int totalCount) {
                HttpRespObject respObject = new HttpRespObject(isSuccess, errCode, errMsg, packageGiftList);

                Message msg = Message.obtain();
                msg.what = EVENT_PACKAGE_GIFT_LSIT_CALLBACK;
                msg.obj = respObject;

                mHandler.sendMessage(msg);
            }
        });
    }

    /**
     * 获取所有礼物列表callback存储
     *
     * @param callback
     */
    private void addToGetListCallbackList(OnVirtualGiftListCallback callback) {
        synchronized (mOnVirtualGiftListCallbacks) {
            if (callback != null && mOnVirtualGiftListCallbacks != null) {
                mOnVirtualGiftListCallbacks.add(callback);
            }
        }
    }

    /**
     * 获取背包礼物返回分发器
     */
    private void distributeGetListCallback(boolean isSuccess, List<GiftTypeItem> giftTypeList, boolean hasPackageItems, int tabCurPosition) {
        //重置请求中状态
        mIsGetVirtualGiftItems = false;

        synchronized (mOnVirtualGiftListCallbacks) {
            if (mOnVirtualGiftListCallbacks != null) {
                for (OnVirtualGiftListCallback callback : mOnVirtualGiftListCallbacks) {
                    if (callback != null) {
                        callback.onGiftList(isSuccess, giftTypeList, hasPackageItems, tabCurPosition);
                    }
                }

                mOnVirtualGiftListCallbacks.clear();
            }
        }
    }


    public interface OnVirtualGiftListCallback {
        void onGiftList(boolean isSuccess, List<GiftTypeItem> giftTypeList,
                        boolean hasPackageItems, int tabCurPosition);
    }
}
