package com.qpidnetwork.livemodule.livechat;

import android.content.Context;
import android.content.SharedPreferences;
import android.text.TextUtils;
import android.util.Base64;

import com.qpidnetwork.livemodule.livechat.LCMagicIconDownloader.LCMagicIconDownloaderCallback;
import com.qpidnetwork.livemodule.livechat.LCMagicIconDownloader.MagicIconDownloadType;
import com.qpidnetwork.livemodule.livechat.LCMessageItem.MessageType;
import com.qpidnetwork.livemodule.livechathttprequest.LCRequestJni;
import com.qpidnetwork.livemodule.livechathttprequest.item.MagicIconConfig;
import com.qpidnetwork.qnbridgemodule.datacache.FileCacheManager;
import com.qpidnetwork.qnbridgemodule.util.Arithmetic;
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

public class LCMagicIconManager implements LCMagicIconDownloaderCallback{
	
	public interface LCMagicIconManagerCallback {
		public void OnDownloadMagicIconImage(boolean result, LCMagicIconItem magicIconItem);
		public void OnDownloadMagicIconThumbImage(boolean result, LCMagicIconItem magicIconItem);
	}
	/**
	 * 正在发送map表（msgId, item）
	 */
	private HashMap<Integer, LCMessageItem> mMsgIdMap;
	
	/**
	 * GetMagicIconConfig的RequestId
	 */
	public long mGetMagicIconConfigReqId;
	
	/**
	 * 下载回调
	 */
	private LCMagicIconManagerCallback mCallback;
	
	/**
	 * 小高级表情拇子图下载列表
	 */
	private HashMap<LCMagicIconItem, LCMagicIconDownloader> mThumbImgDownloadMap;
	/**
	 * 小高级表情原图下载列表
	 */
	private HashMap<LCMagicIconItem, LCMagicIconDownloader> mSourceImgDownloadMap;
	
	/**
	 * 高级表情配置item
	 */
	private MagicIconConfig mConfigItem;
	
	private Context mContext;
	
	public LCMagicIconManager() {
		mMagicIconMap = new HashMap<String, LCMagicIconItem>();
		mMsgIdMap = new HashMap<Integer, LCMessageItem>();
		mGetMagicIconConfigReqId = LCRequestJni.InvalidRequestId;
		mDownloadPath = "";
		mDirPath = "";
		mHost = "";
		mCallback = null;
		mThumbImgDownloadMap = new HashMap<LCMagicIconItem, LCMagicIconDownloader>();
		mSourceImgDownloadMap = new HashMap<LCMagicIconItem, LCMagicIconDownloader>();
		mConfigItem = null;
	}
	
