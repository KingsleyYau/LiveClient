package com.qpidnetwork.livemodule.livechat;

import android.content.Context;
import android.text.TextUtils;
import android.util.Log;

import com.qpidnetwork.livemodule.livechat.LCThemeItemDownloader.LCThemeItemDownloaderCallback;
import com.qpidnetwork.livemodule.livechat.jni.LCPaidThemeInfo;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient;
import com.qpidnetwork.livemodule.livechathttprequest.item.ThemeConfig;
import com.qpidnetwork.qnbridgemodule.datacache.FileCacheManager;
import com.qpidnetwork.qnbridgemodule.util.Arithmetic;
import com.qpidnetwork.qnbridgemodule.util.FileUtil;
import com.qpidnetwork.qnbridgemodule.websitemanager.WebSiteConfigManager;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.zip.ZipException;

public class LCThemeManager implements LCThemeItemDownloaderCallback {
	
	private Context mContext;
	/**
	 * 下载回掉
	 */
	private LCThemeDownloadCallback mCallback;
	/**
	 * 主题包正在下载列表
	 */
	private HashMap<String, LCThemeItemDownloader> mThemeDownloadMap;
	/**
	 * 我的主题本地维护
	 */
	private HashMap<String, List<LCPaidThemeInfo>> mMySceneMap;
	
	/**
	 * 记录正在购买的主题列表，防止重复购买及用于界面状态显示
	 */
	private HashMap<String, Boolean> mThemeBuying;
	/**
	 * 用于记录当前主题下载进度
	 */
	private HashMap<String, Integer> mThemeDownloadProgressMap;
	
	public LCThemeManager(Context context, LCThemeDownloadCallback callback) {
		mContext = context;
		mCallback = callback;
		mThemeDownloadMap = new HashMap<String, LCThemeItemDownloader>();
		mMySceneMap = new HashMap<String, List<LCPaidThemeInfo>>();
		mThemeBuying = new HashMap<String, Boolean>();
		mThemeDownloadProgressMap = new HashMap<String, Integer>();
	}
	
	/**
	 * 开始下载
	 * @param themeId
	 * @return
	 */
	public boolean StartDownload(String themeId) {
		boolean result = false;
		synchronized(mThemeDownloadMap) {
			if (null == mThemeDownloadMap.get(themeId) && !TextUtils.isEmpty(themeId)) 
			{
				Log.i("LCThemeManager", "LCThemeManager StartDownload themeId: " + themeId);
				LCThemeItemDownloader loader = new LCThemeItemDownloader(mContext);
				result = loader.Start(
						getThemeZipUrl(themeId)
						, getThemeZipLocalPath(themeId)
						, themeId
						, this);
				
				if (result) {
					mThemeDownloadMap.put(themeId, loader);
				}
			}else{
				result = true;
			}
		}
		return result;
	}
	
	/**
	 * 获取Zip包下载路径
	 */
	private String getThemeZipUrl(String themeId){
		String zipUrl = "";
		ThemeConfig config = ThemeConfigManager.newInstance().getThemeConfig();
		if(config != null){
			zipUrl += WebSiteConfigManager.getInstance().getCurrentWebSite().getWebSiteHost() ;
			zipUrl += config.themePath ;
			zipUrl += "source/";
			zipUrl += themeId + "/";
			zipUrl += "app.zip";
		}
		return zipUrl;
	}
	
	/**
	 * 获取下载Zip存放路径
	 * @param themeId
	 * @return
	 */
	private String getThemeZipLocalPath(String themeId){
		String localPath = "";
		localPath += FileCacheManager.getInstance().getThemeSavePath();
		localPath += Arithmetic.MD5(themeId.getBytes(), themeId.getBytes().length);
		localPath += ".zip";
		return localPath;
	}
	
	/**
	 * 获取解压完成文件的根路径
	 * @param themeId
	 * @return
	 */
	public String getThemeSourceLocalPath(String themeId){
		String localDir = "";
		localDir += FileCacheManager.getInstance().getThemeSavePath();
		localDir += themeId + "/";
		File file = new File(localDir);
		if(!file.exists()){
			file.mkdir();
		}
		return localDir;
	}
	
	/**
	 * 本地是否已经存在，无需重新下载
	 * @return
	 */
	public boolean isThemeSourceExist(String themeId){
		boolean isExist = false;
		String themeZipPath = getThemeZipLocalPath(themeId);
		if(!TextUtils.isEmpty(themeZipPath)&&
				(new File(themeZipPath).exists())){
			isExist = true;
		}
		return isExist;
	}
	
