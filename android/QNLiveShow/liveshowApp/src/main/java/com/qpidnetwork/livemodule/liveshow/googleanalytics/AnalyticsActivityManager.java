package com.qpidnetwork.livemodule.liveshow.googleanalytics;

import java.lang.reflect.Field;
import java.util.ArrayList;
import android.app.Activity;
import android.app.Application;
import android.text.TextUtils;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.utils.Log;


/**
 * 用于跟踪activity管理类
 * @author Samson Fan
 *
 */
public class AnalyticsActivityManager {
	/**
	 *  Activity路径分隔符 
	 */
	public static final String ACTIVITYNAME_SEPARATOR = "_";
	/**
	 * Acitivty的Tag名分隔符
	 */
	public static final String TAGNAME_SEPARATOR = "_";
	/**
	 * Acitivty的TagID分隔符
	 */
	public static final String TAGID_SEPARATOR = ":";
	/**
	 * 屏幕路径分隔符
	 */
	public static final String SCREENPATH_SEPARATOR = "-";
	/**
	 * 返回的屏幕路径分隔符
	 */
	public static final String SCREENPATH_BACK_SIGN = "*";

	// application
	private Application mApplication = null;
		
	// activity统计列表
	private ArrayList<AnalyticsActivityItem> mActivityStack = new ArrayList<AnalyticsActivityItem>();
	
	// 上一次提交的screen路径
	private ArrayList<String> mOldScreenPath = new ArrayList<String>();
	
	public AnalyticsActivityManager() {}
	
	/**
	 * 设置application
	 * @param application
	 */
	public void SetApplication(Application application)
	{
		mApplication = application;
	}
	
	/**
	 * 添加activity
	 * @param activity
	 */
	public void AddActivity(Activity activity)
	{
		// 添加到activity栈
		AnalyticsActivityItem item = new AnalyticsActivityItem();
		item.mActivity = activity;
		item.SetParentScreenPath(GetCurrActivityScreenPathList());
		AddActivityItem(item);
	}
	
	/**
	 * 移除activity
	 * @param activity
	 */
	public void RemoveActivity(Activity activity)
	{
		// 移出activity栈
		RemoveActivityItem(activity);
	}
	
	/**
	 * 判断是否需要处理onResume
	 * @param activity
	 * @return true:处理，false：不处理
	 */
	public boolean WasResumeSubmit(Activity activity)
	{
		// 默认处理
		boolean result = false;
		
		// 判断是否已曾处理
		AnalyticsActivityItem item = GetActivityItem(activity);
		if (null != item && item.IsResumeSubmit()) 
		{
			result = true;
		}
		return result;
	}
	
	/**
	 * 设置onResume已处理
	 * @param activity
	 * @param process	是否已处理
	 */
	public void SetResumeSubmit(Activity activity, boolean process)
	{
		AnalyticsActivityItem item = GetActivityItem(activity);
		if (null != item) 
		{
			item.SetResumeSubmit(process);
		}
	}
	
	/**
	 * 设置是否page activity
	 * @param activity
	 * @param isPageActivity
	 */
	public void SetPageActivity(Activity activity, boolean isPageActivity)
	{
		AnalyticsActivityItem item = GetActivityItem(activity);
		if (null != item) {
			item.SetPageActivity(isPageActivity);
			item.SetResumeSubmit(!isPageActivity);
		}
	}
	
	/**
	 * 当有新page seleted时，是否需要提交当前page
	 * @param activity
	 * @return
	 */
	public boolean IsReportCurrPageWithSeleted(Activity activity, String... tagNames)
	{
		boolean isReport = false;
		
		AnalyticsActivityItem item = GetActivityItem(activity);
		if (null != item) 
		{
//			isReport = item.IsValidPage() || item.IsPageActivity();
			isReport = IsCurrActivityItem(activity) && !item.IsCurrTag(tagNames);
		}
		
		return isReport;
	}
	
	/**
	 * onDestroy时，统计screen路径
	 * @param activity
	 */
	public void ReportScreenPathWithOnDestroy(Activity activity)
	{
//		ReportScreenPath(activity);
		if (!IsCurrActivityItem(activity)) {
			// destroy非当前activity, 更新所有screen path
			UpdateScreenPathWithOnDestroy(activity);
		}
	}
	
	/**
	 * 获取指定activity的所有tag名(不包含ID)
	 * @param activity
	 * @return
	 */
	public ArrayList<String> GetCurrTagNamesWithoutID(Activity activity)
	{
		ArrayList<String> result = null;
		AnalyticsActivityItem item = GetActivityItem(activity);
		if (null != item)
		{
			result = item.GetCurrTagNamesWithoutID();
		}
		return result;
	}
	