	/**
	 * 初始化
	 * APP异常重启流程：AppInitManager init()-->LiveChatManager 初始化-->但并没有调用init()这个方法，所以会导致mContext为空
	 * @param host		http下载host
	 * @return
	 */
	public boolean init(Context context, String host, LCMagicIconManagerCallback callback) {
		boolean result = false;
		if (!host.isEmpty() 
				&& callback != null
				&& context != null) 
		{
			result = true;
			
			mDirPath = FileCacheManager.getInstance().GetLCMagicIconPath();
			if (!mDirPath.regionMatches(mDirPath.length()-1, "/", 0, 1)) {
				mDirPath += "/";
			}
			
			// 其它
			if (result)
			{
				mHost = host;
				if (!mHost.regionMatches(mHost.length()-1, "/", 0, 1)) {
					mHost += "/";
				}

				mContext = context;
				mCallback = callback;
				
				// 从文件中读取配置
				if (GetConfigItemWithFile()) {
					// 删除所有高级表情item
					removeAllMagicIconItem();
					// 设置下载路径
					setDownloadPath(mConfigItem.path);
					// 添加高级表情
					addMagicIconWithConfigItem(mConfigItem);
				}
			}
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
        	String key = "MagicIconConfigItem_" + WebSiteConfigManager.getInstance().getCurrentWebSite().getSiteId();
            SharedPreferences mSharedPreferences = mContext.getSharedPreferences("base64", Context.MODE_PRIVATE);  
            String personBase64 = mSharedPreferences.getString(key, "");

			// 2018/11/10 Hardy
			if (TextUtils.isEmpty(personBase64)) {
				return result;
			}

            byte[] base64Bytes = Base64.decode(personBase64.getBytes(), Base64.DEFAULT);  
            bais = new ByteArrayInputStream(base64Bytes);
            ois = new ObjectInputStream(bais);
            mConfigItem = (MagicIconConfig) ois.readObject();
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
				String key = "MagicIconConfigItem_" + WebSiteConfigManager.getInstance().getCurrentWebSite().getSiteId();
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
	 * @param updateTime
	 * @return
	 */
	public boolean IsVerNewTheConfigItem(long updateTime)
	{
		boolean result = true;
		if (null != mConfigItem) {
			//result = (version > mConfigItem.version);
			// 版本号不同就更新
			result = (updateTime != mConfigItem.maxupdatetime);
		} 
		return result;
	}
	
	/**
	 * 更新配置
	 * @param configItem
	 * @return
	 */
	public boolean UpdateConfigItem(MagicIconConfig configItem)
	{
		boolean result = false;
		if (null != configItem) {
			result = true;
			// 停止图片文件下载
			StopAllDownloadImage();
			// 停止3gp文件下载
			StopAllDownloadThumbImage();
			// 删除本地缓存目录下所有文件
			DeleteAllMagicIconFile();
			// 删除所有高级表情item
			removeAllMagicIconItem();
			
			mConfigItem = configItem;

			// 保存配置
			SaveConfigItemToFile();
			// 设置下载路径
			setDownloadPath(mConfigItem.path);
			// 添加高级表情
			addMagicIconWithConfigItem(mConfigItem);
		}
		return result;
	}
	
	/**
	 * 获取配置item
	 * @return
	 */
	public MagicIconConfig GetConfigItem()
	{
		return mConfigItem;
	}
	
// ------------------ 小高表对象本地缓存Map操作 ----------------------
	/**
	 * 小高级表情ID与item的map表
	 */
	private HashMap<String, LCMagicIconItem> mMagicIconMap;
	
	/**
	 * 添加配置item的高级表情至map
	 * @param configItem
	 */
	private void addMagicIconWithConfigItem(MagicIconConfig configItem) {
		if(null != configItem && configItem.magicIconArray != null){
			for(int i=0; i< configItem.magicIconArray.length; i++){
				addMagicIconItem(configItem.magicIconArray[i].id);
			}
		}
	}
	
	/**
	 * 添加到当前缓存
	 * @param magicIconId
	 */
	private void addMagicIconItem(String magicIconId){
		synchronized(mMagicIconMap){
			if(!mMagicIconMap.containsKey(magicIconId)){
				LCMagicIconItem item = new LCMagicIconItem(
										magicIconId,
										getMagicIconThumbLocalPath(magicIconId),
										getMagicIconImgLocalPath(magicIconId)
										);
				mMagicIconMap.put(magicIconId, item);
			}
		}
	}
	
	/**
	 * 获取/添加小高表Item
	 * @param magicIconId 小高表Id
	 * @return
	 */
	public LCMagicIconItem getMagicIcon(String magicIconId) {
		LCMagicIconItem item = null;
		synchronized(mMagicIconMap) {
			item = mMagicIconMap.get(magicIconId);
			if (null == item) {
				item = new LCMagicIconItem(
						magicIconId,
						getMagicIconThumbLocalPath(magicIconId),
						getMagicIconImgLocalPath(magicIconId)
						);
				mMagicIconMap.put(magicIconId, item);
			}
		}
		return item;
	}
	
	/**
	 * 清除所有小高表情item
	 */
	public void removeAllMagicIconItem() {
		synchronized(mMagicIconMap)
		{
			mMagicIconMap.clear();
		}
	}
	
// ------------------- 小高表消息发送发送map表操作 --------------------
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
			Log.e("livechat", String.format("%s::%s() fail msgId: %d", "LCMagicIconManager", "getAndRemoveSendingItem", msgId));
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
			if (item.msgType == MessageType.MagicIcon
					&& null != item.getMagicIconItem()
					&& null == mMsgIdMap.get(item.msgId)) 
			{
				mMsgIdMap.put(item.msgId, item);
				result = true;
			}
			else {
				Log.e("livechat", String.format("%s::%s() fail msgId: %d", "LCMagicIconManager", "addSendingItem", item.msgId));
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

// ------------------- 路径处理（包括URL及本地路径） --------------------
	/**
	 * http下载host
	 */
	private String mHost;
	/**
	 * 文件下载路径
	 */
	private String mDownloadPath;
	/**
	 * 本地缓存目录路径
	 */
	private String mDirPath;
	private final String IMG_SUB_PATH = "img/";
	private final String THUMB_SUB_PATH = "thumb/";
	private final String NORMAL_SUFFIX = ".png";
	private final String THUMB_SUFIIX = "-192.png";
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
	
	/**
	 * 获取小高原图下载路径
	 * @param magicIconId
	 * @return
	 */
	private String getMagicIconImgUrl(String magicIconId){
		String url = mHost + mDownloadPath + IMG_SUB_PATH + magicIconId + NORMAL_SUFFIX;
		return url;
	}
	
	/**
	 * 获取小高表缩略图下载路径
	 * @param magicIconId
	 * @return
	 */
	private String getMagicIconThumbUrl(String magicIconId){
		String url = mHost + mDownloadPath + THUMB_SUB_PATH + magicIconId + THUMB_SUFIIX;
		return url;
	}
	
	/**
	 * 获取小高表原图本地缓存路径
	 */
	private String getMagicIconImgLocalPath(String magicIconId){
		String url = getMagicIconImgUrl(magicIconId);
		String localUrl = mDirPath + Arithmetic.MD5(url.getBytes(), url.getBytes().length);
		return localUrl;
	}
	
	/**
	 * 获取小高表拇子图本地缓存路径
	 * @param magicIconId
	 * @return
	 */
	private String getMagicIconThumbLocalPath(String magicIconId){
		String url = getMagicIconThumbUrl(magicIconId);
		String localUrl = mDirPath + Arithmetic.MD5(url.getBytes(), url.getBytes().length);
		return localUrl;
	}

	
	/**
	 * 删除所有高级表情文件（包括图片及3gp）
	 */
	private void DeleteAllMagicIconFile()
	{
		// 删除小高表目录文件
		File magicDir = new File(mDirPath);
		if (magicDir.exists() && magicDir.isDirectory()) {
			File[] files = magicDir.listFiles();
			if(files != null){
				for (int i = 0; i < files.length; i++) {
					if (files[i].isFile() || files[i].isDirectory()) {
						files[i].delete();
					} 
				}
			}
		}
	}
	
// ------------ 下载image ------------
	/**
	 * 开始下载source image
	 * @param item	小高表item
	 * @return
	 */
	public boolean StartDownloadImage(LCMagicIconItem item) {
		boolean result = false;
		synchronized(mSourceImgDownloadMap) {
			if (null == mSourceImgDownloadMap.get(item) && !item.getMagicIconId().isEmpty()) 
			{
				LCMagicIconDownloader loader = new LCMagicIconDownloader(mContext);
				result = loader.Start(
						getMagicIconImgUrl(item.getMagicIconId())
						, getMagicIconImgLocalPath(item.getMagicIconId())
						, MagicIconDownloadType.SOURCE
						, item
						, this);
				
				if (result) {
					mSourceImgDownloadMap.put(item, loader);
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
	public boolean StopDownloadImage(LCMagicIconItem item) {
		boolean result = false;
		synchronized(mSourceImgDownloadMap) {
			LCMagicIconDownloader loader = mSourceImgDownloadMap.get(item);
			if (null != loader) {
				loader.Stop();
				result = true;
			}
		}
		return result;
	}
	
	public boolean StopAllDownloadImage() {
		boolean result = false;
		synchronized(mSourceImgDownloadMap) {
			for (Entry<LCMagicIconItem, LCMagicIconDownloader> entry: mSourceImgDownloadMap.entrySet()) {
				LCMagicIconDownloader loader = entry.getValue();
				loader.Stop();
			}
		}
		return result;
	}
	
	// ------------ 下载Thumb ------------
	/**
	 * 开始下载Thumb image
	 * @param item	小高表item
	 * @return
	 */
	public boolean StartDownloadThumbImage(LCMagicIconItem item) {
		boolean result = false;
		synchronized(mThumbImgDownloadMap) {
			if (null == mThumbImgDownloadMap.get(item) && !item.getMagicIconId().isEmpty()) 
			{
				LCMagicIconDownloader loader = new LCMagicIconDownloader(mContext);
				result = loader.Start(
						getMagicIconThumbUrl(item.getMagicIconId())
						, getMagicIconThumbLocalPath(item.getMagicIconId())
						, MagicIconDownloadType.THUMB
						, item
						, this);
				
				if (result) {
					mThumbImgDownloadMap.put(item, loader);
				}
			}
		}
		return result;
	}
	
	/**
	 * 停止下载Thumb image
	 * @param item	高级表情item
	 * @return
	 */
	public boolean StopDownloadThumbImage(LCMagicIconItem item) {
		boolean result = false;
		synchronized(mThumbImgDownloadMap) {
			LCMagicIconDownloader loader = mThumbImgDownloadMap.get(item);
			if (null != loader) {
				loader.Stop();
				result = true;
			}
		}
		return result;
	}
	
	public boolean StopAllDownloadThumbImage() {
		boolean result = false;
		synchronized(mThumbImgDownloadMap) {
			for (Entry<LCMagicIconItem, LCMagicIconDownloader> entry: mThumbImgDownloadMap.entrySet()) {
				LCMagicIconDownloader loader = entry.getValue();
				loader.Stop();
			}
		}
		return result;
	}
	
	/******************************  下载图片回调     *****************************/
	@Override
	public void onSuccess(MagicIconDownloadType downloadType,
			LCMagicIconItem item) {
		if (mCallback != null) {
			switch (downloadType) {
			case SOURCE: {
				mCallback.OnDownloadMagicIconImage(true, item);
				synchronized(mSourceImgDownloadMap) {
					mSourceImgDownloadMap.remove(item);
				}
			} break;
			case THUMB: {
				mCallback.OnDownloadMagicIconThumbImage(true, item);
				synchronized(mThumbImgDownloadMap) {
					mThumbImgDownloadMap.remove(item);
				}
			} break;
			default:
				break;
			}
		}		
	}

	@Override
	public void onFail(MagicIconDownloadType downloadType, LCMagicIconItem item) {
		if (mCallback != null) {
			switch (downloadType) 
			{
			case SOURCE: {
				mCallback.OnDownloadMagicIconImage(false, item);
				synchronized(mSourceImgDownloadMap) {
					mSourceImgDownloadMap.remove(item);
				}
			} break;
			case THUMB: {
				mCallback.OnDownloadMagicIconThumbImage(false, item);
				synchronized(mThumbImgDownloadMap) {
					mThumbImgDownloadMap.remove(item);
				}
			} break;
			default:
				break;
			}
		}		
	}

}
