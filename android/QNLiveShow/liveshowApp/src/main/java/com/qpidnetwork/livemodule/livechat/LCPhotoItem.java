package com.qpidnetwork.livemodule.livechat;

import com.qpidnetwork.livemodule.livechathttprequest.LCRequestJniLiveChat.PhotoModeType;
import com.qpidnetwork.livemodule.livechathttprequest.LCRequestJniLiveChat.PhotoSizeType;

import java.io.File;
import java.io.Serializable;


/**
 * 图片对象
 * @author Samson Fan
 */
public class LCPhotoItem implements Serializable{

	private static final long serialVersionUID = 8719070618687111312L;
	/**
	 * 图片ID
	 */
	public String photoId;
	/**
	 * 图片描述
	 */
	public String photoDesc;
	/**
	 * 发送ID（仅发送）
	 */
	public String sendId;
	/**
	 * 用于显示不清晰图的路径
	 */
	public String showFuzzyFilePath;
	/**
	 * 拇指不清晰图路径
	 */
	public String thumbFuzzyFilePath;
	/**
	 * 原图路径
	 */
	public String srcFilePath;
	/**
	 * 用于显示的原图路径
	 */
	public String showSrcFilePath;
	/**
	 * 拇指原图路径
	 */
	public String thumbSrcFilePath;
	/**
	 * 是否已付费
	 */
	public boolean charge;
	/**
	 * 处理状态定义
	 */
	enum StatusType {
		/**
		 * 已完成
		 */
		Finish,
		/**
		 * 正在付费
		 */
		PhotoFee,
		/**
		 * 正在下载模糊拇指图
		 */
		DownloadThumbFuzzyPhoto,
		/**
		 * 正在下载模糊显示图
		 */
		DownloadShowFuzzyPhoto,
		/**
		 * 正在下载清晰拇指图
		 */
		DownloadThumbSrcPhoto,
		/**
		 * 正在下载清晰显示图
		 */
		DownloadShowSrcPhoto,
		/**
		 * 正在下载原图
		 */
		DownloadSrcPhoto,
	}
	StatusType statusType;
	
	
	public LCPhotoItem() {
		photoId = "";
		sendId = "";
		photoDesc = "";
		showFuzzyFilePath = "";
		thumbFuzzyFilePath = "";
		srcFilePath = "";
		showSrcFilePath = "";
		thumbSrcFilePath = "";
		charge = false;
		statusType = StatusType.Finish;
	}
	
	public void init(
			String photoId
			, String sendId
			, String photoDesc
			, String showFuzzyFilePath
			, String thumbFuzzyFilePath
			, String srcFilePath
			, String showSrcFilePath
			, String thumbSrcFilePath
			, boolean charge) 
	{
		this.photoId = photoId;
		this.sendId = sendId;
		this.photoDesc = photoDesc;
		this.charge = charge;
		
		if (!showFuzzyFilePath.isEmpty()) {
			File file = new File(showFuzzyFilePath);
			if (file.exists()) {
				this.showFuzzyFilePath = showFuzzyFilePath;
			}
		}
		
		if (!thumbFuzzyFilePath.isEmpty()) {
			File file = new File(thumbFuzzyFilePath);
			if (file.exists()) {
				this.thumbFuzzyFilePath = thumbFuzzyFilePath;
			}
		}
		
		if (!srcFilePath.isEmpty()) {
			File file = new File(srcFilePath);
			if (file.exists()) {
				this.srcFilePath = srcFilePath;
			}
		}
		
		if (!showSrcFilePath.isEmpty()) {
			File file = new File(showSrcFilePath);
			if (file.exists()) {
				this.showSrcFilePath = showSrcFilePath;
			}
		}
		
		if (!thumbSrcFilePath.isEmpty()) {
			File file = new File(thumbSrcFilePath);
			if (file.exists()) {
				this.thumbSrcFilePath = thumbSrcFilePath;
			}
		}
	}
	
	/**
	 * 设置处理状态
	 * @param modeType	图片类型
	 * @param sizeType	图片尺寸
	 */
	public void SetStatusType(PhotoModeType modeType, PhotoSizeType sizeType)
	{
		if (modeType == PhotoModeType.Clear) {
			if (sizeType == PhotoSizeType.Large
				|| sizeType == PhotoSizeType.Middle) 
			{
				statusType = StatusType.DownloadShowSrcPhoto;
			}
			else if (sizeType == PhotoSizeType.Original) 
			{
				statusType = StatusType.DownloadSrcPhoto;
			}
			else {
				statusType = StatusType.DownloadThumbSrcPhoto;
			}
		}
		else if (modeType == PhotoModeType.Fuzzy) {
			if (sizeType == PhotoSizeType.Large
				|| sizeType == PhotoSizeType.Middle) 
			{
				statusType = StatusType.DownloadShowFuzzyPhoto;
			}
			else {
				statusType = StatusType.DownloadThumbFuzzyPhoto;
			}
		}
	}
}
