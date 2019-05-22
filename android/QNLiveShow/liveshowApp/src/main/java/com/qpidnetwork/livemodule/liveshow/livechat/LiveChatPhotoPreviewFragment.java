package com.qpidnetwork.livemodule.liveshow.livechat;


import android.net.Uri;
import android.os.Build;
import android.os.Message;
import android.text.TextUtils;
import android.view.View;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.facebook.common.util.UriUtil;
import com.facebook.drawee.backends.pipeline.Fresco;
import com.facebook.drawee.drawable.ScalingUtils;
import com.facebook.drawee.generic.GenericDraweeHierarchy;
import com.facebook.drawee.generic.GenericDraweeHierarchyBuilder;
import com.facebook.drawee.interfaces.DraweeController;
import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.livechat.LCMessageItem;
import com.qpidnetwork.livemodule.livechat.LCPhotoInfoItem;
import com.qpidnetwork.livemodule.livechat.LCPhotoItem;
import com.qpidnetwork.livemodule.livechat.LCUserItem;
import com.qpidnetwork.livemodule.livechat.LiveChatManager;
import com.qpidnetwork.livemodule.livechathttprequest.LCRequestJniLiveChat;
import com.qpidnetwork.livemodule.liveshow.livechat.album.ZoomableDraweeView;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.view.ButtonRaised;
import com.qpidnetwork.qnbridgemodule.bean.RequestErrorCodeCommon;
import com.qpidnetwork.qnbridgemodule.util.FileUtil;
import com.qpidnetwork.qnbridgemodule.util.Log;

/**
 * 2019/5/7 Hardy
 * 直播 LiveChat 私密照的大图预览
 */
public class LiveChatPhotoPreviewFragment extends LiveChatBasePreviewFragment {

    // 原图
    private ZoomableDraweeView mDraweeSourceView;
    // 模糊图
    private SimpleDraweeView mDraweeBlurView;
    // 加载中
    private ProgressBar mPbLoading;
    // 一般错误
    private TextView mTvErrorNormal;
    // 照片描述
    private TextView mTvPhotoDesc;
    // 网络错误
    private View mLLErrorNet;
    private TextView mTvErrorNet;
    private ButtonRaised mBtnErrorNetRetry;
    // 未付费
    private View mLLUnBuy;
    private TextView mTvUnBuyTip;
    private ButtonRaised mBtnUnBuy;

    /**
     * 接口请求错误类型
     */
    private enum RequestCodeType {
        BLUR_IMAGE_SUCCESS,
        BLUR_IMAGE_FAILED,

        SOURCE_IMAGE_SUCCESS,
        SOURCE_IMAGE_FAILED,

        FEE_SUCCESS,
        FEE_FAILED
    }

    public LiveChatPhotoPreviewFragment() {
        // Required empty public constructor
    }

    @Override
    protected int getLayoutResId() {
        return R.layout.fragment_live_chat_photo_preview;
    }

    @Override
    protected void initView(View rootView) {
        mDraweeSourceView = rootView.findViewById(R.id.fg_live_chat_photo_preview_image_source);

        mDraweeBlurView = rootView.findViewById(R.id.fg_live_chat_photo_preview_image_blur);

        mPbLoading = rootView.findViewById(R.id.fg_live_chat_photo_preview_pb_loading);

        mTvErrorNormal = rootView.findViewById(R.id.fg_live_chat_photo_preview_tv_error_normal);

        mTvPhotoDesc = rootView.findViewById(R.id.fg_live_chat_photo_preview_tv_photo_desc);

        mLLErrorNet = rootView.findViewById(R.id.fg_live_chat_photo_preview_ll_error_net);
        mTvErrorNet = rootView.findViewById(R.id.fg_live_chat_photo_preview_tv_error_net);
        mBtnErrorNetRetry = rootView.findViewById(R.id.fg_live_chat_photo_preview_btn_error_net_retry);

        mLLUnBuy = rootView.findViewById(R.id.fg_live_chat_photo_preview_ll_un_buy);
        mTvUnBuyTip = rootView.findViewById(R.id.fg_live_chat_photo_preview_tv_un_buy_tip);
        mBtnUnBuy = rootView.findViewById(R.id.fg_live_chat_photo_preview_btn_un_buy);

        mBtnErrorNetRetry.setOnClickListener(this);
        mBtnUnBuy.setOnClickListener(this);

        // 原图放大缩小的点击事件，自定义特殊处理
        mDraweeSourceView.setOnClickListener(new ZoomableDraweeView.OnClickListener() {
            @Override
            public void onClick() {
                // 2019/5/8 点触照片切换隐藏或显示底部文字描述
                clickContent2ShowOrHideView();
            }
        });

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
        resetContentView();
    }

