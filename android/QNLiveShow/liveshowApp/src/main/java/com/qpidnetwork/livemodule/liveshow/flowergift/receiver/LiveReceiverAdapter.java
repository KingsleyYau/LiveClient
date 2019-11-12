package com.qpidnetwork.livemodule.liveshow.flowergift.receiver;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.utils.FrescoLoadUtil;
import com.qpidnetwork.qnbridgemodule.bean.BaseUserInfo;
import com.qpidnetwork.qnbridgemodule.util.DisplayUtil;

import java.util.List;

public class LiveReceiverAdapter extends RecyclerView.Adapter<LiveReceiverAdapter.ReceiverViewHolder> {

    protected List<BaseUserInfo> mList;
    protected Context mContext;

    private int picHeight;
    private int topRadius;

    public LiveReceiverAdapter(Context context, List<BaseUserInfo> list) {
        mContext = context;
        mList = list;

        picHeight = mContext.getResources().getDimensionPixelSize(R.dimen.lady_hot_list_bg_max_HW);
        topRadius = DisplayUtil.dip2px(mContext, 3);
    }


    @Override
    public LiveReceiverAdapter.ReceiverViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.adapter_receiver_item, parent, false);
        LiveReceiverAdapter.ReceiverViewHolder viewHolder = new LiveReceiverAdapter.ReceiverViewHolder(view);
        return viewHolder;
    }

    @Override
    public void onBindViewHolder(final LiveReceiverAdapter.ReceiverViewHolder holder, int position) {
        int length = mList.size();
        if (position >= length) {
            position = position % length;
        }
        final BaseUserInfo item = mList.get(position);
        holder.tvName.setText(item.userName);

        //背景图
        if (!TextUtils.isEmpty(item.photoUrl) && mContext != null) {
            FrescoLoadUtil.loadUrl(mContext, holder.ivPhoto, item.photoUrl, picHeight,
                    R.color.black4, false, topRadius, topRadius, 0, 0);
        }
    }

    @Override
    public int getItemCount() {
        return Integer.MAX_VALUE;
    }

    /**
     * 获取指定位置Item
     *
     * @param position
     * @return
     */
    public BaseUserInfo getItemInfo(int position) {
        BaseUserInfo userInfo = null;
        if (position >= 0 && (mList != null) && mList.size() > 0) {
            int length = mList.size();
            if (position >= length) {
                position = position % length;
            }
            userInfo = mList.get(position);
        }
        return userInfo;
    }

    /**
     * 当图片不显示的时候自动释放，防止oom
     *
     * @param holder
     */
    @Override
    public void onViewRecycled(LiveReceiverAdapter.ReceiverViewHolder holder) {
        super.onViewRecycled(holder);
        if (holder.ivPhoto.getController() != null) {
            holder.ivPhoto.getController().onDetach();
        }
    }

    /**
     * ViewHolder
     */
    protected class ReceiverViewHolder extends RecyclerView.ViewHolder {
        private RelativeLayout rlRoot;
        private SimpleDraweeView ivPhoto;
        private TextView tvName;

        public ReceiverViewHolder(View itemView) {
            super(itemView);
            rlRoot = (RelativeLayout) itemView.findViewById(R.id.rlRoot);
            ivPhoto = (SimpleDraweeView) itemView.findViewById(R.id.ivPhoto);
            tvName = (TextView) itemView.findViewById(R.id.tvName);
            //edit by Jagger 2018-6-29:picasso不会从本地取缓存，每次下载，初始化时图片显示得太慢，所以改用fresco
            //对齐方式(中上对齐)
            FrescoLoadUtil.setHierarchy(itemView.getContext(), ivPhoto, R.drawable.ic_default_photo_woman_rect, false);
        }
    }
}
