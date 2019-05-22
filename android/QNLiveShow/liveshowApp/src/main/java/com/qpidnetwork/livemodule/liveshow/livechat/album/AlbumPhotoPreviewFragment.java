package com.qpidnetwork.livemodule.liveshow.livechat.album;

import android.graphics.drawable.Animatable;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.facebook.common.util.UriUtil;
import com.facebook.drawee.backends.pipeline.Fresco;
import com.facebook.drawee.controller.BaseControllerListener;
import com.facebook.drawee.drawable.ScalingUtils;
import com.facebook.drawee.generic.GenericDraweeHierarchy;
import com.facebook.drawee.generic.GenericDraweeHierarchyBuilder;
import com.facebook.drawee.interfaces.DraweeController;
import com.facebook.drawee.view.SimpleDraweeView;
import com.facebook.imagepipeline.image.ImageInfo;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragment;
import com.qpidnetwork.livemodule.liveshow.googleanalytics.AnalyticsFragmentActivity;
import com.qpidnetwork.livemodule.view.MaterialProgressBar;
import com.qpidnetwork.qnbridgemodule.util.Log;


/**
 * 2018/12/20 Hardy
 * 查看大图的单张 Fragment
 */
//public class AlbumPhotoPreviewFragment extends BaseFragment implements ImageViewLoaderCallback {
public class AlbumPhotoPreviewFragment extends BaseFragment {

    private static final String PHOTO_URL = "photoUrl";

//    private static final int GET_PHOTO_SUCCESS = 1;
//    private static final int GET_PHOTO_FAILED = 2;

    private MaterialProgressBar progress;
    private SimpleDraweeView imageView;

    private String photoUrl = "";
//    private ImageViewLoader mDownloader;

    public static AlbumPhotoPreviewFragment getInstance(String imagePath) {
        AlbumPhotoPreviewFragment fragment = new AlbumPhotoPreviewFragment();

        Bundle bundle = new Bundle();
        bundle.putString(PHOTO_URL, imagePath);
        fragment.setArguments(bundle);

        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_album_photo_preview_live, null);

        imageView = view.findViewById(R.id.imageView);
        progress = view.findViewById(R.id.progress);

        return view;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);

        Bundle bundle = getArguments();
        if ((bundle != null) && (bundle.containsKey(PHOTO_URL))) {
            photoUrl = bundle.getString(PHOTO_URL);
        }

        if (!TextUtils.isEmpty(photoUrl)) {
//            mDownloader = new ImageViewLoader(getActivity()){
//                @Override
//                protected void onLocalImagePathLoadFinish() {
//                    super.onLocalImagePathLoadFinish();
//
//                    progress.setVisibility(View.GONE);
//                }
//            };
//            mDownloader.DisplayImage(imageView, "", photoUrl, this);


            //占位图，拉伸方式
            GenericDraweeHierarchyBuilder builder = new GenericDraweeHierarchyBuilder(mContext.getResources());
            GenericDraweeHierarchy hierarchy = builder
                    .setActualImageScaleType(ScalingUtils.ScaleType.FIT_CENTER)      // 居中显示,缩小或放大
                    .build();
            imageView.setHierarchy(hierarchy);

            //加载本地图片
            Uri uri = new Uri.Builder()
                    .scheme(UriUtil.LOCAL_FILE_SCHEME)
                    .path(photoUrl)
                    .build();

            DraweeController controller = Fresco.newDraweeControllerBuilder()
                    .setUri(uri)
                    .setOldController(imageView.getController())
                    .setControllerListener(new BaseControllerListener<ImageInfo>() {
                        @Override
                        public void onFailure(String id, Throwable throwable) {
                            super.onFailure(id, throwable);
                            Log.i("info","---------onFailure------------");
                            progress.setVisibility(View.GONE);
                        }

                        @Override
                        public void onFinalImageSet(String id, ImageInfo imageInfo, Animatable animatable) {
                            super.onFinalImageSet(id, imageInfo, animatable);
                            Log.i("info","---------onFinalImageSet------------");
                            progress.setVisibility(View.GONE);
                        }
                    }).build();

            imageView.setController(controller);

        } else {
            progress.setVisibility(View.GONE);
        }
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();

        //切换隐藏的时候，处理部分拿住的View及占用大内存的相关数据
        if (progress != null) {
            progress.setVisibility(View.GONE);
            progress = null;
        }
//        if (mDownloader != null) {
//            mDownloader.ResetImageView();
//            mDownloader = null;
//        }

        if (imageView != null) {
            if (imageView.getController() != null) {
                imageView.getController().onDetach();
            }

            imageView = null;
        }
    }

//    /**
//     * 图片放大查看，切换到下一张时需还原到为放大状态
//     */
//    public void reset() {
//        if (imageView != null) {
//            imageView.Reset();
//        }
//    }

//    @Override
//    protected void handleUiMessage(Message msg) {
//        super.handleUiMessage(msg);
//
//        if (progress != null) {
//            progress.setVisibility(View.GONE);
//        }
//
//        switch (msg.what) {
//            case GET_PHOTO_SUCCESS:
//                break;
//
//            case GET_PHOTO_FAILED:
//                break;
//
//            default:
//                break;
//        }
//    }

//    @Override
//    public void OnDisplayNewImageFinish(Bitmap bmp) {
//        sendEmptyUiMessage(GET_PHOTO_SUCCESS);
//    }
//
//    @Override
//    public void OnLoadPhotoFailed() {
//        sendEmptyUiMessage(GET_PHOTO_FAILED);
//    }

    @Override
    public void onFragmentSelected(int page) {
        // 统计
        AnalyticsFragmentActivity activity = getAnalyticsFragmentActivity();
        if (null != activity) {
            activity.onAnalyticsPageSelected(this, page);
        }
    }

    @Override
    public void onFragmentPause(int page) {
        // 统计关闭Fragment event
//		AnalyticsEvent(
//			getString(R.string.AlbumLockedPhoto_Category)
//			, getString(R.string.AlbumLockedPhoto_Action_Close)
//			, "");
    }

    private AnalyticsFragmentActivity getAnalyticsFragmentActivity() {
        AnalyticsFragmentActivity activity = null;
        if (getActivity() instanceof AnalyticsFragmentActivity) {
            activity = (AnalyticsFragmentActivity) getActivity();
        }
        return activity;
    }
}
