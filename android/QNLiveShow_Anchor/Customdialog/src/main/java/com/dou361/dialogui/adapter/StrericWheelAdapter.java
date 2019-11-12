package com.dou361.dialogui.adapter;

/**
 * ========================================
 * <p>
 * 版 权：dou361.com 版权所有 （C） 2015
 * <p>
 * 作 者：陈冠明
 * <p>
 * 个人网站：http://www.dou361.com
 * <p>
 * 版 本：1.0
 * <p>
 * 创建日期：2016/3/15 21:29
 * <p>
 * 描 述：自定义wheel适配器
 * <p>
 * <p>
 * 修订历史：
 * <p>
 * ========================================
 */
public class StrericWheelAdapter implements WheelAdapter {
	
	/** The default min value */
	private String[] strContents;
	/**
	 * 构造方法
	 * @param strContents
	 */
	public StrericWheelAdapter(String[] strContents){
		this.strContents=strContents;
	}
	
	
	public String[] getStrContents() {
		return strContents;
	}


	public void setStrContents(String[] strContents) {
		this.strContents = strContents;
	}


	public String getItem(int index) {
		if (index >= 0 && index < getItemsCount()) {
			return strContents[index];
		}
		return null;
	}
	
	public int getItemsCount() {
		return strContents.length;
	}
	/**
	 * 设置最大的宽度
	 */
	public int getMaximumLength() {
		int maxLen=7;
		return maxLen;
	}


	@Override
	public String getCurrentId(int index) {
		// TODO Auto-generated method stub
		return null;
	}
}
