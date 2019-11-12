package com.qpidnetwork.anchor.liveshow.liveroom.beautyfilter;

import android.content.Context;
import android.support.v4.content.ContextCompat;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.liveshow.base.BaseRecyclerViewAdapter;
import com.qpidnetwork.anchor.liveshow.base.BaseViewHolder;

/**
 * Created by Hardy on 2019/10/30.
 */
public class BeautyFilterAdapter extends BaseRecyclerViewAdapter<BeautyFilterBean, BeautyFilterAdapter.BeautyFilterViewHolder> {

    public BeautyFilterAdapter(Context context) {
        super(context);
    }

    @Override
    public int getLayoutId(int viewType) {
        return R.layout.item_beauty_filter;
    }

    @Override
    public BeautyFilterViewHolder getViewHolder(View itemView, int viewType) {
        return new BeautyFilterViewHolder(itemView);
    }

    @Override
    public void initViewHolder(final BeautyFilterViewHolder holder) {
        holder.mIcon.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mOnItemClickListener != null) {
                    mOnItemClickListener.onItemClick(v, getPosition(holder));
                }
            }
        });
    }

    @Override
    public void convertViewHolder(BeautyFilterViewHolder holder, BeautyFilterBean data, int position) {
        holder.setData(data, position);
    }

    /**
     * ViewHolder
     */
    static class BeautyFilterViewHolder extends BaseViewHolder<BeautyFilterBean> {

        public SimpleDraweeView mIcon;
        private TextView mTvName;

        public BeautyFilterViewHolder(View itemView) {
            super(itemView);
        }

        @Override
        public void bindItemView(View itemView) {
            mIcon = f(R.id.item_beauty_filter_icon);
            mTvName = f(R.id.item_beauty_filter_name);
        }

        @Override
        public void setData(BeautyFilterBean data, int position) {
            mTvName.setText(data.filterName);

            if (data.filterType == BeautyFilterType.Original) {
                mIcon.setScaleType(ImageView.ScaleType.CENTER_INSIDE);
                mIcon.setBackground(data.isSelect ? ContextCompat.getDrawable(context, R.drawable.bg_beauty_filter_original_select) :
                        ContextCompat.getDrawable(context, R.drawable.bg_beauty_filter_original));
            } else {
                mIcon.setScaleType(ImageView.ScaleType.CENTER_CROP);
                mIcon.setBackground(data.isSelect ? ContextCompat.getDrawable(context, R.drawable.bg_beauty_filter_select) : null);
            }

            switch (data.filterType) {
                case Emerald:
                    mIcon.setImageResource(R.drawable.ic_beauty_filter_emerald);
                    break;

                case Healthy:
                    mIcon.setImageResource(R.drawable.ic_beauty_filter_healthy);
                    break;

                case Hefe:
                    mIcon.setImageResource(R.drawable.ic_beauty_filter_hefe);
                    break;

                case Lomo:
                    mIcon.setImageResource(R.drawable.ic_beauty_filter_lomo);
                    break;

                case Cool:
                    mIcon.setImageResource(R.drawable.ic_beauty_filter_cool);
                    break;

                case Anitque:
                    mIcon.setImageResource(R.drawable.ic_beauty_filter_anitque);
                    break;

                default:
                    mIcon.setImageResource(R.drawable.ic_beauty_filter_original);
                    break;
            }

        }
    }
}
