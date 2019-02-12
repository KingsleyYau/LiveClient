package com.qpidnetwork.livemodule.livechat;

import android.content.Context;

public class LCMagicIconDownloader implements LiveChatFileDownloader.LiveChatFileDownloaderCallback{
	
	private LiveChatFileDownloader mLiveChatFileDownloader;
	private LCMagicIconItem mMagicIconItem;
	private MagicIconDownloadType mDownloadType;
	private LCMagicIconDownloaderCallback mCallback;
	
	public LCMagicIconDownloader(Context context){
		mLiveChatFileDownloader = new LiveChatFileDownloader(context);
		mMagicIconItem = null;
		mCallback = null;
		mDownloadType = MagicIconDownloadType.DEFAULT;
	} 
	
	/**
	 * 开始下载
	 * @param url		文件下载URL
	 * @param filePath	文件本地路径
	 * @param downloadType	文件类型
	 * @param item		高级表情item
	 * @param callback	回调
	 */
	public boolean Start(String url, String filePath, MagicIconDownloadType downloadType, LCMagicIconItem item, LCMagicIconDownloaderCallback callback) {
		boolean result = false;
		if (!url.isEmpty() 
			&& !filePath.isEmpty()
			&& downloadType != MagicIconDownloadType.DEFAULT
			&& item != null
			&& callback != null)
		{
			mMagicIconItem = item;
			mCallback = callback;
			mDownloadType = downloadType;
			mLiveChatFileDownloader.StartDownload(url, filePath, this);
			result = true;
		}
		return result;
	}
	
	/**
	 * 停止下载
	 */
	public void Stop() {
		if(mLiveChatFileDownloader != null){
			mLiveChatFileDownloader.Stop();
		}
	}

	@Override
	public void onSuccess(LiveChatFileDownloader loader) {
		// TODO Auto-generated method stub
		if (mCallback != null) {
			mCallback.onSuccess(mDownloadType, mMagicIconItem);
		}
		
		mCallback = null;
		mLiveChatFileDownloader = null;
		mMagicIconItem = null;
	}

	@Override
	public void onFail(LiveChatFileDownloader loader) {
		if (mCallback != null) {
			mCallback.onFail(mDownloadType, mMagicIconItem);
		}
		
		mCallback = null;
		mLiveChatFileDownloader = null;
		mMagicIconItem = null;		
	}

	@Override
	public void onUpdate(LiveChatFileDownloader loader, int progress) {

	}


	public enum MagicIconDownloadType{
		DEFAULT,
		THUMB,
		SOURCE
	}
	
	public interface LCMagicIconDownloaderCallback {
		void onSuccess(MagicIconDownloadType downloadType, LCMagicIconItem item);
		void onFail(MagicIconDownloadType downloadType, LCMagicIconItem item);
	}
}
