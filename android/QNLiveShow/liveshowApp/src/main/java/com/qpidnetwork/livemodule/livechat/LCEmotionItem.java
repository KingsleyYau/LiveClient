package com.qpidnetwork.livemodule.livechat;

import java.io.File;
import java.io.Serializable;
import java.util.ArrayList;

/**
 * 高级表情item
 * @author Samson Fan
 *
 */
public class LCEmotionItem implements Serializable{

	private static final long serialVersionUID = -7292173717388991648L;
	/**
	 * 高级表情ID
	 */
	public String emotionId;
	/**
	 * 缩略图路径 
	 */
	public String imagePath;
	/**
	 * 播放大图路径
	 */
	public String playBigPath;
	/**
	 * 播放大图数组路径
	 */
	public ArrayList<String> playBigImages;
//	/**
//	 * 播放中图路径
//	 */
//	public String playMidPath;
//	/**
//	 * 播放中图数组路径
//	 */
//	public ArrayList<String> playMidImages;
//	/**
//	 * 播放小图路径
//	 */
//	public String playSmallPath;
//	/**
//	 * 播放小图路径
//	 */
//	public ArrayList<String> playSmallImages;
	/**
	 * 文件路径 
	 */
	public String f3gpPath;
	
	public LCEmotionItem() {
		emotionId = "";
		imagePath = "";
		f3gpPath = "";
		playBigPath = "";
		playBigImages = new ArrayList<String>();
//		playMidPath = "";
//		playMidImages = new ArrayList<String>();
//		playSmallPath = "";
//		playSmallImages = new ArrayList<String>();
	}
	
	public boolean init(
			String emotionId
			, String imagePath
			, String f3gpPath
			, String playBigPath
			, String playBigSubPath
//			, String playMidPath
//			, String playMidSubPath
//			, String playSmallPath
//			, String playSmallSubPath
			) 
	{
		boolean result = false;
		if (!emotionId.isEmpty()) 
		{
			this.emotionId = emotionId;
			
			if (!imagePath.isEmpty()) {
				File file = new File(imagePath);
				if (file.exists()) {
					this.imagePath = imagePath;
				}
			}
			
			if (!f3gpPath.isEmpty()) {
				File file = new File(f3gpPath);
				if (file.exists()) {
					this.f3gpPath = f3gpPath;
				}
			}
			
			if (!playBigPath.isEmpty()) {
				File file = new File(playBigPath);
				if (file.exists()) {
					this.playBigPath = playBigPath;
				}
			}
			
			setPlayBigSubPath(playBigSubPath);
			
//			if (!playMidPath.isEmpty()) {
//				File file = new File(playMidPath);
//				if (file.exists()) {
//					this.playMidPath = playMidPath;
//				}
//			}
//			
//			if (!playMidSubPath.isEmpty()) {
//				ArrayList<String> images = new ArrayList<String>();
//				int i = 0;
//				while (true) {
//					String path = String.format(playMidSubPath, i);
//					File file = new File(path);
//					if (file.exists()) {
//						images.add(path);
//					}
//					else {
//						break;
//					}
//					i++;
//				}
//				
//				if (images.size() > 0) {
//					playMidImages.clear();
//					playMidImages.addAll(images);
//				}
//			}
//			
//			if (!playSmallPath.isEmpty()) {
//				File file = new File(playSmallPath);
//				if (file.exists()) {
//					this.playSmallPath = playSmallPath;
//				}
//			}
//			
//			if (!playSmallSubPath.isEmpty()) {
//				ArrayList<String> images = new ArrayList<String>();
//				int i = 0;
//				while (true) {
//					String path = String.format(playSmallSubPath, i);
//					File file = new File(path);
//					if (file.exists()) {
//						images.add(path);
//					}
//					else {
//						break;
//					}
//					i++;
//				}
//				
//				if (images.size() > 0) {
//					playSmallImages.clear();
//					playSmallImages.addAll(images);
//				}
//			}
				
			result = true;
		}
		return result;
	}
	
	public boolean setPlayBigSubPath(String playBigSubPath) 
	{
		boolean result = false;
		
		if (!playBigSubPath.isEmpty()) {
			ArrayList<String> images = new ArrayList<String>();
			int i = 0;
			while (true) {
				String path = String.format(playBigSubPath, i);
				File file = new File(path);
				if (file.exists()) {
					images.add(path);
				}
				else {
					break;
				}
				i++;
			}
			
			if (images.size() > 0) {
				playBigImages.clear();
				playBigImages.addAll(images);
				
				result = true;
			}
		}
		
		return result;
	}
}
