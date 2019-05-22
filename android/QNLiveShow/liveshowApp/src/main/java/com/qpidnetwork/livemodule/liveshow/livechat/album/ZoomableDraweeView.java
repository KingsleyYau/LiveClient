package com.qpidnetwork.livemodule.liveshow.livechat.album;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.graphics.RectF;
import android.net.Uri;
import android.util.AttributeSet;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.ScaleGestureDetector;

import com.facebook.drawee.view.SimpleDraweeView;

/**
 * Created by Hardy on 2019/5/7.
 * 跟随手势放大和缩小的 SimpleDraweeView
 * 拷贝自：
 * https://blog.csdn.net/loque/article/details/51373116
 */
public class ZoomableDraweeView extends SimpleDraweeView {

    private ScaleGestureDetector mScaleDetector;
    private GestureDetector mGestureDetector;

    private float mCurrentScale = 1f;
    private Matrix mCurrentMatrix;
    private float mMidX;
    private float mMidY;
    private OnClickListener mClickListener;


    public ZoomableDraweeView(Context context) {
        super(context);
        init();
    }

    public ZoomableDraweeView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public ZoomableDraweeView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        init();
    }

    private void init() {
        mCurrentMatrix = new Matrix();

        ScaleGestureDetector.OnScaleGestureListener scaleListener = new ScaleGestureDetector
                .SimpleOnScaleGestureListener() {

            @Override
            public boolean onScale(ScaleGestureDetector detector) {
                float scaleFactor = detector.getScaleFactor();

                mCurrentScale *= scaleFactor;
                if (mMidX == 0f) {
                    mMidX = getWidth() / 2f;
                }
                if (mMidY == 0f) {
                    mMidY = getHeight() / 2f;
                }
                mCurrentMatrix.postScale(scaleFactor, scaleFactor, mMidX, mMidY);
                invalidate();

                return true;
            }

            @Override
            public void onScaleEnd(ScaleGestureDetector detector) {
                super.onScaleEnd(detector);

                if (mCurrentScale < 1f) {
                    reset();
                }
                checkBorder();
            }
        };
        mScaleDetector = new ScaleGestureDetector(getContext(), scaleListener);

        GestureDetector.SimpleOnGestureListener gestureListener = new GestureDetector.SimpleOnGestureListener() {
            @Override
            public boolean onSingleTapConfirmed(MotionEvent e) {
                if (mClickListener != null) {
                    mClickListener.onClick();
                }
                return true;
            }

            @Override
            public boolean onScroll(MotionEvent e1, MotionEvent e2, float distanceX, float distanceY) {
                if (mCurrentScale > 1f) {
                    mCurrentMatrix.postTranslate(-distanceX, -distanceY);
                    invalidate();
                    checkBorder();
                }
                return true;
            }
        };
        mGestureDetector = new GestureDetector(getContext(), gestureListener);
    }

    /**
     * 检查图片边界是否移到view以内
     * 目的是让图片边缘不要移动到view里面
     */
    private void checkBorder() {
        RectF rectF = getDisplayRect(mCurrentMatrix);
        boolean reset = false;
        float dx = 0;
        float dy = 0;

        if (rectF.left > 0) {
            dx = getLeft() - rectF.left;
            reset = true;
        }
        if (rectF.top > 0) {
            dy = getTop() - rectF.top;
            reset = true;
        }
        if (rectF.right < getRight()) {
            dx = getRight() - rectF.right;
            reset = true;
        }
        if (rectF.bottom < getHeight()) {
            dy = getHeight() - rectF.bottom;
            reset = true;
        }
        if (reset) {
            mCurrentMatrix.postTranslate(dx, dy);
            invalidate();
        }
    }

    /**
     * Helper method that maps the supplied Matrix to the current Drawable
     *
     * @param matrix - Matrix to map Drawable against
     * @return RectF - Displayed Rectangle
     */
    private RectF getDisplayRect(Matrix matrix) {
        RectF rectF = new RectF(getLeft(), getTop(), getRight(), getBottom());
        matrix.mapRect(rectF);
        return rectF;
    }

    @Override
    public void setImageURI(Uri uri) {
        reset();
        super.setImageURI(uri);
    }

    @Override
    public void setImageBitmap(Bitmap bm) {
        reset();
        super.setImageBitmap(bm);
    }

    @Override
    protected void onDraw(Canvas canvas) {
        int saveCount = canvas.save();
        canvas.concat(mCurrentMatrix);
        super.onDraw(canvas);
        canvas.restoreToCount(saveCount);
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        mScaleDetector.onTouchEvent(event);
        if (!mScaleDetector.isInProgress()) {
            mGestureDetector.onTouchEvent(event);
        }
        return true;
    }

    /**
     * Resets the zoom of the attached image.
     * This has no effect if the image has been destroyed
     */
    public void reset() {
        mCurrentMatrix.reset();
        mCurrentScale = 1f;
        invalidate();
    }

    public interface OnClickListener {
        void onClick();
    }

    public void setOnClickListener(OnClickListener listener) {
        mClickListener = listener;
    }

}
