package com.qpidnetwork.livemodule.liveshow.googleanalytics;

import java.util.ArrayList;

import android.app.Activity;
import android.app.Application;
import android.text.TextUtils;

import com.google.android.gms.analytics.GoogleAnalytics;
import com.google.android.gms.analytics.HitBuilders;
import com.google.android.gms.analytics.Tracker;
import com.qpidnetwork.qnbridgemodule.util.Log;

/**
 * Analytics管理类（包括GoogleAnalytics、Facebook等）
 * @author Samson Fan
 *
 */
public class AnalyticsManager 
{
	/**
	 * 注册类型
	 */
	public enum RegisterType
	{
		Facebook,	// facebook注册
		MyCompany	// 我司注册
	}
	
	// 单例
	private static AnalyticsManager sInstance = null;
	
	private AnalyticsActivityManager mActivityMgr = new AnalyticsActivityManager();
	
	// 未pause标记
	private boolean mIsNotPause = false;
		
	// 用于跟踪的用户ID
	private String mGaUserId = "";
	
	// GoogleAnalytics变量
	private Tracker mGaTracker = null;
	private GoogleAnalytics mGaAnalytics = null;

	/**
	 * 获取单例
	 * @return
	 */
	public static AnalyticsManager newInstance()
	{
		if (null == sInstance) {
			sInstance = new AnalyticsManager();
		}
		return sInstance;
	}

	public static AnalyticsManager getsInstance(){
		return sInstance;
	}
	
	/**
	 * 构造函数
	 */
	private AnalyticsManager()
	{
	}
	
	/**
	 * 初始化函数
	 * @param application	应用实例
	 * @param configResId	跟踪配置资源ID
	 * @return
	 */
	public boolean init(Application application, int configResId)
	{
		boolean result = false;
		if (null != application) 
		{
			mActivityMgr.SetApplication(application);
			// GA跟踪初始化
			result = GaInit(application, configResId);
		}
		return result;
	}
	
	/**
	 * 设置是否page activity
	 * @param activity
	 * @param isPageActivity
	 */
	public void SetPageActivity(Activity activity, boolean isPageActivity)
	{
		mActivityMgr.SetPageActivity(activity, isPageActivity);
	}
	
	/**
	 * 获取activity当前所有tag名(包含ID)
	 * @param activity
	 * @return
	 */
	public ArrayList<String> GetCurrTagNamesIncludeID(Activity activity)
	{
		return mActivityMgr.GetCurrTagNamesIncludeID(activity);
	}
	
	/**
	 * 获取activity当前所有tag名(不包含ID)
	 * @param activity
	 * @return
	 */
	public ArrayList<String> GetCurrTagNamesWithoutID(Activity activity)
	{
		return mActivityMgr.GetCurrTagNamesWithoutID(activity);
	}
	
	/**
	 * activity onCreate统计
	 * @param activity
	 */
	public void ReportCreate(Activity activity)
	{
		// 添加Activity
		mActivityMgr.AddActivity(activity);
				
		// 打log
		Log.d("AnalyticsManager", "ReportCreate() activityName:%s", activity.getClass().getName());
	}
	
	/**
	 * activity onDestroy统计
	 * @param activity
	 */
	public void ReportDestroy(Activity activity)
	{
		// 更新screen路径
		mActivityMgr.ReportScreenPathWithOnDestroy(activity);
		
		// 移除Activity
		mActivityMgr.RemoveActivity(activity);
				
		// 打log
		Log.d("AnalyticsManager", "ReportDestroy() activityName:%s", activity.getClass().getName());
	}
	
	/**
	 * activity onStart统计
	 * @param activity
	 */
	public void ReportStart(Activity activity) 
	{
		if (null != activity) {
			// 转换screenName
			String screenName = mActivityMgr.GetSiteScreenName(activity);
			
			// 处理start
			if (!screenName.isEmpty()) {
				ReportStartProc(activity, screenName);
			}
		}
	}
	
	/**
	 * activity onResume统计
	 * @param activity
	 */
	public void ReportResume(Activity activity)
	{
		boolean process = true;
		
		// 判断是否需要处理
		process = !mActivityMgr.WasResumeSubmit(activity);
		
		if (process) {
			// 需要处理
			ReportResumeProc(activity);
		}
	}
	