    @Override
    protected void change2UnBuyView() {
        // 先恢复状态
        resetTopBottomViewLocation();

        mLLUnBuy.setVisibility(View.VISIBLE);
        mTvPhotoDesc.setVisibility(View.VISIBLE);
        mDraweeBlurView.setVisibility(View.VISIBLE);

        mDraweeSourceView.setVisibility(View.GONE);
        mPbLoading.setVisibility(View.GONE);
        mTvErrorNormal.setVisibility(View.GONE);
        mLLErrorNet.setVisibility(View.GONE);
    }

    @Override
    protected void change2LoadingView() {
        // 先恢复状态
        resetTopBottomViewLocation();

        mDraweeBlurView.setVisibility(View.VISIBLE);
        mPbLoading.setVisibility(View.VISIBLE);

        mLLUnBuy.setVisibility(View.GONE);
        mTvPhotoDesc.setVisibility(View.GONE);
        mDraweeSourceView.setVisibility(View.GONE);
        mTvErrorNormal.setVisibility(View.GONE);
        mLLErrorNet.setVisibility(View.GONE);
    }

    @Override
    protected void change2HasBuyView() {
        // 先恢复状态
        resetTopBottomViewLocation();

        mDraweeSourceView.setVisibility(View.VISIBLE);
        mTvPhotoDesc.setVisibility(View.VISIBLE);

        mDraweeBlurView.setVisibility(View.GONE);
        mPbLoading.setVisibility(View.GONE);
        mLLUnBuy.setVisibility(View.GONE);
        mTvErrorNormal.setVisibility(View.GONE);
        mLLErrorNet.setVisibility(View.GONE);
    }

    @Override
    protected void change2NotNetView(String tip) {
        // 先恢复状态
        resetTopBottomViewLocation();

        mDraweeBlurView.setVisibility(View.VISIBLE);
        mLLErrorNet.setVisibility(View.VISIBLE);
        mTvErrorNet.setText(tip);

        mDraweeSourceView.setVisibility(View.GONE);
        mTvPhotoDesc.setVisibility(View.GONE);
        mPbLoading.setVisibility(View.GONE);
        mLLUnBuy.setVisibility(View.GONE);
        mTvErrorNormal.setVisibility(View.GONE);
    }

    @Override
    protected void change2ErrorView(String tip) {
        // 先恢复状态
        resetTopBottomViewLocation();

        mDraweeBlurView.setVisibility(View.VISIBLE);
        mTvErrorNormal.setVisibility(View.VISIBLE);
        mTvErrorNormal.setText(tip);

        mLLErrorNet.setVisibility(View.GONE);
        mDraweeSourceView.setVisibility(View.GONE);
        mTvPhotoDesc.setVisibility(View.GONE);
        mPbLoading.setVisibility(View.GONE);
        mLLUnBuy.setVisibility(View.GONE);
    }

    @Override
    protected void tag2Retry() {
        // 2019/5/8 重试，区分付费中或者下载原图中的断网出错处理

        // 先显示 loading view
        change2LoadingView();

        if (mRetryType == RetryType.FEE) {
            click2Fee();
        } else {
            // 去下载高清原图
            getPhoto(messageItem);
        }
    }

    @Override
    protected void click2Fee() {
        change2LoadingView();
        // 2019/5/8 去付费
        LiveChatManager.getInstance().PhotoFee(messageItem);
    }

    @Override
    protected void getPhoto(LCMessageItem item) {
        LiveChatManager.getInstance().GetPhoto(mAnchorId, item.msgId, LCRequestJniLiveChat.PhotoSizeType.Original);
    }

    @Override
    protected View getTopBottomAnimView() {
        return mTvPhotoDesc;
    }

    @Override
    protected void clickContent2ShowOrHideView() {
        super.clickContent2ShowOrHideView();
    }

