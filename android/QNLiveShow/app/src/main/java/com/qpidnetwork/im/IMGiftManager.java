package com.qpidnetwork.im;

import android.content.Context;
import android.text.TextUtils;

import com.qpidnetwork.httprequest.OnGetAllGiftCallback;
import com.qpidnetwork.httprequest.OnGetGiftDetailCallback;
import com.qpidnetwork.httprequest.RequestJniLiveShow;
import com.qpidnetwork.httprequest.item.GiftItem;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/**
 * 礼物列表管理类
 * Created by Hunter Mun on 2017/6/21.
 */

public class IMGiftManager {

    private HashMap<String, GiftItem> mGiftMap;         //礼物列表，建立索引方便查找

    private static IMGiftManager mIMGiftManager;

    public static IMGiftManager newInstance(){
        if(mIMGiftManager == null){
            mIMGiftManager = new IMGiftManager();
        }
        return mIMGiftManager;
    }

    public static IMGiftManager getInstance(){
        return mIMGiftManager;
    }

    private IMGiftManager(){
        mGiftMap = new HashMap<String, GiftItem>();
    }

    /**
     * 获取礼物列表本地配置
     * @param callback
     */
    public long getAllGiftConfig(final OnGetAllGiftCallback callback){
        return RequestJniLiveShow.GetAllGiftList(new OnGetAllGiftCallback() {
            @Override
            public void onGetAllGift(boolean isSuccess, int errCode, String errMsg, GiftItem[] giftList) {
                if(isSuccess && giftList != null){
                    addToLoaclMap(giftList);
                }
                callback.onGetAllGift(isSuccess, errCode, errMsg, giftList);
            }
        });
    }

    /**
     * 获取礼物详情
     * @param giftId
     */
    public long getGiftDetailById(String giftId, final OnGetGiftDetailCallback callback){
        return RequestJniLiveShow.GetGiftDetail(giftId, new OnGetGiftDetailCallback() {
            @Override
            public void onGetGiftDetail(boolean isSuccess, int errCode, String errMsg, GiftItem giftDetail) {
                if(isSuccess && giftDetail != null){
                    addToLocalMap(giftDetail);
                }
                if(callback != null){
                    callback.onGetGiftDetail(isSuccess, errCode, errMsg, giftDetail);
                }
            }
        });
    }

    /**
     * 获取本地缓存礼物详情
     * @param giftId
     * @return
     */
    public GiftItem getLocalGiftDetailById(String giftId){
        GiftItem item = null;
        synchronized (mGiftMap){
            if(mGiftMap.containsKey(giftId)){
                item = mGiftMap.get(giftId);
            }
        }
        return item;
    }

    /**
     * 获取指定礼物详情列表
     * @param giftIds
     * @return
     */
    public List<GiftItem> getLoaclGiftItems(List<String> giftIds){
        List<GiftItem> giftList = new ArrayList<GiftItem>();
        for(String giftId : giftIds){
            GiftItem giftItem = getLocalGiftDetailById(giftId);
            if(giftItem != null){
                giftList.add(giftItem);
            }
        }
        return  giftList;
    }

    /**
     * 更新到本地配置
     * @param giftItems
     */
    private void addToLoaclMap(GiftItem[] giftItems){
        if(giftItems != null){
            for(GiftItem item : giftItems){
                addToLocalMap(item);
            }
        }
    }

    /**
     * 添加到本地配置
     * @param giftItem
     */
    private void addToLocalMap(GiftItem giftItem){
        if(giftItem != null && !TextUtils.isEmpty(giftItem.id)){
            synchronized (mGiftMap){
                if(!mGiftMap.containsKey(giftItem.id)){
                    mGiftMap.put(giftItem.id, giftItem);
                }
            }
        }
    }
}
