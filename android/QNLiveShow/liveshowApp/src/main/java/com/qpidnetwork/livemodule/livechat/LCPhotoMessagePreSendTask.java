package com.qpidnetwork.livemodule.livechat;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.text.TextUtils;

import com.qpidnetwork.livemodule.livechathttprequest.LCRequestJniLiveChat;
import com.qpidnetwork.livemodule.livechathttprequest.OnLCSendPhotoCallback;
import com.qpidnetwork.livemodule.livechathttprequest.OnLCUploadManPhotoCallback;
import com.qpidnetwork.livemodule.livechathttprequest.item.LCSendPhotoItem;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.utils.ImageUtil;
import com.qpidnetwork.qnbridgemodule.bean.BaseHttpResponseBean;
import com.qpidnetwork.qnbridgemodule.datacache.FileCacheManager;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.io.File;

import io.reactivex.Observable;
import io.reactivex.ObservableEmitter;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.CompositeDisposable;
import io.reactivex.disposables.Disposable;
import io.reactivex.functions.Consumer;
import io.reactivex.schedulers.Schedulers;

/**
 * 封装处理图片发送逻辑
 */
public class LCPhotoMessagePreSendTask {

    private static final String TAG = LCPhotoMessagePreSendTask.class.getName();
    private final int MAX_LENGTH_STANDARD = 1280;
    private final int PICTURE_MAX_SIZE = 5 * 1024;//(单位K)即5M

    private LCMessageItem mMessageItem;
    private String mUserId;
    private String mSid;
    private boolean mIsInited;
    private String mDestPhotoPath;
    //订阅容器
    private CompositeDisposable mCompositeDisposable = new CompositeDisposable();

    private OnLCPhotoMessagePreSendCallback mCallBack;

    public LCPhotoMessagePreSendTask(){

    }

    public void init(LCMessageItem msgItem, String userId, String sid){
        Log.i(TAG, "init msgId: " + msgItem.msgId + " userId: " + userId + "  sid: " + sid);
        mIsInited = true;
        this.mMessageItem = msgItem;
        this.mUserId = userId;
        this.mSid = sid;
        //创建临时缓存文件名
        mDestPhotoPath = FileCacheManager.getInstance().getPrivatePhotoTempSavePath() + createTempFileName(mMessageItem, mUserId);
    }

    /**
     * 设置事件回调
     * @param callback
     */
    public void setOnLCPhotoMessagePreSendCallback(OnLCPhotoMessagePreSendCallback callback){
        mCallBack = callback;
    }

    public boolean start(){
        boolean startSuccess = false;
        if(mIsInited){
            startSuccess = true;
            photoPreCrop(mMessageItem.getPhotoItem().mClearSrcPhotoInfo.photoPath);
        }
        return startSuccess;
    }

    /**
     * 图片宽高及大小处理
     */
    private void photoPreCrop(final String filePath){
        Log.logD(TAG, "photoPreCrop filePath: " + filePath);
        if(TextUtils.isEmpty(filePath) || !(new File(filePath).exists())){
            //文件不存在，发送失败
            onPhotoPreSendCallback(false, "", "", null);
            return;
        }
        //rxjava
        Observable<String> observerable = Observable.create(new ObservableOnSubscribe<String>() {

            @Override
            public void subscribe(final ObservableEmitter<String> emitter) {
                float calculatScale = caculateScaleRate(filePath);
                Bitmap scaleBitmap = ImageUtil.preciseScaleBitmap(filePath, calculatScale);
                if(scaleBitmap != null){
                    Bitmap compressBitmap = ImageUtil.compressImage(scaleBitmap, PICTURE_MAX_SIZE);
                    if(!scaleBitmap.isRecycled()){
                        scaleBitmap.recycle();
                    }
                    ImageUtil.saveBitmapToFile(mDestPhotoPath, compressBitmap, Bitmap.CompressFormat.JPEG, 90);
                    if(!compressBitmap.isRecycled()){
                        compressBitmap.recycle();
                    }
                }
                //发射
                emitter.onNext(mDestPhotoPath);
            }
        });

        Consumer<String> observerResult = new Consumer<String>() {
            @Override
            public void accept(String result) throws Exception {
                uploadPhoto(result);
            }
        };

       Disposable disposable = observerable
                                   .subscribeOn(Schedulers.newThread())
                                   .observeOn(AndroidSchedulers.mainThread())    //转由主线程处理结果
                                   .subscribe(observerResult);
        mCompositeDisposable.add(disposable);
    }

