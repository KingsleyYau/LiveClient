package com.qpidnetwork.livemodule.liveshow.livechat;

import android.graphics.Color;
import android.net.Uri;
import android.os.Message;
import android.support.v4.content.ContextCompat;
import android.text.TextUtils;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.SeekBar;
import android.widget.TextView;

import com.facebook.common.util.UriUtil;
import com.facebook.drawee.backends.pipeline.Fresco;
import com.facebook.drawee.drawable.ScalingUtils;
import com.facebook.drawee.generic.GenericDraweeHierarchy;
import com.facebook.drawee.generic.GenericDraweeHierarchyBuilder;
import com.facebook.drawee.interfaces.DraweeController;
import com.facebook.drawee.view.SimpleDraweeView;
import com.facebook.imagepipeline.postprocessors.IterativeBoxBlurPostProcessor;
import com.facebook.imagepipeline.request.ImageRequest;
import com.facebook.imagepipeline.request.ImageRequestBuilder;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.livechat.LCMessageItem;
import com.qpidnetwork.livemodule.livechat.LCUserItem;
import com.qpidnetwork.livemodule.livechat.LCVideoItem;
import com.qpidnetwork.livemodule.livechat.LiveChatManager;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener;
import com.qpidnetwork.livemodule.livechathttprequest.LCRequestJniLiveChat;
import com.qpidnetwork.livemodule.liveshow.livechat.video.LiveChatVideoPreviewControl;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.utils.ImageUtil;
import com.qpidnetwork.livemodule.view.ButtonRaised;
import com.qpidnetwork.qnbridgemodule.bean.RequestErrorCodeCommon;
import com.qpidnetwork.qnbridgemodule.util.DisplayUtil;
import com.qpidnetwork.qnbridgemodule.util.FileUtil;
import com.qpidnetwork.qnbridgemodule.util.Log;
import com.xiao.nicevideoplayer.NiceVideoPlayer;
import com.xiao.nicevideoplayer.NiceVideoPlayerManager;

import java.util.ArrayList;

/**
 * 2019/5/7 Hardy
 * 直播 LiveChat 视频详情
 */
public class LiveChatVideoPreviewFragment extends LiveChatBasePreviewFragment {

    // 原图
    private SimpleDraweeView mDraweeSourceView;
    // 模糊图
    private SimpleDraweeView mDraweeBlurView;
    // 加载中
    private ProgressBar mPbLoading;
    // 一般错误
    private TextView mTvErrorNormal;
    // 网络错误
    private View mLLErrorNet;
    private TextView mTvErrorNet;
    private ButtonRaised mBtnErrorNetRetry;
    // 未付费
    private View mLLUnBuy;
    private TextView mTvUnBuyTip;
    private ImageView mBtnUnBuy;
    //视频播放 view
    private NiceVideoPlayer mVideoPlayer;
    private LiveChatVideoPreviewControl mVideoControl;
    // 待播放按钮
    private ImageView mBtnPlayBig;
    // 底部视频描述
    private View mLLBottomDesc;
    private TextView mTvPhotoDesc;
    private ImageView mBtnPlaySmall;
    private SeekBar mVideoSeekbar;

    /**
     * 接口请求错误类型
     */
    private enum RequestCodeType {
        VIDEO_IMAGE_SUCCESS,
        VIDEO_IMAGE_FAILED,

        DOWNLOAD_VIDEO_SUCCESS,
        DOWNLOAD_VIDEO_FAILED,

        FEE_SUCCESS,
        FEE_FAILED
    }

    public LiveChatVideoPreviewFragment() {
        // Required empty public constructor
    }

    @Override
    protected int getLayoutResId() {
        return R.layout.fragment_live_chat_video_preview;
    }

