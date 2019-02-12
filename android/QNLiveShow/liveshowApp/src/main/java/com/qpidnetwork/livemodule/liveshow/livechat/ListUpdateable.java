package com.qpidnetwork.livemodule.liveshow.livechat;

import java.util.List;

public interface ListUpdateable<T> {

	/**
	 * 在数据集前面插入
	 * 
	 * @param dataList
	 */
	public void prependList(List<T> dataList);
	
	/**
	 * 在数据集前面插入
	 * 
	 * @param dataArray
	 */
	public void prependList(T[] dataArray);	

	/**
	 * 在数据集前面插入一行数据
	 * 
	 * @param data
	 */
	public void prepend(T data);

	/**
	 * 在数据集后面附加
	 * 
	 * @param dataList
	 */
	public void appendList(List<T> dataList);
	
	/**
	 * 在数据集后面附加
	 * 
	 * @param dataArray
	 */
	public void appendList(T[] dataArray);

	/**
	 * 在数据集后面附加一行数据
	 * 
	 * @param data
	 */
	public void append(T data);

	/**
	 * 替换数据集
	 * 
	 * @param dataList
	 */
	public void replaceList(List<T> dataList);
	
	/**
	 * 替换数据集
	 * @param dataArray
	 */
	public void replaceList(T[] dataArray);

	/**
	 * 清空数据集
	 */
	public void clearList();

}
