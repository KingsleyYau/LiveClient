package com.qpidnetwork.livemodule.livechathttprequest;

import com.qpidnetwork.livemodule.livechathttprequest.item.ThemeConfig;

public interface OnLCGetThemeConfigCallback {
    public void OnLCGetThemeConfig(boolean isSuccess, String errno, String errmsg, ThemeConfig config);
}