    @Override
    protected void initView(View rootView) {
        mDraweeSourceView = rootView.findViewById(R.id.fg_live_chat_video_preview_image);

        mDraweeBlurView = rootView.findViewById(R.id.fg_live_chat_video_preview_image_blur);

        mPbLoading = rootView.findViewById(R.id.fg_live_chat_video_preview_pb_loading);

        mTvErrorNormal = rootView.findViewById(R.id.fg_live_chat_video_preview_tv_error_normal);

        mLLErrorNet = rootView.findViewById(R.id.fg_live_chat_video_preview_ll_error_net);
        mTvErrorNet = rootView.findViewById(R.id.fg_live_chat_video_preview_tv_error_net);
        mBtnErrorNetRetry = rootView.findViewById(R.id.fg_live_chat_video_preview_btn_error_net_retry);

        mLLUnBuy = rootView.findViewById(R.id.fg_live_chat_video_preview_ll_un_buy);
        mTvUnBuyTip = rootView.findViewById(R.id.fg_live_chat_video_preview_tv_un_buy_tip);
        mBtnUnBuy = rootView.findViewById(R.id.fg_live_chat_video_preview_btn_un_buy);

        mBtnPlayBig = rootView.findViewById(R.id.fg_live_chat_video_preview_btn_play_big);

        mLLBottomDesc = rootView.findViewById(R.id.fg_live_chat_photo_preview_ll_photo_desc);
        mTvPhotoDesc = rootView.findViewById(R.id.fg_live_chat_photo_preview_tv_photo_desc);
        mBtnPlaySmall = rootView.findViewById(R.id.fg_live_chat_video_preview_btn_play_small);
        mVideoSeekbar = rootView.findViewById(R.id.fg_live_chat_video_preview_seekBar);

        mVideoPlayer = rootView.findViewById(R.id.fg_live_chat_video_preview_player);
        // 2019/5/9 设置 controller
        mVideoControl = new LiveChatVideoPreviewControl(mContext);
        mVideoControl.setOnPlayOperaListener(mVideoOnPlayOperaListener);
        mVideoControl.setOperaView(mVideoSeekbar, mBtnPlaySmall);
        mVideoControl.setOpenNoVideoFilePathCheck(true);        // 开启是否存在本地视频文件的点击事件拦截检测
        mVideoPlayer.setController(mVideoControl);

        mBtnErrorNetRetry.setOnClickListener(this);
        mBtnUnBuy.setOnClickListener(this);
        mBtnPlayBig.setOnClickListener(this);

        initPhotoBlurView();
        initPhotoSourceView();
    }

    @Override
    protected void initData() {
        resetContentView();
    }

    @Override
    protected void onFragmentVisible() {

    }

    @Override
    protected void onFragmentUnVisible() {
        // 先清除视频
        NiceVideoPlayerManager.instance().releaseNiceVideoPlayer();
        resetContentView();
    }

    /**
     * 播放器的播放操作回调
     */
    LiveChatVideoPreviewControl.OnPlayOperaListener mVideoOnPlayOperaListener = new LiveChatVideoPreviewControl.OnPlayOperaListener() {
        @Override
        public void onVideoPreparing() {

        }

        @Override
        public void onVideoStart() {

        }

        @Override
        public void onVideoPause() {
            // 暂时不用处理
        }

        @Override
        public void onVideoCompleted() {
            change2HasBuyView();
        }

        @Override
        public void onVideoContentClick() {
            clickContent2ShowOrHideView();
        }

        @Override
        public boolean isVideoFileExists() {
            boolean isExists;

            String filePath = getVideoFilePath();

            // 先展示 loading
            change2LoadingView();

            if (isFileExists(filePath)) {
                change2PlayView();

                // 防止在待播放状态，第一次点击小播放按钮，播放器的 url 为空而导致的崩溃问题
                mVideoPlayer.setUp(filePath, null);

                isExists = true;
            } else {
                isExists = false;
                // 不存在，去下载
                getVideo();
            }

            return isExists;
        }
    };


    @Override
    protected void change2UnBuyView() {
        // 先恢复状态
        resetTopBottomViewLocation();

        mDraweeSourceView.setVisibility(View.VISIBLE);
        mDraweeBlurView.setVisibility(View.VISIBLE);
        mLLBottomDesc.setVisibility(View.VISIBLE);
        mLLUnBuy.setVisibility(View.VISIBLE);

        mPbLoading.setVisibility(View.GONE);
        mTvErrorNormal.setVisibility(View.GONE);
        mLLErrorNet.setVisibility(View.GONE);
        mBtnPlayBig.setVisibility(View.GONE);
        mVideoPlayer.setVisibility(View.GONE);

        changePlayOperaEnabled(false);
    }

    @Override
    protected void change2LoadingView() {
        // 先恢复状态
        resetTopBottomViewLocation();

        mDraweeSourceView.setVisibility(View.VISIBLE);
        mDraweeBlurView.setVisibility(View.VISIBLE);
        mLLBottomDesc.setVisibility(View.VISIBLE);
        mPbLoading.setVisibility(View.VISIBLE);

        mBtnPlayBig.setVisibility(View.GONE);
        mLLUnBuy.setVisibility(View.GONE);
        mTvErrorNormal.setVisibility(View.GONE);
        mLLErrorNet.setVisibility(View.GONE);
        mVideoPlayer.setVisibility(View.GONE);

        changePlayOperaEnabled(false);
    }

