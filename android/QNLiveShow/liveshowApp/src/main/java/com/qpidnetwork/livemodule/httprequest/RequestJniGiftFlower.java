package com.qpidnetwork.livemodule.httprequest;

/**
 * 鲜花礼品相关接口
 * @author Hunter Mun
 *
 */
public class RequestJniGiftFlower {
	
	/**
	 * 15.1.获取鲜花礼品列表
	 * @param anchorId	主播ID（可无）
	 * @param callback
	 * @return
	 */
	static public native long GetStoreGiftList(String anchorId, OnGetStoreGiftListCallback callback);
	
	/**
	 * 15.2.获取鲜花礼品详情
	 * @param giftId 		礼物ID
	 * @param callback
	 * @return
	 */
	static public native long GetFlowerGiftDetail(String giftId, OnGetFlowerGiftDetailCallback callback);
	
//	/**
//	 * 15.3.获取推荐鲜花礼品列表(暂时不用)
//	 * @param giftId			礼品ID
//	 * @param anchorId			主播ID
//	 * @param number			数量
//	 * @param callback
//	 * @return
//	 */
//	static public native long GetRecommendGiftList(String giftId, String anchorId, int number, OnGetRecommendGiftListCallback callback);
//
//	/**
//	 * 15.4.获取Resent Recipient主播列表(暂时不用)
//	 * @param rideId
//	 * @return
//	 */
//	static public native long GetResentRecipientList(OnGetResentRecipientListCallback callback);
	
	/**
	 * 15.5.获取My delivery列表
	 * @param callback
	 * @return
	 */
	static public native long GetDeliveryList(OnGetDeliveryListCallback callback);

	/**
	 * 15.6.获取购物车礼品种类数
	 * @param callback
	 * @return
	 */
	static public native long GetCartGiftTypeNum(String anchorId, OnGetCartGiftTypeNumCallback callback);

	/**
	 * 15.7.获取购物车My cart列表
	 * @param start                         起始，用于分页，表示从第几个元素开始获取
	 * @param step                          步长，用于分页，表示本次请求获取多少个元素
	 * @param callback
	 * @return
	 */
	static public native long GetCartGiftList(int start, int step, OnGetCartGiftListCallback callback);

	/**
	 * 15.8.添加购物车商品
	 * @param anchorId                       主播ID
	 * @param giftId                         礼品ID
	 * @param callback
	 * @return
	 */
	static public native long AddCartGift(String anchorId, String giftId, OnRequestCallback callback);

	/**
	 * 15.9.修改购物车商品数量
	 * @param anchorId                      主播ID
	 * @param giftId                        礼品ID
	 * @param giftNumber					礼品数量
	 * @param callback
	 * @return
	 */
	static public native long ChangeCartGiftNumber(String anchorId, String giftId, int giftNumber, OnRequestCallback callback);


	/**
	 * 15.10.删除购物车商品
	 * @param anchorId                      主播ID
	 * @param giftId                        礼品ID
	 * @param callback
	 * @return
	 */
	static public native long RemoveCartGift(String anchorId, String giftId, OnRequestCallback callback);

	/**
	 * 15.11.Checkout商品
	 * @param anchorId                      主播ID
	 * @param callback
	 * @return
	 */
	static public native long CheckOutCartGift(String anchorId, OnCheckOutCartGiftCallback callback);

	/**
	 * 15.12.生成订单
	 * @param anchorId                         主播ID
	 * @param greetingMessage                  文本信息
	 * @param specialDeliveryRequest           文本信息
	 * @param callback
	 * @return
	 */
	static public native long CreateGiftOrder(String anchorId, String greetingMessage, String specialDeliveryRequest, OnCreateGiftOrderCallback callback);

}
