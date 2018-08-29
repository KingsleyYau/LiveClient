package com.qpidnetwork.livemodule.view;

import android.graphics.Rect;
import android.os.Build;
import android.view.View;
import android.view.ViewTreeObserver.OnGlobalLayoutListener;
import android.view.ViewTreeObserver.OnScrollChangedListener;
import android.view.ViewTreeObserver.OnWindowAttachListener;

/**
 * 它很聪明，能知道View在界面上是否能被看到
 * @author Jagger
 * 2017-6-22
 */
public class ViewSmartHelper {
	private View mView;
	private onVisibilityChangedListener mOnVisibilityChangedListener;
	private boolean isViewVisible = false;
	
	public ViewSmartHelper(View v){
		mView = v;
		init();
	}
	
	private void init() {
		mView.getViewTreeObserver().addOnScrollChangedListener(new OnScrollChangedListener() {
			
			@Override
			public void onScrollChanged() {
				// TODO Auto-generated method stub
				isViewVisible = isVisible();
				if(mOnVisibilityChangedListener != null){
					mOnVisibilityChangedListener.onVisibilityChanged(isViewVisible);
				}
				
			}
		});
		
		mView.getViewTreeObserver().addOnGlobalLayoutListener(new OnGlobalLayoutListener() {
			
			@Override
			public void onGlobalLayout() {
				// TODO Auto-generated method stub
				isViewVisible = isVisible();
				if(mOnVisibilityChangedListener != null){
					mOnVisibilityChangedListener.onVisibilityChanged(isViewVisible);
				}
				if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
					mView.getViewTreeObserver().removeOnGlobalLayoutListener(this);
				}

			}
		});

		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) {
			mView.getViewTreeObserver().addOnWindowAttachListener(new OnWindowAttachListener() {

                @Override
                public void onWindowDetached() {
                    // TODO Auto-generated method stub
                    isViewVisible = false;
                    if(mOnVisibilityChangedListener != null){
                        mOnVisibilityChangedListener.onVisibilityChanged(false);
                    }
                }

                @Override
                public void onWindowAttached() {
                    // TODO Auto-generated method stub
                }
            });
		}
	} 
	
	public void setOnVisibilityChangedListener(onVisibilityChangedListener l){
		mOnVisibilityChangedListener = l;
	}
	
	/**
	 * 是否被遮住(有一点点被遮也算)
	 * @return
	 */
	private boolean isCover(){
		boolean cover = false;
		
		Rect rect = new Rect();
		cover = mView.getGlobalVisibleRect(rect);
		if(cover){
			if(rect.width() >= mView.getMeasuredWidth() && rect.height() >= mView.getMeasuredHeight()){
				return !cover;
			}
		}
		
		return true;
	}
	
	/**
	 * 是否完全被遮住
	 * @return
	 */
	private boolean isAllCover(){
		boolean cover = false;
		
		Rect rect = new Rect();
		cover = mView.getGlobalVisibleRect(rect);
		if(cover){
			if(rect.width() >= 0 && rect.height() >= 0){
				return !cover;
			}
		}
		
		return true;
	}
	
	/**
	 * 是否可视（有一点点被看到 也算是可视）
	 * @return
	 */
	private boolean isVisible(){
		boolean visible = false;
		
		Rect rect = new Rect();
		visible = mView.getGlobalVisibleRect(rect);
		if(visible){
			if(rect.width() >= 0 && rect.height() >= 0){
				visible = true;
			}
		}
		
		return visible;
	}
	
	/**
	 * 是否可视
	 * @return
	 */
	public boolean isViewVisible() {
		return isViewVisible;
	}
	
	/**
	 * 可视状态改变接口
	 * @author Jagger
	 * 2017-6-22
	 */
	public interface onVisibilityChangedListener{
		void onVisibilityChanged(boolean isVisible);
	}
}
