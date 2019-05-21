package com.qpidnetwork.livemodule.liveshow.liveroom.hangout.view;

import android.annotation.SuppressLint;
import android.app.Dialog;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.DialogFragment;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.widget.DividerItemDecoration;
import android.support.v7.widget.LinearLayoutManager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetHangoutFriendsCallback;
import com.qpidnetwork.livemodule.httprequest.item.HangoutAnchorInfoItem;
import com.qpidnetwork.livemodule.liveshow.liveroom.BaseHangOutLiveRoomActivity;
import com.qpidnetwork.livemodule.liveshow.liveroom.hangout.adapter.HangoutInviteFriendsAdapter;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.view.RefreshRecyclerView;
import com.qpidnetwork.qnbridgemodule.view.blur_500px.BlurringView;
import com.qpidnetwork.qnbridgemodule.view.bottomSheetDialog.CustomBottomSheetDialog;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Hang-out直播间打开邀请好友列表
 * @author Hunter.Mun
 * @since 2019.3.25
 */
public class HangoutInviteFriendsDialogFragment extends DialogFragment implements RefreshRecyclerView.OnPullRefreshListener, HangoutInviteFriendsAdapter.OnRecommendEventListener, SwipeRefreshLayout.OnRefreshListener{
    /**
     * 推荐主播列表对话框TAG
     */
    private static final String DIALOG_RECOMMEND_TAG = "RecommendList";

    /**
     * 启动参数
     */
    private static final String PARAM_ANCHOR_ID = "PARAM_ANCHOR_ID";
    private static final String PARAM_ANCHOR_NAME = "PARAM_ANCHOR_NAME";

    private final int STEP_REFRESH_BLURRINGVIEW = 2 * 1000;

    /**
     * 请求返回类型
     */
    private final int REQUEST_LIST_BACK = 0;


    private List<HangoutAnchorInfoItem> mList = new ArrayList<>();
    private HangoutInviteFriendsAdapter mRecommendAdapter;
    private Handler mHandlerUI;
    private String mAnchorId = "" , mAnchorName = "";

    //控件
    private RefreshRecyclerView mRefreshRecyclerView;
    private TextView mTvTitle;

    private BlurringView blurring_view_bottom;
    private SwipeRefreshLayout swipeRefreshLayoutEmpty;
    private ImageView ivEmpty;
    private TextView tvEmptyMessage;

    private LinearLayout errorView;
    private ImageView ivError;
    private TextView tv_errerReload;

    private LinearLayout pbLoading;

    //毛玻璃
    private View mBlurredViewContent;

    private OnHangoutInviteFriendsDialogClickListener mOnHangoutInviteFriendsDialogClickListener;

    @Override
    public void onPullDownToRefresh() {
        doRequestData();
    }

    @Override
    public void onPullUpToRefresh() {
        doRequestData();
    }

    /**
     * 无更多关闭下拉刷新
     */
    public void closePullUpRefresh(boolean closePullUp){
        mRefreshRecyclerView.setCanPullUp(!closePullUp);
    }

    /**
     * Adapter回调的
     * @param infoItem
     */
    @Override
    public void onRecommendClicked(HangoutAnchorInfoItem infoItem) {
        if(mOnHangoutInviteFriendsDialogClickListener != null){
            mOnHangoutInviteFriendsDialogClickListener.onInviteClick(infoItem);
        }
        dismiss();
    }

    /**
     * 显示
     * 可扩展添加参数
     * @param fragmentManager
     */
    public static void showDialog(FragmentManager fragmentManager , String roomId, String manNickName, OnHangoutInviteFriendsDialogClickListener listener){
        /**
         * 为了不重复显示dialog，在显示对话框之前移除正在显示的对话框。
         */
        FragmentTransaction ft = fragmentManager.beginTransaction();
        Fragment fragment = fragmentManager.findFragmentByTag(DIALOG_RECOMMEND_TAG);
        if (null != fragment) {
            ft.remove(fragment).commit();
        }

        HangoutInviteFriendsDialogFragment dialogFragment = HangoutInviteFriendsDialogFragment.newInstance(roomId , manNickName);
        dialogFragment.show(fragmentManager, DIALOG_RECOMMEND_TAG);
        dialogFragment.setmOnHangoutInviteFriendsDialogClickListener(listener);

        fragmentManager.executePendingTransactions();
    }