    /**
     * 计算图片缩放比例
     * @param filePath
     * @return
     */
    private float caculateScaleRate(String filePath){
        float caculatePhotoScale = 1.0f;
        BitmapFactory.Options options = ImageUtil.getImageInfoWithFile(filePath);
        if(options != null){
            int photoWidth = options.outWidth;
            int photoHeight = options.outHeight;
            Log.logD(TAG, "caculatePhotoScale photoWidth: " + photoWidth + " photoHeight： " + photoHeight);
            float ratio = 1.0f;
            //计算图片的长宽比
            if(photoHeight > 0 && photoWidth > 0){
                if(photoHeight > photoWidth){
                    ratio = ((float)photoHeight)/photoWidth;
                }else{
                    ratio = ((float)photoWidth)/photoHeight;
                }
                //根据图片的长宽比，结合规则获取具体压缩比例
                if(ratio > 2){
                    //长边短边比例大于2，仅当长宽都大于1280，才需根据规则，以短边压缩
                    if(photoWidth > MAX_LENGTH_STANDARD && photoHeight > MAX_LENGTH_STANDARD){
                        caculatePhotoScale = ((float)MAX_LENGTH_STANDARD)/(photoHeight > photoWidth ? photoWidth:photoHeight);
                    }
                }else{
                    //长边短边比例小于等于2，图片宽度或高度任意一个大于1280时，以长边为准，压缩到1280，另一边等比例缩放
                    if(photoWidth > MAX_LENGTH_STANDARD || photoHeight > MAX_LENGTH_STANDARD){
                        caculatePhotoScale = ((float)MAX_LENGTH_STANDARD)/(photoHeight > photoWidth ? photoHeight:photoWidth);
                    }
                }
            }
        }
        Log.logD(TAG, "caculatePhotoScale caculatePhotoScale: " + caculatePhotoScale);
        return caculatePhotoScale;
    }

    /**
     * 上传照片
     * @param filePath
     */
    private void uploadPhoto(final String filePath){
        mDestPhotoPath = filePath;
        Log.logD(TAG, "uploadPhoto filePath: " + filePath);
        if(TextUtils.isEmpty(filePath) || !(new File(filePath).exists())){
            //文件不存在，发送失败
            onPhotoPreSendCallback(false, "", "", null);
            return;
        }
        //rxjava
        Observable<HttpRespObject> observerable = Observable.create(new ObservableOnSubscribe<HttpRespObject>() {

            @Override
            public void subscribe(final ObservableEmitter<HttpRespObject> emitter) {
                LCRequestJniLiveChat.UploadManPhoto(filePath, new OnLCUploadManPhotoCallback() {
                    @Override
                    public void OnUploadManPhoto(long requestId, boolean isSuccess, int errCode, String errmsg, String photoUrl, String photomd5) {
                        Log.logD(TAG, "OnUploadManPhoto requestId: " + requestId + " isSuccess: " + isSuccess + " errCode: " + errCode + " photoUrl: " + photoUrl);
                        HttpRespObject response = new HttpRespObject(isSuccess, errCode, errmsg, photoUrl);
                        //发射
                        emitter.onNext(response);
                    }
                });
            }
        });

        Consumer<HttpRespObject> observerResult = new Consumer<HttpRespObject>() {
            @Override
            public void accept(HttpRespObject response) throws Exception {
                if(response.isSuccess){
                    sendPhoto((String) response.data);
                }else{
                    onPhotoPreSendCallback(response.isSuccess, "", "", null);
                }
            }
        };

        Disposable disposable = observerable
                                    .observeOn(AndroidSchedulers.mainThread())    //转由主线程处理结果
                                    .subscribe(observerResult);
        mCompositeDisposable.add(disposable);
    }