	/**
	 * 获取指定activity的所有tag名(包含ID)
	 * @param activity
	 * @return
	 */
	public ArrayList<String> GetCurrTagNamesIncludeID(Activity activity)
	{
		ArrayList<String> result = null;
		AnalyticsActivityItem item = GetActivityItem(activity);
		if (null != item)
		{
			result = item.GetCurrTagNamesIncludeID();
		}
		return result;
	}
	
	/**
	 * 获取Screen路径
	 * @param activity	activity
	 * @return
	 */
	private String GetScreenPath(Activity activity)
	{
		String screenPath = "";
		AnalyticsActivityItem item = GetActivityItem(activity);
		if (null != item) {
			screenPath = item.GetScreenPath(GetToPathScreenName(item.mActivity));
		}
		return screenPath;
	}
	
	
	/**
	 * 获取Screen路径
	 * @param activity	activity
	 * @return
	 */
	public String ReportScreenPath(Activity activity)
	{
		String screenPath = GetScreenPath(activity);
		// 设置旧Screen路径
		if (!TextUtils.isEmpty(screenPath)) {
			SetOldScreenPath(screenPath);
		}
		return screenPath;
	}
	
	/**
	 * 解析ScreenPath为ScreenName
	 * @param screenPath
	 * @return
	 */
	private String[] ParsingScreenPath(String screenPath)
	{
		String[] screenNames = new String[0];
		if (!TextUtils.isEmpty(screenPath)) {
			screenNames = screenPath.split(SCREENPATH_SEPARATOR);
		}
		return screenNames;
	}

	/**
	 * 设置旧Screen路径（用于提交返回的Screen路径）
	 * @param screenPath
	 */
	private void SetOldScreenPath(String screenPath)
	{
		// 清空
		mOldScreenPath.clear();
		
		// 添加到旧Screen路径节点列表
		String[] screenNames = ParsingScreenPath(screenPath);
		for (String screenName : screenNames) {
			mOldScreenPath.add(screenName);
		}
	}
	
	/**
	 * 获取返回的Screen路径
	 * @param activity	activity
	 * @return
	 */
	public String GetBackScreenPath(Activity activity)
	{
		String backScreenPath = "";
		
		// 获取当前ScreenPath
		String currScreenPath = GetScreenPath(activity);
		String[] currScreenNames = ParsingScreenPath(currScreenPath);
		
		// 判断当前ScreenPath是旧的子集
		boolean isBack = false;
		if (currScreenNames.length > 0
			&& currScreenNames.length < mOldScreenPath.size())
		{
			// 默认为true（若遍历完成都没有改变，则是子集）
			isBack = true;
			
			
			for (int i = 0; 
				i < currScreenNames.length && i < mOldScreenPath.size();
				i++)
			{
				String currScreenName = currScreenNames[i];
				String oldScreenName = mOldScreenPath.get(i);
				if (!currScreenName.equals(oldScreenName)) {
					// 有节点不相等，不是子集
					isBack = false;
				}
				i++;
			}
		}
		
		// 若当前ScreenPath是旧的子集，则是返回的Screen路径
		if (isBack) {
			backScreenPath = currScreenPath + SCREENPATH_BACK_SIGN;
		}
		
		return backScreenPath;
	}
	
	// ------------------- activity stack处理 ---------------------
	/**
	 * 获取栈中的activity item
	 * @param activity
	 * @return
	 */
	public AnalyticsActivityItem GetActivityItem(Activity activity)
	{
		AnalyticsActivityItem result = null;
		for (AnalyticsActivityItem item : mActivityStack)
		{
			if (item.mActivity == activity) {
				result = item;
				break;
			}
		}
		return result;
	}
	
	/**
	 * 获取栈指定activity item的前一个activity item
	 * @param activity
	 * @return
	 */
	private AnalyticsActivityItem GetPreActivityItem(Activity activity)
	{
		boolean found = false;
		AnalyticsActivityItem preItem = null;
		for (AnalyticsActivityItem item : mActivityStack)
		{
			if (item.mActivity == activity) {
				found = true;
				break;
			}
			preItem = item;
		}
		return found ? preItem : null;
	}
	
	/**
	 * 移除activity item
	 * @param item
	 * @return
	 */
	private boolean RemoveActivityItem(AnalyticsActivityItem item)
	{
		boolean result = false;
		result = mActivityStack.remove(item);
		return result;
	}
	
