package com.qpidnetwork.livemodule.liveshow.flowergift.store;

import android.app.Dialog;
import android.os.Bundle;
import android.os.Message;
import android.support.v4.content.ContextCompat;
import android.support.v7.widget.LinearLayoutManager;
import android.text.Html;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseRecyclerViewFragment;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetDeliveryListCallback;
import com.qpidnetwork.livemodule.httprequest.item.LSDeliveryItem;
import com.qpidnetwork.livemodule.httprequest.item.LSFlowerGiftBaseInfoItem;
import com.qpidnetwork.livemodule.liveshow.anchor.AnchorProfileActivity;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.view.SpaceItemDecoration;
import com.qpidnetwork.qnbridgemodule.util.DisplayUtil;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static android.view.View.GONE;

/**
 * @author Jagger 2019-10-14
 */
public class DeliveryListFragment extends BaseRecyclerViewFragment implements OnDeliveryItemEventListener {
    //请求返回
    private static final int REQ_LIST_CALLBACK = 1;

    //控件
    private DeliveryListAdapter mAdapter;

    //变量
    private List<LSDeliveryItem> mData = new ArrayList<>();
    private onDeliveryEmptyEventListener mOnDeliveryEmptyEventListener;

    /**
     * 无数据事件回调
     */
    public interface onDeliveryEmptyEventListener{
        void onEmptyBtnClicked();
    }


    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = super.onCreateView(inflater, container, savedInstanceState);
        TAG = DeliveryListFragment.class.getSimpleName();
        Log.d(TAG, "onCreateView");
        return view;
    }

    public void setOnEmptyEventListener(onDeliveryEmptyEventListener listener){
        this.mOnDeliveryEmptyEventListener = listener;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);

        LinearLayoutManager manager = new LinearLayoutManager(getActivity(), LinearLayoutManager.VERTICAL, false);
        refreshRecyclerView.getRecyclerView().setLayoutManager(manager);
        mAdapter = new DeliveryListAdapter(getContext());
        mAdapter.setOnDeliveryItemEventListener(this);
        refreshRecyclerView.setAdapter(mAdapter);
        refreshRecyclerView.getRecyclerView().addItemDecoration(new SpaceItemDecoration(0, getActivity().getResources().getDimensionPixelSize(R.dimen.my_cart_item_space_size)));

        //不需要“更多”
        refreshRecyclerView.setEnableLoadMore(false);

        //空页背景色
        llEmpty.setBackgroundColor(ContextCompat.getColor(mContext, R.color.white));
        llErrorContainer.setBackgroundColor(ContextCompat.getColor(mContext, R.color.white));
    }

    @Override
    protected void onReVisible() {
        super.onReVisible();
        //刷新数据
        showLoadingProcess();
        refreshByData(false);
    }

    @Override
    public void onEmptyGuideClicked() {
        super.onEmptyGuideClicked();
        // 无东西，去Shopping
        if(mOnDeliveryEmptyEventListener != null){
            mOnDeliveryEmptyEventListener.onEmptyBtnClicked();
        }
    }

    @Override
    protected void onDefaultErrorRetryClick() {
        super.onDefaultErrorRetryClick();
        showLoadingProcess();
        refreshByData(false);
    }

    @Override
    public void onPullDownToRefresh() {
        super.onPullDownToRefresh();
        refreshByData(false);
    }

    @Override
    public void onPullUpToRefresh() {
        super.onPullUpToRefresh();
        refreshByData(true);
    }

    private void refreshByData(final boolean isMore) {

        if (!isMore) {
            hideNodataPage();
            hideErrorPage();
        }

        // 订单数据
        LiveRequestOperator.getInstance().GetDeliveryList(new OnGetDeliveryListCallback() {
            @Override
            public void onGetDeliveryList(boolean isSuccess, int errCode, String errMsg, LSDeliveryItem[] DeliveryList) {
                //回调界面
                HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, DeliveryList);
                Message msg = Message.obtain();
                msg.what = REQ_LIST_CALLBACK;
                msg.obj = response;
                sendUiMessage(msg);
            }
        });
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        if (getActivity() == null) {
            return;
        }

        onRefreshComplete();
        HttpRespObject response = (HttpRespObject) msg.obj;

        switch (msg.what) {
            case REQ_LIST_CALLBACK:
                //判空处理
                mData.clear();
                if (response.data != null) {
                    LSDeliveryItem[] array = (LSDeliveryItem[]) response.data;
                    mData.addAll(Arrays.asList(array));
                }

                //界面处理
                hideLoadingProcess();

                //刷新界面
                mAdapter.setData(mData);

                if (mAdapter.getItemCount() == 0) {
                    //无数据显示空页
                    showEmptyView();
                }
                break;
        }

    }

    /**
     * 显示无数据页
     */
    private void showEmptyView() {
        if (null != getActivity()) {
            if (null != getActivity()) {
                setDefaultEmptyIconVisible(GONE);
                setDefaultEmptyMessage(getActivity().getResources().getString(R.string.delivery_empty1));
                setDefaultEmptyMessageBottom(getActivity().getResources().getString(R.string.delivery_empty));
                setEmptyGuideButtonText(getActivity().getResources().getString(R.string.go_to_store));
            }
            showNodataPage();
        }
    }

    /**
     * 状态说明
     */
    private void showStatusDialog(){
        //Dialog
        final Dialog dialog = new Dialog(mContext,R.style.CustomTheme_SimpleDialog);
        View rootView = View.inflate(mContext, R.layout.dialog_delivery_status, null);

        TextView tv_msg = rootView.findViewById(R.id.tv_msg);
        tv_msg.setText(Html.fromHtml(getString(R.string.delivery_status_tips)));

        ImageView img_close = rootView.findViewById(R.id.img_close);
        img_close.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dialog.dismiss();
            }
        });

//        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        dialog.setContentView(rootView);
        dialog.setCancelable(true);
        dialog.setCanceledOnTouchOutside(true);
        dialog.show();

        //自定义的东西
        //放在show()之后，不然有些属性是没有效果的，比如height和width
        Window dialogWindow = dialog.getWindow();
        WindowManager.LayoutParams p = dialogWindow.getAttributes(); // 获取对话框当前的参数值
        // 设置高度和宽度
        p.height = ViewGroup.LayoutParams.WRAP_CONTENT;
        p.width = (int) (DisplayUtil.getScreenWidth(mContext) * 0.9); // 宽度设置为屏幕的0.7
        dialogWindow.setAttributes(p);
    }

    //------------------------ 列表点击事件 start ------------------------

    @Override
    public void onAnchorClicked(String anchorId) {
        AnchorProfileActivity.launchAnchorInfoActivty(mContext,
                mContext.getResources().getString(R.string.live_webview_anchor_profile_title),
                anchorId, false, AnchorProfileActivity.TagType.Album);
    }

    @Override
    public void onGiftClicked(LSFlowerGiftBaseInfoItem giftBaseInfoItem) {
        FlowersGiftDetailActivity.startAct(mContext, giftBaseInfoItem.giftId, 2);
    }

    @Override
    public void onStatusClicked() {
        showStatusDialog();
    }

    //------------------------ 列表点击事件 end ------------------------
}
