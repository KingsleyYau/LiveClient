package com.qpidnetwork.livemodule.liveshow.livechat;


import android.app.Activity;
import android.os.Bundle;
import android.support.annotation.LayoutRes;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragment;
import com.qpidnetwork.livemodule.livechat.LCMessageItem;
import com.qpidnetwork.livemodule.livechat.LiveChatManager;
import com.qpidnetwork.livemodule.livechat.LiveChatManagerPhotoListener;
import com.qpidnetwork.livemodule.livechat.LiveChatManagerVideoListener;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener;
import com.qpidnetwork.livemodule.livechathttprequest.LCRequestJniLiveChat;
import com.qpidnetwork.livemodule.liveshow.manager.URL2ActivityManager;
import com.qpidnetwork.livemodule.liveshow.urlhandle.AppUrlHandler;
import com.qpidnetwork.livemodule.view.MaterialDialogAlert;
import com.qpidnetwork.qnbridgemodule.anim.TopBottomAnimHandler;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.util.ArrayList;

/**
 * 2019/5/8 Hardy
 * LiveChat 查看私密照和视频的基类 Fragment
 */
public abstract class LiveChatBasePreviewFragment extends BaseFragment implements LiveChatManagerPhotoListener, LiveChatManagerVideoListener {

    // 网络出错的提示
    protected static final String ERROR_NET_PHOTO_TIP = "Trouble loading full-sized image.";
    protected static final String ERROR_NET_VIDEO_TIP = "Trouble loading full video.";
    protected static final String TAG = "info";

    protected LCMessageItem messageItem;
    protected String mAnchorId;

    /**
     * 网络出错重试的类型
     */
    protected enum RetryType {
        FEE,
        DOWNLOADING
    }

    protected RetryType mRetryType = RetryType.FEE;


    public LiveChatBasePreviewFragment() {
        // Required empty public constructor
    }

    public void setMessageItem(LCMessageItem messageItem) {
        this.messageItem = messageItem;
    }


    public void setAnchorId(String mAnchorId) {
        this.mAnchorId = mAnchorId;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View view = inflater.inflate(getLayoutResId(), container, false);
        initView(view);
        registerListener();
        return view;
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        initData();
    }

    @Override
    protected void onReVisible() {
        super.onReVisible();
        // 2019/5/7 切换到可见状态
        onFragmentVisible();
    }

    @Override
    protected void onReUnVisible() {
        super.onReUnVisible();
        // 2019/5/7 切换到不可见状态
        onFragmentUnVisible();
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        unregisterListener();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();

        // TODO: 2019/5/8

    }


    private void registerListener() {
        LiveChatManager.getInstance().RegisterPhotoListener(this);
        LiveChatManager.getInstance().RegisterVideoListener(this);
    }

    private void unregisterListener() {
        LiveChatManager.getInstance().UnregisterPhotoListener(this);
        LiveChatManager.getInstance().UnregisterVideoListener(this);
    }

    protected boolean isCurMessageItem(LCMessageItem item) {
        if (item != null && messageItem != null && item.msgId == messageItem.msgId) {
            return true;
        }
        return false;
    }

    protected boolean isCurMessageItem(String womanId) {
        if (!TextUtils.isEmpty(womanId) && messageItem != null &&
                (womanId.equals(messageItem.fromId) ||
                        womanId.equals(messageItem.toId))) {
            return true;
        }

        return false;
    }

    /**
     * 是否余额不足的错误
     *
     * @param errno
     * @return
     */
    protected boolean isNoCreditsError(String errno) {
        if (LiveChatManager.getInstance().isNoCredits(errno)) {
            //no money failed
            return true;
        }

        return false;
    }

    /**
     * 打开买点界面
     */
    protected void openBuyCredits() {
        //2019/3/18  打开买点页面
        //edit by Jagger 2018-9-21 使用URL方式跳转
        String urlAddCredit = URL2ActivityManager.createAddCreditUrl("", "B30", "");
        new AppUrlHandler(mContext).urlHandle(urlAddCredit);

        // 关闭界面
        ((Activity) mContext).finish();
    }


