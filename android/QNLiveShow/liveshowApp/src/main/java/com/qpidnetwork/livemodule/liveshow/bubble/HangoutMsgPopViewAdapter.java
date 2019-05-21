package com.qpidnetwork.livemodule.liveshow.bubble;

import android.content.Context;
import android.support.v4.content.ContextCompat;
import android.text.TextUtils;
import android.view.View;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseRecyclerViewAdapter;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseViewHolder;
import com.qpidnetwork.livemodule.utils.PicassoLoadUtil;

/**
 * Created by Hardy on 2019/3/5.
 * home 主页的冒泡消息 adapter
 */
public class HangoutMsgPopViewAdapter extends BaseRecyclerViewAdapter<BubbleMessageBean,
        HangoutMsgPopViewAdapter.HangoutMsgPopViewHolder> {

    private HangoutMsgPopViewHelper mPopViewHelper;

    public HangoutMsgPopViewAdapter(Context context) {
        super(context);

        mPopViewHelper = new HangoutMsgPopViewHelper(context);
    }

    @Override
    public int getLayoutId(int viewType) {
        return R.layout.item_hangout_msg_pop_view;
    }

    @Override
    public HangoutMsgPopViewHolder getViewHolder(View itemView, int viewType) {
        return new HangoutMsgPopViewHolder(itemView);
    }

    @Override
    public void initViewHolder(final HangoutMsgPopViewHolder holder) {
        // 2019/3/5 初始化 item 宽度
        mPopViewHelper.initItemViewWidth(holder.itemView);

        // 2019/3/5 hang out 点击事件
        holder.mPbHangout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mOnItemClickListener != null) {
                    mOnItemClickListener.onItemClick(v, getPosition(holder));
                }
            }
        });
    }

    @Override
    public void convertViewHolder(HangoutMsgPopViewHolder holder, BubbleMessageBean data, int position) {
        holder.setData(data, position);
    }


    /**
     * ViewHolder
     */
    public static class HangoutMsgPopViewHolder extends BaseViewHolder<BubbleMessageBean> {

        private CircleImageView mIvUserBig;
        private CircleImageView mIvUserSmall;
        private TextView mTvName;
        private TextView mTvDesc;
        public TextView mTvHangout;
        public ProgressBar mPbHangout;

        public HangoutMsgPopViewHolder(View itemView) {
            super(itemView);
        }

        @Override
        public void bindItemView(View itemView) {
            mIvUserBig = f(R.id.item_hang_out_msg_pop_iv_user_big);
            mIvUserSmall = f(R.id.item_hang_out_msg_pop_iv_user_small);
            mTvName = f(R.id.item_hang_out_msg_pop_tv_user_name);
            mTvDesc = f(R.id.item_hang_out_msg_pop_tv_desc);
            mTvHangout = f(R.id.item_hang_out_msg_pop_tv_hang_out);
            mPbHangout = f(R.id.item_hang_out_msg_pop_pb);
            // 设置最大值为 45
            mPbHangout.setMax(HangoutMsgPopView.HANG_OUT_PROGRESS_MAX);
            mPbHangout.setSecondaryProgress(HangoutMsgPopView.HANG_OUT_PROGRESS_MAX);
        }

        @Override
        public void setData(BubbleMessageBean data, int position) {
            // TODO: 2019/3/5
            mTvName.setText(data.anchorName);
            mTvDesc.setText(data.invitaionMsg);

            //计算倒计时
            float progress = ((float) (System.currentTimeMillis() - data.firstShowTime)) * 100 /BubbleMessageManager.BUBBLE_SHOW_MAX_TIME;
            mPbHangout.setProgress(progress >= 100 ? 0 : (100 - (int)progress));

            if (data.bubbleMsgType == BubbleMessageType.Hangout) {
                mTvHangout.setText(R.string.Hand_out);
                mIvUserSmall.setVisibility(View.VISIBLE);
                mPbHangout.setProgressDrawable(ContextCompat.getDrawable(context, R.drawable.pb_orange_bg));
            } else {
                mTvHangout.setText(R.string.Chat_now);
                mIvUserSmall.setVisibility(View.GONE);
                mPbHangout.setProgressDrawable(ContextCompat.getDrawable(context, R.drawable.pb_green_bg));
            }

            int iconResId =  R.drawable.ic_default_photo_woman_rect;    // R.drawable.female_default_profile_photo_40dp
            mIvUserBig.setImageResource(iconResId);
            mIvUserSmall.setImageResource(iconResId);
            if(!TextUtils.isEmpty(data.anchorPhotoUrl)) {
                PicassoLoadUtil.loadUrl(mIvUserBig, data.anchorPhotoUrl, iconResId, context.getResources().getDimensionPixelSize(R.dimen.live_size_50dp), context.getResources().getDimensionPixelSize(R.dimen.live_size_50dp));
            }
            if(!TextUtils.isEmpty(data.anchorFriendPhotoUrl)) {
                PicassoLoadUtil.loadUrl(mIvUserSmall, data.anchorFriendPhotoUrl, iconResId, context.getResources().getDimensionPixelSize(R.dimen.live_size_30dp), context.getResources().getDimensionPixelSize(R.dimen.live_size_30dp));
            }
        }

        public void changeHangoutProgress(int progress) {
            if (progress < 0) {
                progress = 0;
            }
            mPbHangout.setProgress(progress);
        }

        public int getProgress() {
            return mPbHangout.getProgress();
        }
    }
}