	/**
	 * activity onResume统计处理
	 * @param activity
	 */
	private void ReportResumeProc(Activity activity)
	{
		if (null != activity) 
		{
			// 转换screenName
			String screenName = mActivityMgr.GetSiteScreenName(activity);
			
			// 处理resume
			if (!screenName.isEmpty()) {
				ReportResumeProc(activity, screenName);
				ReportScreenPath(activity);
				mActivityMgr.SetResumeSubmit(activity, true);
			}
		}
	}
	
	/**
	 * activity onPause统计
	 * @param activity
	 */
	public void ReportPause(Activity activity)
	{
		if (null != activity) {
			// 转换screenName
			String screenName = mActivityMgr.GetSiteScreenName(activity);

			// 处理pause
//			if (!screenName.isEmpty() && !mIsNotPause			// 有screenName，而且未曾Pause
//				|| (screenName.isEmpty() && mIsNotPause))		// 异常pause 
			if (mActivityMgr.WasResumeSubmit(activity))
			{
				ReportPauseProc(activity, screenName);
				mActivityMgr.SetResumeSubmit(activity, false);
			}
		}
	}
	
	/**
	 * activity OnStop统计
	 * @param activity
	 */
	public void ReportStop(Activity activity) 
	{
		if (null != activity) {
			// 转换screenName
			String screenName = mActivityMgr.GetSiteScreenName(activity);
			
			// 处理stop
			if (!screenName.isEmpty()) {
				ReportStopProc(activity, screenName);
			}
		}
	}
	
	/**
	 * activity进入页面统计
	 * @param activity	activity
	 * @param tagNames	tag路径(包含ID)
	 */
	public boolean ReportPageSelected(Activity activity, String... tagNames)
	{
		boolean isReport = false;
		if (null != activity) 
		{
			AnalyticsActivityItem item = mActivityMgr.GetActivityItem(activity);
			if (null != item) 
			{
				// 判断是否需要提交
				isReport = mActivityMgr.IsReportCurrPageWithSeleted(activity, tagNames);
				
				// 把之前的tag页置为pause状态
				if (isReport) {
					ReportPause(activity);
				}
				
				// 设置当前tag页
				item.SetCurrTagPath(tagNames);
				
				// 把当前tag页置为resume状态
				if (isReport) {
					ReportResumeProc(activity);
				}
			}
		}
		
		return isReport;
	}
	
	/**
	 * activity onPageSelected统计
	 * @param activity
	 * @param page
	 */
	public boolean ReportPageSelected(Activity activity, int page)
	{
		boolean isReport = false;
		if (null != activity) 
		{
			AnalyticsActivityItem item = mActivityMgr.GetActivityItem(activity);
			if (null != item) 
			{
				String tagName = String.valueOf(page);
				
				// 判断是否需要提交
				isReport = mActivityMgr.IsReportCurrPageWithSeleted(activity, tagName);
				
				// 把之前的tag页置为pause状态
				if (isReport) {
					ReportPause(activity);
				}
				
				// 设置当前tag页
				item.SetCurrTagPath(tagName);
				
				// 把当前tag页置为resume状态
				if (isReport) {
					ReportResumeProc(activity);
				}
			}
		}
		
		return isReport;
	}
	
	/**
	 * activity onPageSelected统计
	 * @param activity
	 * @param tagName
	 */
	public boolean ReportPageSelected(Activity activity, String tagName, int page)
	{
		boolean isReport = false;
		if (null != activity) 
		{
			AnalyticsActivityItem item = mActivityMgr.GetActivityItem(activity);
			if (null != item) 
			{
				// tagName
				String theTagName = tagName + AnalyticsActivityManager.TAGID_SEPARATOR + String.valueOf(page);
				
				// 判断是否需要提交
				isReport = mActivityMgr.IsReportCurrPageWithSeleted(activity, theTagName);
				
				// 把之前的tag页置为pause状态
				if (isReport) {
					ReportPause(activity);
				}
				
				// 设置当前tag页
				item.SetCurrTagPath(theTagName);
				
				// 把当前tag页置为resume状态
				if (isReport) {
					ReportResumeProc(activity);
				}
			}
		}
		
		return isReport;
	}
	
	/**
	 * activity onPageSelected统计
	 * @param activity
	 * @param page
	 * @param subPage
	 */
	public boolean ReportPageSelected(Activity activity, int page, int subPage)
	{
		boolean isReport = false;
		if (null != activity) 
		{
			AnalyticsActivityItem item = mActivityMgr.GetActivityItem(activity);
			if (null != item) 
			{
				// tagName
				String[] tagName = {String.valueOf(page), String.valueOf(subPage)}; 
				
				// 判断是否需要提交
				isReport = mActivityMgr.IsReportCurrPageWithSeleted(activity, tagName);
				
				// 把之前的tag页置为pause状态
				if (isReport) {
					ReportPause(activity);
				}
				
				// 设置当前tag页的子页
				item.SetCurrTagPath(tagName);
				
				// 把当前tag页置为resume状态
				if (isReport) {
					ReportResumeProc(activity);
				}
			}
		}
		
		return isReport;
	}
	
