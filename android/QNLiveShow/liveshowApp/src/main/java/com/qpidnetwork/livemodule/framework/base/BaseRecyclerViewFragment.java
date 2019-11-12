package com.qpidnetwork.livemodule.framework.base;

import android.annotation.SuppressLint;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.view.RefreshRecyclerView;
import com.qpidnetwork.livemodule.view.ballRefresh.BallRefreshRecyclerView;
import com.qpidnetwork.qnbridgemodule.util.Log;

/**
 * 带上拉和下拉刷新的RecyclerViewFragment（设置默认无数据显示)
 * 
 * @author Jagger
 * @since 2018.4.23
 */
@SuppressLint("InflateParams")
public class BaseRecyclerViewFragment extends BaseLoadingFragment implements RefreshRecyclerView.OnPullRefreshListener {

	
	public static final int Default_Step = 50;	//默认下拉更多步长
//	private PageBean pageBean = new PageBean(mPageSize);

//	protected RefreshRecyclerView refreshRecyclerView;
	protected BallRefreshRecyclerView refreshRecyclerView;

//	protected FrameLayout fl_baseListContainer;
	protected View fl_baseListContainer;


	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		TAG = BaseRecyclerViewFragment.class.getSimpleName();
		View view = super.onCreateView(inflater, container, savedInstanceState);
		View chileView = inflater.inflate(getRecyclerViewRootViewId(), container, false);

		refreshRecyclerView =  chileView.findViewById(R.id.refreshRecyclerView);
		fl_baseListContainer = chileView.findViewById(R.id.fl_baseListContainer);
		setCustomContent(chileView);
		setRefreshView();

		initView(view);

		return view;
	}


	@Override
	public void onActivityCreated(Bundle savedInstanceState) {
		TAG = this.getClass().getSimpleName();
		super.onActivityCreated(savedInstanceState);

		initData();
	}

	/**
	 * 2019/10/8 Hardy
	 * 获取列表页的内容根 view id
	 * @return
	 */
	protected int getRecyclerViewRootViewId(){
		return R.layout.fragment_live_base_pulltorefreshrecyclerview;
	}

	protected void initView(View view){

	}

	protected void initData(){

	}

	/**
	 * 设置背景颜色
	 * @param colorResId
	 */
	public void setContentBackground(int colorResId){
		if(fl_baseListContainer != null){
			fl_baseListContainer.setBackgroundColor(getResources().getColor(colorResId));
		}
	}

	@Override
	public void onReloadDataInEmptyView() {

	}


	public void setRefreshView() {
		refreshRecyclerView.setOnPullRefreshListener(this);
	}

	
	/*下拉刷新*/
	public void onPullDownToRefresh() {
	}
	
	/*上拉刷新*/
	public void onPullUpToRefresh() {
		Log.d(TAG,"onPullUpToRefresh");
	}
	
	/*刷新成功*/
	public void onRefreshComplete(){
		refreshRecyclerView.onRefreshComplete();
		hideEmptyViewReloadProgress();
	}

	/**
	 * 无更多关闭上拉刷新
	 */
	public void closePullUpRefresh(boolean closePullUp){
		refreshRecyclerView.setCanPullUp(!closePullUp);
	}
	
	/**
	 * 关闭下拉刷新功能
	 */
	public void closePullDownRefresh(){
		refreshRecyclerView.setCanPullDown(false);
	}

	@Override
	public void showLoadingProcess() {
		refreshRecyclerView.showRefreshing();
		super.showLoadingProcess();
	}

	@Override
	public void hideLoadingProcess() {
		refreshRecyclerView.hideRefreshing();
		super.hideLoadingProcess();
	}
}
