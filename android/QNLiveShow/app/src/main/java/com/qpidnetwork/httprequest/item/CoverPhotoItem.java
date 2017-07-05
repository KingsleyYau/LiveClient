package com.qpidnetwork.httprequest.item;


public class CoverPhotoItem {
	
	public enum PhotoStatus{
		Unknown,
		Pending,			//审核中
		Approval,			//已审核通过
		Denied				//拒绝
	}
	
	public CoverPhotoItem(){
		photoStatus = PhotoStatus.Pending;
		isInUse = false;
	}
	
	/**
	 * 封面图Bean
	 * @param photoId			//封面图ID
	 * @param photoUrl			//封面图url
	 * @param photoStatus		//审核状态
	 * @param isInUse			//是否正在使用
	 */
	public CoverPhotoItem(String photoId,
						String photoUrl,
						int photoStatus,
						boolean isInUse){
		this.photoId = photoId;
		this.photoUrl = photoUrl;
		
		if( photoStatus < 0 || photoStatus >= PhotoStatus.values().length ) {
			this.photoStatus = PhotoStatus.Pending;
		} else {
			this.photoStatus = PhotoStatus.values()[photoStatus];
		}
		this.isInUse = isInUse;
	}
	
	public String photoId;
	public String photoUrl;
	public PhotoStatus photoStatus;
	public boolean isInUse;
}
