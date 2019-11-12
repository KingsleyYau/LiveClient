package com.qpidnetwork.livemodule.view;

import android.content.Context;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.widget.FrameLayout;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;


/**
 * Created by zy2 on 2017/5/19.
 */

public class RedCircleView extends FrameLayout {

    private String showText;

    private TextView mTvCircle;
    private TextView mTvOval;
    private TextView mTvRedCircle;

    public RedCircleView(Context context) {
        this(context, null);
    }

    public RedCircleView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public RedCircleView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        init(context);
    }

    private void init(Context context) {
    }


    @Override
    protected void onFinishInflate() {
        super.onFinishInflate();

        mTvCircle = (TextView) findViewById(R.id.layout_red_circle_tv_circle);
        mTvOval = (TextView) findViewById(R.id.layout_red_circle_tv_oval);
        mTvRedCircle = (TextView) findViewById(R.id.layout_red_circle_tv_red_circle);
        mTvOval.setVisibility(GONE);
        mTvCircle.setVisibility(GONE);
        mTvRedCircle.setVisibility(GONE);
    }

    public void showText(String text) {
        if (getVisibility() == GONE) {
            setVisibility(VISIBLE);
        }

        this.showText = text;
        if (TextUtils.isEmpty(showText)) {
            showText = "";
        }

        if (showText.length() > 0) {
            mTvRedCircle.setVisibility(GONE);
            if (showText.length() == 1) {
                mTvOval.setVisibility(GONE);
                mTvCircle.setVisibility(VISIBLE);
                mTvCircle.setText(showText);
            } else {
                mTvCircle.setVisibility(GONE);
                mTvOval.setVisibility(VISIBLE);
                mTvOval.setText(showText);
            }
        } else {
            mTvOval.setVisibility(GONE);
            mTvCircle.setVisibility(GONE);
            mTvRedCircle.setVisibility(VISIBLE);
        }
    }

    public void showRedCircle() {
        showText(null);
    }

    public void hide() {
        setVisibility(GONE);
    }
}
