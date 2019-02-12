package com.qpidnetwork.livemodule.liveshow.livechat;

import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

public abstract class UpdateableAdapter<T> extends BaseAdapter implements ListUpdateable<T> {

	protected String tag = getClass().getSimpleName();

	List<T> dataList = new ArrayList<T>();
	Comparator<T> comparator;

	@Override
	public int getCount() {
		return dataList.size();
	}

	@Override
	public T getItem(int position) {
		return dataList.get(position);
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		return convertView;
	}

	@Override
	public long getItemId(int position) {
		return 0;
	}

	@Override
	public void prependList(List<T> dataList) {
		this.dataList.addAll(0, dataList);
		notifyDataSetChanged();
	}

	@Override
	public void prependList(T[] dataArray) {
		prependList(Arrays.asList(dataArray));
	}

	@Override
	public void prepend(T data) {
		this.dataList.add(0, data);
		notifyDataSetChanged();
	};

	@Override
	public void appendList(List<T> dataList) {
		/**
		 * 加入排重操作
		 */
		for(int i=0; i<dataList.size();i++){
			if(!this.dataList.contains(dataList.get(i))){
				this.dataList.add(dataList.get(i));
			}
		}
		notifyDataSetChanged();
	}

	@Override
	public void appendList(T[] dataArray) {
		appendList(Arrays.asList(dataArray));
	}

	@Override
	public void append(T data) {
		this.dataList.add(data);
		notifyDataSetChanged();
	};

	@Override
	public void replaceList(List<T> dataList) {
		this.dataList.clear();
		this.dataList.addAll(dataList);
		notifyDataSetChanged();
	}

	@Override
	public void replaceList(T[] dataArray) {
		replaceList(Arrays.asList(dataArray));
	}

	@Override
	public void clearList() {
		this.dataList.clear();
		notifyDataSetChanged();
	}

	@Override
	public void notifyDataSetChanged() {
		if (comparator != null && this.dataList != null && this.dataList.size() > 0) {
			try {
				System.setProperty("java.util.Arrays.useLegacyMergeSort", "true");
				Collections.sort(this.dataList, comparator);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		super.notifyDataSetChanged();
	}
	
	public void notifyDataSetChanged(boolean mustBeFalse){
		super.notifyDataSetChanged();
	} 

	public List<T> getDataList() {
		return dataList;
	}

	public Comparator<T> getComparator() {
		return comparator;
	}

	public void setComparator(Comparator<T> comparator) {
		this.comparator = comparator;
	}
	
}
