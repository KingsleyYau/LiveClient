package com.qpidnetwork.livemodule.liveshow.liveroom.gift;

import com.qpidnetwork.livemodule.httprequest.OnGetPackageGiftListCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniPackage;
import com.qpidnetwork.livemodule.httprequest.item.PackageGiftItem;
import com.qpidnetwork.livemodule.utils.Log;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 礼物列表管理类
 * Created by Hunter Mun on 2017/6/21.
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

    //用户我的背包-礼物展示
    private Map<String, List<PackageGiftItem>> allPackageGiftItemList = new HashMap<>();
    //用于直播间-背包礼物数量展示
    private Map<String, Integer> allPackageGiftNumList = new HashMap<>();
    //-----------------------------私有方法定义-------------------

    /**
     * 本地背包列表数据刷新
     * @param callback
     */
    public void getAllPackageGiftItems(final OnGetPackageGiftListCallback callback){
        boolean isLocalExisted = isLocalPackageGiftListExist();
        if(!isLocalExisted){
            Log.d(TAG,"getAllPackageGiftItems-isLocalExisted:"+isLocalExisted);
            RequestJniPackage.GetPackageGiftList(new OnGetPackageGiftListCallback() {
                @Override
                public void onGetPackageGiftList(boolean isSuccess, int errCode, String errMsg, PackageGiftItem[] packageGiftList) {
                    Log.d(TAG,"onGetPackageGiftList-isSuccess:"+isSuccess+" errCode:"
                            +" errMsg:"+errMsg+" packageGiftList:"+packageGiftList);

                    if(isSuccess && null != packageGiftList){
                        allPackageGiftNumList.clear();
                        allPackageGiftItemList.clear();
                        for (PackageGiftItem packageGiftItem : packageGiftList){
                            List<PackageGiftItem> packageGiftItemList = new ArrayList<PackageGiftItem>();
                            if(allPackageGiftItemList.containsKey(packageGiftItem.giftId)){
                                packageGiftItemList = allPackageGiftItemList.get(packageGiftItem.giftId);
                            }
                            packageGiftItemList.add(packageGiftItem);
                            allPackageGiftItemList.put(packageGiftItem.giftId,packageGiftItemList);

                            int totalNum = allPackageGiftNumList.containsKey(packageGiftItem.giftId) ?
                                    allPackageGiftNumList.get(packageGiftItem.giftId) : 0;
                            totalNum+=packageGiftItem.num;
                            allPackageGiftNumList.put(packageGiftItem.giftId,totalNum);
                        }
                    }
                    if(null != callback){
                        callback.onGetPackageGiftList(isSuccess,errCode,errMsg,packageGiftList);
                    }

                }
            });
        }
    }

    public boolean isLocalPackageGiftListExist(){
        return null != allPackageGiftItemList && null != allPackageGiftNumList
                && allPackageGiftItemList.size() ==  allPackageGiftNumList.size();
    }

    /**
     *
     * 直播间 背包礼物数据
     * @return
     */
    public Map<String, List<PackageGiftItem>> getLocalAllPackageGiftItemList(){
        return allPackageGiftItemList;
    }

    public int getPackageGiftNumById(String giftId){
        int num = 0;
        if(allPackageGiftNumList.containsKey(giftId)){
            num = allPackageGiftNumList.get(giftId);
        }
        return num;
    }

    public boolean subPackageGiftNumById(String giftId,int num){
        boolean result = false;
        if(allPackageGiftNumList.containsKey(giftId) && allPackageGiftItemList.containsKey(giftId)){
            int totalNum = allPackageGiftNumList.get(giftId);
            totalNum-=num;
            if(totalNum>0){
                allPackageGiftNumList.put(giftId,totalNum);
            }else{
                allPackageGiftNumList.remove(giftId);
                allPackageGiftItemList.remove(giftId);
            }
            result = true;
        }
        return result;
    }
}
