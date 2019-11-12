package com.qpidnetwork.livemodule.liveshow.flowergift.store;

import android.content.Context;
import android.graphics.Paint;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.View;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.LSDeliveryItem;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseRecyclerViewAdapter;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseViewHolder;
import com.qpidnetwork.livemodule.utils.DateUtil;
import com.qpidnetwork.livemodule.utils.FrescoLoadUtil;

/**
 * @author Jagger 2019-10-14
 */
public class DeliveryListAdapter extends BaseRecyclerViewAdapter<LSDeliveryItem, DeliveryListAdapter.ViewHolder> {
    private Context mContext;
    private RecyclerView.RecycledViewPool mViewPool;
    private OnDeliveryItemEventListener mListener;

    public DeliveryListAdapter(Context context) {
        super(context);
        mContext = context;
        mViewPool = new RecyclerView.RecycledViewPool();
    }

    public void setOnDeliveryItemEventListener(OnDeliveryItemEventListener eventListener){
        mListener = eventListener;
    }

    @Override
    public int getLayoutId(int viewType) {
        return R.layout.item_delivery_list;
    }

    @Override
    public ViewHolder getViewHolder(View itemView, int viewType) {
        return new ViewHolder(itemView);
    }

    @Override
    public void initViewHolder(final ViewHolder holder) {
        holder.img_anchor.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(mListener != null){
                    mListener.onAnchorClicked(getItemBean(getPosition(holder)).anchorId);
                }
            }
        });

        holder.tv_status.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(mListener != null){
                    mListener.onStatusClicked();
                }
            }
        });
    }

    @Override
    public void convertViewHolder(ViewHolder holder, LSDeliveryItem data, int position) {
        holder.setData(data, position);
    }

    /**
     * ViewHolder
     */
    protected class ViewHolder extends BaseViewHolder<LSDeliveryItem> {
        public TextView tvName, tvDate, tv_num, tv_status;
        public SimpleDraweeView img_anchor;
        public RecyclerView recyclerView;
        private DeliveryGiftsAdapter mAdapter;

        private int picSize ;

        public ViewHolder(View itemView) {
            super(itemView);
        }

        @Override
        public void bindItemView(View itemView) {
            img_anchor = f(R.id.img_anchor);
            tvName = f(R.id.tvName);
            tvDate = f(R.id.tvDate);
            tv_num = f(R.id.tv_num);
            tv_status = f(R.id.tv_status);
            tv_status.getPaint().setFlags(Paint.UNDERLINE_TEXT_FLAG);
            recyclerView = f(R.id.ry_gifts);
            FrescoLoadUtil.setHierarchy(mContext, img_anchor, R.color.black4, true);

            LinearLayoutManager manager = new LinearLayoutManager(mContext, LinearLayoutManager.HORIZONTAL, false);
            recyclerView.setLayoutManager(manager);
            recyclerView.setNestedScrollingEnabled(false);
            recyclerView.setRecycledViewPool(mViewPool);      // 共用子 item 的缓存池
            recyclerView.setFocusable(false);

            mAdapter = new DeliveryGiftsAdapter(mContext);
            mAdapter.setOnDeliveryItemEventListener(mListener);
            recyclerView.setAdapter(mAdapter);

            picSize = mContext.getResources().getDimensionPixelSize(R.dimen.my_cart_anchor_img_size);
        }

        @Override
        public void setData(LSDeliveryItem data, int position) {
            FrescoLoadUtil.loadUrl(img_anchor, data.anchorAvatar , picSize);
            tvName.setText(data.anchorNickName);
            tvDate.setText(DateUtil.getDateStr(data.orderDate*1000l, DateUtil.FORMAT_MMDDyyyyhhmm_24));
            tv_num.setText(data.orderNumber);
            tv_status.setText(data.deliveryStatusVal);
            mAdapter.setData(data.gifts);
        }
    }
}
