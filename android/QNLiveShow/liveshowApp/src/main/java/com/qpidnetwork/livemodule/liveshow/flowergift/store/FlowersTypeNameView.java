package com.qpidnetwork.livemodule.liveshow.flowergift.store;

import android.content.Context;
import android.support.annotation.DrawableRes;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;

/**
 * Created by Hardy on 2019/10/8.
 * 鲜花礼品的类型名字 view
 */
public class FlowersTypeNameView extends LinearLayout {

    private TextView mTvName;
    private TextView mTvFreeCard;
    private ImageView mIvIcon;

    private View mLineBottom;

    public FlowersTypeNameView(Context context) {
        this(context, null);
    }

    public FlowersTypeNameView(Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public FlowersTypeNameView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(Context context) {

    }

    @Override
    protected void onFinishInflate() {
        super.onFinishInflate();

        mTvName = findViewById(R.id.flowers_type_tv_name);
        mTvFreeCard = findViewById(R.id.flowers_type_tv_free_card);
        mIvIcon = findViewById(R.id.flowers_type_iv_icon);

        mLineBottom = findViewById(R.id.flowers_type_line_bottom);
    }

    public void setName(String name) {
        mTvName.setText(name);
    }

    public void setIcon(@DrawableRes int resId) {
        mIvIcon.setImageResource(resId);
    }

    public void showFreeCard(boolean isShow) {
        mTvFreeCard.setVisibility(isShow ? VISIBLE : GONE);
    }

    public void showIcon(boolean isShow) {
        mIvIcon.setVisibility(isShow ? VISIBLE : GONE);
    }

    public void showLineBottom(boolean isShow) {
        mLineBottom.setVisibility(isShow ? VISIBLE : GONE);
    }
}