    @Override
    protected void change2HasBuyView() {
        // 先恢复状态
        resetTopBottomViewLocation();

        mDraweeSourceView.setVisibility(View.VISIBLE);
        mDraweeBlurView.setVisibility(View.VISIBLE);
        mLLBottomDesc.setVisibility(View.VISIBLE);
        mBtnPlayBig.setVisibility(View.VISIBLE);

        mLLUnBuy.setVisibility(View.GONE);
        mPbLoading.setVisibility(View.GONE);
        mTvErrorNormal.setVisibility(View.GONE);
        mLLErrorNet.setVisibility(View.GONE);
        mVideoPlayer.setVisibility(View.GONE);

        changePlayOperaEnabled(true);
    }

    private void change2PlayView() {
        // 先恢复状态
        resetTopBottomViewLocation();

        mVideoPlayer.setVisibility(View.VISIBLE);
        mLLBottomDesc.setVisibility(View.VISIBLE);

        mBtnPlayBig.setVisibility(View.GONE);
        mDraweeSourceView.setVisibility(View.GONE);
        mDraweeBlurView.setVisibility(View.GONE);
        mLLUnBuy.setVisibility(View.GONE);
        mPbLoading.setVisibility(View.GONE);
        mTvErrorNormal.setVisibility(View.GONE);
        mLLErrorNet.setVisibility(View.GONE);

        changePlayOperaEnabled(true);
    }

    @Override
    protected void change2NotNetView(String tip) {
        // 先恢复状态
        resetTopBottomViewLocation();

        mDraweeSourceView.setVisibility(View.VISIBLE);
        mDraweeBlurView.setVisibility(View.VISIBLE);
        mLLBottomDesc.setVisibility(View.VISIBLE);
        mLLErrorNet.setVisibility(View.VISIBLE);

        mPbLoading.setVisibility(View.GONE);
        mBtnPlayBig.setVisibility(View.GONE);
        mLLUnBuy.setVisibility(View.GONE);
        mTvErrorNormal.setVisibility(View.GONE);
        mVideoPlayer.setVisibility(View.GONE);

        mTvErrorNet.setText(tip);
        changePlayOperaEnabled(false);
    }

    @Override
    protected void change2ErrorView(String tip) {
        // 先恢复状态
        resetTopBottomViewLocation();

        mDraweeSourceView.setVisibility(View.VISIBLE);
        mDraweeBlurView.setVisibility(View.VISIBLE);
        mLLBottomDesc.setVisibility(View.VISIBLE);
        mTvErrorNormal.setVisibility(View.VISIBLE);

        mPbLoading.setVisibility(View.GONE);
        mBtnPlayBig.setVisibility(View.GONE);
        mLLUnBuy.setVisibility(View.GONE);
        mLLErrorNet.setVisibility(View.GONE);
        mVideoPlayer.setVisibility(View.GONE);

        mTvErrorNormal.setText(tip);
        changePlayOperaEnabled(false);
    }

    @Override
    protected void tag2Retry() {
        // 先显示 loading view
        change2LoadingView();

        if (mRetryType == RetryType.FEE) {
            click2Fee();
        } else {
            // 下载视频文件
            getVideo();
        }
    }

    @Override
    protected void click2Fee() {
        // 先显示 loading view
        change2LoadingView();

        LiveChatManager.getInstance().VideoFee(messageItem);
    }

    @Override
    protected void getPhoto(LCMessageItem item) {
        LiveChatManager.getInstance().GetVideoPhoto(item, LCRequestJniLiveChat.VideoPhotoType.Big);
    }

    @Override
    protected View getTopBottomAnimView() {
        return mLLBottomDesc;
    }

    @Override
    protected void clickContent2ShowOrHideView() {
        super.clickContent2ShowOrHideView();
    }

