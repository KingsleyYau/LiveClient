package com.qpidnetwork.livemodule.framework.base;

import android.annotation.SuppressLint;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.ListView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.view.ButtonRaised;
import com.qpidnetwork.livemodule.view.MartinListView;
import com.qpidnetwork.livemodule.view.MartinListView.OnPullRefreshListener;
import com.qpidnetwork.livemodule.view.MaterialProgressBar;

/**
 * 带上拉和下拉刷新的ListFragment（设置默认无数据显示)
 * 
 * @author Hunter
 * @since 2015.5.16
 */
@SuppressLint("InflateParams")
public class BaseListFragment extends BaseFragment implements OnPullRefreshListener {

	
	public static final int Default_Step = 20;	//默认下拉更多步长
	public int mPageSize = 30;
//	private PageBean pageBean = new PageBean(mPageSize);
	
	/*第一次初始化特殊加载及错误逻辑处理*/
	private LinearLayout llInitContainer;
	private LinearLayout llEmpty;//数据为空显示
	private MaterialProgressBar pbLoading;
	private View includeError;
	private ButtonRaised btnRetry;

	private MartinListView refreshListview;
	

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		View view = inflater.inflate(R.layout.fragment_base_pulltorefreshlistview, null);
		refreshListview = (MartinListView) view.findViewById(R.id.refreshListview);
		
		llInitContainer = (LinearLayout)view.findViewById(R.id.llInitContainer);
		llEmpty = (LinearLayout) view.findViewById(R.id.llEmpty);
		pbLoading = (MaterialProgressBar) view.findViewById(R.id.pbLoading11);
		pbLoading.setBarColor(getResources().getColor(R.color.blue_color));
		pbLoading.spin();
		// pbLoading.se
		includeError = (View) view.findViewById(R.id.includeError);
//		ivError = (ImageView) view.findViewById(R.id.ivError);
//		tvErrorMsg = (TextView) view.findViewById(R.id.tvErrorMsg);
		btnRetry = (ButtonRaised) view.findViewById(R.id.btnRetry);

		setRefreshView();
		return view;
	}

	@Override
	public void onActivityCreated(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onActivityCreated(savedInstanceState);
		hideLoadingPage();
	}

	public void setRefreshView() {
		refreshListview.setOnPullRefreshListener(this);
	}


	public ListView getPullToRefreshListView() {
		return refreshListview.getListView();
	}

	/**
	 * 设置无数据时提示
	 * 
	 * @param empty
	 */
	public void setEmptyText(String empty) {
		refreshListview.setEmptyMessage(empty);
	}

	/**
	 * 显示初始化无数据提示
	 */
	public void showInitLoading() {
		llInitContainer.setVisibility(View.VISIBLE);
		refreshListview.setVisibility(View.GONE);
		pbLoading.setVisibility(View.VISIBLE);
		includeError.setVisibility(View.GONE);
		llEmpty.setVisibility(View.GONE);
	}

	/**
	 * 初始化出错显示
	 */
	public void showInitError() {
		llInitContainer.setVisibility(View.VISIBLE);
		refreshListview.setVisibility(View.GONE);
		pbLoading.setVisibility(View.GONE);
		includeError.setVisibility(View.VISIBLE);
		llEmpty.setVisibility(View.GONE);
		btnRetry.setOnClickListener(this);
	}
	
	/**
	 * 数据为空显示UI效果
	 */
	public void showInitEmpty(View emptyView){
		refreshListview.setVisibility(View.GONE);
		llInitContainer.setVisibility(View.GONE);
		llEmpty.removeAllViews();
		llEmpty.setVisibility(View.VISIBLE);
		llEmpty.addView(emptyView);
	}
	

	/**
	 * 初始化成功处理
	 */
	public void hideLoadingPage() {
		llInitContainer.setVisibility(View.GONE);
		refreshListview.setVisibility(View.VISIBLE);
		llEmpty.setVisibility(View.GONE);
	}
	
	/*下拉刷新*/
	public void onPullDownToRefresh() {
		// TODO Auto-generated method stub
	}
	
	/*上拉刷新*/
	public void onPullUpToRefresh() {
		// TODO Auto-generated method stub
	}
	
	/*刷新成功*/
	public void onRefreshComplete(){
		refreshListview.onRefreshComplete();
	}

//	protected PageBean getPageBean() {
//		return pageBean;
//	}

	@Override
	public void onClick(View v) {
		// TODO Auto-generated method stub
		super.onClick(v);
		switch (v.getId()) {
		case R.id.btnRetry:
			onInitRetry();
			break;
		}
	}

	public void onInitRetry() {

	}

	/**
	 * 无更多关闭下拉刷新
	 */
	public void closePullUpRefresh(boolean closePullUp){
		refreshListview.setCanPullUp(!closePullUp);
	}
	
	/**
	 * 关闭下拉刷新功能
	 */
	public void closePullDownRefresh(){
		refreshListview.setCanPullDown(false);
	}
	
}
