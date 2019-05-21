package com.qpidnetwork.livemodule.liveshow.liveroom.gift;

import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;

import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetGiftDetailCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetGiftListCallback;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType;
import com.qpidnetwork.qnbridgemodule.datacache.FileCacheManager;
import com.qpidnetwork.livemodule.liveshow.datacache.file.downloader.FileDownloadManager;
import com.qpidnetwork.livemodule.liveshow.datacache.file.downloader.IFileDownloadedListener;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.utils.SystemUtils;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by Hunter on 18/6/20.
 */

public class NormalGiftManager {
    //data数据区
    private final String TAG = NormalGiftManager.class.getSimpleName();
    private static final int EVENT_GET_ALL_GIFTLIST = 0;

    /**
     * 当前用户的所有礼物数据
     */
    private Map<String, GiftItem> mAllGiftMap = new HashMap<String, GiftItem>();        //存放所有礼物Map
    private boolean mIsGetAllGiftRequesting = false;                                    //是否获取所有礼物配置请求中
    private GiftItem[] mAllGiftArray;                                                   //本地内存缓存获取所有礼物配置
    private List<OnGetGiftListCallback> mOnGetGiftListCallbackList;                     //存放获取所有礼物列表callback列表，解决同时多个同时访问问题
    private Handler mHandler;                                                           //解决线程切换，防止多子线程嵌套导致子线程杀子线程及线程回收异常


    //-------------------------------单例模式，初始化-------------------

    private static NormalGiftManager mNormalGiftManager;

