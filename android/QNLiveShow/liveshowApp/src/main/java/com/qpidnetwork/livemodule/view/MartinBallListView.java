package com.qpidnetwork.livemodule.view;

import android.content.Context;
import android.support.annotation.NonNull;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ListAdapter;
import android.widget.ListView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.view.ballRefresh.ThreeBallFooter;
import com.qpidnetwork.livemodule.view.ballRefresh.ThreeBallHeader;
import com.scwang.smartrefresh.layout.SmartRefreshLayout;
import com.scwang.smartrefresh.layout.api.RefreshLayout;
import com.scwang.smartrefresh.layout.listener.OnRefreshLoadMoreListener;

public class MartinBallListView extends SmartRefreshLayout implements OnRefreshLoadMoreListener {

	public final static int PAGE_SIZE = 30;

	// View objects
	private ListView listView;

	// 2018/11/20 Hardy
	private View mRootView;

	// local various
//	private Context mContext;
	private boolean is_loading = false;
	private boolean can_pull_up = true;
	private boolean can_pull_down = true;

	// callback
	private OnPullRefreshListener mOnPullRefreshListener;

	public MartinBallListView(Context context, AttributeSet attrs) {
		super(context, attrs);
//		mContext = context;
		createView();
	}

	private void createView() {
		mRootView = LayoutInflater.from(getContext()).inflate(R.layout.martin_ball_listview, this, false);

		listView = (ListView) mRootView.findViewById(R.id.listView);
		this.addView(mRootView);

		setRefreshView();

	}

	private void setRefreshView() {
		setRefreshHeader(new ThreeBallHeader(getContext()));
		setRefreshFooter(new ThreeBallFooter(getContext()));
		setEnableLoadMoreWhenContentNotFull(false);	//是否在列表不满一页时候开启上拉加载功能
		setOnRefreshLoadMoreListener(this);
	}

	@Override
	public void onRefresh(@NonNull RefreshLayout refreshLayout) {
		if (!can_pull_down || is_loading) {
			finishRefresh();
			return;
		}
		is_loading = true;
		if (mOnPullRefreshListener != null) {
			mOnPullRefreshListener.onPullDownToRefresh();
		}
	}

	@Override
	public void onLoadMore(@NonNull RefreshLayout refreshLayout) {
		// 2019/7/25 new
		if (!can_pull_up || is_loading) {
			finishLoadMore();
			return;
		}

		is_loading = true;

//        //上拉更多时，不能下拉刷新
		setEnableRefresh(false);

		if (mOnPullRefreshListener != null) {
			mOnPullRefreshListener.onPullUpToRefresh();
		}
	}

	/**
	 * 自动刷新
	 *
	 */
	public void showRefreshing() {
//        autoRefresh();		// 会自动回调到 onRefresh 方法做进一步的业务处理.
		autoRefreshAnimationOnly();//自动刷新，只显示动画不执行刷新
	}

	public void hideRefreshing(){
		finishRefresh();
	}

	/**
	 * 2018/11/20 Hardy
	 * @param colorResId
	 */
	public void setBackgroundColorRes(int colorResId){
		setBackgroundResource(colorResId);
	}

	public void setCanPullDown(boolean b) {
		can_pull_down = b;
		setEnableRefresh(b);
	}

	public boolean getCanPullDown() {
		return can_pull_down;
	}

	public void setCanPullUp(boolean b) {
		can_pull_up = b;
		setEnableLoadMore(b);
	}

	public boolean getCanPullUp() {
		return can_pull_up;
	}

	public void setAdapter(ListAdapter adapter) {
		listView.setAdapter(adapter);
	}

	public ListView getListView() {
		return listView;
	}

	public void onRefreshComplete() {
		finishRefresh();
		finishLoadMore();

		is_loading = false;
		if (can_pull_down) {
			setEnableRefresh(true);
		}
			
	}

	public void setOnPullRefreshListener(OnPullRefreshListener listener) {
		this.mOnPullRefreshListener = listener;
	}

	public interface OnPullRefreshListener {
		void onPullDownToRefresh();
		void onPullUpToRefresh();
	}
}
