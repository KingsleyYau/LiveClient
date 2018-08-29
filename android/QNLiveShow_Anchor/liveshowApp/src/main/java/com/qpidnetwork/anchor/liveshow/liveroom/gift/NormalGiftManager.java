package com.qpidnetwork.anchor.liveshow.liveroom.gift;

import android.annotation.SuppressLint;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;

import com.qpidnetwork.anchor.httprequest.LiveRequestOperator;
import com.qpidnetwork.anchor.httprequest.OnGetGiftDetailCallback;
import com.qpidnetwork.anchor.httprequest.OnGetGiftListCallback;
import com.qpidnetwork.anchor.httprequest.item.GiftItem;
import com.qpidnetwork.anchor.httprequest.item.HttpLccErrType;
import com.qpidnetwork.anchor.liveshow.datacache.file.FileCacheManager;
import com.qpidnetwork.anchor.liveshow.datacache.file.downloader.FileDownloadManager;
import com.qpidnetwork.anchor.liveshow.datacache.file.downloader.IFileDownloadedListener;
import com.qpidnetwork.anchor.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.anchor.utils.Log;
import com.qpidnetwork.anchor.utils.SystemUtils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 礼物列表管理类
 * Created by Hunter Mun on 2017/6/21.
 */

public class NormalGiftManager {

    //------------------------------私有变量定义-------------------

    private final String TAG = NormalGiftManager.class.getSimpleName();
    private boolean mIsGetAllGiftRequesting = false;
    //获取所有礼物列表通知
    private List<OnGetGiftListCallback> mOnGetGiftListCallbackList;
    //本地缓存礼物配置接口返回数据（可用于区分是否接口是否成功过）
    private GiftItem[] mGiftConfigArray;
    //缓存礼物详情配置（包含配置接口返回和通过获取详情缓存）
    private Map<String, GiftItem> mAllGiftMap = new HashMap<String, GiftItem>();
    //解决线程切换，防止多子线程嵌套导致子线程杀子线程及线程回收异常
    private Handler mHandler;
    //调用获取所有礼物配置接口数据返回
    private static final int EVENT_GET_ALL_GIFTLIST = 0;

    //-------------------------------单例模式，初始化-------------------

    private static NormalGiftManager mNormalGiftManager;

    public static NormalGiftManager getInstance(){
        if(mNormalGiftManager == null){
            mNormalGiftManager = new NormalGiftManager();
        }
        return mNormalGiftManager;
    }


    @SuppressLint("HandlerLeak")
    private NormalGiftManager(){
        mOnGetGiftListCallbackList = new ArrayList<OnGetGiftListCallback>();
        mHandler = new Handler(){
            @Override
            public void handleMessage(Message msg) {
                super.handleMessage(msg);
                HttpRespObject response = (HttpRespObject)msg.obj;
                switch (msg.what){
                    case EVENT_GET_ALL_GIFTLIST:{
                        //清除请求中标志
                        mIsGetAllGiftRequesting = false;
                        if(response.isSuccess){
                            mGiftConfigArray = (GiftItem[])response.data;
                            //同步礼物详情到Map,并预加载礼物资源
                            updateAllGiftMap(mGiftConfigArray);
                        }
                        //分发事件到请求监听列表
                        distributeGetAllGiftCallback(response.isSuccess, response.errCode, response.errMsg, (GiftItem[])response.data);
                    }break;
                }
            }
        };
    }

    //-------------------------------获取礼物全局配置-------------------
    /**
     * 获取礼物配置成功，更新本地礼物详情Map列表，方便统一查询获取详情
     * @param giftList
     */
    private void updateAllGiftMap(GiftItem[] giftList){
        synchronized (mAllGiftMap){
            if(giftList != null){
                for(GiftItem item : giftList){
                    if(item != null){
                        mAllGiftMap.put(item.id, item);
                        //同步部分礼物资源
                        preDownloadGiftImgs(item);
                    }
                }
            }
        }
    }

