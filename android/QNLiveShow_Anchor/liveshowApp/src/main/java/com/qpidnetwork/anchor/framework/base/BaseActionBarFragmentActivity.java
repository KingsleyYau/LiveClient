package com.qpidnetwork.anchor.framework.base;

import android.graphics.Color;
import android.os.Bundle;
import android.support.v7.widget.Toolbar;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.framework.widget.statusbar.StatusBarUtil;
import com.qpidnetwork.anchor.utils.DisplayUtil;
import com.qpidnetwork.anchor.utils.Log;
import com.qpidnetwork.anchor.view.MaterialAppBar;

/**
 * 添加基础ActionBar
 * @author Hunter 
 * @since 2015.4.24
 */
public class BaseActionBarFragmentActivity extends BaseFragmentActivity{
	
	private LinearLayout llContainer;

	protected View fl_commTitleBar;
	protected ImageView iv_commBack;
	protected TextView tv_commTitle;
	protected TextView tv_opera;

	private View mBottomDivider;

	@Override
	protected void onCreate(Bundle arg0) {
		super.onCreate(arg0);
		setContentView(R.layout.activity_live_base_actionbar);
		initView();
	}
	
	private void initView(){
		//状态栏颜色
//		StatusBarUtil.setColor(this, Color.parseColor("#5d0e86"),0);

		Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
		//必须要设置这个, 不然左边一边会显示APP名字,而且在app theme中windowActionBar,windowNoTitle都要相应设置
		toolbar.setTitle("");

		fl_commTitleBar = findViewById(R.id.view_commTitleBar);
		iv_commBack = (ImageView) findViewById(R.id.iv_commBack);
		iv_commBack.setOnClickListener(this);
		tv_commTitle = (TextView) findViewById(R.id.tv_commTitle);
		tv_opera = (TextView) findViewById(R.id.tv_opera);
		tv_opera.setOnClickListener(this);
		llContainer = (LinearLayout)findViewById(R.id.llContainer);

		mBottomDivider = (View) findViewById(R.id.viewShadow);

		//启用Toolbar
		setSupportActionBar(toolbar);
	}

	/**
	 * 隐藏标题栏底部阴影
	 */
	public void hideTitleBarBottomDivider(){
		if(mBottomDivider != null){
			mBottomDivider.setVisibility(View.GONE);
		}
	}

	/**
	 * 修改返回键样式
	 * @param resId
	 */
	protected void setBackButtonImg(int resId){
		if(iv_commBack != null){
			iv_commBack.setImageResource(resId);
		}
	}

	protected void setCustomContentView(int layoutResId) {
		LayoutInflater.from(this).inflate(layoutResId, llContainer);
	}

	public MaterialAppBar getCustomActionBar(String title, int txtColor){
		return null;
	}

	protected void setTitle(String title, int txtColor){
		if(!TextUtils.isEmpty(title)){
			tv_commTitle.setText(title);
		}
		tv_commTitle.setTextColor(txtColor);
	}

	protected  void setTitleVisible(int visibility){
		fl_commTitleBar.setVisibility(visibility);
		FrameLayout.LayoutParams params =  (FrameLayout.LayoutParams)llContainer.getLayoutParams();
		if(View.VISIBLE == visibility){
			params.topMargin = DisplayUtil.dip2px(this, getResources().getDimension(R.dimen.actionbar_height));
		}else{
			params.topMargin = 0;
		}
	}

	/**
	 * 设置actionbar右侧的文案
	 * @param opera
	 * @param color
	 */
	protected void setOperaTVTxt(String opera, int color){
		if(TextUtils.isEmpty(opera)){
			tv_opera.setVisibility(View.INVISIBLE);
		}else{
			tv_opera.setVisibility(View.VISIBLE);
			tv_opera.setText(opera);
			tv_opera.setTextColor(color);
		}
	}

	protected void setOperaTVTxtClickable(boolean clickable){
		tv_opera.setClickable(clickable);
		tv_opera.setEnabled(clickable);
	}

	@Override
	public void onClick(View v) {
		super.onClick(v);
		int i = v.getId();
		if (i == R.id.iv_commBack) {
			onTitleBackBtnClick();
			finish();
		}else if(i == R.id.tv_opera){
			onRightTitleBtnClick();
		}
	}

	/**
	 * 标题栏右侧按钮点击事件
	 */
	public void onRightTitleBtnClick(){
		Log.d(TAG,"onRightTitleBtnClick");
	}

	/**
	 * 标题栏 返回前点击事件
	 */
	public void onTitleBackBtnClick(){
		Log.d(TAG,"onTitleBackBtnClick");
	}
}
