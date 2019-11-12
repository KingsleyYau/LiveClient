package com.qpidnetwork.anchor.liveshow.liveroom;

import android.app.Activity;
import android.opengl.GLSurfaceView;
import android.text.TextUtils;

import com.qpidnetwork.anchor.httprequest.item.LoginItem;
import com.qpidnetwork.anchor.liveshow.authorization.LoginManager;
import com.qpidnetwork.anchor.liveshow.datacache.preference.LocalPreferenceManager;
import com.qpidnetwork.anchor.liveshow.liveroom.beautyfilter.BeautyFilterBean;
import com.qpidnetwork.anchor.liveshow.liveroom.beautyfilter.BeautyFilterType;
import com.qpidnetwork.anchor.utils.Log;
import com.qpidnetwork.anchor.utils.SystemUtils;
import com.qpidnetwork.qnbridgemodule.util.ListUtils;

import net.qdating.LSConfig;
import net.qdating.LSPublisher;
import net.qdating.filter.LSImageFilter;
import net.qdating.filter.sample.LSImageSampleBeautyBaseFilter;
import net.qdating.filter.sample.LSImageSampleBeautyBaseFilterEvent;
import net.qdating.filter.sample.LSImageSampleBeautyEmeraldFilter;
import net.qdating.filter.sample.LSImageSampleBeautyHealthyFilter;
import net.qdating.filter.sample.LSImageSampleBeautyHefeFilter;
import net.qdating.filter.sample.LSImageSampleBeautyLomoFilter;
import net.qdating.filter.sample.LSImageSampleBeautySakuraFilter;
import net.qdating.filter.sample.LSImageSampleBeautySunsetFilter;
import net.qdating.publisher.ILSPublisherStatusCallback;

import java.util.ArrayList;
import java.util.List;

/**
 * 拉流播放器管理器
 * 0.初始化
 * 1.开始推流
 * 2.切换摄像头
 * 3.停止推流
 * 4.资源释放
 * 5.断线重连
 * Created by Hunter on 17/11/14.
 */

public class LiveStreamPushManager implements ILSPublisherStatusCallback {
    private final String TAG = LiveStreamPushManager.class.getSimpleName();
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
    //标记是否开启预览
    private boolean mIsCameraPreviewOpen = false;

    public interface ILSPublisherStatusListener {
        void onPushStreamConnect(LSPublisher var1);

        void onPushStreamDisconnect(LSPublisher var1);
    }

    public LiveStreamPushManager(Activity activity) {
        Log.d(TAG, "LiveStreamPushManager");
        mActivity = activity;
    }

    public void setILSPublisherStatusListener(ILSPublisherStatusListener listener) {
        Log.d(TAG, "setILSPublisherStatusListener");
        this.listener = listener;
    }

    /**
     * 0.初始化
     *
     * @param svPublisher
     */
    public void init(GLSurfaceView svPublisher) {
        Log.d(TAG, "init");
        if (mLSPublisher == null) {
            mIsInited = true;
            mLSPublisher = new LSPublisher();

            svPublisher.setKeepScreenOn(true);

            int rotation = mActivity.getWindowManager().getDefaultDisplay().getRotation();
            mLSPublisher.init(mActivity.getApplicationContext(), svPublisher, rotation,
                    LSConfig.FillMode.FillModeAspectRatioFill, this,
                    LSConfig.VideoConfigType.VideoConfigType480x640 /*LSConfig.VideoConfigType.VideoConfigType240x320*/,
                    12, 12, 720 * 1080);

            // 2019/10/30 Hardy
            initPushFilter();
        }
    }

    /**
     * 是否初始化
     *
     * @return
     */
    public boolean isInited() {
        Log.d(TAG, "isInited-mIsInited:" + mIsInited);
        return mIsInited;
    }

    /**
     * 是否开启预览
     *
     * @return
     */
    public boolean isCameraPreviewOpen() {
        return mIsCameraPreviewOpen;
    }

    /**
     * 1.开启摄像头预览
     */
    public boolean openCameraPreview() {
        Log.d(TAG, "openCameraPreview-mIsInited:" + mIsInited);
        boolean openCameraResult = false;
        if (mIsInited) {
            openCameraResult = mLSPublisher.startPreview();
        }
        Log.d(TAG, "openCameraPreview-openCameraResult:" + openCameraResult);
        mIsCameraPreviewOpen = openCameraResult;
        return openCameraResult;

    }

    /**
     * 关闭摄像头预览--release里面会顺带停掉视频预览，因此基本不会调用该方法
     */
    public void closeCameraPreview() {
        Log.d(TAG, "closeCameraPreview-mIsInited:" + mIsInited);
        mIsCameraPreviewOpen = false;
        if (mIsInited) {
            mLSPublisher.stopPreview();
        }
    }

