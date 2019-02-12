package com.qpidnetwork.livemodule.livechat;

import android.content.Context;


/**
 * 高级表情下载器
 * @author Samson Fan
 */
public class LCEmotionDownloader implements LiveChatFileDownloader.LiveChatFileDownloaderCallback
{
	public interface LCEmotionDownloaderCallback {
		void onSuccess(EmotionFileType fileType, LCEmotionItem item);
		void onFail(EmotionFileType fileType, LCEmotionItem item);
	}

	private LiveChatFileDownloader mLiveChatFileDownloader;
	private LCEmotionItem mEmotionItem;
	private EmotionFileType mFileType;
	private LCEmotionDownloaderCallback mCallback;
	private String mFilePath;
	private String mUrl;
	/**
	 * 高级表情待下载的文件类型 
	 */
	public enum EmotionFileType {
		funknow,
		fimage,
		fplaybigimage,
		fplaymidimage,
		fplaysmallimage,
		f3gp
	}
	
	public LCEmotionDownloader(Context context) {
		mFileType = EmotionFileType.funknow;
		mLiveChatFileDownloader = new LiveChatFileDownloader(context);
		mEmotionItem = null;
		mCallback = null;
		mFilePath = "";
		mUrl = "";
	}
	
	/**
	 * 开始下载
	 * @param url		文件下载URL
	 * @param filePath	文件本地路径
	 * @param fileType	文件类型
	 * @param item		高级表情item
	 * @param callback	回调
	 */
	public boolean Start(String url, String filePath, EmotionFileType fileType, LCEmotionItem item, LCEmotionDownloaderCallback callback) {
		boolean result = false;
		if (!url.isEmpty() 
			&& !filePath.isEmpty()
			&& fileType != EmotionFileType.funknow
			&& item != null
			&& callback != null)
		{
			mEmotionItem = item;
			mCallback = callback;
			mFilePath = filePath;
			mUrl = url;
			mFileType = fileType;
			mLiveChatFileDownloader.StartDownload(mUrl, mFilePath, this);
			
			result = true;
		}
		return result;
	}
	
	/**
	 * 停止下载
	 */
	public void Stop() {
		mLiveChatFileDownloader.Stop();
	}

	// ------------- LiveChatFileDownloader.LiveChatFileDownloaderCallback ------------- 
	@Override
	public void onSuccess(LiveChatFileDownloader loader) {
		if (mEmotionItem != null) {
			if (mFileType == EmotionFileType.f3gp) {
				mEmotionItem.f3gpPath = mFilePath;
			}
			else if (mFileType == EmotionFileType.fimage) {
				mEmotionItem.imagePath = mFilePath;
			}
			else if (mFileType == EmotionFileType.fplaybigimage) {
				mEmotionItem.playBigPath = mFilePath;
			}
			else if (mFileType == EmotionFileType.fplaymidimage) {
//				mEmotionItem.playMidPath = mFilePath;
			}
			else if (mFileType == EmotionFileType.fplaysmallimage) {
//				mEmotionItem.playSmallPath = mFilePath;
			}
		}
		
		if (mCallback != null) {
			mCallback.onSuccess(mFileType, mEmotionItem);
		}
		
		mCallback = null;
		mLiveChatFileDownloader = null;
		mEmotionItem = null;
	}

	@Override
	public void onFail(LiveChatFileDownloader loader) {
		if (mCallback != null) {
			mCallback.onFail(mFileType, mEmotionItem);
		}
		
		mCallback = null;
		mLiveChatFileDownloader = null;
		mEmotionItem = null;
	}

	@Override
	public void onUpdate(LiveChatFileDownloader loader, int progress) {

	}
}
