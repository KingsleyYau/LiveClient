package com.qpidnetwork.livemodule.httprequest;


import com.qpidnetwork.livemodule.httprequest.item.LSOrderType;
import com.qpidnetwork.livemodule.httprequest.item.LSValidateCodeType;

/**
 * 7. 支付相关接口
 * @author Hunter Mun
 * @since 2017-6-8
 */
public class RequestJniPayment {
	
	/**
	 * 7.7. 获取h5买点页面URL（仅Android）
	 * @param orderType	购买产品类型（credit：信用点，flowerGift：鲜花礼品, monthFree：月费服务，stamp：邮票）
	 * @param clickFrom  点击来源（Axx表示不可切换，Bxx表示可切换）（可""，""则表示不指定）
	 * @param numberId   已选中的充值包ID（可""，""表示不指定充值包）
	 * @param orderNo	  鲜花礼品订单ID（可无，无或空表示无订单ID）
	 * @param callback
	 * @return
	 */
	static public long MobilePayGoto(LSOrderType orderType, String clickFrom, String numberId, String orderNo, OnMobilePayGotoCallback callback) {
		return MobilePayGoto(orderType.ordinal(), clickFrom, numberId, orderNo, callback);
	}

	static private native long MobilePayGoto(int orderType, String clickFrom, String numberId, String orderNo, OnMobilePayGotoCallback callback);

}
