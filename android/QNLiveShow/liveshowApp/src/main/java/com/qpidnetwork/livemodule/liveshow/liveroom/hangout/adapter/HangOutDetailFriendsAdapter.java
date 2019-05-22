package com.qpidnetwork.livemodule.liveshow.liveroom.hangout.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.PointF;
import android.net.Uri;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import com.facebook.drawee.backends.pipeline.Fresco;
import com.facebook.drawee.controller.BaseControllerListener;
import com.facebook.drawee.drawable.ScalingUtils;
import com.facebook.drawee.generic.GenericDraweeHierarchy;
import com.facebook.drawee.generic.GenericDraweeHierarchyBuilder;
import com.facebook.drawee.generic.RoundingParams;
import com.facebook.drawee.interfaces.DraweeController;
import com.facebook.drawee.view.SimpleDraweeView;
import com.facebook.imagepipeline.common.ResizeOptions;
import com.facebook.imagepipeline.image.ImageInfo;
import com.facebook.imagepipeline.request.ImageRequest;
import com.facebook.imagepipeline.request.ImageRequestBuilder;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.AnchorOnlineStatus;
import com.qpidnetwork.livemodule.httprequest.item.HangoutAnchorInfoItem;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseRecyclerViewAdapter;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseViewHolder;
import com.qpidnetwork.livemodule.utils.FrescoLoadUtil;

/**
 * HangOut详情弹框内，每个item里的Friends横向头像
 *
 * @author Jagger 2019-3-8
 */
public class HangOutDetailFriendsAdapter extends BaseRecyclerViewAdapter<HangoutAnchorInfoItem, HangOutDetailFriendsAdapter.ViewHolderHangOut> {

    private Context mContext;
    private OnHangOutDetailFriendsItemEventListener onHangOutListFriendsItemEventListener;

    public interface OnHangOutDetailFriendsItemEventListener {
        void onFriendClicked(HangoutAnchorInfoItem anchorInfoItem);
    }

    public HangOutDetailFriendsAdapter(Context context) {
        super(context);
        mContext = context;
    }

    public void setOnEventListener(OnHangOutDetailFriendsItemEventListener listener) {
        onHangOutListFriendsItemEventListener = listener;
    }

    @Override
    public int getLayoutId(int viewType) {
        return R.layout.item_live_hang_out_detail_friends;
    }

    @Override
    public ViewHolderHangOut getViewHolder(View itemView, int viewType) {
        return new ViewHolderHangOut(itemView);
    }

    @SuppressLint("ClickableViewAccessibility")
    @Override
    public void initViewHolder(final ViewHolderHangOut holder) {
    }

    @Override
    public void convertViewHolder(final ViewHolderHangOut holder, HangoutAnchorInfoItem data, int position) {
        holder.setData(data, position);
    }

    /**
     *
     */
    protected class ViewHolderHangOut extends BaseViewHolder<HangoutAnchorInfoItem> {
        public Button btnFriend;
        public SimpleDraweeView imgFriend;

        private View mOnlineView;
        private TextView mTvName;

        public ViewHolderHangOut(View itemView) {
            super(itemView);
        }

        @Override
        public void bindItemView(View itemView) {
            imgFriend = f(R.id.img_friend);
            btnFriend = f(R.id.btn_friend);

            mOnlineView = f(R.id.item_live_hang_out_details_friends_online);
            mTvName = f(R.id.item_live_hang_out_details_friends_tv_name);

            float radio = mContext.getResources().getDimensionPixelSize(R.dimen.live_size_4dp);
            FrescoLoadUtil.setHierarchy(itemView.getContext(), imgFriend, R.drawable.ic_default_photo_woman_rect, false, radio, radio, radio, radio);
        }

        @Override
        public void setData(final HangoutAnchorInfoItem data, int position) {
//            imgFriend.setImageURI(data.photoUrl);
            //压缩、裁剪图片
            int bgSize = mContext.getResources().getDimensionPixelSize(R.dimen.live_size_60dp);
            FrescoLoadUtil.loadUrl(imgFriend, data.photoUrl, bgSize);

            btnFriend.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    if (onHangOutListFriendsItemEventListener != null) {
                        onHangOutListFriendsItemEventListener.onFriendClicked(data);
                    }
                }
            });

            // 2019/3/25 Hardy
            mOnlineView.setVisibility(data.onlineStatus == AnchorOnlineStatus.Online ? View.VISIBLE : View.GONE);
            mTvName.setText(data.nickName);
        }

    }
}
