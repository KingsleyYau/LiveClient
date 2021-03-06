package com.qpidnetwork.anchor.framework.base;

import android.annotation.SuppressLint;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.view.RefreshRecyclerView;

/**
 * 带上拉和下拉刷新的RecyclerViewFragment（设置默认无数据显示)
 * 
 * @author Jagger
 * @since 2018.4.23
 */
@SuppressLint("InflateParams")
public class BaseRecyclerViewFragment extends BaseLoadingFragment implements RefreshRecyclerView.OnPullRefreshListener {

	
//	public static final int Default_Step = 50;	//默认下拉更多步长
//	private PageBean pageBean = new PageBean(mPageSize);
	protected RefreshRecyclerView refreshRecyclerView;
	protected FrameLayout fl_baseListContainer;
	

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		TAG = BaseRecyclerViewFragment.class.getSimpleName();
		View view = super.onCreateView(inflater, container, savedInstanceState);
		View chileView = inflater.inflate(R.layout.fragment_live_base_pulltorefreshrecyclerview,null);
		setCustomContent(chileView);
		refreshRecyclerView = (RefreshRecyclerView) view.findViewById(R.id.refreshRecyclerView);
		fl_baseListContainer = (FrameLayout) view.findViewById(R.id.fl_baseListContainer);
		setRefreshView();

//		fl_baseListContainer = (FrameLayout)chileView.findViewById(R.id.fl_baseListContainer);
		return view;
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

	public void showNodataPage(){
		//临时解决空数据双重展示异常
		if(refreshRecyclerView != null){
			refreshRecyclerView.setEmptyButton(View.GONE, "", R.color.blue_color);
			refreshRecyclerView.setEmptyMessage("");
		}
		super.showNodataPage();
	}

	@Override
	public void onReloadDataInEmptyView() {

	}

	@Override
	public void onActivityCreated(Bundle savedInstanceState) {
		TAG = this.getClass().getSimpleName();
		super.onActivityCreated(savedInstanceState);
	}

	public void setRefreshView() {
		refreshRecyclerView.setOnPullRefreshListener(this);
	}


//	public ListView getPullToRefreshListView() {
//		return refreshRecyclerView.getListView();
//	}

	public void setBgColor(int bgColor){
		if(null != fl_baseListContainer){
			fl_baseListContainer.setBackgroundDrawable(new ColorDrawable(bgColor));
		}
	}

	/**
	 * 设置无数据时提示
	 * 
	 * @param empty
	 */
	public void setEmptyText(String empty) {
		refreshRecyclerView.setEmptyMessage(empty);
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
	 * 无更多关闭下拉刷新
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
	
}