    /**
     * 2.设置或更改推流地址列表，并开始推流
     *
     * @param manUploadUrls
     * @param recordH264FilePath
     * @param recordAACFilePath
     */
    public void setOrChangeUploadUrls(String[] manUploadUrls,
                                      String recordH264FilePath,
                                      String recordAACFilePath) {
        Log.d(TAG, "setOrChangeUploadUrls");
        mPublisherUrlCurPosition = 0;
        mPublisherReconnectCount = 0;
        mIsImDisconnected = false;
        mManUploadUrls = manUploadUrls;
        mPublisherRecordH264FilePath = recordH264FilePath;
        mPublisherRecordAACFilePath = recordAACFilePath;
        if (mLSPublisher != null) {
            mLSPublisher.stop();
            startPublisherInternal();
        }
    }

    /**
     * 内部启动尝试链接拉流
     */
    private void startPublisherInternal() {
        Log.d(TAG, "startPublisherInternal");
        if (mManUploadUrls != null && mLSPublisher != null) {
            //循环使用
            if (mPublisherUrlCurPosition >= mManUploadUrls.length || mPublisherUrlCurPosition < 0) {
                mPublisherUrlCurPosition = 0;
            }
            mLSPublisher.publisherUrl(
                    packageUploadAndDownloadUrlWithToken(mManUploadUrls[mPublisherUrlCurPosition]),
                    mPublisherRecordH264FilePath,
                    mPublisherRecordAACFilePath);
        }
    }

    /**
     * 3.切换摄像头
     */
    public void switchCamera() {
        Log.d(TAG, "switchCamera");
        if (mIsInited) {
            mLSPublisher.rotateCamera();
        }

    }

    /**
     * 4.停止推流
     */
    public void stop() {
        if (mLSPublisher != null) {
            //手动停止则不需要再行重试推流尝试,@NOTE:测试的时候需要屏蔽mIsImDisconnected = true;
            mIsImDisconnected = true;
            Log.d(TAG, "stop-mIsImDisconnected:" + mIsImDisconnected);
            mLSPublisher.stop();
        }
    }

//    /**
//     * 测试推流器断开的方法,测试的时候需要将方法签名private更改为public
//     */
//    private void stopForTest(){
//        if(mLSPublisher != null){
//            Log.d(TAG,"stopInternal-mIsImDisconnected:"+mIsImDisconnected);
//            mLSPublisher.stop();
//        }
//    }

    /**
     * 5.资源释放
     */
    public void release() {
        Log.d(TAG, "release");
        mIsImDisconnected = true;
        if (mLSPublisher != null) {
            mIsInited = false;
            mLSPublisher.stop();
            mLSPublisher.uninit();
        }
    }

    @Override
    public void onConnect(LSPublisher lsPublisher) {
        mPublisherReconnectCount = 0;
        if (null != listener) {
            //用于界面提示
            listener.onPushStreamConnect(lsPublisher);
        }
        Log.d(TAG, "onConnect-mIsImDisconnected:" + mIsImDisconnected + " mPublisherReconnectCount:" + mPublisherReconnectCount);
    }

