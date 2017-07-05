package com.qpidnetwork.httprequest;


public class RequestJniUserInfo {
	
	/**
	 * 头像类型
	 */
	public enum PhotoType{
		Unknown,
		Thumb,
		Large
	}
	
	/**
	 * 性别
	 */
	public enum Gender{
		Unknown,
		Male,
		Female
	}
	
	/**
	 * 获取用户头像接口
	 * @param userId
	 * @param photoType
	 * @param callbacks
	 * @return
	 */
	static public long GetUserPhotoInfo(String userId, PhotoType photoType, OnGetUserPhotoCallback callback){
		return GetUserPhotoInfo(userId, photoType.ordinal(), callback);
	}
	static private native long GetUserPhotoInfo(String userId, int photoType, OnGetUserPhotoCallback callback);
	
	/**
	 * 获取用户个人资料
	 * @param callback
	 * @return
	 */
	static public native long GetUserProfile(OnGetProfileCallback callback);
	
	/**
	 * 编辑个人信息
	 * @param photoId
	 * @param nickName
	 * @param gender
	 * @param birthday
	 * @param callback
	 * @return
	 */
	static public long EditUserProfile(String photoId, String nickName, Gender gender, String birthday, OnRequestCallback callback){
		return EditUserProfile(photoId, nickName, gender.ordinal(), birthday, callback);
	}
	static private native long EditUserProfile(String photoId, String nickName, int gender, String birthday, OnRequestCallback callback);
}
