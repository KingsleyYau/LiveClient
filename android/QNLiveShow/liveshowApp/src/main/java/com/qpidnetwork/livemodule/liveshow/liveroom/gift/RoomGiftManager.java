package com.qpidnetwork.livemodule.liveshow.liveroom.gift;

import com.qpidnetwork.livemodule.httprequest.OnGetPackageGiftListCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetSendableGiftListCallback;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.httprequest.item.PackageGiftItem;
import com.qpidnetwork.livemodule.httprequest.item.SendableGiftItem;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.normal.RoomPackageGiftManager;

import java.util.List;

/**
 * 房间礼物管理器
 *  1.可发送礼物列表管理；
 *  2.房间背包礼物管理；
 * 注意：此类使用必须在主线程初始化，内部handler未绑定自己looper
 * Created by Hunter on 18/6/20.
 */

public class RoomGiftManager {

    private final String TAG = RoomGiftManager.class.getSimpleName();
    //data
    private IMRoomInItem mIMRoomInItem;                                                 //当前房间Id
    private RoomSendableGiftManager mRoomSendableGiftManager;               //房间可发送礼物列表管理器
    private RoomPackageGiftManager mRoomPackageGiftManager;                 //房间背包礼物管理类

    public RoomGiftManager(IMRoomInItem imRoomInItem){
        this.mIMRoomInItem = imRoomInItem;
        mRoomSendableGiftManager = new RoomSendableGiftManager(mIMRoomInItem);
        mRoomPackageGiftManager = new RoomPackageGiftManager(mRoomSendableGiftManager);
    }

    /**
     * 2019/9/4 Hardy
     * 获取房间信息
     */
    public IMRoomInItem getIMRoomInItem() {
        return mIMRoomInItem;
    }

    /**
     * 刷新可发送列表列表
     * @param callback
     */
    public void getSendableGiftList(OnGetSendableGiftListCallback callback){
        mRoomSendableGiftManager.getSendableGiftList(callback);
    }

    /**
     * 获取本地可发送列表(过滤本地详情必须存在，否则过滤掉并同步礼物详情)
     * @return
     */
    public List<GiftItem>  getLocalSendableList(){
        return mRoomSendableGiftManager.getLocalSendableList();
    }

    /**
     * 获取可推荐列表
     * @return
     */
    public List<GiftItem> getFilterRecommandGiftList(){
        return  mRoomSendableGiftManager.getLocalRecommandGiftList();
    }

    /**
     * 刷新背包列表(每次都要与服务器同步)
     * @param callback
     */
    public void getPackageGiftItems(final OnGetPackageGiftListCallback callback){
        mRoomPackageGiftManager.getPackageGiftItems(callback);
    }

    /**
     * 获取房间可发送列表（检测本地已经有礼物详情）
     * @return
     */
    public List<PackageGiftItem> getLoaclRoomPackageGiftList(){
        return mRoomPackageGiftManager.getLoaclRoomPackageGiftList();
    }

    /**
     * 根据礼物id获取背包详情
     * @param giftId
     * @return
     */
    public PackageGiftItem getLocalPackageItem(String giftId){
        return mRoomPackageGiftManager.getLocalPackageItem(giftId);
    }

    /**
     * 从本地移除已发送完礼物
     * @param giftId
     * @return
     */
    public PackageGiftItem removeLocalPackageItem(String giftId){
        return mRoomPackageGiftManager.removeLocalPackageItem(giftId);
    }

    /**
     * 查询当前礼物是否可以发送
     * @param giftId
     * @return
     */
    public boolean checkGiftSendable(String giftId){
        boolean canSendable = false;
        if(mRoomSendableGiftManager != null){
            canSendable = mRoomSendableGiftManager.checkGiftSendable(giftId);
        }
        return canSendable;
    }

    //回收数据
    public void onDestroy(){
        if(mRoomSendableGiftManager != null){
            mRoomSendableGiftManager.onDestroy();
        }
    }

    //***************************** 2019/9/3    Hardy   ************************************

    public SendableGiftItem getSendableGiftItem(String giftId){
        if(mRoomSendableGiftManager != null){
            return mRoomSendableGiftManager.getSendableGiftItem(giftId);
        }
        return null;
    }
}