    @Override
    protected void resetContentView() {
        if (messageItem == null || messageItem.getPhotoItem() == null) {
            return;
        }

        LCPhotoItem photoItem = messageItem.getPhotoItem();
        boolean isCharge = photoItem.charge;

        // 设置图片描述
        setPhotoDesc(photoItem.photoDesc);

        // 图片恢复初始缩放状态
        mDraweeSourceView.reset();

        if (isCharge) {     // 已付费
            // 1.先出 loading
            change2LoadingView();

            LCPhotoInfoItem photoInfoItem = photoItem.mClearSrcPhotoInfo;
            if (photoInfoItem != null && FileUtil.isFileExists(photoInfoItem.photoPath)) {      // 已存在高清图
                change2HasBuyView();
                // 设置高清图
                setPhotoSourceViewUrl(photoInfoItem.photoPath);
            } else {
                // 没有，则去下载[高清图]
                getPhoto(messageItem);
            }
        } else {            // 未付费
            // 1.改变 view 样式
            change2UnBuyView();

            // 2.设置主播的 tip
            LCUserItem userItem = LiveChatManager.getInstance().GetUserWithId(mAnchorId);
            if (userItem != null) {
                setPhotoNameString(userItem.userName);
            }

            // 4.显示模糊图
            LCPhotoInfoItem photoInfoItem = photoItem.mFuzzySrcPhotoInfo;
            if (photoInfoItem != null && FileUtil.isFileExists(photoInfoItem.photoPath)) {
                // 已存在模糊图
                setPhotoBlurViewUrl(photoInfoItem.photoPath);
            } else {
                // 没有，则去下载[模糊图]
                getPhoto(messageItem);
            }
        }
    }

    private void setPhotoNameString(String womanName) {
        String val = mContext.getString(R.string.livechat_photo_name, womanName);
        mTvUnBuyTip.setText(val);
    }