    /**
     * 更新本地礼物详情Map列表
     * @param giftItem
     */
    private void updateAllGiftMap(GiftItem giftItem){
        synchronized (mAllGiftMap){
            if(giftItem != null){
                mAllGiftMap.put(giftItem.id, giftItem);
                //同步部分礼物资源
                preDownloadGiftImgs(giftItem);
            }
        }
    }

    /**
     * 读取本地礼物详情
     * @param giftId
     * @return
     */
    public GiftItem getLocalGiftDetail(String giftId){
        GiftItem item = null;
        synchronized (mAllGiftMap){
            if(mAllGiftMap != null){
                item = mAllGiftMap.get(giftId);
            }
        }
        return item;
    }

    /**
     * 获取所有礼物配置详情
     * 在每次登录成功时刷新本地、进入房间时判断是否需要刷新
     * @param callback
     */
    public void getAllGiftItems(final OnGetGiftListCallback callback){
        if(mIsGetAllGiftRequesting){
            //获取礼物配置中，加入回调列表等待
            if(callback != null) {
                addToGetAllGiftCallbackList(callback);
            }
        }else{
            if(mGiftConfigArray != null){
                //本地存在，直接回调即可
                if(callback != null){
                    callback.onGetGiftList(true, HttpLccErrType.HTTP_LCC_ERR_SUCCESS.ordinal(), "", mGiftConfigArray);
                }
            }else{
                mIsGetAllGiftRequesting = true;
                if(callback != null) {
                    addToGetAllGiftCallbackList(callback);
                }
                LiveRequestOperator.getInstance().GetAllGiftList(new OnGetGiftListCallback() {
                    @Override
                    public void onGetGiftList(boolean isSuccess, int errCode, String errMsg, GiftItem[] giftList) {
                        Log.d(TAG,"onGetAllGift-isSuccess:"+isSuccess+" errCode:"+errCode +" errMsg:"+errMsg);

                        HttpRespObject respObject = new HttpRespObject(isSuccess, errCode, errMsg, giftList);
                        Message msg = Message.obtain();
                        msg.what = EVENT_GET_ALL_GIFTLIST;
                        msg.obj = respObject;
                        mHandler.sendMessage(msg);
                    }
                });
            }
        }
    }

    /**
     * 加入获取礼物监听器列表
     * @param callback
     */
    private void addToGetAllGiftCallbackList(OnGetGiftListCallback callback){
        synchronized (mOnGetGiftListCallbackList){
            if(mOnGetGiftListCallbackList != null){
                mOnGetGiftListCallbackList.add(callback);
            }
        }
    }

    /**
     * 获取礼物配置分发器
     * @param isSuccess
     * @param errCode
     * @param errMsg
     * @param giftList
     */
    private void distributeGetAllGiftCallback(boolean isSuccess, int errCode, String errMsg, GiftItem[] giftList){
        synchronized (mOnGetGiftListCallbackList){
            if(mOnGetGiftListCallbackList != null){
                for(OnGetGiftListCallback callback : mOnGetGiftListCallbackList){
                    if(callback != null) {
                        callback.onGetGiftList(isSuccess, errCode, errMsg, giftList);
                    }
                }
                mOnGetGiftListCallbackList.clear();
            }
        }
    }

    //-------------------------------获取单个礼物详情-------------------

