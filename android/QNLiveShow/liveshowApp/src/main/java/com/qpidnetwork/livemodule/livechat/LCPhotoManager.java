package com.qpidnetwork.livemodule.livechat;

import android.annotation.SuppressLint;
import android.graphics.Bitmap;
import android.text.TextUtils;

import com.qpidnetwork.livemodule.livechat.LCMessageItem.MessageType;
import com.qpidnetwork.livemodule.livechat.LCMessageItem.SendType;
import com.qpidnetwork.livemodule.livechathttprequest.LCRequestJni;
import com.qpidnetwork.livemodule.livechathttprequest.LCRequestJniLiveChat;
import com.qpidnetwork.livemodule.livechathttprequest.LCRequestJniLiveChat.PhotoModeType;
import com.qpidnetwork.livemodule.livechathttprequest.LCRequestJniLiveChat.PhotoSizeType;
import com.qpidnetwork.livemodule.livechathttprequest.OnLCGetPhotoCallback;
import com.qpidnetwork.livemodule.utils.ImageUtil;
import com.qpidnetwork.qnbridgemodule.util.Arithmetic;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Set;

/**
 * 图片管理类
 * @author Samson Fan
 *
 */
public class LCPhotoManager {
	/**
	 * msgId与item的待发送map表(msgId, photoItem)（记录未发送成功的item，发送成功则移除）
	 */
	private HashMap<Integer, LCMessageItem> mMsgIdMap;
	/**
	 * 本地缓存文件目录
	 */
	private String mDirPath;
	
	@SuppressLint("UseSparseArrays")
	public LCPhotoManager() {
		mMsgIdMap = new HashMap<Integer, LCMessageItem>();
		mRequestCallbackList = new HashMap<String, List<OnLCGetPhotoCallback>>();
		mPhotoRequestMap = new HashMap<Long, String>();
		mDirPath = "";
	}
	
	/**
	 * 初始化
	 * @param dirPath	文件存放目录
	 * @return
	 */
	public boolean init(String dirPath) {
		mDirPath = dirPath;
		if (!mDirPath.isEmpty() && !mDirPath.regionMatches(mDirPath.length()-1, "/", 0, 1)) {
			mDirPath += "/";
		}
		return !mDirPath.isEmpty();
	}
	
	/**
	 * 获取图片本地缓存文件路径
	 * @param item		消息item
	 * @return
	 */
	private String getPhotoPath(LCMessageItem item, PhotoModeType modeType, PhotoSizeType sizeType) {
		String path = "";
		if (item.msgType == MessageType.Photo && null != item.getPhotoItem()
				&& !item.getPhotoItem().photoId.isEmpty() && !mDirPath.isEmpty()) 
		{
			path = getPhotoPath(item.getPhotoItem().photoId, modeType, sizeType);
		}
		return path;
	}
	
	/**
	 * 获取图片本地缓存文件路径(全路径)
	 * @param photoId	图片ID
	 * @param modeType	照片类型
	 * @param sizeType	照片尺寸
	 * @return
	 */
	public String getPhotoPath(String photoId, PhotoModeType modeType, PhotoSizeType sizeType) {
		String path = "";
		if (!photoId.isEmpty()) {
			path =  getPhotoPathWithMode(photoId, modeType)
					+ "_"
					+ sizeType.name();
		}
		return path;
	}
	
	/**
	 * 获取图片指定类型路径(非全路径)
	 * @param photoId	照片ID
	 * @param modeType	照片类型
	 * @return
	 */
	private String getPhotoPathWithMode(String photoId, PhotoModeType modeType)
	{
		String path = "";
		if (!photoId.isEmpty()) {
			path = mDirPath 
					+ Arithmetic.MD5(photoId.getBytes(), photoId.getBytes().length)
					+ "_"
					+ modeType.name();
		}
		return path;
	}
	
	/**
	 * 获取图片临时文件路径
	 * @param photoId		photoId
	 * @return
	 */
	private String getTempPhotoPath(String photoId, PhotoModeType modeType, PhotoSizeType sizeType) {
		String path = "";
		if (!TextUtils.isEmpty(photoId) && !mDirPath.isEmpty())
		{
			path = getPhotoPath(photoId, modeType, sizeType) + "_temp";
		}
		return path;
	}
	
