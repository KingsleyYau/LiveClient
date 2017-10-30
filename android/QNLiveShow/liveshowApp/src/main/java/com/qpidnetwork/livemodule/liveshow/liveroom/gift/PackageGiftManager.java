package com.qpidnetwork.livemodule.liveshow.liveroom.gift;

import android.text.TextUtils;

import com.qpidnetwork.livemodule.httprequest.OnGetGiftDetailCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetPackageGiftListCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniPackage;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.httprequest.item.PackageGiftItem;
import com.qpidnetwork.livemodule.liveshow.model.HttpReqStatus;
import com.qpidnetwork.livemodule.utils.Log;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 礼物列表管理类
 * Created by Hunter Mun on 2017/6/21.
 * 1.在登录live模块，成功调用http接口文档的3.5 获取礼物列表接口的情况下，调用5.1 获取背包礼物接口，本地缓存
 */

public class PackageGiftManager {
    //-------------------------------单例模式，初始化-------------------

    private static PackageGiftManager mNormalGiftManager;

    public static PackageGiftManager getInstance(){
        if(mNormalGiftManager == null){
            mNormalGiftManager = new PackageGiftManager();
        }
        return mNormalGiftManager;
    }


    private PackageGiftManager(){

    }

    //------------------------------私有变量定义-------------------

    private final String TAG = PackageGiftManager.class.getSimpleName();

    //用于直播间-背包礼物-界面刷新
    private List<PackageGiftItem> allPackageGiftItems = new ArrayList<>();

    private List<GiftItem> packageGiftItems = new ArrayList<>();
    private Map<String, Integer> allPackageGiftNumList = new HashMap<>();

    //1.dialog需要刷新adapter显示背包列表，所以需要list，或者遍历map生成list
    //2.dialog需要显示背包item的数量，因此需要map获取int
    //3.背包也需要动态显示可选数量
    public HttpReqStatus packageGiftReqStatus = HttpReqStatus.NoReq;

    public String currRoomId="";
    //-----------------------------私有方法定义-------------------

    /**
     * 本地背包列表数据刷新
     * @param callback
     */
    public void getAllPackageGiftItems(final OnGetPackageGiftListCallback callback){
        if((null != allPackageGiftItems && allPackageGiftItems.size()> 0) || HttpReqStatus.ReqSuccess == packageGiftReqStatus){
            Log.d(TAG,"getAllPackageGiftItems-本地已经成功请求过或已存在背包礼物配置信息");
            if(null != callback){
//                PackageGiftItem[] packageGiftList = new PackageGiftItem[allPackageGiftItems.size()];
//                for(int index = 0; index<allPackageGiftItems.size(); index++){
//                    packageGiftList[index]=allPackageGiftItems.get(index);
//                }
                callback.onGetPackageGiftList(true, 0, "", null, 0);
            }
            updatePackageGift();
        }else{
            Log.d(TAG,"getAllPackageGiftItems-本地不存在背包礼物配置信息，发起GetPackageGiftList请求");
            if(HttpReqStatus.Reqing == packageGiftReqStatus){
                return;
            }
            packageGiftReqStatus = HttpReqStatus.Reqing;
            RequestJniPackage.GetPackageGiftList(new OnGetPackageGiftListCallback() {
                @Override
                public void onGetPackageGiftList(boolean isSuccess, int errCode, String errMsg, PackageGiftItem[] packageGiftList, int totalCount) {
                    Log.d(TAG,"onGetPackageGiftList-isSuccess:"+isSuccess+" errCode:"
                            +" errMsg:"+errMsg+" packageGiftList:"+packageGiftList);
                    if(isSuccess){
                        packageGiftReqStatus = HttpReqStatus.ReqSuccess;
                        allPackageGiftItems.clear();
                        if(null == packageGiftList){
                            return;
                        }
                        allPackageGiftItems.addAll(Arrays.asList(packageGiftList));
                    }else{
                        packageGiftReqStatus = HttpReqStatus.ResFailed;
                    }
                    if(null != callback){
                        callback.onGetPackageGiftList(isSuccess, errCode, errMsg, packageGiftList, totalCount);
                    }
                    if(isSuccess){
                        updatePackageGift();
                    }
                }
            });
        }
    }



