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

public class LiveRoomHeaderBezierView extends View {

    private Paint mPaint;
    private Path mPath;
    private int roomHeaderBgColor = Color.GREEN;

    public LiveRoomHeaderBezierView(Context context, AttributeSet attrs) {
        super(context, attrs);
        initAttrs(context,attrs);
        mPath = new Path();
        mPaint = new Paint();
        mPaint.setColor(roomHeaderBgColor);
        mPaint.setStyle(Paint.Style.FILL_AND_STROKE);
        mPaint.setAntiAlias(true);
    }

    private void initAttrs(Context context, AttributeSet attrs){
        TypedArray a = context.obtainStyledAttributes(attrs, R.styleable.LiveRoomHeaderBezierView);
        roomHeaderBgColor = a.getColor(R.styleable.LiveRoomHeaderBezierView_roomHeaderBgColor, roomHeaderBgColor);
    }

    public void setRoomHeaderBgColor(int color){
        this.roomHeaderBgColor = color;
        mPaint.setColor(color);
        invalidate();
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        drawTwoOneInFourCircle(canvas);

    }

    /**
     * 绘制两个衔接的1/4圆弧
     * @param canvas
     */
    private void drawTwoOneInFourCircle(Canvas canvas){
        mPath.reset();
        int circleR = getHeight()/2;
        int controllX1 = circleR;
        int controllY1 = 0;
        int controllX2 = controllX1;
        int constrollY2 = getHeight();
        int endX = circleR*2;
        int endY = getHeight();

        mPath.moveTo(0,0);
        mPath.cubicTo(controllX1,controllY1,controllX2,constrollY2,endX,endY);
        mPath.lineTo(getWidth() ,getHeight());
        mPath.lineTo(getWidth(),0);
        mPath.close();
        canvas.drawPath(mPath,mPaint);
    }
}