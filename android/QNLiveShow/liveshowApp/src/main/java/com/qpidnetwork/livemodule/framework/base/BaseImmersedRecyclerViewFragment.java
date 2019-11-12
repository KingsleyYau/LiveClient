package com.qpidnetwork.livemodule.framework.base;

import android.annotation.SuppressLint;
import android.os.Bundle;
import android.support.annotation.LayoutRes;
import android.support.design.widget.AppBarLayout;
import android.support.design.widget.CoordinatorLayout;
import android.support.v7.widget.Toolbar;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ProgressBar;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.view.ballRefresh.BallRefreshRecyclerView;
import com.qpidnetwork.livemodule.view.EmptyView;
import com.qpidnetwork.livemodule.view.ErrorView;
import com.qpidnetwork.livemodule.view.RefreshRecyclerView;

/**
 * 带上拉和下拉刷新并且带有沉浸式工具栏的RecyclerViewFragment
 * https://blog.csdn.net/u013933720/article/details/78191282
 * https://blog.csdn.net/gyyak46/article/details/53103796
 * @author Jagger
 * @since 2018.6.25
 */
@SuppressLint("InflateParams")
public abstract class BaseImmersedRecyclerViewFragment extends BaseFragment {


	protected static final int Default_Step = 50;	//默认下拉更多步长

	private AppBarLayout appBarLayout;
	protected Toolbar mToolbar;

//	protected RefreshRecyclerView refreshRecyclerView;
	protected BallRefreshRecyclerView refreshRecyclerView;

	protected CoordinatorLayout fl_baseListContainer;
    protected View  viewFoldCustom;
    protected EmptyView mEmptyView;
    protected ErrorView mErrorView;
	private ProgressBar pbLoading;

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		TAG = BaseImmersedRecyclerViewFragment.class.getSimpleName();
		View view = inflater.inflate(R.layout.fragment_live_base_immersed_pulltorefreshrecyclerview,null);
		appBarLayout = (AppBarLayout) view.findViewById(R.id.appBarLayout);
		mToolbar = (Toolbar) view.findViewById(R.id.toolbar);

//		refreshRecyclerView = (RefreshRecyclerView) view.findViewById(R.id.refreshRecyclerView);
		refreshRecyclerView = view.findViewById(R.id.refreshRecyclerView);

