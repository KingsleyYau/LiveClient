package com.qpidnetwork.livemodule.livechat;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.SharedPreferences;
import android.text.TextUtils;
import android.util.Base64;

import com.qpidnetwork.livemodule.livechat.LCEmotionDownloader.EmotionFileType;
import com.qpidnetwork.livemodule.livechat.LCMessageItem.MessageType;
import com.qpidnetwork.livemodule.livechathttprequest.LCRequestJni;
import com.qpidnetwork.livemodule.livechathttprequest.item.OtherEmotionConfigEmotionItem;
import com.qpidnetwork.livemodule.livechathttprequest.item.OtherEmotionConfigItem;
import com.qpidnetwork.qnbridgemodule.util.Log;
import com.qpidnetwork.qnbridgemodule.websitemanager.WebSiteConfigManager;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.util.HashMap;
import java.util.Map.Entry;

/**
 * 高级表情管理类
 * @author Samson Fan
 *
 */
@SuppressLint("UseSparseArrays")
public class LCEmotionManager implements LCEmotionDownloader.LCEmotionDownloaderCallback {
	public interface LCEmotionManagerCallback {
		public void OnDownloadEmotionImage(boolean result, LCEmotionItem emotionItem);
		public void OnDownloadEmotionPlayImage(boolean result, LCEmotionItem emotionItem);
		public void OnDownloadEmotion3gp(boolean result, LCEmotionItem emotionItem);
	}
	
	/**
	 * 高级表情ID与item的map表
	 */
	private HashMap<String, LCEmotionItem> mEmotionMap;
	/**
	 * 正在发送map表（msgId, item）
	 */
	private HashMap<Integer, LCMessageItem> mMsgIdMap;
	/**
	 * 本地缓存目录路径
	 */
	private String mDirPath;
	/**
	 * GetEmotionConfig的RequestId
	 */
	public long mEmotionConfigReqId;
	/**
	 * http下载host
	 */
	private String mHost;
	/**
	 * 文件下载路径
	 */
	private String mDownloadPath;
	private final String mImgPath = "img/";
	private final String mImgExt = ".png";
	private final String m3gpPath = "3gp/";
	private final String m3gpExt = ".3gp";
	private final String mPlayImgPath = "pad/";
	private final String mPlayBigPath = "_b";
	private final String mPlayMidPath = "_m";
	private final String mPlaySmallPath = "_s";
	private final String mPlaySubPath = "_%d";
	private final String mPlayExt = ".png";
	private final String mLocalImgPath = "img/";
	private final String mLocal3gpPath = "3gp/";
	/**
	 * 下载回调
	 */
	private LCEmotionManagerCallback mCallback;
	/**
	 * 高级表情图片下载map表
	 */
	private HashMap<LCEmotionItem, LCEmotionDownloader> mImgDownloadMap;
	/**
	 * 高级表情播放图片下载map表
	 */
	private HashMap<LCEmotionItem, LCEmotionDownloader> mPlayImgDownloadMap;
	/**
	 * 高级表情3gp下载map表
	 */
	private HashMap<LCEmotionItem, LCEmotionDownloader> m3gpDownloadMap;
	/**
	 * 高级表情配置item
	 */
	private OtherEmotionConfigItem mConfigItem;
	/**
	 * 
	 */
	private Context mContext;
	
	public LCEmotionManager() {
		mEmotionMap = new HashMap<String, LCEmotionItem>();
		mMsgIdMap = new HashMap<Integer, LCMessageItem>();
		mEmotionConfigReqId = LCRequestJni.InvalidRequestId;
		mDownloadPath = "";
		mDirPath = "";
		mHost = "";
		mCallback = null;
		mImgDownloadMap = new HashMap<LCEmotionItem, LCEmotionDownloader>();
		m3gpDownloadMap = new HashMap<LCEmotionItem, LCEmotionDownloader>();
		mPlayImgDownloadMap = new HashMap<LCEmotionItem, LCEmotionDownloader>();
		mContext = null;
		mConfigItem = null;
	}
	