    /**
     * 付费时的二次确认弹窗
     * <p>
     * https://www.qoogifts.com.cn/zentaopms2/www/index.php?m=bug&f=view&bugID=18451
     * 不需要二次确认弹窗
     *
     * @param title
     */
    protected void showBuyTipDialog(String title) {
        MaterialDialogAlert materialDialogAlert = new MaterialDialogAlert(mContext);
        materialDialogAlert.setMessage(title);
        materialDialogAlert.addButton(materialDialogAlert.createButton(mContext.getString(R.string.common_btn_cancel), null));
        materialDialogAlert.addButton(materialDialogAlert.createButton(mContext.getString(R.string.common_btn_ok), new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                click2Fee();
            }
        }));

        materialDialogAlert.show();
    }

    //=============================     照片回调    ==========================================
    @Override
    public void OnSendPhoto(LiveChatClientListener.LiveChatErrType errType, String errno, String errmsg, LCMessageItem item) {
        Log.i(TAG, "------------------OnSendPhoto-------------------");
        if (!isCurMessageItem(item)) {
            return;
        }
    }

    @Override
    public void OnPhotoFee(boolean success, String errno, String errmsg, LCMessageItem item) {
        Log.i(TAG, "------------------OnPhotoFee-------------------" + this.toString());
        if (!isCurMessageItem(item)) {
            Log.i(TAG, "------------------OnPhotoFee-------------------return----" + this.toString());
            return;
        }
    }

    @Override
    public void OnGetPhoto(boolean isSuccess, String errno, String errmsg, LCMessageItem item) {
        Log.i(TAG, "------------------OnGetPhoto-------------------" + this.toString());
        if (!isCurMessageItem(item)) {
            Log.i(TAG, "------------------OnGetPhoto-------------------return----" + this.toString());
            return;
        }
    }

    @Override
    public void OnRecvPhoto(LCMessageItem item) {
        Log.i(TAG, "------------------OnRecvPhoto-------------------");
        if (!isCurMessageItem(item)) {
            return;
        }
    }


    //=============================     视频回调    ==========================================
    @Override
    public void OnGetVideoPhoto(LiveChatClientListener.LiveChatErrType errType, String errno, String errmsg, String userId, String inviteId, String videoId, LCRequestJniLiveChat.VideoPhotoType type, String filePath, ArrayList<LCMessageItem> msgList) {
        Log.i(TAG, "------------------OnGetVideoPhoto-------------------");
        if (!isCurMessageItem(userId)) {
            return;
        }
    }

    @Override
    public void OnVideoFee(boolean success, String errno, String errmsg, LCMessageItem item) {
        Log.i(TAG, "------------------OnVideoFee-------------------");
        if (!isCurMessageItem(item)) {
            return;
        }
    }

    @Override
    public void OnStartGetVideo(String userId, String videoId, String inviteId, String videoPath, ArrayList<LCMessageItem> msgList) {
        Log.i(TAG, "------------------OnStartGetVideo-------------------");
        if (!isCurMessageItem(userId)) {
            return;
        }
    }

    @Override
    public void OnGetVideo(LiveChatClientListener.LiveChatErrType errType, String userId, String videoId, String inviteId, String videoPath, ArrayList<LCMessageItem> msgList) {
        Log.i(TAG, "------------------OnGetVideo-------------------");
        if (!isCurMessageItem(userId)) {
            return;
        }
    }

    @Override
    public void OnRecvVideo(LCMessageItem item) {
        Log.i(TAG, "------------------OnRecvVideo-------------------");
        if (!isCurMessageItem(item)) {
            return;
        }
    }


    /**
     * 照片：点触照片切换隐藏或显示底部文字描述
     * 视频：轻触视频区域切换隐藏/显示描述及播放条
     */
    protected void clickContent2ShowOrHideView() {
        if (getTopBottomAnimView().getVisibility() == View.VISIBLE) {
            TopBottomAnimHandler.showView(getTopBottomAnimView(), false);
        } else {
            TopBottomAnimHandler.showView(getTopBottomAnimView(), true);
        }
    }

    protected void resetTopBottomViewLocation() {
        TopBottomAnimHandler.resetViewLocation(getTopBottomAnimView());
    }
    //===============================   abstract    =================================

    protected abstract @LayoutRes
    int getLayoutResId();

    protected abstract void initView(View rootView);

    protected abstract void initData();

    protected abstract void onFragmentVisible();

    protected abstract void onFragmentUnVisible();
    //===================   View 状态改变   ==========================

    /**
     * 未付费
     */
    protected abstract void change2UnBuyView();

    /**
     * 加载中
     */
    protected abstract void change2LoadingView();

    /**
     * 已付费
     * 照片：原图预览
     * 视频：显示开始的三角按钮，等用户手动点击
     */
    protected abstract void change2HasBuyView();

    /**
     * 网络错误
     *
     * @param tip 提示
     */
    protected abstract void change2NotNetView(String tip);

    /**
     * 通用错误
     *
     * @param tip 提示
     */
    protected abstract void change2ErrorView(String tip);

    /**
     * 网络出错，点击重试
     * 区分付费中或者下载中的断网出错处理
     */
    protected abstract void tag2Retry();

    /**
     * 点击付费
     */
    protected abstract void click2Fee();

    /**
     * 获取私密照或视频封面照
     */
    protected abstract void getPhoto(LCMessageItem item);

    /**
     * 获取需要上下切换动画的 View
     *
     * @return
     */
    protected abstract View getTopBottomAnimView();

    /**
     * 初始数据状态下，重置默认状态的 View
     * <p>
     * 照片：未付费、先显示 loading 再显示原图
     * <p>
     * 视频：未付费、显示播放按钮
     */
    protected abstract void resetContentView();
    //===================   View 状态改变   ==========================
}
