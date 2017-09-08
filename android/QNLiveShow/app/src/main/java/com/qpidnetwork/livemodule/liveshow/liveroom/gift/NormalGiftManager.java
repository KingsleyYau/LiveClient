package com.qpidnetwork.livemodule.liveshow.liveroom.gift;

import android.text.TextUtils;

import com.qpidnetwork.livemodule.httprequest.OnGetGiftDetailCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetGiftListCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetSendableGiftListCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniLiveShow;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.httprequest.item.SendableGiftItem;
import com.qpidnetwork.livemodule.liveshow.datacache.file.FileCacheManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.downloader.FileDownloadManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.downloader.IFileDownloadedListener;
import com.qpidnetwork.livemodule.utils.Log;
import com.qpidnetwork.livemodule.utils.SystemUtils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 礼物列表管理类
 * Created by Hunter Mun on 2017/6/21.
 */

public class NormalGiftManager {
    //-------------------------------单例模式，初始化-------------------

    private static NormalGiftManager mNormalGiftManager;

    public static NormalGiftManager getInstance(){
        if(mNormalGiftManager == null){
            mNormalGiftManager = new NormalGiftManager();
        }
        return mNormalGiftManager;
    }


    private NormalGiftManager(){

    }

    //------------------------------私有变量定义-------------------

    private final String TAG = NormalGiftManager.class.getSimpleName();


    /**
     * 当前用户的所有礼物数据
     */
    private Map<String, GiftItem> allGiftItems = new HashMap<>();

    /**
     * 所有未知的礼物详情数据，未知指的是本地没有包含该礼物id对应的礼物详情信息
     */
    private Map<String,List<GiftItem>> allRoomShowSendableGiftItems = new HashMap<>();


    //-----------------------------私有方法定义-------------------
    /**
     * 获取所有礼物配置详情
     * 在每次登录成功时刷新本地、进入房间时判断是否需要刷新
     * @param callback
     */
    public void getAllGiftItems(final OnGetGiftListCallback callback){
        RequestJniLiveShow.GetAllGiftList(new OnGetGiftListCallback() {
            @Override
            public void onGetGiftList(boolean isSuccess, int errCode, String errMsg, GiftItem[] giftList) {
                Log.d(TAG,"onGetAllGift-isSuccess:"+isSuccess+" errCode:"+errCode
                        +" errMsg:"+errMsg+" giftList:"+giftList);
                if(isSuccess && giftList != null){
                    int index = 0;
                    for(;index<giftList.length; index++){
                        GiftItem giftItem = giftList[index];
                        allGiftItems.put(giftItem.id,giftItem);
                    }
                    //下载礼物大图,放到获取sendable
                }
                if(null!=callback){
                    callback.onGetGiftList(isSuccess, errCode, errMsg, giftList);
                }
            }
        });
    }

    /**
     * 判断是否存在所有礼物配置详情缓存
     * @return
     */
    public boolean isLocalAllGiftItemsExisted(){
        return null != allGiftItems && allGiftItems.size()>0;
    }

    private boolean isGetDetailWhenSendableInited = false;


    /**
     * 获取当前用户房间内可以发送的礼物列表
     * 进入房间、每次打开礼物列表的时候本地判断是否需要刷新
     * @param roomid
     * @param callback
     */
    public void getSendableGiftList(final String roomid,
                                    final OnGetRoomShowSendableGiftListCallback callback){

        RequestJniLiveShow.GetSendableGiftList(roomid, new OnGetSendableGiftListCallback() {
            @Override
            public void onGetSendableGiftList(boolean isSuccess, int errCode,
                                              String errMsg, SendableGiftItem[] sendableGiftItems) {
                Log.d(TAG,"onGetAllGift-isSuccess:"+isSuccess+" errCode:"+errCode
                        +" errMsg:"+errMsg+" sendableGiftItems:"+sendableGiftItems);
                final List<GiftItem> canShowSendableGiftList = new ArrayList<GiftItem>();
                if(isSuccess && null != sendableGiftItems){
                    for (final SendableGiftItem sendableGiftItem : sendableGiftItems){
                        while(isGetDetailWhenSendableInited){
                            try {
                                Thread.sleep(200l);
                            } catch (InterruptedException e) {
                                e.printStackTrace();
                            }
                        }

                        if(!sendableGiftItem.isVisible){
                            continue;
                        }
                        if(allGiftItems.containsKey(sendableGiftItem.giftId)){
                            canShowSendableGiftList.add(allGiftItems.get(sendableGiftItem.giftId));
                        }else{
                            isGetDetailWhenSendableInited = true;
                            getGiftDetail(sendableGiftItem.giftId, new OnGetGiftDetailCallback() {
                                @Override
                                public void onGetGiftDetail(boolean isSuccess, int errCode, String errMsg, GiftItem giftDetail) {
                                    if(isSuccess){
                                        canShowSendableGiftList.add(giftDetail);
                                        isGetDetailWhenSendableInited = false;
                                    }
                                }
                            });
                        }
                    }

                    //直接put刷新
                    allRoomShowSendableGiftItems.put(roomid,canShowSendableGiftList);
                    //预下载
                    preDownGiftImage(canShowSendableGiftList);
                }

                if(null != callback){
                    callback.onGetRoomShowSendableGiftList(isSuccess,errCode,errMsg,canShowSendableGiftList);
                }
            }
        });
    }

