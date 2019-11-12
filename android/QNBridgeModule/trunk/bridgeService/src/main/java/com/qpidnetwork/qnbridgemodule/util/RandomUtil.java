package com.qpidnetwork.qnbridgemodule.util;

/**
 * Created by Hardy on 2019/10/9.
 */
public class RandomUtil {

    /**
     * 在给定的最大与最小值之间，产生随机数
     *
     * @param min 最小值
     * @param max 最大值
     * @return
     */
    public static int getRandom(int min, int max) {
        return (int) (Math.random() * (max - min) + min);
    }
}
