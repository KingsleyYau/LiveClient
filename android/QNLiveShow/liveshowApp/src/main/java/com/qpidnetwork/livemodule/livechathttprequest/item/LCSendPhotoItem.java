package com.qpidnetwork.livemodule.livechathttprequest.item;

public class LCSendPhotoItem {
	public LCSendPhotoItem() {
		
	}

	/**
	 * 发送私密照片
	 * @param photoId	照片ID
	 * @param sendId	发送ID
	 */
	public LCSendPhotoItem(
			String photoId,
			String sendId
			) 
	{
		this.photoId = photoId;
		this.sendId = sendId;
	}
	
	public String photoId;
	public String sendId;
}
