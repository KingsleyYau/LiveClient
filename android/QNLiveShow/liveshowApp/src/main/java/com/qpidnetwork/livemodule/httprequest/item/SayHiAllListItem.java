package com.qpidnetwork.livemodule.httprequest.item;

import com.qpidnetwork.livemodule.utils.DateUtil;

/**
 * Say Hi的All列表Item
 * @author Alex
 *
 */
public class SayHiAllListItem implements SayHiBaseListItem{

	public SayHiAllListItem(){

	}

	/**
	 * Say Hi的All列表Item
	 * @param sayHiId		sayHi的ID
	 * @param anchorId		主播ID
	 * @param nickName		主播昵称
	 * @param cover			主播封面
	 * @param avatar		主播头像
	 * @param age			主播年龄
	 * @param sendTime		发送时间戳（1970年起的秒数）
	 * @param content		回复内容的摘要（可无，没有回复则为无或空）
	 * @param responseNum	回复数
	 * @param unreadNum		未读数
	 * @param isFree		是否免费（1：是，0：否）
	 */
	public SayHiAllListItem(
						 String sayHiId,
                         String anchorId,
                         String nickName,
						 String cover,
						 String avatar,
						 int age,
						 int sendTime,
						 String content,
						 int responseNum,
						 int unreadNum,
						 boolean isFree){
		this.sayHiId = sayHiId;
		this.anchorId = anchorId;
		this.nickName = nickName;
		this.cover = cover;
		this.avatar = avatar;
		this.age = age;
		this.sendTime = sendTime;
		this.content = content;
		this.responseNum = responseNum;
		this.unreadNum = unreadNum;
		this.isFree = isFree;

		// 2019/5/29 Hardy
		sendTimeString = DateUtil.getCurYearDateString(sendTime * 1000L);
	}

	public String sayHiId;
	public String anchorId;
	public String nickName;
	public String cover;
	public String avatar;
	public int    age;
	public int    sendTime;
	public String content;
	public int    responseNum;
	public int    unreadNum;
	public boolean isFree;

	// 2019/5/29	Hardy
	public String sendTimeString;


	@Override
	public String toString() {
		return "SayHiAllListItem[sayHiId:"+sayHiId
				+ " anchorId:"+anchorId
				+ " nickName:"+nickName
				+ " cover:"+cover
				+ " avatar:"+avatar
				+ " age:"+age
				+ " sendTime:"+sendTime
				+ " content:"+content
				+ " responseNum:"+responseNum
				+ " unreadNum:"+unreadNum
				+ " isFree:"+isFree
				+ "]";
	}

	@Override
	public int getDataType() {
		return DATA_TYPE_ALL;
	}
}
