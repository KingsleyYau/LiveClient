package com.qpidnetwork.livemodule.im.listener;

import java.io.Serializable;

import com.qpidnetwork.livemodule.httprequest.item.LiveRoomType;

public class IMRoomInItem implements Serializable{
	
	private static final long serialVersionUID = -2781675685594191161L;
	
	public IMRoomInItem(){
		
	}
	
	/**
	 * @param userId			主播ID
	 * @param nickName			主播昵称
	 * @param photoUrl			主播头像url
	 * @param videoUrls			视频流url（字符串数组）
	 * @param roomType			直播间类型
	 * @param credit			用户当前信用点
	 * @param usedVoucher		是否使用试用券
	 * @param fansNum			观众人数
	 * @param emoTypeList		可发送文本表情类型列表
	 * @param loveLevel			亲密度等级
	 * @param rebateItem		返点信息（Object）
	 * @param isFavorite		是否已收藏
	 * @param leftSeconds		开播前的倒数秒数
	 * @param needWait			是否要等开播通知
	 * @param manUploadRtmpUrls 男士Rtmp上传Url
	 * @param manLevel			男士等级
	 */	
	public IMRoomInItem(String userId,
						String nickName,
						String photoUrl,
						String[] videoUrls,
						int roomType,
						double credit,
						boolean usedVoucher,
						int fansNum,
						int[] emoTypeList,
						int loveLevel,
						IMRebateItem rebateItem,
						boolean isFavorite,
						int leftSeconds,
						boolean needWait,
						String[] manUploadRtmpUrls,
						int manLevel){
		this.userId = userId;
		this.nickName = nickName;
		this.photoUrl = photoUrl;
		this.videoUrls = videoUrls;
		
		if( roomType < 0 || roomType >= LiveRoomType.values().length ) {
			this.roomType = LiveRoomType.Unknown;
		} else {
			this.roomType = LiveRoomType.values()[roomType];
		}
		
		this.credit = credit;
		this.usedVoucher = usedVoucher;
		this.fansNum = fansNum;
		this.emoTypeList = emoTypeList;
		this.loveLevel = loveLevel;
		this.rebateItem = rebateItem;
		this.isFavorite = isFavorite;
		this.leftSeconds = leftSeconds;
		this.needWait = needWait;
		this.manUploadRtmpUrls = manUploadRtmpUrls;
		this.manLevel = manLevel;
	}
	
	public String userId; 
	public String nickName;
	public String photoUrl;
	public String[] videoUrls;
	public LiveRoomType roomType;
	public double credit;
	public boolean usedVoucher;
	public int fansNum;
	public int[] emoTypeList;
	public int loveLevel;
	public IMRebateItem rebateItem;
	public boolean isFavorite;
	public int leftSeconds;
	public boolean needWait;
	public String [] manUploadRtmpUrls;
	public int manLevel;
}
