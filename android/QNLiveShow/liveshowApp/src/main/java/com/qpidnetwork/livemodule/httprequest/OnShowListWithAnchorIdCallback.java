package com.qpidnetwork.livemodule.httprequest;
import com.qpidnetwork.livemodule.httprequest.item.ProgramInfoItem;

/**
 * 获取节目推荐列表回调
 * @author Hunter Mun
 * @since 2017-5-22
 */
public interface OnShowListWithAnchorIdCallback {

	public void onShowListWithAnchorId(boolean isSuccess, int errCode, String errMsg, ProgramInfoItem[] array);
}
