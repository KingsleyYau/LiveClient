package com.qpidnetwork.anchor.im.listener;

public class IMProgramInfoItem {
	public enum IMProgramStatus {
		UnVerify,            // 未审核
		VerifyPass,            // 审核通过
		VerifyReject,        // 审核被拒
		ProgramEnd,         // 节目正常结束
		ProgramCancel,        // 节目已取消
		OutTime                // 节目已超时
	}

	public IMProgramInfoItem(){

	}

	/**
	 * 节目信息Item
	 * @param showLiveId		节目ID
	 * @param anchorId			主播ID
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
	 * @param ticketNum			已购票数
	 * @param followNum			已关注数
	 * @param isTicketFull		是否已满座

	 */
	public IMProgramInfoItem(String showLiveId,
							 String anchorId,
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
							 int ticketNum,
							 int followNum,
							 boolean isTicketFull){
		this.showLiveId = showLiveId;
		this.anchorId = anchorId;
		this.showTitle = showTitle;
		this.showIntroduce = showIntroduce;
		this.cover = cover;

		this.approveTime = approveTime;
		this.startTime = startTime;
		this.duration = duration;
		this.leftSecToStart = leftSecToStart;
		this.leftSecToEnter = leftSecToEnter;
		this.price = price;

		if( status < 0 || status >= IMProgramStatus.values().length ) {
			this.status = IMProgramStatus.UnVerify;
		} else {
			this.status = IMProgramStatus.values()[status];
		}
		this.ticketNum = ticketNum;
		this.followNum = followNum;
		this.isTicketFull = isTicketFull;
	}

	public String showLiveId;
	public String anchorId;
	public String showTitle;
	public String showIntroduce;
	public String cover;
	public int approveTime;
	public int startTime;
	public int duration;
	public int leftSecToStart;
	public int leftSecToEnter;
	public double price;
	public IMProgramStatus status;
	public int ticketNum;
	public int followNum;
	public boolean isTicketFull;
}
