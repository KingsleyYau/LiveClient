package com.qpidnetwork.anchor.liveshow.liveroom.recommend;

import android.annotation.SuppressLint;
import android.app.Dialog;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.DialogFragment;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.support.v7.widget.LinearLayoutManager;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.httprequest.LiveRequestOperator;
import com.qpidnetwork.anchor.httprequest.OnGetAnchorListCallback;
import com.qpidnetwork.anchor.httprequest.OnRecommendFriendCallback;
import com.qpidnetwork.anchor.httprequest.item.AnchorInfoItem;
import com.qpidnetwork.anchor.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.anchor.view.RefreshRecyclerView;
import com.qpidnetwork.qnbridgemodule.view.bottomSheetDialog.CustomBottomSheetDialog;
import com.qpidnetwork.qnbridgemodule.view.textView.JustifyTextView;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * 推荐主播列表对话框
 * @author Jagger 2018-5-14
 */
public class RecommendDialogFragment extends DialogFragment implements RefreshRecyclerView.OnPullRefreshListener, RecommendAdapter.OnRecommendEventListener {
    /**
     * 推荐主播列表对话框TAG
     */
    private static final String DIALOG_RECOMMEND_TAG = "RecommendList";

    /**
     * 启动参数
     */
    private static final String PARAM_ROOM_ID = "PARAM_ROOM_ID";
    private static final String PARAM_MAN_NICKNAME = "PARAM_MAN_NICKNAME";

    /**
     * 请求返回类型
     */
    private final int REQUEST_LIST_BACK = 0;
    private final int REQUEST_RECOMMEND_BACK = 1;

    //每页刷新数据条数
    private static final int STEP_PAGE_SIZE = 50;

//    private RecommendDialogListener mListener;
    private List<AnchorInfoItem> mList = new ArrayList<>();
    private RecommendAdapter mRecommendAdapter;
    private Handler mHandlerUI;
    private String mRoomId = "" ,mManNickName = "";
    private boolean mIsShowMore = false;   //是否需要显示“更多”

    //控件
    private RefreshRecyclerView mRefreshRecyclerView;
    private TextView mTvTitle;
    private ImageView mImgClose;

    @Override
    public void onPullDownToRefresh() {
        doRequestData(false);
    }

    @Override
    public void onPullUpToRefresh() {
        doRequestData(true);
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
    public void onRecommendClicked(AnchorInfoItem infoItem) {
        //请求
        LiveRequestOperator.getInstance().RecommendFriendJoinHangout(infoItem.anchorId, mRoomId, new OnRecommendFriendCallback() {
            @Override
            public void onRecommendFriend(boolean isSuccess, int errCode, String errMsg, String recommendId) {
                HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, recommendId);
                Message msg = Message.obtain();
                msg.what = REQUEST_RECOMMEND_BACK;
                msg.obj = response;
                mHandlerUI.sendMessage(msg);
            }
        });
    }

    /**
     * 显示
     * 可扩展添加参数
     * @param fragmentManager
     */
    public static void showDialog(FragmentManager fragmentManager , String roomId, String manNickName){
        /**
         * 为了不重复显示dialog，在显示对话框之前移除正在显示的对话框。
         */
        FragmentTransaction ft = fragmentManager.beginTransaction();
        Fragment fragment = fragmentManager.findFragmentByTag(DIALOG_RECOMMEND_TAG);
        if (null != fragment) {
            ft.remove(fragment).commit();
        }

        RecommendDialogFragment dialogFragment = RecommendDialogFragment.newInstance(roomId , manNickName);
        dialogFragment.show(fragmentManager, DIALOG_RECOMMEND_TAG);

        fragmentManager.executePendingTransactions();
    }

    /**
     * 为了参数可保存状态
     * @return
     */
    private static RecommendDialogFragment newInstance(String roomId, String manNickName){
        RecommendDialogFragment instance = new RecommendDialogFragment();
        Bundle args = new Bundle();
        args.putString(PARAM_ROOM_ID , roomId);
        args.putString(PARAM_MAN_NICKNAME , manNickName);

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
            if(bundle.containsKey(PARAM_ROOM_ID)){
                mRoomId = bundle.getString(PARAM_ROOM_ID);
            }

            if(bundle.containsKey(PARAM_MAN_NICKNAME)){
                mManNickName = bundle.getString(PARAM_MAN_NICKNAME);
            }
        }

