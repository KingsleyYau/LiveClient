package com.qpidnetwork.livemodule.livechat;

import com.qpidnetwork.livemodule.livechat.jni.LCPaidThemeInfo;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener.LiveChatErrType;
import com.qpidnetwork.livemodule.livechathttprequest.item.ThemeItem;

/**
 * LiveChat管理回调接口类
 * @author Hunter
 * @since 2016.4.26
 */
public interface LiveChatManagerThemeListener {

	/**
	 * 获取指定男/女士已购主题包回调
	 * @param errType
	 * @param errmsg
	 * @param userId
	 * @param paidThemeList
	 */
	public void OnGetPaidTheme(LiveChatErrType errType, String errmsg, String userId, LCPaidThemeInfo[] paidThemeList); 

	/**
	 * 获取男/女士所有已购主题包回调
	 * @param isSuccess
	 * @param errmsg
	 * @param paidThemeList
	 * @param themeList
	 */
	public void OnGetAllPaidTheme(boolean isSuccess, String errmsg, LCPaidThemeInfo[] paidThemeList, ThemeItem[] themeList);

	/**
	 * 男士购买主题包结果回调
	 * @param errType
	 * @param errmsg
	 * @param paidThemeInfo
	 */
	public void OnManFeeTheme(LiveChatErrType errType, String womanId, String themeId, String errmsg, LCPaidThemeInfo paidThemeInfo);

	/**
	 * 男士应用主题包回调
	 * @param errType
	 * @param errmsg
	 * @param paidThemeInfo
	 */
	public void OnManApplyTheme(LiveChatErrType errType, String womanId, String themeId, String errmsg, LCPaidThemeInfo paidThemeInfo);

	/**
	 * 男/女士播放主题包动画回调
	 * @param errType
	 * @param errmsg
	 * @param womanId
	 * @param themeId
	 */
	public void OnPlayThemeMotion(LiveChatErrType errType, String errmsg, String womanId, String themeId);

	/**
	 * 收到女士端播放动画要求回调
	 * @param themeId
	 * @param manId
	 * @param womanId
	 */
	public void OnRecvThemeMotion(String themeId, String manId, String womanId);

	/**
	 * 收到女士推荐主题推送
	 * @param themeId
	 * @param manId
	 * @param womanId
	 */
	public void OnRecvThemeRecommend(String themeId, String manId, String womanId);
	
	/**
	 * 下载主题资源更新进度
	 * @param themeId
	 * @param progress
	 */
	public void onThemeDownloadUpdate(String themeId, int progress);
	
	/**
	 * 下载主题资源成功或失败回调
	 * @param isSuccess
	 * @param themeId
	 * @param sourceDir
	 */
	public void onThemeDownloadFinish(boolean isSuccess, String themeId, String sourceDir);
}
