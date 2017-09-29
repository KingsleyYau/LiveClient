package com.qpidnetwork.livemodule.im.listener;

import java.io.Serializable;

public class IMRoomInItem implements Serializable{
	
	/**
	 * 直播间类型
	 * @author Hunter Mun
	 *
	 */
	public enum IMLiveRoomType {
		Unknown,				//未知
		FreePublicRoom,			//免费公开直播间
		NormalPrivateRoom,		//普通私密直播间
		PaidPublicRoom,			//付费公开直播间
		AdvancedPrivateRoom		//豪华私密直播间
	}
	
	private static final long serialVersionUID = -2781675685594191161L;
	
	public IMRoomInItem(){
		
	}
	
	/**
	 * @param userId			主播ID
	 * @param nickName			主播昵称
	 * @param photoUrl			主播头像url
	 * @param videoUrls			视频流url（字符串数组）
	 * @param roomId			视频流url（字符串数组）
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
	 * @param roomPrice			直播间资费
	 * @param videoPrice		视频资费
	 * @param audienceLimitNum	最大人数限制
	 */	
	public IMRoomInItem(String userId,
						String nickName,
						String photoUrl,
						String[] videoUrls,
						String roomId,
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
						int manLevel,
						double roomPrice,
						double videoPrice,
						int audienceLimitNum){
		this.userId = userId;
		this.nickName = nickName;
		this.photoUrl = photoUrl;
		this.videoUrls = videoUrls;
		this.roomId = roomId;
		
		if( roomType < 0 || roomType >= IMLiveRoomType.values().length ) {
			this.roomType = IMLiveRoomType.Unknown;
		} else {
			this.roomType = IMLiveRoomType.values()[roomType];
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
		this.roomPrice = roomPrice;
		this.videoPrice = videoPrice;
		this.audienceLimitNum = audienceLimitNum;
	}
	
	public String userId; 
	public String nickName;
	public String photoUrl;
	public String[] videoUrls;
	public String roomId;
	public IMLiveRoomType roomType;
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
	public double roomPrice;
	public double videoPrice;
	public int audienceLimitNum;

	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder("IMRoomInItem[");
		sb.append("userId:");
		sb.append(userId);
		sb.append(" nickName:");
		sb.append(nickName);
		sb.append(" photoUrl:");
		sb.append(photoUrl);
		sb.append(" videoUrls:");
		sb.append(videoUrls);
		sb.append(" roomType:");
		sb.append(roomType);
		sb.append(" roomId:");
		sb.append(roomId);
		sb.append(" credit:");
		sb.append(credit);
		sb.append(" usedVoucher:");
		sb.append(usedVoucher);
		sb.append(" fansNum:");
		sb.append(fansNum);
		sb.append(" emoTypeList:");
		sb.append(emoTypeList);
		sb.append(" loveLevel:");
		sb.append(loveLevel);
		sb.append(" rebateItem:");
		sb.append(rebateItem);
		sb.append(" isFavorite:");
		sb.append(isFavorite);
		sb.append(" leftSeconds:");
		sb.append(leftSeconds);
		sb.append(" needWait:");
		sb.append(needWait);
		sb.append(" manUploadRtmpUrls:");
		sb.append(manUploadRtmpUrls);
		sb.append(" manLevel:");
		sb.append(manLevel);
		sb.append(" roomPrice:");
		sb.append(roomPrice);
		sb.append(" videoPrice:");
		sb.append(videoPrice);
		sb.append(" audienceLimitNum:");
		sb.append(audienceLimitNum);
		sb.append("]");
		return sb.toString();
	}
}