	/**
	 * activity onPageSelected统计
	 * @param activity
	 * @param page
	 * @param subPage
	 * @param subPage2
	 */
	public boolean ReportPageSelected(Activity activity, int page, int subPage, int subPage2)
	{
		boolean isReport = false;	
		if (null != activity) 
		{
			AnalyticsActivityItem item = mActivityMgr.GetActivityItem(activity);
			if (null != item) 
			{
				// tagName
				String[] tagName = {String.valueOf(page), String.valueOf(subPage), String.valueOf(subPage2)}; 
				
				// 判断是否需要提交
				isReport = mActivityMgr.IsReportCurrPageWithSeleted(activity, tagName);
				
				// 把之前的tag页置为pause状态
				if (isReport) {
					ReportPause(activity);
				}
				
				// 设置当前tag页的子页
				item.SetCurrTagPath(tagName);
				
				// 把当前tag页置为resume状态
				if (isReport) {
					ReportResumeProc(activity);
				}
			}
		}
		return isReport;
	}
	
	/**
	 * 统计screen路径
	 */
	public void ReportScreenPath(Activity activity)
	{
		// 提交返回的screen路径
		String backScreenPath = mActivityMgr.GetBackScreenPath(activity);
		if (!backScreenPath.isEmpty()) {
			GaReportScreenPath(backScreenPath);
		}
		
		// 提交screen路径
		String screenPath = mActivityMgr.ReportScreenPath(activity);
		if (!screenPath.isEmpty()) {
			GaReportScreenPath(screenPath);
		}
	}
	
	/**
	 * 统计event
	 */
	public void ReportEvent(String category, String action, String label)
	{
		// Ga统计
		GaReportEvent(category, action, label);
	}
	
	/**
	 * 设置用户跟踪ID
	 * @param gaUserId	用户的跟踪ID
	 */
	public void setGAUserId(String gaUserId)
	{
		if (!TextUtils.isEmpty(gaUserId))
		{
			mGaUserId = gaUserId;
			
			// 设置GA用户跟踪ID
			GaSetUserId(mGaUserId);
		}
	}
	
	/**
	 * 设置用户活动统计
	 * @param gaActivity	活动统计GA值
	 */
	public void setGAActivity(String gaActivity)
	{
		if (!TextUtils.isEmpty(gaActivity))
		{
			
			// 设置GA用户跟踪ID
			GaSetActivity(gaActivity);
		}
	}
	
	/**
	 * GA设置活动统计
	 * @param gaActivity	活动统计GA值	
	 */
	private void GaSetActivity(String gaActivity)
	{
		if (null != mGaTracker
			&& !TextUtils.isEmpty(gaActivity))
		{
			Log.d("AnalyticsManager", "GaSetActivity() activity:%s", gaActivity);
			mGaTracker.send(new HitBuilders.EventBuilder().setCategory("monthGroup").setAction("GA Activity").build());
			mGaTracker.send(new HitBuilders.EventBuilder().setCategory("monthGroup").setCustomDimension(4, gaActivity).build());
		}
	}
	
	/**
	 * 用户注册成功
	 * @param registerType
	 */
	public void RegisterSuccess(RegisterType registerType)
	{
		// GA注册成功统计
		GaRegisterSuccess(registerType);
	}
	
	/**
	 * 获取注册类型提交的字符串
	 * @param registerType	注册类型
	 * @return
	 */
	private String GetRegisterTypeString(RegisterType registerType)
	{
		// 转换注册方式字符串
		String regMethod = "";
		switch (registerType)
		{
		case Facebook:
			regMethod = "Facebook";
			break;
		case MyCompany:
			regMethod = "MyCompany";
			break;
		}
		return regMethod;
	}
	

	
	// ------------------- Report处理 --------------------
	/**
	 * activity onStart统计处理函数
	 * @param activity
	 * @param screenName
	 */
	private void ReportStartProc(Activity activity, String screenName)
	{

	}
	
	/**
	 * activity onStart统计处理函数
	 * @param activity
	 * @param screenName
	 */
	private void ReportStopProc(Activity activity, String screenName)
	{

	}
	
