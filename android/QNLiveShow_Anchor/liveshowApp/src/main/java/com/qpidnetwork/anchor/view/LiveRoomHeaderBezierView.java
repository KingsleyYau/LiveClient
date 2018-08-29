package com.qpidnetwork.anchor.view;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.RectF;
import android.util.AttributeSet;
import android.util.DisplayMetrics;
import android.util.TypedValue;
import android.view.View;

import com.qpidnetwork.anchor.R;

import static com.qpidnetwork.anchor.R.attr.circleR;

/**
 * Created by harry on 2017/8/29.
 *
 * 参考系列文章: https://github.com/GcsSloop/AndroidNote/blob/master/CustomView/Advance/[05]Path_Basic.md
 */

public class LiveRoomHeaderBezierView extends View {

    private Paint mPaint;
    private Paint mPaint2;
    private Paint mPaint1;
    private Path mPath;
    private Path mPath1;
    private Path mPath2;
    private int roomHeaderBgColor = Color.BLUE;
    private int bezierXWidth =0;//in dp
    private int controllX1=0;//in dp
    private int controllY1=0;//in dp
    private int controllX2=0;//in dp
    private int controllY2=0;//in dp
    private boolean useThreeOrderBesselCurve = false;
    private boolean showTestCirclePath = false;
    private boolean fillAndStroke = false;

    public LiveRoomHeaderBezierView(Context context, AttributeSet attrs) {
        super(context, attrs);
        initAttrs(context,attrs);
        mPath = new Path();
        mPath1 = new Path();
        mPath2 = new Path();
        mPaint = new Paint();
        mPaint1 = new Paint();
        mPaint2 = new Paint();
        mPaint.setColor(roomHeaderBgColor);
        mPaint.setStyle(fillAndStroke ? Paint.Style.FILL_AND_STROKE : Paint.Style.STROKE);
        mPaint.setAntiAlias(true);

        mPaint1.setColor(Color.RED);
        mPaint1.setStyle(Paint.Style.STROKE);
        mPaint1.setAntiAlias(true);

        mPaint2.setColor(Color.GREEN);
        mPaint2.setStyle(Paint.Style.STROKE);
        mPaint2.setAntiAlias(true);
    }

    private void initAttrs(Context context, AttributeSet attrs){
        DisplayMetrics dm = getResources().getDisplayMetrics();
        bezierXWidth = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, bezierXWidth, dm);
        controllX1 = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, controllX1, dm);
        controllY1 = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, controllY1, dm);
        controllX2 = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, controllX2, dm);
        controllY2 = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, controllY2, dm);

        TypedArray a = context.obtainStyledAttributes(attrs, R.styleable.LiveRoomHeaderBezierView);
        roomHeaderBgColor = a.getColor(R.styleable.LiveRoomHeaderBezierView_roomHeaderBgColor,
                roomHeaderBgColor);

        bezierXWidth = a.getDimensionPixelSize(R.styleable.LiveRoomHeaderBezierView_bezierXWidth, bezierXWidth);
        controllX1 = a.getDimensionPixelSize(R.styleable.LiveRoomHeaderBezierView_controllX1, controllX1);
        controllY1 = a.getDimensionPixelSize(R.styleable.LiveRoomHeaderBezierView_controllY1, controllY1);
        controllX2 = a.getDimensionPixelSize(R.styleable.LiveRoomHeaderBezierView_controllX2, controllX2);
        controllY2 = a.getDimensionPixelSize(R.styleable.LiveRoomHeaderBezierView_controllY2, controllY2);
        useThreeOrderBesselCurve = a.getBoolean(R.styleable.LiveRoomHeaderBezierView_useThreeOrderBesselCurve,
                useThreeOrderBesselCurve);
        showTestCirclePath = a.getBoolean(R.styleable.LiveRoomHeaderBezierView_showTestCirclePath,
                showTestCirclePath);
        fillAndStroke = a.getBoolean(R.styleable.LiveRoomHeaderBezierView_fillAndStroke,
                fillAndStroke);
    }

    public void setRoomHeaderBgColor(int color){
        this.roomHeaderBgColor = color;
        mPaint.setColor(color);
        invalidate();//请求重绘
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        if(useThreeOrderBesselCurve){
            drawThreeOrderBesselCurve(canvas);
        }else{
            drawArc(canvas);
        }

    }

    private void drawArc(Canvas canvas){
        int circleR = getHeight()/2;
        mPath.reset();
        mPath.moveTo(0,0);
        RectF oval = new RectF(-circleR,0,circleR,circleR*2);
        mPath.arcTo(oval,270,90);
        oval = new RectF(circleR,0,circleR*3,circleR*2);
        mPath.arcTo(oval,180,-90);
        mPath.lineTo(getWidth() ,getHeight());
        mPath.lineTo(getWidth(),0);
        mPath.close();
        canvas.drawPath(mPath,mPaint);

        if(showTestCirclePath){
            mPath1.reset();
            mPath1.moveTo(0,0);
            mPath1.addCircle(0,circleR,circleR, Path.Direction.CW);
            mPath1.close();
            canvas.drawPath(mPath1,mPaint1);

            mPath2.reset();
            mPath2.moveTo(0,0);
            mPath2.addCircle(getHeight(),circleR,circleR, Path.Direction.CW);
            mPath2.close();
            canvas.drawPath(mPath2,mPaint2);
        }
    }

    /**
     * 三阶贝塞尔曲线
     *
     * @param canvas
     */
    private void drawThreeOrderBesselCurve(Canvas canvas){
        mPath.reset();
        mPath.moveTo(0,0);
        mPath.cubicTo(controllX1,controllY1,controllX2,controllY2, bezierXWidth, getHeight());
        mPath.lineTo(getWidth() ,getHeight());
        mPath.lineTo(getWidth(),0);
        mPath.close();
        canvas.drawPath(mPath,mPaint);

        if(showTestCirclePath){
            mPath1.reset();
            mPath1.moveTo(0,0);
            mPath1.addCircle(0,circleR,circleR, Path.Direction.CW);
            mPath1.close();
            canvas.drawPath(mPath1,mPaint1);

            mPath2.reset();
            mPath2.moveTo(0,0);
            mPath2.addCircle(getHeight(),circleR,circleR, Path.Direction.CW);
            mPath2.close();
            canvas.drawPath(mPath2,mPaint2);
        }
    }

    public void reDrawBezier(int bezierXWidth, int controllX1,int controllY1,int controllX2, int controllY2){
        this.bezierXWidth = bezierXWidth;
        this.controllX1 = controllX1;
        this.controllX2 = controllX2;
        this.controllY1 = controllY1;
        this.controllY2 = controllY2;
        invalidate();//请求重绘
    }

    public int getControllX1(){
        return controllX1;
    }

    public int getControllY1(){
        return controllY1;
    }

    public int getControllX2(){
        return controllX2;
    }

    public int getControllY2(){
        return controllY2;
    }

    public int getBezierXWidth(){
        return bezierXWidth;
    }
}