    @Override
    protected void resetContentView() {
        if (messageItem == null || messageItem.getVideoItem() == null) {
            return;
        }

        LCVideoItem videoItem = messageItem.getVideoItem();
        boolean isCharge = videoItem.charget;

        // 设置图片描述
        setPhotoDesc(videoItem.videoDesc);

        // 设置主播的 tip
        LCUserItem userItem = LiveChatManager.getInstance().GetUserWithId(mAnchorId);
        if (userItem != null) {
            setPhotoNameString(userItem.userName);
        }

        // 显示封面图或者下载封面图
        String imagePath = videoItem.bigPhotoFilePath;
        if (!TextUtils.isEmpty(imagePath) && FileUtil.isFileExists(imagePath)) {
            setPhotoAll(imagePath);
        } else {
            getPhoto(messageItem);
        }

        // 显示已付费/未付费的 View 状态
        if (isCharge) {
            change2HasBuyView();
        } else {
            change2UnBuyView();
        }
    }

    private void videoStart(String videoFilePath) {
        Log.i(TAG, "------------videoStart----------videoFilePath: " + videoFilePath);

        mVideoPlayer.setUp(videoFilePath, null);
        // 2019/5/10 control 控制开始播放，
        mVideoControl.start();
    }

    private void setPhotoNameString(String womanName) {
        String val = mContext.getString(R.string.livechat_video_name, womanName);
        mTvUnBuyTip.setText(val);
    }

    private void setPhotoDesc(String desc) {
        mTvPhotoDesc.setText(desc);
    }

    private void changePlayOperaEnabled(boolean isEnabled) {
        mBtnPlaySmall.setEnabled(isEnabled);
        mVideoSeekbar.setEnabled(isEnabled);
    }

    /**
     * 下载视频文件
     */
    private void getVideo() {
        /*
            2019/5/22 Hardy
            先判断视频 url 是否为空，如果为空，则先调用 video fee 接口获取 url，再进行下载
            避免换设备后，取视频消息历史数据的 url 会为空，导致已付费但下载本地文件不成功的问题
         */
        if (isVideoUrlNull()) {
            click2Fee();
        } else {
            LiveChatManager.getInstance().GetVideo(messageItem);
        }
    }

    private void initPhotoBlurView() {
        ImageUtil.showImageColorFilter(true, mDraweeBlurView, Color.LTGRAY);

        //占位图，拉伸方式
        GenericDraweeHierarchyBuilder builder = new GenericDraweeHierarchyBuilder(mContext.getResources());
        GenericDraweeHierarchy hierarchy = builder
                .setActualImageScaleType(ScalingUtils.ScaleType.FIT_XY)      // 按比例放大到屏幕最大
                .build();
        mDraweeBlurView.setHierarchy(hierarchy);
    }


    private void initPhotoSourceView() {
        // 阴影蒙层
        ImageUtil.showImageColorFilter(true, mDraweeSourceView, ContextCompat.getColor(mContext, R.color.white_text_70));

        // 设置原图的高度，和屏幕宽度一致
        FrameLayout.LayoutParams srcParams = (FrameLayout.LayoutParams) mDraweeSourceView.getLayoutParams();
        srcParams.height = DisplayUtil.getScreenWidth(mContext);
        mDraweeSourceView.setLayoutParams(srcParams);

        //占位图，拉伸方式
        GenericDraweeHierarchyBuilder builder = new GenericDraweeHierarchyBuilder(mContext.getResources());
        GenericDraweeHierarchy hierarchy = builder
                .setActualImageScaleType(ScalingUtils.ScaleType.CENTER_CROP)      // 居中显示,缩小或放大
                .build();
        mDraweeSourceView.setHierarchy(hierarchy);
    }

    private void setPhotoViewUrl(SimpleDraweeView simpleDraweeView, String filePath, boolean isBlur) {
        if (simpleDraweeView == null) {
            return;
        }

        //加载本地图片
        Uri uri = new Uri.Builder()
                .scheme(UriUtil.LOCAL_FILE_SCHEME)
                .path(filePath)
                .build();


        DraweeController controller = null;
        if (isBlur) {   // 模糊图，高斯模糊
            ImageRequest requestBlur = ImageRequestBuilder.newBuilderWithSource(uri)
                    .setPostprocessor(new IterativeBoxBlurPostProcessor(2, 30))    //迭代次数，越大越魔化。 //模糊图半径，必须大于0，越大越模糊。
                    .build();

            controller = Fresco.newDraweeControllerBuilder()
                    .setUri(uri)
                    .setOldController(simpleDraweeView.getController())
                    .setImageRequest(requestBlur)
                    .build();
        } else {
            controller = Fresco.newDraweeControllerBuilder()
                    .setUri(uri)
                    .setOldController(simpleDraweeView.getController())
                    .build();
        }

        simpleDraweeView.setController(controller);
    }

