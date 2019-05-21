package com.qpidnetwork.livemodule.view;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.content.ContextCompat;
import android.util.AttributeSet;
import android.widget.FrameLayout;
import android.widget.ImageView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.livemodule.utils.PicassoLoadUtil;

/**
 * Created by zy2 on 2019/3/13.
 * 主播头像，选择样式 View
 */
public class HangoutGiftAnchorView extends FrameLayout {

    private CircleImageView mIvAnchor;
    private CircleHaloView mViewHalo;
    private ImageView mIvAnchorMainTag;
    private ImageView mIvAnchorSelect;

    private int colorWhite;
    private int colorGreen;
    private boolean isAnchorSelect;

    public HangoutGiftAnchorView(@NonNull Context context) {
        this(context, null);
    }

    public HangoutGiftAnchorView(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public HangoutGiftAnchorView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(Context context) {
        colorWhite = ContextCompat.getColor(context, R.color.white);
        colorGreen = ContextCompat.getColor(context, R.color.live_ho_green_anchor);
    }

    @Override
    protected void onFinishInflate() {
        super.onFinishInflate();

        mViewHalo = findViewById(R.id.view_ho_gift_anchor_iv_halo);
        mIvAnchor = findViewById(R.id.view_ho_gift_anchor_iv_icon);
        mIvAnchorMainTag = findViewById(R.id.view_ho_gift_anchor_iv_main);
        mIvAnchorSelect = findViewById(R.id.view_ho_gift_anchor_iv_select);

        // 默认不选中
        setSelect(false, false);
    }

    public void setSelect(boolean isSelect, boolean isAnim) {
        isAnchorSelect = isSelect;

        mIvAnchorSelect.setVisibility(isSelect ? VISIBLE : GONE);
        mIvAnchor.setBorderColor(isSelect ? colorGreen : colorWhite);

        mViewHalo.setVisibility(isSelect ? VISIBLE : INVISIBLE);
        if (isAnim) {
            mViewHalo.startAnim();
        }
    }

    public boolean isSelect() {
        return isAnchorSelect;
    }

    public void setAnchorIsMain(boolean isMain) {
        mIvAnchorMainTag.setVisibility(isMain ? VISIBLE : GONE);
    }

    public void setAnchorUrl(String url) {
        PicassoLoadUtil.loadUrl(mIvAnchor, url, R.drawable.ic_default_photo_woman);
    }

    public void show(boolean isShow) {
        this.setVisibility(isShow ? VISIBLE : GONE);
    }

    public boolean isAnchorShow(){
        return this.getVisibility() == VISIBLE;
    }
}
