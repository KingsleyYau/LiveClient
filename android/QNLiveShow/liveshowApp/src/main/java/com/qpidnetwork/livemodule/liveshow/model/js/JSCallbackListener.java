package com.qpidnetwork.livemodule.liveshow.model.js;

import com.qpidnetwork.livemodule.liveshow.bean.NoMoneyParamsBean;

/**
 * Created by Hunter Mun on 2017/11/10.
 */

public interface JSCallbackListener {
    /**
     * 关闭界面通知
     */
    void onEventClose();

    /**
     * 页面出错通知
     * @param errorcode
     * @param errMsg
     * @param params
     */
    void onEventPageError(String errorcode, String errMsg, NoMoneyParamsBean params);
}
