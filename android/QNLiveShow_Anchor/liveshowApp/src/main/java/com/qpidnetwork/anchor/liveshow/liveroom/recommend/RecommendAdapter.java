package com.qpidnetwork.anchor.liveshow.liveroom.recommend;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.httprequest.item.AnchorInfoItem;
import com.qpidnetwork.anchor.httprequest.item.OnlineStatus;
import com.qpidnetwork.anchor.utils.Log;
import com.qpidnetwork.anchor.view.ButtonRaised;

import java.util.ArrayList;
import java.util.List;

/**
 * 推荐列表item
 * @author Jagger
 * 2018-5-14
 */
public class RecommendAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    private List<AnchorInfoItem> mList = new ArrayList<>();
    private Context mContext;
    private OnRecommendEventListener mOnRecommendEventListener;

    /**
     * item点击事件响应
     */
    public interface OnRecommendEventListener{
        void onRecommendClicked(AnchorInfoItem infoItem);
    }

    public RecommendAdapter(Context context, List<AnchorInfoItem> list){
        mContext = context;
        mList = list;
    }

    public void setOnRecommendEventListener(OnRecommendEventListener mOnRecommendEventListener) {
        this.mOnRecommendEventListener = mOnRecommendEventListener;
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_recommend_list, parent, false);
        return new ViewHolderRecommend(view);
    }

    @Override
    public void onBindViewHolder(RecyclerView.ViewHolder holder, int position) {
        ViewHolderRecommend viewHolder = (ViewHolderRecommend) holder;

        final AnchorInfoItem item = mList.get(position);

        viewHolder.imgAnchorAvatar.setImageURI(item.photoUrl);
        viewHolder.tvAnchorNickname.setText(item.nickName);
        viewHolder.tvDes.setText(mContext.getString(R.string.hangout_dialog_des , item.age , item.country) );

        if(item.onlineStatus == OnlineStatus.On){
            viewHolder.btnRecommend.setEnabled(true);
            viewHolder.btnRecommend.setButtonBackground(mContext.getResources().getColor(R.color.live_msg_list_recommend_bg));
            viewHolder.btnRecommend.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    if(mOnRecommendEventListener != null){
                        mOnRecommendEventListener.onRecommendClicked(item);
                    }
                }
            });
        }else {
            viewHolder.btnRecommend.setEnabled(false);
            viewHolder.btnRecommend.setButtonBackground(mContext.getResources().getColor(R.color.black3));
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
        public ButtonRaised btnRecommend;

        public ViewHolderRecommend(View itemView) {
            super(itemView);
            imgAnchorAvatar = (SimpleDraweeView)itemView.findViewById(R.id.img_anchor_photo);
            tvAnchorNickname = (TextView)itemView.findViewById(R.id.tv_anchor_name);
            tvDes = (TextView)itemView.findViewById(R.id.tv_desc);
            btnRecommend = (ButtonRaised)itemView.findViewById(R.id.btn_recommend);
        }
    }
}
