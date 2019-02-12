package com.qpidnetwork.livemodule.utils;

import java.util.List;

/**
 * Created by Hardy on 2018/9/19.
 * List 工具类
 */
public class ListUtils {

    private ListUtils() {
    }

    /**
     * 判断List是否为空,非空返回true,空则返回false
     *
     * @param list
     * @return boolean
     */
    public static boolean isList(List<?> list) {
        if (null != list) {
            if (list.size() > 0)
                return true;
        }
        return false;
    }


    /**
     * 是否为有效的 position
     *
     * @param mList
     * @param pos
     * @return
     */
    public static boolean isValidPosition(List<?> mList, int pos) {
        return mList != null && pos >= 0 && pos < mList.size();
    }
}
