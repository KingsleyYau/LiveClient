package com.qpidnetwork.anchor.view;

import android.content.Context;
import android.graphics.Color;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v4.widget.SwipeRefreshLayout.OnRefreshListener;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.AbsListView;
import android.widget.AbsListView.OnScrollListener;
import android.widget.LinearLayout;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.TextView;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.utils.DisplayUtil;

public class MartinListView extends LinearLayout implements OnRefreshListener {

	public final static int PAGE_SIZE = 30;

	// View objects
	private SwipeRefreshLayout swipeRefreshLayout;
	private ListView listView;
	private SwipeRefreshLayout swipeLayoutEmpty;
	private TextView emptyView;

	// local objects
	private LinearLayout listFooter;

	// local various
	private boolean is_loading = false;
	private boolean can_pull_up = true;
	private boolean can_pull_down = true;

	// callback
	private OnPullRefreshListener mOnPullRefreshListener;

	public MartinListView(Context context, AttributeSet attrs) {
		super(context, attrs);
		// TODO Auto-generated constructor stub
		createView();
	}

	private void createView() {

		View v = LayoutInflater.from(getContext()).inflate(
				R.layout.martin_listview, null);
		swipeRefreshLayout = (SwipeRefreshLayout) v
				.findViewById(R.id.swipeRefreshLayout);
		listView = (ListView) v.findViewById(R.id.listView);
		swipeLayoutEmpty = (SwipeRefreshLayout) v
				.findViewById(R.id.swipeLayoutEmpty);
		emptyView = (TextView) v.findViewById(R.id.emptyView);
		this.addView(v);

		listFooter = (LinearLayout) LayoutInflater.from(getContext()).inflate(
				R.layout.item_list_view_footer, null);
		listFooter.setBackgroundColor(Color.WHITE);
		/*隐藏footerview*/
		listFooter.setVisibility(View.GONE);
		listFooter.setPadding(0, -DisplayUtil.dip2px(getContext(), 72), 0, 0);
		
		listView.addFooterView(listFooter, null, true);
		listView.setFooterDividersEnabled(false);

		setRefreshView();

	}

	private void setRefreshView() {

		swipeRefreshLayout.setOnRefreshListener(this);
		swipeLayoutEmpty.setOnRefreshListener(this);

		listView.setOnScrollListener(new OnScrollListener() {

			@Override
			public void onScroll(AbsListView view, int firstVisibleItem,
					int visibleItemCount, int totalItemCount) {
				// TODO Auto-generated method stub

			}

			@Override
			public void onScrollStateChanged(AbsListView view, int scrollState) {
				// TODO Auto-generated method stub

				if (!can_pull_up)
					return;
				if (listView == null)
					return;
				if (listView.getCount() == 0)
					return;
				if (listView.getCount() > (PAGE_SIZE - 1)
						&& listView.getLastVisiblePosition() == (listView
						.getCount() - 1)
						&& scrollState == SCROLL_STATE_IDLE) {

					if (is_loading)
						return;
					is_loading = true;
					swipeRefreshLayout.setEnabled(false);
					swipeLayoutEmpty.setEnabled(false);
					listFooter.setVisibility(View.VISIBLE);
					listFooter.setPadding(0, 0, 0, 0);

					if (mOnPullRefreshListener != null) {
						mOnPullRefreshListener.onPullUpToRefresh();
					}
				}

			}

		});
		
		listView.setEmptyView(swipeLayoutEmpty);

	}
	
	/**
	 * 设置列表空时显示
	 * @param emptyText
	 */
	public void setEmptyMessage(String emptyText){
		if(emptyView != null){
			emptyView.setText(emptyText);
		}
	}

	public void setCanPullDown(boolean b) {
		can_pull_down = b;
		swipeRefreshLayout.setEnabled(b);
		swipeLayoutEmpty.setEnabled(b);
	}

	public boolean getCanPullDown() {
		return can_pull_down;
	}

	public void setCanPullUp(boolean b) {
		can_pull_up = b;
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
		swipeLayoutEmpty.setRefreshing(false);
		
		listFooter.setVisibility(View.GONE);
		listFooter.setPadding(0, -DisplayUtil.dip2px(getContext(), 72), 0, 0);
		
		is_loading = false;
		if(can_pull_down){
			swipeRefreshLayout.setEnabled(true);
			swipeLayoutEmpty.setEnabled(true);
		}
			
	}

	public void setOnPullRefreshListener(OnPullRefreshListener listener) {
		this.mOnPullRefreshListener = listener;
	}

	public interface OnPullRefreshListener {
		public void onPullDownToRefresh();

		public void onPullUpToRefresh();
	}
}
