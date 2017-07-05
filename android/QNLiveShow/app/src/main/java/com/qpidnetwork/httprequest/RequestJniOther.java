package com.qpidnetwork.httprequest;

import com.qpidnetwork.httprequest.RequestJniUserInfo.PhotoType;

/**
 * 5. 其他接口
 * @author Hunter Mun
 * @since 2017-6-8
 */
public class RequestJniOther {
	
	public enum UploadPhotoType{
		Unknown,
		UserPhoto,
		CoverPhoto
	}
	
	/**
	 * 5.1. 同步配置
	 * @param callback
	 * @return
	 */
	static public native long SynConfig(OnSynConfigCallback callback);
	
	/**
	 * 5.2. 上传图片
	 * @param uploadPhotoType
	 * @param filePath
	 * @return
	 */
	static public long UploadPicture(UploadPhotoType uploadPhotoType, String filePath, OnUploadPictureCallback callback){
		return UploadPicture(uploadPhotoType.ordinal(), filePath, callback);
	}
	static private native long UploadPicture(int uploadPhotoType, String filePath, OnUploadPictureCallback callback);
	
}
