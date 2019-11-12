package com.qpidnetwork.livemodule.httprequest.item;

/**
 * checkout鲜花礼品Item
 * @author Alex
 *
 */
public class LSAdWomanListAdvertItem {


	/**
	 * 广告URL打开方式
	 */
	public enum LSOpenType {
		HIDE,			// 隐藏打开
		SYSTEMBROWER,	// 系统浏览器打开
		APPBROWER,		// app内嵌浏览器打开
		UNKNOW			// 未知类型
	}

	public LSAdWomanListAdvertItem(){

	}

	/**
	 * checkout鲜花礼品Item
	 * @param id				广告ID
	 * @param image				广告图片URL
	 * @param width				图片宽度
	 * @param height			图片高度
	 * @param adurl				广告点击打开的URL
	 * @param openType			广告点击打开方式
	 * @param advertTitle		广告标题
	 */
	public LSAdWomanListAdvertItem(String id,
                                   String image,
                                   int width,
                                   int height,
								   String adurl,
                                   int openType,
								   String advertTitle){
		this.id = id;
		this.image = image;
		this.width = width;
		this.height = height;
		this.adurl = adurl;
		if( openType < 0 || openType >= AnchorLevelType.values().length ) {
			this.openType = LSOpenType.HIDE;
		} else {
			this.openType = LSOpenType.values()[openType];
		}

		this.advertTitle = advertTitle;

	}

	public String id;
	public String image;
	public int width;
	public int height;
	public String adurl;
	public LSOpenType openType;
	public String advertTitle;

	@Override
	public String toString() {
		return "LSAdWomanListAdvertItem[id:"+id
				+ " image:"+image
				+ " width:"+width
				+ " height:"+height
				+ " adurl:"+adurl
				+ " openType:"+openType
				+ " advertTitle:"+advertTitle
				+ "]";
	}
}
