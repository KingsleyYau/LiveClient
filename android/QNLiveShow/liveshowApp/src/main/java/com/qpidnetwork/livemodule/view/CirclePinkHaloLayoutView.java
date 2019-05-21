package com.qpidnetwork.livemodule.view;

import android.content.Context;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.widget.LinearLayout;

import com.qpidnetwork.livemodule.R;


/**
 * Created by Hardy on 2019/3/7.
 * <p>
 * 在布局中的宽高，一定要给定具体的值，而且宽高一致。
 * 因为这里没做 onMeasure 方法的宽高测量
 * <p>
 * 作为某个展示 View 的底层 View，比展示 View 的宽高多出 10dp，用来显示出光晕
 */
public class CirclePinkHaloLayoutView extends LinearLayout {

    private static final int MAX_MOVE_X = 3;

    private View mBgCircleView;
    private View mCircleHaloView;

    private float mLastX;

    public CirclePinkHaloLayoutView(Context context) {
        this(context, null);
    }

    public CirclePinkHaloLayoutView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public CirclePinkHaloLayoutView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {

    }

    @Override
    protected void onFinishInflate() {
        super.onFinishInflate();

        mCircleHaloView = findViewById(R.id.item_user_info_grid_circle_halo_view);
//        mBgCircleView = findViewById(R.id.item_user_info_grid_circle_view);
    }


    @Override
    public boolean dispatchTouchEvent(MotionEvent ev) {
        switch (ev.getAction()) {
            case MotionEvent.ACTION_DOWN:
                mLastX = ev.getX();
                break;

            case MotionEvent.ACTION_MOVE:
                int dex = (int) (ev.getX() - mLastX);
                dex = Math.abs(dex);

                // 小于默认的滑动距离绝对值，则认为该事件为点击事件
                if (dex < MAX_MOVE_X) {
//                    mBgCircleView.setVisibility(GONE);

                    mCircleHaloView.setVisibility(VISIBLE);
                }
                break;

            case MotionEvent.ACTION_CANCEL:
            case MotionEvent.ACTION_UP:
                mCircleHaloView.setVisibility(INVISIBLE);
//                mBgCircleView.setVisibility(VISIBLE);
                break;
        }

        return super.dispatchTouchEvent(ev);
    }
}
