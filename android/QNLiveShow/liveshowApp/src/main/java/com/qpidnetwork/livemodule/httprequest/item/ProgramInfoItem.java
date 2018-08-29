package com.qpidnetwork.livemodule.httprequest.item;

/**
 * 节目信息Item
 * @author Hunter Mun
 *
 */
public class ProgramInfoItem {

	public ProgramInfoItem(){

	}

	/**
	 * 节目信息Item
	 * @param showLiveId		节目ID
	 * @param anchorId			主播ID
	 * @param anchorNickname	主播昵称
	 * @param anchorAvatar		主播头像url
	 * @param showTitle			节目名称
	 * @param showIntroduce		节目介绍
	 * @param cover				节目封面图url
	 * @param approveTime		审核通过时间（1970年起的秒数）
	 * @param startTime			节目开播时间（1970年起的秒数）
	 * @param duration			节目时长
	 * @param leftSecToStart	开始开播剩余时间
	 * @param leftSecToEnter	可进入过渡页的剩余时间（秒）
	 * @param price				节目价格
	 * @param status			节目状态（0：未审核，1：审核通过，2：审核被拒，3：节目正常结束，4：节目已取消，5：节目已超时）
	 * @param ticketStatus		购票状态（UnBuy：未购票，Buy：已购票，Refund：已退票）
	 * @param isHasFollow		是否已关注
	 * @param isTicketFull		是否已满座

	 */
	public ProgramInfoItem(String showLiveId,
						   String anchorId,
						   String anchorNickname,
						   String anchorAvatar,
						   String showTitle,
						   String showIntroduce,
						   String cover,
						   int approveTime,
						   int startTime,
						   int duration,
						   int leftSecToStart,
						   int leftSecToEnter,
						   double price,
						   int status,
						   int ticketStatus,
						   boolean isHasFollow,
						   boolean isTicketFull){
		this.showLiveId = showLiveId;
		this.anchorId = anchorId;
		this.anchorNickname = anchorNickname;
		this.anchorAvatar = anchorAvatar;
		this.showTitle = showTitle;
		this.showIntroduce = showIntroduce;
		this.cover = cover;

		this.approveTime = approveTime;
		this.startTime = startTime;
		this.duration = duration;
		this.leftSecToStart = leftSecToStart;
		this.leftSecToEnter = leftSecToEnter;
		this.price = price;

		if( status < 0 || status >= ProgramStatus.values().length ) {
			this.status = ProgramStatus.UnVerify;
		} else {
			this.status = ProgramStatus.values()[status];
		}
		if( ticketStatus < 0 || ticketStatus >= ProgramTicketStatus.values().length ) {
			this.ticketStatus = ProgramTicketStatus.UnBuy;
		} else {
			this.ticketStatus = ProgramTicketStatus.values()[ticketStatus];
		}
		this.isHasFollow = isHasFollow;
		this.isTicketFull = isTicketFull;

	}
	
	public String showLiveId;
	public String anchorId;
	public String anchorNickname;
	public String anchorAvatar;
	public String showTitle;
	public String showIntroduce;
	public String cover;
	public int approveTime;
	public int startTime;
	public int duration;
	public int leftSecToStart;
	public int leftSecToEnter;
	public double price;
	public ProgramStatus status;
	public ProgramTicketStatus ticketStatus;
	public boolean isHasFollow;
	public boolean isTicketFull;


	@Override
	public String toString() {
		return "ProgramInfoItem[showLiveId:"+showLiveId
				+ " anchorId:"+anchorId
				+ " anchorNickname:" + anchorNickname
				+ " anchorAvatar:" + anchorAvatar
				+ " showTitle:"+showTitle
				+ " showIntroduce:"+showIntroduce
				+ "]";
	}

	//add by Jagger 2018-4-26
	//增加一些字段 , 作为introducion item
	//由于增加列表头, 却排在分组下, 只能用这种方法
	public enum TYPE{
		Programme,		//节目
		Introduction	//说明
	}

	//--------- introduction ----------
	public int type = TYPE.Programme.ordinal();
	public String des = "";
}
