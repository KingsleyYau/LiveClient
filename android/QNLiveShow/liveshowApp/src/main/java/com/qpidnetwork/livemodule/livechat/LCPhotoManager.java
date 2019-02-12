package com.qpidnetwork.livemodule.livechat;

import android.annotation.SuppressLint;
import android.graphics.Bitmap;

import com.qpidnetwork.livemodule.livechat.LCMessageItem.MessageType;
import com.qpidnetwork.livemodule.livechat.LCMessageItem.SendType;
import com.qpidnetwork.livemodule.livechathttprequest.LCRequestJni;
import com.qpidnetwork.livemodule.livechathttprequest.LCRequestJniLiveChat.PhotoModeType;
import com.qpidnetwork.livemodule.livechathttprequest.LCRequestJniLiveChat.PhotoSizeType;
import com.qpidnetwork.livemodule.utils.ImageUtil;
import com.qpidnetwork.qnbridgemodule.util.Arithmetic;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;

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
	 * RequestId与item的待发送map表(RequestId, photoItem)（记录上传未成功的item，上传成功则移除）
	 */
	private HashMap<Long, LCMessageItem> mRequestMap;
	/**
	 * itme与RequestId的待发送map表(photoItem, RequestId)
	 */
	private HashMap<LCMessageItem, Long> mPhotoRequestMap;
	/**
	 * 本地缓存文件目录
	 */
	private String mDirPath;
	
	@SuppressLint("UseSparseArrays")
	public LCPhotoManager() {
		mMsgIdMap = new HashMap<Integer, LCMessageItem>();
		mRequestMap = new HashMap<Long, LCMessageItem>();
		mPhotoRequestMap = new HashMap<LCMessageItem, Long>();
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
	public String getPhotoPath(LCMessageItem item, PhotoModeType modeType, PhotoSizeType sizeType) {
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
	 * @param item		消息item
	 * @return
	 */
	public String getTempPhotoPath(LCMessageItem item, PhotoModeType modeType, PhotoSizeType sizeType) {
		String path = "";
		if (item.msgType == MessageType.Photo && null != item.getPhotoItem()
				&& !item.getPhotoItem().photoId.isEmpty() && !mDirPath.isEmpty()) 
		{
			path = getPhotoPath(item.getPhotoItem().photoId, modeType, sizeType) + "_temp";
		}
		return path;
	}
	
	/**
	 * 下载完成的临时文件转换成图片文件
	 * @param item		消息item
	 * @param tempPath	临时文件路径
	 * @param modeType	图片类型
	 * @param sizeType	图片尺寸
	 * @return
	 */
	public boolean tempToPhoto(LCMessageItem item, String tempPath, PhotoModeType modeType, PhotoSizeType sizeType) {
		boolean result = false;
		if (null != tempPath && !tempPath.isEmpty()
				&& item.msgType == MessageType.Photo && null != item.getPhotoItem())
		{
			LCPhotoItem photoItem = item.getPhotoItem();
			String path = getPhotoPath(photoItem.photoId, modeType, sizeType);
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
				
				if (renameResult) {
					switch (photoItem.statusType)
					{
					case DownloadShowFuzzyPhoto:
						photoItem.showFuzzyFilePath = path;
						break;
					case DownloadThumbFuzzyPhoto:
						photoItem.thumbFuzzyFilePath = path;
						break;
					case DownloadShowSrcPhoto:
						photoItem.showSrcFilePath = path;
						break;
					case DownloadThumbSrcPhoto:
						photoItem.thumbSrcFilePath = path;
						break;
					case DownloadSrcPhoto:
						photoItem.srcFilePath = path;
						break;
					default:
						break;
					}
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
				item.srcFilePath = desFilePath;
				
				// 显示图路径
				String showFilePath = getPhotoPath(item.photoId, PhotoModeType.Clear, PhotoSizeType.Large);
				if (!showFilePath.isEmpty()) {
					Bitmap showBitmap = ImageUtil.decodeSampledBitmapFromFile(srcFilePath, 370, 370);
					if (null != showBitmap
						&& ImageUtil.saveBitmapToFile(showFilePath, showBitmap, Bitmap.CompressFormat.JPEG, 100))
					{
						item.showSrcFilePath = showFilePath;
					}
				}
				
				// 拇指图路径
				String thumbFilePath = getPhotoPath(item.photoId, PhotoModeType.Clear, PhotoSizeType.Middle);
				if (!thumbFilePath.isEmpty()) {
					Bitmap showBitmap = ImageUtil.decodeSampledBitmapFromFile(srcFilePath, 110, 110);
					if (null != showBitmap
						&& ImageUtil.saveBitmapToFile(thumbFilePath, showBitmap, Bitmap.CompressFormat.JPEG, 100))
					{
						item.thumbSrcFilePath = thumbFilePath;
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
	 * 复制文件至缓冲目录
	 * @param item	源文件路径
	 * @return
	 */
	public boolean removeFuzzyPhotoFile(LCPhotoItem item) {
		boolean result = false;

		if (!item.photoId.isEmpty()) {
			String fuzzyPath = getPhotoPathWithMode(item.photoId, PhotoModeType.Fuzzy) + "*";
			String cmd = "rm -f " + fuzzyPath;
			try {
				Runtime.getRuntime().exec(cmd);
				
				item.showFuzzyFilePath = "";
				item.thumbFuzzyFilePath = "";
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
	public void clearAllSendingItems() {
		synchronized (mMsgIdMap)
		{
			mMsgIdMap.clear();
		}
	}
	
	// --------------------------- Uploading/Download Photo（正在上传/下载 ） -------------------------
	/**
	 * 获取正在上传/下载的RequestId
	 * @param item
	 * @return
	 */
	public long getRequestIdWithItem(LCMessageItem item) {
		long requestId = LCRequestJni.InvalidRequestId;
		synchronized(mPhotoRequestMap) {
			Long result = mPhotoRequestMap.get(item);
			if (null != result) {
				requestId = result;
			}
		}
		return requestId;
	}
	
	/**
	 * 获取并移除正在上传/下载的item
	 * @param requestId	请求ID
	 * @return
	 */
	public LCMessageItem getAndRemoveRequestItem(long requestId) {
		LCMessageItem item = null;
		synchronized (mRequestMap)
		{
			item = mRequestMap.remove(requestId);
			if (null == item) {
				Log.e("livechat", String.format("%s::%s() fail requestId: %d", "LCPhotoManager", "getRequestItem", requestId));
			}
			else {
				synchronized(mPhotoRequestMap) {
					mPhotoRequestMap.remove(item);
				}
			}
		}
		return item;
	}
	
	/**
	 * 添加正在上传/下载的item
	 * @param requestId	请求ID
	 * @param item		消息item
	 * @return
	 */
	public boolean addRequestItem(long requestId, LCMessageItem item) {
		boolean result = false;
		synchronized (mRequestMap)
		{
			if (item.msgType == MessageType.Photo
					&& null != item.getPhotoItem()
					&& requestId != LCRequestJni.InvalidRequestId
					&& null == mRequestMap.get(requestId)) 
			{
				mRequestMap.put(requestId, item);
				synchronized(mPhotoRequestMap) {
					mPhotoRequestMap.put(item, requestId);
				}
				result = true;
			}
			else {
				Log.e("livechat", String.format("%s::%s() fail requestId:%d", "LCPhotoManager", "addRequestItem", requestId));
			}
		}
		return result;
	} 
	
	/**
	 * 清除所有正在上传/下载的item
	 */
	public ArrayList<Long> clearAllRequestItems() {
		ArrayList<Long> list = null;
		synchronized (mRequestMap)
		{
			if (mRequestMap.size() > 0) {
				list = new ArrayList<Long>(mRequestMap.keySet());
			}
			mRequestMap.clear();
			
			synchronized(mPhotoRequestMap) {
				mPhotoRequestMap.clear();
			}
		}
		return list;
	}
}
