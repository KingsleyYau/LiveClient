package com.qpidnetwork.livemodule.liveshow.flowergift.mycart;

import android.content.Context;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.LSMyCartItem;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseRecyclerViewAdapter;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseViewHolder;
import com.qpidnetwork.livemodule.utils.FrescoLoadUtil;
import com.qpidnetwork.livemodule.view.HeaderAndFooterRecyclerViewEx;

/**
 * 购物车列表
 * @author Jagger 2019-10-8
 */
public class MyCartAdapter extends BaseRecyclerViewAdapter<LSMyCartItem, MyCartAdapter.ViewHolderMyCart> {
    private Context mContext;
    private OnCartEventListener mOnCartEventListener;
    private MyCartGiftsSynManager mMyCartGiftsSynManager;
//    private RecyclerView.RecycledViewPool mViewPool;

    public MyCartAdapter(Context context, MyCartGiftsSynManager myCartGiftsSynManager) {
        super(context);
        mContext = context;
        mMyCartGiftsSynManager = myCartGiftsSynManager;
//        mViewPool = new RecyclerView.RecycledViewPool();
    }

    public void setOnEventListener(OnCartEventListener listener){
        mOnCartEventListener = listener;
    }

    @Override
    public int getLayoutId(int viewType) {
        return R.layout.item_mycart_list;
    }

    @Override
    public ViewHolderMyCart getViewHolder(View itemView, int viewType) {
        return new ViewHolderMyCart(itemView);
    }

    @Override
    public void initViewHolder(final ViewHolderMyCart holder) {
        //点击事件
        holder.btn_checkout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(mOnCartEventListener != null){
                    mOnCartEventListener.onCheckout(getItemBean(getPosition(holder)));
                }
            }
        });
        holder.btn_continue_shop.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(mOnCartEventListener != null){
                    mOnCartEventListener.onContinueShop(getItemBean(getPosition(holder)));
                }
            }
        });
        holder.img_anchor.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(mOnCartEventListener != null){
                    mOnCartEventListener.onAnchorClicked(getItemBean(getPosition(holder)).anchorItem);
                }
            }
        });
    }

    @Override
    public void convertViewHolder(ViewHolderMyCart holder, LSMyCartItem data, int position) {
        holder.setData(data, position);
    }

    /**
     * 当图片不显示的时候自动释放，防止oom
     *
     * @param holder
     */
    @Override
    public void onViewRecycled(RecyclerView.ViewHolder holder) {
        super.onViewRecycled(holder);
        if (holder instanceof ViewHolderMyCart) {
            ViewHolderMyCart viewHolder = (ViewHolderMyCart) holder;
            if (viewHolder.img_anchor.getController() != null) {
                viewHolder.img_anchor.getController().onDetach();
            }
        }
    }

    /**
     * ViewHolder
     */
    protected class ViewHolderMyCart extends BaseViewHolder<LSMyCartItem> {
        public TextView tvName;
        public SimpleDraweeView img_anchor;
        public HeaderAndFooterRecyclerViewEx recyclerViewEx;
        public MyCartItemAdapter mAdapterFlowers;
        public Button btn_checkout, btn_continue_shop;

        private int picSize ;

        public ViewHolderMyCart(View itemView) {
            super(itemView);
        }

        @Override
        public void bindItemView(View itemView) {
            recyclerViewEx = f(R.id.ry_myCart);
            tvName = f(R.id.tvName);
            img_anchor = f(R.id.img_anchor);
            btn_checkout = f(R.id.btn_checkout);
            btn_continue_shop = f(R.id.btn_continue_shop);

            FrescoLoadUtil.setHierarchy(mContext, img_anchor, R.color.black4, true);

            LinearLayoutManager manager = new LinearLayoutManager(mContext, LinearLayoutManager.VERTICAL, false);
            recyclerViewEx.setLayoutManager(manager);
            recyclerViewEx.setNestedScrollingEnabled(false);
//            recyclerViewEx.setRecycledViewPool(mViewPool);  // 共用子 item 的缓存池。但使用在嵌套的recyclerView且子recyclerView会修改数据时，由于使用BaseRecyclerViewAdapter，会根据getPosition(holder)取数据，holder被复用了，得到的数据会不准确

            mAdapterFlowers = new MyCartItemAdapter(mContext, mMyCartGiftsSynManager);
            recyclerViewEx.setAdapter(mAdapterFlowers);
            mAdapterFlowers.setOnEventListener(mOnCartEventListener);

            picSize = mContext.getResources().getDimensionPixelSize(R.dimen.my_cart_anchor_img_size);
        }

        @Override
        public void setData(final LSMyCartItem data, int position) {
            mAdapterFlowers.setLSRecipientAnchorGiftItem(data.anchorItem);
            mAdapterFlowers.setData(data.getLSFlowerGiftBaseInfoItemList());

            FrescoLoadUtil.loadUrl(img_anchor, data.anchorItem.anchorAvatarImg, picSize);
            tvName.setText(data.anchorItem.anchorNickName);
        }
    }
}
