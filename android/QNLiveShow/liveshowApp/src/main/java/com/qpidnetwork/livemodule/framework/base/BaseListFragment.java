package com.qpidnetwork.livemodule.framework.base;

import android.annotation.SuppressLint;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ListView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.view.MartinBallListView;
import com.qpidnetwork.qnbridgemodule.util.Log;

/**
 * 带上拉和下拉刷新的ListFragment（设置默认无数据显示)
 *
 * @author Hunter
 * @since 2015.5.16
 */
@SuppressLint("InflateParams")
public class BaseListFragment extends BaseLoadingFragment implements MartinBallListView.OnPullRefreshListener {


	public static final int Default_Step = 50;	//默认下拉更多步长

	protected MartinBallListView refreshListview;
	protected FrameLayout fl_baseListContainer;


	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
							 Bundle savedInstanceState) {
		TAG = BaseListFragment.class.getSimpleName();
		View view = super.onCreateView(inflater, container, savedInstanceState);
		View chileView = inflater.inflate(R.layout.fragment_live_base_pulltorefreshlistview,null);

		refreshListview = chileView.findViewById(R.id.refreshListview);
		fl_baseListContainer = chileView.findViewById(R.id.fl_baseListContainer);
		setCustomContent(chileView);
		setRefreshView();
		return view;
	}

	/**
	 * 2018/11/20 Hardy
	 * @param colorResId
	 */
	public void setListViewBackgroundColor(int colorResId){
		refreshListview.setBackgroundColorRes(colorResId);
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

	@Override
	public void onActivityCreated(Bundle savedInstanceState) {
		TAG = this.getClass().getSimpleName();
		super.onActivityCreated(savedInstanceState);
	}

	public void setRefreshView() {
		refreshListview.setOnPullRefreshListener(this);
	}


	public ListView getPullToRefreshListView() {
		return refreshListview.getListView();
	}

	public void setBgColor(int bgColor){
		if(null != fl_baseListContainer){
			fl_baseListContainer.setBackgroundDrawable(new ColorDrawable(bgColor));
		}
	}

//	/**
//	 * 设置无数据时提示
//	 *
//	 * @param empty
//	 */
//	public void setEmptyText(String empty) {
//		refreshListview.setEmptyMessage(empty);
//	}

	/*下拉刷新*/
	public void onPullDownToRefresh() {
		Log.d(TAG,"onPullDownToRefresh");
	}

	/*上拉刷新*/
	public void onPullUpToRefresh() {
		Log.d(TAG,"onPullUpToRefresh");
	}

	/*刷新成功*/
	public void onRefreshComplete(){
		refreshListview.onRefreshComplete();
		hideEmptyViewReloadProgress();
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

	@Override
	public void showLoadingProcess() {
		if (refreshListview != null) {
			refreshListview.showRefreshing();
		}
		super.showLoadingProcess();
	}

	@Override
	public void hideLoadingProcess() {
		if (refreshListview != null) {
			refreshListview.hideRefreshing();
		}
		super.hideLoadingProcess();
	}
}


////////////////////////旧版本/////////////////////////////

//package com.qpidnetwork.livemodule.framework.base;
//
//		import android.annotation.SuppressLint;
//		import android.graphics.drawable.ColorDrawable;
//		import android.os.Bundle;
//		import android.view.LayoutInflater;
//		import android.view.View;
//		import android.view.ViewGroup;
//		import android.widget.FrameLayout;
//		import android.widget.ListView;
//
//		import com.qpidnetwork.livemodule.R;
//		import com.qpidnetwork.livemodule.view.MartinListView;
//		import com.qpidnetwork.livemodule.view.MartinListView.OnPullRefreshListener;
//		import com.qpidnetwork.qnbridgemodule.util.Log;
//
///**
// * 带上拉和下拉刷新的ListFragment（设置默认无数据显示)
// *
// * @author Hunter
// * @since 2015.5.16
// */
//@SuppressLint("InflateParams")
//public class BaseListFragment extends BaseLoadingFragment implements OnPullRefreshListener {
//
//
//	public static final int Default_Step = 50;	//默认下拉更多步长
//	//	private PageBean pageBean = new PageBean(mPageSize);
//	protected MartinListView refreshListview;
//	protected FrameLayout fl_baseListContainer;
//
//
//	@Override
//	public View onCreateView(LayoutInflater inflater, ViewGroup container,
//							 Bundle savedInstanceState) {
//		TAG = BaseListFragment.class.getSimpleName();
//		View view = super.onCreateView(inflater, container, savedInstanceState);
//		View chileView = inflater.inflate(R.layout.fragment_live_base_pulltorefreshlistview,null);
//		setCustomContent(chileView);
//		refreshListview = (MartinListView) view.findViewById(R.id.refreshListview);
//		fl_baseListContainer = (FrameLayout) view.findViewById(R.id.fl_baseListContainer);
//		setRefreshView();
//
//		fl_baseListContainer = (FrameLayout)chileView.findViewById(R.id.fl_baseListContainer);
//		return view;
//	}
//
//	/**
//	 * 2018/11/20 Hardy
//	 * @param colorResId
//	 */
//	public void setListViewBackgroundColor(int colorResId){
//		refreshListview.setBackgroundColorRes(colorResId);
//	}
//
//	/**
//	 * 设置背景颜色
//	 * @param colorResId
//	 */
//	public void setContentBackground(int colorResId){
//		if(fl_baseListContainer != null){
//			fl_baseListContainer.setBackgroundColor(getResources().getColor(colorResId));
//		}
//	}
//
//	@Override
//	public void onReloadDataInEmptyView() {
//
//	}
//
//	@Override
//	public void onActivityCreated(Bundle savedInstanceState) {
//		TAG = this.getClass().getSimpleName();
//		super.onActivityCreated(savedInstanceState);
//	}
//
//	public void setRefreshView() {
//		refreshListview.setOnPullRefreshListener(this);
//	}
//
//
//	public ListView getPullToRefreshListView() {
//		return refreshListview.getListView();
//	}
//
//	public void setBgColor(int bgColor){
//		if(null != fl_baseListContainer){
//			fl_baseListContainer.setBackgroundDrawable(new ColorDrawable(bgColor));
//		}
//	}
//
//	/**
//	 * 设置无数据时提示
//	 *
//	 * @param empty
//	 */
//	public void setEmptyText(String empty) {
//		refreshListview.setEmptyMessage(empty);
//	}
//
//	/*下拉刷新*/
//	public void onPullDownToRefresh() {
//	}
//
//	/*上拉刷新*/
//	public void onPullUpToRefresh() {
//		Log.d(TAG,"onPullUpToRefresh");
//	}
//
//	/*刷新成功*/
//	public void onRefreshComplete(){
//		refreshListview.onRefreshComplete();
//		hideEmptyViewReloadProgress();
//	}
//
//	/**
//	 * 无更多关闭下拉刷新
//	 */
//	public void closePullUpRefresh(boolean closePullUp){
//		refreshListview.setCanPullUp(!closePullUp);
//	}
//
//	/**
//	 * 关闭下拉刷新功能
//	 */
//	public void closePullDownRefresh(){
//		refreshListview.setCanPullDown(false);
//	}
//
//}
