package com.qpidnetwork.livemodule.liveshow.liveroom.hangout.view;

import android.app.Dialog;
import android.graphics.Color;
import android.graphics.PointF;
import android.graphics.drawable.ColorDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.constraint.ConstraintLayout;
import android.support.design.widget.BottomSheetDialog;
import android.support.v4.app.DialogFragment;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.TextUtils;
import android.text.style.ForegroundColorSpan;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import com.facebook.drawee.backends.pipeline.Fresco;
import com.facebook.drawee.controller.AbstractDraweeController;
import com.facebook.drawee.controller.BaseControllerListener;
import com.facebook.drawee.drawable.ScalingUtils;
import com.facebook.drawee.generic.GenericDraweeHierarchy;
import com.facebook.drawee.generic.GenericDraweeHierarchyBuilder;
import com.facebook.drawee.generic.RoundingParams;
import com.facebook.drawee.interfaces.DraweeController;
import com.facebook.drawee.view.SimpleDraweeView;
import com.facebook.imagepipeline.common.ResizeOptions;
import com.facebook.imagepipeline.image.ImageInfo;
import com.facebook.imagepipeline.postprocessors.IterativeBoxBlurPostProcessor;
import com.facebook.imagepipeline.request.ImageRequest;
import com.facebook.imagepipeline.request.ImageRequestBuilder;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetHangoutFriendsCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetUserInfoCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniHangout;
import com.qpidnetwork.livemodule.httprequest.item.AnchorOnlineStatus;
import com.qpidnetwork.livemodule.httprequest.item.HangoutAnchorInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.HangoutOnlineAnchorItem;
import com.qpidnetwork.livemodule.httprequest.item.UserInfoItem;
import com.qpidnetwork.livemodule.liveshow.liveroom.hangout.adapter.HangOutDetailFriendsAdapter;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.utils.StringUtil;
import com.qpidnetwork.livemodule.view.ButtonRaised;
import com.qpidnetwork.qnbridgemodule.util.ImageTintUtil;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import io.reactivex.Observable;
import io.reactivex.ObservableEmitter;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import io.reactivex.functions.Consumer;

/**
 * HangOut主播详请弹层
 *
 * @author Jagger 2019-3-11
 */
public class HangOutDetailDialogFragment extends DialogFragment implements HangOutDetailFriendsAdapter.OnHangOutDetailFriendsItemEventListener {
    /**
     * HangOut详请对话框TAG
     */
    private static final String DIALOG_TAG = "HangOutDetail";

    /**
     * 启动参数
     */
    private static final String PARAM_ANCHOR = "PARAM_ANCHOR";

    //变量
    private HangoutOnlineAnchorItem mHangoutOnlineAnchorItem;
    private List<Disposable> mDisposableList;

    //控件
    private TextView tv_title, tv_detail, tv_name;
    private SimpleDraweeView imgAnchor;
    private SimpleDraweeView imgBg;
    private RecyclerView rvFriends;
    private HangOutDetailFriendsAdapter mAdapterFriends;
    private ButtonRaised btnStart;

    // 019/3/25 Hardy
    private View mLlLoading;
    private View mLlRetry;
    private FrameLayout mFlAnchorListRoot;

    private OnDialogClickListener mOnDialogClickListener;

    /**
     * 显示
     * 可扩展添加参数
     *
     * @param fragmentManager
     */
    public static void showDialog(FragmentManager fragmentManager, HangoutOnlineAnchorItem hangoutOnlineAnchorItem, OnDialogClickListener dialogClickListener) {
        /**
         * 为了不重复显示dialog，在显示对话框之前移除正在显示的对话框。
         */
        FragmentTransaction ft = fragmentManager.beginTransaction();
        Fragment fragment = fragmentManager.findFragmentByTag(DIALOG_TAG);
        if (null != fragment) {
            ft.remove(fragment).commit();
        }

        HangOutDetailDialogFragment dialogFragment = HangOutDetailDialogFragment.newInstance(hangoutOnlineAnchorItem);
        dialogFragment.show(fragmentManager, DIALOG_TAG);
        dialogFragment.setCancelable(true);
        dialogFragment.setOnDialogClickListener(dialogClickListener);

        fragmentManager.executePendingTransactions();
    }

