package com.qpidnetwork.livemodule.view;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.util.AttributeSet;
import android.view.View;

import com.qpidnetwork.qnbridgemodule.util.Log;

/**
 * 分栏、分页界面所用到的点点点指示
 * 
 * @author Stan Yung
 *
 */
public class DotsView extends View {

	private static final String tag = "DotView";

	private Paint mPaint;
	private float dotRadius = 8.0f;
	private float dotSpace = 30.0f;
	private int dotCount = 3;
	private int currDot = 0; // 选中的dot

	public DotsView(Context context) {
		super(context);
		init();
	}

	public DotsView(Context context, AttributeSet attrs) {
		super(context, attrs);
		init();
	}

	public DotsView(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		init();
	}

	/**
	 * 2019/8/23 Hardy
	 */
	private void init(){
		mPaint = new Paint();
		mPaint.setAntiAlias(true);		// 抗锯齿，圆滑点
	}

	public void setDotRadius(float dotRadius) {
		this.dotRadius = dotRadius;
		invalidate();
	}
	
	public void setDotSpace(float dotSpace) {
		this.dotSpace = dotSpace;
		invalidate();
	}

	public void setDotCount(int dotCount) {
		this.dotCount = dotCount;
		invalidate();
	}

	/**
	 * 选中哪一个点
	 * @param position
	 */
	public void selectDot(int position) {
		currDot = position;
		invalidate();
	}

	@Override
	protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
		setMeasuredDimension(measureWidth(widthMeasureSpec), measureHeight(heightMeasureSpec));
	}

	@Override
	protected void onDraw(Canvas canvas) {
		int width = getMeasuredWidth();
		int height = getMeasuredHeight();
		float left = (width - (dotRadius * 2 * dotCount + dotSpace * (dotCount - 1))) / 2;
		float top = (height - dotRadius * 2) / 2;
		canvas.save();
		for (int i = 0; i < dotCount; i++) {
			// 2019/8/23 Hardy
			if (i == currDot) {
				mPaint.setAlpha(150);
			} else {
				mPaint.setAlpha(50);
			}

			// old
//			if (i == currDot) {
//				mPaint.setAlpha(50);
//			} else {
//				mPaint.setAlpha(150);
//			}
			canvas.drawCircle(left, top + dotRadius, dotRadius, mPaint);
			left += (dotRadius * 2 + dotSpace);
		}
		canvas.restore();
	}

	private int measureWidth(int widthMeasureSpec) {
		int specMode = MeasureSpec.getMode(widthMeasureSpec);
		int specSize = MeasureSpec.getSize(widthMeasureSpec);
		int result = 100;
		if (specMode == MeasureSpec.AT_MOST) {
			Log.d(tag, "measureWidth->AT_MOST");
			result = specSize;
		} else if (specMode == MeasureSpec.EXACTLY) {
			Log.d(tag, "measureWidth->EXACTLY");
			result = specSize;
		}
		return result;
	}

	private int measureHeight(int heightMeasureSpec) {
		int specMode = MeasureSpec.getMode(heightMeasureSpec);
		int specSize = MeasureSpec.getSize(heightMeasureSpec);
		int result = 50;
		if (specMode == MeasureSpec.AT_MOST) {
			Log.d(tag, "measureHeight->AT_MOST");
			result = specSize;
		} else if (specMode == MeasureSpec.EXACTLY) {
			Log.d(tag, "measureHeight->EXACTLY");
			result = specSize;
		}
		return result;
	}

}