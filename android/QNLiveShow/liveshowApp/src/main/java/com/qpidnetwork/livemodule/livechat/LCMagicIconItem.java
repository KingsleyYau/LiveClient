package com.qpidnetwork.livemodule.livechat;

import java.io.Serializable;

/**
 * 小高表Bean
 * @author Hunter
 * @since 2016.4.14
 */
public class LCMagicIconItem implements Serializable{
	private static final long serialVersionUID = 6084584947759524121L;
	/**
	 * Id
	 */
	private String magicIconId = "";
	/**
	 * 拇子图本地缓存地址
	 */
	private String thumbPath = "";
	/**
	 * 原图本地缓存地址
	 */
	private String sourcePath = "";
	
	public LCMagicIconItem(String magicIconId,
					String thumbPath,
					String sourcePath){
		this.setMagicIconId(magicIconId);
		this.setThumbPath(thumbPath);
		this.setSourcePath(sourcePath);
	}

	public String getMagicIconId() {
		return magicIconId;
	}

	public void setMagicIconId(String magicIconId) {
		this.magicIconId = magicIconId;
	}

	public String getThumbPath() {
		return thumbPath;
	}

	public void setThumbPath(String thumbPath) {
		this.thumbPath = thumbPath;
	}

	public String getSourcePath() {
		return sourcePath;
	}

	public void setSourcePath(String sourcePath) {
		this.sourcePath = sourcePath;
	}
	
}
