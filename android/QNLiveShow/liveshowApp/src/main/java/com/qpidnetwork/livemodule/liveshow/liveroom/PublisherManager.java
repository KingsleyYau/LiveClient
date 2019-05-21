package com.qpidnetwork.livemodule.liveshow.liveroom;

import android.app.Activity;
import android.opengl.GLSurfaceView;
import android.text.TextUtils;
import android.view.SurfaceView;

import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.utils.SystemUtils;

import net.qdating.LSConfig;
import net.qdating.LSPublisher;
import net.qdating.publisher.ILSPublisherStatusCallback;

/**
 * 推流器管理
 * Created by Hunter on 17/11/14.
 */

public class PublisherManager implements ILSPublisherStatusCallback {
    private static final int MAX_RECONNECTCOUNT = 5;
    private Activity mActivity;
    private boolean mIsInited = false;
    private boolean mIsImDisconnected = false;
    //publisher
    private LSPublisher mLSPublisher;
    private int mPublisherReconnectCount = 0;
    private String[] mManUploadUrls = null;
    private int mPublisherUrlCurPosition = -1;
    private String mPublisherRecordH264FilePath = "";
    private String mPublisherRecordAACFilePath = "";

    private ILSPublisherStatusListener listener;
    public interface ILSPublisherStatusListener {
        void onPushStreamConnect(LSPublisher var1);

        void onPushStreamDisconnect(LSPublisher var1);
    }

    public void setILSPublisherStatusListener(ILSPublisherStatusListener listener){
        this.listener = listener;
    }

    public PublisherManager(Activity activity){
        mActivity = activity;
    }

    /**
     * 初始化
     * @param svPublisher
     */
    public void init(GLSurfaceView svPublisher){
        if(mLSPublisher == null){
            mIsInited = true;
            mLSPublisher = new LSPublisher();
            int rotation = mActivity.getWindowManager().getDefaultDisplay().getRotation();
            mLSPublisher.init(mActivity.getApplicationContext(), svPublisher, rotation, LSConfig.FillMode.FillModeAspectRatioFill, this, LSConfig.VideoConfigType.VideoConfigType240x240, 10, 10, 400 * 1000);
        }
    }

    /**
     * manager 回收
     */
    public void uninit(){
        if(mLSPublisher != null){
            mIsInited = false;
            mLSPublisher.stop();
            mLSPublisher.uninit();
            //add by Jagger unInit和init是对应的，如果不至空，再调用init也并没有什么卵用
            mLSPublisher = null;
        }
    }

    /**
     * 是否初始化
     * @return
     */
    public boolean isInited(){
        return mIsInited;
    }

    /**
     * 设置或更改推流地址列表，并开始推流
     * @param manUploadUrls
     * @param recordH264FilePath
     * @param recordAACFilePath
     */
    public void setOrChangeManUploadUrls(String[] manUploadUrls, String recordH264FilePath, String recordAACFilePath){
        mPublisherUrlCurPosition = 0;
        mPublisherReconnectCount = 0;
        mIsImDisconnected = false;
        mManUploadUrls = manUploadUrls;
        mPublisherRecordH264FilePath = recordH264FilePath;
        mPublisherRecordAACFilePath = recordAACFilePath;
        if(mLSPublisher != null){
            mLSPublisher.stop();
            startPublisherInternal();
        }
    }

    /**
     * 3.切换摄像头
     */
    public void switchCamera(){
        if(mIsInited){
            mLSPublisher.rotateCamera();
        }

    }

    /**
     * 4.停止推流
     */
    public void stop(){
        if(mLSPublisher != null){
            mLSPublisher.stop();
        }
    }

    /**
     * 5.资源释放
     */
    public void release(){
        mIsImDisconnected = true;
        if(mLSPublisher != null){
            mIsInited = false;
            mLSPublisher.stop();
            mLSPublisher.uninit();
        }
    }

    /**
     * 内部启动尝试链接拉流
     */
    private void startPublisherInternal(){
        if(mManUploadUrls != null && mLSPublisher != null){
            //循环使用
            if(mPublisherUrlCurPosition >= mManUploadUrls.length || mPublisherUrlCurPosition <0){
                mPublisherUrlCurPosition = 0;
            }
            mLSPublisher.publisherUrl(packageUploadAndDownloadUrlWithToken(mManUploadUrls[mPublisherUrlCurPosition]), mPublisherRecordH264FilePath, mPublisherRecordAACFilePath);
        }
    }

    /**
     * 设置静音
     * @param isMute
     */
    public void setPublisherMute(boolean isMute){
        if(mLSPublisher != null){
            mLSPublisher.setMute(isMute);
        }
    }

    @Override
    public void onConnect(LSPublisher lsPublisher) {
        if(null != listener){
            //用于界面提示
            listener.onPushStreamConnect(lsPublisher);
        }
    }

    /**
     * 推流器断开通知
     * @param lsPublisher
     */
    @Override
    public void onDisconnect(LSPublisher lsPublisher) {
        if(!mIsImDisconnected) {
            mActivity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    mPublisherReconnectCount++;
                    if (mPublisherReconnectCount > MAX_RECONNECTCOUNT) {
                        //重连次数达标，需要换url
                        mPublisherReconnectCount = 0;
                        mPublisherUrlCurPosition++;
                        if(mLSPublisher != null){
                            mLSPublisher.stop();
                            startPublisherInternal();
                        }
                    }
                }
            });
            if(null != listener){
                //用于界面提示
                listener.onPushStreamDisconnect(lsPublisher);
            }
        }
    }

    @Override
    public void onVideoCaptureError(LSPublisher lsPublisher, int i) {

    }

    /**
     * IM断线时，停止推流，等重连
     */
    public void onLogout(){
        mIsImDisconnected = true;
        stop();
    }

    /**
     * 设置静音
     * @param isMute
     */
    public void setPushStreamMute(boolean isMute){
        if(mLSPublisher != null){
            mLSPublisher.setMute(isMute);
        }
    }

    /************************************** 拼装视频上传或下载增加token *************************************/
    /**
     * rtmp上传下载添加token用于身份识别
     * @param url
     * @return
     */
    private String packageUploadAndDownloadUrlWithToken(String url){
        String packageUrl = url;
        LoginItem item = LoginManager.getInstance().getLoginItem();
        StringBuilder sb = new StringBuilder(url);
        if(item != null && !TextUtils.isEmpty(item.token) && !TextUtils.isEmpty(url)){
            if(url.contains("?")){
                sb.append("&token=");
            }else{
                sb.append("?token=");
            }
            sb.append(item.token);

            sb.append("&deviceid=");
            String deviceId = SystemUtils.getDeviceId(mActivity);
            sb.append(deviceId);

            packageUrl = sb.toString();
        }
        return packageUrl;
    }

}
