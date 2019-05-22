package com.qpidnetwork.livemodule.liveshow.livechat;

import android.net.Uri;
import android.os.Bundle;
import android.os.Message;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
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
import com.qpidnetwork.livemodule.framework.base.BaseFragment;
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
import com.xiao.nicevideoplayer.base.HomeKeyWatcher;

import java.util.ArrayList;

/**
 * 2019/5/7 Hardy
 * 直播 LiveChat 视频详情
 */
public class LiveChatRecentWatchFragment extends BaseFragment {


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

    private String title;
    private String cover;
    private String videoUrl;

    public LiveChatRecentWatchFragment() {
        // Required empty public constructor
    }

    //=======================   视频播放器的生命周期控制    ===============================================
    private boolean pressedHome;
    private HomeKeyWatcher mHomeKeyWatcher;

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        initData();
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_live_chat_recent_watch, container, false);
        initView(view);
        return view;
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        mHomeKeyWatcher = new HomeKeyWatcher(getActivity());
        mHomeKeyWatcher.setOnHomePressedListener(new HomeKeyWatcher.OnHomePressedListener() {
            @Override
            public void onHomePressed() {
                pressedHome = true;
            }
        });
        pressedHome = false;
        mHomeKeyWatcher.startWatch();
    }

    @Override
    protected void onReUnVisible() {
        super.onReUnVisible();
        NiceVideoPlayerManager.instance().releaseNiceVideoPlayer();
        resetContentView();
    }

    @Override
    public void onStart() {
        mHomeKeyWatcher.startWatch();
        pressedHome = false;
        super.onStart();
        NiceVideoPlayerManager.instance().resumeNiceVideoPlayer();
    }

    @Override
    public void onStop() {
        // 在OnStop中是release还是suspend播放器，需要看是不是因为按了Home键
        if (pressedHome) {
            NiceVideoPlayerManager.instance().suspendNiceVideoPlayer();
        } else {
            NiceVideoPlayerManager.instance().releaseNiceVideoPlayer();
        }
        super.onStop();
        mHomeKeyWatcher.stopWatch();
    }
    //=======================   视频播放器的生命周期控制    ===============================================


    private void initData() {
        resetContentView();
    }

    private void initView(View rootView) {
        mDraweeSourceView = rootView.findViewById(R.id.fg_live_chat_video_preview_image);

        mDraweeBlurView = rootView.findViewById(R.id.fg_live_chat_video_preview_image_blur);

        mPbLoading = rootView.findViewById(R.id.fg_live_chat_video_preview_pb_loading);

        mTvErrorNormal = rootView.findViewById(R.id.fg_live_chat_video_preview_tv_error_normal);

        mLLErrorNet = rootView.findViewById(R.id.fg_live_chat_video_preview_ll_error_net);
        mTvErrorNet = rootView.findViewById(R.id.fg_live_chat_video_preview_tv_error_net);
        mBtnErrorNetRetry = rootView.findViewById(R.id.fg_live_chat_video_preview_btn_error_net_retry);



        mBtnPlayBig = rootView.findViewById(R.id.fg_live_chat_video_preview_btn_play_big);

        mLLBottomDesc = rootView.findViewById(R.id.fg_live_chat_photo_preview_ll_photo_desc);
        mTvPhotoDesc = rootView.findViewById(R.id.fg_live_chat_photo_preview_tv_photo_desc);
        mBtnPlaySmall = rootView.findViewById(R.id.fg_live_chat_video_preview_btn_play_small);
        mVideoSeekbar = rootView.findViewById(R.id.fg_live_chat_video_preview_seekBar);

        mVideoPlayer = rootView.findViewById(R.id.fg_live_chat_video_preview_player);
        // 2019/5/9 设置 controller
        mVideoControl = new LiveChatVideoPreviewControl(mContext);
        mVideoControl.setOpenNoVideoFilePathCheck(true);        // 开启是否存在本地视频文件的点击事件拦截检测
        mVideoControl.setOnPlayOperaListener(mVideoOnPlayOperaListener);
        mVideoControl.setOperaView(mVideoSeekbar, mBtnPlaySmall);
        mVideoPlayer.setController(mVideoControl);

        mBtnErrorNetRetry.setOnClickListener(this);
        mBtnPlayBig.setOnClickListener(this);

        initPhotoBlurView();
        initPhotoSourceView();
    }


    private void initPhotoBlurView() {
        // 阴影蒙层
        ImageUtil.showImageColorFilter(true, mDraweeBlurView);

        //占位图，拉伸方式
        GenericDraweeHierarchyBuilder builder = new GenericDraweeHierarchyBuilder(mContext.getResources());
        GenericDraweeHierarchy hierarchy = builder
                .setActualImageScaleType(ScalingUtils.ScaleType.FIT_XY)      // 按比例放大到屏幕最大
                .build();
        mDraweeBlurView.setHierarchy(hierarchy);
    }

    private void initPhotoSourceView() {
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

    public void setData(String title,
                        String cover,
                        String videoUrl) {

        this.title = title;
        this.cover = cover;
        this.videoUrl = videoUrl;
    }

    private void setPhotoDesc(String desc) {
        mTvPhotoDesc.setText(desc);
    }

    private void setPhotoAll(String filePath) {
        setPhotoViewUrl(mDraweeBlurView, filePath, true);
        setPhotoViewUrl(mDraweeSourceView, filePath, false);
    }


    private void setPhotoViewUrl(SimpleDraweeView simpleDraweeView,
                                 String url,
                                 boolean isBlur) {
        if (simpleDraweeView == null) {
            return;
        }

        //加载本地图片
        Uri uri = Uri.parse(url);
        DraweeController controller = null;
        if (isBlur) {   // 模糊图，高斯模糊
            ImageRequest requestBlur = ImageRequestBuilder.newBuilderWithSource(uri)
                    .setPostprocessor(new IterativeBoxBlurPostProcessor(2, 20))    //迭代次数，越大越魔化。 //模糊图半径，必须大于0，越大越模糊。
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

    private void resetContentView() {


        // 设置图片描述
        setPhotoDesc(title);
        setPhotoAll(cover);
        Log.i(TAG, "------------videoStart----------videoFilePath: " + videoUrl);
        mVideoPlayer.setUp(videoUrl, null);
        change2HasBuyView();
    }

    private void change2HasBuyView() {
        mDraweeSourceView.setVisibility(View.VISIBLE);
        mDraweeBlurView.setVisibility(View.VISIBLE);
        mLLBottomDesc.setVisibility(View.VISIBLE);
        mBtnPlayBig.setVisibility(View.VISIBLE);

        mPbLoading.setVisibility(View.GONE);
        mTvErrorNormal.setVisibility(View.GONE);
        mLLErrorNet.setVisibility(View.GONE);

        changePlayOperaEnabled(true);
    }

    private void changePlayOperaEnabled(boolean isEnabled) {
        mBtnPlaySmall.setEnabled(isEnabled);
        mVideoSeekbar.setEnabled(isEnabled);
    }

    private void change2LoadingView() {
        mDraweeSourceView.setVisibility(View.VISIBLE);
        mDraweeBlurView.setVisibility(View.VISIBLE);
        mLLBottomDesc.setVisibility(View.VISIBLE);
        mPbLoading.setVisibility(View.VISIBLE);

        mBtnPlayBig.setVisibility(View.GONE);
        mTvErrorNormal.setVisibility(View.GONE);
        mLLErrorNet.setVisibility(View.GONE);

        changePlayOperaEnabled(false);
    }

    private void change2PlayView() {
        mLLBottomDesc.setVisibility(View.VISIBLE);
        mBtnPlayBig.setVisibility(View.GONE);
        mDraweeSourceView.setVisibility(View.GONE);
        mDraweeBlurView.setVisibility(View.GONE);
        mPbLoading.setVisibility(View.GONE);
        mTvErrorNormal.setVisibility(View.GONE);
        mLLErrorNet.setVisibility(View.GONE);

        changePlayOperaEnabled(true);
    }


    private void videoStart() {

        // 2019/5/10 control 控制开始播放，
        mVideoControl.start();
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);

        int id = v.getId();
        if (id == R.id.fg_live_chat_video_preview_btn_play_big) {
            videoStart();
        }
    }

    private void clickContent2ShowOrHideView() {
        if (mLLBottomDesc.getVisibility() == View.VISIBLE) {
            mLLBottomDesc.setVisibility(View.GONE);
        } else {
            mLLBottomDesc.setVisibility(View.VISIBLE);
        }
    }

    /**
     * 播放器的播放操作回调
     */
    LiveChatVideoPreviewControl.OnPlayOperaListener mVideoOnPlayOperaListener = new LiveChatVideoPreviewControl.OnPlayOperaListener() {
        @Override
        public void onVideoPreparing() {
            change2LoadingView();
        }

        @Override
        public void onVideoStart() {
            change2PlayView();
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

            return true;
        }
    };
}
