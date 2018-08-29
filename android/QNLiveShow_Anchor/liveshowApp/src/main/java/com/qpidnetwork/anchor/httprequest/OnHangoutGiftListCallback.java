package com.qpidnetwork.anchor.httprequest;


import com.qpidnetwork.anchor.httprequest.item.AnchorHangoutGiftListItem;

/**
 * 6.8.获取多人互动直播间礼物列表
 * @author Hunter Mun
 * @since 2017-5-22
 */
public interface OnHangoutGiftListCallback {
	public void onHangoutGiftList(boolean isSuccess, int errCode, String errMsg, AnchorHangoutGiftListItem giftItem);
}
