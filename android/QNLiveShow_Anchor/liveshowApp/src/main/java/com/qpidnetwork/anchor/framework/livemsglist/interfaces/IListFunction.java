package com.qpidnetwork.anchor.framework.livemsglist.interfaces;


import com.qpidnetwork.anchor.framework.livemsglist.LiveMessageListAdapter;

/**
 * Created by Jagger on 2017/6/2.
 */

public interface IListFunction {

    /**
     * setAdapter
     * @param adapter
     */
    void setAdapter(LiveMessageListAdapter adapter);

    /**
     * 插入新消息
     * @param item
     */
    void addNewLiveMsg(Object item);

    /**
     * 列表 、 缓存 各最大保存消息数据
     * @param maxMsgSum
     */
    void setMaxMsgSum(int maxMsgSum);

    /**
     * 列表停留在历史信息时长
     * @param time 毫秒
     */
    void setHoldingTime(int time);
}
