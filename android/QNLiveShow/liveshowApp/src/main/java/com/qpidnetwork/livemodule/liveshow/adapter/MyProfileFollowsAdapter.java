package com.qpidnetwork.livemodule.liveshow.adapter;

import android.content.Context;
import android.graphics.drawable.AnimationDrawable;
import android.graphics.drawable.Drawable;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.livemodule.httprequest.item.AnchorOnlineStatus;
import com.qpidnetwork.livemodule.httprequest.item.FollowingListItem;
import com.qpidnetwork.livemodule.httprequest.item.LiveRoomType;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.PicassoLoadUtil;

/**
 * Created by Hardy on 2018/9/19.
 * <p>
 * 横向关注列表的 adapter
 */
public class MyProfileFollowsAdapter extends BaseRecyclerViewAdapter<FollowingListItem,
        MyProfileFollowsAdapter.MyProfileFollowsViewHolder> {

    private int mUserIconWH;

    public MyProfileFollowsAdapter(Context context) {
        super(context);
    }

    public void setUserIconWH(int mUserIconWH) {
        this.mUserIconWH = mUserIconWH;
    }

    @Override
    public int getLayoutId(int viewType) {
        return R.layout.item_my_profile_follow;
    }

    @Override
    public MyProfileFollowsViewHolder getViewHolder(View itemView, int viewType) {
        return new MyProfileFollowsViewHolder(itemView);
    }

    @Override
    public void initViewHolder(final MyProfileFollowsViewHolder holder) {
        holder.setUserIconWH(mUserIconWH);
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
    public void convertViewHolder(MyProfileFollowsViewHolder holder, FollowingListItem data, int position) {
        holder.setData(data, position);
    }


    /**
     * ViewHolder
     */
    static class MyProfileFollowsViewHolder extends BaseViewHolder<FollowingListItem> {

        public CircleImageView mIvIcon;
        public ImageView mIvStatus;
        public ImageView mIvStatusLiving;

        private int wh;

        public MyProfileFollowsViewHolder(View itemView) {
            super(itemView);
            wh = DisplayUtil.dip2px(context, 50);
        }

        @Override
        public void bindItemView(View itemView) {
            mIvIcon = f(R.id.item_my_profile_follow_iv_userIcon);
            mIvStatus = f(R.id.item_my_profile_follow_iv_status);
            mIvStatusLiving = f(R.id.item_my_profile_follow_iv_living);
        }

        @Override
        public void setData(FollowingListItem data, int position) {
            // Hardy
            // 参照 FollowingListFragment，并简化某些逻辑
            if (data.onlineStatus == AnchorOnlineStatus.Online) {
                if (data.roomType == LiveRoomType.FreePublicRoom ||
                        data.roomType == LiveRoomType.PaidPublicRoom) {

                    mIvStatus.setVisibility(View.GONE);
                    mIvStatusLiving.setVisibility(View.VISIBLE);

                    setAndStartRoomTypeAnimation(data.roomType);
                } else {
                    mIvStatus.setVisibility(View.VISIBLE);
                    mIvStatusLiving.setVisibility(View.GONE);
                }
            } else {
                mIvStatusLiving.setVisibility(View.GONE);
                mIvStatus.setVisibility(View.GONE);
            }

//            PicassoLoadUtil.loadUrl(mIvIcon, data.photoUrl, R.drawable.ic_default_photo_woman);
            PicassoLoadUtil.loadUrl(mIvIcon, data.photoUrl, R.drawable.ic_default_photo_woman, wh, wh);
        }

        public void setUserIconWH(int mUserIconWH) {
            ViewGroup.LayoutParams params = itemView.getLayoutParams();
            params.height = mUserIconWH;
            params.width = mUserIconWH;
            itemView.setLayoutParams(params);
        }


        /**
         * 设置启动房间直播间状态
         *
         * @param roomType
         */
        private void setAndStartRoomTypeAnimation(LiveRoomType roomType) {
            if (roomType == LiveRoomType.FreePublicRoom || roomType == LiveRoomType.PaidPublicRoom) {
                mIvStatusLiving.setImageResource(R.drawable.anim_my_profile_broadcasting);

                mIvStatusLiving.postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        Drawable tempDrawable = mIvStatusLiving.getDrawable();
                        if ((tempDrawable != null)
                                && (tempDrawable instanceof AnimationDrawable)) {
                            ((AnimationDrawable) tempDrawable).start();
                        }
                    }
                }, 200);
            }
        }
    }
}

