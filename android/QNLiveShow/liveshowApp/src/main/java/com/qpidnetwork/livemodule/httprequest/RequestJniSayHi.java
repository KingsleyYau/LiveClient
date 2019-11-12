package com.qpidnetwork.livemodule.httprequest;

/**
 * SayHi相关接口
 * @author Hunter Mun
 * @since 2017-5-22
 */
public class RequestJniSayHi {
	
	//SayHi回复列表操作类型
	public enum SayHiListOperateType{
		Unkown,		// 未知
		UnRead,		// 未读
		Latest		// 最新
	}

	//SayHi详情回复排序操作类型
	public enum SayHiDetailOperateType{
		Unkown,		// 未知
		Earliest,	// 最早
		Latest,		// 最新
		UnRead		// 未读

	}
	
	/**
	 * 14.1.获取发送SayHi的主题和文本信息（用于观众端获取发送SayHi的主题和文本信息）
	 * @param callback
	 * @return
	 */
	static public native long GetSayHiResourceConfig(OnGetSayHiResourceConfigCallback callback);
	
	/**
	 * 14.2.获取可发Say Hi的主播列表
	 * @param callback
	 * @return
	 */
	static public native long GetSayHiAnchorList(OnGetSayHiAnchorListCallback callback);
	
	/**
	 * 14.3.检测能否对指定主播发送SayHi（用于检测能否对指定主播发送SayHi）
	 * @param anchorId 		主播ID
	 * @param callback
	 * @return
	 */
	static public native long IsCanSendSayHi(String anchorId, OnIsCanSendSayHiCallback callback);
	
	/**
	 * 14.4.发送sayHi
	 * @param anchorId			主播ID
	 * @param themeId			主题ID
	 * @param textId			文本ID
	 * @param callback
	 * @return
	 */
	static public native long SendSayHi(String anchorId, String themeId, String textId, OnSendSayHiCallback callback);
	
	/**
	 * 14.5.获取Say Hi的All列表
	 * @param start		起始，用于分页，表示从第几个元素开始获取
	 * @param step		步长，用于分页，表示本次请求获取多少个元素
	 * @param callback
	 * @return
	 */
	static public native long GetAllSayHiList(int start, int step, OnGetAllSayHiListCallback callback);
	
	/**
	 * 14.6.获取SayHi的Response列表
	 * @param start		起始，用于分页，表示从第几个元素开始获取
	 * @param step		步长，用于分页，表示本次请求获取多少个元素
	 * @param type 		获取Response列表类型
	 * @param callback
	 * @return
	 */
	static public long GetResponseSayHiList(int start, int step, SayHiListOperateType type, OnGetResponseSayHiListCallback callback){
		return GetResponseSayHiList(start, step, type.ordinal(), callback);
	}
	static public native long GetResponseSayHiList(int start, int step, int type, OnGetResponseSayHiListCallback callback);
	
	/**
	 * 14.7.获取SayHi详情
	 * @param sayHiId		SayHi的ID
	 * @param type			SayHi的详情回复排序类型
	 * @param callback
	 * @return
	 */
	static public long GetSayHiDetail(String sayHiId, SayHiDetailOperateType type, OnGetSayDetailCallback callback) {
		return GetSayHiDetail(sayHiId, type.ordinal(), callback);
	}
	static public native long GetSayHiDetail(String sayHiId, int type, OnGetSayDetailCallback callback);
	
	/**
	 * 14.8.购买阅读SayHi回复详情 （用于购买阅读SayHi回复）
	 * @param sayHiId		SayHi的ID
	 * @param responseId	回复ID
	 * @param callback
	 * @return
	 */
	static public native long ReadSayHiResponse(String sayHiId, String responseId, OnReadSayHiResponseCallback callback);

	
}
