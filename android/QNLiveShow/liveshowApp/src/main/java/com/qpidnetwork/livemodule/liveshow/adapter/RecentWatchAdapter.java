package com.qpidnetwork.livemodule.liveshow.adapter;

import android.content.Context;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.livechathttprequest.item.LCVideoItem;
import com.qpidnetwork.livemodule.utils.PicassoLoadUtil;

/**
 * Created  by Oscar
 * 2019-5-13
 */
public class RecentWatchAdapter extends BaseRecyclerViewAdapter<LCVideoItem, RecentWatchAdapter.RecentWatchHolder> {


    public RecentWatchAdapter(Context context) {
        super(context);
    }

    @Override
    public int getLayoutId(int viewType) {
        return R.layout.adapter_live_chat_recent_watch_item;
    }

    @Override
    public RecentWatchHolder getViewHolder(View itemView, int viewType) {
        return new RecentWatchHolder(itemView);
    }


    @Override
    public void initViewHolder(final RecentWatchHolder holder) {

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
    public void convertViewHolder(RecentWatchHolder holder,
                                  LCVideoItem data,
                                  int position) {
        holder.setData(data, position);
    }


    static class RecentWatchHolder extends BaseViewHolder<LCVideoItem> {


        private ImageView videoCover;
        private TextView videoTitle;

        public RecentWatchHolder(View itemView) {
            super(itemView);
        }

        @Override
        public void bindItemView(View itemView) {

            videoCover = f(R.id.videoCover);
            videoTitle = f(R.id.videoTitle);
        }

        @Override
        public void setData(LCVideoItem data, int position) {

            int w = videoCover.getLayoutParams().width;
            int h = videoCover.getLayoutParams().height;
            String coverUrl = data.videoCover;
            PicassoLoadUtil.loadUrl(videoCover, coverUrl, R.color.black4, w, h);
            videoTitle.setText(data.title);

        }
    }
}
