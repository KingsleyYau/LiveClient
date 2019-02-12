package com.qpidnetwork.livemodule.view.DotView;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.RectF;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.Gravity;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;


/**
 * Created by mengxn on 17-3-3.
 */
@SuppressLint("AppCompatCustomView")
public class DotView extends TextView {

    private Paint mPaint;
    private int mDotPadding;

    private static final String DEFAULT_OVER_TEXT = "99+";
    private static final int DEFAULT_PADDING = 3;
    private static final String DEFAULT_TEXT = "88";


    public DotView(Context context) {
        super(context);
    }

    public DotView(Context context, AttributeSet attrs) {
        super(context, attrs);

        TypedArray typedArray = context.obtainStyledAttributes(attrs, R.styleable.DotView, 0, 0);
        int color = typedArray.getColor(R.styleable.DotView_dotColor, Color.RED);
        float density = getResources().getDisplayMetrics().density;
        mDotPadding = typedArray.getDimensionPixelSize(R.styleable.DotView_dotPadding, (int) (DEFAULT_PADDING * density));
        typedArray.recycle();

        mPaint = new Paint();
        mPaint.setColor(color);
        mPaint.setAntiAlias(true);

        setPadding(0, 0, 0, 0);
        setGravity(Gravity.CENTER);
    }

    @Override
    protected void onDraw(Canvas canvas) {
        final int radius = getWidth() / 2;
        if (getText().toString().length() > 2) {
            RectF oval3 = new RectF(0, mDotPadding, radius * 2, radius * 2 - mDotPadding);// 设置个新的长方形
            canvas.drawRoundRect(oval3, radius, radius, mPaint);//第二个参数是x半径，第三个参数是y半径
        } else {
            canvas.drawCircle(radius, radius, radius, mPaint);
        }

        super.onDraw(canvas);
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        int width = 0;
        if (getText().length() > 0) {
            width = Math.max(getTextWidth(), getTextHeight());
        }
        width += mDotPadding * 2;
        int newMeasureSpec = MeasureSpec.makeMeasureSpec(width, MeasureSpec.EXACTLY);
        super.onMeasure(newMeasureSpec, newMeasureSpec);
    }

    private int getTextWidth() {
        return (int) getPaint().measureText(getText().toString());
    }

    private int getTextHeight() {
        final Paint.FontMetrics fontMetrics = getPaint().getFontMetrics();
        return (int) (fontMetrics.descent - fontMetrics.ascent);
    }

    @Override
    public void setText(CharSequence text, BufferType type) {
        if (text.length() > 0) {
            final String testStr = text.toString();
            if (!isNumber(testStr) || !isLegalNumber(Integer.valueOf(testStr))) {
                text = DEFAULT_OVER_TEXT;
            }
        }
        super.setText(text, type);
    }

    private boolean isNumber(String text) {
        if (TextUtils.isEmpty(text)) {
            return false;
        }
        return text.matches("\\d+");
    }

    private boolean isLegalNumber(int number) {
        return number >= 0 && number < 100;
    }

    /**
     * 2018/11/19 Hardy
     * 设置 padding 大小，也可以作为设置小红点的宽高大小
     * @param pxSize
     */
    public void setDotPadding(int pxSize){
        mDotPadding = pxSize;
        invalidate();
    }
}
