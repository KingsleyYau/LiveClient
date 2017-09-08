package com.qpidnetwork.livemodule.framework.base;

import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup.LayoutParams;
import android.view.animation.TranslateAnimation;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.view.MaterialAppBar;

/**
 * 添加基础ActionBar
 * @author Hunter 
 * @since 2015.4.24
 */
public class BaseActionBarFragmentActivity extends BaseFragmentActivity{
	
	private LinearLayout llContainer;
	private MaterialAppBar mActionBar;
	private TextView errorMsg;
	
	@Override
	protected void onCreate(Bundle arg0) {
		// TODO Auto-generated method stub
		super.onCreate(arg0);
		setContentView(R.layout.activity_base_actionbar);

		llContainer = (LinearLayout)findViewById(R.id.llContainer);
		mActionBar = (MaterialAppBar)findViewById(R.id.appbar);
		errorMsg = (TextView)findViewById(R.id.errorMsg);

		mActionBar.addButtonToLeft(R.id.common_button_back, "", R.drawable.ic_arrow_back_white_24dp);
//		mActionBar.setAppbarBackgroundColor(getResources().getColor(R.color.theme_actionbar_bg_default));	//Toolbar默认bg颜色
//		mActionBar.setAppbarBackgroundColor(getResources().getColor(WebSiteManager.getInstance().GetWebSite().getSiteColor()));//Toolbar设置为分站颜色
		mActionBar.setOnButtonClickListener(this);
		
//		//add by Jagger 2017-4-28 把状态栏跟Toolbar默认bg颜色设置成一样
//		this.getWindow().setBackgroundDrawable(new ColorDrawable(getResources().getColor(R.color.theme_actionbar_bg_default)));//状态栏默认bg颜色

	}
	
	protected View getBackButton(){
		return mActionBar.getButtonById(R.id.common_button_back);
	}
	
	protected void setCustomContentView(int layoutResId) {
		LayoutInflater.from(this).inflate(layoutResId, llContainer);
	}
	
	protected  void setCustomContentView(View view) {
		LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);
		llContainer.addView(view, params);
	}
	
	public MaterialAppBar getCustomActionBar(){
		return mActionBar;
	}


	public void showErrorMssage(CharSequence msg){
		errorMsg.setText(msg);
		TranslateAnimation animation = new TranslateAnimation(TranslateAnimation.RELATIVE_TO_SELF, 0,
				TranslateAnimation.RELATIVE_TO_SELF, 0,
				TranslateAnimation.RELATIVE_TO_SELF, -2, 
				TranslateAnimation.RELATIVE_TO_SELF, 0);
		animation.setDuration(500);
		errorMsg.startAnimation(animation);
		errorMsg.setVisibility(View.VISIBLE);
	}
	
	public void clearErrorMessage(){
		errorMsg.setVisibility(View.GONE);
	}
	
	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		super.onClick(v);
		switch (v.getId()) {
		case R.id.common_button_back:
			
			finish();
			break;
		}
	}
}