        //创建RecommendDialog核心代码
        View view = inflater.inflate(R.layout.dialog_recommend_list,container,false);
        //启用窗体的扩展特性。
        getDialog().requestWindowFeature(Window.FEATURE_NO_TITLE);
        //
        mRefreshRecyclerView = (RefreshRecyclerView)view.findViewById(R.id.rv_recommend_list);
        //容易漏掉这个
        LinearLayoutManager manager = new LinearLayoutManager(getActivity(), LinearLayoutManager.VERTICAL, false);
        mRefreshRecyclerView.getRecyclerView().setLayoutManager(manager);
        //上下拉事件
        mRefreshRecyclerView.setOnPullRefreshListener(this);
        mRefreshRecyclerView.setCanPullDown(false);
        //
        mRecommendAdapter = new RecommendAdapter(getContext() , mList);
        mRecommendAdapter.setOnRecommendEventListener(this);
        mRefreshRecyclerView.setAdapter(mRecommendAdapter);
        mTvTitle = (TextView)view.findViewById(R.id.tv_recommend_title_name);
//        mTvTitle.setText(getString(R.string.hangout_dialog_title , mManNickName));
        mTvTitle.setText(mManNickName);
        mImgClose = (ImageView)view.findViewById(R.id.img_recommend_list_close);
        mImgClose.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                dismiss();
            }
        });
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
        doRequestData(false);
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
                    case REQUEST_LIST_BACK:
                        mRefreshRecyclerView.hideLoading();

                        if(msg.obj != null) {
                            HttpRespObject httpRespObject = (HttpRespObject) msg.obj;
                            if (!httpRespObject.isSuccess) {
                                if (mRecommendAdapter.getItemCount() < 1) {
                                    doShowErrorView();
                                    return;
                                }
                            }

                            if (mRecommendAdapter.getItemCount() == 0) {
                                //无数据显示空页
                                doShowEmptyView();
                            } else {
                                mRecommendAdapter.notifyDataSetChanged();
                                //是否需要显示更多
                                if (mIsShowMore) {
                                    closePullUpRefresh(false);
                                } else {
                                    closePullUpRefresh(true);
                                }
                            }
                        }
                        break;
                    case REQUEST_RECOMMEND_BACK:
                        if(msg.obj != null && getContext() != null){
                            HttpRespObject httpRespObject = (HttpRespObject)msg.obj;
                            if(!httpRespObject.isSuccess && !TextUtils.isEmpty(httpRespObject.errMsg)){
                                //发送失败提示 且 不关闭对话框
                                Toast.makeText(getContext() , httpRespObject.errMsg , Toast.LENGTH_LONG).show();
                            }else {
                                //发送成功才关闭
                                dismiss();
                            }
                        }
                        break;
                }
            }
        };
    }

    /**
     * 请求数据
     */
    private void doRequestData(final boolean isMore){
        //正式
        mRefreshRecyclerView.showLoading();
        //起始条目
        int startIndex = 0;
        if(isMore){
            startIndex = mList.size();
        }

        //请求
        LiveRequestOperator.getInstance().GetCanRecommendFriendList(startIndex, STEP_PAGE_SIZE, new OnGetAnchorListCallback() {
            @Override
            public void onGetAnchorList(boolean isSuccess, int errCode, String errMsg, AnchorInfoItem[] anchorList) {
                //数据处理
                if(!isMore){
                    //成功才清空
                    if(isSuccess){
                        mList.clear();
                    }
                }

                if(anchorList != null){
                    mList.addAll(Arrays.asList(anchorList));
                    //是否需显示“更多”
                    if(anchorList.length < STEP_PAGE_SIZE){
                        mIsShowMore = false;
                    }else {
                        mIsShowMore = true;
                    }
                }

                HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, null);
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
        mRefreshRecyclerView.setEmptyMessage(getString(R.string.hangout_dialog_empty_tips),
                R.drawable.ic_live_recommend_list_empty ,
                getContext().getResources().getDimensionPixelSize(R.dimen.live_size_20dp),
                getContext().getResources().getDimensionPixelSize(R.dimen.live_size_20dp)
        );
        mRefreshRecyclerView.showEmptyView();
    }

    /**
     * 错误页
     */
    private void doShowErrorView(){
        mRefreshRecyclerView.setEmptyMessage(getString(R.string.hangout_dialog_error_tips),
                R.drawable.ic_live_recommend_list_empty ,
                getContext().getResources().getDimensionPixelSize(R.dimen.live_size_20dp),
                getContext().getResources().getDimensionPixelSize(R.dimen.live_size_20dp)
        );
        mRefreshRecyclerView.showEmptyView();
    }
}