	/**
	 * 初始化
	 * @param dirPath	高级表情本地缓存目录路径
	 * @param host		http下载host
	 * @return
	 */
	public boolean init(Context context, String dirPath, String host, String logPath, LCEmotionManagerCallback callback) 
	{
		boolean result = false;
		if (!dirPath.isEmpty() 
				&& !host.isEmpty() 
				&& !logPath.isEmpty()
				&& null != callback
				&& context != null) 
		{
			result = true;
			
			mDirPath = dirPath;
			if (!mDirPath.regionMatches(mDirPath.length()-1, "/", 0, 1)) {
				mDirPath += "/";
			}
			
			// 创建高级表情image文件目录
			if (result)
			{
				result = false;
				
				String strDir = getImageDir();
				File dir = new File(strDir);
				if (!dir.exists()) {
					result = dir.mkdirs();
				}
				else {
					result = true;
				}
			}
			
			// 创建高级表情3gp文件目录
			if (result)
			{
				result = false;
				
				String strDir = get3gpDir();
				File dir = new File(strDir);
				if (!dir.exists()) {
					result = dir.mkdirs();
				}
				else {
					result = true;
				}
			}
			
			// 其它
			if (result)
			{
				mHost = host;
				if (!mHost.regionMatches(mHost.length()-1, "/", 0, 1)) {
					mHost += "/";
				}
				
				mCallback = callback;
				mContext = context;
				
				// 从文件中读取配置
				if (GetConfigItemWithFile()) {
					// 设置下载路径
					setDownloadPath(mConfigItem.path);
					// 添加高级表情
					addEmotionsWithConfigItem(mConfigItem);
				}
			}
			
//			// 设置 ImageHandler打log目录
//			ImageHandler.SetLogPath(logPath);
		}
		return result;
	}
	
	/**
	 * 设置下载路径
	 * @param downloadPath
	 * @return
	 */
	public boolean setDownloadPath(String downloadPath) {
		boolean result = false;
		if (!downloadPath.isEmpty()) {
			mDownloadPath = downloadPath;
			if (!mDownloadPath.regionMatches(mDownloadPath.length()-1, "/", 0, 1)) {
				mDownloadPath += "/";
			}
			
			if (mDownloadPath.regionMatches(0, "/", 0, 1)) {
				mDownloadPath = mDownloadPath.substring(1);
			}
			result = true;
		}
		return result;
	}
	
	// ------------------- 高级表情配置操作 --------------------
	/**
	 * 从文件中获取配置item
	 * @return
	 */
	public boolean GetConfigItemWithFile() {
		boolean result = false;

		ByteArrayInputStream bais = null;
		ObjectInputStream ois = null;
        try {  
        	String key = "OtherEmotionConfigItem_" + WebSiteConfigManager.getInstance().getCurrentWebSite().getSiteId();
            SharedPreferences mSharedPreferences = mContext.getSharedPreferences("base64", Context.MODE_PRIVATE);  
            String personBase64 = mSharedPreferences.getString(key, "");

			// 2018/11/10 Hardy
			if (TextUtils.isEmpty(personBase64)) {
				return result;
			}

			byte[] base64Bytes = Base64.decode(personBase64.getBytes(), Base64.DEFAULT);
            bais = new ByteArrayInputStream(base64Bytes);
            ois = new ObjectInputStream(bais);

            mConfigItem = (OtherEmotionConfigItem) ois.readObject();
            if (null != mConfigItem) {
            	result = true;
            }
        } catch (Exception e) {  
            e.printStackTrace();  
        }
		// 2018/11/10 Hardy
		finally {
			try {
				if (bais != null) {
					bais.close();
				}
				if (ois != null) {
					ois.close();
				}
			} catch (IOException e) {
				e.printStackTrace();
			}
		}

		return result;
	}
	
