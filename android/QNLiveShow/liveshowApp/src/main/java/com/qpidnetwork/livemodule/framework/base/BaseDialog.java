package com.qpidnetwork.livemodule.framework.base;

import android.app.Dialog;
import android.content.Context;
import android.graphics.Color;
import android.graphics.Point;
import android.graphics.drawable.ColorDrawable;
import android.os.Build;
import android.view.Display;
import android.view.Window;
import android.view.WindowManager.LayoutParams;

public class BaseDialog extends Dialog{

	
	private int dialogSize;
	
	
	public BaseDialog(Context context, int theme) {
		super(context, theme);
		// TODO Auto-generated constructor stub
		setupDialogWindow();
		
	}
	
	public BaseDialog(Context context) {
		super(context);
		// TODO Auto-generated constructor stub
		setupDialogWindow();
		
	}
	
	protected int getDialogSize(){
		return dialogSize;
	}
	
	@SuppressWarnings("deprecation")
	private void setupDialogWindow(){
		float density = this.getContext().getResources().getDisplayMetrics().density;
		Display display = this.getWindow().getWindowManager().getDefaultDisplay();
    	Point size = new Point();
    	
    	if (Build.VERSION.SDK_INT > 12){
    		display.getSize(size);
    	}else{
    		size.y = display.getHeight();
    		size.x = display.getWidth();
    	}
    	
    	int width_times =  Math.round((float)size.x / (56.0f * density));
    	float dialog_width = ((float)(width_times - 1) * 56.0f * density);
    	dialogSize = (int)dialog_width;
    	
    	this.getWindow().setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
    	this.getWindow().setLayout(dialogSize, LayoutParams.WRAP_CONTENT);
    	this.getWindow().requestFeature(Window.FEATURE_NO_TITLE);
	}

}
