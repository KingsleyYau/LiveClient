package com.qpidnetwork.livemodule.liveshow.liveroom;

import android.app.Activity;
import android.opengl.GLSurfaceView;
import android.text.TextUtils;
import android.util.Log;
import android.view.SurfaceView;

import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.utils.SystemUtils;

import net.qdating.LSConfig;
import net.qdating.LSPlayer;
import net.qdating.player.ILSPlayerStatusCallback;
import net.qdating.player.LSPlayerRendererBinder;

/**
 * 拉流播放器管理器
 * Created by Hunter on 17/11/14.
 */

public class LivePlayerManager implements ILSPlayerStatusCallback {

    private static final int MAX_RECONNECTCOUNT = 5;

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

    private ILSPlayerStatusListener listener;
    public interface ILSPlayerStatusListener {
        void onPullStreamConnect(LSPlayer var1);

        void onPullStreamDisconnect(LSPlayer var1);
    }

    public void setILSPlayerStatusListener(ILSPlayerStatusListener listener){
        this.listener = listener;
    }

    public void removeILSPlayerStatusListener(){
        this.listener = null;
    }

    public LivePlayerManager(Activity activity){
        this.mActivity = activity;
    }

    /**
     * 初始化
     * @param lsPlayerRendererBinder
     */
    public void init(LSPlayerRendererBinder lsPlayerRendererBinder){
        if(mLSPlayer == null){
            mIsInit = true;
            mLSPlayer = new LSPlayer();
            mLSPlayer.init(this);
            mLSPlayer.setRendererBinder(lsPlayerRendererBinder);
        }
    }

    /**
     * manager 回收
     */
    public void uninit(){
        if(mLSPlayer != null){
            mIsInit = false;
            mLSPlayer.stop();
            mLSPlayer.uninit(); //防止内存泄漏
            //uninit需要置空，否则uninit后调用其他接口可能死机
            mLSPlayer = null;
        }
    }

    /**
     * 拉流 -- 静音
     * @param isSilent
     */
    public void setPullStreamSilent(boolean isSilent){
        if(mLSPlayer != null){
            mLSPlayer.setMute(isSilent);
        }
    }

    /**
     * manager 回收
     */
    public void release(){
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
        return mIsInit;
    }

    /**
     * 创建并配置
     * @param sv_player
     * @return
     */
    public static LSPlayerRendererBinder createPlayerRenderBinder(GLSurfaceView sv_player){
        LSPlayerRendererBinder binder = new LSPlayerRendererBinder(sv_player, LSConfig.FillMode.FillModeAspectRatioFill);
        return binder;
    }

    /**
     * 更换player显示view
     */
    public void changePlayerRenderBinder(LSPlayerRendererBinder lsPlayerRendererBinder){
        if(isInited() && mLSPlayer != null){
            Log.i("hunter", "changePlayerRenderBinder lsPlayerRendererBinder: " + lsPlayerRendererBinder);
            mLSPlayer.setRendererBinder(lsPlayerRendererBinder);
        }
    }

    /**
     * 设置或更改播放流地址列表，并开始播放
     * @param videoUrls
     */
    public void setOrChangeVideoUrls(String[] videoUrls, String recordFilePath, String recordH264FilePath, String recordAACFilePath){
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
        if(mVideoUrls != null && mLSPlayer != null){
            //循环使用
            if(mPlayerUrlCurPosition >= mVideoUrls.length || mPlayerUrlCurPosition <0){
                mPlayerUrlCurPosition = 0;
            }
            mLSPlayer.playUrl(packageUploadAndDownloadUrlWithToken(mVideoUrls[mPlayerUrlCurPosition]), mPlayerRecordFilePath, mPlayerRecordH264FilePath, mPlayerRecordAACFilePath);
        }
    }

    /**
     * 内部停止播放器
     */
    private void stopPlayInternal(){
        if(mLSPlayer != null){
            mLSPlayer.stop();
        }
    }

    @Override
    public void onConnect(LSPlayer lsPlayer) {
        if(null != listener){
            listener.onPullStreamConnect(lsPlayer);
        }
    }

    /**
     * 播放器断开通知
     * @param lsPlayer
     */
    @Override
    public void onDisconnect(LSPlayer lsPlayer) {
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
        stopPlayInternal();
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
