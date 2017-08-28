package com.qpidnetwork.livemodule.im;

import android.text.TextUtils;
import com.qpidnetwork.livemodule.httprequest.OnGetGiftDetailCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetGiftListCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetSendableGiftListCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniLiveShow;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.liveshow.datacache.file.FileCacheManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.Gift;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.Pack;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.downloader.FileDownloadManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.downloader.IFileDownloadedListener;
import com.qpidnetwork.livemodule.utils.Log;
import com.qpidnetwork.livemodule.utils.SystemUtils;

import java.util.HashMap;
import java.util.Map;

/**
 * 礼物列表管理类
 * Created by Hunter Mun on 2017/6/21.
 */

public class IMGiftManager {
    //-------------------------------单例模式，初始化-------------------

    private static IMGiftManager mIMGiftManager;

    public static IMGiftManager getInstance(){
        if(mIMGiftManager == null){
            mIMGiftManager = new IMGiftManager();
        }
        return mIMGiftManager;
    }


    private IMGiftManager(){

    }

    //------------------------------私有变量定义-------------------
    /**
     * 礼物图片类型
     */
    public enum GiftImageType{
        Default,
        Thumb,
        ListDrawable,
        Source
    }

    /**
     * 礼物种类标题
     */
    public final static String[] giftTabs = {
            "Store",
            "Backpack"
    };

    private final String TAG = IMGiftManager.class.getSimpleName();

    /**
     * 礼物种类
     */
    public enum GiftTab{
        STORE,
        BACKPACK
    }

    /**
     * 当前用户的所有礼物数据
     */
    private Map<String, Gift> allGifts = new HashMap<>();

    /**
     * 当前用户的所有背包数据
     */
    private Map<String, Pack> allPacks = new HashMap<>();

    /**
     * 所有未知的礼物详情数据，未知指的是本地没有包含该礼物id对应的礼物详情信息
     */
    private Map<String,GiftItem> allUnknowGiftDetails = new HashMap<>();


    //-----------------------------私有方法定义-------------------
    /**
     * 获取所有礼物列表
     * @param callback
     */
    public void getAllStoreGifts(final OnGetAllGiftListener callback){
        // 暂时通过调用旧的JNI接口来制造假的数据源
        RequestJniLiveShow.GetAllGiftList(new OnGetGiftListCallback() {
            @Override
            public void onGetGiftList(boolean isSuccess, int errCode, String errMsg, GiftItem[] giftList) {
                Log.d(TAG,"onGetAllGift-isSuccess:"+isSuccess+" errCode:"+errCode
                        +" errMsg:"+errMsg+" giftList:"+giftList);
                Gift[] gifts = null;
                if(isSuccess && giftList != null){
                    gifts = new Gift[giftList.length];
                    int index = 0;
                    for(;index<giftList.length; index++){
                        GiftItem giftItem = giftList[index];
                        giftItem.name = "st_"+giftItem.name;
                        Gift gift = new Gift(giftItem, new int[]{index+1,index+2,index+3});
                        gifts[index] = gift;
                        allGifts.put(gift.giftItem.id,gift);
                    }
                }
                if(null!=callback){
                    callback.onGetAllGift(isSuccess, errCode, errMsg, gifts);
                }
            }
        });
    }

    /**
     * 获取背包列表
     * @param callback
     */
    public void getAllBackpackGifts(final OnGetAllBackpackGiftListener callback){
        // 暂时通过调用旧的JNI接口来制造假的数据源
        RequestJniLiveShow.GetAllGiftList(new OnGetGiftListCallback() {
            @Override
            public void onGetGiftList(boolean isSuccess, int errCode,
                                     String errMsg, GiftItem[] giftList) {
                Log.d(TAG,"onGetAllGift-isSuccess:"+isSuccess+" errCode:"+errCode
                        +" errMsg:"+errMsg+" giftList:"+giftList);
                Pack[] packs = null;

                if(isSuccess && giftList != null){
                    packs = new Pack[giftList.length];
                    int index = 0;
                    for(;index<giftList.length; index++){
                        GiftItem giftItem = giftList[index];
                        giftItem.name = "bp_"+giftItem.name;
                        Pack pack = new Pack(giftList[index], index+5,giftItem.updateTime,
                                giftItem.updateTime+3600l,
                                new int[]{index+1,index+2,index+3});
                        packs[giftList.length-1-index] = pack;
                        allPacks.put(pack.giftItem.id,pack);
                    }


                }
                if(null!=callback){
                    callback.onGetAllBackpackGift(isSuccess, errCode, errMsg, packs);
                }
            }
        });
    }

    /**
     * 获取当前用户房间内可以发送的礼物列表
     * @param roomid
     * @param callback
     */
    public void getSendableGiftList(String roomid,
                                    final OnGetSendableGiftListCallback callback){
        //1.视图层通过该接口，触发对Jni.getGiftListByUserid的调用
        //2.接口可以直接回调视图层，也可以通过OnGetGiftListListener进行中转
        //3.视图层在获取到可用礼物ID数组之后，调用getGiftDetailById进行界面数据的刷新显示
        RequestJniLiveShow.GetSendableGiftList(roomid,callback);
    }

