package com.qpidnetwork.livemodule.liveshow.liveroom.hangout.adapter;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.AnchorOnlineStatus;
import com.qpidnetwork.livemodule.httprequest.item.HangoutAnchorInfoItem;
import com.qpidnetwork.livemodule.utils.FrescoLoadUtil;

import java.util.ArrayList;
import java.util.List;

public class HangoutInviteFriendsAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    private List<HangoutAnchorInfoItem> mList = new ArrayList<>();
    private Context mContext;
    private OnRecommendEventListener mOnRecommendEventListener;

    /**
     * item点击事件响应
     */
    public interface OnRecommendEventListener{
        void onRecommendClicked(HangoutAnchorInfoItem infoItem);
    }

    public HangoutInviteFriendsAdapter(Context context, List<HangoutAnchorInfoItem> list){
        mContext = context;
        mList = list;
    }

    public void setOnRecommendEventListener(OnRecommendEventListener mOnRecommendEventListener) {
        this.mOnRecommendEventListener = mOnRecommendEventListener;
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_hangout_invite_friends_item, parent, false);
        return new ViewHolderRecommend(view);
    }

    @Override
    public void onBindViewHolder(RecyclerView.ViewHolder holder, int position) {
        ViewHolderRecommend viewHolder = (ViewHolderRecommend) holder;

        final HangoutAnchorInfoItem item = mList.get(position);

        FrescoLoadUtil.loadUrl(viewHolder.imgAnchorAvatar, item.photoUrl, mContext.getResources().getDimensionPixelSize(R.dimen.live_size_60dp));

        viewHolder.tvAnchorNickname.setText(item.nickName);
        viewHolder.tvDes.setText(mContext.getString(R.string.hangout_dialog_des , item.age , item.country) );

        if(item.onlineStatus == AnchorOnlineStatus.Online){
            viewHolder.btnInvite.setEnabled(true);
            viewHolder.btnInvite.setBackgroundResource(R.drawable.btn_hangout_list_stroke_shape);
            viewHolder.btnInvite.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    if(mOnRecommendEventListener != null){
                        mOnRecommendEventListener.onRecommendClicked(item);
                    }
                }
            });
            viewHolder.ivOnline.setVisibility(View.VISIBLE);
        }else {
            viewHolder.ivOnline.setVisibility(View.GONE);
            viewHolder.btnInvite.setEnabled(false);
            viewHolder.btnInvite.setBackgroundResource(R.drawable.rectangle_rounded_angle_grey_bg);
        }

    }

    @Override
    public int getItemCount() {
        return mList.size();
    }

    /**
     * 推荐View
     */
    static class ViewHolderRecommend extends RecyclerView.ViewHolder {
        public SimpleDraweeView imgAnchorAvatar;
        public TextView tvAnchorNickname , tvDes;
        public TextView btnInvite;
        public View ivOnline;

        public ViewHolderRecommend(View itemView) {
            super(itemView);
            imgAnchorAvatar = (SimpleDraweeView)itemView.findViewById(R.id.img_anchor_photo);
            tvAnchorNickname = (TextView)itemView.findViewById(R.id.tv_anchor_name);
            tvDes = (TextView)itemView.findViewById(R.id.tv_desc);
            btnInvite = (TextView)itemView.findViewById(R.id.btnInvite);
            ivOnline = (View)itemView.findViewById(R.id.ivOnline);
            FrescoLoadUtil.setHierarchy(itemView.getContext(), imgAnchorAvatar, R.drawable.ic_default_photo_woman, true);
        }
    }
}