    private void setPhotoDesc(String desc) {
        mTvPhotoDesc.setText(desc);

        /*
            2019/5/21    https://www.qoogifts.com.cn/zentaopms2/www/index.php?m=bug&f=view&bugID=18472
            这里不设置 view 的 gone 属性，因为切换不同状态时，需要变换 gone 和 visible 状态，还有点击图片区域也会显示、隐藏该 view
            故直接设置 background 属性为空，去掉渐变阴影即可.
        */
        if (TextUtils.isEmpty(desc)) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
                mTvPhotoDesc.setBackground(null);
            } else {
                mTvPhotoDesc.setBackgroundDrawable(null);
            }
        }
    }

    private void initPhotoSourceView() {
        //占位图，拉伸方式
        GenericDraweeHierarchyBuilder builder = new GenericDraweeHierarchyBuilder(mContext.getResources());
        GenericDraweeHierarchy hierarchy = builder
                .setActualImageScaleType(ScalingUtils.ScaleType.FIT_CENTER)      // 居中显示,缩小或放大
                .build();
        mDraweeSourceView.setHierarchy(hierarchy);
    }

    private void setPhotoSourceViewUrl(String filePath) {
        if (mDraweeSourceView == null) {
            return;
        }

        //加载本地图片
        Uri uri = new Uri.Builder()
                .scheme(UriUtil.LOCAL_FILE_SCHEME)
                .path(filePath)
                .build();

        DraweeController controller = Fresco.newDraweeControllerBuilder()
                .setUri(uri)
                .setOldController(mDraweeSourceView.getController())
                .build();

        mDraweeSourceView.setController(controller);
    }

    private void initPhotoBlurView() {
        //占位图，拉伸方式
        GenericDraweeHierarchyBuilder builder = new GenericDraweeHierarchyBuilder(mContext.getResources());
        GenericDraweeHierarchy hierarchy = builder
                .setActualImageScaleType(ScalingUtils.ScaleType.FIT_XY)      // 按比例放大到屏幕最大
                .build();
        mDraweeBlurView.setHierarchy(hierarchy);
    }

    private void setPhotoBlurViewUrl(String filePath) {
        if (mDraweeBlurView == null) {
            return;
        }

        //加载本地图片
        Uri uri = new Uri.Builder()
                .scheme(UriUtil.LOCAL_FILE_SCHEME)
                .path(filePath)
                .build();

        DraweeController controller = Fresco.newDraweeControllerBuilder()
                .setUri(uri)
                .setOldController(mDraweeBlurView.getController())
                .build();

        mDraweeBlurView.setController(controller);
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);

        int id = v.getId();

        if (id == R.id.fg_live_chat_photo_preview_btn_error_net_retry) {
            tag2Retry();
        } else if (id == R.id.fg_live_chat_photo_preview_btn_un_buy) {
//            showBuyTipDialog(mContext.getString(R.string.credits_per_photo_15));
            click2Fee();
        }
    }


    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);

        HttpRespObject httpRespObject = (HttpRespObject) msg.obj;
        LCMessageItem item = (LCMessageItem) httpRespObject.data;
        RequestCodeType requestCodeType = RequestCodeType.values()[msg.what];

        switch (requestCodeType) {
            case BLUR_IMAGE_SUCCESS: {
                LCPhotoItem photoItem = item.getPhotoItem();
                if (photoItem != null && photoItem.mFuzzySrcPhotoInfo != null) {
                    setPhotoBlurViewUrl(photoItem.mFuzzySrcPhotoInfo.photoPath);
                }
            }
            break;

            case BLUR_IMAGE_FAILED: {
                // 模糊图下载失败，暂时不用管
            }
            break;

            case SOURCE_IMAGE_SUCCESS: {
                LCPhotoItem photoItem = item.getPhotoItem();
                if (photoItem != null && photoItem.mClearSrcPhotoInfo != null) {
                    setPhotoSourceViewUrl(photoItem.mClearSrcPhotoInfo.photoPath);
                    // 改变 view
                    change2HasBuyView();
                } else {
                    // 暂时不用处理
                }
            }
            break;

            case FEE_SUCCESS: {
                change2LoadingView();
                // 去下载高清原图
                getPhoto(item);
            }
            break;

            case FEE_FAILED:
            case SOURCE_IMAGE_FAILED: {
                if (isNoCreditsError(httpRespObject.errno)) {
                    // 打开买点界面，关闭当前 Act
                    openBuyCredits();
                } else if (!TextUtils.isEmpty(httpRespObject.errno) &&
                        RequestErrorCodeCommon.COMMON_LOCAL_ERROR_CODE_TIMEOUT.contains(httpRespObject.errno)) {
                    // 网络出错
                    change2NotNetView(ERROR_NET_PHOTO_TIP);

                    // 判断网络出错类型
                    mRetryType = requestCodeType == RequestCodeType.FEE_FAILED ? RetryType.FEE : RetryType.DOWNLOADING;
                } else {
                    // 一般错误
                    change2ErrorView(httpRespObject.errMsg);
                }
            }
            break;

            default:
                break;
        }
    }


    @Override
    public void OnPhotoFee(boolean success, String errno, String errmsg, LCMessageItem item) {
        if (!isCurMessageItem(item)) {
            return;
        }

        super.OnPhotoFee(success, errno, errmsg, item);
        Log.i(TAG, "------------------OnPhotoFee-------------------OnPhotoFee");

        HttpRespObject httpRespObject = new HttpRespObject(success, 0, errmsg, item);
        httpRespObject.errno = errno;

        Message message = Message.obtain();
        message.obj = httpRespObject;
        message.what = success ? RequestCodeType.FEE_SUCCESS.ordinal() : RequestCodeType.FEE_FAILED.ordinal();
        sendUiMessage(message);
    }

    @Override
    public void OnGetPhoto(boolean isSuccess, String errno, String errmsg, LCMessageItem item) {
        if (!isCurMessageItem(item)) {
            return;
        }

        super.OnGetPhoto(isSuccess, errno, errmsg, item);
        Log.i(TAG, "------------------OnGetPhoto-------------------OnGetPhoto");

        HttpRespObject httpRespObject = new HttpRespObject(isSuccess, 0, errmsg, item);
        httpRespObject.errno = errno;

        // 判断是否为原图或模糊图
        boolean isClearImage;
        if (item.getPhotoItem() != null && item.getPhotoItem().mClearSrcPhotoInfo != null) {
            isClearImage = true;
        } else {
            isClearImage = false;
        }

        // 请求类型判断
        Message message = Message.obtain();
        message.obj = httpRespObject;
        if (isSuccess) {
            message.what = isClearImage ? RequestCodeType.SOURCE_IMAGE_SUCCESS.ordinal() : RequestCodeType.BLUR_IMAGE_SUCCESS.ordinal();
        } else {
            message.what = isClearImage ? RequestCodeType.SOURCE_IMAGE_FAILED.ordinal() : RequestCodeType.BLUR_IMAGE_FAILED.ordinal();
        }

        sendUiMessage(message);
    }

}
