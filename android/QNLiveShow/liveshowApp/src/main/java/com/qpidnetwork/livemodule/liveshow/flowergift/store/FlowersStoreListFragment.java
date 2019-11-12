package com.qpidnetwork.livemodule.liveshow.flowergift.store;


import android.graphics.Rect;
import android.os.Message;
import android.support.annotation.NonNull;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.View;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseRecyclerViewFragment;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetCartGiftTypeNumCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetStoreGiftListCallback;
import com.qpidnetwork.livemodule.httprequest.item.LSFlowerGiftItem;
import com.qpidnetwork.livemodule.httprequest.item.LSStoreFlowerGiftItem;
import com.qpidnetwork.livemodule.liveshow.flowergift.adapter.FlowersStoreAdapter;
import com.qpidnetwork.livemodule.liveshow.flowergift.mycart.MyCartListActivity;
import com.qpidnetwork.livemodule.liveshow.flowergift.receiver.ReceiverChooseDialog;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.qnbridgemodule.util.DisplayUtil;
import com.qpidnetwork.qnbridgemodule.util.ListUtils;
import com.qpidnetwork.qnbridgemodule.util.Log;
import com.qpidnetwork.qnbridgemodule.util.NoDoubleOnClickListener;
import com.qpidnetwork.qnbridgemodule.util.ToastUtil;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 2019/10/8 Hardy
 * 鲜花礼品
 * ——商店
 * ——主播下
 */