		fl_baseListContainer = (CoordinatorLayout) view.findViewById(R.id.cl_baseListContainer);
		mEmptyView = (EmptyView)view.findViewById(R.id.emptyView);
		mErrorView = (ErrorView)view.findViewById(R.id.errorView);
		pbLoading = (ProgressBar)view.findViewById(R.id.pbLoading);
		setRefreshView();
		setCollapsingToolbarLayout();
		setListener();
		initEmptyView();
		initErrorView();
		return view;
	}

	private void setRefreshView() {
		refreshRecyclerView.setOnPullRefreshListener(new RefreshRecyclerView.OnPullRefreshListener() {
			@Override
			public void onPullDownToRefresh() {
				hideErrorViewAndEmptyView();
				onPullDown();
			}

			@Override
			public void onPullUpToRefresh() {
				onPullUp();
			}
		});
	}

	/**
	 * 初始化CollapsingToolbarLayout
	 */
	private void setCollapsingToolbarLayout(){
		setFoldView();
		mToolbar.addView(viewFoldCustom);
		viewFoldCustom.getLayoutParams().width = ViewGroup.LayoutParams.MATCH_PARENT;
		viewFoldCustom.getLayoutParams().height = ViewGroup.LayoutParams.MATCH_PARENT;
		//默认展开
		appBarLayout.setExpanded(true);
	}

	/**
	 * 初始化EmptyView
	 */
	private void initEmptyView(){
		mEmptyView.setOnClickedEventsListener(new EmptyView.OnClickedEventsListener() {
			@Override
			public void onRetry() {
				onReloadDataInEmptyView();
			}

			@Override
			public void onGuide() {
				onGuideInEmptyView();
			}
		});
		mEmptyView.closePullDownRefresh();
	}

	/**
	 * 初始化ErrorView
	 */
	private void initErrorView(){
		mErrorView.setOnClickedEventsListener(new ErrorView.OnClickedEventsListener() {
			@Override
			public void onRetry() {
				onDefaultErrorRetryClick();
			}
		});
	}

	/**
	 * 设置折叠菜单
	 * （给viewFoldCustom赋值)
	 */
	protected abstract void setFoldView();

	/**
	 * 设置背景颜色
	 * @param colorResId
	 */
	public void setContentBackground(int colorResId){
		if(fl_baseListContainer != null){
			fl_baseListContainer.setBackgroundColor(getResources().getColor(colorResId));
		}
	}

	/**
	 * 显示中间的loading
	 */
	protected void showLoadingProcess(){
		pbLoading.setVisibility(View.VISIBLE);
		hideErrorViewAndEmptyView();
	}

	/**
	 * 显示空数据页
	 */
	protected void showEmptyView(){
		refreshRecyclerView.getRecyclerView().setEmptyView(mEmptyView);
		refreshRecyclerView.getRecyclerView().getAdapter().notifyDataSetChanged();
	}

	/**
	 * 显示错误页
	 */
	protected void showErrorView(){
		refreshRecyclerView.getRecyclerView().setEmptyView(mErrorView);
		refreshRecyclerView.getRecyclerView().getAdapter().notifyDataSetChanged();
	}

	private void hideErrorViewAndEmptyView(){
		if(refreshRecyclerView.getRecyclerView().getEmptyView() != null){
			refreshRecyclerView.getRecyclerView().getEmptyView().setVisibility(View.GONE);
		}
	}

	/**
	 * 空数据页--reload
	 */
	protected void onReloadDataInEmptyView() {
		hideErrorViewAndEmptyView();
		pbLoading.setVisibility(View.VISIBLE);
	}

	/**
	 * 空数据页--guide
	 */
	protected void onGuideInEmptyView() {
		hideErrorViewAndEmptyView();
		pbLoading.setVisibility(View.VISIBLE);
	}

	/**
	 * 错误页--reload
	 */
	protected void onDefaultErrorRetryClick(){
		hideErrorViewAndEmptyView();
		pbLoading.setVisibility(View.VISIBLE);
	}

	@Override
	public void onActivityCreated(Bundle savedInstanceState) {
		TAG = this.getClass().getSimpleName();
		super.onActivityCreated(savedInstanceState);
	}

	/**
	 * 下拉刷新
	 */
	protected abstract void onPullDown();

	 /**
	 * 上拉更多
	 */
	protected abstract void onPullUp();

	/*刷新成功*/
	public void onRefreshComplete(){
		refreshRecyclerView.onRefreshComplete();
		pbLoading.setVisibility(View.GONE);
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

	public View addHeaderView(@LayoutRes int layoutId){
		View headerView =LayoutInflater.from(getActivity()).inflate(layoutId, refreshRecyclerView.getRecyclerView().getHeaderContainer(), false);
		refreshRecyclerView.getRecyclerView().addHeaderView(headerView);
		//因为有时是加载数据后 再加头，所以加头后刷新一下，才能看到
//			recyclerView.getAdapter().notifyDataSetChanged();
        return headerView;
	}

	/**
	 * 设置监听
	 */
	protected void setListener() {
		appBarLayout.addOnOffsetChangedListener(new AppBarLayout.OnOffsetChangedListener() {
			@Override
			public void onOffsetChanged(AppBarLayout appBarLayout, int verticalOffset) {
				//verticalOffset == 0 : 完全展开
				//Math.abs(verticalOffset) == expansionScrollRange : 完全折叠
				int expansionScrollRange = appBarLayout.getTotalScrollRange();
				float percent = (float)Math.abs(verticalOffset) / expansionScrollRange;

				onAppBarLayoutOffsetChange(expansionScrollRange , percent);
			}
		});

	}

	/**
	 *
	 * @param totalScrollRange
	 * @param scrolledPercent 滑动的百分比(0：完全展开; 1:完全折叠)s
	 */
	protected abstract void onAppBarLayoutOffsetChange(int totalScrollRange , float scrolledPercent);

}
