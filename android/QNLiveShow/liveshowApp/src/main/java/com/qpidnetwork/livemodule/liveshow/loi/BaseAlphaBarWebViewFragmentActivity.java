package com.qpidnetwork.livemodule.liveshow.loi;

import android.os.Build;
import android.os.Bundle;
import android.support.v7.widget.Toolbar;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.framework.widget.ObservableWebView;
import com.qpidnetwork.livemodule.utils.DisplayUtil;

/**
 * 添加基础ActionBar
 * @author Hunter 
 * @since 2015.4.24
 */
public class BaseAlphaBarWebViewFragmentActivity extends BaseFragmentActivity{

	protected View fl_commTitleBar;
	protected ImageView iv_commBack;
	protected TextView tv_commTitle;
	protected View mBottomDivider;
	protected View fl_container;
	protected ObservableWebView owv_content;
	protected Toolbar tb_titleBar;
	protected View bottomDivider;
	protected View view_errorpage;
	protected Button btnRetry;
	protected ProgressBar pb_loading;

	@Override
	protected void onCreate(Bundle arg0) {
		super.onCreate(arg0);
		TAG = BaseAlphaBarWebViewFragmentActivity.class.getSimpleName();
		setContentView(R.layout.activity_webview_toolbar);
		initView();
	}
	
	private void initView(){
		//状态栏颜色
		fl_container = findViewById(R.id.fl_container);
		fl_commTitleBar = findViewById(R.id.fl_commTitleBar);
		iv_commBack = (ImageView) findViewById(R.id.iv_commBack);
		iv_commBack.setOnClickListener(this);
		tv_commTitle = (TextView) findViewById(R.id.tv_commTitle);
		tv_commTitle.setTextSize(18);
		mBottomDivider = (View) findViewById(R.id.bottomDivider);
		owv_content = (ObservableWebView) findViewById(R.id.owv_content);
		tb_titleBar = (Toolbar) findViewById(R.id.tb_titleBar);

		bottomDivider = findViewById(R.id.bottomDivider);
		bottomDivider.setVisibility(View.GONE);
		view_errorpage = findViewById(R.id.view_errorpage);
		view_errorpage.setVisibility(View.GONE);
		btnRetry = (Button) findViewById(R.id.btnRetry);
		btnRetry.setOnClickListener(this);
		pb_loading = (ProgressBar) findViewById(R.id.pb_loading);

	}
	/**
	 * 隐藏标题栏底部分割线
	 */
	public void hideTitleBarBottomDivider(){
		if(mBottomDivider != null){
			mBottomDivider.setVisibility(View.GONE);
		}
	}

	protected void setTitle(String title, int txtColorResId){
		if(!TextUtils.isEmpty(title)){
			tv_commTitle.setText(title);
		}
		tv_commTitle.setTextColor(getResources().getColor(txtColorResId));
	}

	protected  void setTitleVisible(int visibility){
		fl_commTitleBar.setVisibility(visibility);
		//解决头部盖在内容上方问题
//		LinearLayout.LayoutParams params = (LinearLayout.LayoutParams)fl_container.getLayoutParams();
//		if(visibility == View.VISIBLE){
//			params.topMargin = DisplayUtil.dip2px(this, 56);
//		}else{
//			params.topMargin = 0;
//		}
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
