package com.qpidnetwork.livemodule.liveshow.flowergift.mycart;

import android.os.Bundle;
import android.os.Message;
import android.support.v4.content.ContextCompat;
import android.support.v7.widget.LinearLayoutManager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseRecyclerViewFragment;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnCheckOutCartGiftCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetCartGiftListCallback;
import com.qpidnetwork.livemodule.httprequest.OnRequestCallback;
import com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType;
import com.qpidnetwork.livemodule.httprequest.item.LSCheckoutItem;
import com.qpidnetwork.livemodule.httprequest.item.LSFlowerGiftBaseInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.LSMyCartItem;
import com.qpidnetwork.livemodule.httprequest.item.LSRecipientAnchorGiftItem;
import com.qpidnetwork.livemodule.liveshow.anchor.AnchorProfileActivity;
import com.qpidnetwork.livemodule.liveshow.flowergift.FlowersMainActivity;
import com.qpidnetwork.livemodule.liveshow.flowergift.checkout.CheckOutActivity;
import com.qpidnetwork.livemodule.liveshow.flowergift.store.FlowersAnchorShopListActivity;
import com.qpidnetwork.livemodule.liveshow.flowergift.store.FlowersGiftDetailActivity;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.view.SpaceItemDecoration;
import com.qpidnetwork.qnbridgemodule.util.Log;
import com.qpidnetwork.qnbridgemodule.util.ToastUtil;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static android.view.View.GONE;
import static com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType.HTTP_LCC_ERR_NO_EXIST_CART;

/**
 * 购物车（MyCart）列表
 *
 * @author Jagger 2019-10-8
 */
public class MyCartListFragment extends BaseRecyclerViewFragment implements OnCartEventListener {
    //请求返回
    private static final int REQ_LIST_CALLBACK = 1;
    private static final int REQ_CHANGE_GIFT_SUM_SUCCESS_CALLBACK = 2;
    private static final int REQ_CHANGE_GIFT_SUM_FAIL_CALLBACK = 3;
    private static final int REQ_DEL_GIFT_CALLBACK = 4;
    private static final int REQ_CHECKOUT_CALLBACK = 5;
    //每页刷新数据条数
    private static final int STEP_PAGE_SIZE = 100;

    /**
     * 事件监听
     */
    public interface onCartEventListener{
        void onGroupsSumRefresh(int sum);
    }

    //控件
    private MyCartAdapter mAdapter;