    public static void dismissDialog(FragmentManager fragmentManager) {
        FragmentTransaction ft = fragmentManager.beginTransaction();
        Fragment fragment = fragmentManager.findFragmentByTag(DIALOG_TAG);
        if (null != fragment) {
            ft.remove(fragment).commit();
        }
        fragmentManager.executePendingTransactions();
    }

    /**
     * 为了参数可保存状态
     *
     * @return
     */
    private static HangOutDetailDialogFragment newInstance(HangoutOnlineAnchorItem hangoutOnlineAnchorItem) {
        HangOutDetailDialogFragment instance = new HangOutDetailDialogFragment();
        Bundle args = new Bundle();
        args.putSerializable(PARAM_ANCHOR, hangoutOnlineAnchorItem);

        instance.setArguments(args);
        return instance;
    }

    /**
     * *应用场景*：一般用于创建替代传统的 Dialog 对话框的场景，UI 简单，功能单一。
     *
     * @param savedInstanceState
     * @return
     */
    @NonNull
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        //创建RecommendDialog核心代码
        View view = inflater.inflate(R.layout.view_live_popupwindow_hangout_detail, container, false);
        //启用窗体的扩展特性。
        getDialog().requestWindowFeature(Window.FEATURE_NO_TITLE);
        //对话框内部的背景设为透明
        getDialog().getWindow().setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));

        //小标题
        tv_title = view.findViewById(R.id.tv_title);

        //描述
        tv_detail = view.findViewById(R.id.tv_detail);

        //头像
        imgAnchor = view.findViewById(R.id.img_anchor);

        //名
        tv_name = view.findViewById(R.id.tv_name);

        //毛玻璃
        imgBg = view.findViewById(R.id.img_bg);

        //好友
        rvFriends = view.findViewById(R.id.rv_friends);
        LinearLayoutManager manager = new LinearLayoutManager(getContext(), LinearLayoutManager.HORIZONTAL, false);
        mAdapterFriends = new HangOutDetailFriendsAdapter(getContext());
        mAdapterFriends.setOnEventListener(this);
        rvFriends.setLayoutManager(manager);
        rvFriends.setAdapter(mAdapterFriends);

        //start
        btnStart = view.findViewById(R.id.btn_start);

        // 好友列表
        mFlAnchorListRoot = view.findViewById(R.id.fl_friends);
        mLlLoading = view.findViewById(R.id.view_live_pop_window_hangout_detail_ll_loading);
        mLlRetry = view.findViewById(R.id.view_live_pop_window_hangout_detail_ll_errorRetry);
        mLlRetry.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showLoadingView();

                if (mHangoutOnlineAnchorItem != null) {
                    loadAnchorListData(mHangoutOnlineAnchorItem.anchorId);
                }
            }
        });

        // 2019/4/11 Hardy 改变图标颜色为白色
        ImageView mIvRetry = view.findViewById(R.id.view_live_pop_window_hangout_detail_iv_errorRetry);
        ImageTintUtil.setImageViewColor(mIvRetry, R.color.white);

        // 默认展示 loading 数据的界面
        showLoadingView();

        return view;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        initData();
        //根据数据刷新界面
        if (!refreshViewWithData(mHangoutOnlineAnchorItem)) {
            //数据不足，刷新失败，需要更新数据
            doGetAnchorInfo(mHangoutOnlineAnchorItem.anchorId, new Consumer<HttpRespObject>() {
                @Override
                public void accept(HttpRespObject httpRespObject) throws Exception {
                    if (httpRespObject.isSuccess) {
                        UserInfoItem userItem = (UserInfoItem) httpRespObject.data;
                        if (mHangoutOnlineAnchorItem != null && userItem != null) {
                            mHangoutOnlineAnchorItem.nickName = userItem.nickName;
                            mHangoutOnlineAnchorItem.avatarImg = userItem.photoUrl;
                            if (userItem.anchorInfo != null) {
                                mHangoutOnlineAnchorItem.coverImg = userItem.anchorInfo.roomPhotoUrl;
                            }
                            mHangoutOnlineAnchorItem.onlineStatus = userItem.isOnline ? AnchorOnlineStatus.Online : AnchorOnlineStatus.Offline;
                            refreshViewWithData(mHangoutOnlineAnchorItem);
                        }
                    }
                }
            });
        }
    }

    /**
     * 初始化数据及业务相关
     */
    private void initData() {

        Bundle bundle = getArguments();
        if (bundle != null) {
            if (bundle.containsKey(PARAM_ANCHOR)) {
                mHangoutOnlineAnchorItem = (HangoutOnlineAnchorItem) bundle.getSerializable(PARAM_ANCHOR);
            }
        }

        mDisposableList = new ArrayList<Disposable>();
    }

    /**
     * 根据数据刷新界面
     *
     * @param item
     * @return 是否刷新成功，需要同步数据
     */
    private boolean refreshViewWithData(HangoutOnlineAnchorItem item) {
        boolean needRefreshData = false;
        if (item != null) {

            if (!TextUtils.isEmpty(item.nickName)) {
                //小标题
                String titleStr = getResources().getString(R.string.hand_out_detail_title, item.nickName);
                SpannableString spanText = new SpannableString(titleStr);
                spanText.setSpan(new ForegroundColorSpan(getResources().getColor(R.color.live_ho_orange_light)), titleStr.indexOf(item.nickName), titleStr.indexOf(item.nickName) + item.nickName.length(), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
                tv_title.setText(spanText);

                //描述
                //主播昵称超过12个字符时从中奖截断，前后显示3个字母
                String anchorName = StringUtil.truncateName(item.nickName);
                String desStr = getString(R.string.hand_out_detail_des, anchorName, anchorName, anchorName);
                tv_detail.setText(desStr);

                //名
                tv_name.setText(getResources().getString(R.string.hand_out_detail_name, item.nickName));
            } else {
                needRefreshData = true;
            }

            if (!TextUtils.isEmpty(item.avatarImg)) {
                //头像
                //压缩、裁剪图片
                int bgSize = getContext().getResources().getDimensionPixelSize(R.dimen.live_size_60dp);  //DisplayUtil.getScreenWidth(mContext);

                //对齐方式(中上对齐)
                PointF focusPoint = new PointF();
                focusPoint.x = 0.5f;
                focusPoint.y = 0f;

                //占位图，拉伸方式
                GenericDraweeHierarchyBuilder builder = new GenericDraweeHierarchyBuilder(getContext().getResources());
                GenericDraweeHierarchy hierarchy = builder
                        .setFadeDuration(300)
                        .setPlaceholderImage(R.drawable.ic_default_photo_woman)    //占位图
                        .setPlaceholderImageScaleType(ScalingUtils.ScaleType.FIT_XY)    //占位图拉伸
                        .setActualImageFocusPoint(focusPoint)
                        .setActualImageScaleType(ScalingUtils.ScaleType.FOCUS_CROP)     //图片拉伸（配合上面的focusPoint）
                        .build();
                imgAnchor.setHierarchy(hierarchy);

                //下载
                Uri imageUri = Uri.parse(item.avatarImg);
                ImageRequest request = ImageRequestBuilder.newBuilderWithSource(imageUri)
                        .setResizeOptions(new ResizeOptions(bgSize, bgSize))
                        .build();
                DraweeController controller = Fresco.newDraweeControllerBuilder()
                        .setImageRequest(request)
                        .setOldController(imgAnchor.getController())
                        .setControllerListener(new BaseControllerListener<ImageInfo>())
                        .build();
                imgAnchor.setController(controller);

                //圆角
                RoundingParams roundingParams = RoundingParams.fromCornersRadius(5f);
                roundingParams.setRoundAsCircle(true);
                imgAnchor.getHierarchy().setRoundingParams(roundingParams);

                //毛玻璃
                Uri uri = Uri.parse(item.avatarImg);    //主播头像。IOS如此
                ImageRequest requestBlur = ImageRequestBuilder.newBuilderWithSource(uri)
                        .setResizeOptions(new ResizeOptions(bgSize, bgSize)) //压缩、裁剪图片
                        .setPostprocessor(new IterativeBoxBlurPostProcessor(2, 20))    //迭代次数，越大越魔化。 //模糊图半径，必须大于0，越大越模糊。
                        .build();
                AbstractDraweeController controllerBlur = Fresco.newDraweeControllerBuilder()
                        .setOldController(imgBg.getController())
                        .setImageRequest(requestBlur)
                        .build();
                imgBg.setController(controllerBlur);
            } else {
                needRefreshData = true;
            }


            //取好友列表
//            doGetHangoutFriends(item.anchorId, new Consumer<HttpRespObject>() {
//                @Override
//                public void accept(HttpRespObject friendsResult) {
//                    if (friendsResult.isSuccess) {
//                        List<HangoutAnchorInfoItem> dataList = new ArrayList<HangoutAnchorInfoItem>();
//                        HangoutAnchorInfoItem[] tempArray = (HangoutAnchorInfoItem[]) friendsResult.data;
//                        if (tempArray != null) {
//                            dataList.addAll(Arrays.asList(tempArray));
//                        }
//                        mAdapterFriends.setData(dataList);
//                    }
//                }
//            });

            // 2019/3/25 Hardy
            loadAnchorListData(item.anchorId);

            //start
            btnStart.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    if (mOnDialogClickListener != null) {
                        mOnDialogClickListener.onStartHangoutClick(mHangoutOnlineAnchorItem);
                    }
                    //关闭对话框，节省内存
                    dismiss();
                }
            });
        }
        return !needRefreshData;
    }

    /**
     * *应用场景*：一般用于创建复杂内容弹窗或全屏展示效果的场景，UI 复杂，功能复杂，一般有网络请求等异步操作。
     *
     * @param savedInstanceState
     * @return
     */
    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        //Android 6.0新控件 BottomSheetDialog | 底部对话框, style解决高度不足够显示全部内容
        BottomSheetDialog dialog = new BottomSheetDialog(getContext(), R.style.HangoutBottomSheetDialog);
        return dialog;
    }

    @Override
    public void onStart() {
        super.onStart();

        //话框外部的背景设为透明
        Window window = getDialog().getWindow();
        WindowManager.LayoutParams windowParams = window.getAttributes();
        windowParams.dimAmount = 0.0f;

        window.setAttributes(windowParams);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        //rxjava回收相关，防止生命周期结束，请求一步返回导致业务错误
        if (mDisposableList != null && mDisposableList.size() > 0) {
            for (Disposable disposable : mDisposableList) {
                if (disposable != null && !disposable.isDisposed()) {
                    disposable.dispose();
                }
            }
        }
    }

    @Override
    public void onFriendClicked(HangoutAnchorInfoItem anchorInfoItem) {
        HangOutFriendsDetailDialog.showCheckMailSuccessDialog(getContext(), anchorInfoItem);
    }

    /**
     * 取好友列表
     *
     * @param anchorId
     * @param observerResult
     */
    private void doGetHangoutFriends(final String anchorId, Consumer<HttpRespObject> observerResult) {
        //rxjava
        Observable<HttpRespObject> observerable = Observable.create(new ObservableOnSubscribe<HttpRespObject>() {

            @Override
            public void subscribe(final ObservableEmitter<HttpRespObject> emitter) {
                LiveRequestOperator.getInstance().GetHangoutFriends(anchorId, new OnGetHangoutFriendsCallback() {
                    @Override
                    public void onGetHangoutFriends(boolean isSuccess, int errCode, String errMsg, HangoutAnchorInfoItem[] audienceList) {
                        HttpRespObject respose = new HttpRespObject(isSuccess, errCode, errMsg, audienceList);
                        //发射
                        emitter.onNext(respose);
                    }
                });
            }
        });

        Disposable disposable = observerable
                .observeOn(AndroidSchedulers.mainThread())    //转由主线程处理结果
                .subscribe(observerResult);
        mDisposableList.add(disposable);
    }

    /**
     * 获取主播信息
     *
     * @param anchorId
     * @param observerResult
     */
    private void doGetAnchorInfo(final String anchorId, Consumer<HttpRespObject> observerResult) {
        //rxjava
        Observable<HttpRespObject> observerable = Observable.create(new ObservableOnSubscribe<HttpRespObject>() {

            @Override
            public void subscribe(final ObservableEmitter<HttpRespObject> emitter) {
                LiveRequestOperator.getInstance().GetUserInfo(anchorId, new OnGetUserInfoCallback() {
                    @Override
                    public void onGetUserInfo(boolean isSuccess, int errCode, String errMsg, UserInfoItem userItem) {
                        HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, userItem);
                        //发射
                        emitter.onNext(response);
                    }
                });
            }
        });

        Disposable disposable = observerable
                .observeOn(AndroidSchedulers.mainThread())    //转由主线程处理结果
                .subscribe(observerResult);
        mDisposableList.add(disposable);
    }

    /**
     * 设置事件
     *
     * @param listener
     */
    public void setOnDialogClickListener(OnDialogClickListener listener) {
        mOnDialogClickListener = listener;
    }

    /**
     * 事件响应
     */
    public interface OnDialogClickListener {
        public void onStartHangoutClick(HangoutOnlineAnchorItem anchorItem);
    }

    //======================    无数据的 UI 变化  =====================================

    /**
     * 加载好友列表数据，和根据数据，展示相关的 UI
     *
     * @param anchorId
     */
    private void loadAnchorListData(String anchorId) {
        if (TextUtils.isEmpty(anchorId)) {
            return;
        }

        //取好友列表
        doGetHangoutFriends(anchorId, new Consumer<HttpRespObject>() {
            @Override
            public void accept(HttpRespObject friendsResult) {
                HangoutAnchorInfoItem[] tempArray = (HangoutAnchorInfoItem[]) friendsResult.data;
                // 返回成功，并且有主播好友，才展示列表
                if (friendsResult.isSuccess && tempArray != null && tempArray.length > 0) {
                    showAnchorListView();

                    mAdapterFriends.setData(Arrays.asList(tempArray));
                } else {
                    showRetryView();
                }
            }
        });
    }

    private void showLoadingView() {
        mLlLoading.setVisibility(View.VISIBLE);

        mLlRetry.setVisibility(View.GONE);
        rvFriends.setVisibility(View.GONE);

        setListViewLayoutParam(true);
    }

    private void showRetryView() {
        mLlRetry.setVisibility(View.VISIBLE);

        mLlLoading.setVisibility(View.GONE);
        rvFriends.setVisibility(View.GONE);

        setListViewLayoutParam(true);
    }

    private void showAnchorListView() {
        rvFriends.setVisibility(View.VISIBLE);

        mLlRetry.setVisibility(View.GONE);
        mLlLoading.setVisibility(View.GONE);

        setListViewLayoutParam(false);
    }

    private void setListViewLayoutParam(boolean isMatchParent) {
        ConstraintLayout.LayoutParams params = (ConstraintLayout.LayoutParams) mFlAnchorListRoot.getLayoutParams();
        if (isMatchParent) {
            params.width = ConstraintLayout.LayoutParams.MATCH_PARENT;
        } else {
            params.width = ConstraintLayout.LayoutParams.WRAP_CONTENT;
        }
        mFlAnchorListRoot.setLayoutParams(params);
    }
    //======================    无数据的 UI 变化  =====================================
}