public class FlowersStoreListFragment extends BaseRecyclerViewFragment implements OnGetCartGiftTypeNumCallback,
        OnGetStoreGiftListCallback {

    // 鲜花礼品详情的 Act 跳转码
    public static final int REQUEST_CODE_DETAIL = 20;
    // 延时展示购物车提示气泡
    private static final int CART_TIP_BUBBLE_DELAY_TIME = 700;

    private static final int SPAN_COUNT = 2;
    private static final int GET_DATA_CART_COUNT = 10;
    private static final int GET_DATA_STORE_LIST = 11;

    private FlowersTypeNameItemView mFlNameView;
    private FlowersTypeLayout mFlTypeLayout;

    private View mCartRootView;
    private TextView mTvCartCount;
    private TextView mTvCartBubbleTip;

    private GridLayoutManager gridLayoutManager;
    private FlowersStoreAdapter mAdapter;
    private RecyclerViewTopSmoothScroller mTopScroller;

    // dialog
    private ReceiverChooseDialog mReceiverDialog;

    // 分组标题数据
    private Map<String, FlowersTypeBean> mTypeMap;
    private List<FlowersTypeBean> mTypeList;
    // 主播 id
    private String anchorId;

    private boolean isOnResume;

    // 间距
    private int LIST_SPACING_20DP;
    private int LIST_SPACING_10DP;
    private int LIST_SPACING_5DP;
    private int LIST_SPACING_2DP;   // 卡片的阴影边距

    public FlowersStoreListFragment() {
        // Required empty public constructor
    }

    //=================  interface  =====================
    private OnFlowersStoreMainListener mOnFlowersStoreListener;

    public void setOnFlowersStoreMainListener(OnFlowersStoreMainListener mOnFlowersStoreListener) {
        this.mOnFlowersStoreListener = mOnFlowersStoreListener;
    }

    public interface OnFlowersStoreMainListener {
        void onCountChange(int num);

        void onGiftAdd(LSFlowerGiftItem item, View startView);
    }
    //=================  interface  =====================

    public void setAnchorId(String anchorId) {
        this.anchorId = anchorId;
    }

    @Override
    protected int getRecyclerViewRootViewId() {
        return R.layout.fragment_flowers_store_list;
    }

    @Override
    protected void initView(View view) {
        super.initView(view);

        // 初始化相关数据
        mTypeMap = new HashMap<>();
        mTypeList = new ArrayList<>();
        LIST_SPACING_20DP = DisplayUtil.dip2px(mContext, 20);
        LIST_SPACING_10DP = LIST_SPACING_20DP / 2;
        LIST_SPACING_5DP = LIST_SPACING_10DP / 2;
        LIST_SPACING_2DP = DisplayUtil.dip2px(mContext, 2);
        // 分类标题
        mFlNameView = view.findViewById(R.id.flowers_type_root_view);
        mFlNameView.setOnClickListener(typeViewOnClickListener);
        mFlNameView.showLineBottom(true);
        mFlNameView.showIcon(true);
        mFlNameView.setIcon(R.drawable.ic_flowers_type);
        // 分类选择弹窗
        mFlTypeLayout = view.findViewById(R.id.layout_flowers_type_root);
        mFlTypeLayout.setOnFlowersTypeSelectListener(onFlowersTypeSelectListener);
        // 购物车
        mCartRootView = view.findViewById(R.id.fg_flowers_store_list_cart_root);
        mTvCartCount = view.findViewById(R.id.fg_flowers_store_list_cart_tv_count);
        mTvCartBubbleTip = view.findViewById(R.id.fg_flowers_store_list_cart_tv_bubble_tip);
        mCartRootView.setVisibility(View.GONE);
        // 购物车按钮的点击事件
        view.findViewById(R.id.fg_flowers_store_list_ll_cart).setOnClickListener(this);

        // 设置无数据界面的初始化
        setDefaultEmptyIconVisible(View.GONE);
        setEmptyGuideButtonText(null);
        setEmptyPullRefreshable(false);     // 空页不能下拉刷新
        setDefaultEmptyMessage("No gifts&flowers are added yet.");

        // list view
        refreshRecyclerView.setEnableLoadMore(false);
        refreshRecyclerView.setEnableRefresh(true);
        refreshRecyclerView.getRecyclerView().setFocusable(false);
        // layoutManager
        gridLayoutManager = new GridLayoutManager(mContext, SPAN_COUNT);
        refreshRecyclerView.getRecyclerView().setLayoutManager(gridLayoutManager);
        // itemDecoration
        refreshRecyclerView.getRecyclerView().addItemDecoration(new RecyclerView.ItemDecoration() {
            @Override
            public void getItemOffsets(@NonNull Rect outRect, @NonNull View view,
                                       @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
                super.getItemOffsets(outRect, view, parent, state);

                handlerItemOffsets(outRect, view, parent, state);
            }
        });
        // scroll
        mTopScroller = new RecyclerViewTopSmoothScroller(mContext, refreshRecyclerView.getRecyclerView());
        // listener
        refreshRecyclerView.getRecyclerView().addOnScrollListener(new RecyclerView.OnScrollListener() {
            @Override
            public void onScrolled(@NonNull RecyclerView recyclerView, int dx, int dy) {
                super.onScrolled(recyclerView, dx, dy);

                int firstPos = gridLayoutManager.findFirstVisibleItemPosition();
                LSFlowerGiftItem giftItem = mAdapter.getItemBean(firstPos);
                if (giftItem != null && mTypeMap.get(giftItem.typeId) != null) {
                    FlowersTypeBean mapTypeBean = mTypeMap.get(giftItem.typeId);
                    FlowersTypeBean curTypeBean = (FlowersTypeBean) mFlNameView.getTag();
                    // 设置分类标题，2 者不相同，才设置
                    if (curTypeBean != null && !curTypeBean.typeId.equals(giftItem.typeId)) {
                        setTypeNameViewData(mapTypeBean);
                    }
                }
            }
        });
        // adapter
        mAdapter = new FlowersStoreAdapter(mContext);
        mAdapter.setOnFlowersStoreListener(onItemClickListener);
        refreshRecyclerView.setAdapter(mAdapter);
    }

    @Override
    protected void initData() {
        super.initData();

        showTypeTitle(false);
        showLoadingProcess();
        loadStoreList();
    }

    @Override
    public void onResume() {
        super.onResume();

        isOnResume = true;
        loadCartCount();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();

        if (mReceiverDialog != null) {
            mReceiverDialog.dismiss();
        }
    }

    @Override
    public void onPullDownToRefresh() {
        super.onPullDownToRefresh();

        loadStoreList();
        loadCartCount();
    }

    @Override
    protected void onDefaultErrorRetryClick() {
        super.onDefaultErrorRetryClick();

        showLoadingProcess();
        loadStoreList();
        loadCartCount();
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);

        int id = v.getId();
        if (id == R.id.fg_flowers_store_list_ll_cart) {
            MyCartListActivity.startAct(mContext);
        }
    }

    /**
     * 快速双击拦截
     */
    NoDoubleOnClickListener typeViewOnClickListener = new NoDoubleOnClickListener() {
        @Override
        public void onNoDoubleClick(View v) {
            if (mFlTypeLayout.isAnimRunning()) {
                return;
            }

            if (mFlTypeLayout.isViewShow()) {
                mFlTypeLayout.hide();
            } else {
                FlowersTypeBean bean = (FlowersTypeBean) mFlNameView.getTag();
                String typeId = bean != null ? bean.typeId : "";
                mFlTypeLayout.show(typeId);
            }
        }
    };

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);

        HttpRespObject response = (HttpRespObject) msg.obj;
        switch (msg.what) {
            case GET_DATA_CART_COUNT: {
                int count = (int) response.data;
                if (isStoreView()) {
                    // 一般商店
                    if (count > 0) {
                        mCartRootView.setVisibility(View.VISIBLE);
                        setCartCount(count);
                        showCartTipBubble();
                    } else {
                        mCartRootView.setVisibility(View.GONE);
                    }
                } else {
                    // 主播内，回调外层，更新数量
                    if (mOnFlowersStoreListener != null) {
                        mOnFlowersStoreListener.onCountChange(count);
                    }
                }
            }
            break;

            case GET_DATA_STORE_LIST: {
                // 隐藏 loading
                hideLoadingProcess();

                List<LSStoreFlowerGiftItem> list = (List<LSStoreFlowerGiftItem>) response.data;
                // 过滤组装数据
                List<LSFlowerGiftItem> itemList = filterItemList(list);

                if (response.isSuccess) {
                    if (ListUtils.isList(itemList)) {
                        showTypeTitle(true);
                        hideNodataPage();
                        hideErrorPage();

                        // 设置列表数据
                        mAdapter.setTypeMap(mTypeMap);
                        mAdapter.setData(itemList);
                        // 设置分类弹窗数据
                        mFlTypeLayout.setData(mTypeList);
                        // 设置分类标题数据
                        if (ListUtils.isList(mTypeList)) {
                            FlowersTypeBean typeBean = mTypeList.get(0);
                            setTypeNameViewData(typeBean);
                        }
                    } else if (mAdapter.getItemCount() == 0) {
                        mAdapter.setData(null);

                        showTypeTitle(false);
                        // 展示空数据页
                        showNodataPage();
                    }
                } else {
                    if (mAdapter.getItemCount() == 0) {
                        showTypeTitle(false);
                        // 展示出错页
                        showErrorPage();
                    } else {
                        showTypeTitle(true);
                        // 出错，暂时提示
                        ToastUtil.showToast(getContext(), response.errMsg);
                    }
                }

                // 恢复初始化状态
                onRefreshComplete();
            }
            break;

            default:
                break;
        }
    }

    //==========================    处理 item 的间距 ==========================================
    private void handlerItemOffsets(@NonNull Rect outRect, @NonNull View view,
                                    @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {

        Log.i("info", "-----------------------handlerItemOffsets--------------------");

        int position = parent.getChildAdapterPosition(view);
        LSFlowerGiftItem giftItem = mAdapter.getItemBean(position);
        if (giftItem != null && giftItem.giftViewType == LSFlowerGiftItem.FlowerGiftViewType.VIEW_ITEM_NORMAL) {
            int groupPos = giftItem.groupPos;
            int groupCount = giftItem.groupCount;

            // item 的左、右边距
            if (isGridLeft(groupPos)) {
                outRect.left = LIST_SPACING_20DP - LIST_SPACING_2DP;
                outRect.right = LIST_SPACING_5DP - LIST_SPACING_2DP;
            } else {
                outRect.left = LIST_SPACING_5DP - LIST_SPACING_2DP;
                outRect.right = LIST_SPACING_20DP - LIST_SPACING_2DP;
            }

            if (isTopPos(position)) {
                outRect.top = LIST_SPACING_10DP - LIST_SPACING_2DP;
            }
            if (!isTopPos(groupPos)) {
                outRect.top = LIST_SPACING_10DP - LIST_SPACING_2DP * 2; // 上下相邻的 2 个 item 的边距
            }

            boolean isBottomGroupPos = isBottomPos(groupPos, groupCount);
            if (isBottomGroupPos) {
                outRect.bottom = LIST_SPACING_20DP - LIST_SPACING_2DP;
            }
            // 如果是商店礼品，则最后一行间距高一些，避免购物车按钮挡住 item 视图
            if (isStoreView() && mCartRootView.getVisibility() == View.VISIBLE
                    && isBottomGroupPos
                    && position + SPAN_COUNT >= mAdapter.getItemCount()) {
                outRect.bottom = outRect.bottom + LIST_SPACING_20DP * 3;
            }
        }
    }

    /**
     * 是否在 grid 列表的左边 item
     */
    private boolean isGridLeft(int groupPos) {
        return groupPos % SPAN_COUNT == 0;
    }

    /**
     * 是否是列表或分组列表的顶部
     */
    private boolean isTopPos(int curPos) {
        return curPos < SPAN_COUNT;
    }

    /**
     * 是否在分组列表数据里的底部
     */
    private boolean isBottomPos(int curPos, int totalCount) {
        boolean isBottom = false;

        boolean isDoubleItems = totalCount % SPAN_COUNT == 0;

        if (isDoubleItems) {
            // 双数
            if (curPos >= totalCount - SPAN_COUNT && curPos < totalCount) {
                isBottom = true;
            }
        } else {
            // 单数
            if (curPos + 1 == totalCount) {
                isBottom = true;
            }
        }

        return isBottom;
    }
    //==========================    处理 item 的间距 ==========================================


    //=============================  listener    ==============================================

    FlowersStoreAdapter.OnFlowersStoreListener onItemClickListener = new FlowersStoreAdapter.OnFlowersStoreListener() {
        @Override
        public void onFlowersAddClick(int pos) {
            LSFlowerGiftItem item = mAdapter.getItemBean(pos);
            if (item != null) {
                if (isStoreView()) {
                    // 无对应主播，商店列表
                    String giftId = item.giftId;
                    showReceiversSelectDialog(giftId);
                } else {
                    FlowersStoreAdapter.FlowersStoreViewHolder viewHolder = (FlowersStoreAdapter.FlowersStoreViewHolder) refreshRecyclerView.getRecyclerView().findViewHolderForLayoutPosition(pos);
                    if (viewHolder != null) {
                        // 对应主播下的添加鲜花
                        if (mOnFlowersStoreListener != null) {
                            mOnFlowersStoreListener.onGiftAdd(item, viewHolder.mIvBg);
                        }
                    }
                }
            }
        }

        @Override
        public void onFlowersDetailClick(int pos) {
            LSFlowerGiftItem item = mAdapter.getItemBean(pos);
            if (item != null) {
                FlowersGiftDetailActivity.startAct(mContext, anchorId, item.giftId, REQUEST_CODE_DETAIL);
            }
        }
    };

    /**
     * 分类选中回调监听
     */
    FlowersTypeLayout.OnFlowersTypeSelectListener onFlowersTypeSelectListener = new FlowersTypeLayout.OnFlowersTypeSelectListener() {
        @Override
        public void onTypeSelect(FlowersTypeBean flowersTypeBean) {
            if (flowersTypeBean != null) {
                // 列表滚动到指定位置
                int size = mAdapter.getItemCount();
                int listPos = 0;
                for (int i = 0; i < size; i++) {
                    LSFlowerGiftItem item = mAdapter.getItemBean(i);
                    if (item != null && flowersTypeBean.typeId.equals(item.typeId)) {
                        listPos = i;
                        break;
                    }
                }

                mTopScroller.scroll2PositionAnim(listPos);

                // 这里不手动设置，跟随滚动监听，即在最后分类不可滚动时，分类列表标题会显示倒数第 2 个分类标题
//                setTypeNameViewData(flowersTypeBean);
            }
        }
    };
    //=============================  listener    ==============================================

    /**
     * 组装数据
     */
    private List<LSFlowerGiftItem> filterItemList(List<LSStoreFlowerGiftItem> groupList) {
        List<LSFlowerGiftItem> list = null;

        if (ListUtils.isList(groupList)) {
            list = new ArrayList<>();

            // 清除已有数据
            mTypeList.clear();
            mTypeMap.clear();

            int groupSize = groupList.size();
            for (int i = 0; i < groupSize; i++) {
                LSStoreFlowerGiftItem storeFlowerGiftItem = groupList.get(i);

                // 组标题数据
                FlowersTypeBean typeBean = new FlowersTypeBean();
                typeBean.typeId = storeFlowerGiftItem.typeId;
                typeBean.typeName = storeFlowerGiftItem.typeName;
                typeBean.hasGreetingCard = storeFlowerGiftItem.isHasGreeting;
                typeBean.hasSelect = false;
                mTypeList.add(typeBean);
                mTypeMap.put(typeBean.typeId, typeBean);

                // 组装列表 item 数据，第一个不需要分组标题 view
                if (i > 0) {
                    // 分组标题
                    LSFlowerGiftItem item = new LSFlowerGiftItem();
                    item.giftViewType = LSFlowerGiftItem.FlowerGiftViewType.VIEW_ITEM_GROUP_TITLE;
                    item.giftName = storeFlowerGiftItem.typeName;
                    item.typeId = storeFlowerGiftItem.typeId;
                    list.add(item);
                }

                list.addAll(Arrays.asList(storeFlowerGiftItem.giftList));
            }
        }

        return list;
    }

    /**
     * 设置购物车数量
     * 显示当前购物车内主播数，最大为 99，若超过依然显示为 99
     */
    private void setCartCount(int num) {
        String numStr;
        if (num < 0) {
            num = 0;
        }
        if (num > 99) {
            numStr = "99";
        } else {
            numStr = num + "";
        }
        mTvCartCount.setText(numStr);
    }

    /**
     * 展示购物车提示冒泡
     */
    private void showCartTipBubble() {
        if (isOnResume && isStoreView()) {
            isOnResume = false;

            // 延时播放
            mUiHandler.postDelayed(new Runnable() {
                @Override
                public void run() {
                    FlowersGiftAnimUtils.showCartTipBubble(mTvCartBubbleTip, mUiHandler);
                }
            }, CART_TIP_BUBBLE_DELAY_TIME);
        }
    }

    /**
     * 是否为鲜花商店的 view
     */
    private boolean isStoreView() {
        return TextUtils.isEmpty(anchorId);
    }

    /**
     * 展示标题分类
     */
    private void showTypeTitle(boolean isShow) {
        mFlNameView.setVisibility(isShow ? View.VISIBLE : View.GONE);
    }

    /**
     * 设置分类标题名字
     */
    private void setTypeNameViewData(FlowersTypeBean typeBean) {
        if (typeBean != null) {
            // 设置分类名字
            mFlNameView.setName(typeBean.typeName);
            mFlNameView.showFreeCard(typeBean.hasGreetingCard);
            mFlNameView.setTag(typeBean);
        }
    }

    //==============================    load data   ========================================

    /**
     * 购物车主播数
     */
    public void loadCartCount() {
        LiveRequestOperator.getInstance().GetCartGiftTypeNum(anchorId, this);
    }

    @Override
    public void onGetCartGiftTypeNum(boolean isSuccess, int errCode, String errMsg, int num) {
        HttpRespObject httpRespObject = new HttpRespObject(isSuccess, errCode, errMsg, num);
        Message message = Message.obtain();
        message.obj = httpRespObject;
        message.what = GET_DATA_CART_COUNT;
        mUiHandler.sendMessage(message);
    }

    /**
     * 鲜花礼品列表
     */
    private void loadStoreList() {
        LiveRequestOperator.getInstance().GetStoreGiftList(anchorId, this);
    }

    @Override
    public void onGetStoreGiftList(boolean isSuccess, int errCode, String errMsg, LSStoreFlowerGiftItem[] flowerGiftList) {
        List<LSStoreFlowerGiftItem> newList = filterGroupList(flowerGiftList);
        HttpRespObject httpRespObject = new HttpRespObject(isSuccess, errCode, errMsg, newList);

        Message message = Message.obtain();
        message.obj = httpRespObject;
        message.what = GET_DATA_STORE_LIST;
        mUiHandler.sendMessage(message);
    }

    /**
     * 过滤指定分类下，无鲜花的分组
     */
    private List<LSStoreFlowerGiftItem> filterGroupList(LSStoreFlowerGiftItem[] flowerGiftList) {
        List<LSStoreFlowerGiftItem> newList = null;

        if (flowerGiftList != null) {
            newList = new ArrayList<>();

            for (LSStoreFlowerGiftItem item : flowerGiftList) {
                if (item != null && item.giftList != null && item.giftList.length > 0) {
                    // 标记礼物 item 在组内的 pos
                    int itemLen = item.giftList.length;
                    for (int i = 0; i < itemLen; i++) {
                        LSFlowerGiftItem subItem = item.giftList[i];
                        subItem.groupPos = i;
                        subItem.groupCount = itemLen;
                    }

                    newList.add(item);
                }
            }
        }

        return newList;
    }

    /**
     * 收货人选择
     */
    private void showReceiversSelectDialog(String giftId) {
        if (mReceiverDialog == null) {
            mReceiverDialog = new ReceiverChooseDialog(getActivity());
            mReceiverDialog.setOnReceiversProcessResultListener(new ReceiverChooseDialog.OnReceiversProcessResultListener() {
                @Override
                public void onGetReceiverListError() {

                }

                @Override
                public void onAddGiftCartCallback(boolean isSuccess, int errCode, String errMsg, String anchorId) {

                }
            });
        }

        mReceiverDialog.bindGiftId(giftId);
        mReceiverDialog.show();
    }


}
