package com.qpidnetwork.liveshow.liveroom.gift.dialog;

/**
 * Description:
 * <p>
 * Created by Harry on 2017/6/26.
 */

public interface OnTimerTaskExecuteListener {

    /**
     * 定时器任务被执行时回调
     */
    void onTaskExecute(int executeCount);


    void onTaskEnd();
}
