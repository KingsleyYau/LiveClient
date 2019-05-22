package com.qpidnetwork.livemodule.view;

import android.content.Context;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v4.widget.SwipeRefreshLayout.OnRefreshListener;
import android.support.v7.widget.RecyclerView;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.LinearLayout;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.takwolf.android.hfrecyclerview.HeaderAndFooterRecyclerView;

/**
 * Created by Jagger on 2018/4/23.
 */
public class RefreshRecyclerView extends LinearLayout implements OnRefreshListener {

	public final static int PAGE_SIZE = 30;

	// View objects
	private FrameLayout frameLayoutRoot;
	private SwipeRefreshLayout swipeRefreshLayout;



	private HeaderAndFooterRecyclerViewEx recyclerView;

	// local objects
	private LinearLayout listFooter;

	// local various
	private boolean is_loading = false;
	private boolean can_pull_up = true;
	private boolean can_pull_down = true;

	// callback
	private OnPullRefreshListener mOnPullRefreshListener;
	private RScrollLister mRScrollLister;

	public RefreshRecyclerView(Context context, AttributeSet attrs) {
		super(context, attrs);
		// TODO Auto-generated constructor stub
		createView();
	}

	private void createView() {

		View v = LayoutInflater.from(getContext()).inflate(
				R.layout.refresh_recyclerview, null);
		frameLayoutRoot = (FrameLayout)v.findViewById(R.id.fl_root);
		swipeRefreshLayout = (SwipeRefreshLayout) v.findViewById(R.id.swipeRefreshLayout);
		recyclerView = (HeaderAndFooterRecyclerViewEx) v.findViewById(R.id.recyclerView);
		this.addView(v);

		//注: recyclerViewList.getFooterContainer() 一定要带, 不然布局不能布满
		listFooter = (LinearLayout) LayoutInflater.from(getContext()).inflate(
				R.layout.item_list_view_footer, recyclerView.getFooterContainer(), false);

		/*隐藏footerview*/
		listFooter.setVisibility(View.GONE);

		recyclerView.addFooterView(listFooter);

		setRefreshView();

	}

	private void setRefreshView() {

		swipeRefreshLayout.setOnRefreshListener(this);

		recyclerView.setHFScrollListener(new HeaderAndFooterRecyclerViewEx.HFScrollListener() {
			@Override
			public void onScrollUp() {
//				android.util.Log.i("Jagger" , "******************onScrollUp");
			}

			@Override
			public void onScrollDown() {
//				android.util.Log.i("Jagger" , "****************onScrollDown");
			}

			@Override
			public void onScrolled(int distanceX, int distanceY) {
//				android.util.Log.i("Jagger" , "onScrolled");
			}

			@Override
			public void onScrollStateChanged(int state) {
//				android.util.Log.i("Jagger" , "onScrollStateChanged");
				if(mRScrollLister != null){
					mRScrollLister.onScrollStateChanged(state);
				}
			}
		});

		recyclerView.setHFRefreshListner(new HeaderAndFooterRecyclerViewEx.HFRefreshListener() {
			@Override
			public void onTopRefreshShow() {
				if(mRScrollLister != null){
					mRScrollLister.onScrollToTop();
				}
			}

			@Override
			public void onBottomMoreShow() {
				if (!can_pull_up)
					return;

				if (is_loading)
					return;

				is_loading = true;
				//上拉更多时，不能下拉刷新
				swipeRefreshLayout.setEnabled(false);
				//显示更多
				listFooter.setVisibility(View.VISIBLE);
				listFooter.setPadding(0, 0, 0, 0);

				if (mOnPullRefreshListener != null) {
					mOnPullRefreshListener.onPullUpToRefresh();
				}
				if(mRScrollLister != null){
					mRScrollLister.onScrollToBottom();
				}
			}
		});

//		recyclerView.addOnScrollListener(new RecyclerView.OnScrollListener() {
//			@Override
//			public void onScrollStateChanged(RecyclerView recyclerView, int newState) {
//				super.onScrollStateChanged(recyclerView, newState);
//
//				if(mRScrollLister != null){
//					mRScrollLister.onScrollStateChanged(newState);
//				}
//
//				if (recyclerView == null)
//					return;
//				if (recyclerView.getAdapter().getItemCount() == 0)
//					return;
//
//				if (newState == SCROLL_STATE_IDLE || newState == SCROLL_STATE_SETTLING) {
//					// 只有LinearLayoutManager才有查找第一个和最后一个可见view位置的方法
//					RecyclerView.LayoutManager layoutManager = recyclerView.getLayoutManager();
//					if (layoutManager instanceof LinearLayoutManager) {
//						LinearLayoutManager linearLayoutManager = (LinearLayoutManager) layoutManager;
//						//当停止滚动时或者惯性滚动时，RecyclerView的最后一个显示的条目：getCount()-1
//						//注意是findLastVisibleItemPosition()而不是getLastVisiblePosition
////						android.util.Log.i("Jagger" , "RefreshRecyclerView addOnScrollListener-->findLastVisibleItemPosition:"
////								+ linearLayoutManager.findLastVisibleItemPosition()
////								+ "findFirstVisibleItemPosition:"
////								+ linearLayoutManager.findFirstVisibleItemPosition()
////						);
//
//						if (linearLayoutManager.findLastVisibleItemPosition() >= recyclerView.getAdapter().getItemCount() - 1) {
////							android.util.Log.i("Jagger" , "**1** can_pull_up:" + can_pull_up + ",is_loading:" + is_loading);
//							if (!can_pull_up)
//								return;
//
//							if (is_loading)
//								return;
//
////							android.util.Log.i("Jagger" , "**2**");
//							is_loading = true;
//							//上拉更多时，不能下拉刷新
//							swipeRefreshLayout.setEnabled(false);
////							swipeLayoutEmpty.setEnabled(false);
//							//显示更多
//							listFooter.setVisibility(View.VISIBLE);
//							listFooter.setPadding(0, 0, 0, 0);
//
//							if (mOnPullRefreshListener != null) {
//								mOnPullRefreshListener.onPullUpToRefresh();
//							}
//							if(mRScrollLister != null){
//								mRScrollLister.onScrollToBottom();
//							}
//						}
//
//						if (linearLayoutManager.findFirstVisibleItemPosition() <= 1){
////							android.util.Log.i("Jagger" , "**3**");
//							if(mRScrollLister != null){
//								mRScrollLister.onScrollToTop();
//							}
//						}
//
//					}
//				}
//
//			}
//
//			@Override
//			public void onScrolled(RecyclerView recyclerView, int dx, int dy) {
//				super.onScrolled(recyclerView, dx, dy);
////				android.util.Log.i("Jagger" , "***2***-->dx:" + dx + ",dy:" + dy);
//			}
//		});

	}