	/**
	 * 移除activity
	 * @param activity
	 * @return
	 */
	private boolean RemoveActivityItem(Activity activity)
	{
		boolean result = false;
		AnalyticsActivityItem item = GetActivityItem(activity);
		if (null != item) {
			RemoveActivityItem(item);
		}
		return result;
	}
	
	/**
	 * 添加activity item
	 * @param item
	 * @return
	 */
	private boolean AddActivityItem(AnalyticsActivityItem item)
	{
		boolean result = false;
		if (null == GetActivityItem(item.mActivity))
		{
			result = mActivityStack.add(item);
		}
		return result;
	}
	
	/**
	 * 判断当前activity栈中的最后一个
	 * @param activity
	 * @return
	 */
	private boolean IsCurrActivityItem(Activity activity)
	{
		boolean result = false;
		if (!mActivityStack.isEmpty())
		{
			AnalyticsActivityItem item = mActivityStack.get(mActivityStack.size() - 1);
			result = (item.mActivity == activity);
		}
		return result;
	}
	
	/**
	 * 获取上一个activity screenName
	 * @param activity
	 * @return
	 */
	private String GetPreActivityScreenName(Activity activity)
	{
		String preScreenName = "";
		AnalyticsActivityItem preItem = GetPreActivityItem(activity);
		if (null != preItem) {
			preScreenName = GetScreenName(preItem.mActivity, false, "");
		}
		return preScreenName;
	}
	
	/**
	 * 获取当前activity的screen路径list
	 * @return
	 */
	private ArrayList<String> GetCurrActivityScreenPathList()
	{
		ArrayList<String> screenPathList = new ArrayList<String>();
		if (!mActivityStack.isEmpty())
		{
			// 获取当前activity的父screen path list
			AnalyticsActivityItem item = mActivityStack.get(mActivityStack.size()-1);
			screenPathList.addAll(item.mParentScreenPathList);
			
			// 添加当前activity的screen name
			String screenName = GetScreenName(item.mActivity, true, "");
			if (!screenName.isEmpty()) {
				screenPathList.add(screenName);
			}
		}
		return screenPathList;
	}
	
	/**
	 * activity destroy时更新screen路径
	 * @param activity
	 */
	private void UpdateScreenPathWithOnDestroy(Activity activity)
	{
		// 获取当前activity的screen name
		String screenName = GetScreenName(activity, false, "");
		
		// 更新screen path
		if (!mActivityStack.isEmpty() && !screenName.isEmpty())
		{
			if (!IsCurrActivityItem(activity))
			{
				// 不是destroy当前activity，更新所有非activity的screen path
				for (AnalyticsActivityItem acItem : mActivityStack) 
				{
					if (acItem.mActivity != activity)
					{
						int i = 0;
						while (i < acItem.mParentScreenPathList.size()) 
						{
							// 删除screen path中对应的screen name
							if (acItem.mParentScreenPathList.get(i).equals(screenName)) {
								acItem.mParentScreenPathList.remove(i);
								continue;
							}
							i++;
						}
					}
				}
			}
		}
	}
	
