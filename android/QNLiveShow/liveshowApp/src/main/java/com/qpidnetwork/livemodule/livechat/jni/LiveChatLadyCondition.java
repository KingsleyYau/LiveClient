package com.qpidnetwork.livemodule.livechat.jni;


/**
 * 获取女士择偶条件item
 * @author Samson Fan
 *
 */
public class LiveChatLadyCondition {
	public LiveChatLadyCondition() {
		
	}
	
	public LiveChatLadyCondition(
			String womanId, 
			boolean marriageCondition,	// 是否判断婚姻状况
			boolean neverMarried,				// 是否从未结婚
			boolean divorced,					// 是否离婚
			boolean widowed,					// 是否丧偶
			boolean separated,					// 是否分居
			boolean married,					// 是否已婚
			boolean childCondition,			// 是否判断子女状况
			boolean noChild,					// 是否没有子女
			boolean countryCondition,		// 是否判断国籍
			boolean unitedstates,				// 是否美国国籍
			boolean canada,						// 是否加拿大国籍
			boolean newzealand,					// 是否新西兰国籍
			boolean australia,					// 是否澳大利亚国籍
			boolean unitedkingdom,				// 是否英国国籍
			boolean germany,					// 是否德国国籍
			boolean othercountries,				// 是否其它国籍
			int startAge,					// 起始年龄
			int endAge						// 结束年龄
			) 
	{
		this.womanId = womanId;
		this.marriageCondition = marriageCondition; 	
		this.neverMarried = neverMarried;
		this.divorced = divorced;
		this.widowed = widowed;	
		this.separated = separated;	
		this.married = 	married;
		this.childCondition = childCondition;	
		this.noChild = noChild;
		this.countryCondition = countryCondition; 
		this.unitedstates = unitedstates;
		this.canada = canada;
		this.newzealand = newzealand;		
		this.australia = australia;
		this.unitedkingdom = unitedkingdom;
		this.germany = germany;
		this.othercountries = othercountries;	
		this.startAge = startAge;
		this.endAge = endAge;	
	}
	
	/**
	 * 女士ID
	 */
	public String womanId; 
	
	/**
	 * 是否判断婚姻状况
	 */
	public boolean marriageCondition;
	
	/**
	 * 是否从未结婚
	 */
	public boolean neverMarried;
	
	/**
	 * 是否离婚
	 */
	public boolean divorced;
	
	/**
	 * 是否丧偶
	 */
	public boolean widowed;
	
	/**
	 * 是否分居
	 */
	public boolean separated;
	
	/**
	 * 是否已婚
	 */
	public boolean married;
	
	/**
	 * 是否判断子女状况
	 */
	public boolean childCondition;
	
	/**
	 * 是否没有子女
	 */
	public boolean noChild;
	
	/**
	 * 是否判断国籍
	 */
	public boolean countryCondition;
	
	/**
	 * 是否美国国籍
	 */
	public boolean unitedstates;
	
	/**
	 * 是否加拿大国籍
	 */
	public boolean canada;
	
	/**
	 * 是否新西兰国籍
	 */
	public boolean newzealand;
	
	/**
	 * 是否澳大利亚国籍
	 */
	public boolean australia;
	
	/**
	 * 是否英国国籍
	 */
	public boolean unitedkingdom;
	
	/**
	 * 是否德国国籍
	 */
	public boolean germany;
	
	/**
	 * 是否其它国籍
	 */
	public boolean othercountries;
	
	/**
	 * 起始年龄
	 */
	public int startAge;
	
	/**
	 * 结束年龄
	 */
	public int endAge;
}
