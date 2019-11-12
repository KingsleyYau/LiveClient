package com.qpidnetwork.livemodule.liveshow.flowergift.adapter;

import android.content.Context;
import android.view.View;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseRecyclerViewAdapter;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseViewHolder;
import com.qpidnetwork.livemodule.liveshow.flowergift.store.FlowersTypeBean;
import com.qpidnetwork.livemodule.liveshow.flowergift.store.FlowersTypeNameItemView;

/**
 * Created by Hardy on 2019/10/9.
 * 鲜花礼品分类的 adapter
 */
public class FlowersTypeAdapter extends BaseRecyclerViewAdapter<FlowersTypeBean,
        FlowersTypeAdapter.FlowersTypeViewHolder> {


    public FlowersTypeAdapter(Context context) {
        super(context);
    }

    @Override
    public int getLayoutId(int viewType) {
        return R.layout.layout_flowers_type_name_item;
    }

    @Override
    public FlowersTypeViewHolder getViewHolder(View itemView, int viewType) {
        return new FlowersTypeViewHolder(itemView);
    }

    @Override
    public void initViewHolder(final FlowersTypeViewHolder holder) {
        holder.itemView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mOnItemClickListener != null) {
                    mOnItemClickListener.onItemClick(v, getPosition(holder));
                }
            }
        });
    }

    @Override
    public void convertViewHolder(FlowersTypeViewHolder holder, FlowersTypeBean data, int position) {
        holder.setData(data, position);
    }

    /**
     * ViewHolder
     */
    static class FlowersTypeViewHolder extends BaseViewHolder<FlowersTypeBean> {

        private FlowersTypeNameItemView mNameView;

        public FlowersTypeViewHolder(View itemView) {
            super(itemView);
        }

        @Override
        public void bindItemView(View itemView) {
            mNameView = f(R.id.flowers_type_root_view);

            mNameView.showLineBottom(false);
//            mNameView.setIcon(R.drawable.ic_live_emoji_pear);
            mNameView.showIcon(false);
        }

        @Override
        public void setData(FlowersTypeBean data, int position) {
            // 名字
            mNameView.setName(data.typeName);

            // 免费贺卡
            mNameView.showFreeCard(data.hasGreetingCard);

            // 选中效果
//            mNameView.showIcon(data.hasSelect);
            mNameView.setBackgroundResource(data.hasSelect ?
                    R.color.theme_default_activity_bg_grey : R.color.white);
        }
    }
}
