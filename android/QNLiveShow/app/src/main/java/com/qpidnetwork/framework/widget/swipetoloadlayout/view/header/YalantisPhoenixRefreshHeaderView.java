package com.qpidnetwork.framework.widget.swipetoloadlayout.view.header;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.FrameLayout;
import android.widget.ImageView;

import com.qpidnetwork.framework.widget.swipetoloadlayout.SwipeRefreshTrigger;
import com.qpidnetwork.framework.widget.swipetoloadlayout.SwipeTrigger;
import com.qpidnetwork.framework.widget.swipetoloadlayout.view.drawable.yalantis.BaseRefreshDrawable;
import com.qpidnetwork.framework.widget.swipetoloadlayout.view.drawable.yalantis.SunRefreshDrawable;
import com.qpidnetwork.liveshow.R;
import com.qpidnetwork.utils.DisplayUtil;

/**
 * Created by Aspsine on 2015/11/5.
 */
public class YalantisPhoenixRefreshHeaderView extends FrameLayout implements SwipeTrigger, SwipeRefreshTrigger {

    private ImageView ivRefresh;

    private BaseRefreshDrawable mDrawable;

    private int mTriggerOffset;

    public YalantisPhoenixRefreshHeaderView(Context context) {
        this(context, null);
    }

    public YalantisPhoenixRefreshHeaderView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public YalantisPhoenixRefreshHeaderView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        mTriggerOffset = getResources().getDimensionPixelOffset(R.dimen.refresh_header_height_yalantis);
    }

    @Override
    protected void onFinishInflate() {
        super.onFinishInflate();
        ivRefresh = (ImageView) findViewById(R.id.ivRefresh);
        mDrawable = new SunRefreshDrawable(getContext(), this, mTriggerOffset, DisplayUtil.getScreenWidth(getContext()));
        ivRefresh.setBackgroundDrawable(mDrawable);
    }


    @Override
    public void onRefresh() {
        if (!mDrawable.isRunning()){
            mDrawable.start();
        }
    }

    @Override
    public void onPrepare() {

    }

    private int mOldY = 0;

    @Override
    public void onMove(int y, boolean isComplete, boolean automatic) {
        int delta = y - mOldY;
        mDrawable.offsetTopAndBottom(delta);
        mDrawable.setPercent(y / (float) mTriggerOffset, true);
        mOldY = y;
    }

    @Override
    public void onRelease() {
        if (!mDrawable.isRunning()){
            mDrawable.start();
        }
    }

    @Override
    public void onComplete() {

    }

    @Override
    public void onReset() {
        mDrawable.stop();
    }
}
