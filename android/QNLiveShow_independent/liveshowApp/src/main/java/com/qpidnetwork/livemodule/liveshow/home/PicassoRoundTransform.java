package com.qpidnetwork.livemodule.liveshow.home;

import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.Rect;
import android.graphics.RectF;
import android.util.Log;

import com.squareup.picasso.Transformation;

/**
 * Picasso专用，以短边拉伸图片，左上角对齐, 并可裁剪为圆角
 * @author Jagger
 * 2017-7-17
 */
public class PicassoRoundTransform implements Transformation{
	
	private int mTargetWidthPx , mTargetHeightPx;
	private float mRadius = 10f;
	
	/**
	 * 以短边拉伸图片，并裁剪为圆角
	 * @param targetWidthPx	宽px
	 * @param targetHeightPx 高px
	 * @param radius 弧度px
	 */
	public PicassoRoundTransform(int targetWidthPx , int targetHeightPx , float radius){
		mTargetWidthPx = targetWidthPx;
		mTargetHeightPx = targetHeightPx;
		mRadius = radius;
	}

	@Override
	public String key() {
		// TODO Auto-generated method stub
		return "ladies";
	}

	@Override
	public Bitmap transform(Bitmap source) {
		// TODO Auto-generated method stub
		if(source == null || source.getWidth() < 1 || source.getHeight() < 1)
			return null;

		float scale = 1.0f;
		//计算短边拉伸比例
		if (source.getWidth()  > source.getHeight()) {
			scale = mTargetHeightPx / (float) source.getHeight();
		}else if (source.getWidth()  == source.getHeight()) {
			if(mTargetHeightPx > mTargetWidthPx ){
				scale = mTargetHeightPx / (float) source.getHeight();
			}else{
				scale = mTargetWidthPx / (float) source.getWidth();
			}
		}else {
			scale = mTargetWidthPx / (float) source.getWidth();
		}
		
		//缩放原图
		Bitmap newBitmap = null;
		if(scale != 1.0f){
			//当scale==1时,会返回Bitmap src(source),所以不能把它recycle()
			//索性直接newBitmap =	source, 还能提高一点效率
			newBitmap =	Bitmap.createScaledBitmap(source, (int)(source.getWidth()*scale), (int)(source.getHeight()*scale), true);
			source.recycle();
		}else{
			newBitmap =	source;
		}
		
		//新建画布
		Bitmap output =  Bitmap.createBitmap(mTargetWidthPx, mTargetHeightPx, Bitmap.Config.ARGB_8888);
		Canvas canvas = new Canvas(output);
		Rect destRect = new Rect(0, 0, mTargetWidthPx, mTargetHeightPx);
		//画圆角
		Paint paintColor = new Paint();
		paintColor.setFlags(Paint.ANTI_ALIAS_FLAG);
		
		RectF rectF = new RectF(destRect);
		
		canvas.drawRoundRect(rectF, mRadius, mRadius, paintColor);	//弧度
		//裁剪图像
		Paint paintImage = new Paint();
		paintImage.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.SRC_ATOP));
		if(newBitmap != null && !newBitmap.isRecycled()){
			canvas.drawBitmap(newBitmap, destRect, destRect, paintImage);
			newBitmap.recycle();
		}
		newBitmap = null;
		return output;
	}

}
