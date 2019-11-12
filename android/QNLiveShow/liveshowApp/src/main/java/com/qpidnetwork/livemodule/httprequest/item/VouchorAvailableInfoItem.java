package com.qpidnetwork.livemodule.httprequest.item;

/**
 * 试用券可用列表Item
 * @author Hunter Mun
 *
 */
public class VouchorAvailableInfoItem {

	public VouchorAvailableInfoItem(){

	}

	/**
	 * 试用券可用列表结构体Item
	 * @param onlypublicExpTime			仅公开直播（且不限制主播且不限制新关系）试用券到期时间（1970年起的秒数）
	 * @param onlyprivateExpTime		仅私密直播（且不限制主播且不限制新关系）试用券到期时间（1970年起的秒数）
	 * @param svrList					绑定主播列表[
	 *                                  		主播ID,
	 *                               			可用的直播间类型（0：不限，1：公开，2：私密）,
	 *                       					试用券到期时间（1970年起的秒数）
	 *                                     ]
	 * @param onlypublicNewExpTime			仅公开的新关系试用券到期时间（1970年起的秒数）
	 * @param onlyprivateNewExpTime			仅私密的新关系试用券到期时间（1970年起的秒数）
	 * @param watchedAnchor				我看过的主播列表[主播ID]
	 */
	public VouchorAvailableInfoItem(long onlypublicExpTime,
									long onlyprivateExpTime,
									BindAnchorItem[] svrList,
									long onlypublicNewExpTime,
									long onlyprivateNewExpTime,
									String[] watchedAnchor){
		this.onlypublicExpTime = onlypublicExpTime;
		this.onlyprivateExpTime = onlyprivateExpTime;
		this.svrList = svrList;
		this.onlypublicNewExpTime = onlypublicNewExpTime;
		this.onlyprivateNewExpTime = onlyprivateNewExpTime;
		this.watchedAnchor = watchedAnchor;

	}
	
	public long onlypublicExpTime;
	public long onlyprivateExpTime;
	public BindAnchorItem[] svrList;
	public long onlypublicNewExpTime;
	public long onlyprivateNewExpTime;
	public String[] watchedAnchor;


	@Override
	public String toString() {
		return "VouchorAvailableInfoItem[onlypublicExpTime:"+onlypublicExpTime
				+ " onlyprivateExpTime:"+onlyprivateExpTime
				+ " onlypublicNewExpTime:"+onlypublicNewExpTime
				+ " onlyprivateNewExpTime:"+onlyprivateNewExpTime
				+ "]";
	}
}
