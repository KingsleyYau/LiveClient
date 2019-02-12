/**
 * Author: Martin Shum
 * License Apache 2.0
 * 
 */




package com.qpidnetwork.livemodule.view;

import android.content.Context;
import android.graphics.Canvas;
import android.os.Handler;
import android.os.Message;
import android.util.AttributeSet;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.view.animation.Animation.AnimationListener;
import android.widget.ImageView;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;


public class MovingImageView extends ImageView{
	
	public static enum TranslateMode{
		XTRANSLATE,
		YTRANSLATE
	}
	
	
	private boolean isLayout = false;
	
	public boolean isAutoStopped = false;
	
	
	private onImageMovingEvent callback;
	private Timer timer;
	private TimerTask task;
	
	private int height;
	private int width;
	private float frequency = 10;
	private float duration = 16000;
	private boolean isMeasured = false;
	
	public TranslateMode mode = TranslateMode.XTRANSLATE;
	private float translateOffset = 1.2F; // Scale times 
	private float translateOffsetX = 0.0F;
	private float translateOffsetY = 0.0F;
	
	private ArrayList<Map<String, Object>>  path;  //  float[1]
	private int curPosition = 0;

	public MovingImageView(Context context){
		this(context, null);
	}
	
	public MovingImageView(Context context, AttributeSet attrs) {
		super(context, attrs);
		// TODO Auto-generated constructor stub
	
		this.setScaleType(ScaleType.CENTER_CROP);

	}

	
	public void setTranslateOffset(float offset){
		this.translateOffset = offset;
	}
	
	public void setFrequency(float frequency){
		this.frequency = frequency;
	}
	
	public void setDuration(float duration){
		this.duration = duration;
	}
	
	public void setMode(TranslateMode mode){
		this.mode = mode;
	}
	
	
	@SuppressWarnings({ "rawtypes", "unchecked" })
	private void createPath(){
		
		path = new ArrayList<Map<String, Object>>();
		
		int draw_times = (int)(duration / frequency);
		float each_draw = 1.0f / (float)draw_times;
		float sxOffset = 0.0f;

		for(int i = 0; i < draw_times; i++){
			
			Map map = new HashMap<String, Object>();
			sxOffset += each_draw;
			map.put("x", sxOffset);
			path.add(map);
			
			//Log.v("offset", sxOffset + "");
			
		}
		

	}
	
	public void runAnimate(long delay){
		runAnimate(mode, delay);
	}
	
	public void runAnimate(){
		runAnimate(mode);
	}
	
	
	public void runAnimate(TranslateMode mode){
		runAnimate( mode, 500);
	}
	
	public void runAnimate(TranslateMode mode, long delay){
		if (path == null) createPath();
		if (curPosition >= path.size() - 1) curPosition = 0;
		isAutoStopped = false;
		this.mode = mode;
		
		if (task != null) task.cancel();
		if (timer != null) timer.cancel();
		task = null;
		timer = null;
		
		timer = new Timer();
		task = new TimerTask(){

			@Override
			public void run() {
				// TODO Auto-generated method stub
				handler.sendEmptyMessage(0);
			}
			
		};
		
		timer.schedule(task, delay, (int)frequency);
	}
	
	@SuppressWarnings("rawtypes")
	private void translate(){
		
		if (path == null) return;
		if (path.size() == 0) return;
		if (translateOffsetX == 0) return;
		if (isAutoStopped) return;
		if (curPosition == path.size() - 1) {
			stopAnimate();
			isAutoStopped = true;
			if (callback != null) callback.onAnimationStopped();
			return;
		}
		
		Map map = path.get(curPosition);
		
		float x = (float)map.get("x");
		float offset = 0;
		
		if (x > 1.0f) x = 1.0f;
		
		if (mode.equals(TranslateMode.XTRANSLATE)){
			offset = translateOffsetX * x;
			this.setPadding(0 - (int)offset, 0, 0, 0);
		}else{
			offset = translateOffsetY * x;
			this.setPadding(0, 0 - (int)offset, 0, 0);
		}
		
		
		
		invalidate();
		//Log.v("this", offset + "");
		curPosition ++;

	}
	
