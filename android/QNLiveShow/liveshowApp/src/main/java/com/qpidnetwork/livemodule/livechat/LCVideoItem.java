package com.qpidnetwork.livemodule.livechat;

import android.text.TextUtils;

import com.qpidnetwork.livemodule.livechathttprequest.LCRequestJniLiveChat.VideoPhotoType;

import java.io.File;
import java.io.Serializable;


/**
 * 微视频对象
 * @author Samson Fan
 */
public class LCVideoItem implements Serializable{

	/**
	 * 
	 */
	private static final long serialVersionUID = -8534730648806322141L;
	/**
	 * 视频ID
	 */
	public String videoId;
	/**
	 * 视频描述
	 */
	public String videoDesc;
	/**
	 * 发送ID（仅发送）
	 */
	public String sendId;
	/**
	 * 视频文件URL
	 */
	public String videoUrl;
	/**
	 * 小图路径
	 */
	public String thumbPhotoFilePath;
	/**
	 * 大图路径
	 */
	public String bigPhotoFilePath;
	/**
	 * 视频路径
	 */
	public String videoFilePath;
	/**
	 * 是否已付费
	 */
	public boolean charget;
	/**
	 * 是否正在付费
	 */
	public boolean isVideoFeeding;
	/**
	 * 是否正在下载小图
	 */
	public boolean isThumbPhotoDownloading;
	/**
	 * 是否正在下载大图
	 */
	public boolean isBigPhotoDownloading;
	/**
	 * 是否正在下载视频
	 */
	public boolean isVideoDownloading;
	/**
	 * 视频文件下载进度（0-100）
	 */
	public int videoDownloadProgress;
	
	
	public LCVideoItem() {
		videoId = "";
		sendId = "";
		videoDesc = "";
		bigPhotoFilePath = "";
		thumbPhotoFilePath = "";
		videoFilePath = "";
		charget = false;
		videoUrl = "";
		isVideoFeeding = false;
		isThumbPhotoDownloading = false;
		isBigPhotoDownloading = false;
		isVideoDownloading = false;
		videoDownloadProgress = 0;
	}
	
	public void init(
			String videoId
			, String sendId
			, String videoDesc
			, String bigPhotoFilePath
			, String thumbPhotoFilePath
			, String videoUrl
			, String videoFilePath
			, boolean charget) 
	{
		this.videoId = videoId;
		this.sendId = sendId;
		this.videoDesc = videoDesc;
		this.charget = charget;
		this.videoUrl = videoUrl;
		
		if (!bigPhotoFilePath.isEmpty()) {
			File file = new File(bigPhotoFilePath);
			if (file.exists()) {
				this.bigPhotoFilePath = bigPhotoFilePath;
			}
		}
		
		if (!thumbPhotoFilePath.isEmpty()) {
			File file = new File(thumbPhotoFilePath);
			if (file.exists()) {
				this.thumbPhotoFilePath = thumbPhotoFilePath;
			}
		}
		
		if (!videoFilePath.isEmpty()) {
			File file = new File(videoFilePath);
			if (file.exists()) {
				this.videoFilePath = videoFilePath;
			}
		}
	}
	
	/**
	 * 更新视频图片下载标志
	 * @param type			图片类型
	 * @param isDownloading	下载标志
	 */
	public void updatePhotoDownloadSign(VideoPhotoType type, boolean isDownloading)
	{
		switch (type)
		{
		case Big: {
			this.isBigPhotoDownloading = isDownloading;
		}break;
		case Default: {
			this.isThumbPhotoDownloading = isDownloading;
		}break;
		}
	}
	
	/**
	 * 更新视频图片路径
	 * @param filePath	图片路径
	 * @param type		图片类型
	 */
	public void updatePhotoPathWithType(String filePath, VideoPhotoType type) 
	{
		if (!TextUtils.isEmpty(filePath))
		{
			File file = new File(filePath);
			if (file.isFile() && file.exists()) 
			{
				switch (type)
				{
				case Big: {
					this.bigPhotoFilePath = filePath;
				}break;
				case Default: {
					this.thumbPhotoFilePath = filePath;
				}break;
				}
			}
		}
	}
}