    /**
     * 为了参数可保存状态
     * @return
     */
    private static HangoutInviteFriendsDialogFragment newInstance(String anchorId, String anchorName){
        HangoutInviteFriendsDialogFragment instance = new HangoutInviteFriendsDialogFragment();
        Bundle args = new Bundle();
        args.putString(PARAM_ANCHOR_ID , anchorId);
        args.putString(PARAM_ANCHOR_NAME , anchorName);

        instance.setArguments(args);
        return instance;
    }

    /**
     * 步骤2
     * *应用场景*：一般用于创建替代传统的 Dialog 对话框的场景，UI 简单，功能单一。
     * @param savedInstanceState
     * @return
     */
    @NonNull
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        Bundle bundle = getArguments();
        if(bundle != null){
            if(bundle.containsKey(PARAM_ANCHOR_ID)){
                mAnchorId = bundle.getString(PARAM_ANCHOR_ID);
            }

            if(bundle.containsKey(PARAM_ANCHOR_NAME)){
                mAnchorName = bundle.getString(PARAM_ANCHOR_NAME);
            }
        }

        //创建RecommendDialog核心代码
        View view = inflater.inflate(R.layout.dialog_hangout_invite_friends,container,false);
        //启用窗体的扩展特性。
        getDialog().requestWindowFeature(Window.FEATURE_NO_TITLE);
        //对话框内部的背景设为透明
        getDialog().getWindow().setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
        //高斯模糊背景
        blurring_view_bottom = (BlurringView)view.findViewById(R.id.blurring_view_bottom);
        if(getActivity() != null &&  getActivity() instanceof BaseHangOutLiveRoomActivity){
            mBlurredViewContent = getActivity().findViewById(R.id.ll_msglist);
            blurring_view_bottom.setBlurredView(mBlurredViewContent);
            blurring_view_bottom.invalidate();
        }

        mRefreshRecyclerView = (RefreshRecyclerView)view.findViewById(R.id.rv_recommend_list);
        mRefreshRecyclerView.setOnPullRefreshListener(this);
        swipeRefreshLayoutEmpty = (SwipeRefreshLayout) view.findViewById(R.id.swipeRefreshLayoutEmpty);
        swipeRefreshLayoutEmpty.setOnRefreshListener(this);
        ivEmpty = (ImageView) view.findViewById(R.id.ivEmpty);
        tvEmptyMessage = (TextView) view.findViewById(R.id.tvEmptyMessage);

        errorView = (LinearLayout) view.findViewById(R.id.dialog_ho_gift_ll_errorRetry);
        ivError = (ImageView) view.findViewById(R.id.ivError);
        tv_errerReload = (TextView) view.findViewById(R.id.tv_errerReload);

        pbLoading = (LinearLayout) view.findViewById(R.id.dialog_ho_gift_ll_loading);

        //容易漏掉这个
        LinearLayoutManager manager = new LinearLayoutManager(getActivity(), LinearLayoutManager.VERTICAL, false);
        mRefreshRecyclerView.getRecyclerView().setLayoutManager(manager);

        //添加分割线
        DividerItemDecoration divider = new DividerItemDecoration(getActivity(), DividerItemDecoration.VERTICAL);
        divider.setDrawable(new ColorDrawable(getResources().getColor(R.color.common_list_divider_grey)));
        mRefreshRecyclerView.getRecyclerView().addItemDecoration(divider);
        //上下拉事件
        mRefreshRecyclerView.setOnPullRefreshListener(this);
        mRefreshRecyclerView.setCanPullDown(false);
        //
        mRecommendAdapter = new HangoutInviteFriendsAdapter(getContext() , mList);
        mRecommendAdapter.setOnRecommendEventListener(this);
        mRefreshRecyclerView.setAdapter(mRecommendAdapter);
        mTvTitle = (TextView)view.findViewById(R.id.tv_title);
        mTvTitle.setText(getResources().getString(R.string.hangout_room_friends_list_title, mAnchorName));
        //关闭上拉刷新
        closePullUpRefresh(true);

