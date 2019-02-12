package com.qpidnetwork.livemodule.livechat;

import android.annotation.SuppressLint;

import com.qpidnetwork.livemodule.livechat.LCMessageItem.MessageType;
import com.qpidnetwork.livemodule.livechat.LCMessageItem.SendType;
import com.qpidnetwork.livemodule.livechathttprequest.LCRequestJni;
import com.qpidnetwork.livemodule.livechathttprequest.LCRequestJniLiveChat.VideoPhotoType;
import com.qpidnetwork.qnbridgemodule.util.Arithmetic;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;

/**
 * 视频管理类
 * @author Samson Fan
 *
 */
public class LCVideoManager {
	/**
	 * 正在下载视频map表(FileDownloader, videoId)（记录下载未成功的视频ID，下载成功则移除）
	 */
	private HashMap<LiveChatFileDownloader, String> mDownloadVideoMap;
	/**
	 * 正在下载视频map表(videoId, FileDownloader)
	 */
	private HashMap<String, LiveChatFileDownloader> mVideoDownloadMap;
	/**
	 * 正在下载视频map表(RequestId, videoId)（记录下载未成功的视频ID，下载成功则移除）
	 */
	private HashMap<Long, String> mRequestVideoPhotoMap;
	/**
	 * 正在下载视频map表(videoId, RequestId)
	 */
	private HashMap<String, Long> mVideoPhotoRequestMap;
	/**
	 * 本地缓存文件目录
	 */
	private String mDirPath;
	
