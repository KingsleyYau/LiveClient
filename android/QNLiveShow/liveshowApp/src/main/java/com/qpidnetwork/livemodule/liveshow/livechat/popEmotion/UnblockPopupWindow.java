package com.qpidnetwork.livemodule.liveshow.livechat.popEmotion;

import android.app.Activity;
import android.content.Context;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.FrameLayout;

import com.qpidnetwork.livemodule.R;

/**
 * 不会阻塞UI线程的类似popupwindow浮窗控件
 * @author Jagger
 * 2017-5-9
 */
public class UnblockPopupWindow {
	private Activity mActivity;
	private PopBgView mPopBgView;
	private ViewGroup mRootView;
	private boolean isShow = false;
	
	public UnblockPopupWindow(Activity activity){
		mActivity = activity;
		
		//创建背景View，为了可以在指定坐标画出弹出框
		mRootView = (ViewGroup)mActivity.findViewById(Window.ID_ANDROID_CONTENT);
		View popView = mRootView.findViewById(R.id.unblockpopupwindow_view);
		if(popView instanceof PopBgView){
			mPopBgView = (PopBgView)popView;
		}else{
			mPopBgView = new PopBgView(mActivity);
			mPopBgView.setId(R.id.unblockpopupwindow_view);
		}
	}
	
	/**
	 * 加入子VIEW
	 * (先清除所有子VIEW,加入新的子VIEW)
	 * @param anchorView	锚控件,就是为了附着它(暂时只会出现在它的上方)
	 * @param contentView	子VIEW
	 * @param topOffset		上偏移
	 * @param leftOffset	左偏移
	 * @return
	 */
	public void show(View anchorView , View contentView, int topOffset , int leftOffset){
		if(!isShow){
			isShow = true;
			mRootView.addView(mPopBgView);
			mPopBgView.removeAllViews();
			
			Rect rect = new Rect();
			anchorView.getGlobalVisibleRect(rect);
			int[] location = new int[2];
			mPopBgView.getLocationOnScreen(location);
			rect.offset(-location[0], -location[1]);
			
			int widthMeasureSpec = View.MeasureSpec.makeMeasureSpec((1 << 30) - 1, View.MeasureSpec.AT_MOST);
			int heightMeasureSpec = View.MeasureSpec.makeMeasureSpec((1 << 30) - 1, View.MeasureSpec.AT_MOST);
			contentView.measure(widthMeasureSpec, heightMeasureSpec);
			
			int topMargin = rect.top - contentView.getMeasuredHeight() - topOffset;//+ ((mAnchorView.getMeasuredHeight() - contentView.getMeasuredHeight())/2) + 1;
			int leftMargin = rect.left + leftOffset;//+ ((mAnchorView.getMeasuredWidth() - contentView.getMeasuredWidth())/2) + 1;
			
//			Log.v("Jagger", "location[1]:" + location[1] + ",location[0]:" + location[0] + ",topMargin:" +  topMargin + ",leftMargin:" + leftMargin);
			
			FrameLayout.LayoutParams lp = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
			lp.topMargin = topMargin;
			lp.leftMargin = leftMargin;
			
			mPopBgView.addView(contentView , lp);
		}
	}
	
	public void dismiss(){
		mPopBgView.removeAllViews();
		mRootView.removeView(mPopBgView);
		isShow = false;
	}
	
	/**
	 * 背景VIEW,为了可以在指定坐标添加子VIEW
	 * @author Jagger
	 * 2017-5-9
	 */
	private class PopBgView extends FrameLayout{
		public PopBgView(Context context){
			this(context , null);
		}
		
		public PopBgView(Context context , AttributeSet attrs){
			this(context , attrs , 0);
		}
		
		public PopBgView(Context context , AttributeSet attrs , int defStyle){
			super(context , attrs , defStyle);
		}
	}
}
