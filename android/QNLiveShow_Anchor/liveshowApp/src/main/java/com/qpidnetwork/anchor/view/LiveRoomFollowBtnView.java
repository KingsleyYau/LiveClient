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

/**
 * Created by harry on 2017/8/29.
 *
 * 参考: http://blog.csdn.net/u013831257/article/details/51281136
 * http://www.jianshu.com/p/55c721887568
 */

public class LiveRoomFollowBtnView extends View {

    private Paint mPaint;
    private Path mPath;
    private int followBgColor = Color.GREEN;
    private int followColor = Color.BLACK;
    private int circleR = 0;
    private int followPlusHeight = 0;

    public LiveRoomFollowBtnView(Context context, AttributeSet attrs) {
        super(context, attrs);
        initAttrs(context,attrs);
        mPath = new Path();
        mPaint = new Paint();
        mPaint.setStyle(Paint.Style.FILL_AND_STROKE);
        mPaint.setAntiAlias(true);
    }

    private void initAttrs(Context context, AttributeSet attrs){
        DisplayMetrics dm = getResources().getDisplayMetrics();
        circleR = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, circleR, dm);
        followPlusHeight = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, followPlusHeight, dm);

        TypedArray a = context.obtainStyledAttributes(attrs, R.styleable.LiveRoomFollowBtnView);
        followBgColor = a.getColor(R.styleable.LiveRoomFollowBtnView_followBgColor, followBgColor);
        followColor = a.getColor(R.styleable.LiveRoomFollowBtnView_followColor, followColor);
        circleR = a.getDimensionPixelSize(R.styleable.LiveRoomFollowBtnView_circleR, circleR);
        followPlusHeight = a.getDimensionPixelSize(R.styleable.LiveRoomFollowBtnView_followPlusHeight, followPlusHeight);
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);

        drawFollowBitmap(canvas);
    }

    private void drawFollowBitmap(Canvas canvas){
        mPath.reset();
        mPaint.setColor(followBgColor);
        int rX = getWidth()/2;
        int rY = getHeight()/2;
        mPath.moveTo(rX,rY);
        mPath.addCircle(rX,rY,circleR, Path.Direction.CCW);
        canvas.drawPath(mPath,mPaint);
        mPath.reset();
        mPaint.setColor(followColor);
//        mPath.moveTo(rX,rY-followPlusHeight/2);
//        mPath.lineTo(rX,rY+followPlusHeight/2);
//        mPath.close();
        mPath.addRect(new RectF(rX-followPlusHeight/2,rY-1,rX+followPlusHeight/2,rY+1), Path.Direction.CCW);
        canvas.drawPath(mPath,mPaint);
//        mPath.moveTo(rX-followPlusHeight/2,rY);
//        mPath.lineTo(rX+followPlusHeight/2,rY);
//        mPath.close();
        mPath.addRect(new RectF(rX-1,rY-followPlusHeight/2,rX+1,rY+followPlusHeight/2), Path.Direction.CCW);
        canvas.drawPath(mPath,mPaint);

    }
}