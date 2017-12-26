package com.qpidnetwork.livemodule.liveshow.googleanalytics;

import android.text.TextUtils;

import com.qpidnetwork.livemodule.utils.Log;

import java.util.ArrayList;
import java.util.Arrays;

/**
 * tag管理类
 * @author Samson Fan
 *
 */
public class AnalyticsTagManager {
	
	/**
	 * 根tag节点
	 */
	private AnalyticsTagItem mCurrTagItem = new AnalyticsTagItem();
	
	AnalyticsTagManager() {
		
	}
	
	/**
	 * 是否有tag
	 * @return
	 */
	public boolean HasTag()
	{
		return mCurrTagItem.HasSubTag();
	}
	
	/**
	 * 获取tag名称(筛选id)
	 * @param tagName	tag名称(可能带id)
	 * @return
	 */
	private String GetTagName(String tagName)
	{
		String name = "";
		int idSeparator = tagName.indexOf(AnalyticsActivityManager.TAGID_SEPARATOR);
		name = (idSeparator > 0 ? tagName.substring(0, idSeparator) : tagName);
		return name;
	}
	
	/**
	 * 获取tag id
	 * @param tagName	tag名称(可能带id)
	 * @return
	 */
	private String GetTagID(String tagName)
	{
		String id = "";
		int idSeparator = tagName.indexOf(AnalyticsActivityManager.TAGID_SEPARATOR);
		id = (idSeparator > 0 ? tagName.substring(idSeparator) : "");
		return id;
	}
	
	/**
	 * 获取tag路径(不带id)
	 * @return
	 */
	public String GetCurrTagPath()
	{
		return GetTagPath(mCurrTagItem);
	}
	
	/**
	 * 获取当前所有tag名称(不包含tagID)
	 * @return
	 */
	public ArrayList<String> GetCurrTagNamesWithoutID()
	{
		ArrayList<String> names = new ArrayList<String>();
		if (null != mCurrTagItem)
		{
			// 遍历当前tag
			AnalyticsTagItem item = mCurrTagItem.GetCurrSubTag();
			while (null != item) {
				// 获取name
				String tagName = item.GetTagName();
				if (!TextUtils.isEmpty(tagName))
				{
					names.add(tagName);
				}
			
				// 子tag
				item = item.GetCurrSubTag();
			}
		}
		return names;
	}
	
	/**
	 * 获取当前所有tag名称(包含tagID)
	 * @return
	 */
	public ArrayList<String> GetCurrTagNamesIncludeID()
	{
		ArrayList<String> names = new ArrayList<String>();
		if (null != mCurrTagItem)
		{
			// 遍历当前tag
			AnalyticsTagItem item = mCurrTagItem.GetCurrSubTag();
			while (null != item)
			{
				String tagName = "";
				
				// 获取name
				String name = item.GetTagName();
				if (!TextUtils.isEmpty(name)) {
					tagName = name;
				}
				
				// 获取id
				String id = item.GetTagID();
				if (!TextUtils.isEmpty(id)) {
					tagName = tagName + AnalyticsActivityManager.TAGID_SEPARATOR + id;
				}
				
				// 添加到list
				if (!TextUtils.isEmpty(tagName)) {
					names.add(tagName);
				}
				
				// 子tag
				item = item.GetCurrSubTag();
			}
		}
		
		
		return names;
	}
	
	/**
	 * 获取tag路径处理类
	 * @param item
	 * @return
	 */
	private String GetTagPath(AnalyticsTagItem item)
	{
		String path = "";
		if (!item.GetTagName().isEmpty()) {
			path = AnalyticsActivityManager.TAGNAME_SEPARATOR + item.GetTagName();
		}
		
		if (null != item.GetCurrSubTag()) {
			path += GetTagPath(item.GetCurrSubTag());
		}
		return path;
	}
	
