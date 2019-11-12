package com.qpidnetwork.livemodule.livechat;

import android.text.TextUtils;

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
	 * 增加用户属性，解决由于男女士图片不同表，即可能出现相同photoId对应不同图片
	 */
	public enum PhotoUserAttribute{
		Man,
		Woman
	}

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
	 * photoItem唯一性以来（photoUserAttr， photoId）
	 */
	public PhotoUserAttribute photoUserAttr;

	/**
	 * 是否已付费
	 */
	public boolean charge;

	/**
	 * 模糊小图
	 */
	public LCPhotoInfoItem mFuzzySmallPhotoInfo;

	/**
	 * 模糊中图
	 */
	public LCPhotoInfoItem mFuzzyMiddlePhotoInfo;

	/**
	 * 模糊大图
	 */
	public LCPhotoInfoItem mFuzzyLargePhotoInfo;

	/**
	 * 模糊原始图
	 */
	public LCPhotoInfoItem mFuzzySrcPhotoInfo;

	/**
	 * 清晰小图
	 */
	public LCPhotoInfoItem mClearSmallPhotoInfo;

	/**
	 * 清晰中图
	 */
	public LCPhotoInfoItem mClearMiddlePhotoInfo;

	/**
	 * 清晰大图
	 */
	public LCPhotoInfoItem mClearLargePhotoInfo;

	/**
	 * 清晰原始图
	 */
	public LCPhotoInfoItem mClearSrcPhotoInfo;

	
	public LCPhotoItem() {
		photoId = "";
		sendId = "";
		photoDesc = "";
		charge = false;
		photoUserAttr = PhotoUserAttribute.Man;
	}
	
	public void init(
			LCPhotoManager photoManager
			,String photoId
			, String sendId
			, String photoDesc
			, boolean charge
			, boolean isMan)
	{
		this.photoId = photoId;
		this.sendId = sendId;
		this.photoDesc = photoDesc;
		this.charge = charge;

		if(isMan){
			photoUserAttr = PhotoUserAttribute.Man;
		}else{
			photoUserAttr = PhotoUserAttribute.Woman;
		}

		//处理本地已存在，直接赋值
		initPhotoInfos(photoManager, photoUserAttr, photoId, PhotoModeType.Clear, PhotoSizeType.Original);
		initPhotoInfos(photoManager, photoUserAttr, photoId, PhotoModeType.Clear, PhotoSizeType.Large);
		initPhotoInfos(photoManager, photoUserAttr, photoId, PhotoModeType.Clear, PhotoSizeType.Middle);
		initPhotoInfos(photoManager, photoUserAttr, photoId, PhotoModeType.Clear, PhotoSizeType.Small);
		initPhotoInfos(photoManager, photoUserAttr, photoId, PhotoModeType.Fuzzy, PhotoSizeType.Original);
		initPhotoInfos(photoManager, photoUserAttr, photoId, PhotoModeType.Fuzzy, PhotoSizeType.Large);
		initPhotoInfos(photoManager, photoUserAttr, photoId, PhotoModeType.Fuzzy, PhotoSizeType.Middle);
		initPhotoInfos(photoManager, photoUserAttr, photoId, PhotoModeType.Fuzzy, PhotoSizeType.Small);
	}

	/**
	 * 初始化private photo状态，如果本地已存在，直接赋值
	 * @param photoManager
	 * @param photoUserAttr
	 * @param photoId
	 * @param modeType
	 * @param sizeType
	 */
	private void initPhotoInfos(LCPhotoManager photoManager, PhotoUserAttribute photoUserAttr, String photoId, PhotoModeType modeType, PhotoSizeType sizeType){
		String localPath = photoManager.getPhotoPath(photoUserAttr, photoId, modeType, sizeType);
		if(!TextUtils.isEmpty(localPath)){
			File file = new File(localPath);
			if(file.exists()){
				setPhotInfoItem(modeType, sizeType, LCPhotoInfoItem.StatusType.Success, "", "", localPath);
			}
		}
	}

	/**
	 * 更新photo下载状态
	 * @param modeType
	 * @param sizeType
	 * @param statusType
	 * @param errno
	 * @param errmsg
	 * @param photoPath
	 */
	public void setPhotInfoItem(PhotoModeType modeType,
								PhotoSizeType sizeType,
								LCPhotoInfoItem.StatusType statusType,
								String errno,
								String errmsg,
								String photoPath){
		LCPhotoInfoItem photoInfoItem = new LCPhotoInfoItem(statusType, errno, errmsg, photoPath);
		if(modeType == PhotoModeType.Fuzzy){
			switch (sizeType){
				case Original:{
					mFuzzySrcPhotoInfo = photoInfoItem;
				}break;
				case Large:{
					mFuzzyLargePhotoInfo = photoInfoItem;
				}break;
				case Middle:{
					mFuzzyMiddlePhotoInfo = photoInfoItem;
				}break;
				case Small:{
					mFuzzySmallPhotoInfo = photoInfoItem;
				}break;
			}
		}else{
			switch (sizeType){
				case Original:{
					mClearSrcPhotoInfo = photoInfoItem;
				}break;
				case Large:{
					mClearLargePhotoInfo = photoInfoItem;
				}break;
				case Middle:{
					mClearMiddlePhotoInfo = photoInfoItem;
				}break;
				case Small:{
					mClearSmallPhotoInfo = photoInfoItem;
				}break;
			}
		}
	}

}
