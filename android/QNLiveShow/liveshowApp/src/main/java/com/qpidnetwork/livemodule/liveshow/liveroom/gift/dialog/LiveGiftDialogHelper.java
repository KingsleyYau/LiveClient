package com.qpidnetwork.livemodule.liveshow.liveroom.gift.dialog;

import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.httprequest.item.PackageGiftItem;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.GiftTab;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/**
 * 用于处理不同界面共享部分数据（共享内存实现）
 * ps：此类仅限于配合LiveGiftDialog使用
 * Created by Hunter on 18/7/5.
 */

public class LiveGiftDialogHelper {
    //当前所在页
    private GiftTab.GiftTabFlag mCurrentTab;

    //对应tab store 本地数据缓存
    private List<GiftItem> mGiftDialogNormalGiftList;
    //对应tab package 本地数据缓存
    private List<PackageGiftItem> mGiftDialogPackageGiftList;
    //用于缓存tab内部数据
    private HashMap<GiftTab.GiftTabFlag, GiftTabCache> mGiftTabCacheMap;
    //男士等级
    private int mManLevel;
    //男士与当前直播间主播亲密度
    private int mRoomLoveLevel;

    public LiveGiftDialogHelper(){
        mCurrentTab = GiftTab.GiftTabFlag.STORE;
        mGiftDialogNormalGiftList = new ArrayList<GiftItem>();
        mGiftDialogPackageGiftList = new ArrayList<PackageGiftItem>();
        mGiftTabCacheMap = new HashMap<GiftTab.GiftTabFlag, GiftTabCache>();
        mManLevel = 0;
        mRoomLoveLevel = 0;
    }

    /**
     * 更新用户信息
     * @param manLevel
     */
    public void updateManLevel(int manLevel){
        mManLevel = manLevel;
    }

    /**
     * 更新用户与直播间主播亲密度
     * @param roomLoveLevel
     */
    public void updateRoomLevel(int roomLoveLevel){
        mRoomLoveLevel = roomLoveLevel;
    }

    /**
     * 检测用户等级和房间亲密度是否满足礼物设置
     * @param giftItem
     * @return
     */
    public boolean checkGiftSendable(GiftItem giftItem){
        boolean isSendadle = true;
        if(giftItem.lovelevelLimit > mRoomLoveLevel || giftItem.levelLimit > mManLevel){
            isSendadle = false;
        }
        return isSendadle;
    }

    /**
     * 读取直播间男士等级
     * @return
     */
    public int getRoomManLevel(){
        return mManLevel;
    }

    /**
     * 读取直播间用户主播亲密度
     * @return
     */
    public int getRoomLoveLevel(){
        return mRoomLoveLevel;
    }

    /**
     * 更新当前tab选中分页
     * @param giftTab
     * @param currentIndex
     */
    public void updateGiftTabPageIndex(GiftTab.GiftTabFlag giftTab, int currentIndex){
        getLoacalGiftTabCache(giftTab).mCurrentPageIndex = currentIndex;
    }

    /**
     * 更新当前tab选中礼物Id
     * @param giftTab
     * @param giftId
     */
    public void updateGiftTabSelectedGiftId(GiftTab.GiftTabFlag giftTab, String giftId){
        getLoacalGiftTabCache(giftTab).mGiftId = giftId;
    }

    /**
     * 读取当前分页选中分页index
     * @param giftTab
     * @return
     */
    public int getGiftTabSelectedPageIndex(GiftTab.GiftTabFlag giftTab){
        return getLoacalGiftTabCache(giftTab).mCurrentPageIndex;
    }

    /**
     * 读取当前tab选中礼物Id
     * @param giftTab
     * @return
     */
    public String getGiftTabSelectedGiftId(GiftTab.GiftTabFlag giftTab){
        return getLoacalGiftTabCache(giftTab).mGiftId;
    }

    /**
     * 读取本地缓存tab信息，如果没有则新建
     * @param giftTab
     * @return
     */
    private GiftTabCache getLoacalGiftTabCache(GiftTab.GiftTabFlag giftTab){
        GiftTabCache cache = null;
        if(!mGiftTabCacheMap.containsKey(giftTab)){
            cache = new GiftTabCache();
            mGiftTabCacheMap.put(giftTab, cache);
        }else{
            cache = mGiftTabCacheMap.get(giftTab);
        }
        return cache;
    }

    /**
     * 重置清除本地数据
     */
    public void resetAndClear(){
        mCurrentTab = GiftTab.GiftTabFlag.STORE;
        mGiftDialogNormalGiftList.clear();
        mGiftDialogPackageGiftList.clear();
        mGiftTabCacheMap.clear();
    }

    private class GiftTabCache{
        public int mCurrentPageIndex;       //停留当前tab中的页码
        public String mGiftId;              //当前page选中的礼物Id

        public GiftTabCache(){
            mCurrentPageIndex = 0;
            mGiftId = "";
        }
    }

    //==========================    2019/09/04 Hardy ================================
    private boolean isPackageListSuccess;
    private boolean isSendableListSuccess;

    public boolean isPackageListSuccess() {
        return isPackageListSuccess;
    }

    public void setPackageListSuccess(boolean packageListSuccess) {
        isPackageListSuccess = packageListSuccess;
    }

    public boolean isSendableListSuccess() {
        return isSendableListSuccess;
    }

    public void setSendableListSuccess(boolean sendableListSuccess) {
        isSendableListSuccess = sendableListSuccess;
    }
}
