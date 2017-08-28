package com.qpidnetwork.livemodule.httprequest;

import com.qpidnetwork.livemodule.httprequest.item.EmotionCategory;

public interface OnGetEmotionListCallback {
	public void onGetEmotionList(boolean isSuccess, int errCode, String errMsg, EmotionCategory[] emotionCategoryList);
}