	public void setCanPullDown(boolean b) {
		can_pull_down = b;
		swipeRefreshLayout.setEnabled(b);
	}

	public boolean isCanPullDown() {
		return can_pull_down;
	}

	public void setCanPullUp(boolean b) {
		can_pull_up = b;
	}

	public boolean isCanPullUp() {
		return can_pull_up;
	}

	public void setAdapter(RecyclerView.Adapter adapter) {
		recyclerView.setAdapter(adapter);
	}

	public HeaderAndFooterRecyclerView getRecyclerView() {
		return recyclerView;
	}

	public SwipeRefreshLayout getSwipeRefreshLayout() {
		return swipeRefreshLayout;
	}

	public FrameLayout getRootView() {
		return frameLayoutRoot;
	}

	@Override
	public void onRefresh() {
		// TODO Auto-generated method stub
		if (!can_pull_down)
			return;
		if (is_loading)
			return;
		is_loading = true;
		if (mOnPullRefreshListener != null) {
			mOnPullRefreshListener.onPullDownToRefresh();
		}
	}

	public void onRefreshComplete() {
		swipeRefreshLayout.setRefreshing(false);
//		swipeLayoutEmpty.setRefreshing(false);
		
		listFooter.setVisibility(View.GONE);
		listFooter.setPadding(0, -DisplayUtil.dip2px(getContext(), 72), 0, 0);
		
		is_loading = false;
		if(can_pull_down){
			swipeRefreshLayout.setEnabled(true);
//			swipeLayoutEmpty.setEnabled(true);
		}
			
	}

	public void setOnPullRefreshListener(OnPullRefreshListener listener) {
		this.mOnPullRefreshListener = listener;
	}

	public void setRScrollLister(RScrollLister listener) {
		this.mRScrollLister = listener;
	}

	/**
	 * 刷新事件
	 */
	public interface OnPullRefreshListener {
		/**
		 * 下拉刷新
		 */
		void onPullDownToRefresh();

		/**
		 * 上拉更多
		 */
		void onPullUpToRefresh();
	}

	/**
	 * 滚动事件
	 */
	public interface RScrollLister{
		void onScrollToTop();
		void onScrollToBottom();
		void onScrollStateChanged(int state);
	}
}
