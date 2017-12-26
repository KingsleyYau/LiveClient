package com.qpidnetwork.livemodule.view.DotView;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.RectF;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.view.View;
import android.widget.FrameLayout;

import com.qpidnetwork.livemodule.R;

/**
 * 提示布局
 * Created by mengxn on 2017/8/21.
 */

public class DotLayout extends FrameLayout {

    private Paint mPaint;
    private Paint mTextPaint;
    private int mDotPadding;
    private int mDotLocation;
    private float mTextSize;
    private int mDotOverPadding;
    private int mNumber;
    private boolean isShow;

    private static final String DEFAULT_OVER_TEXT = "99+";
    private static final int DEFAULT_PADDING = 3;
    private static final int DEFAULT_OVER_PADDING = 3;
    private static final String DEFAULT_TEXT = "88";
    private static final int DEFAULT_TEXT_SIZE = 10;

    private static final int LOCATION_LEFT = 0;
    private static final int LOCATION_RIGHT_TOP = 1;
    private static final int LOCATION_RIGHT_BOTTOM = 2;


    public DotLayout(@NonNull Context context) {
        this(context, null);
    }

    public DotLayout(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);

        TypedArray typedArray = context.obtainStyledAttributes(attrs, R.styleable.DotLayout, 0, 0);
        int color = typedArray.getColor(R.styleable.DotLayout_dotColor, Color.RED);
        float density = getResources().getDisplayMetrics().density;
        mDotPadding = typedArray.getDimensionPixelOffset(R.styleable.DotLayout_dotPadding, (int) (DEFAULT_PADDING * density));
        mTextSize = typedArray.getDimensionPixelOffset(R.styleable.DotLayout_dotTextSize, (int) (DEFAULT_TEXT_SIZE * density));
        mDotOverPadding = typedArray.getDimensionPixelOffset(R.styleable.DotLayout_dotOverPadding, (int) (DEFAULT_OVER_PADDING * density));
        mDotLocation = typedArray.getInt(R.styleable.DotLayout_dotLocation, LOCATION_RIGHT_TOP);
        typedArray.recycle();

        mPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        mPaint.setColor(color);
        mPaint.setAntiAlias(true);

        mTextPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        mTextPaint.setColor(Color.WHITE);
        mTextPaint.setTextSize(mTextSize);

        setWillNotDraw(false);

        // 修改padding值以便显示红点
        if (mDotLocation == LOCATION_LEFT) {
            final int padding = mDotOverPadding + mDotPadding * 2;
            if (getPaddingLeft() < padding) {
                setPadding(padding, getPaddingTop(), getPaddingRight(), getPaddingBottom());
            }
        }
        else if (mDotLocation == LOCATION_RIGHT_TOP) {
            if (getPaddingTop() < mDotOverPadding || getPaddingRight() < mDotOverPadding) {
                setPadding(getPaddingLeft(), mDotOverPadding, mDotOverPadding * 2, getPaddingBottom()); //加大右边Padding,为了够位置画99+的圆角模型
            }
        }
        else if (mDotLocation == LOCATION_RIGHT_BOTTOM) {
            if (getPaddingRight() < mDotOverPadding || getPaddingBottom() < mDotOverPadding) {
                setPadding(getPaddingLeft(), getPaddingTop(), mDotOverPadding * 2, mDotOverPadding);
            }
//            if (getPaddingTop() < mDotOverPadding || getPaddingRight() < mDotOverPadding) {
//                setPadding(getPaddingLeft(), mDotOverPadding, mDotOverPadding, getPaddingBottom());
//            }
        }
        else {
            if (getPaddingTop() < mDotOverPadding || getPaddingRight() < mDotOverPadding) {
                setPadding(getPaddingLeft(), mDotOverPadding, mDotOverPadding, getPaddingBottom());
            }
        }

