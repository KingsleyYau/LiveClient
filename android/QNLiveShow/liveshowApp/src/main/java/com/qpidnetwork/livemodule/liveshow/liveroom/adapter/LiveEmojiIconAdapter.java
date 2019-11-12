package com.qpidnetwork.livemodule.liveshow.liveroom.adapter;

import android.content.Context;
import android.view.View;
import android.widget.ImageView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.EmotionItem;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseRecyclerViewAdapter;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseViewHolder;
import com.qpidnetwork.livemodule.utils.ImageUtil;
import com.qpidnetwork.livemodule.utils.PicassoLoadUtil;
import com.qpidnetwork.livemodule.utils.SystemUtils;
import com.qpidnetwork.qnbridgemodule.datacache.FileCacheManager;

/**
 * Created by Hardy on 2019/9/5.
 * 直播间，新版表情列表的 adapter
 */
public class LiveEmojiIconAdapter extends BaseRecyclerViewAdapter<EmotionItem,
        LiveEmojiIconAdapter.LiveEmojiIconViewHolder> {

    private int emojiIconWH;
    private boolean isAdvancedEmoji;

    public LiveEmojiIconAdapter(Context context, boolean isAdvancedEmoji) {
        super(context);

        this.isAdvancedEmoji = isAdvancedEmoji;

        emojiIconWH = context.getResources().getDimensionPixelSize(R.dimen.live_emoji_item_icon_width);
    }

    public boolean isAdvancedEmoji() {
        return isAdvancedEmoji;
    }

    @Override
    public int getLayoutId(int viewType) {
        return R.layout.item_emoji_tab_icon;
    }

    @Override
    public LiveEmojiIconViewHolder getViewHolder(View itemView, int viewType) {
        return new LiveEmojiIconViewHolder(itemView);
    }

    @Override
    public void initViewHolder(final LiveEmojiIconViewHolder holder) {
        holder.setEmojiIconWH(emojiIconWH);
        holder.setAdvancedEmoji(isAdvancedEmoji);

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
    public void convertViewHolder(LiveEmojiIconViewHolder holder, EmotionItem data, int position) {
        holder.setData(data, position);
    }

    /**
     * ViewHolder
     */
    static class LiveEmojiIconViewHolder extends BaseViewHolder<EmotionItem> {

        private ImageView mIvEmoji;
        private View mBlurView;

        private int emojiIconWH;
        private boolean isAdvancedEmoji;

        public LiveEmojiIconViewHolder(View itemView) {
            super(itemView);
        }

        @Override
        public void bindItemView(View itemView) {
            mIvEmoji = f(R.id.iv_emoji);
            mBlurView = f(R.id.view_blur);
        }

        @Override
        public void setData(EmotionItem data, int position) {
            String localPath = FileCacheManager.getInstance().parseEmotionImgLocalPath(
                    data.emotionId, data.emoIconUrl);

            if (SystemUtils.fileExists(localPath)) {
//                PicassoLoadUtil.loadLocal(mIvEmoji, R.drawable.ic_live_chat_emoji_default, localPath);

                mIvEmoji.setImageBitmap(ImageUtil.decodeSampledBitmapFromFile(localPath,
                        emojiIconWH, emojiIconWH));
            } else {
                PicassoLoadUtil.loadUrl(mIvEmoji, data.emoIconUrl, R.drawable.ic_live_chat_emoji_default);
            }

            // item 变灰白遮罩，不可点效果
            if (isAdvancedEmoji) {
                mBlurView.setVisibility(data.isEmoJiAdvancedCanClick ? View.GONE : View.VISIBLE);
            } else {
                mBlurView.setVisibility(View.GONE);
            }
        }

        public void setEmojiIconWH(int emojiIconWH) {
            this.emojiIconWH = emojiIconWH;
        }

        public void setAdvancedEmoji(boolean advancedEmoji) {
            isAdvancedEmoji = advancedEmoji;
        }
    }
}