	/**
	 * 判断是否当前tag
	 * @param tagNames	tag路径
	 * @return
	 */
	public boolean IsCurrTagPath(String... tagNames)
	{
		boolean result = false;
		
		if (null != tagNames && tagNames.length > 0)
		{
			// 有路径，判断当前路径是否一致
			AnalyticsTagItem item = mCurrTagItem;
			for (String tagName : tagNames)
			{
				if (null == item) {
					break;
				}
				
				// 判断是否当前tag
				String name = GetTagName(tagName);
				String id = GetTagID(tagName);
				if (item.GetTagName().equals(name)
					&& item.GetTagID().equals(id))
				{
					// 是当前tag，判断子
					result = true;
					item = item.GetCurrSubTag();
				}
				else {
					// 不是当前tag
					result = false;
					break;
				}
			}
		}
		else {
			// 没有路径，判断当前是否没有路径
			result = (null == mCurrTagItem.GetCurrSubTag());
		}
		
		return result;
	}
	
	/**
	 * 设置当前tag路径
	 * @param tagNames	tag各路径名称
	 * @return	是否改变原来路径
	 */
	public boolean SetCurrTagPath(String... tagNames)
	{
		boolean result = false;
		
		if (null != tagNames && tagNames.length > 0)
		{
			// 生成ArrayList
			ArrayList<String> tagNameList = new ArrayList<String>(Arrays.asList(tagNames));
			
			// 筛选已是当前的tag
			AnalyticsTagItem diffItem = mCurrTagItem.GetCurrSubTag();
			AnalyticsTagItem lastCurrItem = mCurrTagItem;
			while (null != diffItem
				&& !tagNameList.isEmpty())
			{
				// 获取第一个待筛选tag名
				String tagName = tagNameList.get(0);
				
				// 判断tag名与id是否相等
				String name = GetTagName(tagName);
				String id = GetTagID(tagName);
				if (diffItem.GetTagName().equals(name)
					&& diffItem.GetTagID().equals(id)) 
				{
					// 是当前tag，从待筛选列表删除
					tagNameList.remove(0);
					
					// 更新最后一个相同当前tag
					lastCurrItem = diffItem;
					
					// 筛选子tag
					diffItem = diffItem.GetCurrSubTag();
				}
				else {
					diffItem = null;
					break;
				}
			}
			
			if (!tagNameList.isEmpty()) 
			{
				// 不是当前tag
				result = true;
				
				// 根据tag路径设置当前tag
				SetCurrTagItemWithPath(lastCurrItem, tagNameList);
			}
		}
		else {
			// 去掉tag路径
			result = (null != mCurrTagItem.GetCurrSubTag());
			mCurrTagItem.CleanSubTag();
		}

		return result;
	}
	
	/**
	 * 根据tag路径设置当前tag，若tag不存在则创建
	 * @param parentItem	父tag item
	 * @param tagNameList	tag名列表
	 */
	private void SetCurrTagItemWithPath(AnalyticsTagItem parentItem, ArrayList<String> tagNameList)
	{
		// 不正常参数
		if (null == parentItem) {
			Log.e("AnalyticsManager", "SetCurrTagItemWithPath() tagNameList.isEmpty:%b, parentItem:%s"
					, tagNameList.isEmpty(), String.valueOf(parentItem));
			return;
		}
		
		// 处理完毕
		if (tagNameList.isEmpty()) {
			return;
		}

		String tagName = GetTagName(tagNameList.get(0));
		String tagId = GetTagID(tagNameList.get(0));
		AnalyticsTagItem subItem = parentItem.HasSubTag(tagName, tagId);
		if (null != subItem) {
			// 子tag已存在，设置为当前tag
			parentItem.SetCurrSubTag(subItem);
			
			// 移除tagName，并继续设置子tag
			tagNameList.remove(0);
			SetCurrTagItemWithPath(subItem, tagNameList);
		}
		else {
			// 子tag不存在，创建子tag并加至parentItem
			subItem = new AnalyticsTagItem(tagName, tagId);
			parentItem.InsertSubTag(subItem);
			parentItem.SetCurrSubTag(subItem);

			// 移除tagName，并继续设置子tag
			tagNameList.remove(0);
			SetCurrTagItemWithPath(subItem, tagNameList);
		}
	}
}
