package com.qpidnetwork.anchor.liveshow.googleanalytics;

import java.util.ArrayList;

/**
 * 用于跟踪tag的item（1 Activity : n Tag）
 * @author Samson Fan
 *
 */
public class AnalyticsTagItem {
	/**
	 * tag名称
	 */
	private String mTagName = "";
	
	/**
	 * tag ID（仅用于区分相同tag名不同的tag，不算在tag路径）
	 */
	private String mTagId = "";
	
	/**
	 * 当前指向的子tag
	 */
	private AnalyticsTagItem mCurrSubTag = null;
	
	/**
	 * 子tag列表
	 */
	private ArrayList<AnalyticsTagItem> mSubTagList = null;
	
	public AnalyticsTagItem() {}
	
	public AnalyticsTagItem(String tagName, String tagId) 
	{
		mTagName = tagName;
		mTagId = tagId;
	}
	
	/**
	 * 设置tag名称
	 * @param tagName
	 */
	public void SetTagName(String tagName)
	{
		mTagName = tagName;
	}
	
	/**
	 * 获取tag名称
	 * @return
	 */
	public String GetTagName()
	{
		return mTagName;
	}
	
	/**
	 * 设置tag id
	 * @param tagId
	 */
	public void SetTagID(String tagId)
	{
		mTagId = tagId;
	}
	
	/**
	 * 获取tag id
	 * @return
	 */
	public String GetTagID()
	{
		return mTagId;
	}
	
	/**
	 * 设置当前子tag
	 * @param tagItem
	 */
	public void SetCurrSubTag(AnalyticsTagItem tagItem)
	{
		mCurrSubTag = tagItem;
	}
	
	/**
	 * 获取当前子tag
	 * @return
	 */
	public AnalyticsTagItem GetCurrSubTag()
	{
		return mCurrSubTag;
	}
	
	/**
	 * 是否存在子tag
	 */
	public boolean HasSubTag()
	{
		return null != mSubTagList;
	}
	
	/**
	 * 获取子tag列表
	 */
	public ArrayList<AnalyticsTagItem> GetSubTagList() 
	{
		return mSubTagList;
	}
	
	/**
	 * 是否存在指定子tag
	 */
	public AnalyticsTagItem HasSubTag(String name, String id)
	{
		AnalyticsTagItem item = null;
		if (HasSubTag()) {
			for (AnalyticsTagItem subItem : mSubTagList)
			{
				if (subItem.GetTagName().equals(name)
					&& subItem.GetTagID().equals(id))
				{
					item = subItem;
					break;
				}
			}
		}
		return item;
	}
	
	/**
	 * 插入子tag
	 * @param tagItem
	 */
	public void InsertSubTag(AnalyticsTagItem tagItem)
	{
		if (null == mSubTagList) {
			mSubTagList = new ArrayList<AnalyticsTagItem>();
		}
		mSubTagList.add(tagItem);
	}
	
	/**
	 * 清空所有子路径
	 */
	public void CleanSubTag()
	{
		mCurrSubTag = null;
		mSubTagList = null;
	}
}
