package com.qpidnetwork.livemodule.framework.base;

import android.graphics.Color;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.widget.statusbar.StatusBarUtil;
import com.qpidnetwork.livemodule.view.MaterialAppBar;

/**
 * 添加基础ActionBar
 * @author Hunter 
 * @since 2015.4.24
 */
public class BaseActionBarFragmentActivity extends BaseFragmentActivity{
	
	private LinearLayout llContainer;
	private TextView errorMsg;

	protected View fl_commTitleBar;
	protected ImageView iv_commBack;
	protected TextView tv_commTitle;

	@Override
	protected void onCreate(Bundle arg0) {
		super.onCreate(arg0);
		setContentView(R.layout.activity_live_base_actionbar);
		initView();
	}
	
	private void initView(){
		//状态栏颜色
		StatusBarUtil.setColor(this, Color.parseColor("#5d0e86"),0);

		fl_commTitleBar = findViewById(R.id.view_commTitleBar);
		iv_commBack = (ImageView) findViewById(R.id.iv_commBack);
		iv_commBack.setOnClickListener(this);
		tv_commTitle = (TextView) findViewById(R.id.tv_commTitle);
		llContainer = (LinearLayout)findViewById(R.id.llContainer);
		errorMsg = (TextView)findViewById(R.id.errorMsg);
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
	}

	@Override
	public void onClick(View v) {
		super.onClick(v);
		int i = v.getId();
		if (i == R.id.iv_commBack) {
			finish();
		}
	}
}