    /**
     * 上传照片
     * @param photoUrl
     */
    private void sendPhoto(final String photoUrl){
        Log.logD(TAG, "sendPhoto photoUrl: " + photoUrl);
        //rxjava
        Observable<BaseHttpResponseBean> observerable = Observable.create(new ObservableOnSubscribe<BaseHttpResponseBean>() {

            @Override
            public void subscribe(final ObservableEmitter<BaseHttpResponseBean> emitter) {
                LCUserItem userItem = mMessageItem.getUserItem();
                final LCPhotoItem photoItem = mMessageItem.getPhotoItem();
                long requestId = LCRequestJniLiveChat.SendPhoto(userItem.userId, userItem.inviteId, mUserId, mSid, photoUrl, new OnLCSendPhotoCallback() {
                    @Override
                    public void OnLCSendPhoto(long requestId, boolean isSuccess, String errno, String errmsg, LCSendPhotoItem item) {
                        Log.logD(TAG, "OnLCSendPhoto isSuccess: " + isSuccess + " errno: " + errno);
                        BaseHttpResponseBean response = new BaseHttpResponseBean(isSuccess, errno, errmsg, item);
                        //发射
                        emitter.onNext(response);
                    }
                });
            }
        });

        Consumer<BaseHttpResponseBean> observerResult = new Consumer<BaseHttpResponseBean>() {
            @Override
            public void accept(BaseHttpResponseBean response) throws Exception {
                onPhotoPreSendCallback(response.isSuccess, response.errno, response.errMsg, (LCSendPhotoItem)response.data);
            }
        };

        Disposable disposable = observerable
                                    .observeOn(AndroidSchedulers.mainThread())    //转由主线程处理结果
                                    .subscribe(observerResult);
        mCompositeDisposable.add(disposable);
    }

    /**
     * 统一处理回调
     * @param isSuccess
     * @param errno
     * @param errmsg
     * @param item
     */
    private void onPhotoPreSendCallback(boolean isSuccess, String errno, String errmsg, LCSendPhotoItem item){

        if(mCallBack != null){
            mCallBack.onLCPhotoMessagePreSendCallback(this, isSuccess, errno, errmsg, item, mDestPhotoPath);
        }

        //解除订阅
        releaseDisposable();
    }

    /**
     * 创建图片中间缓存
     * @param msgItem
     * @param userId
     * @return
     */
    private String createTempFileName(LCMessageItem msgItem, String userId){
        String fileName = "";
        fileName += userId;
        if(msgItem != null){
            fileName += "_" + msgItem.msgId;
        }
        fileName += "_" + System.currentTimeMillis() + "_temp";
        return fileName;
    }

    /**
     * 释放rxjava订阅，防止内存泄漏
     */
    public void releaseDisposable(){
        if(!mCompositeDisposable.isDisposed()){
            mCompositeDisposable.dispose();
        }
        if(!TextUtils.isEmpty(mDestPhotoPath)){
            try {
                File file = new File(mDestPhotoPath);
                if(file.exists()){
                    file.delete();
                }
            }catch (Exception e){
                //删除文件失败
            }

            mDestPhotoPath = "";
        }
    }

    public interface OnLCPhotoMessagePreSendCallback{
        public void onLCPhotoMessagePreSendCallback(LCPhotoMessagePreSendTask task, boolean isSuccess, String errno, String errmsg, LCSendPhotoItem item, String filePath);
    }

}
