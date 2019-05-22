package com.qpidnetwork.qnbridgemodule.view.camera;

import java.io.Serializable;

/**
 * 系统图片类
 * @author Hunter
 * @since 2015.5.6
 */
public class ImageBean implements Serializable{
	
	private static final long serialVersionUID = 594001293054851923L;
	
	public String imageId;
	public String thumbnailPath;
	public String imagePath;

	// 2019/5/14 Hardy
	// 文件名，包含后缀名
	// 例如：1557814957403.jpg
	public String imageFileName;

	// 2018/12/17 Hardy 记录是否选中当前 item
	public boolean isSelect;

}