	@SuppressLint("UseSparseArrays")
	public LCVideoManager() 
	{
		mDirPath = "";
		// 视频下载对照表
		mDownloadVideoMap = new HashMap<LiveChatFileDownloader, String>();
		mVideoDownloadMap = new HashMap<String, LiveChatFileDownloader>();
		// 视频图片下载对照表
		mRequestVideoPhotoMap = new HashMap<Long, String>();
		mVideoPhotoRequestMap = new HashMap<String, Long>();
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
	
	// --------------------------- 获取视频本地缓存路径 -------------------------
	/**
	 * 获取视频图片本地缓存文件路径(全路径)
	 * @param userId	用户ID
	 * @param videoId	视频ID
	 * @param inviteId	邀请ID
	 * @param type		图片类型
	 * @return
	 */
	public String getVideoPhotoPath(String userId, String videoId, String inviteId, VideoPhotoType type)
	{
		String path = "";
		if (!userId.isEmpty()
			&& !videoId.isEmpty()
			&& !inviteId.isEmpty()) 
		{
			// 生成文件名
			String temp = userId + videoId + inviteId;
			String fileName = Arithmetic.MD5(temp.getBytes(), temp.getBytes().length);
			
			// 生成文件全路径 
			path = mDirPath
					+ fileName
					+ "_"
					+ "img"
					+ "_"
					+ type.name();
		}
		return path;
	}
	
	/**
	 * 获取视频图片临时文件路径
	 * @param userId	用户ID
	 * @param videoId	视频ID
	 * @param inviteId	邀请ID
	 * @param type		视频图片类型
	 * @return
	 */
	public String getVideoPhotoTempPath(String userId, String videoId, String inviteId, VideoPhotoType type)
	{
		String tempPath = "";
		String path = getVideoPhotoPath(userId, videoId, inviteId, type);
		if (!path.isEmpty()) 
		{
			tempPath = path + "_temp";
		}
		return tempPath;
	}
	
	/**
	 * 获取视频本地缓存文件路径(全路径)
	 * @param userId	用户ID
	 * @param videoId	视频ID
	 * @param inviteId	邀请ID
	 * @return
	 */
	public String getVideoPath(String userId, String videoId, String inviteId) 
	{
		String path = "";
		if (!userId.isEmpty()
			&& !videoId.isEmpty()
			&& !inviteId.isEmpty()) 
		{
			// 生成文件名
			String temp = userId + videoId + inviteId;
			String fileName = Arithmetic.MD5(temp.getBytes(), temp.getBytes().length);
			
			// 生成文件全路径 
			path = mDirPath + fileName;
		}
		return path;
	}
	
	/**
	 * 获取视频临时文件路径
	 * @return
	 */
	public String getVideoTempPath(String userId, String videoId, String inviteId) 
	{
		String tempPath = "";
		String path = getVideoPath(userId, videoId, inviteId);
		if (!path.isEmpty()) 
		{
			tempPath = path + "_temp";
		}
		return tempPath;
	}
	
	/**
	 * 下载完成的临时文件转换成正式文件
	 * @param tempPath	临时文件路径
	 * @param desPath		正式文件路径
	 * @return
	 */
	public boolean tempFileToDesFile(String tempPath, String desPath) 
	{
		boolean result = false;
		if (null != tempPath && !tempPath.isEmpty()
				&& null != desPath && !desPath.isEmpty())
		{
			File tempFile = new File(tempPath);
			File newFile = new File(desPath);
			if (tempFile.exists() 
				&& tempFile.isFile()
				&& tempFile.renameTo(newFile)) 
			{
				result = true;
			}
		}
		return result;
	}
	
	/**
	 * 清除所有视频文件
	 */
	public void removeAllVideoFile()
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
	
	// --------------------------- Video消息处理 -------------------------
	/**
	 * 根据videoId获取消息列表里的所有视频消息
	 * @param videoId	视频ID
	 * @param msgList	聊天消息列表
	 * @return
	 */
	public ArrayList<LCMessageItem> getMessageItem(String videoId, ArrayList<LCMessageItem> msgList)
	{
		ArrayList<LCMessageItem> result = new ArrayList<LCMessageItem>();
		if (null != msgList) 
		{
			synchronized (msgList) 
			{
				if (!msgList.isEmpty())
				{
					for (LCMessageItem item : msgList) 
					{
						if (item.msgType == MessageType.Video
							&& null != item.getVideoItem()
							&& item.getVideoItem().videoId.compareTo(videoId) == 0)
						{
							result.add(item);
						}
					}
				}
			}
		}
		return result;
	}
	
	/**
	 * 合并视频消息记录（把女士发出及男士已购买的视频记录合并为一条聊天记录）
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
				// 女士发送视频消息列表
				ArrayList<LCMessageItem> womanList = new ArrayList<LCMessageItem>();
				// 男士发送视频消息列表
				ArrayList<LCMessageItem> manList = new ArrayList<LCMessageItem>();
				// 找出所有男士和女士发出的视频消息
				for (LCMessageItem item : msgList)
				{
					if (item.msgType == MessageType.Video
						&& null != item.getVideoItem()
						&& !item.getVideoItem().videoId.isEmpty())
					{
						if (item.sendType == SendType.Recv) {
							womanList.add(item);
						}
						else if (item.sendType == SendType.Send) {
							manList.add(item);
						}
					}
				}
				
				// 合并男士购买的视频消息
				if (manList.size() > 0 && womanList.size() > 0)
				{
					for (LCMessageItem manItem : manList) {
						for (LCMessageItem womanItem : womanList) {
							LCVideoItem manVideoItem = manItem.getVideoItem();
							LCVideoItem womanVideoItem = womanItem.getVideoItem();
							if (manVideoItem.videoId.compareTo(womanVideoItem.videoId) == 0
								&& manVideoItem.sendId.compareTo(womanVideoItem.sendId) == 0) 
							{
								// 男士发出的视频ID与女士发出的视频ID一致，需要合并
								msgList.remove(manItem);
								womanVideoItem.charget = true;
							}
						}
					}
				}
			}
		}
	}
	
	// --------------------------- 正在下载的视频图片对照表 -------------------------
	/**
	 * 获取正在下载的视频图片RequestId
	 * @param videoId	视频ID
	 * @return 请求ID
	 */
	public long getRequestIdWithVideoPhotoId(String videoId) 
	{
		long requestId = LCRequestJni.InvalidRequestId;
		synchronized(mVideoPhotoRequestMap) {
			Long result = mVideoPhotoRequestMap.get(videoId);
			if (null != result) {
				requestId = result;
			}
		}
		return requestId;
	}
	
	/**
	 * 判断视频图片是否在下载
	 * @param videoId	视频ID
	 * @return
	 */
	public boolean isVideoPhotoRequest(String videoId)
	{
		return getRequestIdWithVideoPhotoId(videoId) != LCRequestJni.InvalidRequestId;
	}
	
	/**
	 * 获取并移除正在下载的视频图片
	 * @param requestId	请求ID
	 * @return 视频ID
	 */
	public String getAndRemoveRequestVideoPhoto(long requestId) 
	{
		String videoId = "";
		synchronized (mRequestVideoPhotoMap)
		{
			videoId = mRequestVideoPhotoMap.remove(requestId);
			if (null == videoId) {
				Log.e("livechat", String.format("%s::%s() fail requestId: %d", "LCVideoManager", "getAndRemoveRequestVideoPhoto", requestId));
			}
			else {
				synchronized(mVideoPhotoRequestMap) {
					mVideoPhotoRequestMap.remove(videoId);
				}
			}
		}
		return videoId;
	}
	
	/**
	 * 添加下载的视频图片
	 * @param requestId	请求ID
	 * @param videoId	视频ID
	 * @return
	 */
	public boolean addRequestVideoPhoto(long requestId, String videoId) {
		boolean result = false;
		synchronized (mRequestVideoPhotoMap)
		{
			if (null != videoId
				&& !videoId.isEmpty()
				&& requestId != LCRequestJni.InvalidRequestId
				&& null == mRequestVideoPhotoMap.get(requestId)) 
			{
				mRequestVideoPhotoMap.put(requestId, videoId);
				synchronized(mVideoPhotoRequestMap) {
					mVideoPhotoRequestMap.put(videoId, requestId);
				}
				result = true;
			}
			else {
				Log.e("livechat", String.format("%s::%s() fail requestId:%d", "LCVideoManager", "addRequestVideoPhoto", requestId));
			}
		}
		return result;
	} 
	
	/**
	 * 清除所有下载的视频图片
	 */
	public ArrayList<Long> clearAllRequestVideoPhoto() {
		ArrayList<Long> list = null;
		synchronized (mRequestVideoPhotoMap)
		{
			if (mRequestVideoPhotoMap.size() > 0) {
				list = new ArrayList<Long>(mRequestVideoPhotoMap.keySet());
			}
			mRequestVideoPhotoMap.clear();
			
			synchronized(mVideoPhotoRequestMap) {
				mVideoPhotoRequestMap.clear();
			}
		}
		return list;
	}
	
	// --------------------------- 正在下载的视频对照表 -------------------------
	/**
	 * 获取正在下载的视频下载器
	 * @param videoId	视频ID
	 * @return 下载器
	 */
	public LiveChatFileDownloader getDownloaderWithVideoId(String videoId)
	{
		LiveChatFileDownloader fileDownloader = null;
		synchronized(mVideoDownloadMap) {
			fileDownloader = mVideoDownloadMap.get(videoId);
		}
		return fileDownloader;
	}
	
	/**
	 * 判断视频是否在下载
	 * @param videoId	视频ID
	 * @return
	 */
	public boolean isVideoDownload(String videoId)
	{
		return getDownloaderWithVideoId(videoId) != null;
	}
	
	/**
	 * 获取并移除正在下载的视频
	 * @param fileDownloader
	 * @return 视频ID
	 */
	public String getAndRemoveDownloadVideo(LiveChatFileDownloader fileDownloader)
	{
		String videoId = "";
		synchronized (mDownloadVideoMap)
		{
			videoId = mDownloadVideoMap.remove(fileDownloader);
			if (null != videoId) {
				synchronized(mVideoDownloadMap) {
					mVideoDownloadMap.remove(videoId);
				}
			}
		}
		return videoId;
	}
	
	/**
	 * 添加下载的视频
	 * @param fileDownloader	下载器
	 * @param videoId			视频ID
	 * @return
	 */
	public boolean addDownloadVideo(LiveChatFileDownloader fileDownloader, String videoId) {
		boolean result = false;
		synchronized (mDownloadVideoMap)
		{
			if (null != videoId
				&& !videoId.isEmpty()
				&& null != fileDownloader
				&& null == mDownloadVideoMap.get(fileDownloader)) 
			{
				mDownloadVideoMap.put(fileDownloader, videoId);
				synchronized(mVideoDownloadMap) {
					mVideoDownloadMap.put(videoId, fileDownloader);
				}
				result = true;
			}
		}
		return result;
	} 
	
	/**
	 * 清除所有下载的video
	 */
	public ArrayList<LiveChatFileDownloader> clearAllRequestVideo() {
		ArrayList<LiveChatFileDownloader> list = null;
		synchronized (mDownloadVideoMap)
		{
			if (mDownloadVideoMap.size() > 0) {
				list = new ArrayList<LiveChatFileDownloader>(mDownloadVideoMap.keySet());
			}
			mDownloadVideoMap.clear();
			
			synchronized(mVideoDownloadMap) {
				mVideoDownloadMap.clear();
			}
		}
		return list;
	}
}