    public static NormalGiftManager getInstance(){
        if(mNormalGiftManager == null){
            mNormalGiftManager = new NormalGiftManager();
        }
        return mNormalGiftManager;
    }


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
                            mAllGiftArray = (GiftItem[])response.data;
                            //同步礼物详情到Map,并预加载礼物资源
                            updateAllGiftMap(mAllGiftArray);
                        }
                        //分发事件到请求监听列表
                        distributeGetAllGiftCallback(response.isSuccess, response.errCode, response.errMsg, (GiftItem[])response.data);
                    }break;
                }
            }
        };
    }

    //-------------------------------礼物本地缓存管理-------------------

    /**
     * 获取礼物列表配置成功，同步缓存到本地Map
     * @param giftList
     */
    private void updateAllGiftMap(GiftItem[] giftList){
        synchronized (mAllGiftMap){
            if(giftList != null){
                for(GiftItem item : giftList){
                    if(item != null){
                        mAllGiftMap.put(item.id, item);
                        //同步检测并下载礼物资源
                        preDownSingleGiftImgs(item);
                    }
                }
            }
        }
    }

    /**
     * 同步单个礼物到本地缓存
     * @param item
     */
    private void updateAllGiftMap(GiftItem item){
        synchronized (mAllGiftMap){
            if(item != null) {
                mAllGiftMap.put(item.id, item);
                //同步检测并下载礼物资源
                preDownSingleGiftImgs(item);
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

    //-------------------------------获取所有礼物本地配置-------------------
    /**
     * 获取所有礼物配置详情
     * 在每次登录成功时刷新本地、进入房间时判断是否需要刷新
     * @param callback
     */
    public void getAllGiftItems(final OnGetGiftListCallback callback){
        if(mIsGetAllGiftRequesting){
            //请求中
            if(callback != null){
                addToGetAllGiftCallbackList(callback);
            }
        }else{
            if(mAllGiftArray != null){
                //本地数据已存在
                if(callback != null){
                    callback.onGetGiftList(true, HttpLccErrType.HTTP_LCC_ERR_SUCCESS.ordinal(), "", mAllGiftArray);
                }
            }else{
                mIsGetAllGiftRequesting = true;
                //解决请求当前次未加入列表，导致无法回调
                if(callback != null){
                    addToGetAllGiftCallbackList(callback);
                }
                //需要接口请求更新数据
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
     * 获取所有礼物列表callback存储
     * @param callback
     */
    private void addToGetAllGiftCallbackList(OnGetGiftListCallback callback){
        synchronized (mOnGetGiftListCallbackList){
            if(callback != null && mOnGetGiftListCallbackList != null){
                mOnGetGiftListCallbackList.add(callback);
            }
        }
    }

    /**
     * 获取所有礼物返回分发器
     * @param isSuccess
     * @param errCode
     * @param errMsg
     * @param giftList
     */
    private void distributeGetAllGiftCallback(boolean isSuccess, int errCode, String errMsg, GiftItem[] giftList){
        synchronized (mOnGetGiftListCallbackList){
            if(mOnGetGiftListCallbackList != null){
                for (OnGetGiftListCallback callback : mOnGetGiftListCallbackList){
                    if(callback != null){
                        callback.onGetGiftList(isSuccess, errCode, errMsg, giftList);
                    }
                }
                mOnGetGiftListCallbackList.clear();
            }
        }
    }

    //-------------------------------获取单个礼物详情-------------------

    /**
     * 根据礼物ID获取单个礼物详情
     * @param giftId
     * @param callback
     */
    public void getGiftDetail(String giftId, final OnGetGiftDetailCallback callback){
        GiftItem item = getLocalGiftDetail(giftId);
        if(item != null){
            //本地已缓存礼物详情信息，不需同步
            if(callback != null){
                callback.onGetGiftDetail(true, HttpLccErrType.HTTP_LCC_ERR_SUCCESS.ordinal(), "", item);
            }
        }else{
            LiveRequestOperator.getInstance().GetGiftDetail(giftId, new OnGetGiftDetailCallback() {
                @Override
                public void onGetGiftDetail(final boolean isSuccess, final int errCode,
                                            final String errMsg, final GiftItem giftDetail) {
                    //此处线程切换为偷懒操作，避免显示定义对象，解决回传多数据需要重新定义数据对象问题（内部类自动实现）
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            if(isSuccess && giftDetail != null){
                                //同步礼物详情到本地缓存
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

    //-------------------------------礼物相关资源本地下载-------------------

    /**
     * 本地检测并处理下载礼物相关资源预加载文件（大礼物需提前下载webp动画资源）
     * @param giftItem
     */
    private void preDownSingleGiftImgs(GiftItem giftItem){
        if(giftItem.giftType == GiftItem.GiftType.Advanced){
            getGiftImage(giftItem.id, GiftImageType.BigAnimSrc, null);
        }
    }

    /**
     * 获取礼物相关资源
     * @param giftId
     * @param imageType    资源类型
     */
    public void getGiftImage(String giftId, GiftImageType imageType, final IFileDownloadedListener listener){
        GiftItem item = getLocalGiftDetail(giftId);
        if(item != null){
            String url = getImageUrlByType(item, imageType);
            if(!TextUtils.isEmpty(url)){
                final String localPath = FileCacheManager.getInstance().getGiftLocalPath(giftId, url);
                if(SystemUtils.fileExists(localPath)){
                    //本地有礼物小图片，那么adapter就能够正常刷新，无需notif
                    if(imageType != GiftImageType.MsgListIcon && null != listener){
                        listener.onCompleted(true, localPath, url);
                    }
                }else{
                    FileDownloadManager.getInstance().start(url, localPath, new IFileDownloadedListener(){
                        public void onCompleted(boolean isSuccess, String localFilePath, String fileUrl){
                            if(null != listener){
                                listener.onCompleted(isSuccess, localFilePath, fileUrl);
                            }
                        }

                        @Override
                        public void onProgress(String fileUrl, int progress) {

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

                        @Override
                        public void onProgress(String fileUrl, int progress) {

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
                case BigPngSrc:{
                    url = giftItem.middleImgUrl;        //与ModuleGiftManager.addToAdvanceGiftManager里的判断条件对应
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