    /**
     * 根据ID获取礼物详情
     * @param giftId
     */
    public void getGiftDetail(String giftId, final OnGetGiftDetailCallback callback){
        GiftItem giftDetail = queryLocalGiftDetailById(giftId);
        if(null != giftDetail && null != callback){
            callback.onGetGiftDetail(true, 0,"",giftDetail);
        }else{
            //这里将会调用Jni.getGiftDetail，
            //1.调用接口
            //2.在接口回调内，首先将拿到的GiftDetail数据put到allUnknowGiftDetails中
            //3.而后调用callback.onGetGiftDetail
            RequestJniLiveShow.GetGiftDetail(giftId, new OnGetGiftDetailCallback() {
                @Override
                public void onGetGiftDetail(boolean isSuccess, int errCode,
                                            String errMsg, GiftItem giftDetail) {
                    Log.d(TAG,"onGetGiftDetail-isSuccess:"+isSuccess+" errCode:"
                            +errCode+" errMsg:"+errMsg+" giftDetail:"+giftDetail);
                    if(isSuccess && null != giftDetail){
                        allUnknowGiftDetails.put(giftDetail.id,giftDetail);
                    }
                    if(null != callback){
                        callback.onGetGiftDetail(isSuccess,errCode,errMsg,giftDetail);
                    }

                }
            });
        }
    }

    /**
     * 根据giftId获取本地缓存的Gift
     * @param giftId
     * @return
     */
    public Gift getLocalGiftById(String giftId){
        Gift gift = null;
        if(null != allGifts && allGifts.containsKey(giftId)){
            gift = allGifts.get(giftId);
        }
        return gift;
    }

    /**
     * 根据礼物ID，查询本地是否存在对应的礼物详情信息
     * @param giftId
     * @return
     */
    public GiftItem queryLocalGiftDetailById(String giftId){
        GiftItem giftDetail = null;
        if(null != allGifts && allGifts.containsKey(giftId)){
            giftDetail = allGifts.get(giftId).giftItem;
        }else if(null != allPacks && allPacks.containsKey(giftId)){
            giftDetail = allPacks.get(giftId).giftItem;
        }else if(null != allUnknowGiftDetails && allUnknowGiftDetails.containsKey(giftId)){
            giftDetail = allUnknowGiftDetails.get(giftId);
        }else{
            giftDetail = null;
        }

        Log.d(TAG,"queryLocalGiftDetailById-giftId:"+giftId+" giftDetail:"+giftDetail);
        return giftDetail;
    }

    /**
     * 本地是否存在图片
     * @param giftId
     * @param imageType
     * @return
     */
    public boolean isGiftLocalPictureExist(String giftId, GiftImageType imageType){
        boolean isExist = false;
        GiftItem item = queryLocalGiftDetailById(giftId);
        if(item != null) {
            String url = getImageUrlByType(item, imageType);
            if(!TextUtils.isEmpty(url)) {
                String localPath = FileCacheManager.getInstance().getGiftLocalPath(giftId, url);
                if(!TextUtils.isEmpty(localPath)
                        && SystemUtils.fileExists(localPath)){
                    isExist = true;
                }
            }
        }
        return  isExist;
    }

    /**
     * 下载礼物小图
     * @param giftId
     * @param imageType
     */
    public void getGiftImage(String giftId, GiftImageType imageType, final IFileDownloadedListener listener){
        GiftItem item = queryLocalGiftDetailById(giftId);
        if(item != null){
            String url = getImageUrlByType(item, imageType);
            if(!TextUtils.isEmpty(url)){
                String localPath = FileCacheManager.getInstance().getGiftLocalPath(giftId, url);
                FileDownloadManager.getInstance().start(url, localPath, new IFileDownloadedListener(){
                    public void onCompleted(boolean isSuccess, String localFilePath, String fileUrl){
                        listener.onCompleted(isSuccess, localFilePath, fileUrl);
                    }
                });
            }
        }
    }

    /**
     * 根据类型获取指定url
     * @param giftItem
     * @param imageType
     * @return
     */
    private String getImageUrlByType(GiftItem giftItem, GiftImageType imageType){
        String url = "";
        if(giftItem != null){
            switch (imageType){
                case Thumb:{
                    url = giftItem.smallImgUrl;
                }break;
                case ListDrawable:{
                    url = giftItem.middleImgUrl;
                }break;
                case Source:{
                    url = giftItem.srcWebpUrl;
                }break;
                default:
                    break;
            }
        }
        return url;
    }

    //-----------------------------Callback定义---------------------
    public interface OnGetAllGiftListener {
        void onGetAllGift(boolean isSuccess, int errCode,
                          String errMsg, Gift[] gifts);
    }

    public interface OnGetAllBackpackGiftListener{
        void onGetAllBackpackGift(boolean isSuccess, int errCode,
                                  String errMsg, Pack[] packs);
    }
}
