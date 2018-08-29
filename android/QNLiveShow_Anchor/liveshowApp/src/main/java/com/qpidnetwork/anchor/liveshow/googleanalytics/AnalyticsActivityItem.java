package com.qpidnetwork.anchor.liveshow.googleanalytics;

import java.util.ArrayList;

import android.app.Activity;

/**
 * 用于跟踪activity的item
 * @author Samson Fan
 *
 */
public class AnalyticsActivityItem {
	// activity
	public Activity mActivity = null;
	// 是否page activity标记
	private boolean mIsPageActivity = false;
	// onResume提交标记(是否提交过resume事件)
	private boolean mResumeSubmit = false;
	// 父activity screen路径list
	public ArrayList<String> mParentScreenPathList = new ArrayList<String>();
	// tag管理器
	public AnalyticsTagManager mTagMgr = new AnalyticsTagManager();
	
	/**
	 * 设置父activity screen路径
	 * @param parentScreenPathList	父screen路径
	 */
	public void SetParentScreenPath(ArrayList<String> parentScreenPathList)
	{
		mParentScreenPathList.clear();
		mParentScreenPathList.addAll(parentScreenPathList);
	}
	
	/**
	 * 获取父screen路径
	 * @return
	 */
	public String GetParentScreenPath()
	{
		String screenPath = "";
		for (String parentScreenPath : mParentScreenPathList)
		{
			if (!screenPath.isEmpty()) {
				screenPath += AnalyticsActivityManager.SCREENPATH_SEPARATOR;
			}
			screenPath += parentScreenPath;
		}
		return screenPath;
	}
	
	/**
	 * 获取screen路径
	 * @param screenName
	 * @return
	 */
	public String GetScreenPath(String screenName)
	{
		String screenPath = GetParentScreenPath();
		if (!screenPath.isEmpty()) {
			screenPath += AnalyticsActivityManager.SCREENPATH_SEPARATOR;
		}
		screenPath += screenName;
		return screenPath;
	}
	
	/**
	 * 设置onResume时提交统计
	 * @param isSubmit
	 */
	void SetResumeSubmit(boolean isSubmit)
	{
		mResumeSubmit = isSubmit;
	}
	
	/**
	 * 判断onResume时是否提交统计 
	 * @return
	 */
	public boolean IsResumeSubmit()
	{
		return mResumeSubmit;
	}
	
	/**
	 * 设置为page activity
	 * @param isPageActivity
	 */
	void SetPageActivity(boolean isPageActivity)
	{
		mIsPageActivity = isPageActivity;
	}
	
	/**
	 * 判断是否page activity
	 * @return
	 */
	boolean IsPageActivity()
	{
		return mIsPageActivity;
	}
	
	/**
	 * 判断tag页是否有效
	 */
	public boolean IsValidPage() 
	{
		return mTagMgr.HasTag();
	}
	
	/**
	 * 判断是否当前tag
	 * @param tagNames	tag路径
	 * @return
	 */
	public boolean IsCurrTag(String... tagNames)
	{
		return mTagMgr.IsCurrTagPath(tagNames);
	}
	
	/**
	 * 设置当前tag路径
	 * @param tagNames	tag路径
	 * @return
	 */
	public boolean SetCurrTagPath(String... tagNames)
	{
		return mTagMgr.SetCurrTagPath(tagNames);
	}
	
	/**
	 * 获取当前tag路径
	 * @return
	 */
	public String GetCurrTagPath()
	{
		return mTagMgr.GetCurrTagPath();
	}
	
	/**
	 * 获取当前所有tag名称(不包含tagID)
	 * @return
	 */
	public ArrayList<String> GetCurrTagNamesWithoutID()
	{
		return mTagMgr.GetCurrTagNamesWithoutID();
	}
	
	/**
	 * 获取当前所有tag名称(包含tagID)
	 * @return
	 */
	public ArrayList<String> GetCurrTagNamesIncludeID()
	{
		return mTagMgr.GetCurrTagNamesIncludeID();
	}
}
