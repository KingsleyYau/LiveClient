package com.qpidnetwork.livemodule.liveshow.liveroom.gift;

import android.annotation.SuppressLint;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.text.TextUtils;

import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetGiftTypeListCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniLiveShow;
import com.qpidnetwork.livemodule.httprequest.item.GiftTypeItem;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by Hardy on 2019/9/4.
 * 直播间礼物分类管理器
 * 登录成功后，获取一次全新的.
 * 进入直播间时，根据 list 是否为空再次获取.
 */
public class RoomGiftTypeListManager {

    private static final int EVENT_GET_PACKAGE_GIFT_LIST_CALLBACK = 1;

    private boolean mIsGetVirtualGiftItems = false;                                             // 标记请求中，解决单个请求请求多次
    private List<OnGetGiftTypeListCallback> mOnGetGiftTypeListCallback;                         // 保存获取列表的listener列表
    private Map<Integer, List<GiftTypeItem>> mGiftTypeItemMap;
    private Handler mHandler;

    private static RoomGiftTypeListManager manager;

    public static RoomGiftTypeListManager getInstance() {
        if (manager == null) {
            manager = new RoomGiftTypeListManager();
        }
        return manager;
    }

    @SuppressLint("UseSparseArrays")
    public RoomGiftTypeListManager() {
        mGiftTypeItemMap = new HashMap<>();
        mOnGetGiftTypeListCallback = new ArrayList<>();

        mHandler = new Handler(Looper.getMainLooper()) {
            @Override
            public void handleMessage(Message msg) {
                super.handleMessage(msg);

                HttpRespObject response = (HttpRespObject) msg.obj;
                switch (msg.what) {
                    case EVENT_GET_PACKAGE_GIFT_LIST_CALLBACK: {
                        GiftTypeItem[] packageGiftItems = (GiftTypeItem[]) response.data;
                        int typeIndex = msg.arg1;

                        if (response.isSuccess && packageGiftItems != null) {
                            filterAndMergeRoomGiftTypeArray(packageGiftItems, typeIndex);
                        }

                        distributeGetTypeListCallback(response.isSuccess, response.errCode, response.errMsg, packageGiftItems);
                    }
                    break;
                }
            }
        };
    }

    /**
     * 获取直播间类型
     */
    public RequestJniLiveShow.GiftRoomType getGiftRoomType(IMRoomInItem mIMRoomInItem) {
        RequestJniLiveShow.GiftRoomType type = RequestJniLiveShow.GiftRoomType.Unknown;

        if (mIMRoomInItem != null && mIMRoomInItem.roomType != null) {
            switch (mIMRoomInItem.roomType) {
                case AdvancedPrivateRoom:
                case NormalPrivateRoom:
                    type = RequestJniLiveShow.GiftRoomType.Private;
                    break;

                case FreePublicRoom:
                case PaidPublicRoom:
                    type = RequestJniLiveShow.GiftRoomType.Public;
                    break;

                default:
                    break;
            }
        }

        return type;
    }

    /**
     * 是否符合指定分类的礼物
     */
    public boolean isGiftTypeValid(String typeId, String[] typeList) {
        boolean isValid = false;

        if (!TextUtils.isEmpty(typeId) && typeList != null && typeList.length > 0) {
            for (String type : typeList) {
                if (typeId.equals(type)) {
                    isValid = true;
                    break;
                }
            }
        }

        return isValid;
    }


    public List<GiftTypeItem> getLocalGiftTypeItemList(RequestJniLiveShow.GiftRoomType type) {
        if (type != null) {
            return mGiftTypeItemMap.get(type.ordinal());
        }
        return null;
    }

    /**
     * 刷新礼物分类列表(登录后都要与服务器同步)
     */
    public void getGiftTypeItemList(RequestJniLiveShow.GiftRoomType giftRoomType, OnGetGiftTypeListCallback callback) {
        if (callback != null) {
            addToGetTypeListCallbackList(callback);
        }
        if (!mIsGetVirtualGiftItems) {
            mIsGetVirtualGiftItems = true;
            getPackageGiftItemsInternal(giftRoomType);
        }
    }

    private void filterAndMergeRoomGiftTypeArray(GiftTypeItem[] packageGiftItems, int giftType) {
        List<GiftTypeItem> mapList = mGiftTypeItemMap.get(giftType);
        if (mapList == null) {
            mapList = new ArrayList<>();
        }
        mapList.clear();

        if (packageGiftItems != null && packageGiftItems.length > 0) {
            for (GiftTypeItem typeItem : packageGiftItems) {
                if (typeItem != null) {
                    mapList.add(typeItem);
                }
            }

            mGiftTypeItemMap.put(giftType, mapList);
        }
    }

    /**
     * 刷新礼物分类列表
     */
    private void getPackageGiftItemsInternal(final RequestJniLiveShow.GiftRoomType giftRoomType) {
        LiveRequestOperator.getInstance().GetGiftTypeList(giftRoomType, new OnGetGiftTypeListCallback() {
            @Override
            public void onGetGiftTypeList(boolean isSuccess, int errCode, String errMsg, GiftTypeItem[] giftTypeList) {
                HttpRespObject respObject = new HttpRespObject(isSuccess, errCode, errMsg, giftTypeList);

                Message msg = Message.obtain();
                msg.what = EVENT_GET_PACKAGE_GIFT_LIST_CALLBACK;
                msg.obj = respObject;
                msg.arg1 = giftRoomType.ordinal();

                mHandler.sendMessage(msg);
            }
        });
    }

    /**
     * 获取所有礼物列表callback存储
     *
     * @param callback
     */
    private void addToGetTypeListCallbackList(OnGetGiftTypeListCallback callback) {
        synchronized (mOnGetGiftTypeListCallback) {
            if (callback != null && mOnGetGiftTypeListCallback != null) {
                mOnGetGiftTypeListCallback.add(callback);
            }
        }
    }

    /**
     * 获取礼物类型返回分发器
     */
    private void distributeGetTypeListCallback(boolean isSuccess, int errCode, String errMsg, GiftTypeItem[] giftTypeList) {
        //重置请求中状态
        mIsGetVirtualGiftItems = false;

        synchronized (mOnGetGiftTypeListCallback) {
            if (mOnGetGiftTypeListCallback != null) {
                for (OnGetGiftTypeListCallback callback : mOnGetGiftTypeListCallback) {
                    if (callback != null) {
                        callback.onGetGiftTypeList(isSuccess, errCode, errMsg, giftTypeList);
                    }
                }
                mOnGetGiftTypeListCallback.clear();
            }
        }
    }

    public void onDestroy(){
        synchronized (mGiftTypeItemMap){
            mGiftTypeItemMap.clear();
        }
        synchronized (mOnGetGiftTypeListCallback){
            mOnGetGiftTypeListCallback.clear();
        }
        mIsGetVirtualGiftItems = false;
        mHandler.removeCallbacksAndMessages(null);
    }

}
