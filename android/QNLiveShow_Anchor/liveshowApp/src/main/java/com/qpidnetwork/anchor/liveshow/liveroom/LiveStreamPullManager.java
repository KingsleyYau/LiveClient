package com.qpidnetwork.anchor.liveshow.liveroom;

import android.app.Activity;
import android.opengl.GLSurfaceView;
import android.text.TextUtils;

import com.qpidnetwork.anchor.httprequest.item.LoginItem;
import com.qpidnetwork.anchor.liveshow.authorization.LoginManager;
import com.qpidnetwork.anchor.utils.Log;
import com.qpidnetwork.anchor.utils.SystemUtils;

import net.qdating.LSConfig;
import net.qdating.LSPlayer;
import net.qdating.player.ILSPlayerStatusCallback;
import net.qdating.player.LSPlayerRendererBinder;

/**
 * 推流器管理
 * Created by Hunter on 17/11/14.
 */

public class LiveStreamPullManager implements ILSPlayerStatusCallback {
    private static final int MAX_RECONNECTCOUNT = 5;
    private final static String TAG = LiveStreamPullManager.class.getSimpleName();
    private Activity mActivity;
    private boolean mIsInit = false;
    private boolean mIsImDisconnected = false;
    //player
    private LSPlayer mLSPlayer;
    private int mPlayerReconnectCount = 0;
    private String[] mVideoUrls = null;
    private int mPlayerUrlCurPosition = -1;
    private String mPlayerRecordFilePath = "";
    private String mPlayerRecordH264FilePath = "";
    private String mPlayerRecordAACFilePath = "";


    public interface ILSPlayerStatusListener {
        void onPullStreamConnect(LSPlayer var1);

        void onPullStreamDisconnect(LSPlayer var1);
    }

    private ILSPlayerStatusListener listener;

    public void setILSPlayerStatusListener(ILSPlayerStatusListener listener){
        Log.d(TAG,"setILSPlayerStatusListener");
        this.listener = listener;
    }

    public LiveStreamPullManager(Activity activity){
        Log.d(TAG,"LiveStreamPullManager");
        this.mActivity = activity;
    }

    /**
     * 初始化
     * @param sv_player
     */
    public void init(GLSurfaceView sv_player){
        Log.d(TAG,"init");
        if(mLSPlayer == null){
            mIsInit = true;
            mLSPlayer = new LSPlayer();
//            mLSPlayer.init(sv_player, LSConfig.FillMode.FillModeAspectRatioFill, this);

            // 2019/10/29 Hardy 新的构造方法
            mLSPlayer.init(this);
            LSPlayerRendererBinder playerRenderderBinder = new LSPlayerRendererBinder(sv_player, LSConfig.FillMode.FillModeAspectRatioFill);
            playerRenderderBinder.setCustomFilter(null);    // 不加滤镜
            mLSPlayer.setRendererBinder(playerRenderderBinder);
        }
    }

    /**
     * 更换player显示view
     */
    public void changePlayer(GLSurfaceView sv_player){
        if(isInited() && mLSPlayer != null){
            LSPlayerRendererBinder binder = new LSPlayerRendererBinder(sv_player, LSConfig.FillMode.FillModeAspectRatioFill);
            binder.setCustomFilter(null);    // 不加滤镜
            mLSPlayer.setRendererBinder(binder);
        }
    }

    /**
     * 拉流 -- 静音
     * @param isSilent
     */
    public void setPullStreamSilent(boolean isSilent){
        Log.d(TAG,"setPullStreamSilent-isSilent:"+isSilent);
        if(mLSPlayer != null){
            mLSPlayer.setMute(isSilent);
        }
    }

    /**
     * manager 回收
     */
    public void release(){
        Log.d(TAG,"release");
        mIsImDisconnected = true;
        if(mLSPlayer != null){
            mIsInit = false;
            mLSPlayer.stop();
            mLSPlayer.uninit(); //防止内存泄漏
        }
    }

    /**
     * 是否初始化成功
     * @return
     */
    public boolean isInited(){
        Log.d(TAG,"release-mIsInit:"+mIsInit);
        return mIsInit;
    }

    /**
     * 设置或更改播放流地址列表，并开始播放
     * @param videoUrls
     */
    public void setOrChangeVideoUrls(String[] videoUrls, String recordFilePath, String recordH264FilePath, String recordAACFilePath){
        Log.d(TAG,"setOrChangeVideoUrls");
        mPlayerUrlCurPosition = 0;
        mPlayerReconnectCount = 0;
        mIsImDisconnected = false;
        mVideoUrls = videoUrls;
        mPlayerRecordFilePath = recordFilePath;
        mPlayerRecordH264FilePath = recordH264FilePath;
        mPlayerRecordAACFilePath = recordAACFilePath;
        if(mLSPlayer != null){
            mLSPlayer.stop();
            startPlayerInternal();
        }
    }

    /**
     * 内部启动尝试链接拉流
     */
    private void startPlayerInternal(){
        Log.d(TAG,"startPlayerInternal");
        if(mVideoUrls != null && mLSPlayer != null){
            //循环使用
            if(mPlayerUrlCurPosition >= mVideoUrls.length || mPlayerUrlCurPosition <0){
                mPlayerUrlCurPosition = 0;
            }
            mLSPlayer.playUrl(packageUploadAndDownloadUrlWithToken(mVideoUrls[mPlayerUrlCurPosition]),
                    mPlayerRecordFilePath, mPlayerRecordH264FilePath, mPlayerRecordAACFilePath);
        }
    }

    /**
     * 内部停止播放器
     */
    public void stopPlayInternal(){
        Log.d(TAG,"stopPlayInternal");
        mIsImDisconnected = true;
        if(mLSPlayer != null){
            mLSPlayer.stop();
        }
    }

    @Override
    public void onConnect(LSPlayer lsPlayer) {
        mPlayerReconnectCount = 0;

        if(null != listener){
            listener.onPullStreamConnect(lsPlayer);
        }

        Log.d(TAG,"onConnect-mIsImDisconnected:"+mIsImDisconnected+" mPlayerReconnectCount:"+mPlayerReconnectCount);
    }

    /**
     * 播放器断开通知
     * @param lsPlayer
     */
    @Override
    public void onDisconnect(LSPlayer lsPlayer) {
        Log.d(TAG,"onDisconnect-mIsImDisconnected:"+mIsImDisconnected);
        if(!mIsImDisconnected) {
            mActivity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    mPlayerReconnectCount++;
                    if (mPlayerReconnectCount > MAX_RECONNECTCOUNT) {
                        //重连次数达标，需要换url
                        mPlayerReconnectCount = 0;
                        mPlayerUrlCurPosition++;
                        //替换url需先停止再启动
                        if(mLSPlayer != null){
                            mLSPlayer.stop();
                            startPlayerInternal();
                        }
                    }
                }
            });
            if(null != listener){
                //用于界面提示
                listener.onPullStreamDisconnect(lsPlayer);
            }
        }
    }

    /**
     * IM断线时，停止推流，等重连
     */
    public void onLogout(){
        mIsImDisconnected = true;
        Log.d(TAG,"onLogout-mIsImDisconnected:"+mIsImDisconnected);
        stopPlayInternal();
    }

    /************************************** 拼装视频上传或下载增加token *************************************/
    /**
     * rtmp上传下载添加token用于身份识别
     * @param url
     * @return
     */
    private String packageUploadAndDownloadUrlWithToken(String url){
        Log.d(TAG,"packageUploadAndDownloadUrlWithToken-url:"+url);
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