	/**
	 * activity onStart统计处理函数
	 * @param activity
	 * @param screenName
	 */
	private void ReportResumeProc(Activity activity, String screenName)
	{
		if (!mIsNotPause) {
			// 设置未pause标记
			mIsNotPause = true;
			// GA开始activity统计
			GaReportStart(screenName);
		}
		else {
			Log.e("AnalyticsManager", "ReportResumeProc() screenName:%s, mIsNotPause:%b", screenName, mIsNotPause);
		}
	}
	
	/**
	 * activity onStart统计处理函数
	 * @param activity
	 * @param screenName
	 */
	private void ReportPauseProc(Activity activity, String screenName)
	{
		// 重置未pause标记
		mIsNotPause = false;
		
		// 打印异常pause的activity名称
		if (screenName.isEmpty() && null != activity) {
			screenName = activity.getClass().getName();
		}
		
		// GA停止activity统计
		GaReportStop(screenName);
	}
	// -------------- Google Analytics --------------
	/**
	 * GA初始化
	 * @param application	application
	 * @param configResId	
	 * @return
	 */
	private boolean GaInit(Application application, int configResId)
	{
		boolean result = false;
		mGaAnalytics = GoogleAnalytics.getInstance(application);
		if (null != mGaAnalytics) {
			mGaTracker = mGaAnalytics.newTracker(configResId);
		}
		result = (null != mGaTracker && null != mGaAnalytics);
		return result;
	}
	
	/**
	 * GA开始activity统计
	 * @param screenName
	 */
	private void GaReportStart(String screenName) 
	{
		if (null != mGaAnalytics && null != mGaTracker) 
		{
			Log.d("AnalyticsManager", "GaReportStart() screenName:%s", screenName);
			
			mGaTracker.setScreenName(screenName);
			mGaTracker.send(new HitBuilders.ScreenViewBuilder().build());
		}
	}
	
	/**
	 * GA停止activity统计
	 * @param screenName
	 */
	private void GaReportStop(String screenName) 
	{
		if (null != mGaAnalytics && null != mGaTracker) 
		{
			Log.d("AnalyticsManager", "GaReportStop() screenName:%s", screenName);
			mGaAnalytics.dispatchLocalHits();
		}
	}
	
	/**
	 * Ga统计screen路径
	 * @param screenPath
	 */
	private void GaReportScreenPath(String screenPath)
	{
		if (null != mGaAnalytics && null != mGaTracker) 
		{
			Log.d("AnalyticsManager", "GaReportScreenPath() screenPath:%s", screenPath);
			mGaTracker.send(new HitBuilders.EventBuilder()
						    .setCategory("APPActionEvent")
						    .setAction("APPAction")
						    .setLabel(screenPath)
						    .build());
		}
	}
	
	/**
	 * GA设置user id
	 * @param gaUserId	用户的跟踪ID	
	 */
	private void GaSetUserId(String gaUserId)
	{
		if (null != mGaTracker
			&& !TextUtils.isEmpty(gaUserId))
		{
			Log.d("AnalyticsManager", "GaSetUserId() userId:%s", gaUserId);
			
			mGaTracker.set("&uid", gaUserId);
			mGaTracker.send(new HitBuilders.EventBuilder().setCategory("userid").setAction("User Sign In").build());
			mGaTracker.send(new HitBuilders.EventBuilder().setCategory("userid").setCustomDimension(2, gaUserId).build());
		}
	}
	
	/**
	 * GA注册成功
	 */
	private void GaRegisterSuccess(RegisterType registerType)
	{
		if (null != mGaTracker) 
		{
			// 获取注册类型字符串
			String regType = GetRegisterTypeString(registerType);
			
			// 打印log
			Log.d("AnalyticsManager", "GaRegisterSuccess() regType:%s", regType);
			
			// Build and send an Event.
			mGaTracker.send(new HitBuilders.EventBuilder()
				.setCategory("registerCategory")
				.setAction("registerSuccess")
				.setLabel(regType)
				.build());
		}
	}
	
	/**
	 * Ga统计event
	 */
	private void GaReportEvent(String category, String action, String label)
	{
		if (null != mGaTracker) 
		{
			Log.d("AnalyticsManager", "GaReportEvent() category:%s, action:%s, label:%s"
					, category, action, label);
			
			// Build and send an Event.
			mGaTracker.send(new HitBuilders.EventBuilder()
				.setCategory(category)
				.setAction(action)
				.setLabel(label)
				.build());
		}
	}
}
