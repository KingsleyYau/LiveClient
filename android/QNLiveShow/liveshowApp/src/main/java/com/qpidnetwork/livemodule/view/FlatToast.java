package com.qpidnetwork.livemodule.view;

import android.app.Activity;
import android.content.Context;
import android.os.Handler;
import android.os.Message;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.LinearLayout.LayoutParams;
import android.widget.PopupWindow;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;


public class FlatToast {
	
	public static String TAG = "FlatToast";

	private boolean isProgreesed = false;
//	private View mParent;
	private PopupWindow mPopupWindow;
	private Context mContext;
	private View mContentView;
	private LinearLayout mLoadingView;
	private LinearLayout mDoneView;
	private LinearLayout mFailedView;
	private MaterialProgressBar mProgress;
	private TextView text1;
	private TextView text2;
	private TextView text3;
	private ToastHanddler handler;
	

	public FlatToast(Context context) {
		mContext = context;
		
		mContentView = LayoutInflater.from(context).inflate(R.layout.view_material_toast_live, null);
		mLoadingView = (LinearLayout)mContentView.findViewById(R.id.progressing);
		mDoneView  = (LinearLayout)mContentView.findViewById(R.id.done);
		mFailedView  = (LinearLayout)mContentView.findViewById(R.id.failed);
		mProgress = (MaterialProgressBar)mContentView.findViewById(R.id.progress);
		text1 = (TextView)mContentView.findViewById(R.id.text1);
		text2 = (TextView)mContentView.findViewById(R.id.text2);
		text3 = (TextView)mContentView.findViewById(R.id.text3);
		
		
		mPopupWindow = new  PopupWindow(mContentView, LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
		handler = new ToastHanddler(mPopupWindow);
	}
	
	public void updateProgress(float precentage){
		if (!isProgreesed) {
			isProgreesed = true;
			mProgress.setPressed(true);
		}
		mProgress.setProgress(precentage);
	}
	
	public void setProgressing(CharSequence text){
		isProgreesed = false;
		mProgress.setPressed(false);
		mLoadingView.setVisibility(View.VISIBLE);
		mFailedView.setVisibility(View.GONE);
		mDoneView.setVisibility(View.GONE);
		text1.setText(text);
	}
	
	public void setDone(CharSequence text){
		mLoadingView.setVisibility(View.GONE);
		mFailedView.setVisibility(View.GONE);
		mDoneView.setVisibility(View.VISIBLE);
		text2.setText(text);
		cancel();
	}
	
	public void setFailed(CharSequence text){
		mLoadingView.setVisibility(View.GONE);
		mFailedView.setVisibility(View.VISIBLE);
		mDoneView.setVisibility(View.GONE);
		text3.setText(text);
		cancel();
	}
	
	public void showFailed(CharSequence text){
		mLoadingView.setVisibility(View.GONE);
		mFailedView.setVisibility(View.VISIBLE);
		mDoneView.setVisibility(View.GONE);
		text3.setText(text);
	}
	
	public boolean isShowing(){
		return mPopupWindow.isShowing();
	}
	
	
	public void show(){
		if (mPopupWindow.isShowing()) return;
		mPopupWindow.showAtLocation(((Activity)mContext).getWindow().getDecorView(), Gravity.CENTER, 0, 0);
	}
	
	public void cancel(){
		handler.sendEmptyMessageDelayed(0, 1000);
	}
	
	public void cancelImmediately(){
		if (isShowing())mPopupWindow.dismiss();
	}
	
	class ToastHanddler extends Handler{
		
		private PopupWindow popup;
		
		public ToastHanddler(PopupWindow pw){
			super();
			popup = pw;
		}
		
		@Override
		public void handleMessage(Message msg){
			try{
				if (isShowing())popup.dismiss();
			}catch(Exception e){};
			
		}
	}
	
	public static  enum StikyToastType{
		PROCESSING,
		DONE,
		FAILED
	}
	
//	public static void showStickToast(Context context, String text, StikyToastType type){
//		View v = LayoutInflater.from(context).inflate(R.layout.view_material_toast, null);
//		LinearLayout processingView = (LinearLayout)v.findViewById(R.id.progressing);
//		LinearLayout doneView = (LinearLayout)v.findViewById(R.id.done);
//		LinearLayout failedView = (LinearLayout)v.findViewById(R.id.failed);
//
//
//		TextView text1 = (TextView)v.findViewById(R.id.text1);
//		TextView text2 = (TextView)v.findViewById(R.id.text2);
//		TextView text3 = (TextView)v.findViewById(R.id.text3);
//
//		if (type == StikyToastType.PROCESSING){
//			processingView.setVisibility(View.VISIBLE);
//			doneView.setVisibility(View.GONE);
//			failedView.setVisibility(View.GONE);
//			text1.setText(text);
//		}
//
//
//		if (type == StikyToastType.DONE){
//			processingView.setVisibility(View.GONE);
//			doneView.setVisibility(View.VISIBLE);
//			failedView.setVisibility(View.GONE);
//			text2.setText(text);
//		}
//
//
//		if (type == StikyToastType.FAILED){
//			processingView.setVisibility(View.GONE);
//			doneView.setVisibility(View.GONE);
//			failedView.setVisibility(View.VISIBLE);
//			text3.setText(text);
//		}
//
//		Toast toast = new Toast(context);
//		toast.setView(v);
//		toast.setDuration(Toast.LENGTH_SHORT);
//		toast.setGravity(Gravity.CENTER, 0, 0);
//		toast.show();
//	}

}
