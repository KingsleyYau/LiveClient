package com.qpidnetwork.livemodule.view;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.os.Handler;
import android.util.AttributeSet;
import android.view.View;


import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.ImageUtil;

import java.io.File;
import java.util.ArrayList;

public class EmotionPlayer extends View implements ViewSmartHelper.onVisibilityChangedListener {
	
	private static final int MIN_FRAME_SPACE = 1000/6;//1秒钟6帧 
	private ArrayList<String> imgUrls = null;
	private int currentFrame = 0;//当前要画的帧在数组中的位置
	private Bitmap curBitmap = null;//当前要画的Bitmap预加载
	private Context mConetext;
	private boolean isPlaying = false;
	private ViewSmartHelper mViewSmartHelper;
	
	public EmotionPlayer(Context context){
		super(context);
		mConetext = context;
		init();
	}
	
	public EmotionPlayer(Context context, AttributeSet attrs){
		super(context, attrs);
		mConetext = context;
		init();
	}
	
	@Override
	protected void onDraw(Canvas canvas) {
		// TODO Auto-generated method stub
		super.onDraw(canvas);
		synchronized (this) {		
			if(curBitmap != null){
				int width = getMeasuredWidth();
				Matrix matrix = new Matrix();
				matrix.setScale(((float)width)/curBitmap.getWidth(), ((float)width)/curBitmap.getWidth());
				canvas.drawBitmap(curBitmap, matrix, null);
				curBitmap.recycle();
				curBitmap = null;
			}
		}
	}
	
	private Handler mHandler = new Handler();
	
	private Runnable animationTimer = new Runnable(){
		public void run() {
			refreshFrames();
		};
	};
	
	private void refreshFrames(){
		if((imgUrls != null)){
			if(imgUrls.size() > currentFrame + 1){
				//动画未画到最后一帧，继续画
				currentFrame++;	
			}else{
				//动画播放到最后一帧，重头播放
				currentFrame = 0;
			}
			long start = System.currentTimeMillis();
			if(reInvalidate()){
				/*图片无问题，刷新动画成功，不跳帧直接处理下一帧*/
				long timestamp = 0;//保证1秒6帧
				if(System.currentTimeMillis() - start > MIN_FRAME_SPACE){
					timestamp = 0;
				}else{
					timestamp = MIN_FRAME_SPACE - (System.currentTimeMillis() - start);
				}
				mHandler.postDelayed(animationTimer, timestamp);
			}else{
				/*跳帧时，删除改帧*/
				imgUrls.remove(currentFrame);
				if(imgUrls.size() > 0){
					currentFrame--;
				}else{
					imgUrls = null;
				}
				refreshFrames();
			}
		}
	}

	private void init(){
		//可视状态改变监听
		mViewSmartHelper = new ViewSmartHelper(this);
		mViewSmartHelper.setOnVisibilityChangedListener(this);
		//
		currentFrame = 0;
		reInvalidate();
	}
	
	/**
	 * 设置即将播放的动画数组
	 * @param playBigImages
	 */
	public void setImageList(ArrayList<String> playBigImages){
		if(imgUrls == null){
			imgUrls = new ArrayList<String>();
		}else{
			imgUrls.clear();
		}
		this.imgUrls.addAll(playBigImages);
		init();
	}
	
	/**
	 * 播放
	 */
	public void play(){
		if(!isPlaying() && canPlay() && mViewSmartHelper.isViewVisible()){
			isPlaying = true;
			refreshFrames();
		}
	}
	
	/**
	 * 是否正在播放
	 * @return
	 */
	public boolean isPlaying(){
		return isPlaying;
	}
	
	/**
	 * 是否能播放
	 */
	public boolean canPlay(){
		return (imgUrls != null &&(imgUrls.size()>0));
	}
	
	/**
	 * 停止播放
	 */
	public void stop(){
		isPlaying = false;
		mHandler.removeCallbacks(animationTimer);
		currentFrame = 0;
		reInvalidate();
	}
	
	/**
	 * 清空
	 */
	public void clean(){
		isPlaying = false;
		mHandler.removeCallbacks(animationTimer);
		currentFrame = 0;
		if(curBitmap != null){
			curBitmap.recycle();
			curBitmap = null;
		}
	}
	
	private boolean reInvalidate(){
		boolean isInvalidate = false;
		synchronized (this) {
			if((imgUrls != null)&&(imgUrls.size() > currentFrame)){
				File file = new File(imgUrls.get(currentFrame));
				if(file.exists()){
//					curBitmap = BitmapFactory.decodeFile(imgUrls.get(currentFrame));
					curBitmap = ImageUtil.decodeHeightDependedBitmapFromFile(imgUrls.get(currentFrame), DisplayUtil.dip2px(mConetext, 120));
					if(curBitmap != null){
						isInvalidate = true;
						invalidate();
					}
				}
			}
		}
		return isInvalidate;
	}

	@Override
	public void onVisibilityChanged(boolean isVisible) {
		// TODO Auto-generated method stub
		if(isVisible){
			play();
		}else{
			clean();
		}
	}

}