    //变量
    private List<LSMyCartItem> mData = new ArrayList<>();
    private MyCartGiftsSynManager mMyCartGiftsSynManager;
    private onCartEventListener mOnCartEventListener;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = super.onCreateView(inflater, container, savedInstanceState);
        TAG = MyCartListFragment.class.getSimpleName();
        Log.d(TAG, "onCreateView");
        return view;
    }

    /**
     * 事件监听
     * @param listener
     */
    public void setOnCartEventListener(onCartEventListener listener){
        mOnCartEventListener = listener;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        mMyCartGiftsSynManager = new MyCartGiftsSynManager();

        LinearLayoutManager manager = new LinearLayoutManager(getActivity(), LinearLayoutManager.VERTICAL, false);
        refreshRecyclerView.getRecyclerView().setLayoutManager(manager);

        mAdapter = new MyCartAdapter(getContext(), mMyCartGiftsSynManager);
        mAdapter.setOnEventListener(this);
        refreshRecyclerView.setAdapter(mAdapter);
        refreshRecyclerView.getRecyclerView().addItemDecoration(new SpaceItemDecoration(0, getActivity().getResources().getDimensionPixelSize(R.dimen.my_cart_item_space_size)));

        //不需要“更多”
        refreshRecyclerView.setEnableLoadMore(false);

        //空页背景色
        llEmpty.setBackgroundColor(ContextCompat.getColor(mContext, R.color.white));
        llErrorContainer.setBackgroundColor(ContextCompat.getColor(mContext, R.color.white));
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        mMyCartGiftsSynManager.destroy();
        mOnCartEventListener = null;
    }

    @Override
    public void onResume() {
        super.onResume();
        //刷新数据
        showLoadingProcess();
        refreshByData(false);
    }

    @Override
    public void onEmptyGuideClicked() {
        super.onEmptyGuideClicked();
        // 无东西，去Shopping
        FlowersMainActivity.startAct(mContext);
        if (getActivity() != null) {
            getActivity().finish();
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

    /**
     * 刷新购物车数据
     *
     * @param isMore
     */
    private void refreshByData(final boolean isMore) {

        if (!isMore) {
            hideNodataPage();
            hideErrorPage();
        }

        //购物车数据
        LiveRequestOperator.getInstance().GetCartGiftList(0, STEP_PAGE_SIZE, new OnGetCartGiftListCallback() {
            @Override
            public void onGetCartGiftList(boolean isSuccess, int errCode, String errMsg, int total, LSMyCartItem[] cartList) {
                //回调界面
                HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, cartList);
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
                //界面处理
                hideLoadingProcess();

                //判空处理
                mData.clear();
                if (response.data != null) {
                    LSMyCartItem[] array = (LSMyCartItem[]) response.data;
                    mData.addAll(Arrays.asList(array));
                }
                //刷新界面
                mAdapter.setData(mData);

                if(response.isSuccess){
                    if(mOnCartEventListener != null){
                        mOnCartEventListener.onGroupsSumRefresh( mData == null? 0:mData.size());
                    }

                    if (mAdapter.getItemCount() == 0) {
                        //无数据显示空页
                        showEmptyView();
                    }
                }else{
                    if(mOnCartEventListener != null){
                        mOnCartEventListener.onGroupsSumRefresh(0);
                    }
                    showErrorPage();
                }

                break;
            case REQ_DEL_GIFT_CALLBACK:
                if(response.isSuccess) {
                    refreshByData(false);
                }else {
                    ToastUtil.showToast(mContext, response.errMsg);
                }
                break;
            case REQ_CHECKOUT_CALLBACK:
                if(response.isSuccess){
                    if (response.data != null) {
                        LSMyCartItem cartItem = (LSMyCartItem) response.data;
                        CheckOutActivity.lanchAct(mContext, cartItem.anchorItem.anchorId, cartItem.anchorItem.anchorNickName, cartItem.anchorItem.anchorAvatarImg);
                    }
                }else{
                    ToastUtil.showToast(mContext, response.errMsg);
                }
                break;
            case REQ_CHANGE_GIFT_SUM_SUCCESS_CALLBACK:
                mMyCartGiftsSynManager.confirmChange();
                break;
            case REQ_CHANGE_GIFT_SUM_FAIL_CALLBACK:
                if(HttpLccErrType.values()[response.errCode] == HTTP_LCC_ERR_NO_EXIST_CART){
                    ToastUtil.showToast(mContext, response.errMsg);
                    refreshByData(false);
                }

                mMyCartGiftsSynManager.refuseChange();
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
                setDefaultEmptyMessage(getActivity().getResources().getString(R.string.my_cart_empty));
                setEmptyGuideButtonText(getActivity().getResources().getString(R.string.my_cart_empty_btn));
            }
            showNodataPage();
        }
    }

    //------------------------------- 列表点击事件 Start --------------------------------

    @Override
    public void onChangeGiftSum(LSRecipientAnchorGiftItem anchor, LSFlowerGiftBaseInfoItem giftBaseInfoItem, int oldSum, int newSum) {
        mMyCartGiftsSynManager.summitChange(anchor.anchorId, giftBaseInfoItem.giftId, oldSum, newSum);

        LiveRequestOperator.getInstance().ChangeCartGiftNumber(anchor.anchorId, giftBaseInfoItem.giftId, newSum, new OnRequestCallback() {
            @Override
            public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, null);
                Message msg = Message.obtain();
                msg.what = isSuccess ? REQ_CHANGE_GIFT_SUM_SUCCESS_CALLBACK : REQ_CHANGE_GIFT_SUM_FAIL_CALLBACK;
                msg.obj = response;
                sendUiMessage(msg);
            }
        });
    }

    @Override
    public void onDelGift(LSRecipientAnchorGiftItem anchor, LSFlowerGiftBaseInfoItem giftBaseInfoItem) {
        LiveRequestOperator.getInstance().RemoveCartGift(anchor.anchorId, giftBaseInfoItem.giftId, new OnRequestCallback() {
            @Override
            public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, null);
                Message msg = Message.obtain();
                msg.what = REQ_DEL_GIFT_CALLBACK;
                msg.obj = response;
                sendUiMessage(msg);
            }
        });
    }

    @Override
    public void onCheckout(final LSMyCartItem cartItem) {
        LiveRequestOperator.getInstance().CheckOutCartGift(cartItem.anchorItem.anchorId, new OnCheckOutCartGiftCallback() {
            @Override
            public void onCheckOutCartGift(boolean isSuccess, int errCode, String errMsg, LSCheckoutItem checkoutItem) {
                HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, cartItem);
                Message msg = Message.obtain();
                msg.what = REQ_CHECKOUT_CALLBACK;
                msg.obj = response;
                sendUiMessage(msg);
            }
        });
    }

    @Override
    public void onContinueShop(LSMyCartItem cartItem) {
        if (cartItem != null && cartItem.anchorItem != null) {
            FlowersAnchorShopListActivity.startAct(mContext, cartItem.anchorItem.anchorId,
                    cartItem.anchorItem.anchorNickName, cartItem.anchorItem.anchorAvatarImg);
        }
    }

    @Override
    public void onAnchorClicked(LSRecipientAnchorGiftItem anchor) {
        AnchorProfileActivity.launchAnchorInfoActivty(mContext,
                mContext.getResources().getString(R.string.live_webview_anchor_profile_title),
                anchor.anchorId, false, AnchorProfileActivity.TagType.Album);
    }

    @Override
    public void onGiftClicked(LSFlowerGiftBaseInfoItem giftBaseInfoItem) {
        FlowersGiftDetailActivity.startAct(mContext, giftBaseInfoItem.giftId, 2);
    }

    //------------------------------- 列表点击事件 end --------------------------------
}
