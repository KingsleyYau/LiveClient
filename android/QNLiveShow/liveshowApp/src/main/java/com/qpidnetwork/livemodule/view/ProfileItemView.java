package com.qpidnetwork.livemodule.view;

import android.content.Context;
import android.graphics.Typeface;
import android.support.annotation.ColorInt;
import android.support.annotation.ColorRes;
import android.support.annotation.DrawableRes;
import android.support.annotation.StringRes;
import android.support.v4.content.ContextCompat;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;

/**
 * Created by Hardy on 2018/9/19.
 * <p>
 * 个人中心——单条 item 的样式 View
 */
public class ProfileItemView extends RelativeLayout {

    private TextView mTvLeft;
    private TextView mTvRight;
    private View mLineView;

    public ProfileItemView(Context context) {
        this(context, null);
    }

    public ProfileItemView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public ProfileItemView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {

    }

    @Override
    protected void onFinishInflate() {
        super.onFinishInflate();

        mTvLeft = (TextView) findViewById(R.id.textViewLeft);
        mTvRight = (TextView) findViewById(R.id.textViewRight);
        mLineView = findViewById(R.id.textViewLine);
    }

    public void setItemHeight(int height) {
        ViewGroup.LayoutParams params = this.getLayoutParams();
        params.height = height;
        this.setLayoutParams(params);
    }

    public void setItemHeightSmall() {
        int height = getResources().getDimensionPixelSize(R.dimen.live_size_48dp);
        setItemHeight(height);
    }

    private void setTextBold(TextView textView, boolean isBold) {
//        mTvRight.getPaint().setFakeBoldText(isBold);      // 无效

//        https://blog.csdn.net/qq_33650812/article/details/76670224
        textView.setTypeface(Typeface.defaultFromStyle(isBold ? Typeface.BOLD : Typeface.NORMAL));
    }

    //==================    left text   ====================

    public void setTextLeft(String val) {
        mTvLeft.setText(val);
    }

    public void setTextLeft(@StringRes int resId) {
        mTvLeft.setText(resId);
    }

    public void setTextLeftBold(boolean isBold) {
        setTextBold(mTvLeft, isBold);
    }

    public void setTextLeftColor(@ColorRes int resId) {
        setTextLeftColorInt(ContextCompat.getColor(getContext(), resId));
    }

    public void setTextLeftColorInt(@ColorInt int color) {
        mTvLeft.setTextColor(color);
    }
    //==================    left text   ====================


    //==================    right text   ====================

    public String getTextRight() {
        return mTvRight.getText().toString().trim();
    }

    public void setTextRight(String val) {
        mTvRight.setText(val);
    }

    public void setTextRight(@StringRes int resId) {
        mTvRight.setText(resId);
    }

    public void setTextRightColor(@ColorRes int resId) {
        setTextRightColorInt(ContextCompat.getColor(getContext(), resId));
    }

    public void setTextRightColorInt(@ColorInt int color) {
        mTvRight.setTextColor(color);
    }

    public void setTextRightBold(boolean isBold) {
        setTextBold(mTvRight, isBold);
    }

    public void setRightIcon(@DrawableRes int resId) {
        mTvRight.setCompoundDrawablesWithIntrinsicBounds(null, null,
                ContextCompat.getDrawable(getContext(), resId), null);
    }

    public void setRightIcon2Arrow() {
        setRightIcon(R.drawable.ic_arrow_right_grey);
    }

    public void setRightIconNull() {
        mTvRight.setCompoundDrawablesWithIntrinsicBounds(null, null, null, null);
    }
    //==================    right text   ====================


    //==================    line   ====================

    public void showBottomLine(boolean isShow) {
        mLineView.setVisibility(isShow ? VISIBLE : GONE);
    }

    public void setBottomLineColor(@ColorRes int resId) {
        mLineView.setBackgroundResource(resId);
    }

    public void setBottomLineLeftMargin(int marginLeft) {
        ((LayoutParams) mLineView.getLayoutParams()).leftMargin += marginLeft;
    }

    public void setBottomLineLeftMarginDefault() {
        setBottomLineLeftMargin(getResources().getDimensionPixelSize(R.dimen.live_size_16dp));
    }
    //==================    line   ====================


}
