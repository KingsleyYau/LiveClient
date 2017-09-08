package com.qpidnetwork.livemodule.view;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.util.AttributeSet;
import android.view.View;

import com.qpidnetwork.livemodule.R;

/**
 * Created by harry on 2017/8/29.
 *
 * 参考: http://blog.csdn.net/u013831257/article/details/51281136
 * http://www.jianshu.com/p/55c721887568
 */

public class LiveRoomHostHeaderBgView extends View {

    private Paint mPaint;
    private Path mPath;
    private int hostHeaderBgColor = Color.GREEN;

    public LiveRoomHostHeaderBgView(Context context, AttributeSet attrs) {
        super(context, attrs);
        initAttrs(context,attrs);
        mPath = new Path();
        mPaint = new Paint();
        mPaint.setColor(hostHeaderBgColor);
        mPaint.setStyle(Paint.Style.FILL_AND_STROKE);
        mPaint.setAntiAlias(true);
    }

    private void initAttrs(Context context, AttributeSet attrs){
        TypedArray a = context.obtainStyledAttributes(attrs, R.styleable.LiveRoomHostHeaderBgView);
        hostHeaderBgColor = a.getColor(R.styleable.LiveRoomHostHeaderBgView_hostHeaderBgColor, hostHeaderBgColor);
    }

    public void setColor(int color){
        this.hostHeaderBgColor = color;
        mPaint.setColor(color);
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        drawTwoOneInTwoCircle(canvas);
    }

    /**
     * 绘制两个衔接的1/4圆弧
     * @param canvas
     */
    private void drawTwoOneInTwoCircle(Canvas canvas){
        int circleR = getHeight()/2;
        mPath.setFillType(Path.FillType.WINDING);
        mPath.addCircle(circleR,circleR,circleR, Path.Direction.CCW);
        mPath.addRect(circleR,0,getWidth()-circleR,getHeight(), Path.Direction.CW);
        mPath.addCircle(getWidth()-circleR,circleR,circleR, Path.Direction.CCW);
        mPath.close();
        canvas.drawPath(mPath,mPaint);
    }
}