	@Override
	public void onSuccess(String themeId, String localPath) {
		String sourceDir = getThemeSourceLocalPath(themeId);
		try {
			FileUtil.upZipFile(localPath, sourceDir);
		} catch (ZipException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		if(mCallback != null){
			mCallback.onDownloadThemeFinish(true, themeId, sourceDir);
		}
		synchronized(mThemeDownloadMap) {
			mThemeDownloadMap.remove(themeId);
		}
	}

	@Override
	public void onFail(String themeId, String localPath) {
		if(mCallback != null){
			mCallback.onDownloadThemeFinish(false, themeId, "");
		}
		synchronized(mThemeDownloadMap) {
			mThemeDownloadMap.remove(themeId);
		}
	}

	@Override
	public void onUpdate(String themeId, String localPath, int progress) {
//		if(mCallback != null){
//			mCallback.onDownloadThemeUpdating(themeId, progress);
//		}
		synchronized (mThemeDownloadProgressMap) {
			if(mThemeDownloadProgressMap != null){
				mThemeDownloadProgressMap.put(themeId, Integer.valueOf(progress));
			}
		}
	}
	
	/**
	 * 获取当前主题下载进度
	 * @param themeId
	 */
	public int getThemeDownloadProgress(String themeId){
		int progress = 0;
		synchronized (mThemeDownloadProgressMap) {
			if(mThemeDownloadProgressMap.containsKey(themeId)){
				progress = mThemeDownloadProgressMap.get(themeId);
			}
		}
		return progress;
	}
	
	public interface LCThemeDownloadCallback {
		public void onDownloadThemeStart(String themeId);
		public void onDownloadThemeUpdating(String themeId, int progress);
		public void onDownloadThemeFinish(boolean isSuccess, String themeId, String sourceDir);
	}
	
	/******************************* My Scene本地维护 **************************************/
	
	/**
	 * 获取当前对该女士使用的Id
	 * @param womanId
	 * @return
	 */
	public LCPaidThemeInfo getCurrentUsedTheme(String womanId){
		LCPaidThemeInfo themeInfo = null;
		synchronized (mMySceneMap){
			if(mMySceneMap.containsKey(womanId)){
				List<LCPaidThemeInfo> tempThemeList = mMySceneMap.get(womanId);
				if(tempThemeList.size() > 0){
					themeInfo = tempThemeList.get(0);
				}
			}
		}
		return themeInfo;
	}
	
	/**
	 * 删除指定女士的过期主题
	 */
	public void removeOverTimeTheme(String womanId){
		synchronized (mMySceneMap) {
			List<LCPaidThemeInfo> tempThemeList = mMySceneMap.get(womanId);
			int i = 0;
			while (i < tempThemeList.size()) {
				LCPaidThemeInfo themeInfo = tempThemeList.get(i);
				if (isThemeExpired(themeInfo)) {
					tempThemeList.remove(i);
					continue;
				}			
				i++;
			}
		}
	}
	
	/**
	 * 主题是否过期
	 * @param themeInfo
	 * @return
	 */
	public boolean isThemeExpired(LCPaidThemeInfo themeInfo){
		boolean isExpired = true;
		int currentTime = (int)(System.currentTimeMillis()/1000);
		if(currentTime >= themeInfo.startTime &&
				currentTime < themeInfo.endTime){
			isExpired = false;
		}
		return isExpired;
	}
	
	/**
	 * 获取指定女士指定主题当前状态
	 * @return
	 */
	public ThemeStatus getThemeStatus(String womanId, String themeId){
		ThemeStatus themeStatus = ThemeStatus.NO_PAID;
		synchronized (mMySceneMap) {
			if(mMySceneMap.containsKey(womanId)){
				List<LCPaidThemeInfo> themeList = mMySceneMap.get(womanId);
				for(int i=0; i<themeList.size(); i++){
					if(themeList.get(i).themeId.equals(themeId)){
						if(i==0){
							themeStatus = ThemeStatus.USED;
						}else{
							themeStatus = ThemeStatus.PAID_NO_USED;
						}
						break;
					}
				}
			}
		}
		return themeStatus;
	}
	
	/**
	 * 获取所有已付费主题返回更新
	 * @param paidThemeList
	 */
	public void OnGetAllPaidTheme(LCPaidThemeInfo[] paidThemeList){
		if(paidThemeList != null){
			synchronized (mMySceneMap) {
				//清楚刷新队列
				mMySceneMap.clear();
			}
			for(LCPaidThemeInfo info : paidThemeList){
				updateOrAddPaidTheme(info);
			}
		}
	}
	/**
	 * 男士购买主题更新
	 * @param paidThemeInfo
	 */
	public void OnManFeeTheme(LCPaidThemeInfo paidThemeInfo){
		clearBuyingFlags(paidThemeInfo.womanId, paidThemeInfo.themeId);
		updateOrAddPaidTheme(paidThemeInfo);
	}
	/**
	 * 男士应用主题更新
	 * @param paidThemeInfo
	 */
	public void OnManApplyTheme(LCPaidThemeInfo paidThemeInfo){
		updateOrAddPaidTheme(paidThemeInfo);
	}
	/**
	 * 更新或者添加到当前已购买主题列表
	 */
	private void updateOrAddPaidTheme(LCPaidThemeInfo paidThemeInfo){
		List<LCPaidThemeInfo> themeList = null;
		synchronized (mMySceneMap) {
			if(mMySceneMap.containsKey(paidThemeInfo.womanId)){
				boolean isContain = false;
				themeList = mMySceneMap.get(paidThemeInfo.womanId);
				for(LCPaidThemeInfo item : themeList){
					if(item.themeId.equals(paidThemeInfo.themeId)){
						isContain = true;
						item.startTime = paidThemeInfo.startTime;
						item.endTime = paidThemeInfo.endTime;
						item.now = paidThemeInfo.now;
						item.updateTime = paidThemeInfo.updateTime;
						break;
					}
				}
				if(!isContain){
					themeList.add(paidThemeInfo);
				}
				//根据最后更新时间倒序排序
				Collections.sort(themeList, new Comparator<LCPaidThemeInfo>() {

					@Override
					public int compare(LCPaidThemeInfo lhs, LCPaidThemeInfo rhs) {
						int result = 0;
						if(lhs.updateTime > rhs.updateTime){
							result = -1;
						}else if(lhs.updateTime < rhs.updateTime){
							result = 1;
						}
						return result;
					}
				});
			}else{
				themeList = new ArrayList<LCPaidThemeInfo>();
				themeList.add(paidThemeInfo);
				mMySceneMap.put(paidThemeInfo.womanId, themeList);
			}
		}
	}
	
	public enum ThemeStatus{
		USED,
		PAID_NO_USED,
		NO_PAID,
	}
	
	/************************* 主题购买管理 ***************************************/
	/**
	 * 购买主题
	 * @param womanId
	 * @param themeId
	 * @return
	 */
	public boolean ManFeeTheme(String womanId, String themeId){
		String mapKey = getMapBuyingKey(womanId, themeId);
		synchronized (mThemeBuying) {
			if(mThemeBuying.containsKey(mapKey)){
				//购买中
				return true;
			}
		}
		return LiveChatClient.ManFeeTheme(womanId, themeId);
	}
	
	/**
	 * 清除购买中标志
	 * @param womanId
	 * @param themeId
	 */
	public void clearBuyingFlags(String womanId, String themeId){
		String mapKey = getMapBuyingKey(womanId, themeId);
		synchronized (mThemeBuying) {
			if(mThemeBuying.containsKey(mapKey)){
				mThemeBuying.remove(mapKey);
			}
		}
	}
	
	/**
	 * 指定女士指定主题是否购买中
	 * @param womanId
	 * @param themeId
	 * @return
	 */
	public boolean isThemeBuying(String womanId, String themeId){
		boolean isBuying = false;
		String mapKey = getMapBuyingKey(womanId, themeId);
		synchronized (mThemeBuying) {
			if(mThemeBuying.containsKey(mapKey)){
				isBuying = true;
			}
		}
		return isBuying;
	}
	
	/**
	 * 生成Mapkey
	 * @param womanId
	 * @param themeId
	 * @return
	 */
	private String getMapBuyingKey(String womanId, String themeId){
		String mapKey = "";
		if(!TextUtils.isEmpty(womanId)
				&& !TextUtils.isEmpty(themeId)){
			mapKey += womanId;
			mapKey += "_";
			mapKey += themeId;
		}
		return mapKey;
	}
	
	/**
	 * 注销清除数据，防止数据串
	 */
	public void clear(){
		synchronized (mMySceneMap) {
			mMySceneMap.clear();
		}
	}
}