	/**
	 * 下载完成的临时文件转换成图片文件
	 * @param photoId
	 * @param modeType	图片类型
	 * @param sizeType	图片尺寸
	 * @return
	 */
	private boolean tempToPhoto(String photoId, PhotoModeType modeType, PhotoSizeType sizeType) {
		boolean result = false;
		if (!TextUtils.isEmpty(photoId)) {
			String tempPath = getTempPhotoPath(photoId, modeType, sizeType);
			String path = getPhotoPath(photoId, modeType, sizeType);
			if (!path.isEmpty()) {
				boolean renameResult = false; 
				File tempFile = new File(tempPath);
				File newFile = new File(path);
				if (tempFile.exists() 
					&& tempFile.isFile()
					&& tempFile.renameTo(newFile)) 
				{
					renameResult = true;
				}
			}
		}
		return result;
	}
	
	/**
	 * 复制文件至缓冲目录(用于发送图片消息)
	 * @param srcFilePath	源文件路径
	 * @return
	 */
	public boolean copyPhotoFileToDir(LCPhotoItem item, String srcFilePath) {
		boolean result = false;
		File file = new File(srcFilePath);
		if (file.exists() && file.isFile()) {
			String desFilePath = getPhotoPath(item.photoId, PhotoModeType.Clear, PhotoSizeType.Original);
			String cmd = "cp -f " + srcFilePath + " " + desFilePath;
			try {
				Runtime.getRuntime().exec(cmd);
				
				// 原图路径
				item.mClearSrcPhotoInfo = new LCPhotoInfoItem(LCPhotoInfoItem.StatusType.Success, "", "", desFilePath);
				
				// 显示图路径
				String showFilePath = getPhotoPath(item.photoId, PhotoModeType.Clear, PhotoSizeType.Large);
				if (!showFilePath.isEmpty()) {
					Bitmap showBitmap = ImageUtil.decodeSampledBitmapFromFile(srcFilePath, 370, 370);
					if (null != showBitmap
						&& ImageUtil.saveBitmapToFile(showFilePath, showBitmap, Bitmap.CompressFormat.JPEG, 100))
					{
						LCPhotoInfoItem photoInfoItem = new LCPhotoInfoItem(LCPhotoInfoItem.StatusType.Success, "", "", showFilePath);
						item.mClearLargePhotoInfo = photoInfoItem;
						item.mClearMiddlePhotoInfo = photoInfoItem;
					}
				}
				
				// 拇指图路径
				String thumbFilePath = getPhotoPath(item.photoId, PhotoModeType.Clear, PhotoSizeType.Middle);
				if (!thumbFilePath.isEmpty()) {
					Bitmap showBitmap = ImageUtil.decodeSampledBitmapFromFile(srcFilePath, 110, 110);
					if (null != showBitmap
						&& ImageUtil.saveBitmapToFile(thumbFilePath, showBitmap, Bitmap.CompressFormat.JPEG, 100))
					{
						item.mClearSmallPhotoInfo = new LCPhotoInfoItem(LCPhotoInfoItem.StatusType.Success, "", "", thumbFilePath);
					}
				}
				
				result = true;
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		return result;
	}
	
	/**
	 * 清除所有图片
	 */
	public void removeAllPhotoFile()
	{
		if (!mDirPath.isEmpty())
		{
			String dirPath = mDirPath + "*";
			String cmd = "rm -f " + dirPath;
			try {
				Runtime.getRuntime().exec(cmd);
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
	
	/**
	 * 合并图片消息记录（把女士发出及男士已购买的图片记录合并为一条聊天记录）
	 * @param msgList
	 */
	public void combineMessageItem(ArrayList<LCMessageItem> msgList)
	{
		if (null == msgList) {
			return;
		}
		
		synchronized (msgList) 
		{
			if (!msgList.isEmpty()) 
			{
			
				// 女士发送图片列表
				ArrayList<LCMessageItem> womanPhotoList = new ArrayList<LCMessageItem>();
				// 男士发送图片列表
				ArrayList<LCMessageItem> manPhotoList = new ArrayList<LCMessageItem>();
				// 找出所有男士和女士发出的图片消息
				for (LCMessageItem item : msgList)
				{
					if (item.msgType == MessageType.Photo
						&& null != item.getPhotoItem()
						&& !item.getPhotoItem().photoId.isEmpty())
					{
						if (item.sendType == SendType.Recv) {
							womanPhotoList.add(item);
						}
						else if (item.sendType == SendType.Send) {
							manPhotoList.add(item);
						}
					}
				}
				
				// 合并男士购买的图片消息
				if (manPhotoList.size() > 0 && womanPhotoList.size() > 0)
				{
					for (LCMessageItem manItem : manPhotoList) {
						for (LCMessageItem womanItem : womanPhotoList) {
							LCPhotoItem manPhotoItem = manItem.getPhotoItem();
							LCPhotoItem womanPhotoItem = womanItem.getPhotoItem();
							if (manPhotoItem.photoId.compareTo(womanPhotoItem.photoId) == 0
								&& manPhotoItem.sendId.compareTo(womanPhotoItem.sendId) == 0) 
							{
								// 男士发出的图片ID与女士发出的图片ID一致，需要合并
								msgList.remove(manItem);
								womanPhotoItem.charge = true;
							}
						}
					}
				}
			}
		}
	}
	
	// --------------------- sending（正在发送） --------------------------
	/**
	 * 获取指定票根的item并从待发送map表中移除
	 * @param msgId	消息ID 
	 * @return
	 */
	public LCMessageItem getAndRemoveSendingItem(int msgId) {
		LCMessageItem item = null;
		synchronized (mMsgIdMap)
		{
			item = mMsgIdMap.remove(msgId);
			if (null == item) { 
				Log.e("livechat", String.format("%s::%s() fail msgId: %d", "LCPhotoManager", "getAndRemoveSendingItem", msgId));
			}
		}
		return item;
	}
	
	/**
	 * 添加指定票根的item到待发送map表中
	 * @param item	图片item
	 * @return
	 */
	public boolean addSendingItem(LCMessageItem item) {
		boolean result = false;
		synchronized (mMsgIdMap)
		{
			if (item.msgType == MessageType.Photo
					&& null != item.getPhotoItem()
					&& null == mMsgIdMap.get(item.msgId)) {
				mMsgIdMap.put(item.msgId, item);
				result = true;
			}
			else {
				Log.e("livechat", String.format("%s::%s() fail msgId: %d", "LCPhotoManager", "addSendingItem", item.msgId));
			}
		}
		return result;
	}
	
	/**
	 * 清除所有待发送表map表的item
	 */
	private void clearAllSendingItems() {
		synchronized (mMsgIdMap)
		{
			mMsgIdMap.clear();
		}
	}
	
	// --------------------------- Uploading/Download Photo（正在上传/下载 ） -------------------------

	/**
	 * 存储请求中的图片及callback列表
	 */
	private HashMap<String, List<OnLCGetPhotoCallback>> mRequestCallbackList;
	/**
	 * 存储请求RequestId与UniqueId，用于请求与callback匹配
	 */
	private HashMap<Long, String> mPhotoRequestMap;

	/**
	 * 生成私密照下载请求唯一key
	 * @param photoId
	 * @param photoModeType
	 * @param photoSizeType
	 * @return
	 */
	private String createPrivatePhotoDownloadingUniqueKey(String photoId, PhotoModeType photoModeType, PhotoSizeType photoSizeType){
		String uniqueKey = photoId;
		if(photoModeType != null){
			uniqueKey += "_" + photoModeType.name();
		}
		if(photoSizeType != null){
			uniqueKey += "_" + photoSizeType.name();
		}
		return uniqueKey;
	}

	/**
	 * 添加到请求列表
	 * @param requestId
	 * @param uniqueKey
	 * @return
	 */
	private void addToRequestMap(Long requestId, String uniqueKey){
		synchronized (mPhotoRequestMap){
			mPhotoRequestMap.put(requestId, uniqueKey);
		}
	}

	/**
	 * 根据requestId获取uniquekey
	 * @param requestId
	 * @return
	 */
	private String getAndRemoveRequestMap(Long requestId){
		String uniqueKey = "";
		synchronized (mPhotoRequestMap){
			if(mPhotoRequestMap.containsKey(requestId)){
				uniqueKey = mPhotoRequestMap.remove(requestId);
			}
		}
		return uniqueKey;
	}

	/**
	 * 图片下载完成回调分发
	 * @param requestId
	 * @param isSuccess
	 * @param errno
	 * @param errmsg
	 * @param filePath
	 */
	private void onGetPhotoCallback(long requestId, boolean isSuccess, String errno,
									String errmsg, String filePath){
		List<OnLCGetPhotoCallback> callbackList = null;
		String uniqueKey = getAndRemoveRequestMap(requestId);
		if(!TextUtils.isEmpty(uniqueKey)){
			synchronized (mRequestCallbackList){
				if(mRequestCallbackList.containsKey(uniqueKey)){
					callbackList = mRequestCallbackList.remove(uniqueKey);
				}
			}
		}
		if(callbackList != null){
			for(OnLCGetPhotoCallback callback : callbackList){
				callback.OnLCGetPhoto(requestId, isSuccess, errno, errmsg, filePath);
			}
		}
	}

	/**
	 * 下载指定类型私密照
	 * @param toFlag
	 * @param targetId
	 * @param userId
	 * @param sid
	 * @param photoId
	 * @param sizeType
	 * @param modeType
	 * @param callback
	 */
	public boolean getPrivatePhoto(LCRequestJniLiveChat.ToFlagType toFlag, String targetId, String userId, String sid, final String photoId, final PhotoSizeType sizeType, final PhotoModeType modeType, OnLCGetPhotoCallback callback){
		boolean result = true;		//请求是否发送成功
		boolean isDownloading = false;
		String uniqueKey = createPrivatePhotoDownloadingUniqueKey(photoId, modeType, sizeType);
		synchronized (mRequestCallbackList){
			isDownloading = mRequestCallbackList.containsKey(uniqueKey);
			List<OnLCGetPhotoCallback> callbackList;
			if(isDownloading){
				callbackList = mRequestCallbackList.get(uniqueKey);
			}else{
				callbackList = new ArrayList<OnLCGetPhotoCallback>();
				mRequestCallbackList.put(uniqueKey, callbackList);
			}
			callbackList.add(callback);
		}
		if(!isDownloading){
			long requestId = LCRequestJniLiveChat.GetPhoto(
					toFlag
					, targetId
					, userId
					, sid
					, photoId
					, sizeType
					, modeType
					, getTempPhotoPath(photoId, modeType, sizeType)
					, new OnLCGetPhotoCallback() {

						@Override
						public void OnLCGetPhoto(long requestId, boolean isSuccess, String errno,
												 String errmsg, String filePath) {
							if(isSuccess){
								tempToPhoto(photoId, modeType, sizeType);
							}
							onGetPhotoCallback(requestId, isSuccess, errno, errmsg, getPhotoPath(photoId, modeType, sizeType));
						}
					});

			if (requestId != LCRequestJni.InvalidRequestId) {
				addToRequestMap(requestId, uniqueKey);
			}else{
				result = false;
			}
		}
		return result;
	}
	
	/**
	 * 清除所有正在上传/下载的item
	 */
	private void clearAllRequestItems() {

		synchronized(mPhotoRequestMap) {
			mPhotoRequestMap.clear();
		}

		synchronized (mRequestCallbackList) {
			mRequestCallbackList.clear();

		}
	}

	// --------------------- photo presend tasks --------------------------
	private HashMap<LCPhotoMessagePreSendTask, LCMessageItem> mPhotoPreSendingMap = new HashMap<LCPhotoMessagePreSendTask, LCMessageItem>();

	/**
	 * task添加到presending map
	 * @param task
	 * @param msgItem
	 */
	public void addToPhotoPreSendingMap(LCPhotoMessagePreSendTask task, LCMessageItem msgItem){
		synchronized (mPhotoPreSendingMap){
			mPhotoPreSendingMap.put(task, msgItem);
		}
	}

	/**
	 * 从presending map清除task
	 * @param task
	 * @return
	 */
	public LCMessageItem getAndRemovePhotoPreSengdingtMap(LCPhotoMessagePreSendTask task){
		LCMessageItem msgItem = null;
		synchronized (mPhotoPreSendingMap){
			if(mPhotoPreSendingMap.containsKey(task)){
				msgItem = mPhotoPreSendingMap.remove(task);
			}
		}
		return msgItem;
	}

	/**
	 * 清除所有presending task
	 */
	private void clearAllPreSendingTask(){
		synchronized (mPhotoPreSendingMap){
			Set<LCPhotoMessagePreSendTask> set = mPhotoPreSendingMap.keySet();
			for(LCPhotoMessagePreSendTask task : set){
				task.releaseDisposable();
			}
			mPhotoPreSendingMap.clear();
		}
	}

	public void  release(){
		// 停止所有图片请求
		clearAllRequestItems();
		//停止所有图片发送预处理任务
		clearAllPreSendingTask();
		//停止所有请求
		clearAllSendingItems();
	}
}
