package com.qpidnetwork.anchor.httprequest;

import com.qpidnetwork.anchor.httprequest.item.EmotionCategory;

public interface OnGetEmotionListCallback {
	public void onGetEmotionList(boolean isSuccess, int errCode, String errMsg, EmotionCategory[] emotionCategoryList);
}
