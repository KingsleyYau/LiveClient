package com.qpidnetwork.livemodule.liveshow.bubble;

/**
 * Created by zy2 on 2019/3/5.
 */
public interface IOnHangoutMsgPopListener {

    /**
     * item 的 hang out 点击事件
     *
     * @param pos
     */
    void onHandoutClick(int pos);

    /**
     * 滚动过程中选中哪个 item 的回调
     *
     * @param pos
     */
    void onScrollItemChange(int pos);
}
