package com.qpidnetwork.livemodule.liveshow.liveroom;

import android.app.Activity;
import android.opengl.GLSurfaceView;
import android.text.TextUtils;
import android.view.SurfaceView;

import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.utils.SystemUtils;

import net.qdating.LSConfig;
import net.qdating.LSPlayer;
import net.qdating.player.ILSPlayerStatusCallback;

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

    public LivePlayerManager(Activity activity){
        this.mActivity = activity;
    }

    /**
     * 初始化
     * @param sv_player
     */
    public void init(GLSurfaceView sv_player){
        if(mLSPlayer == null){
            mIsInit = true;
            mLSPlayer = new LSPlayer();
            mLSPlayer.init(sv_player, LSConfig.FillMode.FillModeAspectRatioFill, this);
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
     * 是否初始化成功
     * @return
     */
    public boolean isInited(){
        return mIsInit;
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