        if (isInEditMode()) {
            isShow = true;
            mNumber = 35;
        }
    }

    @Override
    public void draw(Canvas canvas) {
        super.draw(canvas);

        // draw dot when isShow is true and has child
        if (isShow && getChildCount() > 0) {
            if (mDotLocation == LOCATION_LEFT) {
                drawLeft(canvas);
            }if (mDotLocation == LOCATION_RIGHT_TOP) {
                drawRightTop(canvas);
            }if (mDotLocation == LOCATION_RIGHT_BOTTOM) {
                drawRightBottom(canvas);
            }
            else {
                drawRightTop(canvas);
            }
        }
    }

    /**
     * 只支持点显示，不显示具体数据
     * @param canvas
     */
    private void drawLeft(Canvas canvas) {
        canvas.save();
        final int radius = mDotPadding;
        final View childView = getChildAt(0);
        canvas.translate(childView.getLeft() - radius * 2 - mDotOverPadding, (childView.getTop() + childView.getBottom()) / 2 - radius);
        canvas.drawCircle(radius, radius, radius, mPaint);
        canvas.restore();
    }

    private void drawRightTop(Canvas canvas) {
        canvas.save();
        final View childView = getChildAt(0);

        // 画点
        int radius = getDotRadius();
        canvas.translate(childView.getRight() - radius * 2 + mDotOverPadding, childView.getTop() - mDotOverPadding);
        canvas.drawCircle(radius, radius, radius, mPaint);

        // 如果 mNumber > 0, 将数据画出来
        if (mNumber > 0) {
            String text;
            if (mNumber <= 99) {
                text = String.valueOf(mNumber);
            } else {
                text = DEFAULT_OVER_TEXT;
            }
            final float textWidth = mTextPaint.measureText(text);
            final Paint.FontMetrics fontMetrics = mTextPaint.getFontMetrics();
            final float textHeight = fontMetrics.descent - fontMetrics.ascent;
            final float translateY = radius * 2 - (radius * 2 - textHeight) / 2 - fontMetrics.descent;
            canvas.translate(radius - textWidth / 2, translateY);
            canvas.drawText(text, 0, 0, mTextPaint);
        }

        canvas.restore();
    }

    private void drawRightBottom(Canvas canvas) {
        canvas.save();
        final View childView = getChildAt(0);

        int radius = getDotRadius();

        if (mNumber > 99) {
            int left = childView.getRight() - radius;
            int top = childView.getBottom() - radius;
            canvas.translate(left , top);
            //画圆角矩形
//            RectF oval3 = new RectF(left, top, left + radius , top + radius);// 设置个新的长方形
//            final Paint.FontMetrics fontMetrics = mTextPaint.getFontMetrics();
            float x = 0;//getTextHeight()/2 ;//- fontMetrics.descent;
            float y = getTextHeight()/2 ;
            RectF oval3 = new RectF(x, y ,x + radius * 2  , y + radius);// 设置个新的长方形
            canvas.drawRoundRect(oval3, radius/2, radius/2, mPaint);//第二个参数是x半径，第三个参数是y半径
        }else {
            int left = childView.getRight() - radius;
            int top = childView.getBottom() - radius;
            canvas.translate(left , top);
            // 画点
            canvas.drawCircle(radius, radius, radius, mPaint);
        }

        // 如果 mNumber > 0, 将数据画出来
        if (mNumber > 0) {
            String text;
            if (mNumber <= 99) {
                text = String.valueOf(mNumber);
            } else {
                text = DEFAULT_OVER_TEXT;
            }
            final float textWidth = mTextPaint.measureText(text);
            final Paint.FontMetrics fontMetrics = mTextPaint.getFontMetrics();
            final float textHeight = fontMetrics.descent - fontMetrics.ascent;
            final float translateY = radius * 2 - (radius * 2 - textHeight) / 2 - fontMetrics.descent;
            canvas.translate(radius - textWidth / 2, translateY);
            canvas.drawText(text, 0, 0, mTextPaint);
        }

        canvas.restore();
    }

    // 计算点半径
    private int getDotRadius() {
        int radius = mDotPadding;
        if (mNumber > 0) {
            final float textWidth = mTextPaint.measureText( mNumber > 99 ? DEFAULT_OVER_TEXT : String.valueOf(mNumber));//(DEFAULT_TEXT);
//            final Paint.FontMetrics fontMetrics = mTextPaint.getFontMetrics();
//            final float textHeight = fontMetrics.descent - fontMetrics.ascent;
//            radius += Math.max(textWidth, textHeight) / 2;
            radius += textWidth/2;
        }else {
            final float textWidth = mTextPaint.measureText( "x");//(DEFAULT_TEXT);
            radius += textWidth/2;
        }
        return radius;
    }

    /**
     * 取字高
     * @return
     */
    private float getTextHeight(){
        Paint.FontMetrics fontMetrics = mTextPaint.getFontMetrics();
        float textHeight = fontMetrics.descent - fontMetrics.ascent;
        return textHeight;
    }

    /**
     * 设置显示数据
     *
     * @param number (0,99] 显示具体数据
     *               (-, 0] 只显示点
     *               (99,+) ...
     */
    public void setNumber(int number) {
        mNumber = number;
    }

    /**
     * 是否显示提示
     * @param isShow
     */
    public void show(boolean isShow) {
        show(isShow, 0);
    }

    /**
     * 是否显示提示
     * @param isShow
     * @param number 提示数据 {@link #setNumber(int)}
     */
    public void show(boolean isShow, int number) {
        this.isShow = isShow;
        this.mNumber = isShow ? number : 0;
        postInvalidate();
    }
}
