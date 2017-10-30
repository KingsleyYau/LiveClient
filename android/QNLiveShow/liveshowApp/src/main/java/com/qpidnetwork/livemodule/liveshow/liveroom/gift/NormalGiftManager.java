package com.qpidnetwork.livemodule.liveshow.liveroom.gift;

import android.text.TextUtils;

import com.qpidnetwork.livemodule.httprequest.OnGetGiftDetailCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetGiftListCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetSendableGiftListCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniLiveShow;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.httprequest.item.SendableGiftItem;
import com.qpidnetwork.livemodule.liveshow.datacache.file.FileCacheManager;
import com.qpidnetwork.livemodule.liveshow.datacache.file.downloader.FileDownloadManager;
import com.qpidnetwork.livemodule.liveshow.datacache.file.downloader.IFileDownloadedListener;
import com.qpidnetwork.livemodule.liveshow.model.HttpReqStatus;
import com.qpidnetwork.livemodule.utils.IPConfigUtil;
import com.qpidnetwork.livemodule.utils.Log;
import com.qpidnetwork.livemodule.utils.SystemUtils;

import java.util.ArrayList;
import java.util.Arrays;
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
    public HttpReqStatus allGiftConfigReqStatus = HttpReqStatus.NoReq;
    private Map<String, HttpReqStatus> roomSendableGiftReqStatusList = new HashMap<>();

    /**
     * 当前用户的所有礼物数据
     */
    private Map<String, GiftItem> allGiftItems = new HashMap<>();

    /**
     * 所有未知的礼物详情数据，未知指的是本地没有包含该礼物id对应的礼物详情信息
     */
    private Map<String,GiftItem> allUnkonwGiftItems = new HashMap<>();
    /**
     * 直播间可发送礼物关系影射表
     */
    private Map<String,List<SendableGiftItem>> allRoomSendableGiftItemConfigs = new HashMap<>();
    private Map<String,List<GiftItem>> allRoomSendableGiftItems = new HashMap<>();

    public String currRoomId = "";

    //-----------------------------私有方法定义-------------------

    /**
     * 获取所有礼物配置详情
     * 在每次登录成功时刷新本地、进入房间时判断是否需要刷新
     * @param callback
     */
    public void getAllGiftItems(final OnGetGiftListCallback callback){
        if(allGiftConfigReqStatus != HttpReqStatus.ReqSuccess && !isLocalAllGiftConfigExisted()){
            Log.d(TAG,"onGetAllGift-未初始化所有礼物配置信息，发起GetAllGiftList请求");
            allGiftConfigReqStatus = HttpReqStatus.Reqing;
            RequestJniLiveShow.GetAllGiftList(new OnGetGiftListCallback() {
                @Override
                public void onGetGiftList(boolean isSuccess, int errCode, String errMsg, GiftItem[] giftList) {
                    Log.d(TAG,"onGetAllGift-isSuccess:"+isSuccess+" errCode:"+errCode +" errMsg:"+errMsg);
                    if(isSuccess){
                        allGiftConfigReqStatus = HttpReqStatus.ReqSuccess;
                        allGiftItems.clear();
                        if(giftList == null){
                            return;
                        }
                        Log.d(TAG,"onGetGiftList-giftList.length:"+giftList.length);
                        int index = 0;
                        synchronized (allGiftItems){
                            for(;index<giftList.length; index++){
                                GiftItem giftItem = giftList[index];
                                if(IPConfigUtil.isSimulatorEnv){
                                    giftItem.smallImgUrl = IPConfigUtil.getGiftNormalImgUrl(giftItem.id);
                                    giftItem.middleImgUrl = IPConfigUtil.getGiftNormalImgUrl(giftItem.id);
                                    giftItem.bigImageUrl = IPConfigUtil.getGiftNormalImgUrl(giftItem.id);
                                    if(giftItem.giftType == GiftItem.GiftType.Advanced){
                                        giftItem.srcWebpUrl = IPConfigUtil.getGiftAdvanceAnimImgUrl(giftItem.id);
                                    }
                                }
                                if(null == allGiftItems){
                                    allGiftItems = new HashMap<String, GiftItem>();
                                }
                                allGiftItems.put(giftItem.id,giftItem);
                                Log.d(TAG,"onGetAllGift-allGiftItems.size:"+allGiftItems.size());
                            }

                        }
                        //异步下载
                        preDownGiftImgs(Arrays.asList(giftList));
                        updateRooomSendableGift();
                    }else{
                        allGiftConfigReqStatus = HttpReqStatus.ResFailed;
                    }
                    if(null!=callback){
                        callback.onGetGiftList(isSuccess, errCode, errMsg, giftList);
                    }
                }
            });
        }else{
            Log.d(TAG,"onGetAllGift-已初始化所有礼物配置信息");
            updateRooomSendableGift();
            if(null!=callback){
//                GiftItem[] giftItems = new GiftItem[allGiftItems.size()];
//                Iterator<String> idKeys = allGiftItems.keySet().iterator();
//                int index = 0;
//                while(idKeys.hasNext()){
//                    if(index<giftItems.length){
//                        giftItems[index] = allGiftItems.get(idKeys.next());
//                    }
//                }
                callback.onGetGiftList(true, 0, "", null);
            }
        }
    }


    /**
     * 获取当前用户房间内可以发送的礼物列表
     * 进入房间、每次打开礼物列表的时候本地判断是否需要刷新
     * @param roomid
     * @param callback
     */
    public void getSendableGiftItems(final String roomid,
                                     final OnGetSendableGiftListCallback callback){
        currRoomId = roomid;
        if((null != allRoomSendableGiftItemConfigs && allRoomSendableGiftItemConfigs.containsKey(roomid))){
            Log.d(TAG,"getSendableGiftItems-本地已存在roomId:"+roomid+"对应的房间可发送礼物配置，直接回调刷新");
            updateRooomSendableGift();
            if(null != callback){
//                List<SendableGiftItem> sendableGiftItemList = allRoomSendableGiftItemConfigs.get(roomid);
//                SendableGiftItem[] sendableGiftItems = new SendableGiftItem[sendableGiftItemList.size()];
//                for(int index=0; index<sendableGiftItemList.size(); index++){
//                    if(index == sendableGiftItems.length){
//                        break;
//                    }
//                    sendableGiftItems[index] = sendableGiftItemList.get(index);
//                }
                callback.onGetSendableGiftList(true,0,"",null);
            }
            return;
        }
        //一般不存在房间可发送礼物为空的情况
        if(roomSendableGiftReqStatusList.containsKey(roomid) &&
                roomSendableGiftReqStatusList.get(roomid) == HttpReqStatus.Reqing){
            //gift dialog或者activity触发该方法，最终都会去刷新gift dialog,因此暂时不顾callback是否相同
            return;
        }
        roomSendableGiftReqStatusList.put(roomid,HttpReqStatus.Reqing);
        Log.d(TAG,"getSendableGiftItems-本地不存在roomId:"+roomid+"获取房间可发送礼物配置，直接回调刷新");
        RequestJniLiveShow.GetSendableGiftList(roomid, new OnGetSendableGiftListCallback() {
            @Override
            public void onGetSendableGiftList(boolean isSuccess, int errCode,
                                              String errMsg, SendableGiftItem[] sendableGiftItems) {
                Log.d(TAG,"onGetSendableGiftList-isSuccess:"+isSuccess+" errCode:"+errCode
                        +" errMsg:"+errMsg+" sendableGiftItems:"+sendableGiftItems);
                if(isSuccess && null != sendableGiftItems){
                    if(allRoomSendableGiftItemConfigs.containsKey(roomid)){
                        allRoomSendableGiftItemConfigs.remove(roomid);
                    }
                    allRoomSendableGiftItemConfigs.put(roomid,Arrays.asList(sendableGiftItems));
                }
                roomSendableGiftReqStatusList.put(roomid,isSuccess ? HttpReqStatus.ReqSuccess : HttpReqStatus.ResFailed);
                updateRooomSendableGift();
                if(null != callback){
                    callback.onGetSendableGiftList(isSuccess,errCode,errMsg,sendableGiftItems);
                }
            }
        });
    }

    private int currRoomShowableGiftNum = 0;

    public synchronized void updateRooomSendableGift(){
        if(TextUtils.isEmpty(currRoomId)){
            return;
        }
        boolean allGiftConfigInited = allGiftConfigReqStatus == HttpReqStatus.ReqSuccess
                || isLocalAllGiftConfigExisted();
        boolean roomSendableGiftInited =
                null != allRoomSendableGiftItemConfigs && allRoomSendableGiftItemConfigs.containsKey(currRoomId);
        Log.d(TAG,"updateRooomSendableGift-allGiftConfigInited:"+allGiftConfigInited
                +" roomSendableGiftInited:"+roomSendableGiftInited
                +" roomId:"+currRoomId);
        if(allGiftConfigInited && roomSendableGiftInited){
            final List<SendableGiftItem> sendableGiftItems=allRoomSendableGiftItemConfigs.get(currRoomId);
            if(null != sendableGiftItems && sendableGiftItems.size()>0){
                final List<GiftItem> roomShowSendableGiftItems = new ArrayList<>();
                currRoomShowableGiftNum = 0;
                for(SendableGiftItem sendableGiftItem :sendableGiftItems){
                    currRoomShowableGiftNum+=sendableGiftItem.isVisible ? 1 : 0;
                }
                Log.d(TAG,"updateRooomSendableGift-currRoomShowableGiftNum:"+currRoomShowableGiftNum);
                for(final SendableGiftItem sendableGiftItem :sendableGiftItems){
                    if(!sendableGiftItem.isVisible){
                        continue;
                    }
                    getGiftDetail(sendableGiftItem.giftId, new OnGetGiftDetailCallback() {
                        @Override
                        public void onGetGiftDetail(boolean isSuccess, int errCode, String errMsg, GiftItem giftDetail) {
                            if(isSuccess && null != giftDetail){
                                roomShowSendableGiftItems.add(giftDetail);
                            }
                            Log.d(TAG,"updateRooomSendableGift-roomShowSendableGiftItems.size:"+roomShowSendableGiftItems.size()
                                        +"currRoomShowableGiftNum:"+currRoomShowableGiftNum);
                            //数量达到可见礼物的总和，那么更新
                            if(roomShowSendableGiftItems.size() == currRoomShowableGiftNum){
                                listeners.get(currRoomId).onRoomSendableGiftChanged(currRoomId,roomShowSendableGiftItems);
                            }
                        }
                    });
                }
            }
        }
    }


    /**
     * 预下载礼物图片文件
     */
    private void preDownGiftImgs(List<GiftItem> giftItems){
        for(GiftItem giftItem : giftItems){
            if(giftItem.giftType == GiftItem.GiftType.Advanced){
                Log.d(TAG, "preDownGiftImgs-giftItem.id:"+giftItem.id+" 为大礼物");
                getGiftImage(giftItem.id, GiftImageType.BigAnimSrc, null);
            }
            //其实除了大礼物动画文件之外，其他2种url可以直接利用Picasso来加载，且执行加载中、加载失败的处理更为简单
//            getGiftImage(giftItem.id, GiftImageType.MsgListIcon, null);
//            getGiftImage(giftItem.id, GiftImageType.GiftListIcon, null);
//            getGiftImage(giftItem.id, GiftImageType.RepeatAnimImg, null);
        }
    }

    private void preDownSingleGiftImgs(GiftItem giftItem){
        if(giftItem.giftType == GiftItem.GiftType.Advanced){
            Log.d(TAG, "preDownGiftImgs-giftItem.id:"+giftItem.id+" 为大礼物");
            getGiftImage(giftItem.id, GiftImageType.BigAnimSrc, null);
        }
//        getGiftImage(giftItem.id, GiftImageType.MsgListIcon, null);
//        getGiftImage(giftItem.id, GiftImageType.GiftListIcon, null);
//        getGiftImage(giftItem.id, GiftImageType.RepeatAnimImg, null);
    }

    /**
     * 判断是否存在所有礼物配置详情缓存
     * @return
     */
    public boolean isLocalAllGiftConfigExisted(){
        return null != allGiftItems && allGiftItems.size()>0;
    }

    public boolean isLocalRoomSendableGiftExisted(String roomId){
        return allRoomSendableGiftItemConfigs!=null && !TextUtils.isEmpty(roomId)
                && allRoomSendableGiftItemConfigs.containsKey(roomId)
                && allRoomSendableGiftItemConfigs.get(roomId).size()>0;
    }

    public List<SendableGiftItem> getLocalRoomSendableGiftList(String roomId){
        return allRoomSendableGiftItemConfigs.get(roomId);
    }

    public Map<String,SendableGiftItem> getLocalRoomSendableGiftMap(String roomId){
        Map<String,SendableGiftItem> sendableGiftItemMap = new HashMap<>();
        if(null != allRoomSendableGiftItemConfigs && allRoomSendableGiftItemConfigs.containsKey(roomId)){
            List<SendableGiftItem> sendableGiftItems = allRoomSendableGiftItemConfigs.get(roomId);
            for(SendableGiftItem sendableGiftItem : sendableGiftItems){
                sendableGiftItemMap.put(sendableGiftItem.giftId,sendableGiftItem);
            }
        }
        return sendableGiftItemMap;
    }

    public HttpReqStatus getRoomSendableGiftReqStatus(String roomId){
        if(!roomSendableGiftReqStatusList.containsKey(roomId)){
            roomSendableGiftReqStatusList.put(roomId,HttpReqStatus.NoReq);
        }
        return roomSendableGiftReqStatusList.get(roomId);
    }

    /**
     * 根据ID获取礼物详情
     * @param giftId
     * @param callback
     */
    public void getGiftDetail(String giftId, final OnGetGiftDetailCallback callback){
        if((null != allGiftItems && allGiftItems.containsKey(giftId))){
            Log.d(TAG,"getGiftDetail-已GetAllGiftList获取的礼物配置列表中包含giftId:"+giftId+"对应的礼物详情，回调返回本地详情");
            if(null != callback){
                callback.onGetGiftDetail(true,0,"",allGiftItems.get(giftId));
            }
            return;
        }

        if(null != allUnkonwGiftItems && allUnkonwGiftItems.containsKey(giftId)){
            Log.d(TAG,"getGiftDetail-已调用GetGiftDetail获取giftId:"+giftId+"对应的礼物详情，回调返回本地详情");
            if(null != callback){
                callback.onGetGiftDetail(true,0,"",allUnkonwGiftItems.get(giftId));
            }
            return;
        }
        Log.d(TAG,"getGiftDetail-调用GetGiftDetail获取giftId:"+giftId+"对应的礼物详情");
        RequestJniLiveShow.GetGiftDetail(giftId, new OnGetGiftDetailCallback() {
            @Override
            public void onGetGiftDetail(boolean isSuccess, int errCode,
                                        String errMsg, GiftItem giftDetail) {
                Log.d(TAG,"onGetGiftDetail-isSuccess:"+isSuccess+" errCode:"
                        +errCode+" errMsg:"+errMsg+" giftDetail:"+giftDetail);
                if(isSuccess && null != giftDetail){
                    allUnkonwGiftItems.put(giftDetail.id,giftDetail);
                    preDownSingleGiftImgs(giftDetail);
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
        }else if(null != allUnkonwGiftItems && allUnkonwGiftItems.containsKey(giftId)){
            giftDetail = allUnkonwGiftItems.get(giftId);
        }
        Log.d(TAG,"queryLocalGiftDetailById-giftId:"+giftId+" giftDetail:"+giftDetail);
        return giftDetail;
    }

    /**
     * 获取礼物图片本地缓存路径
     * @param giftId
     * @param imageType
     */
    public void getGiftImage(String giftId, GiftImageType imageType, final IFileDownloadedListener listener){
        GiftItem item = queryLocalGiftDetailById(giftId);
        if(item != null){
            String url = getImageUrlByType(item, imageType);
            if(!TextUtils.isEmpty(url)){
                final String localPath = FileCacheManager.getInstance().getGiftLocalPath(giftId, url);
                Log.d(TAG,"getGiftImage-giftId:"+giftId+" imageType:"+imageType.toString()+" localPath:"+localPath);
                if(SystemUtils.fileExists(localPath)){
                    Log.d(TAG,"本地图片已经存在");
                    //本地有礼物小图片，那么adapter就能够正常刷新，无需notif
                    if(imageType != GiftImageType.MsgListIcon && null != listener){
                        listener.onCompleted(true, localPath, url);
                    }
                }else{
                    Log.d(TAG,"本地图片不存在，开始下载");
                    FileDownloadManager.getInstance().start(url, localPath, new IFileDownloadedListener(){
                        public void onCompleted(boolean isSuccess, String localFilePath, String fileUrl){
                            if(null != listener){
                                Log.d(TAG,"图片下载成功,localPath:"+localPath);
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
                case MsgListIcon:{
                    url = giftItem.smallImgUrl;
                }break;
                case GiftListIcon:{
                    url = giftItem.middleImgUrl;
                }break;
                case RepeatAnimImg: {
                    url = giftItem.bigImageUrl;
                }break;
                case BigAnimSrc:{
                    url = giftItem.srcWebpUrl;
                }break;
                default:
                    break;
            }
        }
        return url;
    }

    /**
     * 本地获取所有可发送礼物列表
     * @param roomId
     * @return
     */
    public List<GiftItem> getLocalSendabelRecomGiftList(String roomId, int manLevel, int loveLevel){
        Log.d(TAG,"getLocalSendabelRecomGiftList-roomId:"+roomId+" manLevel:"+manLevel+" loveLevel:"+loveLevel);
        List<GiftItem> giftList = new ArrayList<GiftItem>();
        List<SendableGiftItem> sendableGiftItems = allRoomSendableGiftItemConfigs.get(roomId);
        if(sendableGiftItems != null){
            for(SendableGiftItem item : sendableGiftItems){
                if(allGiftItems.containsKey(item.giftId)){
                    GiftItem giftItem = allGiftItems.get(item.giftId);
                    if(item.isVisible && item.isPromo && giftItem.lovelevelLimit <= loveLevel
                            && giftItem.levelLimit <= manLevel){
                        giftList.add(giftItem);
                    }
                }
            }
        }
        return giftList;
    }

    /**
     * 本地读取礼物详情
     * @param giftId
     * @return
     */
    public GiftItem getLocalGiftDetail(String giftId){
        GiftItem giftItem = null;
        if(allGiftItems != null && allGiftItems.containsKey(giftId)){
            giftItem = allGiftItems.get(giftId);
        }
        if(allUnkonwGiftItems != null && allUnkonwGiftItems.containsKey(giftId)){
            giftItem = allGiftItems.get(giftId);
        }
        return giftItem;
    }

    //-----------------------------Callback定义---------------------
    private Map<String,OnRoomShowSendableGiftDataChangeListener> listeners = new HashMap<>();

    public void registerListener(String roomId,OnRoomShowSendableGiftDataChangeListener listener){
        Log.d(TAG,"registerListener-roomId:"+roomId);
        if(!listeners.containsKey(roomId)){
            listeners.put(roomId,listener);
        }
    }

    public void unregisterListener(String roomId){
        Log.d(TAG,"unregisterListener-roomId:"+roomId);
        if(listeners.containsKey(roomId)){
            listeners.remove(roomId);
        }
    }


    public interface OnRoomShowSendableGiftDataChangeListener {
        void onRoomSendableGiftChanged(String roomId,List<GiftItem> sendableGiftItemList);
    }

}
