package com.qpidnetwork.livemodule.livechathttprequest;

import com.qpidnetwork.livemodule.livechathttprequest.item.ThemeItem;

public interface OnLCGetThemeDetailCallback {
    public void OnLCGetThemeDetail(boolean isSuccess, String errno, String errmsg, ThemeItem[] themeList);
}
