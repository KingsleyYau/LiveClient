package com.qpidnetwork.anchor.view;

import android.content.Context;
import android.util.AttributeSet;
import android.util.Log;
import android.view.MotionEvent;
import android.view.VelocityTracker;
import android.view.View;
import android.view.ViewConfiguration;
import android.view.ViewGroup;
import android.widget.Scroller;

/**
 * Description:仿Launcher中的WorkSapce，可以左右滑动切换屏幕的类
 * 参考:http://blog.csdn.net/chuchu521/article/details/8294450
 * <p>
 * Created by Harry on 2017/6/7.
 */
public class ScrollLayout extends ViewGroup {

    private static final String TAG = ScrollLayout.class.getSimpleName();
    private Scroller mScroller;
    private VelocityTracker mVelocityTracker;

    private int mCurScreen;
    private int mDefaultScreen = 0;

    private static final int TOUCH_STATE_REST = 0;
    private static final int TOUCH_STATE_SCROLLING = 1;

    private static final int SNAP_VELOCITY = 600;

    private int mTouchState = TOUCH_STATE_REST;
    private int mTouchSlop;
    private float mLastMotionX;
    private float mLastMotionY;


    public ScrollLayout(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public ScrollLayout(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        mScroller = new Scroller(context);
        mCurScreen = mDefaultScreen;
        mTouchSlop = ViewConfiguration.get(getContext()).getScaledTouchSlop();
    }

    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {
        Log.d(TAG,"onLayout-changed:"+changed+" l:"+l+" t:"+t+" r:"+r+" b:"+b);
        int childLeft = 0;
        final int childCount = getChildCount();
        for (int i = 0; i < childCount; i++) {
            final View childView = getChildAt(i);
            if (childView.getVisibility() != View.GONE) {
                final int childWidth = childView.getMeasuredWidth();
                Log.d(TAG,"onLayout-childWidth:"+childWidth);
                childView.layout(childLeft, 0, childLeft + childWidth,
                        childView.getMeasuredHeight());
                childLeft += childWidth;
            }
        }
        Log.d(TAG,"onLayout-childCount:"+childCount+" childLeft:"+childLeft);
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        Log.e(TAG, "onMeasure");
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        final int width = MeasureSpec.getSize(widthMeasureSpec);
        final int widthMode = MeasureSpec.getMode(widthMeasureSpec);
        final int heightMode = MeasureSpec.getMode(heightMeasureSpec);
        if(heightMode == MeasureSpec.EXACTLY && widthMode == MeasureSpec.EXACTLY){
            final int count = getChildCount();
            for (int i = 0; i < count; i++) {
                getChildAt(i).measure(widthMeasureSpec, heightMeasureSpec);
            }
            Log.d(TAG,"onMeasure-mCurScreen:"+mCurScreen+" width:"+width);
            scrollTo(mCurScreen * width, 0);
        }else{
            Log.d(TAG,"onMeasure-ScrollLayout only can run at EXACTLY mode!");
        }


    }

    /**
     * According to the position of current layout scroll to the destination
     * page.
     */
    public void snapToDestination() {
        final int screenWidth = getWidth();
        final int destScreen = (getScrollX() + screenWidth / 2) / screenWidth;
        Log.d(TAG,"snapToDestination-screenWidth:"+screenWidth+" destScreen:"+destScreen
                +" ->snapToScreen");
        snapToScreen(destScreen,true);
    }

    /**
     * 滚动到指定屏幕
     * @param whichScreen
     * @param autoCalcTime true-自动根据当前屏幕到指定屏幕间的距离计算滚动时长，false-立即
     */
    public void snapToScreen(int whichScreen, boolean autoCalcTime) {
        Log.d(TAG,"snapToScreen-whichScreen:"+whichScreen);
        whichScreen = Math.max(0, Math.min(whichScreen, getChildCount() - 1));
        if (getScrollX() != (whichScreen * getWidth())) {
            final int delta = whichScreen * getWidth() - getScrollX();
            mScroller.startScroll(getScrollX(), 0, delta, 0,
                    autoCalcTime ? Math.abs(delta) * 2 : 0);
            mCurScreen = whichScreen;
            Log.d(TAG,"snapToScreen-mCurScreen:"+mCurScreen);
            invalidate(); // Redraw the layout
        }
        notifyScreeChanged(mCurScreen);
    }

    public void setToScreen(int whichScreen) {
        whichScreen = Math.max(0, Math.min(whichScreen, getChildCount() - 1));
        mCurScreen = whichScreen;
        Log.d(TAG,"setToScreen-whichScreen:"+whichScreen+" mCurScreen:"+mCurScreen);
        scrollTo(whichScreen * getWidth(), 0);
    }

    @Override
    public void scrollTo(int x, int y) {
        Log.d(TAG,"scrollTo-x:"+x+" y:"+y);
        super.scrollTo(x, y);
    }

    @Override
    protected void onScrollChanged(int l, int t, int oldl, int oldt) {
        Log.d(TAG,"onScrollChanged-l:"+l+" t:"+t+" oldl:"+oldl+" oldt:"+oldt);
        super.onScrollChanged(l, t, oldl, oldt);

    }

    public int getCurScreen() {
        return mCurScreen;
    }

    public void abortScrollAnimation(){
        if(null != mScroller && !mScroller.isFinished()){
            mScroller.abortAnimation();
        }
    }

    @Override
    public void computeScroll() {
        boolean computeScrollOffsets = mScroller.computeScrollOffset();
        Log.d(TAG,"computeScroll-computeScrollOffsets:"+computeScrollOffsets);
        if (computeScrollOffsets) {
            Log.d(TAG,"computeScroll->scrollTo");
            scrollTo(mScroller.getCurrX(), mScroller.getCurrY());
            postInvalidate();
        }
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        if (mVelocityTracker == null) {
            mVelocityTracker = VelocityTracker.obtain();
        }
        mVelocityTracker.addMovement(event);
        final int action = event.getAction();
        final float x = event.getX();
        switch (action) {
            case MotionEvent.ACTION_DOWN:
                Log.d(TAG, "onTouchEvent-ACTION_DOWN");
                abortScrollAnimation();
                mLastMotionX = x;
                break;
            case MotionEvent.ACTION_MOVE:
                int deltaX = (int) (mLastMotionX - x);
                mLastMotionX = x;
                int oldScrollX = getScrollX();
                int nextScrollX = oldScrollX+deltaX;
                if(nextScrollX<0){
                    deltaX = 0;
                }
                if(nextScrollX > (getChildCount() - 1) * getWidth()){
                    deltaX = 0;
                }
                scrollBy(deltaX, 0);
                break;

            case MotionEvent.ACTION_UP:
                Log.e(TAG, "ACTION_UP");
                final VelocityTracker velocityTracker = mVelocityTracker;
                velocityTracker.computeCurrentVelocity(1000);
                int velocityX = (int) velocityTracker.getXVelocity();
                Log.e(TAG, "velocityX:" + velocityX+" SNAP_VELOCITY:"+SNAP_VELOCITY+" mCurScreen:"+mCurScreen);
                if (velocityX > SNAP_VELOCITY && mCurScreen > 0) {
                    // Fling enough to move left
                    Log.d(TAG, "onTouchEvent-ACTION_UP 向左滑动一屏");
                    snapToScreen(mCurScreen - 1,true);
                } else if (velocityX < -SNAP_VELOCITY
                        && mCurScreen < getChildCount() - 1) {
                    // Fling enough to move right
                    Log.d(TAG, "onTouchEvent-ACTION_UP 向右滑动一屏");
                    snapToScreen(mCurScreen + 1,true);
                } else {
                    Log.d(TAG, "onTouchEvent-ACTION_UP 滑动回去");
                    snapToDestination();
                }

                if (mVelocityTracker != null) {
                    mVelocityTracker.recycle();
                    mVelocityTracker = null;
                }
                mTouchState = TOUCH_STATE_REST;
                break;
            case MotionEvent.ACTION_CANCEL:
                mTouchState = TOUCH_STATE_REST;
                break;
        }

        return true;
    }

    @Override
    public boolean onInterceptTouchEvent(MotionEvent ev) {
        Log.e(TAG, "onInterceptTouchEvent-mTouchSlop:" + mTouchSlop);
        final int action = ev.getAction();
        if ((action == MotionEvent.ACTION_MOVE)
                && (mTouchState != TOUCH_STATE_REST)) {
            return true;
        }
        final float x = ev.getX();
        final float y = ev.getY();
        switch (action) {
            case MotionEvent.ACTION_MOVE:
                final int xDiff = (int) Math.abs(mLastMotionX - x);
                if (xDiff > mTouchSlop) {
                    mTouchState = TOUCH_STATE_SCROLLING;
                }
                break;

            case MotionEvent.ACTION_DOWN:
                mLastMotionX = x;
                mLastMotionY = y;
                mTouchState = mScroller.isFinished() ? TOUCH_STATE_REST
                        : TOUCH_STATE_SCROLLING;
                break;

            case MotionEvent.ACTION_CANCEL:
            case MotionEvent.ACTION_UP:
                mTouchState = TOUCH_STATE_REST;
                break;
        }

        return mTouchState != TOUCH_STATE_REST;
    }

    //分页监听
    public interface OnScreenChangeListener {
        void onScreenChange(int currentIndex);
    }

    private OnScreenChangeListener onScreenChangeListener;

    public void setOnScreenChangeListener(
            OnScreenChangeListener onScreenChangeListener) {
        this.onScreenChangeListener = onScreenChangeListener;
    }

    private void notifyScreeChanged(int toScreen){
        Log.d(TAG,"notifyScreeChanged");
        if(null != onScreenChangeListener){
            onScreenChangeListener.onScreenChange(toScreen);
        }
    }
}