    private void setPhotoAll(String filePath) {
        setPhotoViewUrl(mDraweeBlurView, filePath, true);
        setPhotoViewUrl(mDraweeSourceView, filePath, false);
    }

    private String getVideoFilePath() {
        if (messageItem != null && messageItem.getVideoItem() != null && !TextUtils.isEmpty(messageItem.getVideoItem().videoFilePath)) {
            return messageItem.getVideoItem().videoFilePath;
        }
        return "";
    }

    /**
     * 判断视频文件 url 是否为空
     *
     * @return
     */
    private boolean isVideoUrlNull() {
        if (messageItem != null && messageItem.getVideoItem() != null && !TextUtils.isEmpty(messageItem.getVideoItem().videoUrl)) {
            return false;
        }

        return true;
    }

    private boolean isFileExists(String filePath) {
        if (!TextUtils.isEmpty(filePath) && FileUtil.isFileExists(filePath)) {
            return true;
        }
        return false;
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);

        int id = v.getId();

        if (id == R.id.fg_live_chat_video_preview_btn_error_net_retry) {
            tag2Retry();
        } else if (id == R.id.fg_live_chat_video_preview_btn_un_buy) {
//            showBuyTipDialog(mContext.getString(R.string.credits_per_video_25));
            click2Fee();
        } else if (id == R.id.fg_live_chat_video_preview_btn_play_big) {
            videoStart(getVideoFilePath());
        }
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);

        HttpRespObject httpRespObject = (HttpRespObject) msg.obj;
        RequestCodeType requestCodeType = RequestCodeType.values()[msg.what];

        switch (requestCodeType) {
            case VIDEO_IMAGE_SUCCESS: {
                String photoFilePath = (String) httpRespObject.data;
                setPhotoAll(photoFilePath);
            }
            break;

            case VIDEO_IMAGE_FAILED: {
                // 暂时不用处理
            }
            break;


            case FEE_SUCCESS: {
//                change2HasBuyView();

                // 2019/5/20 Hardy 需求更改
                // https://www.qoogifts.com.cn/zentaopms2/www/index.php?m=bug&f=view&bugID=18459
                getVideo();
            }
            break;

            case FEE_FAILED: {
                if (isNoCreditsError(httpRespObject.errno)) {
                    // 打开买点界面，关闭当前 Act
                    openBuyCredits();
                } else if (!TextUtils.isEmpty(httpRespObject.errno) &&
                        RequestErrorCodeCommon.COMMON_LOCAL_ERROR_CODE_TIMEOUT.contains(httpRespObject.errno)) {
                    // 网络出错
                    change2NotNetView(ERROR_NET_VIDEO_TIP);

                    // 判断网络出错类型
                    mRetryType = RetryType.FEE;
                } else {
                    // 一般错误
                    change2ErrorView(httpRespObject.errMsg);
                }
            }
            break;

            case DOWNLOAD_VIDEO_SUCCESS: {
                videoStart(getVideoFilePath());
            }
            break;

            case DOWNLOAD_VIDEO_FAILED: {
                change2NotNetView(ERROR_NET_VIDEO_TIP);

                // 判断网络出错类型
                mRetryType = RetryType.DOWNLOADING;
            }
            break;

            default:
                break;
        }
    }

    /**
     * 获取视频封面照片
     */
    @Override
    public void OnGetVideoPhoto(LiveChatClientListener.LiveChatErrType errType, String errno, String errmsg, String userId, String inviteId, String videoId, LCRequestJniLiveChat.VideoPhotoType type, String filePath, ArrayList<LCMessageItem> msgList) {
        if (!isCurMessageItem(videoId, inviteId)) {
            return;
        }

        super.OnGetVideoPhoto(errType, errno, errmsg, userId, inviteId, videoId, type, filePath, msgList);
        Log.i(TAG, "------------------OnGetVideoPhoto-------------------OnGetVideoPhoto");

        boolean isSuccess;
        Message message = Message.obtain();
        if (errType == LiveChatClientListener.LiveChatErrType.Success) {
            message.what = RequestCodeType.VIDEO_IMAGE_SUCCESS.ordinal();
            isSuccess = true;
        } else {
            message.what = RequestCodeType.VIDEO_IMAGE_FAILED.ordinal();
            isSuccess = false;
        }
        HttpRespObject httpRespObject = new HttpRespObject(isSuccess, 0, errmsg, filePath);
        httpRespObject.errno = errno;

        message.obj = httpRespObject;

        sendUiMessage(message);
    }

    /**
     * 扣费并获取微视频文件URL
     */
    @Override
    public void OnVideoFee(boolean success, String errno, String errmsg, LCMessageItem item) {
        if (!isCurMessageItem(item)) {
            return;
        }

        super.OnVideoFee(success, errno, errmsg, item);
        Log.i(TAG, "------------------OnVideoFee-------------------OnVideoFee");

        HttpRespObject httpRespObject = new HttpRespObject(success, 0, errmsg, item);
        httpRespObject.errno = errno;

        Message message = Message.obtain();
        message.obj = httpRespObject;
        message.what = success ? RequestCodeType.FEE_SUCCESS.ordinal() : RequestCodeType.FEE_FAILED.ordinal();
        sendUiMessage(message);
    }

    /**
     * 视频文件，开始下载
     */
    @Override
    public void OnStartGetVideo(String userId, String videoId, String inviteId, String videoPath, ArrayList<LCMessageItem> msgList) {
        if (!isCurMessageItem(videoId, inviteId)) {
            return;
        }

        super.OnStartGetVideo(userId, videoId, inviteId, videoPath, msgList);
        Log.i(TAG, "------------------OnStartGetVideo-------------------OnStartGetVideo");
    }

    /**
     * 视频文件，下载完成，
     * 成功：待播放界面
     * 失败：统一显示网络出错界面，等用户手动点击按钮重试
     */
    @Override
    public void OnGetVideo(LiveChatClientListener.LiveChatErrType errType, String userId, String videoId, String inviteId, String videoPath, ArrayList<LCMessageItem> msgList) {
        if (!isCurMessageItem(videoId, inviteId)) {
            return;
        }

        super.OnGetVideo(errType, userId, videoId, inviteId, videoPath, msgList);
        Log.i(TAG, "------------------OnGetVideo-------------------OnGetVideo");

        boolean isSuccess;
        Message message = Message.obtain();
        if (errType == LiveChatClientListener.LiveChatErrType.Success) {
            message.what = RequestCodeType.DOWNLOAD_VIDEO_SUCCESS.ordinal();
            isSuccess = true;
        } else {
            message.what = RequestCodeType.DOWNLOAD_VIDEO_FAILED.ordinal();
            isSuccess = false;
        }
        HttpRespObject httpRespObject = new HttpRespObject(isSuccess, 0, "", videoPath);
        message.obj = httpRespObject;
        sendUiMessage(message);
    }


    //=======================   视频播放器的生命周期控制    ===============================================
