package com.qpidnetwork.livemodule.utils;

import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.text.style.ReplacementSpan;

import java.lang.ref.WeakReference;

/**
 * Created by Jagger on 2018/2/2.
 */

public abstract class DynamicDrawableSpanJ extends ReplacementSpan {
    private static final String TAG = "DynamicDrawableSpanJ";

    /**
     * A constant indicating that the bottom of this span should be aligned
     * with the bottom of the surrounding text, i.e., at the same level as the
     * lowest descender in the text.
     */
    public static final int ALIGN_BOTTOM = 0;

    /**
     * A constant indicating that the bottom of this span should be aligned
     * with the baseline of the surrounding text.
     */
    public static final int ALIGN_BASELINE = 1;

    /**
     * 垂直居中
     */
    public static final int ALIGN_VCENTER = 2;

    protected final int mVerticalAlignment;

    public DynamicDrawableSpanJ() {
        mVerticalAlignment = ALIGN_BOTTOM;
    }

    /**
     * @param verticalAlignment one of {@link #ALIGN_BOTTOM} or {@link #ALIGN_BASELINE}.
     */
    protected DynamicDrawableSpanJ(int verticalAlignment) {
        mVerticalAlignment = verticalAlignment;
    }

    /**
     * Returns the vertical alignment of this span, one of {@link #ALIGN_BOTTOM} or
     * {@link #ALIGN_BASELINE}.
     */
    public int getVerticalAlignment() {
        return mVerticalAlignment;
    }

    /**
     * Your subclass must implement this method to provide the bitmap
     * to be drawn.  The dimensions of the bitmap must be the same
     * from each call to the next.
     */
    public abstract Drawable getDrawable();

    @Override
    public int getSize(Paint paint, CharSequence text,
                       int start, int end,
                       Paint.FontMetricsInt fm) {
        Drawable d = getCachedDrawable();

        if(d == null)
            return 0;

        Rect rect = d.getBounds();

        if (fm != null) {
            fm.ascent = -rect.bottom;
            fm.descent = 0;

            fm.top = fm.ascent;
            fm.bottom = 0;
        }

        return rect.right;
    }

    @Override
    public void draw(Canvas canvas, CharSequence text,
                     int start, int end, float x,
                     int top, int y, int bottom, Paint paint) {
        Drawable b = getCachedDrawable();
        canvas.save();

        //说明:
        //图片初始化位置在画布右上角
        //如果文字换行, bottom会变, 换一次行回调一次
//        Log.i("Jagger" , "bottom:" + bottom + ",b.getBounds().bottom:" + b.getBounds().bottom );

        int transY = bottom - b.getBounds().bottom; //居底

        if (mVerticalAlignment == ALIGN_BASELINE) {
            //paint.getFontMetricsInt()的值都是固定值,就算换行也是一样, 这个是有问题的, 系统的代码也是这样,所以不改动了
            transY -= paint.getFontMetricsInt().descent;
        }else if(mVerticalAlignment == ALIGN_VCENTER){

            //这是自定义的
            float textHeight = paint.getFontMetricsInt().bottom - paint.getFontMetricsInt().top;
            int rowTop = bottom - (int)textHeight;
            int picBottom = rowTop + b.getBounds().height(); //换行后的居底坐标
            int picBottomDis = bottom - picBottom; //换行后与底的距离

//            Log.i("Jagger" , "picBottom:" + picBottom +", picBottomDis:" + picBottomDis);

            transY -= picBottomDis/2; //一定要使用 "-=",代表居底后向上移多少, 因为有多行的情况,所以只能先居底,再向上移,这样才可以保证与议定居同一行
        }

        canvas.translate(x, transY);
        b.draw(canvas);
        canvas.restore();
    }

    private Drawable getCachedDrawable() {
        WeakReference<Drawable> wr = mDrawableRef;
        Drawable d = null;

        if (wr != null)
            d = wr.get();

        if (d == null) {
            d = getDrawable();
            mDrawableRef = new WeakReference<Drawable>(d);
        }

        return d;
    }

    private WeakReference<Drawable> mDrawableRef;
}
