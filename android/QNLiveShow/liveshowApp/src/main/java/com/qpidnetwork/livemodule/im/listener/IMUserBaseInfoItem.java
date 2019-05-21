package com.qpidnetwork.livemodule.im.listener;

import android.os.Parcel;
import android.os.Parcelable;

public class IMUserBaseInfoItem implements Parcelable {

	public IMUserBaseInfoItem(){
		
	}
	
	/**
	 * 粉丝基础信息
	 * @param userId
	 * @param nickName
	 * @param photoUrl
	 */
	public IMUserBaseInfoItem(String userId,
						String nickName,
						String photoUrl){
		this.userId = userId;
		this.nickName = nickName;
		this.photoUrl = photoUrl;
	}

	/**
	 * 粉丝基础信息
	 * @param userId
	 * @param nickName
	 * @param photoUrl
	 * @param isHasTicket
	 */
	public IMUserBaseInfoItem(String userId,
							  String nickName,
							  String photoUrl,
							  boolean isHasTicket){
		this.userId = userId;
		this.nickName = nickName;
		this.photoUrl = photoUrl;
		this.isHasTicket = isHasTicket;
	}
	
	public String userId;
	public String nickName;
	public String photoUrl;				//用于显示的其他用户小头像
	public boolean isHasTicket = false;	//是否已购票

	/******************************************  Parcelable相关   ****************************************/
	@Override
	public int describeContents() {
		return 0;
	}

	@Override
	public void writeToParcel(Parcel dest, int flags) {
		dest.writeString(userId);
		dest.writeString(nickName);
		dest.writeString(photoUrl);
		dest.writeByte((byte) (isHasTicket ? 1 : 0));
	}

	public static final Parcelable.Creator<IMUserBaseInfoItem> CREATOR = new Parcelable.Creator<IMUserBaseInfoItem>() {
		public IMUserBaseInfoItem createFromParcel(Parcel in) {
			return new IMUserBaseInfoItem(in);
		}
		public IMUserBaseInfoItem[] newArray(int size) {
			return new IMUserBaseInfoItem[size];
		}
	};

	private IMUserBaseInfoItem(Parcel in) {
		userId = in.readString();
		nickName = in.readString();
		photoUrl = in.readString();
		isHasTicket = in.readByte() != 0;
	}
}
