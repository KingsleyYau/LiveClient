package com.qpidnetwork.livemodule.httprequest.item;

import com.qpidnetwork.livemodule.utils.DateUtil;

/**
 * Say Hi的Response列表Item
 * @author Alex
 *
 */
public class SayHiResponseListItem implements SayHiBaseListItem{

	public SayHiResponseListItem(){

	}

	/**
	 * Say Hi的Response列表Item
	 * @param sayHiId		sayHi的ID
	 * @param responseId	回复ID
	 * @param anchorId		主播ID
	 * @param nickName		主播昵称
	 * @param cover			主播封面
	 * @param avatar		主播头像
	 * @param age			主播年龄
	 * @param responseTime	回复时间戳
	 * @param content		回复内容的摘要
	 * @param hasImg		是否有图片
	 * @param hasRead		是否已读
	 * @param isFree		是否免费（1：是，0：否）
	 */
	public SayHiResponseListItem(
						 String sayHiId,
						 String responseId,
                         String anchorId,
                         String nickName,
						 String cover,
						 String avatar,
						 int age,
						 int responseTime,
						 String content,
						 boolean hasImg,
						 boolean hasRead,
						 boolean isFree){
		this.sayHiId = sayHiId;
		this.responseId = responseId;
		this.anchorId = anchorId;
		this.nickName = nickName;
		this.cover = cover;
		this.avatar = avatar;
		this.age = age;
		this.responseTime = responseTime;
		this.content = content;
		this.hasImg = hasImg;
		this.hasRead = hasRead;
		this.isFree = isFree;

		// 2019/5/29 Hardy
		responseTimeString = DateUtil.getCurYearDateString(responseTime * 1000L);
	}

	public String sayHiId;
	public String responseId;
	public String anchorId;
	public String nickName;
	public String cover;
	public String avatar;
	public int    age;
	public int    responseTime;
	public String content;
	public boolean hasImg;
	public boolean hasRead;
	public boolean isFree;

	// 2019/5/29	Hardy
	public String responseTimeString;

	@Override
	public String toString() {
		return "SayHiResponseListItem[sayHiId:"+sayHiId
				+ " responseId:"+responseId
				+ " anchorId:"+anchorId
				+ " nickName:"+nickName
				+ " cover:"+cover
				+ " avatar:"+avatar
				+ " age:"+age
				+ " responseTime:"+responseTime
				+ " content:"+content
				+ " hasImg:"+hasImg
				+ " hasRead:"+hasRead
				+ " isFree:"+isFree
				+ "]";
	}

	@Override
	public int getDataType() {
		return DATA_TYPE_RESPONSE;
	}
}