    /**
     * 推流器断开通知
     *
     * @param lsPublisher
     */
    @Override
    public void onDisconnect(final LSPublisher lsPublisher) {
        Log.d(TAG, "onDisconnect-mIsImDisconnected:" + mIsImDisconnected);
        if (!mIsImDisconnected) {
            mActivity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    mPublisherReconnectCount++;
                    if (mPublisherReconnectCount > MAX_RECONNECTCOUNT) {
                        //重连次数达标，需要换url
                        mPublisherReconnectCount = 0;
                        mPublisherUrlCurPosition++;
                        if (mLSPublisher != null) {
                            mLSPublisher.stop();
                            startPublisherInternal();
                        }
                    }
                }
            });
            if (null != listener) {
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
    public void onLogout() {
        Log.d(TAG, "onLogout-mIsImDisconnected:" + mIsImDisconnected);
        //手动停止则不需要再行重试推流尝试,例如IM断线界面仅仅会提示toast，此时就不再需要回调onDisconnect以避免再次toast并loading anim
        stop();
    }

    /**
     * 设置静音
     *
     * @param isMute
     */
    public void setPushStreamMute(boolean isMute) {
        Log.d(TAG, "setPushStreamMute-isMute:" + isMute);
        if (mLSPublisher != null) {
            mLSPublisher.setMute(isMute);
        }
    }


    /**
     * rtmp上传下载添加token用于身份识别
     *
     * @param url
     * @return
     */
    private String packageUploadAndDownloadUrlWithToken(String url) {
        Log.d(TAG, "packageUploadAndDownloadUrlWithToken-url:" + url);
        String packageUrl = url;
        LoginItem item = LoginManager.getInstance().getLoginItem();
        StringBuilder sb = new StringBuilder(url);
        if (item != null && !TextUtils.isEmpty(item.token) && !TextUtils.isEmpty(url)) {
            if (url.contains("?")) {
                sb.append("&token=");
            } else {
                sb.append("?token=");
            }
            sb.append(item.token);

            sb.append("&deviceid=");
            String deviceId = SystemUtils.getDeviceId(mActivity);
            sb.append(deviceId);

            sb.append("&device_type=30");

            packageUrl = sb.toString();
        }
        return packageUrl;
    }


    //=========================  2019/10/29 Hardy 设置美颜参数=========================================
    // 推流预设滤镜
    public static final int PUSH_FILTER_MAX_PROGRESS = 100;
    private int mPushFilterIndex = 0;
    private List<LSImageFilter> mPushFilterList;
    private LocalPreferenceManager localPreferenceManager;
    private List<BeautyFilterBean> mFilterBeanList;

    private void initPushFilter() {
        com.qpidnetwork.qnbridgemodule.util.Log.i("info","----------------- initPushFilter ------------------------");

        localPreferenceManager = new LocalPreferenceManager(mActivity);
        mPushFilterList = new ArrayList<>();

        // 初始化滤镜顺序要和 BeautyFilterType 对应
        mPushFilterList.add(new LSImageSampleBeautyBaseFilter(mActivity));
        mPushFilterList.add(new LSImageSampleBeautyEmeraldFilter(mActivity));
        mPushFilterList.add(new LSImageSampleBeautyHealthyFilter(mActivity));
        mPushFilterList.add(new LSImageSampleBeautyHefeFilter(mActivity));
        mPushFilterList.add(new LSImageSampleBeautyLomoFilter(mActivity));
        mPushFilterList.add(new LSImageSampleBeautySakuraFilter(mActivity));
        mPushFilterList.add(new LSImageSampleBeautySunsetFilter(mActivity));

        // 取上次设置的值
        mPushFilterIndex = localPreferenceManager.getLiveRoomFilterType();
        if (!ListUtils.isValidPosition(mPushFilterList, mPushFilterIndex)) {
            mPushFilterIndex = 0;
        }
        // 设置滤镜
        setBeautyFilter(mPushFilterIndex, false);

        // 初始化滤镜列表的数据
        mFilterBeanList = new ArrayList<>();
        int len = BeautyFilterType.values().length;
        for (int i = 0; i < len; i++) {
            BeautyFilterBean bean = new BeautyFilterBean(BeautyFilterType.values()[i]);
            bean.isSelect = i == mPushFilterIndex;  // 上次选中的滤镜
            mFilterBeanList.add(bean);
        }
    }

    public List<BeautyFilterBean> getFilterBeanList() {
        return mFilterBeanList;
    }

    /**
     * 设置美颜级别
     *
     * @param progress 进度条 0~100
     */
    public void setBeautyLevel(int progress) {
        LSImageSampleBeautyBaseFilterEvent event = (LSImageSampleBeautyBaseFilterEvent) mPushFilterList.get(mPushFilterIndex);
        localPreferenceManager.saveLiveRoomFilterBeautyLevel(progress);
        setBeautyLevel(event, progress);
    }

    /**
     * 设置美白级别
     *
     * @param progress 进度条 0~100
     */
    public void setStrength(int progress) {
        LSImageSampleBeautyBaseFilterEvent event = (LSImageSampleBeautyBaseFilterEvent) mPushFilterList.get(mPushFilterIndex);
        localPreferenceManager.saveLiveRoomFilterBeautyStrength(progress);
        setStrength(event, progress);
    }

    /**
     * 设置滤镜
     *
     * @param pos 哪个位置的滤镜
     */
    public void setBeautyFilter(int pos, boolean isSaveLocal) {
        if (ListUtils.isValidPosition(mPushFilterList, pos)) {
            this.mPushFilterIndex = pos;

            if (mLSPublisher != null) {
                LSImageSampleBeautyBaseFilterEvent event = (LSImageSampleBeautyBaseFilterEvent) mPushFilterList.get(mPushFilterIndex);
                // 美颜级别
                setBeautyLevel(event, getLocalBeautyLevel());
                // 美白级别
                setStrength(event, getLocalBeautyStrength());
                // 设置滤镜
                mLSPublisher.setCustomFilter(mPushFilterList.get(mPushFilterIndex));
                // 保存选中位置在本地
                if (isSaveLocal) {
                    localPreferenceManager.saveLiveRoomFilterType(BeautyFilterType.values()[pos]);
                }
            }
        }
    }

    public int getLocalBeautyLevel() {
        return localPreferenceManager.getLiveRoomFilterBeautyLevel();
    }

    public int getLocalBeautyStrength() {
        return localPreferenceManager.getLiveRoomFilterBeautyStrength();
    }

    private void setBeautyLevel(LSImageSampleBeautyBaseFilterEvent event, int progress) {
        event.setBeautyLevel(getProgressScale(progress));
    }

    private void setStrength(LSImageSampleBeautyBaseFilterEvent event, int progress) {
        event.setStrength(getProgressScale(progress));
    }

    private float getProgressScale(int progress) {
        if (progress < 0) {
            progress = 0;
        }
        if (progress > PUSH_FILTER_MAX_PROGRESS) {
            progress = PUSH_FILTER_MAX_PROGRESS;
        }

        return progress * 1.0f / PUSH_FILTER_MAX_PROGRESS;
    }
}