        return view;
    }

    /**
     * 步骤1
     * *应用场景*：一般用于创建复杂内容弹窗或全屏展示效果的场景，UI 复杂，功能复杂，一般有网络请求等异步操作。
     * @param savedInstanceState
     * @return
     */
    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        //Android 6.0新控件 BottomSheetDialog | 底部对话框
        CustomBottomSheetDialog dialog = new CustomBottomSheetDialog(getContext());
        //
        initData();
        return dialog;
    }

    /**
     * 步骤3
     */
    @Override
    public void onStart() {
        super.onStart();

        //话框外部的背景设为透明
        Window window = getDialog().getWindow();
        WindowManager.LayoutParams windowParams = window.getAttributes();
        windowParams.dimAmount = 0.0f;

        window.setAttributes(windowParams);

        //请求数据
        doRequestData();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }

    @SuppressLint("HandlerLeak")
    private void initData(){
        /**
         * 处理数据返回后的UI
         */
        mHandlerUI = new Handler(){
            @Override
            public void handleMessage(Message msg) {
                super.handleMessage(msg);

                //防止 not attached to Activity错误
                if(getActivity() == null){
                    return;
                }

                switch (msg.what){
                    case REQUEST_LIST_BACK: {
                        //隐藏进度条
                        pbLoading.setVisibility(View.GONE);
                        swipeRefreshLayoutEmpty.setRefreshing(false);

                        HttpRespObject httpRespObject = (HttpRespObject) msg.obj;
                        if (!httpRespObject.isSuccess) {
                            if (mRecommendAdapter.getItemCount() < 1) {
                                doShowErrorView();
                                return;
                            }
                        }else{
                            mList.clear();
                            HangoutAnchorInfoItem[] audienceList = (HangoutAnchorInfoItem[])httpRespObject.data;
                            if(audienceList != null){
                                mList.addAll(Arrays.asList(audienceList));
                            }
                            if (mRecommendAdapter.getItemCount() == 0) {
                                //无数据显示空页
                                doShowEmptyView();
                            } else {
                                hideEmptyView();
                                mRecommendAdapter.notifyDataSetChanged();
                            }
                        }
                    }break;
                }
            }
        };
    }

    /**
     * 请求数据
     */
    private void doRequestData(){
        //正式
        hideEmptyView();
        hideErrorView();
        pbLoading.setVisibility(View.VISIBLE);

        //请求
        LiveRequestOperator.getInstance().GetHangoutFriends(mAnchorId, new OnGetHangoutFriendsCallback() {
            @Override
            public void onGetHangoutFriends(boolean isSuccess, int errCode, String errMsg, HangoutAnchorInfoItem[] audienceList){
                HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, audienceList);
                Message msg = Message.obtain();
                msg.what = REQUEST_LIST_BACK;
                msg.obj = response;
                mHandlerUI.sendMessage(msg);
            }
        });
    }

    /**
     * 无数据页
     */
    private void doShowEmptyView(){
        swipeRefreshLayoutEmpty.setVisibility(View.VISIBLE);
        ivEmpty.setImageResource(R.drawable.hangout_no_broadcaster);
        tvEmptyMessage.setText(getResources().getString(R.string.live_common_no_broadcasters));
    }

    /**
     * 隐藏空页提示
     */
    private void hideEmptyView(){
        swipeRefreshLayoutEmpty.setVisibility(View.GONE);
    }

    /**
     * 错误页
     */
    private void doShowErrorView(){
        errorView.setVisibility(View.VISIBLE);
        tv_errerReload.setText(getResources().getString(R.string.live_common_taptoretry));
        errorView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                errorView.setVisibility(View.GONE);
                doRequestData();
            }
        });
    }

    /**
     * 隐藏错误页
     */
    private void hideErrorView(){
        errorView.setVisibility(View.GONE);
    }

    @Override
    public void onRefresh() {
        doRequestData();
    }

    public interface OnHangoutInviteFriendsDialogClickListener{
        public void onInviteClick(HangoutAnchorInfoItem item);
    }

    /**
     * 设置监听器
     * @param listener
     */
    public void setmOnHangoutInviteFriendsDialogClickListener(OnHangoutInviteFriendsDialogClickListener listener){
        mOnHangoutInviteFriendsDialogClickListener = listener;
    }
}
