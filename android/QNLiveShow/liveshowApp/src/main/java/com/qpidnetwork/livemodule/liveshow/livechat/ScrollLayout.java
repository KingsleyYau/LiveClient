package com.qpidnetwork.livemodule.liveshow.livechat;

import android.content.Context;
import android.util.AttributeSet;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.ScrollView;

/**
 * 滚动布局 <br />
 * 与ScrollView的区别：可以添加多个子View
 */
public class ScrollLayout extends ScrollView {


	private LinearLayout container;

	public ScrollLayout(Context context) {
		super(context);
		initMessageListView();
	}

	public ScrollLayout(Context context, AttributeSet attrs) {
		this(context, attrs, 0);
	}

	public ScrollLayout(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		initMessageListView();
	}

	private void initMessageListView() {
		container = new LinearLayout(getContext());
		container.setOrientation(LinearLayout.VERTICAL);
		ViewGroup.LayoutParams lp = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
		container.setLayoutParams(lp);
		super.addView(container);
	}

	public LinearLayout getContainer() {
		return container;
	}

	public void scrollToBottom(final boolean smooth) {
		// 若不postDelayed，则在addRow后，getBottom()新增的行高没有计算入内，最后一行就没有显示出来
		postDelayed(new Runnable() {
			@Override
			public void run() {
				int bottom = getChildAt(0).getBottom();
				if (smooth) {
					smoothScrollTo(0, bottom);
				} else {
					scrollTo(0, bottom);
				}
			}
		}, 50);
	}

	public void scrollToTop(final boolean smooth) {
		postDelayed(new Runnable() {

			@Override
			public void run() {
				int top = getChildAt(0).getTop();
				if (smooth) {
					smoothScrollTo(0, top);
				} else {
					scrollTo(0, top);
				}

			}
		}, 50);
	}


}