    /**
     * 预下载大礼物文件-store
     */
    private void preDownGiftImage(List<GiftItem> sendableShowGiftItems){
        for(GiftItem giftItem : sendableShowGiftItems){
            if(giftItem.giftType == GiftItem.GiftType.Advanced){
                Log.d(TAG, "preDownGiftImage-giftItem.srcUrl:"+giftItem.srcWebpUrl);
                NormalGiftManager.getInstance().getGiftImage(giftItem.id, GiftImageType.Source, null);
            }
        }
    }

    /**
     * 获取本地缓存的roomId对方房间内可见可发送的礼物详情列表
     * @param roomId
     * @return
     */
    public List<GiftItem> getLocalRoomShowSendableGiftList(String roomId){
        return allRoomShowSendableGiftItems.get(roomId);
    }

    /**
     * 根据ID获取礼物详情
     * @param giftId
     */
    public void getGiftDetail(String giftId, final OnGetGiftDetailCallback callback){
        RequestJniLiveShow.GetGiftDetail(giftId, new OnGetGiftDetailCallback() {
            @Override
            public void onGetGiftDetail(boolean isSuccess, int errCode,
                                        String errMsg, GiftItem giftDetail) {
                Log.d(TAG,"onGetGiftDetail-isSuccess:"+isSuccess+" errCode:"
                        +errCode+" errMsg:"+errMsg+" giftDetail:"+giftDetail);
                if(isSuccess && null != giftDetail){
                    allGiftItems.put(giftDetail.id,giftDetail);
                }
                if(null != callback){
                    callback.onGetGiftDetail(isSuccess,errCode,errMsg,giftDetail);
                }

            }
        });
    }

    /**
     * 根据礼物ID，查询本地是否存在对应的礼物详情信息
     * @param giftId
     * @return
     */
    public GiftItem queryLocalGiftDetailById(String giftId){
        GiftItem giftDetail = null;
        if(null != allGiftItems && allGiftItems.containsKey(giftId)){
            giftDetail = allGiftItems.get(giftId);
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
                isExist = !TextUtils.isEmpty(localPath) && SystemUtils.fileExists(localPath);
            }
        }
        return  isExist;
    }

    /**
     * 下载礼物图片资源
     * @param giftId
     * @param imageType
     */
    public void getGiftImage(String giftId, GiftImageType imageType, final IFileDownloadedListener listener){
        GiftItem item = queryLocalGiftDetailById(giftId);
        if(item != null){
            String url = getImageUrlByType(item, imageType);
            if(!TextUtils.isEmpty(url)){
                String localPath = FileCacheManager.getInstance().getGiftLocalPath(giftId, url);
                if(!TextUtils.isEmpty(localPath) && SystemUtils.fileExists(localPath)){
                    //本地有礼物小图片，那么adapter就能够正常刷新，无需notif
                    //TODO:如果在进入直播间的瞬间刷新聊天栏，且这里立即通过回调onCompleted来notify Adapter，就会抛出异常，抽时间找出原因
                }else{
                    FileDownloadManager.getInstance().start(url, localPath, new IFileDownloadedListener(){
                        public void onCompleted(boolean isSuccess, String localFilePath, String fileUrl){
                            if(null != listener){
                                listener.onCompleted(isSuccess, localFilePath, fileUrl);
                            }
                        }
                    });
                }
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
    public interface OnGetRoomShowSendableGiftListCallback{
        void onGetRoomShowSendableGiftList(boolean isSuccess, int errCode, String errMsg, List<GiftItem> giftItems);
    }
}