    private int showPkgGiftNum = 0;
    public synchronized void updatePackageGift(){
        boolean allPackageGiftConfigInited = null != allPackageGiftItems && allPackageGiftItems.size()>0;
        boolean allGiftConfigInited = NormalGiftManager.getInstance().isLocalAllGiftConfigExisted();
        boolean roomSendableGiftConfigInited = NormalGiftManager.getInstance().isLocalRoomSendableGiftExisted(currRoomId);
        Log.d(TAG,"updatePackageGift-allPackageGiftConfigInited:"+allPackageGiftConfigInited
                +" allGiftConfigInited:"+allGiftConfigInited
                +" roomSendableGiftConfigInited:"+roomSendableGiftConfigInited
                +" roomId:"+currRoomId);
        if(!TextUtils.isEmpty(currRoomId) && !TextUtils.isEmpty(NormalGiftManager.getInstance().currRoomId)
                && currRoomId.equals(NormalGiftManager.getInstance().currRoomId)){
            if(allPackageGiftConfigInited && allGiftConfigInited && roomSendableGiftConfigInited){
                packageGiftItems.clear();
                allPackageGiftNumList.clear();
                showPkgGiftNum = 0;
                for(int index=0; index<allPackageGiftItems.size(); index++){
                    PackageGiftItem packageGiftItem = allPackageGiftItems.get(index);
                    if(!allPackageGiftNumList.containsKey(packageGiftItem.giftId)){
                        allPackageGiftNumList.put(packageGiftItem.giftId,packageGiftItem.num);
                        showPkgGiftNum+=1;
                    }
                }
                Log.d(TAG,"updatePackageGift-showPkgGiftNum:"+showPkgGiftNum);
                allPackageGiftNumList.clear();
                for (final PackageGiftItem packageGiftItem : allPackageGiftItems){
                    //接下来拿礼物详情
                    NormalGiftManager.getInstance().getGiftDetail(packageGiftItem.giftId, new OnGetGiftDetailCallback() {
                        @Override
                        public void onGetGiftDetail(boolean isSuccess, int errCode, String errMsg, GiftItem giftDetail) {
                            if(isSuccess && null != giftDetail){
                                if(!packageGiftItems.contains(giftDetail)){
                                    packageGiftItems.add(giftDetail);
                                }
                                int totalNumbs = 0;
                                if(allPackageGiftNumList.containsKey(giftDetail.id)){
                                    totalNumbs = allPackageGiftNumList.get(giftDetail.id);
                                }
                                totalNumbs+=packageGiftItem.num;
                                allPackageGiftNumList.put(giftDetail.id,totalNumbs);
                            }
                            Log.d(TAG,"updatePackageGift-showPkgGiftNum:"+showPkgGiftNum+" packageGiftItems.size():"+packageGiftItems.size());
                            if(packageGiftItems.size() == showPkgGiftNum && listeners != null && listeners.containsKey(currRoomId)){
                                listeners.get(currRoomId).onPackageGiftDataChanged(currRoomId);
                            }
                        }
                    });
                }
            }
        }
    }

    public List<GiftItem> getLocalPackageGiftDetails(){
        return packageGiftItems;
    }

    public Map<String,Integer> getLocalPackageGiftNumData(){
        return allPackageGiftNumList;
    }

    //------------------------------自定义接口-------------------


    private Map<String,OnPackageGiftDataChangeListener> listeners = new HashMap<>();

    public void registerListener(String roomId,OnPackageGiftDataChangeListener listener){
        Log.d(TAG,"registerListener-roomId:"+roomId);
        if(null != listeners && !listeners.containsKey(roomId)){
            listeners.put(roomId,listener);
        }
    }

    public void unregisterListener(String roomId){
        Log.d(TAG,"unregisterListener-roomId:"+roomId);
        if(null != listeners && listeners.containsKey(roomId)){
            listeners.remove(roomId);
        }
    }

    public interface OnPackageGiftDataChangeListener {
        void onPackageGiftDataChanged(String currRoomId);
    }
}