//    private boolean pressedHome;
//    private HomeKeyWatcher mHomeKeyWatcher;
//
//    @Override
//    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
//        super.onViewCreated(view, savedInstanceState);
//        mHomeKeyWatcher = new HomeKeyWatcher(getActivity());
//        mHomeKeyWatcher.setOnHomePressedListener(new HomeKeyWatcher.OnHomePressedListener() {
//            @Override
//            public void onHomePressed() {
//                pressedHome = true;
//            }
//        });
//        pressedHome = false;
////        mHomeKeyWatcher.startWatch();
//    }

//    @Override
//    public void onStart() {
//        mHomeKeyWatcher.startWatch();
//        pressedHome = false;
//        super.onStart();
//        NiceVideoPlayerManager.instance().resumeNiceVideoPlayer();
//    }

//    @Override
//    public void onStop() {
//        // 在OnStop中是release还是suspend播放器，需要看是不是因为按了Home键
//        if (pressedHome) {
//            NiceVideoPlayerManager.instance().suspendNiceVideoPlayer();
//        } else {
//            NiceVideoPlayerManager.instance().releaseNiceVideoPlayer();
//        }
//        super.onStop();
//        mHomeKeyWatcher.stopWatch();
//    }

    @Override
    public void onPause() {
        super.onPause();
        NiceVideoPlayerManager.instance().suspendNiceVideoPlayer();
    }

    @Override
    public void onResume() {
        super.onResume();
        NiceVideoPlayerManager.instance().resumeNiceVideoPlayer();
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        NiceVideoPlayerManager.instance().releaseNiceVideoPlayer();
    }
    //=======================   视频播放器的生命周期控制    ===============================================
}
