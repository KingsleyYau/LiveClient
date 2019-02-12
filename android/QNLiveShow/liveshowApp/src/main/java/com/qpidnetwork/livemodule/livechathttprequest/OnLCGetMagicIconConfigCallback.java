package com.qpidnetwork.livemodule.livechathttprequest;

import com.qpidnetwork.livemodule.livechathttprequest.item.MagicIconConfig;

public interface OnLCGetMagicIconConfigCallback {
    public void OnLCGetMagicIconConfig(boolean isSuccess, String errno, String errmsg, MagicIconConfig config);
}