	// ------------------- ScreenName转换处理 --------------------
	/**
	 * 把Activity名称转换为ScreenName
	 * @param activityName
	 * @return
	 */
	private String ActivityNameToScreenName(String activityName)
	{
		String screenName = "";
		// 通过配置文件转换ScreenName
		try {
			String resName = activityName.replaceAll("\\.", ACTIVITYNAME_SEPARATOR);
			resName = resName.replaceAll("-", ACTIVITYNAME_SEPARATOR);
			Field f = R.string.class.getField(resName);
			Integer sid = f.getInt(null);
			screenName = mApplication.getResources().getString(sid);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return screenName;
	}
	
	/**
	 * 获取父ScreenName关键字
	 * @return
	 */
	private String GetScreenNameParentKeyWords()
	{
		String keyWords = "";
		try {
			keyWords = mApplication.getResources().getString(R.string.parent_keywords);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return keyWords;
	}
	
	/**
	 * 获取用于路径的ScreenName
	 * @param activity
	 * @return
	 */
	public String GetToPathScreenName(Activity activity)
	{
		return GetScreenName(activity, true, "");
	}
	
	/**
	 * 获取activity的ScreenName
	 * @param activity			activity
	 * @param keyWordSupport	是否支持关键字替换（是：替换ScreenName中的关键字，否：仅去掉关键字）
	 * @param filterTagName		被过滤的tagName
	 * @return
	 */
	private String GetScreenName(Activity activity, boolean keyWordSupport, String filterTagName)
	{
		String screenName = "";

		// 获取activity name
		String activityName = activity.getClass().getName();
		
		// 尝试组合获取
		AnalyticsActivityItem item = GetActivityItem(activity);
		if (null != item) 
		{
			//hunter修改，优先使用本地设置screenName
			if(activity != null && activity instanceof AnalyticsFragmentActivity){
				screenName = ((AnalyticsFragmentActivity)activity).getCurrentScreenName();
			}

			// 获取tag路径
			String tagName = item.GetCurrTagPath();
			
			// 尝试activity + tag路径
			if (TextUtils.isEmpty(screenName)
				&& !TextUtils.isEmpty(tagName))
			{
				String temp = activityName + item.GetCurrTagPath();
				screenName = ActivityNameToScreenName(temp);
			}

			// 获取父activity
			String preActivityScreenName = GetPreActivityScreenName(activity);
			
			// 尝试仅父activity + activity
			if (TextUtils.isEmpty(screenName)
				&& !TextUtils.isEmpty(preActivityScreenName))
			{
				String temp =  preActivityScreenName + ACTIVITYNAME_SEPARATOR + activityName;
				screenName = ActivityNameToScreenName(temp);
			}
			
			// 尝试父acitivty + activity + tag路径
			if (TextUtils.isEmpty(screenName)
				&& !TextUtils.isEmpty(preActivityScreenName)
				&& !TextUtils.isEmpty(tagName))
			{
				String temp = preActivityScreenName + ACTIVITYNAME_SEPARATOR + activityName + tagName;
				screenName = ActivityNameToScreenName(temp);
			}
			
			// 尝试只用tag路径
			if (TextUtils.isEmpty(screenName)
				&& !TextUtils.isEmpty(tagName))
			{
				screenName = ActivityNameToScreenName(tagName);
			}

			// 解析成功的tagName
			String successTagName = "";
			// 尝试使用各tag节点
			ArrayList<String> tagNameList = item.GetCurrTagNamesWithoutID();
			if (TextUtils.isEmpty(screenName)
				&& null != tagNameList 
				&& !tagNameList.isEmpty())
			{
				for (String tagNodeName : tagNameList)
				{
					// 过滤tagName
					if (!TextUtils.isEmpty(filterTagName)
						&& filterTagName.equals(tagNodeName)) 
					{
						continue;
					}
					
					screenName = ActivityNameToScreenName(tagNodeName);
					if (!TextUtils.isEmpty(screenName)) {
						successTagName = tagNodeName;
						break;
					}
				}
			}
			
			// 替换关键字
			if (!TextUtils.isEmpty(screenName))
			{
				String keyWord = GetScreenNameParentKeyWords();
				if (!TextUtils.isEmpty(keyWord)
					&& screenName.contains(keyWord))
				{
					// screenName去掉关键字
					int filterStart = screenName.indexOf(keyWord, 0) + keyWord.length();
					screenName = screenName.substring(filterStart);
					
					if (keyWordSupport)
					{
						// screenName存在关键字，需要替换
						String parentScreenName = GetScreenName(activity, false, successTagName);
						if (!TextUtils.isEmpty(parentScreenName)) {
							screenName = parentScreenName + SCREENPATH_SEPARATOR + screenName;
						}
					}
				}
			}
		}
		
		// 尝试获取activity的screenName
		if (TextUtils.isEmpty(screenName)) {
			screenName = ActivityNameToScreenName(activityName);
		}
		
		if (TextUtils.isEmpty(screenName)) {
			Log.e("AnalyticsManager", "GetScreenName() is empty, activity:%s, activityName:%s", activity.getClass().getName(), activityName);
		}
		
		return screenName;
	}
	
	/**
	 * 获取带站点名的ScreenName
	 * @param activity
	 * @return
	 */
	public String GetSiteScreenName(Activity activity)
	{
//		String name = "";
		String screenName = GetScreenName(activity, false, "");
//		if (!screenName.isEmpty()) {
//			// 获取站点名称
//			String webName = "";
//			if (null != WebSiteManager.getInstance()
//				&& null != WebSiteManager.getInstance().GetWebSite())
//			{
//				WebSite webSite =  WebSiteManager.getInstance().GetWebSite();
//				webName = webSite.getSiteShortName();
//			}
//
//			name = webName + ACTIVITYNAME_SEPARATOR + screenName;
//		}
		return screenName;
	}
}
