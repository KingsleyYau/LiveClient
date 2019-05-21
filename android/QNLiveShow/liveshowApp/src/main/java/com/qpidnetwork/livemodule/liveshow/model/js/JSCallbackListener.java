package com.qpidnetwork.livemodule.liveshow.model.js;

import com.qpidnetwork.livemodule.httprequest.item.HangoutAnchorInfoItem;
import com.qpidnetwork.livemodule.liveshow.model.NoMoneyParamsBean;

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

    /**
     * 2.2.8控制导航栏显示/隐藏
     * @param isShow
     */
    void onEventShowNavigation(String isShow);

    /**
     * 显示主播好友头像
     * @param item
     */
    void onShowHangoutAnchor(HangoutAnchorInfoItem item);
}