	/**
	 * 把配置item保存到文件
	 * @return
	 */
	public boolean SaveConfigItemToFile() 
	{
		boolean result = false;
		if (null != mConfigItem
			&& null != mContext) 
		{

			ByteArrayOutputStream baos = null;
			ObjectOutputStream oos = null;

			try {
				String key = "OtherEmotionConfigItem_" + WebSiteConfigManager.getInstance().getCurrentWebSite().getSiteId();
				SharedPreferences mSharedPreferences = mContext.getSharedPreferences("base64", Context.MODE_PRIVATE);

				baos = new ByteArrayOutputStream();
				oos = new ObjectOutputStream(baos);
		        oos.writeObject(mConfigItem);

		        String personBase64 = new String(Base64.encode(baos.toByteArray(), Base64.DEFAULT));  
		        SharedPreferences.Editor editor = mSharedPreferences.edit();  
		        editor.putString(key, personBase64);  
		        result = editor.commit();

			} catch (IOException e) {
				e.printStackTrace();
			}
			// 2018/11/10 Hardy
			finally {
				try {
					if (baos != null) {
						baos.close();
					}
					if (oos != null) {
						oos.close();
					}
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}

		return result;
	}
	
	/**
	 * 判断版本是否比当前配置版本新
	 * @param version
	 * @return
	 */
	public boolean IsVerNewThenConfigItem(int version)
	{
		boolean result = true;
		if (null != mConfigItem) {
			//result = (version > mConfigItem.version);
			// 版本号不同就更新
			result = (version != mConfigItem.version);
		} 
		return result;
	}
	
	/**
	 * 更新配置
	 * @param configItem
	 * @return
	 */
	public boolean UpdateConfigItem(OtherEmotionConfigItem configItem) 
	{
		boolean result = false;
		if (null != configItem) {
			result = true;
			// 停止图片文件下载
			StopAllDownloadImage();
			// 停止3gp文件下载
			StopAllDownload3gp();
			// 删除本地缓存目录下所有文件
			DeleteAllEmotionFile();
			// 删除所有高级表情item
			removeAllEmotionItem();
			
			mConfigItem = configItem;

			// 保存配置
			SaveConfigItemToFile();
			// 设置下载路径
			setDownloadPath(mConfigItem.path);
			// 添加高级表情
			addEmotionsWithConfigItem(mConfigItem);
		}
		return result;
	}
	
	/**
	 * 获取配置item
	 * @return
	 */
	public OtherEmotionConfigItem GetConfigItem() 
	{
		return mConfigItem;
	}
	
	// ------------------- 高级表情ID的map表操作 --------------------
	/**
	 * 添加配置item的高级表情至map
	 * @param configItem
	 */
	private void addEmotionsWithConfigItem(OtherEmotionConfigItem configItem) 
	{
		addEmotions(configItem.manEmotionList);
		addEmotions(configItem.ladyEmotionList);
	}
	
	/**
	 * 批量添加高级表情至map
	 * @param items
	 */
	private void addEmotions(OtherEmotionConfigEmotionItem[] items) {
		for (int i = 0; i < items.length; i++) {
			if (!items[i].fileName.isEmpty()) {
				getEmotion(items[i].fileName);
			}
		}
	}
	
	/**
	 * 添加高级表情至map
	 * @param item		高级表情item
	 * @return
	 */
	private boolean addEmotion(LCEmotionItem item) {
		boolean result = false;
		if (!item.emotionId.isEmpty()) 
		{
			synchronized(mEmotionMap)
			{
				// add to map
				LCEmotionItem old = mEmotionMap.get(item.emotionId);
				if (null == old) 
				{
					// 判断image文件是否存在，若存在则赋值
					String imagePath = getImagePath(item.emotionId);
					File fimage = new File(imagePath);
					if (fimage.exists()) {
						item.imagePath = imagePath;
					}
					
					// 判断3gp文件是否存在，若存在则赋值
					String f3gpPath = get3gpPath(item.emotionId);
					File f3gp = new File(f3gpPath);
					if (f3gp.exists()) {
						item.f3gpPath = f3gpPath;
					}
					
					mEmotionMap.put(item.emotionId, item);
					result = true;
				}
			}
		}
		else {
			Log.e("livechat", String.format("%s::%s() emotionId is empty.", "LCEmotionManager", "addEmotion"));
		}
		return result;
	}
	
	/**
	 * 获取/添加高级表情item
	 * @param emotionId	高级表情item
	 * @return
	 */
	public LCEmotionItem getEmotion(String emotionId) {
		LCEmotionItem item = null;
		synchronized(mEmotionMap) {
			item = mEmotionMap.get(emotionId);
		}
		
		if (null == item) {
			item = new LCEmotionItem();
			item.init(emotionId
					, getImagePath(emotionId)
					, get3gpPath(emotionId)
					, getPlayBigImagePath(emotionId)
					, getPlayBigSubImagePath(emotionId)
//					, getPlayMidImagePath(emotionId)
//					, getPlayMidSubImagePath(emotionId)
//					, getPlaySmallImagePath(emotionId)
//					, getPlaySmallSubImagePath(emotionId)
					);
			this.addEmotion(item);
		}
		return item;
	}
	
	/**
	 * 清除所有高级表情item
	 */
	public void removeAllEmotionItem() {
		synchronized(mEmotionMap)
		{
			mEmotionMap.clear();
		}
	}
	
	// ------------------- 路径处理（包括URL及本地路径） --------------------
	/**
	 * 获取高级表情图片目录
	 * @return
	 */
	private String getImageDir()
	{
		String fImageDir = mDirPath + mLocalImgPath;
		return fImageDir;
	}
	
	/**
	 * 获取缩略图路径
	 * @param emotionId	高级表情ID
	 * @return
	 */
	public String getImagePath(String emotionId) {
		String imagePath = getImageDir() + emotionId;// + mImgExt;
		return imagePath;
	}
	
	/**
	 * 获取高级表情图片下载URL
	 * @param emotionId	高级表情ID
	 * @return
	 */
	public String getImageURL(String emotionId) {
		String url = mHost + mDownloadPath + mImgPath + emotionId + mImgExt;
		return url;
	}
	
	/**
	 * 获取播放大图的下载URL
	 * @param emotionId	高级表情ID
	 * @return
	 */
	public String getPlayBigImageUrl(String emotionId) {
		String url = mHost + mDownloadPath + mPlayImgPath + emotionId + mPlayBigPath + mPlayExt;
		return url;
	}
	
	/**
	 * 获取播放大图路径
	 * @param emotionId	高级表情ID
	 * @return
	 */
	public String getPlayBigImagePath(String emotionId) {
		String url = getImageDir() + emotionId + mPlayBigPath;
		return url;
	}
	
	/**
	 * 获取播放大图的子图路径(带%s，需要转换)
	 * @param emotionId	高级表情ID
	 * @return
	 */
	public String getPlayBigSubImagePath(String emotionId) {
		String url = getImageDir() + emotionId + mPlayBigPath + mPlaySubPath;
		return url;
	}
	
	/**
	 * 获取播放中图的下载URL
	 * @param emotionId	高级表情ID
	 * @return
	 */
	public String getPlayMidImageUrl(String emotionId) {
		String url = mHost + mDownloadPath + mPlayImgPath + emotionId + mPlayMidPath + mPlayExt;
		return url;
	}
	
	/**
	 * 获取播放中图路径
	 * @param emotionId	高级表情ID
	 * @return
	 */
	public String getPlayMidImagePath(String emotionId) {
		String url = getImageDir() + emotionId + mPlayMidPath;
		return url;
	}
	
	/**
	 * 获取播放中图的子图路径(带%s，需要转换)
	 * @param emotionId	高级表情ID
	 * @return
	 */
	public String getPlayMidSubImagePath(String emotionId) {
		String url = getImageDir() + emotionId + mPlayMidPath + mPlaySubPath;
		return url;
	}
	
	/**
	 * 获取播放小图的下载URL
	 * @param emotionId	高级表情ID
	 * @return
	 */
	public String getPlaySmallImageUrl(String emotionId) {
		String url = mHost + mDownloadPath + mPlayImgPath + emotionId + mPlaySmallPath + mPlayExt;
		return url;
	}
	
	/**
	 * 获取播放小图路径
	 * @param emotionId	高级表情ID
	 * @return
	 */
	public String getPlaySmallImagePath(String emotionId) {
		String url = getImageDir() + emotionId + mPlaySmallPath;
		return url;
	}
	
	/**
	 * 获取播放小图的子图路径(带%s，需要转换)
	 * @param emotionId	高级表情ID
	 * @return
	 */
	public String getPlaySmallSubImagePath(String emotionId) {
		String url = getImageDir() + emotionId + mPlaySmallPath + mPlaySubPath;
		return url;
	}
	
	/**
	 * 获取高级表情3gp目录
	 * @return
	 */
	private String get3gpDir()
	{
		String f3gpDir = mDirPath + mLocal3gpPath;
		return f3gpDir;
	}
	
	/**
	 * 获取高级表情文件路径
	 * @param emotionId	高级表情ID
	 * @return
	 */
	public String get3gpPath(String emotionId) {
		String f3gpPath = get3gpDir() + emotionId;
		return f3gpPath;
	}
	
	/**
	 * 获取高级表情3gp下载URL
	 * @param emotionId	高级表情ID
	 * @return
	 */
	public String get3gpURL(String emotionId) {
		String url = mHost + mDownloadPath + m3gpPath + emotionId + m3gpExt;
		return url;
	}
	
	/**
	 * 删除所有高级表情文件（包括图片及3gp）
	 */
	private void DeleteAllEmotionFile()
	{
		// 删除3gp目录文件
		String str3gpDir = get3gpDir();
		File f3gpDir = new File(str3gpDir);
		if (f3gpDir.exists() && f3gpDir.isDirectory()) {
			File[] files = f3gpDir.listFiles();
			if(files != null){
				for (int i = 0; i < files.length; i++) {
					if (files[i].isFile() || files[i].isDirectory()) {
						files[i].delete();
					} 
				}
			}
		}
		
		// 删除image目录文件
		String strImageDir = getImageDir();
		File fImageDir = new File(strImageDir);
		if (fImageDir.exists() && fImageDir.isDirectory()) {
			File[] files = fImageDir.listFiles();
			if(files != null){
				for (int i = 0; i < files.length; i++) {
					if (files[i].isFile() || files[i].isDirectory()) {
						files[i].delete();
					} 
				}
			}
		}
	}
	
	// ------------------- 高级表情发送map表操作 --------------------
	/**
	 * 获取并移除待发送的item
	 * @param msgId	消息ID
	 * @return
	 */
	public LCMessageItem getAndRemoveSendingItem(int msgId) {
		LCMessageItem item = null;
		synchronized(mMsgIdMap)
		{
			item = mMsgIdMap.remove(msgId);
		}
		
		if (null == item) {
			Log.e("livechat", String.format("%s::%s() fail msgId: %d", "LCEmotionManager", "getAndRemoveSendingItem", msgId));
		}
		return item;
	}
	
	/**
	 * 添加待发送item
	 * @param item	消息item
	 * @return
	 */
	public boolean addSendingItem(LCMessageItem item) {
		boolean result = false;
		synchronized(mMsgIdMap)
		{
			if (item.msgType == MessageType.Emotion
					&& null != item.getEmotionItem()
					&& null == mMsgIdMap.get(item.msgId)) 
			{
				mMsgIdMap.put(item.msgId, item);
				result = true;
			}
			else {
				Log.e("livechat", String.format("%s::%s() fail msgId: %d", "LCEmotionManager", "addSendingItem", item.msgId));
			}
		}
		return result;
	}
	
	/**
	 * 清除所有待发送item
	 */
	public void removeAllSendingItems() {
		synchronized(mMsgIdMap)
		{
			mMsgIdMap.clear();
		}
	}
	
	// ------------ 下载image ------------
	/**
	 * 开始下载image
	 * @param item	高级表情item
	 * @return
	 */
	public boolean StartDownloadImage(LCEmotionItem item) {
		boolean result = false;
		synchronized(mImgDownloadMap) {
			if (null == mImgDownloadMap.get(item) && !item.emotionId.isEmpty()) 
			{
				LCEmotionDownloader loader = new LCEmotionDownloader(mContext);
				result = loader.Start(
						getImageURL(item.emotionId)
						, getImagePath(item.emotionId)
						, EmotionFileType.fimage
						, item
						, this);
				
				if (result) {
					mImgDownloadMap.put(item, loader);
				}
			}
		}
		return result;
	}
	
	/**
	 * 停止下载image
	 * @param item	高级表情item
	 * @return
	 */
	public boolean StopDownloadImage(LCEmotionItem item) {
		boolean result = false;
		synchronized(mImgDownloadMap) {
			LCEmotionDownloader loader = mImgDownloadMap.get(item);
			if (null != loader) {
				loader.Stop();
				result = true;
			}
		}
		return result;
	}
	
	public boolean StopAllDownloadImage() {
		boolean result = false;
		synchronized(mImgDownloadMap) {
			for (Entry<LCEmotionItem, LCEmotionDownloader> entry: mImgDownloadMap.entrySet()) {
				LCEmotionDownloader loader = entry.getValue();
				loader.Stop();
			}
		}
		return result;
	}
	
	// ------------ 下载3gp ------------
	public boolean StartDownload3gp(LCEmotionItem item) {
		boolean result = false;
		synchronized(m3gpDownloadMap) {
			if (null == m3gpDownloadMap.get(item) && !item.emotionId.isEmpty()) 
			{
				LCEmotionDownloader loader = new LCEmotionDownloader(mContext);
				result = loader.Start(
						get3gpURL(item.emotionId)
						, get3gpPath(item.emotionId)
						, EmotionFileType.f3gp
						, item
						, this);
				
				if (result) {
					m3gpDownloadMap.put(item, loader);
				}
			}
		}
		return result;
	}
	
	public boolean StopDownload3gp(LCEmotionItem item) {
		boolean result = false;
		synchronized(m3gpDownloadMap) {
			LCEmotionDownloader loader = m3gpDownloadMap.get(item);
			if (null != loader) {
				loader.Stop();
				result = true;
			}
		}
		return result;
	}
	
	public boolean StopAllDownload3gp() {
		boolean result = false;
		synchronized(m3gpDownloadMap) {
			for (Entry<LCEmotionItem, LCEmotionDownloader> entry: m3gpDownloadMap.entrySet()) {
				LCEmotionDownloader loader = entry.getValue();
				loader.Stop();
			}
		}
		return result;
	}
	
	// ------------ 下载播放image ------------
	/**
	 * 开始下载播放image
	 * @param item	高级表情item
	 * @return
	 */
	public boolean StartDownloadPlayImage(LCEmotionItem item) {
		boolean result = false;
		synchronized(mPlayImgDownloadMap) {
			if (null == mPlayImgDownloadMap.get(item) && !item.emotionId.isEmpty()) 
			{
				LCEmotionDownloader loader = new LCEmotionDownloader(mContext);
				result = loader.Start(
						getPlayBigImageUrl(item.emotionId)
						, getPlayBigImagePath(item.emotionId)
						, EmotionFileType.fplaybigimage
						, item
						, this);
				
				if (result) {
					mPlayImgDownloadMap.put(item, loader);
				}
			}
		}
		return result;
	}
	
	/**
	 * 停止下载播放image
	 * @param item	高级表情item
	 * @return
	 */
	public boolean StopDownloadPlayImage(LCEmotionItem item) {
		boolean result = false;
		synchronized(mPlayImgDownloadMap) {
			LCEmotionDownloader loader = mPlayImgDownloadMap.get(item);
			if (null != loader) {
				loader.Stop();
				result = true;
			}
		}
		return result;
	}
	
	public boolean StopAllDownloadPlayImage() {
		boolean result = false;
		synchronized(mPlayImgDownloadMap) {
			for (Entry<LCEmotionItem, LCEmotionDownloader> entry: mPlayImgDownloadMap.entrySet()) {
				LCEmotionDownloader loader = entry.getValue();
				loader.Stop();
			}
		}
		return result;
	}
	
	// ------------- LCEmotionDownloader.LCEmotionDownloaderCallback -------------
	@Override
	public void onSuccess(LCEmotionDownloader.EmotionFileType fileType, LCEmotionItem item) 
	{
		if (mCallback != null) {
			switch (fileType) 
			{
			case f3gp: {
				mCallback.OnDownloadEmotion3gp(true, item);
				synchronized(m3gpDownloadMap) {
					m3gpDownloadMap.remove(item);
				}
			} break;
			case fimage: {
				mCallback.OnDownloadEmotionImage(true, item);
				synchronized(mImgDownloadMap) {
					mImgDownloadMap.remove(item);
				}
			} break;
			case fplaybigimage: {
				boolean result = false;
//				if (ImageHandler.ConvertEmotionPng(item.playBigPath)) {
//					// 裁剪播放图片成功
//					result = item.setPlayBigSubPath(getPlayBigSubImagePath(item.emotionId));
//				}

				if (!result) {
					// 裁剪播放图片失败
					// 删除文件
					File file = new File(item.playBigPath);
					if (file.exists()) {
						file.delete();
					}
					// 把路径置空
					item.playBigPath = "";
					item.playBigImages.clear();
				}
//				long end = System.currentTimeMillis();
//				long diff = end - begin;
//				// 打印裁剪播放图片使用时间
//				Log.d("LiveChatManager", String.format("LCEmotionManager::onSuccess() diff:%d", diff));
				
				mCallback.OnDownloadEmotionPlayImage(result, item);
				synchronized(mPlayImgDownloadMap) {
					mPlayImgDownloadMap.remove(item);
				}
			} break;
			default:
				break;
			}
		}
	}
	
	@Override
	public void onFail(LCEmotionDownloader.EmotionFileType fileType, LCEmotionItem item)
	{
		if (mCallback != null) {
			switch (fileType) 
			{
			case f3gp: {
				mCallback.OnDownloadEmotion3gp(false, item);
				synchronized(m3gpDownloadMap) {
					m3gpDownloadMap.remove(item);
				}
			} break;
			case fimage: {
				mCallback.OnDownloadEmotionImage(false, item);
				synchronized(mImgDownloadMap) {
					mImgDownloadMap.remove(item);
				}
			} break;
			case fplaybigimage: {
				mCallback.OnDownloadEmotionPlayImage(false, item);
				synchronized(mPlayImgDownloadMap) {
					mPlayImgDownloadMap.remove(item);
				}
			} break;
			default:
				break;
			}
		}
	}
}