    /**
     * 根据ID获取礼物详情
     * @param giftId
     * @param callback
     */
    public void getGiftDetail(String giftId, final OnGetGiftDetailCallback callback){
        GiftItem item = getLocalGiftDetail(giftId);
        if(item != null){
            if(callback != null) {
                callback.onGetGiftDetail(true, HttpLccErrType.HTTP_LCC_ERR_SUCCESS.ordinal(), "", item);
            }
        }else{
            Log.d(TAG,"getGiftDetail-调用GetGiftDetail获取giftId:"+giftId+"对应的礼物详情");
            LiveRequestOperator.getInstance().GetGiftDetail(giftId, new OnGetGiftDetailCallback() {
                @Override
                public void onGetGiftDetail(final boolean isSuccess,final int errCode,final
                                            String errMsg,final GiftItem giftDetail) {
                    Log.d(TAG,"onGetGiftDetail-isSuccess:"+isSuccess+" errCode:"
                            +errCode+" errMsg:"+errMsg+" giftDetail:"+giftDetail);

                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            if(isSuccess && null != giftDetail){
                                //同步到本地详情并处理资源预下载
                                updateAllGiftMap(giftDetail);
                            }
                            if(null != callback){
                                callback.onGetGiftDetail(isSuccess,errCode,errMsg,giftDetail);
                            }
                        }
                    });
                }
            });
        }
    }
    //-------------------------------礼物资源下载器-------------------

    /**
     * 预加载礼物部分资源
     *     大礼物或庆祝礼物:动画播放webp文件
     *     吧台礼物：动画播放所需要的静态图片
     * @param giftItem
     */
    private void preDownloadGiftImgs(GiftItem giftItem){
        if(giftItem.giftType == GiftItem.GiftType.Advanced || giftItem.giftType == GiftItem.GiftType.Celebrate){
            Log.d(TAG, "preDownGiftImgs-giftItem.id:"+giftItem.id+" 为webp大礼物");
            getGiftImage(giftItem.id, GiftImageType.BigAnimSrc, null);
        }
        if(giftItem.giftType == GiftItem.GiftType.Bar){
            Log.d(TAG, "preDownGiftImgs-giftItem.id:"+giftItem.id+" 为png大礼物");
            getGiftImage(giftItem.id, GiftImageType.RepeatAnimImg, null);
        }
    }

    /**
     * 获取礼物图片本地缓存路径
     * @param giftId
     * @param imageType
     */
    public void getGiftImage(String giftId, GiftImageType imageType, final IFileDownloadedListener listener){
        GiftItem item = getLocalGiftDetail(giftId);
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
     * 获取礼物图片本地缓存路径
     * @param giftId
     * @param imageType
     * @return localPath 如果本地有图片，则返回本地路径
     */
    public String getGiftImageEx(String giftId, GiftImageType imageType, final IFileDownloadedListener listener){
        String localPath = "";
        GiftItem item = getLocalGiftDetail(giftId);
        if(item != null){
            String url = getImageUrlByType(item, imageType);
            if(!TextUtils.isEmpty(url)){
                String tempLocalPath = FileCacheManager.getInstance().getGiftLocalPath(giftId, url);
//                Log.d(TAG,"getGiftImage-giftId:"+giftId+" imageType:"+imageType.toString()+" localPath:"+localPath);
                if(SystemUtils.fileExists(tempLocalPath)){
//                    Log.d(TAG,"本地图片已经存在");
                    //本地有礼物小图片，那么adapter就能够正常刷新，无需notif
//                    if(null != listener){
//                        listener.onCompleted(true, false, localPath, url);
//                    }
                    //
                    localPath = tempLocalPath;
                }else{
//                    Log.d(TAG,"本地图片不存在，开始下载");
                    FileDownloadManager.getInstance().start(url, tempLocalPath, new IFileDownloadedListener(){
                        public void onCompleted(boolean isSuccess, String localFilePath, String fileUrl){
                            if(null != listener){
//                                Log.d(TAG,"图片下载成功,localPath:"+localPath);
                                listener.onCompleted( isSuccess, localFilePath, fileUrl);
                            }
                        }
                    });
                }
            }
        }
        return localPath;
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

    //-------------------------------本地实现线程切换操作-------------------
    /**
     * 切换主线程操作
     * @param runnable
     */
    private void runOnUiThread(Runnable runnable){
        if(mHandler != null && runnable != null){
            mHandler.post(runnable);
        }
    }
}
