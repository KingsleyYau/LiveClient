package com.qpidnetwork.anchor.view;

import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.support.annotation.ColorRes;
import android.support.annotation.DrawableRes;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v4.widget.SwipeRefreshLayout.OnRefreshListener;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.utils.DisplayUtil;
import com.takwolf.android.hfrecyclerview.HeaderAndFooterRecyclerView;

import static android.support.v7.widget.RecyclerView.SCROLL_STATE_IDLE;
import static android.support.v7.widget.RecyclerView.SCROLL_STATE_SETTLING;

/**
 * Created by Jagger on 2018/4/23.
 */
public class RefreshRecyclerView extends LinearLayout implements OnRefreshListener {

	public final static int PAGE_SIZE = 30;

	private Context mContext;
	// View objects
	private SwipeRefreshLayout swipeRefreshLayout;
	private HeaderAndFooterRecyclerView recyclerView;
	private SwipeRefreshLayout swipeLayoutEmpty;
	private TextView tvEmptyView;
	private ButtonRaised mBtnEmptyView;
	private LinearLayout mLlEmptyView;

	// local objects
	private LinearLayout listFooter;

	// local various
	private boolean is_loading = false;
	private boolean can_pull_up = true;
	private boolean can_pull_down = true;

	// callback
	private OnPullRefreshListener mOnPullRefreshListener;

	public RefreshRecyclerView(Context context, AttributeSet attrs) {
		super(context, attrs);
		// TODO Auto-generated constructor stub
		mContext = context;
		createView();
	}

	private void createView() {

		View v = LayoutInflater.from(getContext()).inflate(
				R.layout.refresh_recyclerview, null);
		swipeRefreshLayout = (SwipeRefreshLayout) v
				.findViewById(R.id.swipeRefreshLayout);
		recyclerView = (HeaderAndFooterRecyclerView) v.findViewById(R.id.recyclerView);
		mLlEmptyView = (LinearLayout) v.findViewById(R.id.ll_emptyView);
		swipeLayoutEmpty = (SwipeRefreshLayout) v.findViewById(R.id.swipeLayoutEmpty);
		tvEmptyView = (TextView) v.findViewById(R.id.tvEmptyView);
		mBtnEmptyView = (ButtonRaised)v.findViewById(R.id.btnRetry);
		mBtnEmptyView.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View view) {
				swipeRefreshLayout.setVisibility(VISIBLE);
				swipeLayoutEmpty.setVisibility(GONE);
				swipeRefreshLayout.setRefreshing(true);
				if (mOnPullRefreshListener != null) {
					mOnPullRefreshListener.onPullDownToRefresh();
				}
			}
		});
		this.addView(v);

		//注: recyclerView.getFooterContainer() 一定要带, 不然布局不能布满
		listFooter = (LinearLayout) LayoutInflater.from(getContext()).inflate(
				R.layout.item_list_view_footer, recyclerView.getFooterContainer(), false);
		listFooter.setBackgroundColor(Color.WHITE);

		/*隐藏footerview*/
		listFooter.setVisibility(View.GONE);

		recyclerView.addFooterView(listFooter);

		setRefreshView();

	}

	private void setRefreshView() {

		swipeRefreshLayout.setOnRefreshListener(this);
		swipeLayoutEmpty.setOnRefreshListener(this);

		recyclerView.addOnScrollListener(new RecyclerView.OnScrollListener() {
			@Override
			public void onScrollStateChanged(RecyclerView recyclerView, int newState) {
				super.onScrollStateChanged(recyclerView, newState);

				if (!can_pull_up)
					return;
				if (recyclerView == null)
					return;
				if (recyclerView.getAdapter().getItemCount() == 0)
					return;

				if (newState == SCROLL_STATE_IDLE || newState == SCROLL_STATE_SETTLING) {
					// 只有LinearLayoutManager才有查找第一个和最后一个可见view位置的方法
					RecyclerView.LayoutManager layoutManager = recyclerView.getLayoutManager();
					if (layoutManager instanceof LinearLayoutManager) {
						LinearLayoutManager linearLayoutManager = (LinearLayoutManager) layoutManager;
						//当停止滚动时或者惯性滚动时，RecyclerView的最后一个显示的条目：getCount()-1
						//注意是findLastVisibleItemPosition()而不是getLastVisiblePosition

						if (linearLayoutManager.findLastVisibleItemPosition() >= recyclerView.getAdapter().getItemCount() - 1) {

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
				}

			}

		});
		
		recyclerView.setEmptyView(swipeLayoutEmpty);

	}
	
	/**
	 * 设置列表空时显示
	 * @param emptyText
	 */
	public void setEmptyMessage(String emptyText){
		if(tvEmptyView != null){
			tvEmptyView.setText(emptyText);
		}
	}

	/**
	 * 设置默认无数据页样式中文字
	 * @param message
	 */
	public void setEmptyMessage(String message  , @DrawableRes int drawableLeftId , int widthPx , int heightPx){
		if(tvEmptyView != null){
			tvEmptyView.setText(message);
			Drawable drawableLeft = mContext.getResources().getDrawable(drawableLeftId);
			// 这一步必须要做，否则不会显示。
			drawableLeft.setBounds(0,
					0,
					widthPx,
					heightPx);// 设置图片宽高
			tvEmptyView.setCompoundDrawables(drawableLeft , null , null , null);
			tvEmptyView.setCompoundDrawablePadding(8);//设置图片和text之间的间距
		}
	}

	/**
	 * 设置默认无数据页按钮样式
	 * @param visibility
	 * @param text
	 * @param colorId
	 */
	public void setEmptyButton(int visibility , String text , @ColorRes int colorId){
		if(mBtnEmptyView != null){
			mBtnEmptyView.setVisibility(visibility);
			mBtnEmptyView.setButtonTitle(text);
			mBtnEmptyView.setButtonBackground(getResources().getColor(colorId));
		}
	}

	/**
	 * 显示loading
	 */
	public void showLoading(){
		swipeRefreshLayout.setRefreshing(true);
	}

	/**
	 * 隐藏loading
	 */
	public void hideLoading(){
		swipeRefreshLayout.setRefreshing(false);
		swipeLayoutEmpty.setRefreshing(false);
	}

	/**
	 * 显示默认页
	 */
	public void showEmptyView(){
		swipeRefreshLayout.setVisibility(GONE);
		mLlEmptyView.setVisibility(VISIBLE);
		swipeLayoutEmpty.setVisibility(VISIBLE);
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

	public void setAdapter(RecyclerView.Adapter adapter) {
		recyclerView.setAdapter(adapter);
	}

	public HeaderAndFooterRecyclerView getRecyclerView() {
		return recyclerView;
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
