package com.qpidnetwork.livemodule.httprequest.item;

/**
 * Say Hi详情的主播Item
 * @author Alex
 *
 */
public class SayHiDetailAnchorItem {

	public SayHiDetailAnchorItem(){

	}

	/**
	 * Say Hi详情的主播Item
	 * @param sayHiId		sayHi的ID
	 * @param anchorId		主播ID
	 * @param nickName		主播昵称
	 * @param cover			主播封面
	 * @param avatar		主播头像
	 * @param age			主播年龄
	 * @param sendTime		发送时间戳
	 * @param text		    文本内容
	 * @param imgUrl		图片地址
	 * @param responseNum	回复数
	 * @param unreadNum		未读数
	 *
	 */
	public SayHiDetailAnchorItem(
						 String sayHiId,
						 String anchorId,
						 String nickName,
						 String cover,
						 String avatar,
						 int age,
						 int sendTime,
						 String text,
						 String imgUrl,
						 int responseNum,
						 int unreadNum){
		this.sayHiId = sayHiId;
		this.anchorId = anchorId;
		this.nickName = nickName;
		this.cover = cover;
		this.avatar = avatar;
		this.age = age;
		this.sendTime = sendTime;
		this.text = text;
		this.imgUrl = imgUrl;
		this.responseNum = responseNum;
		this.unreadNum = unreadNum;

	}

	public String sayHiId;
	public String anchorId;
	public String nickName;
	public String cover;
	public String avatar;
	public int	  age;
	public int    sendTime;
	public String text;
	public String imgUrl;
	public int    responseNum;
	public int    unreadNum;

	@Override
	public String toString() {
		return "SayHiDetailAnchorItem[sayHiId:"+sayHiId
				+ " anchorId:"+anchorId
				+ " nickName:"+nickName
				+ " cover:"+cover
				+ " avatar:"+avatar
				+ " age:"+age
				+ " sendTime:"+sendTime
				+ " text:"+text
				+ " imgUrl:"+imgUrl
				+ " responseNum:"+responseNum
				+ " unreadNum:"+unreadNum
				+ "]";
	}
}
