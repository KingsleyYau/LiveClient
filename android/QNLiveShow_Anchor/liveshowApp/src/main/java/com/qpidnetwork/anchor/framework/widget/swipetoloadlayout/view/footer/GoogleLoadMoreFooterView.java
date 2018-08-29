package com.qpidnetwork.anchor.framework.widget.swipetoloadlayout.view.footer;

import android.content.Context;
import android.content.res.Resources;
import android.util.AttributeSet;
import android.widget.FrameLayout;
import android.widget.ImageView;

import com.qpidnetwork.anchor.framework.widget.swipetoloadlayout.SwipeLoadMoreTrigger;
import com.qpidnetwork.anchor.framework.widget.swipetoloadlayout.SwipeTrigger;
import com.qpidnetwork.anchor.framework.widget.swipetoloadlayout.view.drawable.google.RingProgressDrawable;
import com.qpidnetwork.anchor.R;

/**
 * Created by Aspsine on 2015/11/5.
 */
public class GoogleLoadMoreFooterView extends FrameLayout implements SwipeTrigger, SwipeLoadMoreTrigger {
    private ImageView ivLoadMore;

    private int mTriggerOffset;

    private RingProgressDrawable ringProgressDrawable;
    public GoogleLoadMoreFooterView(Context context) {
        this(context, null);
    }

    public GoogleLoadMoreFooterView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public GoogleLoadMoreFooterView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        ringProgressDrawable = new RingProgressDrawable(context);
        Resources res = getResources();
        ringProgressDrawable.setColors(
                res.getColor(R.color.google_blue),
                res.getColor(R.color.google_red),
                res.getColor(R.color.google_yellow),
                res.getColor(R.color.google_green));
        mTriggerOffset = context.getResources().getDimensionPixelOffset(R.dimen.load_more_trigger_offset_google);
    }

    @Override
    protected void onFinishInflate() {
        super.onFinishInflate();
        ivLoadMore = (ImageView) findViewById(R.id.ivLoadMore);
        ivLoadMore.setBackgroundDrawable(ringProgressDrawable);
    }

    @Override
    public void onLoadMore() {
        ringProgressDrawable.start();
    }

    @Override
    public void onPrepare() {

    }

    @Override
    public void onMove(int y, boolean isComplete, boolean automatic) {
        if (!isComplete){
            ringProgressDrawable.setPercent(-y / (float) mTriggerOffset);
        }
    }

    @Override
    public void onRelease() {

    }

    @Override
    public void onComplete() {
        ringProgressDrawable.stop();
    }

    @Override
    public void onReset() {

    }
}
