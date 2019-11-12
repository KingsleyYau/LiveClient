package com.qpidnetwork.livemodule.httprequest.item;

/**
 * Created by Hardy on 2019/5/29.
 * <p>
 * Say Hi 的 all 和 response 列表数据的基类
 * 为了在 adapter 使用时统一数据 bean
 */
public interface SayHiBaseListItem {

    public static final int DATA_TYPE_ALL = 0;
    public static final int DATA_TYPE_RESPONSE = 1;

    /**
     * 获取数据类型
     */
    int getDataType();
}
