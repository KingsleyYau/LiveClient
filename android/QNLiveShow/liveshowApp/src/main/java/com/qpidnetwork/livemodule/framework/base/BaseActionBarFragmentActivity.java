package com.qpidnetwork.livemodule.framework.base;

import android.graphics.Color;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.facebook.drawee.backends.pipeline.Fresco;
import com.facebook.drawee.generic.GenericDraweeHierarchy;
import com.facebook.drawee.generic.GenericDraweeHierarchyBuilder;
import com.facebook.drawee.generic.RoundingParams;
import com.facebook.drawee.interfaces.DraweeController;
import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.widget.statusbar.StatusBarUtil;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.view.MaterialAppBar;

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
	protected SimpleDraweeView img_commTitle;

	protected View mBottomDivider;

	@Override
	protected void onCreate(Bundle arg0) {
		super.onCreate(arg0);
		setContentView(R.layout.activity_live_base_actionbar);
		initView();
	}
	
	private void initView(){
		//状态栏颜色
//		StatusBarUtil.setColor(this, Color.parseColor("#5d0e86"),0);

		fl_commTitleBar = findViewById(R.id.view_commTitleBar);
		iv_commBack = (ImageView) findViewById(R.id.iv_commBack);
		iv_commBack.setOnClickListener(this);
		tv_commTitle = (TextView) findViewById(R.id.tv_commTitle);
		tv_commTitle.setTextSize(18);
		tv_commTitle.setOnClickListener(this);
		llContainer = (LinearLayout)findViewById(R.id.llContainer);
		img_commTitle = (SimpleDraweeView)findViewById(R.id.img_commTitle);

		mBottomDivider = (View) findViewById(R.id.bottomDivider);
	}

	protected void setCustomContentView(int layoutResId) {
		LayoutInflater.from(this).inflate(layoutResId, llContainer);
	}

	public MaterialAppBar getCustomActionBar(String title, int txtColor){
		return null;
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

	/**
	 * 设置标题图标
	 * add by Jagger 2018-7-31
	 * @param imageUri
	 * @param isCircle
	 */
	protected void setTitleImage(String imageUri , boolean isCircle){
		if(TextUtils.isEmpty(imageUri)){
			return;
		}

		img_commTitle.setVisibility(View.VISIBLE);
	    if(isCircle){
            //初始化圆角圆形参数对象
            RoundingParams rp = new RoundingParams();
            //设置图像是否为圆形
            rp.setRoundAsCircle(true);
            //设置圆角半径
            rp.setCornersRadius(getResources().getDimensionPixelSize(R.dimen.live_size_30dp));

            //获取GenericDraweeHierarchy对象
            GenericDraweeHierarchy hierarchy = GenericDraweeHierarchyBuilder.newInstance(getResources())
                    //设置圆形圆角参数
                    .setRoundingParams(rp)
                    .setFadeDuration(1000)
                    //构建
                    .build();

            //设置Hierarchy
            img_commTitle.setHierarchy(hierarchy);
        }

        //构建Controller
        DraweeController controller = Fresco.newDraweeControllerBuilder()
                //设置需要下载的图片地址
                .setUri(imageUri)
                //设置点击重试是否开启
                .setTapToRetryEnabled(false)
                //构建
                .build();

        //设置Controller
        img_commTitle.setController(controller);
    }

	protected  void setTitleVisible(int visibility){
		fl_commTitleBar.setVisibility(visibility);
		//解决头部盖在内容上方问题
		RelativeLayout.LayoutParams params = (RelativeLayout.LayoutParams)llContainer.getLayoutParams();
		if(visibility == View.VISIBLE){
			params.topMargin = DisplayUtil.dip2px(this, 56);
		}else{
			params.topMargin = 0;
		}
	}

	/**
	 * 标题文字被点击响应
	 */
	protected void onTitleClicked(){

	}

	@Override
	public void onClick(View v) {
		super.onClick(v);
		int i = v.getId();
		if (i == R.id.iv_commBack) {
			finish();
		}else if (i == R.id.tv_commTitle){
			onTitleClicked();
		}
	}
}
