package com.qpidnetwork.livemodule.liveshow.livechat.album;

import android.content.Context;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.View;
import android.widget.ImageView;
import android.widget.RelativeLayout;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.utils.ImageUtil;


/**
 * Chat 聊天
 * 快捷选图发送的 item view
 * Created by Hardy on 2018/12/17.
 */
public class LiveChatAlbumItemView extends RelativeLayout implements View.OnClickListener {

    private View mTvView;
    private View mTvSend;

    private ImageView mIvImage;
    private View mOperaBtnRootView;

    private OnImageOperaListener mOnImageOperaListener;

    private int position;
    private boolean isSelect;
    // 阴影颜色值
    private static final int GRAY = 0xFF666666;

    public LiveChatAlbumItemView(Context context) {
        this(context, null);
    }

    public LiveChatAlbumItemView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public LiveChatAlbumItemView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
    }

    @Override
    protected void onFinishInflate() {
        super.onFinishInflate();

        mOperaBtnRootView = findViewById(R.id.adapter_album_item_live_chat_ll_opera_btn);
        mTvView = findViewById(R.id.adapter_album_item_live_chat_tv_view);
        mTvSend = findViewById(R.id.adapter_album_item_live_chat_tv_send);
        mTvView.setOnClickListener(this);
        mTvSend.setOnClickListener(this);
        mIvImage = findViewById(R.id.ivAlbum);
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        if (id == R.id.adapter_album_item_live_chat_tv_view) {
            if (mOnImageOperaListener != null) {
                mOnImageOperaListener.onView(getImagePathTag(), position);
            }
        } else if (id == R.id.adapter_album_item_live_chat_tv_send) {
            if (mOnImageOperaListener != null) {
                mOnImageOperaListener.onSend(getImagePathTag(), position);
            }
        }
    }

    public void setPosition(int position) {
        this.position = position;
    }

    public void setImagePathTag(String imagePath) {
        mIvImage.setTag(imagePath);
    }

    public void setImageLayoutParam(LayoutParams mItemParam) {
        mIvImage.setLayoutParams(mItemParam);
    }

    public String getImagePathTag() {
        String path = (String) mIvImage.getTag();
        return TextUtils.isEmpty(path) ? "" : path;
    }

    public ImageView getIvImage() {
        return mIvImage;
    }

    public boolean isSelect() {
        return isSelect;
    }

    /**
     * 展示选中图片的样式
     *
     * @param isShow
     */
    public void showImageOperaButton(boolean isShow) {
        this.isSelect = isShow;

        if (isShow) {
            ImageUtil.showImageColorFilter(true, mIvImage, GRAY);
            mOperaBtnRootView.setVisibility(VISIBLE);
        } else {
            ImageUtil.showImageColorFilter(false, mIvImage);
            mOperaBtnRootView.setVisibility(GONE);
        }
    }

    public void setOnImageOperaListener(OnImageOperaListener mOnImageOperaListener) {
        this.mOnImageOperaListener = mOnImageOperaListener;
    }

    public interface OnImageOperaListener {
        /**
         * 预览大图
         */
        void onView(String imagePath, int position);

        /**
         * 直接发送
         */
        void onSend(String imagePath, int position);
    }
}
