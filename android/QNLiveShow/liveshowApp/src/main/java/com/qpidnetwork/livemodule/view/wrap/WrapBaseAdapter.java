package com.qpidnetwork.livemodule.view.wrap;

import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnLongClickListener;
import android.view.ViewGroup;


public abstract class WrapBaseAdapter {
	
	private View myView;
	private ViewGroup myViewGroup;
	private WrapListView myCustomListView;
	private WrapListView.OnItemClickListener listener;
	private WrapListView.OnItemLongClickListener longListener;

	protected abstract int getCount();

	protected abstract Object getItem(int position);

	protected abstract int getItemId(int position);

	protected abstract View getView(int position, View convertView, ViewGroup parent);

	private final void getAllViewAddSexangle() {
		this.myCustomListView.removeAllViews();
		for (int i = 0; i < getCount(); ++i) {
			View viewItem = getView(i, this.myView, this.myViewGroup);
			this.myCustomListView.addView(viewItem, i);
		}
	}

	public void notifyDataSetChanged() {
		WrapListView.setAddChildType(true);
		notifyCustomListView(this.myCustomListView);
	}

	public void notifyCustomListView(WrapListView formateList) {
		this.myCustomListView = formateList;
		getAllViewAddSexangle();
		if(listener != null){
			setOnItemClickListener(this.listener);
		}
		if(longListener != null){
			setOnItemLongClickListener(this.longListener);
		}
	}

	public void setOnItemClickListener(WrapListView.OnItemClickListener listener) {
		this.listener = listener;
		for (int i = 0; i < this.myCustomListView.getChildCount(); ++i) {
			View view = this.myCustomListView.getChildAt(i);
			view.setTag(i);
			view.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View v) {
					WrapBaseAdapter.this.listener.onItemClick(null, v, Integer.parseInt(v.getTag().toString()), getCount());
				}
			});
		}
	}

	public void setOnItemLongClickListener(WrapListView.OnItemLongClickListener listener) {
		this.longListener = listener;
		for (int i = 0; i < this.myCustomListView.getChildCount(); ++i) {
			View view = this.myCustomListView.getChildAt(i);
			view.setTag(i);
			view.setOnLongClickListener(new OnLongClickListener() {
				@Override
				public boolean onLongClick(View v) {
					WrapBaseAdapter.this.longListener.onItemLongClick(null, v,  Integer.parseInt(v.getTag().toString()), getCount());
					return true;
				}
			});
		}
	}
}