	public void stopAnimate(){
		if (task != null) task.cancel();
		if (timer != null) timer.cancel();
		task = null;
		timer = null;
		
	}
	
	Handler handler = new Handler(){
		
		@Override
		public void handleMessage(Message msg){
			super.handleMessage(msg);
			translate();
		}
		
	};
	
	
	
	public void setNextPhoto(final int resourceId){
		
		long duration = 800;
		
		AlphaAnimation alAnimZA = new AlphaAnimation(1.0f, 0.0f);
		final AlphaAnimation alAnimAZ = new AlphaAnimation(0.0f, 1.0f);
		
		alAnimZA.setDuration(duration);
		alAnimZA.setFillEnabled(true);
		alAnimZA.setFillAfter(true);
		
		alAnimAZ.setDuration(duration);
		
		alAnimZA.setAnimationListener(new AnimationListener(){

			@Override
			public void onAnimationEnd(Animation animation) {
				// TODO Auto-generated method stub
				setPadding(0, 0, 0, 0);
				invalidate();
				if (callback != null) callback.onBeforeSetNext();
				setImageResource(resourceId);
				startAnimation(alAnimAZ);
				
			}

			@Override
			public void onAnimationRepeat(Animation animation) {
				// TODO Auto-generated method stub
				
			}

			@Override
			public void onAnimationStart(Animation animation) {
				// TODO Auto-generated method stub
				
			}
			
		});
		
		alAnimAZ.setAnimationListener(new AnimationListener(){

			@Override
			public void onAnimationEnd(Animation animation) {
				// TODO Auto-generated method stub
				
				if (callback != null) callback.onNextPhotoSet();
				
			}

			@Override
			public void onAnimationRepeat(Animation animation) {
				// TODO Auto-generated method stub
				
			}

			@Override
			public void onAnimationStart(Animation animation) {
				// TODO Auto-generated method stub
				
			}
			
		});
		
		this.startAnimation(alAnimZA);
		
		
		
	}
	
	public void setCallback(onImageMovingEvent callback){
		this.callback = callback;
	}
	
	@Override
	public void onDraw(Canvas canvas){
		if (path == null) return;
		super.onDraw(canvas);
		//Log.v("this", this.getPaddingLeft() + "");
	}
	
	
	@Override
	public void onMeasure(int widthMeasureSpec, int heightMeasureSpec){
		super.onMeasure(widthMeasureSpec, heightMeasureSpec);
		

		
		if (!isMeasured){
			
			float orgWidth = MeasureSpec.getSize(widthMeasureSpec);
			float orgHeight = MeasureSpec.getSize(heightMeasureSpec);
			
			width = (int)(orgWidth * translateOffset);
			height = (int)(orgHeight * translateOffset);
			setMeasuredDimension(width, height);
			
			
			translateOffsetX = width - orgWidth;
			translateOffsetY = height - orgHeight;
			
			isMeasured = true;
			
			
		}
		
	}
	
	
	@Override
	public void onLayout(boolean changed, int left, int top, int right, int bottom){
		if (isLayout) return;
		super.onLayout(changed, left, top, right, bottom);
		isLayout = true;
	}
	
	
	
	
	public interface onImageMovingEvent{
		public void onAnimationStopped();
		public void onBeforeSetNext();
		public void onNextPhotoSet();
	}
	
	
	public static class Images{
		
		public int next = 0;
		public int[] images;
		
		public Images(int[] imageResourceIds){
			images = imageResourceIds;
		}
		
		public void moveToFirst(){
			next = 0;
		}
		
		public int getNext(){
			if (next > images.length - 1) next = 0;//throw  new Exception("No more images, please use moveToFirst().");
			int image =  images[next];
			next++;
			return image;
		}
		
		public int getNextPosition(){
			return next;
		}
		
		public int getSize(){
			return images.length;
		}
		
	}


}
