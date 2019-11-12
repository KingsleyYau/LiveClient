package com.qpidnetwork.livemodule.liveshow.liveroom;

import android.content.Context;
import android.support.v7.widget.CardView;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.AnchorOnlineStatus;
import com.qpidnetwork.livemodule.httprequest.item.LiveRoomListItem;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.httprequest.item.PageRecommendItem;
import com.qpidnetwork.livemodule.liveshow.anchor.AnchorProfileActivity;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.manager.FollowManager;
import com.qpidnetwork.livemodule.liveshow.sayhi.SayHiEditActivity;
import com.qpidnetwork.livemodule.utils.ButtonUtils;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.FrescoLoadUtil;

import java.util.List;

public class LiveRoomRecommandAdapter extends RecyclerView.Adapter<LiveRoomRecommandAdapter.RecommandViewHolder> {
    //变量
    protected List<RecommandDataBean> mList ;
    protected Context mContext;
    private int mRecycleBodyWidth = 0;

    public LiveRoomRecommandAdapter(Context context, List<RecommandDataBean> list, int width){
        mContext = context;
        mList = list;
        mRecycleBodyWidth = width;
    }

    @Override
    public LiveRoomRecommandAdapter.RecommandViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.adapter_liveroom_end_recommand, parent, false);
        RecommandViewHolder viewHolder = new RecommandViewHolder(view);
        return viewHolder;
    }

    @Override
    public void onBindViewHolder(final LiveRoomRecommandAdapter.RecommandViewHolder holder, int position) {
        int length = mList.size();
        if (position >= length) {
            position = position % length;
        }

        RecyclerView.LayoutParams params = (RecyclerView.LayoutParams)holder.ll_root.getLayoutParams();
        params.width = mRecycleBodyWidth;

        LinearLayout.LayoutParams cardViewLeftParams = (LinearLayout.LayoutParams) holder.cardViewLeft.getLayoutParams();
        cardViewLeftParams.width = (mRecycleBodyWidth - DisplayUtil.dip2px(mContext, 8))/2;

        LinearLayout.LayoutParams cardViewRightParams = (LinearLayout.LayoutParams) holder.cardViewRight.getLayoutParams();
        cardViewRightParams.width = (mRecycleBodyWidth - DisplayUtil.dip2px(mContext, 8))/2;

        final RecommandDataBean item = mList.get(position);

        //left 处理
        holder.tvLeftName.setText(item.leftData.nickName);
        if(item.leftData.onlineStatus == AnchorOnlineStatus.Online){
            holder.ivLeftOnline.setImageResource(R.drawable.circle_solid_green);
        }else{
            holder.ivLeftOnline.setImageResource(R.drawable.circle_solid_grey);
        }

        //背景图
        if(!TextUtils.isEmpty(item.leftData.coverImg) && mContext!= null){
            int picHeight = mContext.getResources().getDimensionPixelSize(R.dimen.lady_hot_list_bg_max_HW);
            FrescoLoadUtil.loadUrl(holder.ivLeftRoomBg, item.leftData.coverImg, picHeight);
        }

        //follow
        if(item.leftData.isFollow){
            holder.ivLeftFollow.setImageResource(R.drawable.ic_recommand_follow);
        }else{
            holder.ivLeftFollow.setImageResource(R.drawable.ic_recommand_unfollow);
        }

        //right处理
        holder.tvRightName.setText(item.rightData.nickName);
        if(item.rightData.onlineStatus == AnchorOnlineStatus.Online){
            holder.ivRightOnline.setImageResource(R.drawable.circle_solid_green);
        }else{
            holder.ivRightOnline.setImageResource(R.drawable.circle_solid_grey);
        }

        //背景图
        if(!TextUtils.isEmpty(item.rightData.coverImg) && mContext!= null){
            int picHeight = mContext.getResources().getDimensionPixelSize(R.dimen.lady_hot_list_bg_max_HW);
            FrescoLoadUtil.loadUrl(holder.ivRightRoomBg, item.rightData.coverImg, picHeight);
        }

        //follow
        if(item.rightData.isFollow){
            holder.ivRightFollow.setImageResource(R.drawable.ic_recommand_follow);
        }else{
            holder.ivRightFollow.setImageResource(R.drawable.ic_recommand_unfollow);
        }

        //SayHi
        if(LoginManager.getInstance().getLoginStatus() == LoginManager.LoginStatus.Logined){
            //观众是否有SayHi权限
            LoginItem loginItem = LoginManager.getInstance().getLoginItem();
            if (null != loginItem && loginItem.userPriv != null) {
                if(loginItem.userPriv.isSayHiPriv){
                    holder.ivLeftSayhi.setVisibility(View.VISIBLE);
                    holder.ivRightSayhi.setVisibility(View.VISIBLE);
                }else {
                    holder.ivLeftSayhi.setVisibility(View.GONE);
                    holder.ivRightSayhi.setVisibility(View.GONE);
                }
            }

        }else{
            holder.ivLeftSayhi.setVisibility(View.GONE);
            holder.ivRightSayhi.setVisibility(View.GONE);
        }

        //点击资料
        holder.ivLeftRoomBg.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if(!ButtonUtils.isFastDoubleClick(view.getId())) {
                    AnchorProfileActivity.launchAnchorInfoActivty(mContext,
                            mContext.getResources().getString(R.string.live_webview_anchor_profile_title),
                            item.leftData.anchorId, false, AnchorProfileActivity.TagType.Album);
                }
            }
        });

        holder.ivRightRoomBg.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if(!ButtonUtils.isFastDoubleClick(view.getId())) {
                    AnchorProfileActivity.launchAnchorInfoActivty(mContext,
                            mContext.getResources().getString(R.string.live_webview_anchor_profile_title),
                            item.rightData.anchorId, false, AnchorProfileActivity.TagType.Album);
                }
            }
        });

        holder.ivLeftFollow.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if(!item.leftData.isFollow){
                    item.leftData.isFollow = true;
                    holder.ivLeftFollow.setImageResource(R.drawable.ic_recommand_follow);
                    FollowManager followManager = FollowManager.getInstance();
                    if(followManager != null){
                        LiveRoomListItem liveRoomListItem = new LiveRoomListItem();
                        liveRoomListItem.userId = item.leftData.anchorId;
                        liveRoomListItem.isFollow = false;
                        followManager.summitFollow(liveRoomListItem, false);
                    }
                }
            }
        });

        holder.ivRightFollow.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if(!item.rightData.isFollow){
                    item.rightData.isFollow = true;
                    holder.ivRightFollow.setImageResource(R.drawable.ic_recommand_follow);
                    FollowManager followManager = FollowManager.getInstance();
                    if(followManager != null){
                        LiveRoomListItem liveRoomListItem = new LiveRoomListItem();
                        liveRoomListItem.userId = item.rightData.anchorId;
                        liveRoomListItem.isFollow = false;
                        followManager.summitFollow(liveRoomListItem, false);
                    }
                }
            }
        });

        //SayHi
        holder.ivLeftSayhi.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                SayHiEditActivity.startAct(mContext, item.leftData.anchorId, item.leftData.nickName);
            }
        });

        holder.ivRightSayhi.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                SayHiEditActivity.startAct(mContext, item.rightData.anchorId, item.rightData.nickName);
            }
        });

    }

    /**
     * 当图片不显示的时候自动释放，防止oom
     * @param holder
     */
    @Override
    public void onViewRecycled(LiveRoomRecommandAdapter.RecommandViewHolder holder) {
        super.onViewRecycled(holder);
        if (holder.ivLeftRoomBg.getController() != null) {
            holder.ivLeftRoomBg.getController().onDetach();
        }
        if (holder.ivRightRoomBg.getController() != null) {
            holder.ivRightRoomBg.getController().onDetach();
        }
    }

    @Override
    public int getItemCount() {
        return Integer.MAX_VALUE;
    }

    /**
     * ViewHolder
     */
    protected class RecommandViewHolder extends RecyclerView.ViewHolder {
        public LinearLayout ll_root;
        public SimpleDraweeView ivLeftRoomBg, ivRightRoomBg;
        public ImageView ivLeftFollow, ivRightFollow;
        public ImageView ivLeftSayhi, ivRightSayhi;
        public ImageView ivLeftOnline, ivRightOnline;
        public TextView tvLeftName, tvRightName;
        public CardView cardViewLeft, cardViewRight;

        public RecommandViewHolder(View itemView){
            super(itemView);
            ll_root = (LinearLayout)itemView.findViewById(R.id.ll_root);

            cardViewLeft = (CardView) itemView.findViewById(R.id.cardViewLeft);
            ivLeftRoomBg = (SimpleDraweeView)itemView.findViewById(R.id.iv_left_roomBg);
            tvLeftName = (TextView)itemView.findViewById(R.id.tvLeftName);
            ivLeftOnline = (ImageView)itemView.findViewById(R.id.ivLeftOnline);
            ivLeftFollow = (ImageView)itemView.findViewById(R.id.ivLeftFollow);
            ivLeftSayhi = (ImageView)itemView.findViewById(R.id.ivLeftSayhi);

            cardViewRight = (CardView)itemView.findViewById(R.id.cardViewRight);
            ivRightRoomBg = (SimpleDraweeView)itemView.findViewById(R.id.iv_right_roomBg);
            tvRightName = (TextView)itemView.findViewById(R.id.tvRightName);
            ivRightOnline = (ImageView)itemView.findViewById(R.id.ivRightOnline);
            ivRightFollow = (ImageView)itemView.findViewById(R.id.ivRightFollow);
            ivRightSayhi = (ImageView)itemView.findViewById(R.id.ivRightSayhi);

            //edit by Jagger 2018-6-29:picasso不会从本地取缓存，每次下载，初始化时图片显示得太慢，所以改用fresco
            //对齐方式(中上对齐)
            FrescoLoadUtil.setHierarchy(itemView.getContext(), ivLeftRoomBg, R.drawable.bg_hotlist_item, false);
            FrescoLoadUtil.setHierarchy(itemView.getContext(), ivRightRoomBg, R.drawable.bg_hotlist_item, false);
        }
    }

    /**
     * 数据bean
     */
    public static class RecommandDataBean{
        public PageRecommendItem leftData;
        public PageRecommendItem rightData;

        public RecommandDataBean(){

        }
    }
}
